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
                new ObjectMapper(), "file:config/attribute-profiles");
        service.load();

        assertEquals(4, service.list().size());
        assertEquals("lareferencia-repository", service.get("lareferencia-repository").typeId());
        service.validateReference(Map.of("@class",
                "org.lareferencia.backend.network.LAReferenciaNetworkAttributes"));
        assertThrows(ApiV5Exception.class, () -> service.validateReference(Map.of("@class", "unknown.Profile")));
    }

    @Test
    void missingExternalCatalogDoesNotPreventApplicationStartup() {
        ApiV5AttributeProfileService service = new ApiV5AttributeProfileService(new DefaultResourceLoader(),
                new ObjectMapper(), "file:config/attribute-profiles-missing");

        service.load();

        assertEquals(3, service.list().size());
        service.validateReference(Map.of("@class",
                "org.lareferencia.backend.network.IbictRepositoryNetworkAttributes"));
    }
}
