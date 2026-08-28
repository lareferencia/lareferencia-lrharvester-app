package org.lareferencia.backend.api.v5;

import java.time.OffsetDateTime;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.databind.JsonNode;

import jakarta.validation.constraints.NotNull;

public final class ApiV5ApplicationActionDtos {
    private ApiV5ApplicationActionDtos() { }

    public record ApplicationActionResponse(Long id, String engineType, String actionKey, String state,
            boolean enabled, boolean available, JsonNode definition, JsonNode configuration, JsonNode schema,
            JsonNode uiSchema, List<String> problems,
            @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime lastSeenAt,
            @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime updatedAt, String updatedBy) { }

    public record ApplicationActionRequest(@NotNull Boolean enabled, @NotNull JsonNode configuration) { }

    public record ApplicationActionUsageResponse(boolean used, int networkCount, int scheduleCount,
            List<ApiV5Dtos.UsageNetworkResponse> networks) { }

    public record ApplicationActionRefreshResponse(String engineType, boolean bootstrap, int created, int updated,
            int unavailable, List<String> conflicts) { }
}
