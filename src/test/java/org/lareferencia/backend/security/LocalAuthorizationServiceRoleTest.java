package org.lareferencia.backend.security;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import org.junit.jupiter.api.Test;
import org.lareferencia.backend.api.v5.ApiV5Exception;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;

class LocalAuthorizationServiceRoleTest {
    private final LocalAuthorizationService authorization = new LocalAuthorizationService(null);

    @Test
    void onlyDashboardUsersAndAdminsMayUseDashboard() {
        assertDoesNotThrow(() -> authorization.requireDashboardAccess(user("ADMIN")));
        assertDoesNotThrow(() -> authorization.requireDashboardAccess(user("DASHBOARD")));
        assertEquals(HttpStatus.FORBIDDEN,
                assertThrows(ApiV5Exception.class, () -> authorization.requireDashboardAccess(user("READER"))).getStatus());
        assertEquals(HttpStatus.FORBIDDEN,
                assertThrows(ApiV5Exception.class, () -> authorization.requireDashboardAccess(service())).getStatus());
    }

    private Authentication user(String role) {
        LocalPrincipal principal = new LocalPrincipal(1, "user", "", role, LocalPrincipal.Kind.USER, true);
        return UsernamePasswordAuthenticationToken.authenticated(principal, null, principal.getAuthorities());
    }

    private Authentication service() {
        LocalPrincipal principal = new LocalPrincipal(2, "service", "", "SERVICE_ACCOUNT", LocalPrincipal.Kind.SERVICE_ACCOUNT, true);
        return UsernamePasswordAuthenticationToken.authenticated(principal, null, principal.getAuthorities());
    }
}
