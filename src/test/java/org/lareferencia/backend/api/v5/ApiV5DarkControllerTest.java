package org.lareferencia.backend.api.v5;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.OffsetDateTime;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.lareferencia.contrib.dark.services.DarkRuntimeConfigurationService;
import org.lareferencia.contrib.dark.worker.DarkManualRunningContext;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import com.fasterxml.jackson.databind.ObjectMapper;

class ApiV5DarkControllerTest {
    private MockMvc mvc;
    private ApiV5DarkService service;

    @BeforeEach
    void setUp() {
        service = mock(ApiV5DarkService.class);
        mvc = MockMvcBuilders.standaloneSetup(new ApiV5DarkController(service, mock(DarkRuntimeConfigurationService.class)))
                .setMessageConverters(new MappingJackson2HttpMessageConverter(new ObjectMapper().findAndRegisterModules()))
                .setControllerAdvice(new ApiV5ExceptionHandler()).build();
    }

    @Test
    void stageReturnsAcceptedCommandContract() throws Exception {
        when(service.launch(eq("12345"), eq("admin"), eq(DarkManualRunningContext.Action.STAGE), any()))
                .thenReturn(new ApiV5DarkDtos.ManualCommandResponse("cmd-1", "QUEUED", "STAGE", 1,
                        "QUEUED", 0, 0, 0, 0, "/api/v5/dark/commands/cmd-1", OffsetDateTime.parse("2026-01-01T00:00:00Z")));
        var admin = new UsernamePasswordAuthenticationToken("admin", "n/a",
                List.of(new SimpleGrantedAuthority("ROLE_ADMIN")));
        mvc.perform(post("/api/v5/dark/naans/12345/stage").principal(admin)
                        .contentType(MediaType.APPLICATION_JSON).content("{\"oaiIds\":[\"oai:test:1\"]}"))
                .andExpect(status().isAccepted())
                .andExpect(jsonPath("$.commandId").value("cmd-1"))
                .andExpect(jsonPath("$.status").value("QUEUED"))
                .andExpect(jsonPath("$.statusUrl").value("/api/v5/dark/commands/cmd-1"));
    }

    @Test
    void previewReturnsPayloadShape() throws Exception {
        when(service.preview(eq("12345"), any())).thenReturn(new ApiV5DarkDtos.PreviewResponse(List.of(
                new ApiV5DarkDtos.PreviewItem("oai:test:1", "ark:123/1", "PUBLISHED", true, null,
                        "https://example.org/item", 12, 34, 56, List.of(), null, null))));
        var admin = new UsernamePasswordAuthenticationToken("admin", "n/a",
                List.of(new SimpleGrantedAuthority("ROLE_ADMIN")));
        mvc.perform(post("/api/v5/dark/naans/12345/preview").principal(admin)
                        .contentType(MediaType.APPLICATION_JSON).content("{\"oaiIds\":[\"oai:test:1\"]}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.items[0].eligible").value(true))
                .andExpect(jsonPath("$.items[0].l1Bytes").value(12))
                .andExpect(jsonPath("$.items[0].l2Bytes").value(34));
    }
}
