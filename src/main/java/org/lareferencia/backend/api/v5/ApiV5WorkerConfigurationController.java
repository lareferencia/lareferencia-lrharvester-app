package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5WorkerConfigurationDtos.*;

import java.util.List;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/v5/worker-configurations")
@Validated
public class ApiV5WorkerConfigurationController {
    private final ApiV5WorkerConfigurationService service;
    public ApiV5WorkerConfigurationController(ApiV5WorkerConfigurationService service) { this.service = service; }
    @GetMapping @PreAuthorize("hasAnyRole('VIEWER','ADMIN')") public List<WorkerConfigurationResponse> list() { return service.list(); }
    @GetMapping("/{workerKey}") @PreAuthorize("hasAnyRole('VIEWER','ADMIN')") public WorkerConfigurationResponse get(@PathVariable String workerKey) { return service.get(workerKey); }
    @PutMapping("/{workerKey}") @PreAuthorize("hasRole('ADMIN')") public WorkerConfigurationResponse replace(@PathVariable String workerKey, @Valid @RequestBody WorkerConfigurationRequest request, Authentication authentication) { return service.replace(workerKey, request, authentication.getName()); }
}
