package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5ApplicationActionDtos.*;

import java.util.List;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/v5/application-actions")
@Validated
public class ApiV5ApplicationActionController {
    private final ApiV5ApplicationActionService service;

    public ApiV5ApplicationActionController(ApiV5ApplicationActionService service) {
        this.service = service;
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('VIEWER','ADMIN')")
    public List<ApplicationActionResponse> list() { return service.list(); }

    @GetMapping("/{actionKey}")
    @PreAuthorize("hasAnyRole('VIEWER','ADMIN')")
    public ApplicationActionResponse get(@PathVariable String actionKey) { return service.get(actionKey); }

    @PutMapping("/{actionKey}")
    @PreAuthorize("hasRole('ADMIN')")
    public ApplicationActionResponse replace(@PathVariable String actionKey,
            @Valid @RequestBody ApplicationActionRequest request, Authentication authentication) {
        return service.replace(actionKey, request, authentication.getName());
    }

    @GetMapping("/{actionKey}/usage")
    @PreAuthorize("hasAnyRole('VIEWER','ADMIN')")
    public ApplicationActionUsageResponse usage(@PathVariable String actionKey) { return service.usage(actionKey); }

    @PostMapping("/refresh")
    @PreAuthorize("hasRole('ADMIN')")
    public ApplicationActionRefreshResponse refresh(Authentication authentication) {
        return service.refresh(authentication.getName());
    }
}
