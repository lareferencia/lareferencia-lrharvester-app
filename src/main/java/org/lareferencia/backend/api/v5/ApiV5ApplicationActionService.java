package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5ApplicationActionDtos.*;

import java.util.ArrayList;
import java.util.List;

import org.lareferencia.core.domain.ApplicationAction;
import org.lareferencia.core.domain.Network;
import org.lareferencia.core.repository.jpa.NetworkRepository;
import org.lareferencia.core.task.ApplicationActionCatalogService;
import org.lareferencia.core.task.ApplicationActionState;
import org.lareferencia.core.task.NetworkAction;
import org.lareferencia.core.task.NetworkActionkManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ApiV5ApplicationActionService {
    private final ApplicationActionCatalogService catalog;
    private final NetworkActionkManager manager;
    private final NetworkRepository networks;

    public ApiV5ApplicationActionService(ApplicationActionCatalogService catalog, NetworkActionkManager manager,
            NetworkRepository networks) {
        this.catalog = catalog;
        this.manager = manager;
        this.networks = networks;
    }

    @Transactional(readOnly = true)
    public List<ApplicationActionResponse> list() {
        return catalog.list(manager.getEngineType()).stream().map(this::response).toList();
    }

    @Transactional(readOnly = true)
    public ApplicationActionResponse get(String actionKey) {
        return response(catalog.require(manager.getEngineType(), actionKey));
    }

    public ApplicationActionResponse replace(String actionKey, ApplicationActionRequest request, String username) {
        return response(catalog.replace(manager.getEngineType(), actionKey, request.enabled(), request.configuration(), username));
    }

    public ApplicationActionResponse move(String actionKey, ApplicationActionMoveRequest request, String username) {
        var direction = request.direction() == MoveDirection.UP
                ? ApplicationActionCatalogService.MoveDirection.UP : ApplicationActionCatalogService.MoveDirection.DOWN;
        return response(catalog.move(manager.getEngineType(), actionKey, direction, username));
    }

    public ApplicationActionRefreshResponse refresh(String username) {
        var result = manager.refreshActionCatalog(username);
        return new ApplicationActionRefreshResponse(result.engineType(), result.bootstrap(), result.created(),
                result.updated(), result.unavailable(), result.conflicts());
    }

    @Transactional(readOnly = true)
    public ApplicationActionUsageResponse usage(String actionKey) {
        catalog.require(manager.getEngineType(), actionKey);
        NetworkAction descriptor = manager.getActions().stream().filter(action -> actionKey.equals(action.getName()))
                .findFirst().orElse(null);
        List<ApiV5Dtos.UsageNetworkResponse> affected = new ArrayList<>();
        int schedules = 0;
        for (Network network : networks.findAll()) {
            List<String> relations = new ArrayList<>();
            if ("flowable".equals(manager.getEngineType()) && "networkProcessing".equals(actionKey)
                    && hasSchedule(network)) {
                relations.add("SCHEDULE");
            }
            if (descriptor != null && "legacy".equals(manager.getEngineType())) {
                descriptor.getProperties().forEach(property -> {
                    if (network.getBooleanPropertyValue(property.getName())) relations.add("PROPERTY:" + property.getName());
                });
                if (!relations.isEmpty() && hasSchedule(network)) relations.add("SCHEDULE");
            }
            if (!relations.isEmpty()) {
                if (relations.contains("SCHEDULE")) schedules++;
                affected.add(new ApiV5Dtos.UsageNetworkResponse(network.getId(), network.getAcronym(), network.getName(), relations));
            }
        }
        return new ApplicationActionUsageResponse(!affected.isEmpty(), affected.size(), schedules, affected);
    }

    private boolean hasSchedule(Network network) {
        return network.getScheduleCronExpression() != null && !network.getScheduleCronExpression().isBlank();
    }

    private ApplicationActionResponse response(ApplicationAction row) {
        ApplicationActionState state = catalog.state(row);
        List<String> problems = state == ApplicationActionState.INVALID_CONFIGURATION
                ? List.of("Stored configuration no longer matches the discovered schema") : List.of();
        return new ApplicationActionResponse(row.getId(), row.getEngineType(), row.getActionKey(), state.name(), row.getExecutionOrder(),
                row.isEnabled(), row.isAvailable(), row.getDefinition(), row.getConfiguration(),
                row.getDefinition().path("schema"), row.getDefinition().path("uiSchema"), problems,
                row.getLastSeenAt(), row.getUpdatedAt(), row.getUpdatedBy());
    }
}
