package org.lareferencia.backend.api.v5;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.databind.JsonNode;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

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

    public record NetworkRequest(@NotBlank String acronym, @NotBlank String name, @NotBlank String institutionName,
            String institutionAcronym, Boolean published, @NotBlank String originUrl, String metadataPrefix,
            String metadataStoreSchema, List<String> sets, Map<String, Object> attributes,
            Map<String, Boolean> properties, String scheduleCronExpression, Long prevalidatorId, Long validatorId,
            Long transformerId, Long secondaryTransformerId) {
    }

    public record RuleRequest(String typeId, String className, @NotBlank String name, String description,
            Boolean mandatory, String quantifier, Integer runOrder, @NotNull JsonNode configuration) {
    }

    public record ValidatorRequest(@NotBlank String name, String description, List<@Valid RuleRequest> rules) {
    }

    public record TransformerRequest(@NotBlank String name, String description, List<@Valid RuleRequest> rules) {
    }

    public record RuleResponse(Long id, String typeId, String className, String name, String description,
            Boolean mandatory, String quantifier, Integer runOrder, JsonNode configuration) {
    }

    public record RuleOrderRequest(@NotEmpty List<@Positive Long> ruleIds) {
    }

    public record ValidatorResponse(Long id, String name, String description, List<RuleResponse> rules) {
    }

    public record TransformerResponse(Long id, String name, String description, List<RuleResponse> rules) {
    }

    public record RuleTypeResponse(String typeId, String kind, String className, String name, JsonNode schema) {
    }

    public record SnapshotResponse(Long id, Long networkId, Long previousSnapshotId, String status, String indexStatus,
            LocalDateTime startTime, LocalDateTime lastIncrementalTime, LocalDateTime endTime, Integer size,
            Integer validSize, Integer transformedSize, boolean deleted) {
    }

    public record LogEntryResponse(String timestamp, String message) {
    }

    public record DiagnosticQuery(List<String> filters, Integer page, Integer size) {
    }

    /** JSON is deliberately a v5 boundary object, never a JPA/HAL representation. */
    public record DiagnosticResponse(JsonNode data) {
    }

    public record CommandRequest(@NotNull CommandType type, String actionName, Boolean incremental) {
    }

    public enum CommandType { RUN_ACTION, RUN_ENABLED_ACTIONS, CANCEL_ALL, RESCHEDULE }

    public record CommandReceipt(String requestId, Long networkId, CommandType command, String result,
            LocalDateTime acceptedAt, String runtimeUrl, String message) {
    }

    public record BatchCommandRequest(@NotEmpty List<@Positive Long> networkIds, @NotNull @Valid CommandRequest command) {
    }

    public record BatchCommandReceipt(String requestId, LocalDateTime acceptedAt, List<CommandReceipt> children) {
    }

    public record RuntimeProcessResponse(String processId, String networkAcronym, String actionType, String status,
            LocalDateTime startTime, Boolean incremental, Map<String, Object> variables, String engineType,
            String cancellationScope) {
    }

    public record RuntimeSummaryResponse(String engineType, int runningCount, int queuedCount,
            List<RuntimeProcessResponse> processes) {
    }

    public record CapabilityResponse(String engineType, List<ActionResponse> actions, List<PropertyResponse> properties,
            List<String> metadataFormats, List<String> commands) {
    }

    public record ActionResponse(String name, String description, boolean incremental, Boolean runOnSchedule,
            Boolean alwaysRunOnSchedule, Integer displayOrder, List<String> workers, List<String> properties) {
    }

    public record PropertyResponse(String name, String description) {
    }
}
