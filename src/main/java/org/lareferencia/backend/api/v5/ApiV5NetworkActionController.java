package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5NetworkActionDtos.*;

import java.util.List;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/v5/networks/{networkId}/actions")
public class ApiV5NetworkActionController {
    private final ApiV5NetworkActionService service;
    public ApiV5NetworkActionController(ApiV5NetworkActionService service) { this.service = service; }

    @GetMapping @PreAuthorize("hasAnyRole('VIEWER','ADMIN')")
    public List<NetworkActionResponse> list(@PathVariable Long networkId) { return service.list(networkId); }

    @GetMapping("/{actionKey}") @PreAuthorize("hasAnyRole('VIEWER','ADMIN')")
    public NetworkActionResponse get(@PathVariable Long networkId, @PathVariable String actionKey) { return service.get(networkId, actionKey); }

    @PutMapping("/{actionKey}") @PreAuthorize("hasRole('ADMIN')")
    public NetworkActionResponse replace(@PathVariable Long networkId, @PathVariable String actionKey,
            @Valid @RequestBody NetworkActionRequest request, Authentication authentication) {
        return service.replace(networkId, actionKey, request, authentication.getName());
    }
}
