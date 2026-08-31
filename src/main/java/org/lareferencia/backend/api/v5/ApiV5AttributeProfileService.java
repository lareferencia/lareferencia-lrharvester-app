package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5Dtos.AttributeProfileResponse;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.nio.file.Files;
import java.nio.file.Path;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;

import jakarta.annotation.PostConstruct;

@Service
public class ApiV5AttributeProfileService {
    private static final Logger logger = LoggerFactory.getLogger(ApiV5AttributeProfileService.class);
    private final ResourceLoader resourceLoader;
    private final ObjectMapper objectMapper;
    private final String location;
    private List<AttributeProfileResponse> profiles = List.of();

    public ApiV5AttributeProfileService(ResourceLoader resourceLoader, ObjectMapper objectMapper,
            @Value("${api-v5.attribute-profiles-location:file:config/attribute-profiles}") String location) {
        this.resourceLoader = resourceLoader;
        this.objectMapper = objectMapper;
        this.location = location;
    }

    @PostConstruct
    void load() {
        Resource resource = resourceLoader.getResource(location);
        try {
            if (resource.isFile() && resource.getFile().isDirectory()) {
                profiles = loadDirectory(resource.getFile().toPath());
            } else {
                try (InputStream stream = resource.getInputStream()) {
                profiles = List.copyOf(objectMapper.readValue(stream, new TypeReference<List<AttributeProfileResponse>>() {}));
                }
            }
        } catch (Exception exception) {
            profiles = builtInProfiles();
            logger.warn("Cannot load API v5 attribute profiles from {}; using built-in compatibility profiles",
                    location);
        }
    }

    private List<AttributeProfileResponse> loadDirectory(Path directory) throws Exception {
        List<AttributeProfileResponse> loaded = new ArrayList<>();
        try (var files = Files.list(directory)) {
            for (Path file : files.filter(path -> path.getFileName().toString().endsWith(".json"))
                    .sorted(Comparator.comparing(path -> path.getFileName().toString())).toList()) {
                var node = objectMapper.readTree(file.toFile());
                if (node.isArray()) {
                    loaded.addAll(objectMapper.convertValue(node, new TypeReference<List<AttributeProfileResponse>>() {}));
                } else if (node.isObject()) {
                    loaded.add(objectMapper.treeToValue(node, AttributeProfileResponse.class));
                }
            }
        }
        if (loaded.isEmpty()) throw new IllegalStateException("No attribute profile JSON files found");
        return List.copyOf(loaded);
    }

    public List<AttributeProfileResponse> list() { return profiles; }

    public AttributeProfileResponse get(String typeId) {
        return profiles.stream().filter(profile -> profile.typeId().equals(typeId) || profile.className().equals(typeId)).findFirst()
                .orElseThrow(() -> new ApiV5Exception(HttpStatus.NOT_FOUND, "ATTRIBUTE_PROFILE_NOT_FOUND",
                        "Attribute profile " + typeId + " was not found"));
    }

    public void validateReference(Map<String, Object> attributes) {
        if (attributes == null || attributes.isEmpty()) return;
        Object className = attributes.get("@class");
        if (!(className instanceof String value) || value.isBlank()) {
            throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "ATTRIBUTE_PROFILE_REQUIRED",
                    "attributes.@class must identify an installed attribute profile");
        }
        if (profiles.stream().noneMatch(profile -> value.equals(profile.className()))) {
            throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "ATTRIBUTE_PROFILE_UNKNOWN",
                    "attributes.@class does not identify an installed attribute profile");
        }
    }

    private List<AttributeProfileResponse> builtInProfiles() {
        return List.of(
                builtIn("lareferencia-repository", "LA Referencia Repository Profile",
                        "org.lareferencia.backend.network.LAReferenciaNetworkAttributes"),
                builtIn("ibict-repository", "IBICT Repository Profile",
                        "org.lareferencia.backend.network.IbictRepositoryNetworkAttributes"),
                builtIn("rcaap-repository", "RCAAP Repository Profile",
                        "org.lareferencia.backend.network.RCAAPNetworkAttributes"));
    }

    private AttributeProfileResponse builtIn(String typeId, String name, String className) {
        ObjectNode schema = objectMapper.createObjectNode();
        schema.put("$schema", "https://json-schema.org/draft/2020-12/schema");
        schema.put("type", "object");
        schema.put("additionalProperties", true);
        ObjectNode properties = schema.putObject("properties");
        properties.putObject("@class").put("type", "string").put("const", className);
        schema.putArray("required").add("@class");
        ObjectNode uiSchema = objectMapper.createObjectNode();
        uiSchema.putObject("@class").put("ui:widget", "hidden");
        return new AttributeProfileResponse(typeId, name, className, "compatibility", schema, uiSchema);
    }
}
