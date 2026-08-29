package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5WorkerConfigurationDtos.*;

import java.util.List;

import org.lareferencia.core.domain.ApplicationWorkerConfiguration;
import org.lareferencia.core.task.ApplicationWorkerConfigurationService;
import org.lareferencia.core.task.NetworkActionkManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ApiV5WorkerConfigurationService {
    private final ApplicationWorkerConfigurationService configurations;
    private final NetworkActionkManager manager;
    public ApiV5WorkerConfigurationService(ApplicationWorkerConfigurationService configurations, NetworkActionkManager manager) {
        this.configurations = configurations; this.manager = manager;
    }
    @Transactional(readOnly = true) public List<WorkerConfigurationResponse> list() { return configurations.list(manager.getEngineType()).stream().map(this::response).toList(); }
    @Transactional(readOnly = true) public WorkerConfigurationResponse get(String key) { return response(configurations.require(manager.getEngineType(), key)); }
    public WorkerConfigurationResponse replace(String key, WorkerConfigurationRequest request, String username) { return response(configurations.replace(manager.getEngineType(), key, request.configuration(), username)); }
    private WorkerConfigurationResponse response(ApplicationWorkerConfiguration row) { return new WorkerConfigurationResponse(row.getId(), row.getEngineType(), row.getWorkerKey(), row.isAvailable(), row.getDefinition(), row.getConfiguration(), row.getDefinition().path("schema"), row.getLastSeenAt(), row.getUpdatedAt(), row.getUpdatedBy()); }
}
