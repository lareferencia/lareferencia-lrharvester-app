package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5Dtos.*;

import java.util.List;

import org.lareferencia.core.domain.NetworkSnapshot;
import org.lareferencia.core.metadata.IMetadataStore;
import org.lareferencia.core.metadata.ISnapshotStore;
import org.lareferencia.core.repository.jpa.NetworkSnapshotRepository;
import org.lareferencia.core.repository.validation.RecordValidation;
import org.lareferencia.core.service.management.SnapshotLogService;
import org.lareferencia.core.service.validation.IValidationStatisticsService;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class ApiV5DiagnosticsService {
    private final NetworkSnapshotRepository snapshots;
    private final SnapshotLogService logs;
    private final IValidationStatisticsService statistics;
    private final IMetadataStore metadataStore;
    private final ISnapshotStore snapshotStore;
    private final ObjectMapper objectMapper;

    public ApiV5DiagnosticsService(NetworkSnapshotRepository snapshots, SnapshotLogService logs,
            IValidationStatisticsService statistics, IMetadataStore metadataStore, ISnapshotStore snapshotStore,
            ObjectMapper objectMapper) {
        this.snapshots = snapshots; this.logs = logs; this.statistics = statistics;
        this.metadataStore = metadataStore; this.snapshotStore = snapshotStore; this.objectMapper = objectMapper;
    }

    public PageResponse<LogEntryResponse> logs(Long snapshotId, int page, int size) {
        requireSnapshot(snapshotId);
        SnapshotLogService.LogQueryResult result = logs.getLogEntries(snapshotId, page, size);
        if (!result.isSuccess()) throw new ApiV5Exception(HttpStatus.NOT_FOUND, "SNAPSHOT_LOG_NOT_FOUND", result.getError());
        return new PageResponse<>(result.getEntries().stream().map(e -> new LogEntryResponse(e.getTimestamp(), e.getMessage())).toList(),
                result.getCurrentPage(), result.getPageSize(), result.getTotalElements(), result.getTotalPages());
    }

    public DiagnosticResponse summary(Long snapshotId, List<String> filters) {
        try {
            return new DiagnosticResponse(objectMapper.valueToTree(statistics.queryValidatorRulesStatsBySnapshot(requireSnapshot(snapshotId), safe(filters))));
        } catch (Exception exception) {
            throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "DIAGNOSTIC_QUERY_FAILED", exception.getMessage());
        }
    }

    public DiagnosticResponse records(Long snapshotId, List<String> filters, int page, int size) {
        requireSnapshot(snapshotId);
        try {
            return new DiagnosticResponse(objectMapper.valueToTree(statistics.queryValidationStatsObservationsBySnapshotID(snapshotId, safe(filters), PageRequest.of(page, size))));
        } catch (Exception exception) {
            throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "DIAGNOSTIC_QUERY_FAILED", exception.getMessage());
        }
    }

    public DiagnosticResponse occurrences(Long snapshotId, Long ruleId, List<String> filters) {
        requireSnapshot(snapshotId);
        try {
            return new DiagnosticResponse(objectMapper.valueToTree(statistics.queryValidRuleOccurrencesCountBySnapshotID(snapshotId, ruleId, safe(filters))));
        } catch (Exception exception) {
            throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "DIAGNOSTIC_QUERY_FAILED", exception.getMessage());
        }
    }

    public String metadata(Long snapshotId, String identifier) {
        if (identifier == null || identifier.isBlank()) throw new ApiV5Exception(HttpStatus.BAD_REQUEST, "IDENTIFIER_REQUIRED", "identifier is required");
        requireSnapshot(snapshotId);
        try {
            RecordValidation validation = statistics.getRecordValidationListBySnapshotAndIdentifier(snapshotId, identifier);
            if (validation == null) throw new ApiV5Exception(HttpStatus.NOT_FOUND, "RECORD_NOT_FOUND", "Record was not found in diagnostics");
            return metadataStore.getMetadata(snapshotStore.getSnapshotMetadata(snapshotId), validation.getPublishedMetadataHash());
        } catch (ApiV5Exception exception) { throw exception;
        } catch (Exception exception) { throw new ApiV5Exception(HttpStatus.NOT_FOUND, "METADATA_NOT_FOUND", exception.getMessage()); }
    }

    private NetworkSnapshot requireSnapshot(Long id) { return snapshots.findById(id).orElseThrow(() -> new ApiV5Exception(HttpStatus.NOT_FOUND, "SNAPSHOT_NOT_FOUND", "Snapshot " + id + " was not found")); }
    private List<String> safe(List<String> filters) { List<String> safe = filters == null ? List.of() : filters; if (!statistics.validateFilters(safe)) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "DIAGNOSTIC_FILTER_INVALID", "One or more diagnostic filters are invalid"); return safe; }
}
