package org.lareferencia.backend.api.v5;

import java.time.OffsetDateTime;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.databind.JsonNode;

import jakarta.validation.constraints.NotNull;

public final class ApiV5NetworkActionDtos {
    private ApiV5NetworkActionDtos() { }
    public record NetworkActionResponse(String actionKey, String globalState, boolean enabled, boolean scheduleEnabled,
            JsonNode configuration, JsonNode effectiveConfiguration, JsonNode schema, JsonNode uiSchema,
            List<String> problems, @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime updatedAt, String updatedBy) { }
    public record NetworkActionRequest(@NotNull Boolean enabled, @NotNull Boolean scheduleEnabled,
            @NotNull JsonNode configuration) { }
}
