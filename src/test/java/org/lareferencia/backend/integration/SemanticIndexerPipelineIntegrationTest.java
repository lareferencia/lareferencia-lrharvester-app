package org.lareferencia.backend.integration;

import static org.awaitility.Awaitility.await;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.timeout;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.io.StringReader;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import javax.xml.parsers.DocumentBuilderFactory;

import com.fasterxml.jackson.databind.node.ObjectNode;

import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.impl.HttpSolrClient;
import org.apache.solr.client.solrj.request.schema.FieldTypeDefinition;
import org.apache.solr.client.solrj.request.schema.SchemaRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.lareferencia.backend.app.MainApp;
import org.lareferencia.core.domain.Network;
import org.lareferencia.core.domain.NetworkSnapshot;
import org.lareferencia.core.domain.SnapshotStatus;
import org.lareferencia.core.embedding.IEmbeddingService;
import org.lareferencia.core.metadata.IMDFormatTransformer;
import org.lareferencia.core.metadata.IMetadataStore;
import org.lareferencia.core.metadata.MDFormatTransformerService;
import org.lareferencia.core.metadata.SnapshotMetadata;
import org.lareferencia.core.repository.jpa.NetworkRepository;
import org.lareferencia.core.repository.jpa.NetworkSnapshotRepository;
import org.lareferencia.core.repository.validation.RecordValidationRepository;
import org.lareferencia.core.repository.validation.ValidationDatabaseManager;
import org.lareferencia.core.repository.validation.ValidationRecord;
import org.lareferencia.core.task.ApplicationActionCatalogService;
import org.lareferencia.core.task.NetworkActionkManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.xml.sax.InputSource;

@SpringBootTest(classes = { MainApp.class,
        SemanticIndexerPipelineIntegrationTest.TestConfig.class }, properties = {
                "spring.main.allow-bean-definition-overriding=true"
        })
public class SemanticIndexerPipelineIntegrationTest extends BaseIntegrationTest {

    @TestConfiguration
    static class TestConfig {
        @Bean
        @Primary
        public MDFormatTransformerService metadataTransformerServiceMock() {
            return mock(MDFormatTransformerService.class);
        }
    }

    @Autowired
    private NetworkSnapshotRepository snapshotRepository;

    @Autowired
    private NetworkActionkManager networkActionManager;

    @Autowired
    private ValidationDatabaseManager validationDatabaseManager;

    @Autowired
    private IMetadataStore metadataStore;

    @Autowired
    private NetworkRepository networkRepository;

    @Autowired
    private RecordValidationRepository validationRepository;

    @Autowired
    private ApplicationActionCatalogService actionCatalog;

    private NetworkSnapshot snapshot;

    private static final String TITLE = "Semantic indexing integration fixture title";

    @MockitoBean
    private IEmbeddingService embeddingService;

    @Autowired
    private MDFormatTransformerService metadataTransformerService;

    @BeforeEach
    void setUp() throws Exception {
        Network network = new Network();
        network.setAcronym("TEST" + UUID.randomUUID().toString().substring(0, 8));
        network.setName("Semantic integration test");
        network.setInstitutionName("Test institution");
        network.setAttributes(new HashMap<>());
        network.getProperties().put("INDEX_SEMANTIC", true);
        network = networkRepository.saveAndFlush(network);
        ObjectNode actionConfiguration = (ObjectNode) actionCatalog
                .require("legacy", "SEMANTIC_INDEXING_ACTION").getConfiguration().deepCopy();
        actionCatalog.replace("legacy", "SEMANTIC_INDEXING_ACTION", true, actionConfiguration, "test");
        networkActionManager.reconcileNetwork(network);

        snapshot = new NetworkSnapshot();
        snapshot.setNetwork(network);
        snapshot.setStatus(SnapshotStatus.VALID);
        snapshot.setEndTime(LocalDateTime.now());
        snapshot.setSize(1);
        snapshot.setValidSize(1);
        snapshot = snapshotRepository.saveAndFlush(snapshot);
        SnapshotMetadata metadata = new SnapshotMetadata(snapshot);

        String xmlContent = "<metadata><element name=\"dc\"><element name=\"title\">"
                + "<element name=\"none\"><field name=\"value\">" + TITLE
                + "</field></element></element></element></metadata>";
        String hash = metadataStore.storeAndReturnHash(metadata, xmlContent);
        validationDatabaseManager.initializeSnapshot(metadata, Collections.emptyList());
        validationRepository.registerRuleIds(snapshot.getId(), Collections.emptyList());
        String identifier = "oai:test:semantic-fixture";
        String identifierHash = org.lareferencia.core.repository.catalog.OAIRecord.generateIdFromIdentifier(identifier);
        ValidationRecord record = new ValidationRecord(identifierHash, identifier, LocalDateTime.now(),
                true, false, hash, Collections.emptyMap());
        validationRepository.insertBatch(snapshot.getId(), List.of(record));

        // Declare the fields needed by this integration against Solr's default
        // configset. Production schema and external embedding APIs are independent.
        try (HttpSolrClient client = solrClient()) {
            FieldTypeDefinition vectorType = new FieldTypeDefinition();
            vectorType.setAttributes(Map.of("name", "test_vector_type", "class", "solr.DenseVectorField",
                    "vectorDimension", 768, "similarityFunction", "cosine"));
            new SchemaRequest.AddFieldType(vectorType).process(client);
            new SchemaRequest.AddField(Map.of("name", "test_vector", "type", "test_vector_type",
                    "stored", true, "indexed", true)).process(client);
            new SchemaRequest.AddField(Map.of("name", "network_acronym_str", "type", "string",
                    "stored", true, "indexed", true)).process(client);
        }

        setupMocks();
    }

    private void setupMocks() throws Exception {
        // Return a mock vector matching the configured embedding dimension
        List<Float> mockVector = Collections.nCopies(768, 0.1f);
        when(embeddingService.embed(anyString())).thenReturn(Optional.of(mockVector));
        when(embeddingService.getEmbeddingDimension()).thenReturn(768);

        IMDFormatTransformer mockTrf = mock(IMDFormatTransformer.class);
        when(mockTrf.transform(any())).thenReturn(DocumentBuilderFactory.newInstance().newDocumentBuilder()
                .parse(new InputSource(new StringReader("<doc><field name=\"id\">semantic-fixture</field></doc>"))));
        when(metadataTransformerService.getMDTransformer(any(), any())).thenReturn(mockTrf);
    }

    private HttpSolrClient solrClient() {
        return new HttpSolrClient.Builder("http://" + solr.getHost() + ":"
                + solr.getMappedPort(8983) + "/solr/biblio").build();
    }

    @Test
    void testSemanticIndexingFlow() throws Exception {
        networkActionManager.executeAction("SEMANTIC_INDEXING_ACTION", false, snapshot.getNetwork());

        // Verify that the action pipeline invokes the embedding service.
        verify(embeddingService, timeout(15000)).embed(anyString());
        try (HttpSolrClient client = solrClient()) {
            await().atMost(Duration.ofSeconds(30)).untilAsserted(() -> {
                var results = client.query(new SolrQuery("id:semantic-fixture")).getResults();
                assertEquals(1L, results.getNumFound());
                assertEquals(768, results.get(0).getFieldValues("test_vector").size());
            });
        }
    }
}
