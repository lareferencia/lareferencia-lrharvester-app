package org.lareferencia.backend.api.v5;

import java.time.OffsetDateTime;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonFormat;

public final class ApiV5DarkDtos {
    private ApiV5DarkDtos() { }

    public record StateCount(String state, long count) { }
    public record NaanSummary(String arkNaan, long total) { }
    public record NaanStateCount(String arkNaan, String state, long count) { }
    public record Summary(long total, List<StateCount> states, List<NaanSummary> naans, List<NaanStateCount> naanStates) { }

    public record RecordResponse(String arkNaan, String oaiId, String ark, String targetUrl, String state,
            String sourceMetadataHash, String stagePayloadHash, String lastError,
            @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime createdAt,
            @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime updatedAt,
            @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime lastStagedAt,
            @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime lastReconciledAt,
            @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime publishedAt) { }
}
