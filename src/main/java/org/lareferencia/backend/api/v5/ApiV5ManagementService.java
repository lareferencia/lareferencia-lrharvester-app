package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5Dtos.*;

import java.net.URI;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.HashSet;
import java.util.UUID;

import org.lareferencia.core.domain.Network;
import org.lareferencia.core.domain.NetworkSnapshot;
import org.lareferencia.core.domain.Transformer;
import org.lareferencia.core.domain.TransformerRule;
import org.lareferencia.core.domain.Validator;
import org.lareferencia.core.domain.ValidatorRule;
import org.lareferencia.core.repository.jpa.NetworkRepository;
import org.lareferencia.core.repository.jpa.NetworkSnapshotRepository;
import org.lareferencia.core.repository.jpa.TransformerRepository;
import org.lareferencia.core.repository.jpa.TransformerRuleRepository;
import org.lareferencia.core.repository.jpa.ValidatorRepository;
import org.lareferencia.core.repository.jpa.ValidatorRuleRepository;
import org.lareferencia.core.task.NetworkAction;
import org.lareferencia.core.task.ApplicationActionPolicyException;
import org.lareferencia.core.task.ApplicationActionCatalogService;
import org.lareferencia.core.task.NetworkActionkManager;
import org.lareferencia.core.task.NetworkProperty;
import org.lareferencia.core.task.RunningProcessInfo;
import org.lareferencia.core.worker.NetworkRunningContext;
import org.lareferencia.core.worker.validation.ITransformerRule;
import org.lareferencia.core.worker.validation.IValidatorRule;
import org.lareferencia.core.worker.validation.RuleSchemaDefinition;
import org.lareferencia.core.worker.validation.RuleSerializer;
import org.lareferencia.core.worker.validation.ValidatorRuleSchemaService;
import org.lareferencia.core.worker.validation.QuantifierValues;
import org.lareferencia.core.metadata.MDFormatTransformerService;
import org.lareferencia.core.metadata.ISnapshotStore;
import org.lareferencia.core.metadata.MetadataOrphanAnalysisService;
import org.lareferencia.core.metadata.SnapshotMetadata;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.scheduling.support.CronExpression;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;

@Service
public class ApiV5ManagementService {
    private final NetworkRepository networks;
    private final NetworkSnapshotRepository snapshots;
    private final ValidatorRepository validators;
    private final TransformerRepository transformers;
    private final ValidatorRuleRepository validatorRules;
    private final TransformerRuleRepository transformerRules;
    private final NetworkActionkManager actions;
    private final ApplicationActionCatalogService actionCatalog;
    private final ValidatorRuleSchemaService ruleSchemas;
    private final RuleSerializer ruleSerializer;
    private final ObjectMapper objectMapper;
    private final MDFormatTransformerService metadataFormats;
    private final ApiV5AttributeProfileService attributeProfiles;
    private final ISnapshotStore snapshotStore;
    private final MetadataOrphanAnalysisService metadataOrphans;

    public ApiV5ManagementService(NetworkRepository networks, NetworkSnapshotRepository snapshots,
            ValidatorRepository validators, TransformerRepository transformers, ValidatorRuleRepository validatorRules,
            TransformerRuleRepository transformerRules, NetworkActionkManager actions, ApplicationActionCatalogService actionCatalog,
            ValidatorRuleSchemaService ruleSchemas, RuleSerializer ruleSerializer, ObjectMapper objectMapper,
            MDFormatTransformerService metadataFormats, ApiV5AttributeProfileService attributeProfiles,
            ISnapshotStore snapshotStore, MetadataOrphanAnalysisService metadataOrphans) {
        this.networks = networks;
        this.snapshots = snapshots;
        this.validators = validators;
        this.transformers = transformers;
        this.validatorRules = validatorRules;
        this.transformerRules = transformerRules;
        this.actions = actions;
        this.actionCatalog = actionCatalog;
        this.ruleSchemas = ruleSchemas;
        this.ruleSerializer = ruleSerializer;
        this.objectMapper = objectMapper;
        this.metadataFormats = metadataFormats;
        this.attributeProfiles = attributeProfiles;
        this.snapshotStore = snapshotStore;
        this.metadataOrphans = metadataOrphans;
    }

    public PageResponse<NetworkResponse> listNetworks(int page, int size) {
        Page<Network> result = networks.findAll(PageRequest.of(page, size));
        return new PageResponse<>(result.map(this::networkResponse).toList(), result.getNumber(), result.getSize(),
                result.getTotalElements(), result.getTotalPages());
    }

    public NetworkResponse network(Long id) { return networkResponse(requireNetwork(id)); }

    /**
     * Read-only analysis. It retains both LGK and last harvested snapshots so an
     * operator can inspect cleanup impact without endangering a recent attempt.
     */
    public MetadataCleanupPreviewResponse previewMetadataCleanup(Long networkId) {
        Network network = requireNetwork(networkId);
        Long lgk = snapshotStore.findLastGoodKnownSnapshot(network);
        Long lastHarvested = snapshotStore.findLastHarvestingSnapshot(network);
        if (lgk == null) throw new ApiV5Exception(HttpStatus.CONFLICT, "METADATA_CLEANUP_NO_LGK",
                "The source has no last good known snapshot");
        List<Long> ids = new ArrayList<>(); ids.add(lgk);
        if (lastHarvested != null && !lastHarvested.equals(lgk)) ids.add(lastHarvested);
        try {
            List<SnapshotMetadata> protectedSnapshots = ids.stream().map(snapshotStore::getSnapshotMetadata).toList();
            MetadataOrphanAnalysisService.MetadataOrphanAnalysis analysis = metadataOrphans.analyze(protectedSnapshots);
            return new MetadataCleanupPreviewResponse(networkId, analysis.protectedSnapshotIds(),
                    analysis.oaiReferences(), analysis.validationReferences(), analysis.metadataEntriesScanned(),
                    analysis.orphanCandidates(), analysis.falsePositiveProbability());
        } catch (Exception error) {
            throw new ApiV5Exception(HttpStatus.INTERNAL_SERVER_ERROR, "METADATA_CLEANUP_ANALYSIS_FAILED",
                    "Could not analyze metadata cleanup: " + error.getMessage());
        }
    }

