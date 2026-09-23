package org.lareferencia.backend.api.v5;

import java.time.OffsetDateTime;
import java.util.List;
import com.fasterxml.jackson.databind.JsonNode;

import com.fasterxml.jackson.annotation.JsonFormat;

public final class ApiV5DarkDtos {
    private ApiV5DarkDtos() { }

    public record StateCount(String state, long count) { }
    public record NaanSummary(String arkNaan, long total) { }
    public record NaanStateCount(String arkNaan, String state, long count) { }
    public record Summary(long total, List<StateCount> states, List<NaanSummary> naans, List<NaanStateCount> naanStates) { }
    public record RuntimeConfiguration(JsonNode configuration) { }

    /** Explicit selection shared by preview, stage and reconciliation commands. */
    public record ManualCommandRequest(List<String> oaiIds) { }

    public record ManualCommandResponse(String commandId, String status, String action, int total, String phase,
            int processed, int succeeded, int skipped, int failed,
            String statusUrl,
            @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime acceptedAt) { }

    public record PreviewItem(String oaiId, String ark, String localState, boolean eligible, String error,
            String targetUrl, Integer l1Bytes, Integer l2Bytes, Integer payloadBytes, List<String> warnings,
            JsonNode minimalMetadata, String originalMetadata) { }

    public record PreviewResponse(List<PreviewItem> items) { }

    public record RecordResponse(String arkNaan, String oaiId, String ark, String targetUrl, String state,
            String sourceMetadataHash, Long sourceNetworkId, String sourceNetworkAcronym, Long sourceSnapshotId, String stagePayloadHash, String lastError,
            @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime createdAt,
            @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime updatedAt,
            @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime lastStagedAt,
            @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime lastReconciledAt,
            @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime publishedAt) { }
}
