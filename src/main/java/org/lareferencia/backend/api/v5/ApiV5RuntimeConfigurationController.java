package org.lareferencia.backend.api.v5;

import com.fasterxml.jackson.databind.JsonNode;
import org.lareferencia.core.task.TaskManager;
import org.lareferencia.core.task.TaskManagerRuntimeConfigurationService;
import org.lareferencia.core.task.TaskSubmissionRejectedException;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v5/runtime/configuration")
@PreAuthorize("hasRole('ADMIN')")
public class ApiV5RuntimeConfigurationController {
    private final ObjectProvider<TaskManagerRuntimeConfigurationService> configurations;

    public ApiV5RuntimeConfigurationController(ObjectProvider<TaskManagerRuntimeConfigurationService> configurations) {
        this.configurations = configurations;
    }

    @GetMapping
    public TaskManagerRuntimeConfigurationService.ConfigurationResponse get() { return service().get(); }

    @PutMapping
    public TaskManagerRuntimeConfigurationService.ConfigurationResponse replace(@RequestBody JsonNode request,
            Authentication authentication) {
        var service = service();
        try {
            if (!request.isObject()) throw new IllegalArgumentException("Configuration must be an object");
            var value = new TaskManager.RuntimeConfiguration(integer(request, "concurrentTasks"),
                    integer(request, "maxQueuedTasks"), number(request, "resultRetentionSeconds"),
                    integer(request, "maxRetainedResults"), number(request, "shutdownTimeoutSeconds"));
            return service.replace(value, authentication.getName());
        } catch (IllegalArgumentException | ArithmeticException e) {
            throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "TASKMANAGER_CONFIGURATION_INVALID", e.getMessage());
        } catch (TaskSubmissionRejectedException e) {
            throw new ApiV5Exception(HttpStatus.SERVICE_UNAVAILABLE, e.getReason(), "TaskManager is shutting down");
        }
    }

    private TaskManagerRuntimeConfigurationService service() {
        var service = configurations.getIfAvailable();
        if (service == null) throw new ApiV5Exception(HttpStatus.CONFLICT, "TASKMANAGER_CONFIGURATION_UNAVAILABLE",
                "TaskManager runtime configuration is available only for the legacy engine");
        return service;
    }

    private static int integer(JsonNode value, String name) {
        number(value, name);
        if (!value.path(name).canConvertToInt()) throw new IllegalArgumentException(name + " exceeds the integer range");
        return value.path(name).intValue();
    }

    private static long number(JsonNode value, String name) {
        var field = value.path(name);
        if (!field.isIntegralNumber() || !field.canConvertToLong()) {
            throw new IllegalArgumentException(name + " is required and must be an integer");
        }
        return field.longValue();
    }
}
