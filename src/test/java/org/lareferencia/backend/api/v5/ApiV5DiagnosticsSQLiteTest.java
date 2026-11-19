package org.lareferencia.backend.api.v5;

import java.nio.file.Path;
import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.lareferencia.backend.security.LocalAuthorizationService;
import org.lareferencia.core.domain.Network;
import org.lareferencia.core.domain.NetworkSnapshot;
import org.lareferencia.core.metadata.ISnapshotStore;
import org.lareferencia.core.metadata.SnapshotMetadata;
import org.lareferencia.core.repository.jpa.NetworkSnapshotRepository;
import org.lareferencia.core.repository.validation.RecordValidationRepository;
import org.lareferencia.core.repository.validation.RuleOccurrenceRepository;
import org.lareferencia.core.repository.validation.ValidationDatabaseManager;
import org.lareferencia.core.service.validation.ValidationStatisticsSQLiteService;
import org.springframework.http.MediaType;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class ApiV5DiagnosticsSQLiteTest {
    private static final long ID = 4145;
    private static final String COMPAT = "/api/v5/dashboard/validation/source/FIX/4145/records";
    private static final String NATIVE = "/api/v5/snapshots/4145/diagnostics/";
    private final ValidationDatabaseManager databases = new ValidationDatabaseManager();
    private final ObjectMapper json = new ObjectMapper();
    private MockMvc mvc;

    @BeforeEach
    void setUp(@TempDir Path directory) throws Exception {
        var network = new Network();
        network.setAcronym("FIX");
        var snapshot = new NetworkSnapshot();
        snapshot.setNetwork(network);
        ReflectionTestUtils.setField(snapshot, "id", ID);
        var metadata = new SnapshotMetadata();
        metadata.setSnapshotId(ID);
        metadata.setNetwork(network);
        metadata.registerRule(7L, "Idioma", "", "ONE_OR_MORE", true);

        ReflectionTestUtils.setField(databases, "basePath", directory.toString());
        databases.initializeSnapshot(metadata, List.of(7L));
        try (var conn = databases.getDataSource(ID).getConnection(); var sql = conn.createStatement()) {
            sql.executeUpdate("INSERT INTO record_validation (identifier_hash,identifier,is_valid,is_transformed,rule_7) VALUES ('a','oai:1',1,0,1),('b','oai:10',0,1,0),('c','oai:%_!\"@@',1,0,1)");
            sql.executeUpdate("INSERT INTO rule_occurrences (identifier_hash,rule_id,is_valid,occurrence_value) VALUES ('a',7,1,'es'),('a',7,1,'es'),('a',7,0,'mixed'),('b',7,0,'?')");
            sql.executeUpdate("INSERT INTO record_validation (identifier_hash,identifier,is_valid,is_transformed,rule_7,deleted) VALUES ('d','oai:deleted',1,0,1,1)");
            sql.executeUpdate("INSERT INTO rule_occurrences (identifier_hash,rule_id,is_valid,occurrence_value) VALUES ('d',7,1,'removed')");
        }
        var records = new RecordValidationRepository();
        var occurrences = new RuleOccurrenceRepository();
        ReflectionTestUtils.setField(records, "dbManager", databases);
        ReflectionTestUtils.setField(occurrences, "dbManager", databases);
        var store = mock(ISnapshotStore.class);
        when(store.getSnapshotMetadata(ID)).thenReturn(metadata);
        var stats = new ValidationStatisticsSQLiteService();
        ReflectionTestUtils.setField(stats, "basePath", directory.toString());
        ReflectionTestUtils.setField(stats, "dbManager", databases);
        ReflectionTestUtils.setField(stats, "recordRepository", records);
        ReflectionTestUtils.setField(stats, "occurrenceRepository", occurrences);
        ReflectionTestUtils.setField(stats, "snapshotStore", store);

        var snapshots = mock(NetworkSnapshotRepository.class);
        when(snapshots.findById(ID)).thenReturn(java.util.Optional.of(snapshot));
        var auth = mock(LocalAuthorizationService.class);
        var compat = new ApiV5DashboardCompatibilityController(null, snapshots, stats, auth, null);
        var diagnostics = new ApiV5DiagnosticsController(new ApiV5DiagnosticsService(snapshots, null, stats, null, store, auth));
        mvc = MockMvcBuilders.standaloneSetup(compat, diagnostics).build();
    }

    @AfterEach
    void close() {
        databases.cleanup();
    }

    @ParameterizedTest
    @CsvSource({"is_valid,false", "is_transformed,true", "invalid_rules,7"})
    void compatibleFiltersReturnOnlyTheRejectedRecord(String field, String value) throws Exception {
        mvc.perform(get(COMPAT).accept(MediaType.APPLICATION_JSON).param(field, value))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalElements").value(1))
                .andExpect(jsonPath("$.content.length()").value(1))
                .andExpect(jsonPath("$.content[0].identifier").value("oai:10"));
    }

    @Test
    void compatibleRuleFilterPaginatesAfterFilteringAndCombinesWithValidity() throws Exception {
        mvc.perform(get(COMPAT).accept(MediaType.APPLICATION_JSON).param("valid_rules", "7").param("pageNumber", "1").param("pageSize", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalElements").value(2))
                .andExpect(jsonPath("$.content[0].identifier").value("oai:1"));
        mvc.perform(get(COMPAT).accept(MediaType.APPLICATION_JSON).param("is_valid", "true").param("invalid_rules", "7"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalElements").value(0))
                .andExpect(jsonPath("$.content.length()").value(0));
    }

    @Test
    void frequenciesCountEveryOccurrenceOfTheSelectedRecords() throws Exception {
        var filters = List.of(filter("VALID", "EQ", true), filter("RULE_VALID", "EQ", 7));
        assertEquals(2, query("summary", filters).get("size").intValue());
        assertEquals(2, query("records", filters).get("totalElements").intValue());
        var selected = query("rules/7/occurrences", filters);
        assertEquals(json.readTree("[{\"value\":\"es\",\"count\":2}]"), selected.get("valid"));
        assertEquals(json.readTree("[{\"value\":\"mixed\",\"count\":1}]"), selected.get("invalid"));
        var global = query("rules/7/occurrences", List.of());
        assertEquals(selected.get("valid"), global.get("valid"));
        assertEquals(2, global.get("invalid").size());
    }

    @ParameterizedTest
    @CsvSource({"EQ,oai:1,1", "CONTAINS,oai:1,2", "EQ,OAI:1,0", "CONTAINS,OAI:1,2",
            "EQ,oai:%_!\"@@,1", "CONTAINS,%_!\"@@,1", "CONTAINS,_,1", "CONTAINS,%,1"})
    void identifierSelectionAgreesAcrossSummaryAndRecords(String operator, String value, int count) throws Exception {
        var filters = List.of(filter("IDENTIFIER", operator, value));
        assertEquals(count, query("summary", filters).get("size").intValue());
        var page = query("records", filters);
        assertEquals(count, page.get("totalElements").intValue());
        assertEquals(count, page.get("items").size());
    }

    private Map<String, Object> filter(String field, String operator, Object value) {
        return Map.of("field", field, "operator", operator, "value", value);
    }

    private JsonNode query(String resource, List<Map<String, Object>> filters) throws Exception {
        var request = post(NATIVE + resource + "/query").accept(MediaType.APPLICATION_JSON).contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsBytes(Map.of("filters", filters)));
        var response = mvc.perform(request).andExpect(status().isOk()).andReturn().getResponse();
        return json.readTree(response.getContentAsByteArray());
    }
}
