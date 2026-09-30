package org.lareferencia.backend.security;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.csrf.HttpSessionCsrfTokenRepository;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

class LocalAuthControllerTest {
    @Test
    void meReportsReaderAndAssignedNetworks() throws Exception {
        LocalPrincipal reader = new LocalPrincipal(7, "reader", "", "READER", LocalPrincipal.Kind.USER, true);
        Authentication authentication = UsernamePasswordAuthenticationToken.authenticated(
                reader, null, reader.getAuthorities());
        LocalAuthorizationService authorization = new LocalAuthorizationService(null) {
            @Override public List<Long> readableNetworkIds(Authentication ignored) { return List.of(3L, 8L); }
        };
        var mvc = MockMvcBuilders.standaloneSetup(new LocalAuthController(
                ignored -> authentication, authorization, new HttpSessionCsrfTokenRepository())).build();

        mvc.perform(get("/api/v5/me").accept(MediaType.APPLICATION_JSON).principal(authentication))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.username").value("reader"))
                .andExpect(jsonPath("$.roles[0]").value("READER"))
                .andExpect(jsonPath("$.readableNetworkIds[0]").value(3))
                .andExpect(jsonPath("$.readableNetworkIds[1]").value(8))
                .andExpect(jsonPath("$.serviceAccount").value(false));
    }

    @Test
    void meReportsDashboardRoleAndAssignedNetworks() throws Exception {
        LocalPrincipal dashboard = new LocalPrincipal(8, "dashboard", "", "DASHBOARD", LocalPrincipal.Kind.USER, true);
        Authentication authentication = UsernamePasswordAuthenticationToken.authenticated(
                dashboard, null, dashboard.getAuthorities());
        LocalAuthorizationService authorization = new LocalAuthorizationService(null) {
            @Override public List<Long> readableNetworkIds(Authentication ignored) { return List.of(3L); }
        };
        var mvc = MockMvcBuilders.standaloneSetup(new LocalAuthController(
                ignored -> authentication, authorization, new HttpSessionCsrfTokenRepository())).build();

        mvc.perform(get("/api/v5/me").accept(MediaType.APPLICATION_JSON).principal(authentication))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.roles[0]").value("DASHBOARD"))
                .andExpect(jsonPath("$.readableNetworkIds[0]").value(3));
    }

    @Test
    void serviceAccountCannotUseBrowserLogin() throws Exception {
        LocalPrincipal service = new LocalPrincipal(9, "service:test", "", "SERVICE_ACCOUNT",
                LocalPrincipal.Kind.SERVICE_ACCOUNT, true);
        Authentication authentication = UsernamePasswordAuthenticationToken.authenticated(
                service, null, service.getAuthorities());
        var mvc = MockMvcBuilders.standaloneSetup(new LocalAuthController(
                ignored -> authentication, new LocalAuthorizationService(null), new HttpSessionCsrfTokenRepository())).build();

        mvc.perform(post("/api/v5/auth/login").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"username\":\"service:test\",\"password\":\"unused\"}"))
                .andExpect(status().isUnauthorized());
    }
}
