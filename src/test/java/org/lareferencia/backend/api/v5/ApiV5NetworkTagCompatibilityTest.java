package org.lareferencia.backend.api.v5;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;
import java.util.*;
import org.junit.jupiter.api.Test;
import org.lareferencia.core.domain.Network;
import org.lareferencia.core.repository.jpa.NetworkRepository;
import org.lareferencia.core.task.NetworkActionkManager;
import org.springframework.mock.web.MockMultipartFile;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import com.fasterxml.jackson.databind.ObjectMapper;
import static org.lareferencia.backend.api.v5.ApiV5Dtos.*;
import static org.lareferencia.backend.api.v5.ApiV5NetworkTransferDtos.*;

class ApiV5NetworkTagCompatibilityTest {
    @Test void jsonClientsCanOmitTags() throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        var node = mapper.valueToTree(request(List.of("piloto")));
        ((com.fasterxml.jackson.databind.node.ObjectNode) node).remove("tags");
        assertNull(mapper.treeToValue(node, NetworkRequest.class).tags());
    }
    @Test void updatingAnOlderRequestPreservesTagsAndExplicitEmptyClearsThem() {
        NetworkRepository repository = mock(NetworkRepository.class);
        Network network = new Network(); network.setAcronym("TEST"); network.setTags(new LinkedHashSet<>(List.of("piloto")));
        when(repository.findById(1L)).thenReturn(Optional.of(network));
        when(repository.save(any(Network.class))).thenAnswer(call -> call.getArgument(0));
        var actions = mock(NetworkActionkManager.class);
        when(actions.getRunningTasksByRunningContextID(anyString())).thenReturn(List.of());
        when(actions.getQueuedTasksByRunningContextID(anyString())).thenReturn(List.of());
        var management = new ApiV5ManagementService(repository, null, null, null, null, null, actions,
                null, null, null, new ObjectMapper(), null, mock(ApiV5AttributeProfileService.class));
        management.replaceNetwork(1L, request(null));
        assertEquals(Set.of("piloto"), network.getTags());
        management.replaceNetwork(1L, request(List.of(" PAIS:AR ", "pais:ar")));
        assertEquals(Set.of("pais:ar"), network.getTags());
        management.replaceNetwork(1L, request(List.of()));
        assertTrue(network.getTags().isEmpty());
        verify(actions, never()).rescheduleNetwork(any());
    }
    NetworkRequest request(List<String> tags) {
        return new NetworkRequest("TEST", "Test", "Institution", null, false, "https://example.org/oai",
                null, null, List.of(), Map.of(), Map.of(), null, null, null, null, null, tags);
    }
    @Test void spreadsheetsDistinguishMissingTagsFromExplicitEmptyAndRoundTripTags() throws Exception {
        var repository = mock(NetworkRepository.class);
        Network network = new Network(); network.setAcronym("TEST"); network.setName("Test"); network.setInstitutionName("Institution");
        network.setOriginURL("https://example.org/oai"); network.setTags(new LinkedHashSet<>(List.of("piloto")));
        when(repository.findByAcronym("TEST")).thenReturn(network);
        when(repository.findAll()).thenReturn(List.of(network));
        var management = mock(ApiV5ManagementService.class);
        when(management.replaceNetwork(any(), any())).thenReturn(response());
        var service = new ApiV5NetworkTransferService(repository, mock(org.lareferencia.core.repository.jpa.ValidatorRepository.class),
                mock(org.lareferencia.core.repository.jpa.TransformerRepository.class), management,
                mock(ApiV5AttributeProfileService.class), mock(org.lareferencia.core.task.NetworkActionConfigurationService.class),
                mock(org.lareferencia.core.task.ApplicationActionCatalogService.class), mock(NetworkActionkManager.class), new ObjectMapper());
        service.importXlsx(file(null), ImportMode.UPSERT, "admin");
        verify(management).replaceNetwork(any(), argThat(request -> request.tags() == null));
        clearInvocations(management);
        service.importXlsx(file("[]"), ImportMode.UPSERT, "admin");
        verify(management).replaceNetwork(any(), argThat(request -> request.tags().isEmpty()));
        clearInvocations(management);
        byte[] bytes = service.exportXlsx();
        service.importXlsx(new MockMultipartFile("file", "sources.xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", bytes), ImportMode.UPSERT, "admin");
        verify(management).replaceNetwork(any(), argThat(request -> request.tags().equals(List.of("piloto"))));
        assertEquals(1, service.validate(file("invalid"), ImportMode.UPSERT).invalidRows());
        assertEquals(1, service.validate(file("[123]"), ImportMode.UPSERT).invalidRows());
    }
    NetworkResponse response() {
        return new NetworkResponse(1L, false, "TEST", "Test", "Institution", null, "https://example.org/oai",
            "oai_dc", "xoai", List.of(), Map.of(), Map.of(), null, null, null, null, null, List.of("piloto"));
    }
    MockMultipartFile file(String tags) throws Exception {
        try (var book = new XSSFWorkbook(); var out = new java.io.ByteArrayOutputStream()) {
            var sheet = book.createSheet("Fuentes"); var header = sheet.createRow(0); var row = sheet.createRow(1);
            String[] columns = { "acronym", "name", "institutionName", "originUrl" };
            String[] values = { "TEST", "Test", "Institution", "https://example.org/oai" };
            for (int i=0; i<columns.length; i++) { header.createCell(i).setCellValue(columns[i]); row.createCell(i).setCellValue(values[i]); }
            if (tags != null) { header.createCell(4).setCellValue("tagsJson"); row.createCell(4).setCellValue(tags); }
            book.write(out);
            return new MockMultipartFile("file", "sources.xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", out.toByteArray());
        }
    }
}
