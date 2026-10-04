package org.lareferencia.backend.api.v5;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;
import java.util.*;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.*;
import org.lareferencia.core.domain.Network;
import org.lareferencia.core.task.NetworkActionkManager;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

class ApiV5NetworkTagsTest {
    static LocalContainerEntityManagerFactoryBean factory;
    EntityManager em;
    Network first, second, third;

    @BeforeAll static void createDatabase() throws Exception {
        factory = new LocalContainerEntityManagerFactoryBean();
        String postgres = System.getProperty("indexing.test.jdbc-url");
        factory.setDataSource(postgres == null
            ? new DriverManagerDataSource("jdbc:h2:mem:networktags;DB_CLOSE_DELAY=-1", "sa", "")
            : new DriverManagerDataSource(postgres, "postgres", "indexing-test"));
        factory.setPackagesToScan("org.lareferencia.core.domain");
        factory.setJpaVendorAdapter(new HibernateJpaVendorAdapter());
        factory.setJpaPropertyMap(Map.of("hibernate.hbm2ddl.auto", "create-drop"));
        var jdbc = new org.springframework.jdbc.core.JdbcTemplate(factory.getDataSource());
        if (postgres == null) jdbc.execute("CREATE DOMAIN IF NOT EXISTS JSONB AS JSON");
        factory.afterPropertiesSet();
        jdbc.execute("DROP TABLE network_tag");
        String migration = java.nio.file.Files.readString(java.nio.file.Path.of("../lareferencia-shell/src/main/resources/db/migration/V5.0.0.16__Network_tags.sql"));
        for (String statement : migration.split(";")) if (!statement.isBlank()) jdbc.execute(statement);
    }
    @AfterAll static void closeDatabase() { factory.destroy(); }
    @BeforeEach void prepare() {
        em = factory.getObject().createEntityManager();
        em.getTransaction().begin();
        first = network("ONE", "pais:ar", "piloto");
        second = network("TWO", "pais:uy", "piloto");
        third = network("THREE");
        em.flush(); em.clear();
    }
    @AfterEach void cleanup() { em.getTransaction().rollback(); em.close(); }
    Network network(String acronym, String... tags) {
        Network n = new Network(); n.setAcronym(acronym); n.setName(acronym);
        n.setInstitutionName("Institution"); n.setPublished(false);
        n.setTags(new LinkedHashSet<>(List.of(tags))); em.persist(n); return n;
    }
    ApiV5NetworkSummaryService summaries() {
        NetworkActionkManager actions = mock(NetworkActionkManager.class);
        when(actions.getRunningTasksByRunningContextID(anyString())).thenReturn(List.of());
        when(actions.getQueuedTasksByRunningContextID(anyString())).thenReturn(List.of());
        when(actions.getScheduledTasksByRunningContextID(anyString())).thenReturn(List.of());
        return new ApiV5NetworkSummaryService(em, actions);
    }
    @Test void exactMembershipAllAnyPaginationAndAuthorization() {
        org.junit.jupiter.api.Assumptions.assumeTrue(System.getProperty("indexing.test.jdbc-url") != null,
            "Operational summary queries require the disposable PostgreSQL test database");
        var service = summaries();
        var all = service.list(0, 25, "id,asc", null, null, null, null, null, null, null, null, List.of("PILOTO", "pais:ar"), "all");
        assertEquals(1, all.totalElements()); assertEquals(first.getId(), all.items().get(0).id());
        var any = service.list(0, 1, "id,asc", null, null, null, null, null, null, null, null, List.of("piloto", "pais:ar"), "any");
        assertEquals(2, any.totalElements()); assertEquals(2, any.totalPages()); assertEquals(1, any.items().size());
        var page2 = service.list(1, 1, "id,asc", null, null, null, null, null, null, null, null, List.of("piloto"), "all");
        assertEquals(second.getId(), page2.items().get(0).id());
        var restricted = service.list(0, 25, "id,asc", null, null, null, null, null, null, null, List.of(first.getId()), List.of("piloto"), "any");
        assertEquals(1, restricted.totalElements());
        var substring = service.list(0, 25, "id,asc", null, null, null, null, null, null, null, null, List.of("pilot"), "all");
        assertEquals(0, substring.totalElements());
        var combined = service.list(0, 25, "id,asc", "TWO", null, null, null, null, null, null, null, List.of("piloto"), "all");
        assertEquals(second.getId(), combined.items().get(0).id());
    }
    @Test void configurationsAndVocabularyRespectPermissions() {
        ApiV5ManagementService management = mock(ApiV5ManagementService.class);
        var service = new ApiV5NetworkTagQueryService(em, management);
        assertEquals(List.of("pais:ar", "piloto"), service.vocabulary(List.of(first.getId())));
        assertEquals(List.of(), service.vocabulary(List.of()));
        var result = service.list(0, 1, List.of(first.getId(), second.getId()), List.of("piloto"), "all");
        assertEquals(2, result.totalElements()); assertEquals(2, result.totalPages());
        verify(management).networkResponse(any(Network.class));
        assertEquals(0, service.list(0, 25, List.of(), List.of("piloto"), "all").totalElements());
    }
    @Test void tagsCanBeRemovedWithoutAffectingOtherNetworks() {
        Network n = em.find(Network.class, first.getId()); n.getTags().clear(); em.flush(); em.clear();
        assertTrue(em.find(Network.class, first.getId()).getTags().isEmpty());
        assertEquals(Set.of("pais:uy", "piloto"), em.find(Network.class, second.getId()).getTags());
    }
    @Test void bulkDeletionCascadesToTags() {
        em.createQuery("delete from Network n where n.id=:id").setParameter("id", first.getId()).executeUpdate();
        assertEquals(0L, ((Number) em.createNativeQuery("select count(*) from network_tag where network_id=:id")
            .setParameter("id", first.getId()).getSingleResult()).longValue());
    }
    @Test void normalizationAndValidation() {
        assertEquals(List.of("piloto", "pais:ar"), ApiV5NetworkTags.normalize(List.of(" PILOTO ", "piloto", "Pais:AR")));
        assertThrows(ApiV5Exception.class, () -> ApiV5NetworkTags.normalize(List.of(" ")));
        assertThrows(ApiV5Exception.class, () -> ApiV5NetworkTags.normalize(List.of("x".repeat(101))));
        assertThrows(ApiV5Exception.class, () -> ApiV5NetworkTags.normalize(Collections.nCopies(51, "x")));
        assertThrows(ApiV5Exception.class, () -> ApiV5NetworkTags.filter(new StringBuilder(), new HashMap<>(), List.of(), "invalid"));
    }
}
