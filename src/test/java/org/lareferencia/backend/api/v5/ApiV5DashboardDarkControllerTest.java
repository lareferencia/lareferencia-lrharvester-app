package org.lareferencia.backend.api.v5;

import java.util.UUID;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.lareferencia.backend.security.LocalAuthorizationService;
import org.lareferencia.backend.security.LocalPrincipal;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class ApiV5DashboardDarkControllerTest {
    private static final String ROOT = "/api/v5/dashboard/networks/";
    private MockMvc mvc;
    private JdbcTemplate jdbc;
    private final UsernamePasswordAuthenticationToken reader = principal(LocalPrincipal.Kind.USER);

    private static UsernamePasswordAuthenticationToken principal(LocalPrincipal.Kind kind) {
        var principal = new LocalPrincipal(7, "reader", "", "DASHBOARD", kind, true);
        return new UsernamePasswordAuthenticationToken(principal, null, principal.getAuthorities());
    }

    @BeforeEach void setup() {
        var ds = new DriverManagerDataSource("jdbc:h2:mem:" + UUID.randomUUID() + ";DB_CLOSE_DELAY=-1", "sa", "");
        jdbc = new JdbcTemplate(ds);
        jdbc.execute("create table network (id bigint)");
        jdbc.execute("insert into network values (1), (2)");
        jdbc.execute("create table local_user_network_read (user_id bigint, network_id bigint)");
        jdbc.execute("insert into local_user_network_read values (7, 1)");
        jdbc.execute("create table dark_tracking_record (ark_naan varchar, source_network_id bigint, ark varchar, "
                + "oai_id varchar, state char, updated_at timestamp)");
        mvc = MockMvcBuilders.standaloneSetup(new ApiV5DashboardDarkController(
                new LocalAuthorizationService(jdbc), new DashboardDarkReport(ds)))
                .setControllerAdvice(new ApiV5ExceptionHandler()).build();
    }

    private void row(Integer owner, String ark, String oai, String state, String updated) {
        jdbc.update("insert into dark_tracking_record values ('123', ?, ?, ?, ?, cast(? as timestamp))",
                owner, ark, oai, state, updated);
    }

    @Test void listAndFullExportUseTheSameScopeAndLiteralFilters() throws Exception {
        String day = "2026-05-04";
        row(1, "ark:123/a", "=Te_st%;\"A", "P", day + " 00:00:00");
        row(1, "ark:123/b", "te_st%b", "P", day + " 23:59:59.999999");
        row(2, "ark:123/private", "te_st%", "P", day);
        row(null, "ark:123/legacy", "te_st%", "P", day);
        row(1, null, "te_st%", "P", day);
        row(1, "ark:123/wrong-state", "te_st%", "R", day);
        row(1, "ark:123/wildcard", "testSomething", "P", day);
        row(1, "ark:123/next-day", "te_st%", "P", "2026-05-05");
        String path = ROOT + "1/dark";
        for (int page = 0; page < 2; page++) {
            mvc.perform(get(path).principal(reader).param("q", "TE_ST%").param("from", day).param("to", day)
                    .param("state", "PUBLISHED").param("size", "1").param("page", String.valueOf(page)))
                    .andExpect(status().isOk()).andExpect(jsonPath("$.totalElements").value(2))
                    .andExpect(jsonPath("$.content.length()").value(1))
                    .andExpect(jsonPath("$.content[0].ark").value(page == 0 ? "ark:123/b" : "ark:123/a"));
        }
        var response = mvc.perform(get(path + "/export.csv").principal(reader).param("q", "TE_ST%")
                .param("state", "PUBLISHED").param("from", day).param("to", day))
                .andExpect(status().isOk()).andExpect(header().string("Content-Disposition", "attachment; filename=\"dark-network-1.csv\""))
                .andReturn().getResponse();
        assertEquals(List.of("\uFEFFark;oai_id;state;updated_at_utc", "\"ark:123/b\";\"te_st%b\";PUBLISHED;2026-05-04T23:59:59.999999Z",
                "\"ark:123/a\";\"'=Te_st%;\"\"A\";PUBLISHED;2026-05-04T00:00Z"), response.getContentAsString().lines().toList());
    }

    @Test void bothResourcesEnforceRoleGrantAndDates() throws Exception {
        for (String suffix : List.of("/dark", "/dark/export.csv")) {
            mvc.perform(get(ROOT + "2" + suffix).principal(reader)).andExpect(status().isForbidden());
            mvc.perform(get(ROOT + "1" + suffix)).andExpect(status().isUnauthorized());
            mvc.perform(get(ROOT + "1" + suffix).principal(principal(LocalPrincipal.Kind.SERVICE_ACCOUNT)))
                    .andExpect(status().isForbidden());
            mvc.perform(get(ROOT + "1" + suffix).principal(reader).param("from", "2026-05-05").param("to", "2026-05-04"))
                    .andExpect(status().isUnprocessableEntity());
            mvc.perform(get(ROOT + "1" + suffix).principal(reader).param("state", "MISSING"))
                    .andExpect(status().isUnprocessableEntity());
        }
    }
}
