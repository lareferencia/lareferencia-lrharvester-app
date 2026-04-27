package org.lareferencia.backend.integration;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Duration;

import org.junit.jupiter.api.io.TempDir;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.containers.SolrContainer;
import org.testcontainers.containers.output.Slf4jLogConsumer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.utility.DockerImageName;
import org.testcontainers.utility.MountableFile;

@Testcontainers
public abstract class BaseIntegrationTest {

    private static final Logger logger = LoggerFactory.getLogger(BaseIntegrationTest.class);

    @TempDir
    protected static Path sharedTempDir;

    @Container
    @ServiceConnection
    protected static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15-alpine");

    @Container
    protected static SolrContainer solr = new SolrContainer(DockerImageName.parse("solr:9.5.0"))
            .withCopyFileToContainer(
                MountableFile.forHostPath(Paths.get("../lareferencia-solr-cores/biblio/conf").toAbsolutePath()),
                "/opt/solr/server/solr/configsets/biblio/conf"
            )
            .withCollection("biblio")
            .withStartupTimeout(Duration.ofSeconds(120))
            .withLogConsumer(new Slf4jLogConsumer(logger));

    @DynamicPropertySource
    static void infrastructureProperties(DynamicPropertyRegistry registry) {
        // Habilita a sobrescrita de beans
        registry.add("spring.main.allow-bean-definition-overriding", () -> "true");

        // Desabilita o Liquibase para o teste
        registry.add("spring.liquibase.enabled", () -> "false");
        
        // Garante que o Hibernate crie as tabelas no container vazio
        registry.add("spring.jpa.hibernate.ddl-auto", () -> "create-drop");
        registry.add("spring.jpa.show-sql", () -> "true");

        // Solr e Basepath
        registry.add("frontend.solr.url", () -> "http://" + solr.getHost() + ":" + solr.getMappedPort(8983) + "/solr/biblio");
        registry.add("store.basepath", () -> sharedTempDir.toAbsolutePath().toString());
        
        // Propriedades fundamentais
        registry.add("taskexecutor.pool.size", () -> "10");
        registry.add("scheduler.pool.size", () -> "10");
        registry.add("workflow.engine", () -> "legacy");
        registry.add("actions.beans.filename", () -> "actions.xml");

        // Propriedades de Embedding para o SemanticIndexerWorker
        registry.add("embedding.model.name", () -> "test-model");
        registry.add("embedding.model.datatype", () -> "float32");
        registry.add("embedding.model.dimension", () -> "768");
        registry.add("embedding.model.applicationId", () -> "test-app");
        registry.add("embedding.api.url", () -> "http://mock-api:5000");

        // Configuração do ambiente
        System.setProperty("app.config.dir", "config");
        System.setProperty("actions.beans.filename", "actions.xml");
    }
}
