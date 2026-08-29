package org.lareferencia.backend.api.v5;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.annotation.JsonFormat;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/** Public, persistence-free v5 API contract. */
public final class ApiV5Dtos {
    private ApiV5Dtos() {
    }

    public record PageResponse<T>(List<T> items, int page, int size, long totalElements, int totalPages) {
    }

    public record NetworkResponse(Long id, boolean published, String acronym, String name, String institutionName,
            String institutionAcronym, String originUrl, String metadataPrefix, String metadataStoreSchema,
            List<String> sets, Map<String, Object> attributes, Map<String, Boolean> properties,
            String scheduleCronExpression, Long prevalidatorId, Long validatorId, Long transformerId,
            Long secondaryTransformerId) {
    }

    public record NetworkSummaryResponse(Long id, boolean published, String acronym, String name,
            String institutionName, String institutionAcronym, SnapshotResponse latestSnapshot,
            Long lastValidSnapshotId, @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime lastValidSnapshotAt,
            RuntimeStateResponse runtime) {
    }

    public record RuntimeStateResponse(int runningCount, int queuedCount, int scheduledCount,
            List<String> running, List<String> queued, List<String> scheduled) {
    }

    public record NetworkRequest(@NotBlank @Size(min = 2, max = 10)
            @Pattern(regexp = "^[A-Za-z0-9][A-Za-z0-9._-]*$", message = "must contain only letters, digits, dot, underscore or hyphen") String acronym,
            @NotBlank String name, @NotBlank String institutionName,
            String institutionAcronym, Boolean published, @NotBlank String originUrl, String metadataPrefix,
            String metadataStoreSchema, List<String> sets, Map<String, Object> attributes,
            Map<String, Boolean> properties, String scheduleCronExpression, Long prevalidatorId, Long validatorId,
            Long transformerId, Long secondaryTransformerId) {
    }

    public record RuleRequest(@Positive Long id, String typeId, String className, @NotBlank String name, String description,
            Boolean mandatory, String quantifier, Integer runOrder, @NotNull JsonNode configuration) {
    }

    public record ValidatorRequest(@NotBlank String name, String description, List<@Valid RuleRequest> rules) {
    }

    public record TransformerRequest(@NotBlank String name, String description, List<@Valid RuleRequest> rules) {
    }

    /** Changes the configuration identity without reconciling its child rules. */
    public record ConfigurationMetadataRequest(@NotBlank String name, String description) {
    }

    public record RuleResponse(Long id, String typeId, String className, String name, String description,
            Boolean mandatory, String quantifier, Integer runOrder, JsonNode configuration) {
    }

    public record RuleOrderRequest(@NotEmpty List<@Positive Long> ruleIds) {
    }

    public record RuleConfigurationValidationRequest(@NotNull JsonNode configuration) {
    }

    /** Result of validating a rule configuration without changing persisted state. */
    public record RuleConfigurationValidationResponse(String typeId, String className, boolean valid) {
    }

    public record UsageNetworkResponse(Long id, String acronym, String name, List<String> relations) {
    }

    public record UsageResponse(boolean used, List<UsageNetworkResponse> networks) {
    }

    public record ValidatorResponse(Long id, String name, String description, List<RuleResponse> rules) {
    }

    public record TransformerResponse(Long id, String name, String description, List<RuleResponse> rules) {
    }

    /**
     * Rule metadata for a client-generated form. uiSchema intentionally uses the
     * JSON Schema form vocabulary rather than exposing the legacy Angular form.
     */
    public record RuleTypeResponse(String typeId, String kind, String className, String name, String help,
            JsonNode schema, JsonNode uiSchema) {
    }

    public record SnapshotResponse(Long id, Long networkId, Long previousSnapshotId, String status, String indexStatus,
            @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime startTime,
            @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime lastIncrementalTime,
            @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime endTime, Integer size,
            Integer validSize, Integer transformedSize, boolean deleted) {
    }

    public record LogEntryResponse(String timestamp, String message) {
    }

    public record DiagnosticQuery(List<@Valid DiagnosticFilter> filters, Integer page, Integer size) {
    }

    public enum DiagnosticFilterField { IDENTIFIER, VALID, TRANSFORMED, RULE_VALID, RULE_INVALID }

    public enum DiagnosticFilterOperator { EQ, CONTAINS }

    public record DiagnosticFilter(@NotNull DiagnosticFilterField field, DiagnosticFilterOperator operator,
            Object value) {
    }

    public record DiagnosticSummaryResponse(int size, int validSize, int transformedSize,
            List<DiagnosticRuleResponse> rules, List<DiagnosticFacetResponse> facets) {
    }

    public record DiagnosticRuleResponse(Long ruleId, String name, String description, String quantifier,
            Boolean mandatory, Integer validCount, Integer invalidCount) {
    }

    public record DiagnosticFacetResponse(String field, String value, long count) {
    }

    public record DiagnosticRecordResponse(String id, String identifier, Long snapshotId, String origin,
            String setSpec, String metadataPrefix, String networkAcronym, String repositoryName,
            String institutionName, Boolean valid, Boolean transformed, List<String> validRuleIds,
            List<String> invalidRuleIds, Map<String, List<String>> validOccurrencesByRuleId,
            Map<String, List<String>> invalidOccurrencesByRuleId) {
    }

    public record RuleOccurrenceItemResponse(String value, Integer count) {
    }

    public record RuleOccurrencesResponse(Long ruleId, List<RuleOccurrenceItemResponse> valid,
            List<RuleOccurrenceItemResponse> invalid) {
    }

    public record CommandRequest(@NotNull CommandType type, String actionName, Boolean incremental) {
    }

    public enum CommandType { RUN_ACTION, RUN_ENABLED_ACTIONS, CANCEL_ALL, RESCHEDULE }

    public record CommandReceipt(String requestId, Long networkId, CommandType command, String result,
            @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime acceptedAt, String runtimeUrl, String message) {
    }

    public record BatchCommandRequest(@NotEmpty List<@Positive Long> networkIds, @NotNull @Valid CommandRequest command) {
    }

    public record BatchCommandReceipt(String requestId,
            @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime acceptedAt, List<CommandReceipt> children) {
    }

    public record RuntimeProcessResponse(String processId, String networkAcronym, String actionType, String status,
            @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime startTime, Boolean incremental,
            Map<String, Object> variables, String engineType,
            String cancellationScope) {
    }

    public record RuntimeSummaryResponse(String engineType, int runningCount, int queuedCount,
            List<RuntimeProcessResponse> processes) {
    }

    public record CapabilityResponse(String engineType, List<ActionResponse> actions, List<PropertyResponse> properties,
            List<String> metadataFormats, List<String> metadataStoreSchemas, List<String> commands) {
    }

    public record ActionResponse(String name, String description, boolean incremental, Boolean runOnSchedule,
            Boolean alwaysRunOnSchedule, Integer order, List<String> workers, List<String> properties) {
    }

    public record PropertyResponse(String name, String description) {
    }

    public record CurrentUserResponse(String username, String displayName, List<String> roles, String authMode) {
    }

    public record AttributeProfileResponse(String typeId, String name, String className, String version,
            JsonNode schema, JsonNode uiSchema) {
    }

    public record NetworkSummaryQuery(@Size(max = 200) String q, String acronym, String name,
            String institutionName, Boolean published, String snapshotStatus, String indexStatus) {
    }
}
