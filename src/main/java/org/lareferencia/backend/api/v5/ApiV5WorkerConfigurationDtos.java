package org.lareferencia.backend.api.v5;

import java.time.OffsetDateTime;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.databind.JsonNode;

import jakarta.validation.constraints.NotNull;

public final class ApiV5WorkerConfigurationDtos {
    private ApiV5WorkerConfigurationDtos() { }
    public record WorkerConfigurationResponse(Long id, String engineType, String workerKey, boolean available,
            JsonNode definition, JsonNode configuration, JsonNode schema,
            @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime lastSeenAt,
            @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime updatedAt, String updatedBy) { }
    public record WorkerConfigurationRequest(@NotNull JsonNode configuration) { }
}
