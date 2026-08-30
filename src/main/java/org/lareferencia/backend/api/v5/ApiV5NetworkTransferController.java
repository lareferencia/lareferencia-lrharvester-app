package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5NetworkTransferDtos.*;

import java.time.LocalDate;

import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v5/network-transfers")
public class ApiV5NetworkTransferController {
    private static final MediaType XLSX = MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
    private final ApiV5NetworkTransferService service;

    public ApiV5NetworkTransferController(ApiV5NetworkTransferService service) { this.service = service; }

    @GetMapping(value = "/export.xlsx", produces = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<byte[]> exportXlsx() {
        String name = "fuentes-" + LocalDate.now() + ".xlsx";
        return ResponseEntity.ok().contentType(XLSX).header(HttpHeaders.CONTENT_DISPOSITION,
                ContentDisposition.attachment().filename(name).build().toString()).body(service.exportXlsx());
    }

    @PostMapping(path = "/import/validate", consumes = MediaType.MULTIPART_FORM_DATA_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    @PreAuthorize("hasRole('ADMIN')")
    public ImportValidationResponse validate(@RequestParam("file") MultipartFile file,
            @RequestParam(defaultValue = "UPSERT") ImportMode mode) { return service.validate(file, mode); }

    @PostMapping(path = "/import", consumes = MediaType.MULTIPART_FORM_DATA_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    @PreAuthorize("hasRole('ADMIN')")
    public ImportResult importXlsx(@RequestParam("file") MultipartFile file,
            @RequestParam(defaultValue = "UPSERT") ImportMode mode, Authentication authentication) {
        return service.importXlsx(file, mode, authentication.getName());
    }
}
