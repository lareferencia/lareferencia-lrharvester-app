package org.lareferencia.backend.api.v5;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import java.util.Map;

import org.junit.jupiter.api.Test;
import org.springframework.core.io.DefaultResourceLoader;

import com.fasterxml.jackson.databind.ObjectMapper;

class ApiV5AttributeProfileServiceTest {
    @Test
    void loadsConfiguredProfilesAndValidatesClassReference() {
        ApiV5AttributeProfileService service = new ApiV5AttributeProfileService(new DefaultResourceLoader(),
                new ObjectMapper(), "file:config/api-v5-attribute-profiles.json");
        service.load();

        assertEquals("lareferencia-repository", service.list().get(0).typeId());
        service.validateReference(Map.of("@class",
                "org.lareferencia.backend.network.LAReferenciaNetworkAttributes"));
        assertThrows(ApiV5Exception.class, () -> service.validateReference(Map.of("@class", "unknown.Profile")));
    }

    @Test
    void missingExternalCatalogDoesNotPreventApplicationStartup() {
        ApiV5AttributeProfileService service = new ApiV5AttributeProfileService(new DefaultResourceLoader(),
                new ObjectMapper(), "file:config/does-not-exist-api-v5-profiles.json");

        service.load();

        assertEquals(3, service.list().size());
        service.validateReference(Map.of("@class",
                "org.lareferencia.backend.network.IbictRepositoryNetworkAttributes"));
    }
}