    @Transactional
    public NetworkResponse createNetwork(NetworkRequest request) {
        if (networks.findByAcronym(request.acronym()) != null) {
            throw conflict("NETWORK_ACRONYM_EXISTS", "A network already uses acronym " + request.acronym());
        }
        Network network = new Network();
        apply(network, request);
        return networkResponse(networks.save(network));
    }

    @Transactional
    public NetworkResponse replaceNetwork(Long id, NetworkRequest request) {
        Network network = requireNetwork(id);
        ensureNotActive(network);
        Network sameAcronym = networks.findByAcronym(request.acronym());
        if (sameAcronym != null && !sameAcronym.getId().equals(id)) {
            throw conflict("NETWORK_ACRONYM_EXISTS", "A network already uses acronym " + request.acronym());
        }
        boolean reschedule = !java.util.Objects.equals(network.getScheduleCronExpression(), request.scheduleCronExpression());
        apply(network, request);
        Network saved = networks.save(network);
        if (reschedule) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    actions.rescheduleNetwork(saved);
                }
            });
        }
        return networkResponse(saved);
    }

    @Transactional
    public CommandReceipt deleteNetwork(Long id, String confirmation) {
        Network network = requireNetwork(id);
        if (!network.getAcronym().equals(confirmation)) {
            throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "DELETE_CONFIRMATION_REQUIRED",
                    "X-Confirm-Network-Deletion must equal the network acronym");
        }
        ensureNotActive(network);
        if (actions.getActions().stream().noneMatch(action -> "NETWORK_DELETE_ACTION".equals(action.getName()))) {
            throw new ApiV5Exception(HttpStatus.CONFLICT, "DELETE_ACTION_UNAVAILABLE",
                    "NETWORK_DELETE_ACTION is not configured in this installation");
        }
        actions.executeAction("NETWORK_DELETE_ACTION", false, network);
        return receipt(id, CommandType.RUN_ACTION, "ACCEPTED", "Network deletion was submitted");
    }

    public PageResponse<ValidatorResponse> listValidators(int page, int size) {
        Page<Validator> result = validators.findAll(PageRequest.of(page, size));
        return new PageResponse<>(result.map(this::validatorResponse).toList(), result.getNumber(), result.getSize(),
                result.getTotalElements(), result.getTotalPages());
    }

    public ValidatorResponse validator(Long id) { return validatorResponse(requireValidator(id)); }

    public ConfigurationExport exportValidator(Long id) {
        ValidatorResponse value = validator(id);
        ObjectNode configuration = objectMapper.createObjectNode();
        configuration.setAll((ObjectNode) objectMapper.valueToTree(value));
        configuration.remove("id");
        removeRuleIds(configuration);
        return new ConfigurationExport("lareferencia-harvester-configuration", 1, "validator",
                OffsetDateTime.now(ZoneOffset.UTC).toString(), configuration);
    }

    @Transactional
    public ValidatorResponse importValidator(ConfigurationExport request) {
        if (!"validator".equals(request.kind()) || request.configuration() == null)
            throw new ApiV5Exception(HttpStatus.BAD_REQUEST, "CONFIGURATION_EXPORT_INVALID", "The export does not contain a validator configuration");
        return createValidator(objectMapper.convertValue(request.configuration(), ValidatorRequest.class));
    }

    @Transactional
    public ValidatorResponse createValidator(ValidatorRequest request) {
        Validator validator = new Validator();
        validator.setName(request.name());
        validator.setDescription(request.description());
        replaceValidatorRules(validator, request.rules(), true);
        return validatorResponse(validators.save(validator));
    }

    @Transactional
    public ValidatorResponse replaceValidator(Long id, ValidatorRequest request) {
        Validator validator = requireValidator(id);
        validator.setName(request.name());
        validator.setDescription(request.description());
        replaceValidatorRules(validator, request.rules(), false);
        return validatorResponse(validators.save(validator));
    }

    /** Metadata is deliberately isolated from rule replacement for the v5 editor. */
    @Transactional
    public ValidatorResponse updateValidatorMetadata(Long id, ConfigurationMetadataRequest request) {
        Validator validator = requireValidator(id);
        validator.setName(request.name());
        validator.setDescription(request.description());
        return validatorResponse(validators.save(validator));
    }

    @Transactional
    public ValidatorResponse cloneValidator(Long id) {
        Validator source = requireValidator(id);
        Validator copy = new Validator();
        copy.setName(source.getName() + " - copy");
        copy.setDescription(source.getDescription());
        for (ValidatorRule rule : source.getRules()) {
            ValidatorRule duplicate = new ValidatorRule();
            duplicate.setName(rule.getName()); duplicate.setDescription(rule.getDescription());
            duplicate.setMandatory(rule.getMandatory()); duplicate.setQuantifier(rule.getQuantifier());
            duplicate.setJsonserialization(rule.getJsonserialization()); copy.getRules().add(duplicate);
        }
        return validatorResponse(validators.save(copy));
    }

    @Transactional
    public void deleteValidator(Long id) {
        Validator validator = requireValidator(id);
        if (validatorUsage(id).used()) {
            throw conflict("VALIDATOR_IN_USE", "Validator is associated with a network");
        }
        validators.delete(validator);
    }

    public PageResponse<TransformerResponse> listTransformers(int page, int size) {
        Page<Transformer> result = transformers.findAll(PageRequest.of(page, size));
        return new PageResponse<>(result.map(this::transformerResponse).toList(), result.getNumber(), result.getSize(),
                result.getTotalElements(), result.getTotalPages());
    }

    public TransformerResponse transformer(Long id) { return transformerResponse(requireTransformer(id)); }

    public ConfigurationExport exportTransformer(Long id) {
        TransformerResponse value = transformer(id);
        ObjectNode configuration = objectMapper.createObjectNode();
        configuration.setAll((ObjectNode) objectMapper.valueToTree(value));
        configuration.remove("id");
        removeRuleIds(configuration);
        return new ConfigurationExport("lareferencia-harvester-configuration", 1, "transformer",
                OffsetDateTime.now(ZoneOffset.UTC).toString(), configuration);
    }

    @Transactional
    public TransformerResponse importTransformer(ConfigurationExport request) {
        if (!"transformer".equals(request.kind()) || request.configuration() == null)
            throw new ApiV5Exception(HttpStatus.BAD_REQUEST, "CONFIGURATION_EXPORT_INVALID", "The export does not contain a transformer configuration");
        return createTransformer(objectMapper.convertValue(request.configuration(), TransformerRequest.class));
    }

    private void removeRuleIds(ObjectNode configuration) {
        JsonNode rules = configuration.get("rules");
        if (rules != null && rules.isArray()) {
            rules.forEach(rule -> { if (rule.isObject()) ((ObjectNode) rule).remove("id"); });
        }
    }

    @Transactional
    public TransformerResponse createTransformer(TransformerRequest request) {
        Transformer transformer = new Transformer(); transformer.setName(request.name()); transformer.setDescription(request.description());
        replaceTransformerRules(transformer, request.rules(), true);
        return transformerResponse(transformers.save(transformer));
    }

    @Transactional
    public TransformerResponse replaceTransformer(Long id, TransformerRequest request) {
        Transformer transformer = requireTransformer(id); transformer.setName(request.name()); transformer.setDescription(request.description());
        replaceTransformerRules(transformer, request.rules(), false);
        return transformerResponse(transformers.save(transformer));
    }

    /** Metadata is deliberately isolated from rule replacement for the v5 editor. */
    @Transactional
    public TransformerResponse updateTransformerMetadata(Long id, ConfigurationMetadataRequest request) {
        Transformer transformer = requireTransformer(id);
        transformer.setName(request.name());
        transformer.setDescription(request.description());
        return transformerResponse(transformers.save(transformer));
    }

    @Transactional
    public TransformerResponse cloneTransformer(Long id) {
        Transformer source = requireTransformer(id); Transformer copy = new Transformer();
        copy.setName(source.getName() + " - copy"); copy.setDescription(source.getDescription());
        for (TransformerRule rule : source.getRules()) {
            TransformerRule duplicate = new TransformerRule(); duplicate.setName(rule.getName()); duplicate.setDescription(rule.getDescription());
            duplicate.setRunorder(rule.getRunorder()); duplicate.setJsonserialization(rule.getJsonserialization()); copy.getRules().add(duplicate);
        }
        return transformerResponse(transformers.save(copy));
    }

    @Transactional
    public void deleteTransformer(Long id) {
        Transformer transformer = requireTransformer(id);
        if (transformerUsage(id).used()) {
            throw conflict("TRANSFORMER_IN_USE", "Transformer is associated with a network");
        }
        transformers.delete(transformer);
    }

    public UsageResponse validatorUsage(Long id) {
        requireValidator(id);
        List<UsageNetworkResponse> usage = new ArrayList<>();
        for (Network network : networks.findAll()) {
            List<String> relations = new ArrayList<>();
            if (network.getPrevalidator() != null && id.equals(network.getPrevalidator().getId())) relations.add("prevalidator");
            if (network.getValidator() != null && id.equals(network.getValidator().getId())) relations.add("validator");
            if (!relations.isEmpty()) usage.add(new UsageNetworkResponse(network.getId(), network.getAcronym(), network.getName(), relations));
        }
        return new UsageResponse(!usage.isEmpty(), usage);
    }

    public UsageResponse transformerUsage(Long id) {
        requireTransformer(id);
        List<UsageNetworkResponse> usage = new ArrayList<>();
        for (Network network : networks.findAll()) {
            List<String> relations = new ArrayList<>();
            if (network.getTransformer() != null && id.equals(network.getTransformer().getId())) relations.add("transformer");
            if (network.getSecondaryTransformer() != null && id.equals(network.getSecondaryTransformer().getId())) relations.add("secondaryTransformer");
            if (!relations.isEmpty()) usage.add(new UsageNetworkResponse(network.getId(), network.getAcronym(), network.getName(), relations));
        }
        return new UsageResponse(!usage.isEmpty(), usage);
    }

    public List<RuleResponse> validatorRules(Long id) { return requireValidator(id).getRules().stream().map(this::validatorRuleResponse).toList(); }
    public List<RuleResponse> transformerRules(Long id) { return requireTransformer(id).getRules().stream().sorted(Comparator.comparing(TransformerRule::getRunorder)).map(this::transformerRuleResponse).toList(); }
    public RuleResponse validatorRule(Long validatorId, Long ruleId) { return validatorRules(validatorId).stream().filter(rule -> ruleId.equals(rule.id())).findFirst().orElseThrow(() -> notFound("RULE_NOT_FOUND", "Rule was not found")); }
    public RuleResponse transformerRule(Long transformerId, Long ruleId) { return transformerRules(transformerId).stream().filter(rule -> ruleId.equals(rule.id())).findFirst().orElseThrow(() -> notFound("RULE_NOT_FOUND", "Rule was not found")); }

    @Transactional
    public RuleResponse addValidatorRule(Long id, RuleRequest request) {
        requireNewRule(request);
        Validator validator = requireValidator(id); ValidatorRule rule = validatorRule(request); validator.getRules().add(rule);
        validators.save(validator); return validatorRuleResponse(rule);
    }

    @Transactional
    public RuleResponse addTransformerRule(Long id, RuleRequest request) {
        requireNewRule(request);
        Transformer transformer = requireTransformer(id); TransformerRule rule = transformerRule(request); transformer.getRules().add(rule);
        transformers.save(transformer); return transformerRuleResponse(rule);
    }

    @Transactional
    public RuleResponse updateValidatorRule(Long validatorId, Long ruleId, RuleRequest request) {
        requireMatchingRuleId(ruleId, request);
        Validator validator = requireValidator(validatorId);
        ValidatorRule existing = validator.getRules().stream()
                .filter(rule -> ruleId.equals(rule.getId())).findFirst().orElseThrow(() -> notFound("RULE_NOT_FOUND", "Rule was not found"));
        ValidatorRule replacement = validatorRule(request);
        existing.setName(replacement.getName()); existing.setDescription(replacement.getDescription());
        existing.setMandatory(replacement.getMandatory()); existing.setQuantifier(replacement.getQuantifier()); existing.setJsonserialization(replacement.getJsonserialization());
        validators.save(validator); return validatorRuleResponse(existing);
    }

    @Transactional
    public RuleResponse updateTransformerRule(Long transformerId, Long ruleId, RuleRequest request) {
        requireMatchingRuleId(ruleId, request);
        Transformer transformer = requireTransformer(transformerId);
        TransformerRule existing = transformer.getRules().stream().filter(rule -> ruleId.equals(rule.getId())).findFirst()
                .orElseThrow(() -> notFound("RULE_NOT_FOUND", "Rule was not found"));
        TransformerRule replacement = transformerRule(request);
        existing.setName(replacement.getName()); existing.setDescription(replacement.getDescription()); existing.setRunorder(replacement.getRunorder()); existing.setJsonserialization(replacement.getJsonserialization());
        transformers.save(transformer); return transformerRuleResponse(existing);
    }

    @Transactional
    public void deleteValidatorRule(Long validatorId, Long ruleId) {
        Validator validator = requireValidator(validatorId);
        ValidatorRule rule = validator.getRules().stream().filter(item -> ruleId.equals(item.getId())).findFirst()
                .orElseThrow(() -> notFound("RULE_NOT_FOUND", "Rule was not found"));
        validator.getRules().remove(rule);
        // Validator.rules has no orphanRemoval in the legacy mapping. Flush the
        // association update before deleting the detached rule row.
        validators.saveAndFlush(validator);
        validatorRules.delete(rule);
    }

    @Transactional
    public void deleteTransformerRule(Long transformerId, Long ruleId) {
        Transformer transformer = requireTransformer(transformerId);
        TransformerRule rule = transformer.getRules().stream().filter(item -> ruleId.equals(item.getId())).findFirst()
                .orElseThrow(() -> notFound("RULE_NOT_FOUND", "Rule was not found"));
        transformer.getRules().remove(rule);
        // Transformer.rules has no orphanRemoval in the legacy mapping.
        transformers.saveAndFlush(transformer);
        transformerRules.delete(rule);
    }

    @Transactional
    public List<RuleResponse> reorderValidatorRules(Long validatorId, RuleOrderRequest request) {
        Validator validator = requireValidator(validatorId);
        if (validator.getRules().size() != request.ruleIds().size()) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "RULE_ORDER_INVALID", "Every validator rule must be included exactly once");
        Map<Long, ValidatorRule> byId = validator.getRules().stream().collect(java.util.stream.Collectors.toMap(ValidatorRule::getId, rule -> rule));
        List<ValidatorRule> ordered = request.ruleIds().stream().map(byId::get).toList();
        if (ordered.contains(null) || byId.size() != request.ruleIds().stream().distinct().count()) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "RULE_ORDER_INVALID", "Rule ids are invalid or duplicated");
        validator.setRules(new ArrayList<>(ordered)); validators.save(validator); return ordered.stream().map(this::validatorRuleResponse).toList();
    }

    @Transactional
    public List<RuleResponse> reorderTransformerRules(Long transformerId, RuleOrderRequest request) {
        Transformer transformer = requireTransformer(transformerId);
        if (transformer.getRules().size() != request.ruleIds().size()) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "RULE_ORDER_INVALID", "Every transformer rule must be included exactly once");
        Map<Long, TransformerRule> byId = transformer.getRules().stream().collect(java.util.stream.Collectors.toMap(TransformerRule::getId, rule -> rule));
        for (int index = 0; index < request.ruleIds().size(); index++) {
            TransformerRule rule = byId.get(request.ruleIds().get(index));
            if (rule == null) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "RULE_ORDER_INVALID", "Rule ids are invalid or duplicated");
            rule.setRunorder(index);
        }
        transformers.save(transformer); return transformer.getRules().stream().sorted(Comparator.comparing(TransformerRule::getRunorder)).map(this::transformerRuleResponse).toList();
    }

    public List<RuleTypeResponse> ruleTypes(String kind, Locale locale) {
        List<RuleTypeResponse> all = new ArrayList<>();
        if (kind == null || kind.equalsIgnoreCase("validator")) all.addAll(ruleTypes("validator", ruleSchemas.getAllValidatorSchemas(locale)));
        if (kind == null || kind.equalsIgnoreCase("transformer")) all.addAll(ruleTypes("transformer", ruleSchemas.getAllTransformerSchemas(locale)));
        if (all.isEmpty()) throw new ApiV5Exception(HttpStatus.BAD_REQUEST, "RULE_KIND_INVALID", "kind must be validator or transformer");
        return all;
    }

    public RuleTypeResponse ruleType(String typeId, Locale locale) {
        return ruleTypes(null, locale).stream().filter(type -> typeId.equals(type.typeId())).findFirst()
                .orElseThrow(() -> notFound("RULE_TYPE_NOT_FOUND", "Rule type was not found"));
    }

    /**
     * Runs the same schema/type resolution and serializer check as a write, but does
     * not create a rule or otherwise mutate the aggregate.
     */
    public RuleConfigurationValidationResponse validateRuleConfiguration(String typeId,
            RuleConfigurationValidationRequest request) {
        RuleTypeResponse type = ruleType(typeId, Locale.ROOT);
        serialize(type.kind(), type.className(), request.configuration());
        return new RuleConfigurationValidationResponse(type.typeId(), type.className(), true);
    }

    public CapabilityResponse capabilities() {
        var orderedCatalog = actionCatalog.list(actions.getEngineType()).stream()
                .collect(java.util.stream.Collectors.toMap(org.lareferencia.core.domain.ApplicationAction::getActionKey,
                        org.lareferencia.core.domain.ApplicationAction::getExecutionOrder));
        List<ActionResponse> actionResponses = actions.getEnabledActions().stream().map(action -> new ActionResponse(action.getName(),
                action.getDescription(), action.isIncremental(), action.getRunOnSchedule(), action.getAllwaysRunOnSchedule(),
                orderedCatalog.get(action.getName()), action.getWorkers(), action.getProperties().stream().map(NetworkProperty::getName).toList())).toList();
        List<PropertyResponse> properties = actions.getProperties().stream().map(p -> new PropertyResponse(p.getName(), p.getDescription())).toList();
        String engine = actions.getEngineType();
        return new CapabilityResponse(engine, actionResponses, properties, metadataFormats.getSourceMetadataFormats(),
                List.of("xoai", "xoai_openaire"),
                List.of(CommandType.RUN_ACTION.name(), CommandType.RUN_ENABLED_ACTIONS.name(), CommandType.CANCEL_ALL.name(), CommandType.RESCHEDULE.name()));
    }

    public RuntimeSummaryResponse runtime() {
        List<RuntimeProcessResponse> processes = actions.listRunning().stream().map(this::runtimeResponse).toList();
        String engine = processes.stream().map(RuntimeProcessResponse::engineType).filter(java.util.Objects::nonNull).findFirst().orElse("configured");
        return new RuntimeSummaryResponse(engine, actions.getRunningCount(), actions.getQueuedCount(), processes);
    }

    public List<RuntimeProcessResponse> networkRuntime(Long id) {
        Network network = requireNetwork(id); String context = NetworkRunningContext.buildID(network);
        return actions.listRunning().stream().filter(p -> context.equals(p.getProcessId()) || network.getAcronym().equals(p.getNetworkAcronym()))
                .map(this::runtimeResponse).toList();
    }

    public CommandReceipt command(Long id, CommandRequest request) {
        Network network = requireNetwork(id);
        try {
            switch (request.type()) {
                case RUN_ACTION -> {
                    if (request.actionName() == null || request.actionName().isBlank()) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "ACTION_REQUIRED", "actionName is required");
                    if (actions.getActions().stream().noneMatch(a -> request.actionName().equals(a.getName()))) throw new ApiV5Exception(HttpStatus.NOT_FOUND, "ACTION_NOT_FOUND", "Action is not configured");
                    actions.executeAction(request.actionName(), Boolean.TRUE.equals(request.incremental()), network);
                }
                case RUN_ENABLED_ACTIONS -> actions.executeActions(network);
                case CANCEL_ALL -> actions.killAndUnqueueActions(network);
                case RESCHEDULE -> actions.rescheduleNetwork(network);
            }
            return receipt(id, request.type(), "ACCEPTED", "Command submitted to the configured workflow engine");
        } catch (ApiV5Exception | ApplicationActionPolicyException exception) { throw exception;
        } catch (RuntimeException exception) { throw new ApiV5Exception(HttpStatus.CONFLICT, "COMMAND_REJECTED", exception.getMessage()); }
    }

    public BatchCommandReceipt batch(BatchCommandRequest request) {
        String id = UUID.randomUUID().toString(); List<CommandReceipt> children = new ArrayList<>();
        for (Long networkId : request.networkIds()) {
            try { children.add(command(networkId, request.command())); }
            catch (ApiV5Exception exception) { children.add(new CommandReceipt(UUID.randomUUID().toString(), networkId, request.command().type(), "REJECTED", OffsetDateTime.now(ZoneOffset.UTC), "/api/v5/networks/" + networkId + "/runtime", exception.getMessage())); }
        }
        return new BatchCommandReceipt(id, OffsetDateTime.now(ZoneOffset.UTC), children);
    }

    public PageResponse<SnapshotResponse> networkSnapshots(Long id, int page, int size) {
        requireNetwork(id); Page<NetworkSnapshot> result = snapshots.findByNetworkIdOrdered(id, PageRequest.of(page, size));
        return new PageResponse<>(result.map(this::snapshotResponse).toList(), result.getNumber(), result.getSize(), result.getTotalElements(), result.getTotalPages());
    }

    public SnapshotResponse snapshot(Long id) { return snapshotResponse(requireSnapshot(id)); }

    public SnapshotResponse latestSnapshot(Long networkId, String status) {
        Network network = requireNetwork(networkId); NetworkSnapshot snapshot = "valid".equalsIgnoreCase(status)
                ? snapshots.findLastGoodKnowByNetworkID(networkId) : snapshots.findLastByNetworkID(networkId);
        if (snapshot == null) throw new ApiV5Exception(HttpStatus.NOT_FOUND, "SNAPSHOT_NOT_FOUND", "No matching snapshot exists for " + network.getAcronym());
        return snapshotResponse(snapshot);
    }

    private void apply(Network network, NetworkRequest request) {
        if (request.scheduleCronExpression() != null && !request.scheduleCronExpression().isBlank() && !CronExpression.isValidExpression(request.scheduleCronExpression())) {
            throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "CRON_INVALID", "scheduleCronExpression is invalid");
        }
        try { URI uri = URI.create(request.originUrl()); if (uri.getScheme() == null || uri.getHost() == null) throw new IllegalArgumentException(); }
        catch (IllegalArgumentException exception) { throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "ORIGIN_URL_INVALID", "originUrl must be an absolute URL"); }
        network.setAcronym(request.acronym()); network.setName(request.name()); network.setInstitutionName(request.institutionName());
        network.setInstitutionAcronym(request.institutionAcronym()); network.setPublished(Boolean.TRUE.equals(request.published()));
        network.setOriginURL(request.originUrl()); network.setMetadataPrefix(defaultValue(request.metadataPrefix(), "oai_dc"));
        network.setMetadataStoreSchema(defaultValue(request.metadataStoreSchema(), "xoai")); network.setSets(request.sets() == null ? new ArrayList<>() : new ArrayList<>(request.sets()));
        attributeProfiles.validateReference(request.attributes());
        network.setAttributes(request.attributes() == null ? new HashMap<>() : new HashMap<>(request.attributes()));
        network.setProperties(request.properties() == null ? new HashMap<>() : new HashMap<>(request.properties()));
        network.setScheduleCronExpression(blankToNull(request.scheduleCronExpression())); network.setPrevalidator(optionalValidator(request.prevalidatorId()));
        network.setValidator(optionalValidator(request.validatorId())); network.setTransformer(optionalTransformer(request.transformerId())); network.setSecondaryTransformer(optionalTransformer(request.secondaryTransformerId()));
    }

    /** Reconciles a submitted aggregate without replacing existing rule identities. */
    private void replaceValidatorRules(Validator validator, List<RuleRequest> requests, boolean creating) {
        List<RuleRequest> source = requests == null ? List.of() : requests;
        Map<Long, ValidatorRule> existing = validator.getRules().stream().filter(rule -> rule.getId() != null)
                .collect(java.util.stream.Collectors.toMap(ValidatorRule::getId, rule -> rule));
        Set<Long> retained = new HashSet<>(); List<ValidatorRule> desired = new ArrayList<>();
        for (RuleRequest request : source) {
            ValidatorRule target;
            if (request.id() == null) target = validatorRule(request);
            else {
                if (creating) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "RULE_ID_NOT_ALLOWED", "New validators cannot contain rule ids");
                target = existing.get(request.id());
                if (target == null) rejectForeignValidatorRule(request.id());
                if (!retained.add(request.id())) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "RULE_ID_DUPLICATED", "A rule id appears more than once");
                copyValidatorRule(target, validatorRule(request));
            }
            desired.add(target);
        }
        List<ValidatorRule> removed = validator.getRules().stream()
                .filter(rule -> rule.getId() != null && !retained.contains(rule.getId())).toList();
        validator.setRules(desired);
        if (!creating && !removed.isEmpty()) {
            validators.saveAndFlush(validator);
            validatorRules.deleteAll(removed);
        }
    }

    /** Reconciles a submitted aggregate without replacing existing rule identities. */
    private void replaceTransformerRules(Transformer transformer, List<RuleRequest> requests, boolean creating) {
        List<RuleRequest> source = requests == null ? List.of() : requests;
        Map<Long, TransformerRule> existing = transformer.getRules().stream().filter(rule -> rule.getId() != null)
                .collect(java.util.stream.Collectors.toMap(TransformerRule::getId, rule -> rule));
        Set<Long> retained = new HashSet<>(); List<TransformerRule> desired = new ArrayList<>();
        for (RuleRequest request : source) {
            TransformerRule target;
            if (request.id() == null) target = transformerRule(request);
            else {
                if (creating) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "RULE_ID_NOT_ALLOWED", "New transformers cannot contain rule ids");
                target = existing.get(request.id());
                if (target == null) rejectForeignTransformerRule(request.id());
                if (!retained.add(request.id())) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "RULE_ID_DUPLICATED", "A rule id appears more than once");
                copyTransformerRule(target, transformerRule(request));
            }
            desired.add(target);
        }
        List<TransformerRule> removed = transformer.getRules().stream()
                .filter(rule -> rule.getId() != null && !retained.contains(rule.getId())).toList();
        transformer.setRules(desired);
        if (!creating && !removed.isEmpty()) {
            transformers.saveAndFlush(transformer);
            transformerRules.deleteAll(removed);
        }
    }

    private void copyValidatorRule(ValidatorRule target, ValidatorRule source) {
        target.setName(source.getName()); target.setDescription(source.getDescription()); target.setMandatory(source.getMandatory());
        target.setQuantifier(source.getQuantifier()); target.setJsonserialization(source.getJsonserialization());
    }

    private void copyTransformerRule(TransformerRule target, TransformerRule source) {
        target.setName(source.getName()); target.setDescription(source.getDescription()); target.setRunorder(source.getRunorder());
        target.setJsonserialization(source.getJsonserialization());
    }

    private void rejectForeignValidatorRule(Long ruleId) {
        if (validatorRules.existsById(ruleId)) throw conflict("RULE_OWNERSHIP_CONFLICT", "Rule belongs to another validator");
        throw notFound("RULE_NOT_FOUND", "Rule was not found");
    }

    private void rejectForeignTransformerRule(Long ruleId) {
        if (transformerRules.existsById(ruleId)) throw conflict("RULE_OWNERSHIP_CONFLICT", "Rule belongs to another transformer");
        throw notFound("RULE_NOT_FOUND", "Rule was not found");
    }

    private void requireNewRule(RuleRequest request) {
        if (request.id() != null) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "RULE_ID_NOT_ALLOWED", "New rules cannot contain an id");
    }

    private void requireMatchingRuleId(Long ruleId, RuleRequest request) {
        if (request.id() != null && !ruleId.equals(request.id())) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "RULE_ID_MISMATCH", "Body rule id must match the path");
    }

    private ValidatorRule validatorRule(RuleRequest request) {
        String className = resolveClassName("validator", request); String serialized = serialize("validator", className, request.configuration());
        ValidatorRule rule = new ValidatorRule(); rule.setName(request.name()); rule.setDescription(request.description()); rule.setMandatory(Boolean.TRUE.equals(request.mandatory()));
        try { rule.setQuantifier(request.quantifier() == null ? QuantifierValues.ONE_OR_MORE : QuantifierValues.valueOf(request.quantifier())); }
        catch (IllegalArgumentException exception) { throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "QUANTIFIER_INVALID", "Unknown validator quantifier"); }
        rule.setJsonserialization(serialized); return rule;
    }

    private TransformerRule transformerRule(RuleRequest request) {
        String className = resolveClassName("transformer", request); TransformerRule rule = new TransformerRule();
        rule.setName(request.name()); rule.setDescription(request.description()); rule.setRunorder(request.runOrder() == null ? 0 : request.runOrder());
        rule.setJsonserialization(serialize("transformer", className, request.configuration())); return rule;
    }

    private String serialize(String kind, String className, JsonNode configuration) {
        if (configuration == null || !configuration.isObject()) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "RULE_CONFIGURATION_INVALID", "configuration must be an object");
        ObjectNode node = ((ObjectNode) configuration).deepCopy(); node.put("@class", className);
        try {
            String json = objectMapper.writeValueAsString(node);
            Object rule = "validator".equals(kind) ? ruleSerializer.deserializeValidatorFromJsonString(json) : ruleSerializer.deserializeTransformerFromJsonString(json);
            if (rule == null) throw new IllegalArgumentException("Rule serializer rejected configuration");
            return json;
        } catch (Exception exception) { throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "RULE_CONFIGURATION_INVALID", exception.getMessage()); }
    }

    private String resolveClassName(String kind, RuleRequest request) {
        String fromType = request.typeId() == null ? null : ruleTypes(kind, schemas(kind)).stream().filter(t -> request.typeId().equals(t.typeId())).map(RuleTypeResponse::className).findFirst().orElse(null);
        if (request.typeId() != null && fromType == null) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "RULE_TYPE_UNKNOWN", "Unknown typeId");
        if (request.className() != null && ruleTypes(kind, schemas(kind)).stream().noneMatch(t -> request.className().equals(t.className()))) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "RULE_CLASS_UNKNOWN", "Unknown className");
        if (fromType != null && request.className() != null && !fromType.equals(request.className())) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "RULE_TYPE_MISMATCH", "typeId and className do not match");
        if (fromType == null && request.className() == null) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "RULE_TYPE_REQUIRED", "typeId or className is required");
        return fromType == null ? request.className() : fromType;
    }

    private List<RuleSchemaDefinition> schemas(String kind) { return "validator".equals(kind) ? ruleSchemas.getAllValidatorSchemas(Locale.ROOT) : ruleSchemas.getAllTransformerSchemas(Locale.ROOT); }

    /**
     * Converts the legacy Angular Schema Form layout into portable RJSF hints.
     * The original form structure is deliberately not part of the v5 contract.
     */
    private List<RuleTypeResponse> ruleTypes(String kind, List<RuleSchemaDefinition> definitions) {
        return definitions.stream().map(definition -> ruleTypeResponse(kind, definition))
                .sorted(Comparator.comparing(RuleTypeResponse::typeId)).toList();
    }

    private RuleTypeResponse ruleTypeResponse(String kind, RuleSchemaDefinition definition) {
        ObjectNode uiSchema = objectMapper.createObjectNode();
        List<String> order = new ArrayList<>();
        String help = null;
        if (definition.getForm() != null) {
            for (Object item : definition.getForm()) {
                if (item instanceof String key) {
                    order.add(key);
                    continue;
                }
                if (!(item instanceof Map<?, ?> map)) continue;
                String type = stringValue(map.get("type"));
                if ("help".equals(type)) {
                    help = stringValue(map.get("helpvalue"));
                    continue;
                }
                if ("submit".equals(type)) continue;
                String key = stringValue(map.get("key"));
                if (key == null || key.isBlank()) continue;
                order.add(key);
                String widget = rjsfWidget(stringValue(map.get("type")));
                if (widget != null) uiSchema.putObject(key).put("ui:widget", widget);
            }
        }
        if (!order.isEmpty()) {
            ArrayNode uiOrder = uiSchema.putArray("ui:order");
            order.forEach(uiOrder::add);
        }
        return new RuleTypeResponse(typeId(kind, definition.getClassName()), kind, definition.getClassName(),
                definition.getName(), help, objectMapper.valueToTree(definition.getSchema()), uiSchema);
    }

    private static String rjsfWidget(String legacyType) {
        return "textarea".equals(legacyType) ? "textarea" : null;
    }

    private static String stringValue(Object value) {
        return value == null ? null : String.valueOf(value);
    }
    private String typeId(String kind, String className) { return kind + "--" + className.substring(className.lastIndexOf('.') + 1).replaceAll("([a-z])([A-Z])", "$1-$2").toLowerCase(); }

    private NetworkResponse networkResponse(Network n) { return new NetworkResponse(n.getId(), Boolean.TRUE.equals(n.getPublished()), n.getAcronym(), n.getName(), n.getInstitutionName(), n.getInstitutionAcronym(), n.getOriginURL(), n.getMetadataPrefix(), n.getMetadataStoreSchema(), n.getSets(), n.getAttributes(), n.getProperties(), n.getScheduleCronExpression(), id(n.getPrevalidator()), id(n.getValidator()), id(n.getTransformer()), id(n.getSecondaryTransformer())); }
    private ValidatorResponse validatorResponse(Validator v) { return new ValidatorResponse(v.getId(), v.getName(), v.getDescription(), v.getRules().stream().map(this::validatorRuleResponse).toList()); }
    private TransformerResponse transformerResponse(Transformer t) { return new TransformerResponse(t.getId(), t.getName(), t.getDescription(), t.getRules().stream().map(this::transformerRuleResponse).toList()); }
    private RuleResponse validatorRuleResponse(ValidatorRule r) { return ruleResponse(r.getId(), r.getName(), r.getDescription(), r.getMandatory(), r.getQuantifier() == null ? null : r.getQuantifier().name(), null, r.getJsonserialization(), "validator"); }
    private RuleResponse transformerRuleResponse(TransformerRule r) { return ruleResponse(r.getId(), r.getName(), r.getDescription(), null, null, r.getRunorder(), r.getJsonserialization(), "transformer"); }
    private RuleResponse ruleResponse(Long id, String name, String description, Boolean mandatory, String quantifier, Integer order, String json, String kind) { try { ObjectNode node = (ObjectNode) objectMapper.readTree(json); String className = node.remove("@class").asText(); return new RuleResponse(id, typeId(kind, className), className, name, description, mandatory, quantifier, order, node); } catch (Exception exception) { throw new ApiV5Exception(HttpStatus.INTERNAL_SERVER_ERROR, "RULE_SERIALIZATION_INVALID", "Stored rule cannot be represented"); } }
    private SnapshotResponse snapshotResponse(NetworkSnapshot s) { return new SnapshotResponse(s.getId(), s.getNetwork() == null ? null : s.getNetwork().getId(), s.getPreviousSnapshotId(), s.getStatus().name(), s.getIndexStatus().name(), ApiV5NetworkSummaryService.utc(s.getStartTime()), ApiV5NetworkSummaryService.utc(s.getLastIncrementalTime()), ApiV5NetworkSummaryService.utc(s.getEndTime()), s.getSize(), s.getValidSize(), s.getTransformedSize(), s.isDeleted()); }
    private RuntimeProcessResponse runtimeResponse(RunningProcessInfo p) { return new RuntimeProcessResponse(p.getProcessId(), p.getNetworkAcronym(), p.getActionType(), p.getStatus(), ApiV5NetworkSummaryService.utc(p.getStartTime()), p.getIncremental(), p.getVariables(), p.getEngineType(), "legacy".equals(p.getEngineType()) ? "NETWORK" : "PROCESS"); }
    private CommandReceipt receipt(Long id, CommandType type, String result, String message) { return new CommandReceipt(UUID.randomUUID().toString(), id, type, result, OffsetDateTime.now(ZoneOffset.UTC), "/api/v5/networks/" + id + "/runtime", message); }
    private Network requireNetwork(Long id) { return networks.findById(id).orElseThrow(() -> notFound("NETWORK_NOT_FOUND", "Network " + id + " was not found")); }
    private Validator requireValidator(Long id) { return validators.findById(id).orElseThrow(() -> notFound("VALIDATOR_NOT_FOUND", "Validator " + id + " was not found")); }
    private Transformer requireTransformer(Long id) { return transformers.findById(id).orElseThrow(() -> notFound("TRANSFORMER_NOT_FOUND", "Transformer " + id + " was not found")); }
    private NetworkSnapshot requireSnapshot(Long id) { return snapshots.findById(id).orElseThrow(() -> notFound("SNAPSHOT_NOT_FOUND", "Snapshot " + id + " was not found")); }
    private Validator optionalValidator(Long id) { return id == null ? null : requireValidator(id); }
    private Transformer optionalTransformer(Long id) { return id == null ? null : requireTransformer(id); }
    private void ensureNotActive(Network network) { String context = NetworkRunningContext.buildID(network); if (!actions.getRunningTasksByRunningContextID(context).isEmpty() || !actions.getQueuedTasksByRunningContextID(context).isEmpty()) throw conflict("NETWORK_ACTIVE", "Network has active or queued tasks"); }
    private static boolean same(Object left, Object right) { return left != null && right != null && java.util.Objects.equals(id(left), id(right)); }
    private static Long id(Object entity) { if (entity instanceof Validator v) return v.getId(); if (entity instanceof Transformer t) return t.getId(); return null; }
    private static ApiV5Exception notFound(String code, String message) { return new ApiV5Exception(HttpStatus.NOT_FOUND, code, message); }
    private static ApiV5Exception conflict(String code, String message) { return new ApiV5Exception(HttpStatus.CONFLICT, code, message); }
    private static String defaultValue(String value, String fallback) { return value == null || value.isBlank() ? fallback : value; }
    private static String blankToNull(String value) { return value == null || value.isBlank() ? null : value; }
}
