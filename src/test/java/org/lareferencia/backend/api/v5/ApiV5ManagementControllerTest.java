package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5Dtos.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import com.fasterxml.jackson.databind.ObjectMapper;

class ApiV5ManagementControllerTest {
    private ApiV5ManagementService service;
    private MockMvc mvc;

    @BeforeEach
    void setUp() {
        service = new StubManagementService();
        mvc = MockMvcBuilders.standaloneSetup(new ApiV5ManagementController(service, new ObjectMapper()))
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

    private static final class StubManagementService extends ApiV5ManagementService {
        StubManagementService() { super(null, null, null, null, null, null, null, new ObjectMapper(), null); }
        @Override
        public PageResponse<NetworkResponse> listNetworks(int page, int size) {
            return new PageResponse<>(List.of(), page, size, 0, 0);
        }
    }
}
