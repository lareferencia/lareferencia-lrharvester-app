package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5Dtos.*;

import java.util.List;
import java.util.Locale;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;

import jakarta.validation.Valid;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.ConstraintViolationException;
import jakarta.validation.Validator;
import org.lareferencia.backend.app.FileBasedUserDetailsService;

@RestController
@RequestMapping(path = "/api/v5", produces = MediaType.APPLICATION_JSON_VALUE)
public class ApiV5ManagementController {
    private final ApiV5ManagementService service;
    private final ObjectMapper objectMapper;
    private final ApiV5NetworkSummaryService summaries;
    private final ApiV5AttributeProfileService attributeProfiles;
    private final Validator requestValidator;
    private final FileBasedUserDetailsService users;

    @Value("${security.api-v5.auth-mode:file}")
    private String authMode;

    public ApiV5ManagementController(ApiV5ManagementService service, ObjectMapper objectMapper) {
        this(service, objectMapper, null, null, null, null);
    }

    public ApiV5ManagementController(ApiV5ManagementService service, ObjectMapper objectMapper,
            ApiV5NetworkSummaryService summaries, ApiV5AttributeProfileService attributeProfiles) {
        this(service, objectMapper, summaries, attributeProfiles, null, null);
    }

    @Autowired
    public ApiV5ManagementController(ApiV5ManagementService service, ObjectMapper objectMapper,
            ApiV5NetworkSummaryService summaries, ApiV5AttributeProfileService attributeProfiles,
            Validator requestValidator, FileBasedUserDetailsService users) {
        this.service = service;
        this.objectMapper = objectMapper;
        this.summaries = summaries;
        this.attributeProfiles = attributeProfiles;
        this.requestValidator = requestValidator;
        this.users = users;
    }

    @GetMapping("/capabilities")
    @PreAuthorize("hasAnyRole('VIEWER','ADMIN')")
    public CapabilityResponse capabilities() { return service.capabilities(); }

