package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5NetworkActionDtos.*;

import java.util.List;

import org.lareferencia.core.domain.Network;
import org.lareferencia.core.domain.NetworkActionConfiguration;
import org.lareferencia.core.repository.jpa.NetworkRepository;
import org.lareferencia.core.task.ApplicationActionCatalogService;
import org.lareferencia.core.task.NetworkActionConfigurationService;
import org.lareferencia.core.task.NetworkActionkManager;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ApiV5NetworkActionService {
    private final NetworkRepository networks;
    private final NetworkActionConfigurationService configurations;
    private final ApplicationActionCatalogService catalog;
    private final NetworkActionkManager manager;

    public ApiV5NetworkActionService(NetworkRepository networks, NetworkActionConfigurationService configurations,
            ApplicationActionCatalogService catalog, NetworkActionkManager manager) {
        this.networks = networks; this.configurations = configurations; this.catalog = catalog; this.manager = manager;
    }

    @Transactional(readOnly = true)
    public List<NetworkActionResponse> list(Long networkId) {
        return configurations.list(network(networkId)).stream().map(this::response).toList();
    }

    @Transactional(readOnly = true)
    public NetworkActionResponse get(Long networkId, String actionKey) {
        return response(configurations.require(network(networkId), manager.getEngineType(), actionKey));
    }

    public NetworkActionResponse replace(Long networkId, String actionKey, NetworkActionRequest request, String username) {
        return response(configurations.replace(network(networkId), manager.getEngineType(), actionKey, request.enabled(),
                request.scheduleEnabled(), request.configuration(), username));
    }

    private Network network(Long id) {
        return networks.findById(id).orElseThrow(() -> new ApiV5Exception(HttpStatus.NOT_FOUND, "NETWORK_NOT_FOUND", "Network was not found"));
    }

    private NetworkActionResponse response(NetworkActionConfiguration row) {
        var app = row.getApplicationAction();
        return new NetworkActionResponse(app.getActionKey(), catalog.state(app).name(), row.isEnabled(), row.isScheduleEnabled(),
                row.getConfiguration(), configurations.effectiveConfiguration(row), app.getDefinition().path("schema"),
                app.getDefinition().path("uiSchema"), List.of(), row.getUpdatedAt(), row.getUpdatedBy());
    }
}
