package org.lareferencia.backend.api.v5;

import org.lareferencia.contrib.dark.services.DarkCredentialService;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v5/dark/authentication")
@PreAuthorize("hasRole('ADMIN')")
public class ApiV5DarkAuthenticationController {
    public record GenerateRequest(boolean confirmed, String expectedCredentialId) { }
    public record ResumeRequest(boolean confirmed, String keyId, String authorityId, String baseUrl) { }
    private final DarkCredentialService credentials;

    public ApiV5DarkAuthenticationController(DarkCredentialService credentials) { this.credentials = credentials; }

    @GetMapping
    public DarkCredentialService.Status status() { return credentials.status(); }

    @PostMapping("/credentials")
    public DarkCredentialService.Status generate(@RequestBody GenerateRequest request, Authentication user) {
        try { return credentials.generate(request.confirmed(), request.expectedCredentialId(), user.getName()); }
        catch (IllegalArgumentException e) { throw invalid(e); }
        catch (IllegalStateException e) { throw storageError(); }
    }

    @GetMapping(value = "/credentials/{id}/public-key", produces = "text/plain")
    public org.springframework.http.ResponseEntity<String> publicKey(@PathVariable String id) {
        var current = credentials.status();
        if (!id.equals(current.credentialId()))
            throw new ApiV5Exception(HttpStatus.CONFLICT, "DARK_AUTHENTICATION_CONFLICT", "Credentials changed; refresh before downloading");
        if (current.publicKey() == null) throw storageError();
        return org.springframework.http.ResponseEntity.ok()
                .header("Content-Disposition", "attachment; filename=\"dark-minter.pub\"")
                .body(current.publicKey() + "\n");
    }

    @PostMapping("/credentials/{id}/resume")
    public DarkCredentialService.Status resume(@PathVariable String id, @RequestBody ResumeRequest request, Authentication user) {
        try { return credentials.resume(id, request.keyId(), request.authorityId(), request.baseUrl(), request.confirmed(), user.getName()); }
        catch (IllegalArgumentException e) { throw invalid(e); }
        catch (IllegalStateException e) { throw storageError(); }
    }

    private ApiV5Exception invalid(IllegalArgumentException e) {
        return new ApiV5Exception(HttpStatus.CONFLICT, "DARK_AUTHENTICATION_CONFLICT", e.getMessage());
    }

    private ApiV5Exception storageError() {
        return new ApiV5Exception(HttpStatus.SERVICE_UNAVAILABLE, "DARK_CREDENTIAL_STORAGE_ERROR",
                "Credential storage is unavailable; modifications remain paused. Check server storage and permissions.");
    }
}
