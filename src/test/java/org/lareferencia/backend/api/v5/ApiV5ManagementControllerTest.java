package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5Dtos.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.OffsetDateTime;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import com.fasterxml.jackson.databind.ObjectMapper;

class ApiV5ManagementControllerTest {
    private ApiV5ManagementService service;
    private MockMvc mvc;

    @BeforeEach
    void setUp() {
        service = new StubManagementService();
        ObjectMapper mapper = new ObjectMapper();
        mvc = MockMvcBuilders.standaloneSetup(new ApiV5ManagementController(service, mapper,
                        new StubNetworkSummaryService(), null))
                .setControllerAdvice(new ApiV5ExceptionHandler()).build();
    }

    @Test
    void listNetworks_UsesZeroBasedPaginationContract() throws Exception {
        mvc.perform(get("/api/v5/networks?page=0&size=25"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.page").value(0))
                .andExpect(jsonPath("$.items").isArray());
    }

    @Test
    void listNetworks_RejectsNegativePageAsProblemDetail() throws Exception {
        mvc.perform(get("/api/v5/networks?page=-1"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("PAGE_INVALID"));
    }

    @Test
    void networkSummaries_ExposeDashboardProjection() throws Exception {
        mvc.perform(get("/api/v5/network-summaries?page=0&size=25&sort=name,asc"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items[0].acronym").value("TEST"))
                .andExpect(jsonPath("$.items[0].latestSnapshot.endTime").value("2026-08-25T10:00:00Z"))
                .andExpect(jsonPath("$.items[0].runtime.runningCount").value(1));
    }

    @Test
    void me_ExposesNormalizedRoles() throws Exception {
        var authentication = new UsernamePasswordAuthenticationToken("reader", "n/a",
                List.of(new SimpleGrantedAuthority("ROLE_VIEWER")));
        mvc.perform(get("/api/v5/me").principal(authentication))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.username").value("reader"))
                .andExpect(jsonPath("$.roles[0]").value("VIEWER"));
    }

    private static final class StubManagementService extends ApiV5ManagementService {
        StubManagementService() { super(null, null, null, null, null, null, null, null, null, new ObjectMapper(), null, null); }
        @Override
        public PageResponse<NetworkResponse> listNetworks(int page, int size) {
            return new PageResponse<>(List.of(), page, size, 0, 0);
        }
    }

    private static final class StubNetworkSummaryService extends ApiV5NetworkSummaryService {
        StubNetworkSummaryService() { super(null, null); }

        @Override
        public PageResponse<NetworkSummaryResponse> list(int page, int size, String sort, String q, String acronym,
                String name, String institutionName, Boolean published, String snapshotStatus, String indexStatus) {
            SnapshotResponse snapshot = new SnapshotResponse(10L, 1L, null, "VALID", "INDEXED",
                    OffsetDateTime.parse("2026-08-25T09:00:00Z"), null,
                    OffsetDateTime.parse("2026-08-25T10:00:00Z"), 100, 90, 80, false);
            RuntimeStateResponse runtime = new RuntimeStateResponse(1, 0, 1, List.of("harvesting"), List.of(),
                    List.of("scheduled"));
            NetworkSummaryResponse item = new NetworkSummaryResponse(1L, true, "TEST", "Test network",
                    "Institution", "INST", snapshot, 10L, snapshot.endTime(), runtime);
            return new PageResponse<>(List.of(item), page, size, 1, 1);
        }
    }
}