    @GetMapping("/networks")
    @PreAuthorize("hasAnyRole('VIEWER','ADMIN')")
    public PageResponse<NetworkResponse> networks(@RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "25") int size) {
        return service.listNetworks(validPage(page), validSize(size));
    }

    @GetMapping("/network-summaries")
    @PreAuthorize("hasAnyRole('VIEWER','ADMIN')")
    public PageResponse<NetworkSummaryResponse> networkSummaries(@RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "25") int size, @RequestParam(defaultValue = "id,asc") String sort,
            @RequestParam(required = false) String q, @RequestParam(required = false) String acronym,
            @RequestParam(required = false) String name, @RequestParam(required = false) String institutionName,
            @RequestParam(required = false) Boolean published, @RequestParam(required = false) String snapshotStatus,
            @RequestParam(required = false) String indexStatus) {
        return summaries.list(validPage(page), validSize(size), sort, q, acronym, name, institutionName, published,
                snapshotStatus, indexStatus);
    }

    @GetMapping("/me")
    @PreAuthorize("hasAnyRole('VIEWER','ADMIN')")
    public CurrentUserResponse me(Authentication authentication) {
        List<String> roles = authentication.getAuthorities().stream().map(authority -> authority.getAuthority())
                .filter(authority -> authority.startsWith("ROLE_")).map(authority -> authority.substring(5))
                .distinct().sorted().toList();
        return new CurrentUserResponse(authentication.getName(), authentication.getName(), roles, authMode);
    }

    @GetMapping("/users") @PreAuthorize("hasRole('ADMIN')")
    public List<UserResponse> users() { return users.listUsers().stream().map(u -> new UserResponse(u.username(), u.roles())).toList(); }

    @PostMapping(path = "/users", consumes = MediaType.APPLICATION_JSON_VALUE) @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserResponse> createUser(@Valid @RequestBody CreateUserRequest request) {
        users.createOrUpdateUser(request.username(), new org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder().encode(request.password()), request.roles(), true);
        return ResponseEntity.status(HttpStatus.CREATED).body(users.listUsers().stream().filter(u -> u.username().equals(request.username())).findFirst().map(u -> new UserResponse(u.username(), u.roles())).orElseThrow());
    }

    @PutMapping(path = "/users/{username}/roles", consumes = MediaType.APPLICATION_JSON_VALUE) @PreAuthorize("hasRole('ADMIN')")
    public UserResponse updateUserRoles(@PathVariable String username, @Valid @RequestBody UserRolesRequest request) { users.createOrUpdateUser(username, null, request.roles(), false); return users.listUsers().stream().filter(u -> u.username().equals(username)).findFirst().map(u -> new UserResponse(u.username(), u.roles())).orElseThrow(); }

    @PostMapping(path = "/users/{username}/password", consumes = MediaType.APPLICATION_JSON_VALUE) @PreAuthorize("hasRole('ADMIN')")
    public void updateUserPassword(@PathVariable String username, @Valid @RequestBody PasswordRequest request) { var current = users.listUsers().stream().filter(u -> u.username().equals(username)).findFirst().orElseThrow(); users.createOrUpdateUser(username, new org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder().encode(request.password()), current.roles(), true); }

    @DeleteMapping("/users/{username}") @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteUser(@PathVariable String username) { users.deleteUser(username); return ResponseEntity.noContent().build(); }

    @GetMapping("/attribute-profiles")
    @PreAuthorize("hasAnyRole('VIEWER','ADMIN')")
    public List<AttributeProfileResponse> attributeProfiles() { return attributeProfiles.list(); }

    @GetMapping("/attribute-profiles/{typeId}")
    @PreAuthorize("hasAnyRole('VIEWER','ADMIN')")
    public AttributeProfileResponse attributeProfile(@PathVariable String typeId) { return attributeProfiles.get(typeId); }

    @PostMapping(path = "/networks", consumes = MediaType.APPLICATION_JSON_VALUE)
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<NetworkResponse> createNetwork(@Valid @RequestBody NetworkRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.createNetwork(request));
    }

    @GetMapping("/networks/{id}")
    @PreAuthorize("hasAnyRole('VIEWER','ADMIN')")
    public NetworkResponse network(@PathVariable Long id) { return service.network(id); }

    @PutMapping(path = "/networks/{id}", consumes = MediaType.APPLICATION_JSON_VALUE)
    @PreAuthorize("hasRole('ADMIN')")
    public NetworkResponse replaceNetwork(@PathVariable Long id, @Valid @RequestBody NetworkRequest request) { return service.replaceNetwork(id, request); }

    @PatchMapping(path = "/networks/{id}", consumes = { "application/merge-patch+json", MediaType.APPLICATION_JSON_VALUE })
    @PreAuthorize("hasRole('ADMIN')")
    public NetworkResponse patchNetwork(@PathVariable Long id, @RequestBody JsonNode patch) {
        ObjectNode current = objectMapper.valueToTree(service.network(id));
        merge(current, patch);
        return service.replaceNetwork(id, patchedRequest(current, NetworkRequest.class));
    }

    @DeleteMapping("/networks/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<CommandReceipt> deleteNetwork(@PathVariable Long id,
            @RequestHeader(value = "X-Confirm-Network-Deletion", required = false) String confirmation) {
        return ResponseEntity.accepted().body(service.deleteNetwork(id, confirmation));
    }

    @GetMapping("/networks/{id}/snapshots")
    @PreAuthorize("hasAnyRole('VIEWER','ADMIN')")
    public PageResponse<SnapshotResponse> snapshots(@PathVariable Long id, @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "25") int size) { return service.networkSnapshots(id, validPage(page), validSize(size)); }

    @GetMapping("/networks/{id}/snapshots/latest")
    @PreAuthorize("hasAnyRole('VIEWER','ADMIN')")
    public SnapshotResponse latest(@PathVariable Long id, @RequestParam(defaultValue = "valid") String status) { return service.latestSnapshot(id, status); }

    @GetMapping("/networks/{id}/runtime")
    @PreAuthorize("hasAnyRole('VIEWER','ADMIN')")
    public List<RuntimeProcessResponse> networkRuntime(@PathVariable Long id) { return service.networkRuntime(id); }

    @PostMapping("/networks/{id}/metadata-cleanup/preview")
    @PreAuthorize("hasRole('ADMIN')")
    public MetadataCleanupPreviewResponse previewMetadataCleanup(@PathVariable Long id) {
        return service.previewMetadataCleanup(id);
    }

    @PostMapping(path = "/networks/{id}/commands", consumes = MediaType.APPLICATION_JSON_VALUE)
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<CommandReceipt> command(@PathVariable Long id, @Valid @RequestBody CommandRequest request) {
        return ResponseEntity.accepted().body(service.command(id, request));
    }

    @PostMapping(path = "/network-command-batches", consumes = MediaType.APPLICATION_JSON_VALUE)
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<BatchCommandReceipt> batch(@Valid @RequestBody BatchCommandRequest request) {
        return ResponseEntity.accepted().body(service.batch(request));
    }

    @GetMapping("/validators")
    @PreAuthorize("hasAnyRole('VIEWER','ADMIN')")
    public PageResponse<ValidatorResponse> validators(@RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "25") int size) { return service.listValidators(validPage(page), validSize(size)); }

    @PostMapping(path = "/validators", consumes = MediaType.APPLICATION_JSON_VALUE)
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ValidatorResponse> createValidator(@Valid @RequestBody ValidatorRequest request) { return ResponseEntity.status(HttpStatus.CREATED).body(service.createValidator(request)); }

    @GetMapping("/validators/{id}") @PreAuthorize("hasAnyRole('VIEWER','ADMIN')") public ValidatorResponse validator(@PathVariable Long id) { return service.validator(id); }
    @GetMapping("/validators/{id}/export") @PreAuthorize("hasAnyRole('VIEWER','ADMIN')") public ConfigurationExport exportValidator(@PathVariable Long id) { return service.exportValidator(id); }
    @PostMapping(path = "/validators/import", consumes = MediaType.APPLICATION_JSON_VALUE) @PreAuthorize("hasRole('ADMIN')") public ResponseEntity<ValidatorResponse> importValidator(@RequestBody JsonNode request) { return ResponseEntity.status(HttpStatus.CREATED).body(service.importValidator(request)); }
    @PutMapping(path = "/validators/{id}", consumes = MediaType.APPLICATION_JSON_VALUE) @PreAuthorize("hasRole('ADMIN')") public ValidatorResponse replaceValidator(@PathVariable Long id, @Valid @RequestBody ValidatorRequest request) { return service.replaceValidator(id, request); }
    @PutMapping(path = "/validators/{id}/metadata", consumes = MediaType.APPLICATION_JSON_VALUE) @PreAuthorize("hasRole('ADMIN')") public ValidatorResponse updateValidatorMetadata(@PathVariable Long id, @Valid @RequestBody ConfigurationMetadataRequest request) { return service.updateValidatorMetadata(id, request); }
    @PatchMapping(path = "/validators/{id}", consumes = { "application/merge-patch+json", MediaType.APPLICATION_JSON_VALUE }) @PreAuthorize("hasRole('ADMIN')") public ValidatorResponse patchValidator(@PathVariable Long id, @RequestBody JsonNode patch) { ObjectNode current = objectMapper.valueToTree(service.validator(id)); merge(current, patch); return service.replaceValidator(id, patchedRequest(current, ValidatorRequest.class)); }
    @PostMapping("/validators/{id}/clone") @PreAuthorize("hasRole('ADMIN')") public ResponseEntity<ValidatorResponse> cloneValidator(@PathVariable Long id) { return ResponseEntity.status(HttpStatus.CREATED).body(service.cloneValidator(id)); }
    @DeleteMapping("/validators/{id}") @PreAuthorize("hasRole('ADMIN')") public ResponseEntity<Void> deleteValidator(@PathVariable Long id) { service.deleteValidator(id); return ResponseEntity.noContent().build(); }
    @GetMapping("/validators/{id}/usage") @PreAuthorize("hasAnyRole('VIEWER','ADMIN')") public UsageResponse validatorUsage(@PathVariable Long id) { return service.validatorUsage(id); }
    @GetMapping("/validators/{id}/rules") @PreAuthorize("hasAnyRole('VIEWER','ADMIN')") public List<RuleResponse> validatorRules(@PathVariable Long id) { return service.validatorRules(id); }
    @GetMapping("/validators/{id}/rules/{ruleId}") @PreAuthorize("hasAnyRole('VIEWER','ADMIN')") public RuleResponse validatorRule(@PathVariable Long id, @PathVariable Long ruleId) { return service.validatorRule(id, ruleId); }
    @PostMapping(path = "/validators/{id}/rules", consumes = MediaType.APPLICATION_JSON_VALUE) @PreAuthorize("hasRole('ADMIN')") public ResponseEntity<RuleResponse> addValidatorRule(@PathVariable Long id, @Valid @RequestBody RuleRequest request) { return ResponseEntity.status(HttpStatus.CREATED).body(service.addValidatorRule(id, request)); }
    @PutMapping(path = "/validators/{id}/rules/{ruleId}", consumes = MediaType.APPLICATION_JSON_VALUE) @PreAuthorize("hasRole('ADMIN')") public RuleResponse updateValidatorRule(@PathVariable Long id, @PathVariable Long ruleId, @Valid @RequestBody RuleRequest request) { return service.updateValidatorRule(id, ruleId, request); }
    @DeleteMapping("/validators/{id}/rules/{ruleId}") @PreAuthorize("hasRole('ADMIN')") public ResponseEntity<Void> deleteValidatorRule(@PathVariable Long id, @PathVariable Long ruleId) { service.deleteValidatorRule(id, ruleId); return ResponseEntity.noContent().build(); }
    @PutMapping(path = "/validators/{id}/rules/order", consumes = MediaType.APPLICATION_JSON_VALUE) @PreAuthorize("hasRole('ADMIN')") public List<RuleResponse> reorderValidatorRules(@PathVariable Long id, @Valid @RequestBody RuleOrderRequest request) { return service.reorderValidatorRules(id, request); }

    @GetMapping("/transformers") @PreAuthorize("hasAnyRole('VIEWER','ADMIN')") public PageResponse<TransformerResponse> transformers(@RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "25") int size) { return service.listTransformers(validPage(page), validSize(size)); }
    @PostMapping(path = "/transformers", consumes = MediaType.APPLICATION_JSON_VALUE) @PreAuthorize("hasRole('ADMIN')") public ResponseEntity<TransformerResponse> createTransformer(@Valid @RequestBody TransformerRequest request) { return ResponseEntity.status(HttpStatus.CREATED).body(service.createTransformer(request)); }
    @GetMapping("/transformers/{id}") @PreAuthorize("hasAnyRole('VIEWER','ADMIN')") public TransformerResponse transformer(@PathVariable Long id) { return service.transformer(id); }
    @GetMapping("/transformers/{id}/export") @PreAuthorize("hasAnyRole('VIEWER','ADMIN')") public ConfigurationExport exportTransformer(@PathVariable Long id) { return service.exportTransformer(id); }
    @PostMapping(path = "/transformers/import", consumes = MediaType.APPLICATION_JSON_VALUE) @PreAuthorize("hasRole('ADMIN')") public ResponseEntity<TransformerResponse> importTransformer(@RequestBody JsonNode request) { return ResponseEntity.status(HttpStatus.CREATED).body(service.importTransformer(request)); }
    @PutMapping(path = "/transformers/{id}", consumes = MediaType.APPLICATION_JSON_VALUE) @PreAuthorize("hasRole('ADMIN')") public TransformerResponse replaceTransformer(@PathVariable Long id, @Valid @RequestBody TransformerRequest request) { return service.replaceTransformer(id, request); }
    @PutMapping(path = "/transformers/{id}/metadata", consumes = MediaType.APPLICATION_JSON_VALUE) @PreAuthorize("hasRole('ADMIN')") public TransformerResponse updateTransformerMetadata(@PathVariable Long id, @Valid @RequestBody ConfigurationMetadataRequest request) { return service.updateTransformerMetadata(id, request); }
    @PatchMapping(path = "/transformers/{id}", consumes = { "application/merge-patch+json", MediaType.APPLICATION_JSON_VALUE }) @PreAuthorize("hasRole('ADMIN')") public TransformerResponse patchTransformer(@PathVariable Long id, @RequestBody JsonNode patch) { ObjectNode current = objectMapper.valueToTree(service.transformer(id)); merge(current, patch); return service.replaceTransformer(id, patchedRequest(current, TransformerRequest.class)); }
    @PostMapping("/transformers/{id}/clone") @PreAuthorize("hasRole('ADMIN')") public ResponseEntity<TransformerResponse> cloneTransformer(@PathVariable Long id) { return ResponseEntity.status(HttpStatus.CREATED).body(service.cloneTransformer(id)); }
    @DeleteMapping("/transformers/{id}") @PreAuthorize("hasRole('ADMIN')") public ResponseEntity<Void> deleteTransformer(@PathVariable Long id) { service.deleteTransformer(id); return ResponseEntity.noContent().build(); }
    @GetMapping("/transformers/{id}/usage") @PreAuthorize("hasAnyRole('VIEWER','ADMIN')") public UsageResponse transformerUsage(@PathVariable Long id) { return service.transformerUsage(id); }
    @GetMapping("/transformers/{id}/rules") @PreAuthorize("hasAnyRole('VIEWER','ADMIN')") public List<RuleResponse> transformerRules(@PathVariable Long id) { return service.transformerRules(id); }
    @GetMapping("/transformers/{id}/rules/{ruleId}") @PreAuthorize("hasAnyRole('VIEWER','ADMIN')") public RuleResponse transformerRule(@PathVariable Long id, @PathVariable Long ruleId) { return service.transformerRule(id, ruleId); }
    @PostMapping(path = "/transformers/{id}/rules", consumes = MediaType.APPLICATION_JSON_VALUE) @PreAuthorize("hasRole('ADMIN')") public ResponseEntity<RuleResponse> addTransformerRule(@PathVariable Long id, @Valid @RequestBody RuleRequest request) { return ResponseEntity.status(HttpStatus.CREATED).body(service.addTransformerRule(id, request)); }
    @PutMapping(path = "/transformers/{id}/rules/{ruleId}", consumes = MediaType.APPLICATION_JSON_VALUE) @PreAuthorize("hasRole('ADMIN')") public RuleResponse updateTransformerRule(@PathVariable Long id, @PathVariable Long ruleId, @Valid @RequestBody RuleRequest request) { return service.updateTransformerRule(id, ruleId, request); }
    @DeleteMapping("/transformers/{id}/rules/{ruleId}") @PreAuthorize("hasRole('ADMIN')") public ResponseEntity<Void> deleteTransformerRule(@PathVariable Long id, @PathVariable Long ruleId) { service.deleteTransformerRule(id, ruleId); return ResponseEntity.noContent().build(); }
    @PutMapping(path = "/transformers/{id}/rules/order", consumes = MediaType.APPLICATION_JSON_VALUE) @PreAuthorize("hasRole('ADMIN')") public List<RuleResponse> reorderTransformerRules(@PathVariable Long id, @Valid @RequestBody RuleOrderRequest request) { return service.reorderTransformerRules(id, request); }

    @GetMapping("/rule-types") @PreAuthorize("hasAnyRole('VIEWER','ADMIN')") public List<RuleTypeResponse> ruleTypes(@RequestParam(required = false) String kind, @RequestParam(required = false) String locale) { return service.ruleTypes(kind, locale == null ? Locale.ROOT : Locale.forLanguageTag(locale)); }
    @GetMapping("/rule-types/{typeId}") @PreAuthorize("hasAnyRole('VIEWER','ADMIN')") public RuleTypeResponse ruleType(@PathVariable String typeId, @RequestParam(required = false) String locale) { return service.ruleType(typeId, locale == null ? Locale.ROOT : Locale.forLanguageTag(locale)); }
    @PostMapping(path = "/rule-types/{typeId}/validate", consumes = MediaType.APPLICATION_JSON_VALUE) @PreAuthorize("hasRole('ADMIN')") public RuleConfigurationValidationResponse validateRuleConfiguration(@PathVariable String typeId, @Valid @RequestBody RuleConfigurationValidationRequest request) { return service.validateRuleConfiguration(typeId, request); }
    @GetMapping("/snapshots/{id}") @PreAuthorize("hasAnyRole('VIEWER','ADMIN')") public SnapshotResponse snapshot(@PathVariable Long id) { return service.snapshot(id); }
    @GetMapping("/runtime/summary") @PreAuthorize("hasAnyRole('VIEWER','ADMIN')") public RuntimeSummaryResponse runtime() { return service.runtime(); }

    private int validPage(int page) { if (page < 0) throw new ApiV5Exception(HttpStatus.BAD_REQUEST, "PAGE_INVALID", "page must be zero or greater"); return page; }
    private int validSize(int size) { if (size < 1 || size > 200) throw new ApiV5Exception(HttpStatus.BAD_REQUEST, "SIZE_INVALID", "size must be between 1 and 200"); return size; }
    private void merge(ObjectNode target, JsonNode patch) { if (!patch.isObject()) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "PATCH_INVALID", "Merge patch must be an object"); patch.fields().forEachRemaining(field -> { if (field.getValue().isNull()) target.putNull(field.getKey()); else target.set(field.getKey(), field.getValue()); }); }
    private <T> T patchedRequest(ObjectNode source, Class<T> type) {
        T request = objectMapper.convertValue(source, type);
        if (requestValidator != null) {
            java.util.Set<ConstraintViolation<T>> violations = requestValidator.validate(request);
            if (!violations.isEmpty()) throw new ConstraintViolationException(violations);
        }
        return request;
    }
}
