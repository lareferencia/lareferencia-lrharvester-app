package org.lareferencia.backend.app;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.lareferencia.backend.security.LocalPrincipal;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

class WebSecurityConfigTest {
    @AfterEach
    void clearSecurityContext() { SecurityContextHolder.clearContext(); }

    @Test
    void browserWriteRequiresCsrf() {
        LocalPrincipal reader = new LocalPrincipal(1, "reader", "", "READER", LocalPrincipal.Kind.USER, true);
        SecurityContextHolder.getContext().setAuthentication(
                UsernamePasswordAuthenticationToken.authenticated(reader, null, reader.getAuthorities()));

        assertTrue(WebSecurityConfig.requiresCsrf(new MockHttpServletRequest("POST", "/api/v5/auth/logout")));
        assertTrue(WebSecurityConfig.requiresCsrf(new MockHttpServletRequest("DELETE", "/api/v5/users/test")));
        assertFalse(WebSecurityConfig.requiresCsrf(new MockHttpServletRequest("GET", "/api/v5/me")));
    }

    @Test
    void validServicePrincipalDoesNotNeedCsrfForPostQuery() {
        LocalPrincipal service = new LocalPrincipal(2, "service:test", "", "SERVICE_ACCOUNT",
                LocalPrincipal.Kind.SERVICE_ACCOUNT, true);
        SecurityContextHolder.getContext().setAuthentication(
                UsernamePasswordAuthenticationToken.authenticated(service, null, service.getAuthorities()));

        assertFalse(WebSecurityConfig.requiresCsrf(new MockHttpServletRequest("POST",
                "/api/v5/snapshots/1/diagnostics/summary/query")));
    }

    @Test
    void BearerHeaderAloneDoesNotBypassCsrf() {
        MockHttpServletRequest request = new MockHttpServletRequest("POST", "/api/v5/auth/login");
        request.addHeader("Authorization", "Bearer invalid");

        assertTrue(WebSecurityConfig.requiresCsrf(request));
    }
}
