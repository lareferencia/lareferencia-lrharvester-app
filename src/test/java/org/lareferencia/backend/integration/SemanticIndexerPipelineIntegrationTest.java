package org.lareferencia.backend.integration;

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
import org.lareferencia.backend.app.MainApp;
import org.lareferencia.core.domain.NetworkSnapshot;
import org.lareferencia.core.embedding.IEmbeddingService;
import org.lareferencia.core.metadata.IMDFormatTransformer;
import org.lareferencia.core.metadata.IMetadataStore;
import org.lareferencia.core.metadata.MDFormatTransformerService;
import org.lareferencia.core.metadata.SnapshotMetadata;
import org.lareferencia.core.repository.jpa.NetworkSnapshotRepository;
import org.lareferencia.core.repository.validation.ValidationDatabaseManager;
import org.lareferencia.core.task.NetworkActionkManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.core.io.Resource;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.util.StreamUtils;

@SpringBootTest(classes = { MainApp.class,
        SemanticIndexerPipelineIntegrationTest.TestConfig.class }, properties = {
                "spring.main.allow-bean-definition-overriding=true"
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

    @Autowired
    private NetworkSnapshotRepository snapshotRepository;

    @Autowired
    private NetworkActionkManager networkActionManager;

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

    @Autowired
    private MDFormatTransformerService metadataTransformerService;

    @BeforeEach
    void setUp() throws Exception {
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
        NetworkSnapshot snapshot = snapshotRepository.findById(1L).orElseThrow();
        networkActionManager.executeAction("SEMANTIC_INDEXING_ACTION", false, snapshot.getNetwork());

        // Verify that the action pipeline invokes the embedding service.
        verify(embeddingService, timeout(15000)).embed(anyString());
    }
}
