package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5Dtos.*;

import java.util.List;
import java.util.Map;

import org.lareferencia.core.domain.NetworkSnapshot;
import org.lareferencia.core.metadata.IMetadataStore;
import org.lareferencia.core.metadata.ISnapshotStore;
import org.lareferencia.core.repository.jpa.NetworkSnapshotRepository;
import org.lareferencia.core.repository.validation.RecordValidation;
import org.lareferencia.core.service.management.SnapshotLogService;
import org.lareferencia.core.service.validation.IValidationStatisticsService;
import org.lareferencia.core.service.validation.ValidationRuleOccurrencesCount;
import org.lareferencia.core.service.validation.ValidationStatObservation;
import org.lareferencia.core.service.validation.ValidationStatsObservationsResult;
import org.lareferencia.core.service.validation.ValidationStatsResult;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class ApiV5DiagnosticsService {
    private final NetworkSnapshotRepository snapshots;
    private final SnapshotLogService logs;
    private final IValidationStatisticsService statistics;
    private final IMetadataStore metadataStore;
    private final ISnapshotStore snapshotStore;

    public ApiV5DiagnosticsService(NetworkSnapshotRepository snapshots, SnapshotLogService logs,
            IValidationStatisticsService statistics, IMetadataStore metadataStore, ISnapshotStore snapshotStore) {
        this.snapshots = snapshots; this.logs = logs; this.statistics = statistics;
        this.metadataStore = metadataStore; this.snapshotStore = snapshotStore;
    }

    public PageResponse<LogEntryResponse> logs(Long snapshotId, int page, int size) {
        requireSnapshot(snapshotId);
        SnapshotLogService.LogQueryResult result = logs.getLogEntries(snapshotId, page, size);
        if (!result.isSuccess()) throw new ApiV5Exception(HttpStatus.NOT_FOUND, "SNAPSHOT_LOG_NOT_FOUND", result.getError());
        return new PageResponse<>(result.getEntries().stream().map(e -> new LogEntryResponse(e.getTimestamp(), e.getMessage())).toList(),
                result.getCurrentPage(), result.getPageSize(), result.getTotalElements(), result.getTotalPages());
    }

    public DiagnosticSummaryResponse summary(Long snapshotId, List<DiagnosticFilter> filters) {
        try {
            ValidationStatsResult result = statistics.queryValidatorRulesStatsBySnapshot(requireSnapshot(snapshotId), translate(filters));
            List<DiagnosticRuleResponse> rules = result.getRulesByID().values().stream()
                    .map(rule -> new DiagnosticRuleResponse(rule.getRuleID(), rule.getName(), rule.getDescription(),
                            rule.getQuantifier() == null ? null : rule.getQuantifier().name(), rule.getMandatory(),
                            rule.getValidCount(), rule.getInvalidCount()))
                    .sorted(java.util.Comparator.comparing(DiagnosticRuleResponse::ruleId)).toList();
            List<DiagnosticFacetResponse> facets = result.getFacets().entrySet().stream()
                    .flatMap(entry -> entry.getValue().stream().map(facet -> new DiagnosticFacetResponse(entry.getKey(),
                            facet.getValue(), facet.getValueCount())))
                    .sorted(java.util.Comparator.comparing(DiagnosticFacetResponse::field)
                            .thenComparing(DiagnosticFacetResponse::value)).toList();
            return new DiagnosticSummaryResponse(value(result.getSize()), value(result.getValidSize()),
                    value(result.getTransformedSize()), rules, facets);
        } catch (ApiV5Exception exception) {
            throw exception;
        } catch (Exception exception) {
            throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "DIAGNOSTIC_QUERY_FAILED", exception.getMessage());
        }
    }

    public PageResponse<DiagnosticRecordResponse> records(Long snapshotId, List<DiagnosticFilter> filters, int page, int size) {
        requireSnapshot(snapshotId);
        try {
            ValidationStatsObservationsResult result = statistics.queryValidationStatsObservationsBySnapshotID(
                    snapshotId, translate(filters), PageRequest.of(page, size));
            return new PageResponse<>(result.getContent().stream().map(this::record).toList(), result.getCurrentPage(),
                    result.getPageSize(), result.getTotalElements(), result.getTotalPages());
        } catch (Exception exception) {
            throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "DIAGNOSTIC_QUERY_FAILED", exception.getMessage());
        }
    }

    public RuleOccurrencesResponse occurrences(Long snapshotId, Long ruleId, List<DiagnosticFilter> filters) {
        requireSnapshot(snapshotId);
        try {
            ValidationRuleOccurrencesCount result = statistics.queryValidRuleOccurrencesCountBySnapshotID(snapshotId,
                    ruleId, translate(filters));
            return new RuleOccurrencesResponse(ruleId,
                    occurrences(result.getValidRuleOccrs()), occurrences(result.getInvalidRuleOccrs()));
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
    private DiagnosticRecordResponse record(ValidationStatObservation item) {
        return new DiagnosticRecordResponse(item.getId(), item.getIdentifier(), item.getSnapshotId(), item.getOrigin(),
                item.getSetSpec(), item.getMetadataPrefix(), item.getNetworkAcronym(), item.getRepositoryName(),
                item.getInstitutionName(), item.getIsValid(), item.getIsTransformed(), item.getValidRulesList(),
                item.getInvalidRulesList(), copy(item.getValidOccurrencesByRuleID()), copy(item.getInvalidOccurrencesByRuleID()));
    }

    private Map<String, List<String>> copy(Map<String, List<String>> source) {
        return source == null ? Map.of() : source.entrySet().stream().collect(java.util.stream.Collectors.toUnmodifiableMap(
                Map.Entry::getKey, entry -> List.copyOf(entry.getValue())));
    }

    private List<RuleOccurrenceItemResponse> occurrences(
            List<org.lareferencia.core.service.validation.OccurrenceCount> source) {
        return source == null ? List.of() : source.stream()
                .map(item -> new RuleOccurrenceItemResponse(item.getValue(), item.getCount())).toList();
    }

    List<String> translate(List<DiagnosticFilter> filters) {
        if (filters == null || filters.isEmpty()) return List.of();
        return filters.stream().map(this::translate).toList();
    }

    private String translate(DiagnosticFilter filter) {
        if (filter == null || filter.field() == null || filter.value() == null) {
            throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "DIAGNOSTIC_FILTER_INVALID",
                    "Each diagnostic filter requires field and value");
        }
        DiagnosticFilterOperator operator = filter.operator() == null ? DiagnosticFilterOperator.EQ : filter.operator();
        String value = String.valueOf(filter.value()).replace("\"", "").trim();
        return switch (filter.field()) {
            case IDENTIFIER -> {
                if (operator != DiagnosticFilterOperator.CONTAINS && operator != DiagnosticFilterOperator.EQ)
                    throw invalidOperator();
                yield "identifier@@\"" + value + "\"";
            }
            case VALID -> booleanFilter("is_valid", value, operator);
            case TRANSFORMED -> booleanFilter("is_transformed", value, operator);
            case RULE_VALID -> ruleFilter("valid_rules", value, operator);
            case RULE_INVALID -> ruleFilter("invalid_rules", value, operator);
        };
    }

    private String booleanFilter(String field, String value, DiagnosticFilterOperator operator) {
        if (operator != DiagnosticFilterOperator.EQ || !("true".equalsIgnoreCase(value) || "false".equalsIgnoreCase(value)))
            throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "DIAGNOSTIC_FILTER_INVALID",
                    field + " requires EQ and a boolean value");
        return field + "@@\"" + value.toLowerCase(java.util.Locale.ROOT) + "\"";
    }

    private String ruleFilter(String field, String value, DiagnosticFilterOperator operator) {
        if (operator != DiagnosticFilterOperator.EQ || !value.matches("[0-9]+"))
            throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "DIAGNOSTIC_FILTER_INVALID",
                    field + " requires EQ and a numeric rule id");
        return field + "@@\"" + value + "\"";
    }

    private ApiV5Exception invalidOperator() {
        return new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "DIAGNOSTIC_FILTER_INVALID",
                "Operator is not supported for this diagnostic field");
    }

    private int value(Integer value) { return value == null ? 0 : value; }
}
