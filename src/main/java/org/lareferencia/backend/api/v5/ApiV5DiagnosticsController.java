package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5Dtos.*;

import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/v5/snapshots/{snapshotId}")
@PreAuthorize("hasAnyRole('VIEWER','ADMIN')")
public class ApiV5DiagnosticsController {
    private final ApiV5DiagnosticsService service;
    public ApiV5DiagnosticsController(ApiV5DiagnosticsService service) { this.service = service; }

    @GetMapping("/logs") public PageResponse<LogEntryResponse> logs(@PathVariable Long snapshotId, @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "100") int size) { return service.logs(snapshotId, validPage(page), validSize(size)); }
    @GetMapping("/diagnostics/summary") public DiagnosticSummaryResponse summary(@PathVariable Long snapshotId) { return service.summary(snapshotId, null); }
    @PostMapping(path = "/diagnostics/summary/query", consumes = MediaType.APPLICATION_JSON_VALUE) public DiagnosticSummaryResponse summaryQuery(@PathVariable Long snapshotId, @Valid @RequestBody DiagnosticQuery query) { return service.summary(snapshotId, query.filters()); }
    @GetMapping("/diagnostics/records") public PageResponse<DiagnosticRecordResponse> records(@PathVariable Long snapshotId, @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "25") int size) { return service.records(snapshotId, null, validPage(page), validSize(size)); }
    @PostMapping(path = "/diagnostics/records/query", consumes = MediaType.APPLICATION_JSON_VALUE) public PageResponse<DiagnosticRecordResponse> recordsQuery(@PathVariable Long snapshotId, @Valid @RequestBody DiagnosticQuery query) { return service.records(snapshotId, query.filters(), validPage(query.page() == null ? 0 : query.page()), validSize(query.size() == null ? 25 : query.size())); }
    @GetMapping("/diagnostics/rules/{ruleId}/occurrences") public RuleOccurrencesResponse occurrences(@PathVariable Long snapshotId, @PathVariable Long ruleId) { return service.occurrences(snapshotId, ruleId, null); }
    @PostMapping(path = "/diagnostics/rules/{ruleId}/occurrences/query", consumes = MediaType.APPLICATION_JSON_VALUE) public RuleOccurrencesResponse occurrencesQuery(@PathVariable Long snapshotId, @PathVariable Long ruleId, @Valid @RequestBody DiagnosticQuery query) { return service.occurrences(snapshotId, ruleId, query.filters()); }
    @GetMapping(path = "/diagnostics/records/metadata", produces = "application/xml") public String metadata(@PathVariable Long snapshotId, @RequestParam String identifier) { return service.metadata(snapshotId, identifier); }
    private int validPage(int page) { if (page < 0) throw new ApiV5Exception(org.springframework.http.HttpStatus.BAD_REQUEST, "PAGE_INVALID", "page must be zero or greater"); return page; }
    private int validSize(int size) { if (size < 1 || size > 200) throw new ApiV5Exception(org.springframework.http.HttpStatus.BAD_REQUEST, "SIZE_INVALID", "size must be between 1 and 200"); return size; }
}
