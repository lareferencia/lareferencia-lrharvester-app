package org.lareferencia.backend.api.v5;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Optional;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.lareferencia.backend.security.LocalAuthorizationService;
import org.lareferencia.core.domain.Network;
import org.lareferencia.core.domain.NetworkSnapshot;
import org.lareferencia.core.repository.jpa.NetworkRepository;
import org.lareferencia.core.repository.jpa.NetworkSnapshotRepository;
import org.lareferencia.core.service.validation.IValidationStatisticsService;
import org.lareferencia.core.util.date.DateHelper;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;

class ApiV5DashboardCompatibilityControllerTest {
    private final NetworkRepository networks = mock(NetworkRepository.class);
    private final NetworkSnapshotRepository snapshots = mock(NetworkSnapshotRepository.class);
    private final IValidationStatisticsService statistics = mock(IValidationStatisticsService.class);
    private final LocalAuthorizationService authorization = mock(LocalAuthorizationService.class);
    private final Authentication authentication = mock(Authentication.class);
    private final ApiV5DashboardCompatibilityController controller =
            new ApiV5DashboardCompatibilityController(networks, snapshots, statistics, authorization, new DateHelper());

    @Test
    void listFiltersBeforePaging() {
        Network network = mock(Network.class);
        when(network.getId()).thenReturn(2L);
        when(network.getAcronym()).thenReturn("TWO");
        PageRequest page = PageRequest.of(0, 1);
        when(authorization.readableNetworkIds(authentication)).thenReturn(List.of(2L));
        when(networks.findByIdIn(List.of(2L), page)).thenReturn(new PageImpl<>(List.of(network), page, 1));

        var result = controller.sources(page, authentication);

        assertEquals(1, result.getTotalElements());
        assertEquals("TWO", result.getContent().get(0).acronym());
        verify(networks).findByIdIn(List.of(2L), page);
        verify(networks, never()).findAll(page);
    }

    @Test
    void directNetworkReadChecksGrant() {
        Network network = mock(Network.class);
        when(network.getId()).thenReturn(2L);
        when(networks.findByAcronym("TWO")).thenReturn(network);
        org.mockito.Mockito.doThrow(new ApiV5Exception(HttpStatus.FORBIDDEN, "NETWORK_ACCESS_DENIED", "denied"))
                .when(authorization).requireNetworkRead(authentication, 2L);

        assertEquals(HttpStatus.FORBIDDEN,
                assertThrows(ApiV5Exception.class, () -> controller.source("TWO", authentication)).getStatus());
    }

    @Test
    void validationChecksSnapshotBeforeQuery() {
        org.mockito.Mockito.doThrow(new ApiV5Exception(HttpStatus.FORBIDDEN, "NETWORK_ACCESS_DENIED", "denied"))
                .when(authorization).requireSnapshotRead(authentication, 9L);

        assertEquals(HttpStatus.FORBIDDEN,
                assertThrows(ApiV5Exception.class, () -> controller.summary("TWO", 9L, authentication)).getStatus());
        verify(snapshots, never()).findById(9L);
    }

    @Test
    void validationRejectsAcronymMismatch() throws Exception {
        Network network = new Network();
        network.setAcronym("ONE");
        NetworkSnapshot snapshot = new NetworkSnapshot();
        snapshot.setNetwork(network);
        when(snapshots.findById(9L)).thenReturn(Optional.of(snapshot));

        assertEquals(HttpStatus.NOT_FOUND,
                assertThrows(ApiV5Exception.class, () -> controller.summary("TWO", 9L, authentication)).getStatus());
        verify(statistics, never()).queryValidatorRulesStatsBySnapshot(snapshot, List.of());
    }

    @Test
    void legacyBooleanPropertyNamesArePreserved() throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        var source = new ApiV5DashboardCompatibilityController.Source(1L, "Name", "ONE", null, null,
                java.util.Map.of(), true);
        var harvest = new ApiV5DashboardCompatibilityController.Harvest(2L, null, null, "VALID", 0, 0, 0, false);

        assertEquals(true, mapper.readTree(mapper.writeValueAsString(source)).get("public").asBoolean());
        assertEquals(false, mapper.readTree(mapper.writeValueAsString(harvest)).get("deleted").asBoolean());
    }
}
