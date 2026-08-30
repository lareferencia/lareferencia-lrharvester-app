package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5NetworkTransferDtos.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

class ApiV5NetworkTransferControllerTest {
    private ApiV5NetworkTransferService service;
    private MockMvc mvc;

    @BeforeEach
    void setUp() {
        service = mock(ApiV5NetworkTransferService.class);
        mvc = MockMvcBuilders.standaloneSetup(new ApiV5NetworkTransferController(service))
                .setControllerAdvice(new ApiV5ExceptionHandler()).build();
    }

    @Test
    void exportUsesAnAttachmentXlsxContract() throws Exception {
        when(service.exportXlsx()).thenReturn(new byte[] { 1, 2, 3 });
        mvc.perform(get("/api/v5/network-transfers/export.xlsx"))
                .andExpect(status().isOk())
                .andExpect(content().contentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                .andExpect(header().string("Content-Disposition", org.hamcrest.Matchers.containsString("attachment")));
    }

    @Test
    void validationReturnsRowsWithoutWritingAnything() throws Exception {
        ImportValidationResponse response = new ImportValidationResponse("lareferencia-network-xlsx", 1,
                ImportMode.UPSERT, 1, 0, 1, List.of(new ImportRowResult(2, "ABC", "CREATE",
                        List.of("validatorRef: validator not found: Common"), List.of())));
        when(service.validate(any(), eq(ImportMode.UPSERT))).thenReturn(response);
        MockMultipartFile file = new MockMultipartFile("file", "sources.xlsx",
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", new byte[] { 1 });
        mvc.perform(multipart("/api/v5/network-transfers/import/validate").file(file))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.invalidRows").value(1))
                .andExpect(jsonPath("$.rows[0].errors[0]").value("validatorRef: validator not found: Common"));
    }
}
