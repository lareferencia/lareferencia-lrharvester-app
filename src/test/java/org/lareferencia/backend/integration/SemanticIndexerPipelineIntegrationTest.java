package org.lareferencia.backend.integration;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.is;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.timeout;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.lareferencia.backend.app.FileBasedUserDetailsService;
import org.lareferencia.backend.app.MainApp;
import org.lareferencia.core.domain.NetworkSnapshot;
import org.lareferencia.core.embedding.IEmbeddingService;
import org.lareferencia.core.metadata.IMDFormatTransformer;
import org.lareferencia.core.metadata.IMetadataStore;
import org.lareferencia.core.metadata.MDFormatTransformerService;
import org.lareferencia.core.metadata.SnapshotMetadata;
import org.lareferencia.core.repository.jpa.NetworkSnapshotRepository;
import org.lareferencia.core.repository.validation.ValidationDatabaseManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.core.io.Resource;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.util.StreamUtils;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;

@SpringBootTest(classes = { MainApp.class,
        SemanticIndexerPipelineIntegrationTest.TestConfig.class }, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT, properties = {
                "spring.main.allow-bean-definition-overriding=true",
                "security.users.file=config/users.properties"
        })
@Sql(scripts = "/sql/seed_test.sql", executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)
public class SemanticIndexerPipelineIntegrationTest extends BaseIntegrationTest {

    @TestConfiguration
    static class TestConfig {
        @Bean
        @Primary
        public MDFormatTransformerService metadataTransformerServiceMock() {
            return mock(MDFormatTransformerService.class);
        }
    }

    @LocalServerPort
    private int port;

    @Autowired
    private NetworkSnapshotRepository snapshotRepository;

    @Autowired
    private ValidationDatabaseManager validationDatabaseManager;

    @Autowired
    private IMetadataStore metadataStore;

    @Value("classpath:sql/seed_validation.sql")
    private Resource seedValidationSql;

    @Value("classpath:xml/xoai_obi_wan.xml")
    private Resource obiWanXml;

    @MockitoBean
    private IEmbeddingService embeddingService;

    @MockitoBean
    private FileBasedUserDetailsService fileBasedUserDetailsService;

    @Autowired
    private MDFormatTransformerService metadataTransformerService;

    @BeforeEach
    void setUp() throws Exception {
        RestAssured.port = port;

        var adminUser = User.builder()
                .username("admin")
                .password("$2a$10$4y1zPBq1Sab.k62WLj7QNudiifOuJq/Da27oIT1S7SgPwdvheGw5W")
                .authorities(new SimpleGrantedAuthority("ROLE_ADMIN"))
                .build();
        when(fileBasedUserDetailsService.loadUserByUsername("admin")).thenReturn(adminUser);

        NetworkSnapshot snapshot = snapshotRepository.findById(1L).orElseThrow();
        SnapshotMetadata metadata = new SnapshotMetadata(snapshot);

        String xmlContent = StreamUtils.copyToString(obiWanXml.getInputStream(), StandardCharsets.UTF_8);
        String hash = metadataStore.storeAndReturnHash(metadata, xmlContent);
        validationDatabaseManager.initializeSnapshot(metadata, Collections.emptyList());

        String sql = StreamUtils.copyToString(seedValidationSql.getInputStream(), StandardCharsets.UTF_8)
                .replace("${metadataHash}", hash);
        try (Connection conn = validationDatabaseManager.getDataSource(1L).getConnection()) {
            conn.createStatement().execute(sql);
        }

        setupMocks();
    }

    private void setupMocks() throws Exception {
        // Return a mock vector matching the configured embedding dimension
        List<Float> mockVector = Collections.nCopies(768, 0.1f);
        when(embeddingService.embed(anyString())).thenReturn(Optional.of(mockVector));
        when(embeddingService.getEmbeddingDimension()).thenReturn(768);

        IMDFormatTransformer mockTrf = mock(IMDFormatTransformer.class);
        when(mockTrf.transformToString(any())).thenReturn("<doc><field name=\"id\">1</field></doc>");
        when(metadataTransformerService.getMDTransformer(any(), any())).thenReturn(mockTrf);
    }

    @Test
    void testSemanticIndexingFlow() {
        given()
                .auth().preemptive().basic("admin", "admin")
                .contentType(ContentType.JSON)
                .when()
                .get("/private/networkAction/SEMANTIC_INDEXING_ACTION/false/1")
                .then()
                .log().ifValidationFails()
                .statusCode(200)
                .body("msg", is("DONE"));

        // Verifica acionamento do worker via IEmbeddingService
        verify(embeddingService, timeout(15000)).embed(anyString());
    }
}
