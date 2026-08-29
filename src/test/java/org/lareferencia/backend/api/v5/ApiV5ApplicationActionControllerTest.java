package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5ApplicationActionDtos.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.OffsetDateTime;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import com.fasterxml.jackson.databind.ObjectMapper;

class ApiV5ApplicationActionControllerTest {
    private final ObjectMapper mapper = new ObjectMapper();
    private MockMvc mvc;

    @BeforeEach
    void setUp() {
        mvc = MockMvcBuilders.standaloneSetup(new ApiV5ApplicationActionController(new StubService()))
                .setControllerAdvice(new ApiV5ExceptionHandler()).build();
    }

    @Test
    void list_UsesPersistenceFreeContract() throws Exception {
        mvc.perform(get("/api/v5/application-actions").accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].actionKey").value("harvesting"))
                .andExpect(jsonPath("$[0].state").value("ENABLED"))
                .andExpect(jsonPath("$[0]._links").doesNotExist());
    }

    @Test
    void replace_AcceptsObjectConfiguration() throws Exception {
        var authentication = new UsernamePasswordAuthenticationToken("admin", "n/a", List.of());
        mvc.perform(put("/api/v5/application-actions/harvesting").principal(authentication)
                        .accept(MediaType.APPLICATION_JSON).contentType(MediaType.APPLICATION_JSON)
                        .content("{\"enabled\":false,\"configuration\":{}}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.enabled").value(false));
    }

    private final class StubService extends ApiV5ApplicationActionService {
        StubService() { super(null, null, null); }

        @Override public List<ApplicationActionResponse> list() { return List.of(response(true)); }
        @Override public ApplicationActionResponse replace(String key, ApplicationActionRequest request, String user) {
            return response(request.enabled());
        }

        private ApplicationActionResponse response(boolean enabled) {
            var empty = mapper.createObjectNode();
            return new ApplicationActionResponse(1L, "legacy", "harvesting", enabled ? "ENABLED" : "DISABLED",
                    0, enabled, true, empty, empty, empty, empty, List.of(), OffsetDateTime.now(), OffsetDateTime.now(), "test");
        }
    }
}
