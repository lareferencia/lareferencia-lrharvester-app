package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5DarkDtos.*;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.security.core.Authentication;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PutMapping;
import org.lareferencia.contrib.dark.services.DarkRuntimeConfigurationService;

@RestController
@RequestMapping("/api/v5/dark")
@PreAuthorize("hasAnyRole('VIEWER','ADMIN')")
public class ApiV5DarkController {
    private final ApiV5DarkService service;
    private final DarkRuntimeConfigurationService runtimeConfiguration;
    public ApiV5DarkController(ApiV5DarkService service, DarkRuntimeConfigurationService runtimeConfiguration) {
        this.service = service; this.runtimeConfiguration = runtimeConfiguration;
    }

    @GetMapping("/configuration")
    public RuntimeConfiguration configuration() { return new RuntimeConfiguration(runtimeConfiguration.get()); }

    @PutMapping("/configuration")
    @PreAuthorize("hasRole('ADMIN')")
    @org.springframework.web.bind.annotation.ResponseStatus(HttpStatus.OK)
    public RuntimeConfiguration replaceConfiguration(@RequestBody RuntimeConfiguration request, Authentication authentication) {
        try {
            return new RuntimeConfiguration(runtimeConfiguration.replace(request.configuration(), authentication.getName()));
        } catch (IllegalArgumentException e) {
            throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "DARK_CONFIGURATION_INVALID", e.getMessage());
        }
    }

    @GetMapping("/summary")
    public Summary summary(@RequestParam(required = false) String arkNaan) { return service.summary(arkNaan); }

    @GetMapping("/records")
    public ApiV5Dtos.PageResponse<RecordResponse> records(@RequestParam(required = false) String arkNaan,
            @RequestParam(required = false) String state, @RequestParam(required = false) String q,
            @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "25") int size) {
        if (page < 0) throw new ApiV5Exception(org.springframework.http.HttpStatus.BAD_REQUEST, "PAGE_INVALID", "page must be zero or greater");
        if (size < 1 || size > 200) throw new ApiV5Exception(org.springframework.http.HttpStatus.BAD_REQUEST, "SIZE_INVALID", "size must be between 1 and 200");
        return service.records(arkNaan, state, q, page, size);
    }

    @GetMapping("/networks/{networkId}/summary")
    public Summary networkSummary(@PathVariable Long networkId) {
        String naan = service.networkNaan(networkId);
        return naan == null ? new Summary(0, java.util.List.of(), java.util.List.of(), java.util.List.of()) : service.summary(naan);
    }

    @GetMapping("/networks/{networkId}/records")
    public ApiV5Dtos.PageResponse<RecordResponse> networkRecords(@PathVariable Long networkId,
            @RequestParam(required = false) String state, @RequestParam(required = false) String q,
            @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "25") int size) {
        if (page < 0) throw new ApiV5Exception(org.springframework.http.HttpStatus.BAD_REQUEST, "PAGE_INVALID", "page must be zero or greater");
        if (size < 1 || size > 200) throw new ApiV5Exception(org.springframework.http.HttpStatus.BAD_REQUEST, "SIZE_INVALID", "size must be between 1 and 200");
        String naan = service.networkNaan(networkId);
        if (naan == null) return new ApiV5Dtos.PageResponse<>(java.util.List.of(), page, size, 0, 0);
        return service.records(naan, state, q, page, size);
    }
}
