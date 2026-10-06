package org.lareferencia.backend.api.v5;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

import java.util.List;
import org.junit.jupiter.api.Test;
import org.lareferencia.core.domain.Network;
import org.lareferencia.core.repository.jpa.NetworkRepository;
import org.lareferencia.core.task.NetworkActionkManager;
import org.springframework.test.util.ReflectionTestUtils;
import com.fasterxml.jackson.databind.ObjectMapper;

class ApiV5ManagementNetworkActionsTest {
    @Test
    void creatingNetworkReconcilesItsPerNetworkActionConfiguration() {
        NetworkRepository networks = mock(NetworkRepository.class);
        NetworkActionkManager actions = mock(NetworkActionkManager.class);
        ApiV5AttributeProfileService profiles = mock(ApiV5AttributeProfileService.class);
        when(networks.save(any(Network.class))).thenAnswer(invocation -> {
            Network saved = invocation.getArgument(0);
            ReflectionTestUtils.setField(saved, "id", 26L);
            return saved;
        });
        ApiV5ManagementService service = new ApiV5ManagementService(networks, null, null, null, null, null,
                actions, null, null, null, new ObjectMapper(), null, profiles, null, null);

        var created = service.createNetwork(new ApiV5Dtos.NetworkRequest("PY", "Paraguay", "Institution",
                "INST", true, "https://example.org/oai", "xoai", "xoai", List.of(), null, null,
                null, null, null, null, null, List.of()));

        assertEquals(26L, created.id());
        var saved = org.mockito.ArgumentCaptor.forClass(Network.class);
        verify(networks).save(saved.capture());
        verify(actions).reconcileNetwork(saved.getValue());
    }
}
