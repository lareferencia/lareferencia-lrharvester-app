package org.lareferencia.backend.security;

import java.time.OffsetDateTime;
import java.util.List;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/v5")
public class LocalIdentityController {
    public record UserRequest(@NotBlank @Size(max=100) String username, @NotBlank @Size(min=12,max=200) String password,
            @NotBlank String role, List<Long> networkIds) {}
    public record UserUpdate(@jakarta.validation.constraints.Pattern(regexp="ADMIN|READER|DASHBOARD") String role, Boolean enabled,
            @Size(min=12,max=200) String password, List<Long> networkIds) {}
    public record ServiceRequest(@NotBlank @Size(max=120) String name, @NotEmpty List<Long> networkIds) {}
    public record ServiceUpdate(Boolean enabled, @NotEmpty List<Long> networkIds) {}
    public record TokenRequest(@jakarta.validation.constraints.NotNull OffsetDateTime expiresAt) {}

    private final LocalIdentityService identities;
    private final LocalAuthorizationService authorization;
    public LocalIdentityController(LocalIdentityService identities, LocalAuthorizationService authorization) {
        this.identities = identities; this.authorization = authorization;
    }
    @GetMapping("/users") public List<LocalIdentityService.UserView> users(Authentication a) { authorization.requireAdmin(a); return identities.users(); }
    @PostMapping("/users") public LocalIdentityService.UserView createUser(Authentication a, @Valid @RequestBody UserRequest r) {
        authorization.requireAdmin(a); return identities.createUser(r.username(), r.password(), r.role(), r.networkIds());
    }
    @PutMapping("/users/{username}") public LocalIdentityService.UserView updateUser(Authentication a, @PathVariable String username, @Valid @RequestBody UserUpdate r) {
        authorization.requireAdmin(a); var result = identities.updateUser(username, r.role(), r.enabled(), r.password(), r.networkIds());
        if (result == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND); return result;
    }
    @DeleteMapping("/users/{username}") public void deleteUser(Authentication a, @PathVariable String username) {
        authorization.requireAdmin(a); if (username.equals(authorization.principal(a).getUsername())) throw new ResponseStatusException(HttpStatus.CONFLICT, "Cannot delete the current administrator");
        identities.deleteUser(username);
    }
    @GetMapping("/service-accounts") public List<LocalIdentityService.ServiceView> serviceAccounts(Authentication a) { authorization.requireAdmin(a); return identities.serviceAccounts(); }
    @PostMapping("/service-accounts") public LocalIdentityService.ServiceView createService(Authentication a, @Valid @RequestBody ServiceRequest r) {
        authorization.requireAdmin(a); return identities.createServiceAccount(r.name(), r.networkIds());
    }
    @PutMapping("/service-accounts/{id}") public LocalIdentityService.ServiceView updateService(Authentication a, @PathVariable long id, @Valid @RequestBody ServiceUpdate r) {
        authorization.requireAdmin(a); var result = identities.updateServiceAccount(id, r.enabled(), r.networkIds());
        if (result == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND); return result;
    }
    @DeleteMapping("/service-accounts/{id}") public void deleteService(Authentication a, @PathVariable long id) { authorization.requireAdmin(a); identities.deleteServiceAccount(id); }
    @GetMapping("/service-accounts/{id}/tokens") public List<LocalIdentityService.TokenView> tokens(Authentication a, @PathVariable long id) { authorization.requireAdmin(a); return identities.tokens(id); }
    @PostMapping("/service-accounts/{id}/tokens") public LocalIdentityService.IssuedToken issueToken(Authentication a, @PathVariable long id, @Valid @RequestBody TokenRequest r) {
        authorization.requireAdmin(a); return identities.issueToken(id, r.expiresAt());
    }
    @DeleteMapping("/service-accounts/{id}/tokens/{tokenId}") public void revokeToken(Authentication a, @PathVariable long id, @PathVariable long tokenId) {
        authorization.requireAdmin(a); identities.revokeToken(id, tokenId);
    }
}
