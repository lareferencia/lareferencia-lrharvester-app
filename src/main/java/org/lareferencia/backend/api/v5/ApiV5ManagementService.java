package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5Dtos.*;

import java.net.URI;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
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
import org.lareferencia.core.repository.jpa.ValidatorRepository;
import org.lareferencia.core.task.NetworkAction;
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
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.scheduling.support.CronExpression;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;

@Service
public class ApiV5ManagementService {
    private final NetworkRepository networks;
    private final NetworkSnapshotRepository snapshots;
    private final ValidatorRepository validators;
    private final TransformerRepository transformers;
    private final NetworkActionkManager actions;
    private final ValidatorRuleSchemaService ruleSchemas;
    private final RuleSerializer ruleSerializer;
    private final ObjectMapper objectMapper;
    private final MDFormatTransformerService metadataFormats;

    public ApiV5ManagementService(NetworkRepository networks, NetworkSnapshotRepository snapshots,
            ValidatorRepository validators, TransformerRepository transformers, NetworkActionkManager actions,
            ValidatorRuleSchemaService ruleSchemas, RuleSerializer ruleSerializer, ObjectMapper objectMapper,
            MDFormatTransformerService metadataFormats) {
        this.networks = networks;
        this.snapshots = snapshots;
        this.validators = validators;
        this.transformers = transformers;
        this.actions = actions;
        this.ruleSchemas = ruleSchemas;
        this.ruleSerializer = ruleSerializer;
        this.objectMapper = objectMapper;
        this.metadataFormats = metadataFormats;
    }

    public PageResponse<NetworkResponse> listNetworks(int page, int size) {
        Page<Network> result = networks.findAll(PageRequest.of(page, size));
        return new PageResponse<>(result.map(this::networkResponse).toList(), result.getNumber(), result.getSize(),
                result.getTotalElements(), result.getTotalPages());
    }

    public NetworkResponse network(Long id) { return networkResponse(requireNetwork(id)); }

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
        if (reschedule) actions.rescheduleNetwork(saved);
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

    @Transactional
    public ValidatorResponse createValidator(ValidatorRequest request) {
        Validator validator = new Validator();
        validator.setName(request.name());
        validator.setDescription(request.description());
        replaceValidatorRules(validator, request.rules());
        return validatorResponse(validators.save(validator));
    }

    @Transactional
    public ValidatorResponse replaceValidator(Long id, ValidatorRequest request) {
        Validator validator = requireValidator(id);
        validator.setName(request.name());
        validator.setDescription(request.description());
        replaceValidatorRules(validator, request.rules());
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
        if (networks.findAll().stream().anyMatch(n -> same(n.getPrevalidator(), validator) || same(n.getValidator(), validator))) {
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

    @Transactional
    public TransformerResponse createTransformer(TransformerRequest request) {
        Transformer transformer = new Transformer(); transformer.setName(request.name()); transformer.setDescription(request.description());
        replaceTransformerRules(transformer, request.rules());
        return transformerResponse(transformers.save(transformer));
    }

    @Transactional
    public TransformerResponse replaceTransformer(Long id, TransformerRequest request) {
        Transformer transformer = requireTransformer(id); transformer.setName(request.name()); transformer.setDescription(request.description());
        replaceTransformerRules(transformer, request.rules());
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
        if (networks.findAll().stream().anyMatch(n -> same(n.getTransformer(), transformer) || same(n.getSecondaryTransformer(), transformer))) {
            throw conflict("TRANSFORMER_IN_USE", "Transformer is associated with a network");
        }
        transformers.delete(transformer);
    }

    @Transactional
    public RuleResponse addValidatorRule(Long id, RuleRequest request) {
        Validator validator = requireValidator(id); ValidatorRule rule = validatorRule(request); validator.getRules().add(rule);
        validators.save(validator); return validatorRuleResponse(rule);
    }

    @Transactional
    public RuleResponse addTransformerRule(Long id, RuleRequest request) {
        Transformer transformer = requireTransformer(id); TransformerRule rule = transformerRule(request); transformer.getRules().add(rule);
        transformers.save(transformer); return transformerRuleResponse(rule);
    }

    @Transactional
    public RuleResponse updateValidatorRule(Long validatorId, Long ruleId, RuleRequest request) {
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
        if (!validator.getRules().removeIf(rule -> ruleId.equals(rule.getId()))) throw notFound("RULE_NOT_FOUND", "Rule was not found");
        validators.save(validator);
    }

    @Transactional
    public void deleteTransformerRule(Long transformerId, Long ruleId) {
        Transformer transformer = requireTransformer(transformerId);
        if (!transformer.getRules().removeIf(rule -> ruleId.equals(rule.getId()))) throw notFound("RULE_NOT_FOUND", "Rule was not found");
        transformers.save(transformer);
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

    public CapabilityResponse capabilities() {
        List<ActionResponse> actionResponses = actions.getActions().stream().map(action -> new ActionResponse(action.getName(),
                action.getDescription(), action.isIncremental(), action.getRunOnSchedule(), action.getAllwaysRunOnSchedule(),
                action.getDisplayOrder(), action.getWorkers(), action.getProperties().stream().map(NetworkProperty::getName).toList())).toList();
        List<PropertyResponse> properties = actions.getProperties().stream().map(p -> new PropertyResponse(p.getName(), p.getDescription())).toList();
        String engine = actions.listRunning().stream().map(RunningProcessInfo::getEngineType).filter(java.util.Objects::nonNull).findFirst().orElse("configured");
        return new CapabilityResponse(engine, actionResponses, properties, metadataFormats.getSourceMetadataFormats(),
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
        } catch (ApiV5Exception exception) { throw exception;
        } catch (RuntimeException exception) { throw new ApiV5Exception(HttpStatus.CONFLICT, "COMMAND_REJECTED", exception.getMessage()); }
    }

    public BatchCommandReceipt batch(BatchCommandRequest request) {
        String id = UUID.randomUUID().toString(); List<CommandReceipt> children = new ArrayList<>();
        for (Long networkId : request.networkIds()) {
            try { children.add(command(networkId, request.command())); }
            catch (ApiV5Exception exception) { children.add(new CommandReceipt(UUID.randomUUID().toString(), networkId, request.command().type(), "REJECTED", LocalDateTime.now(), "/api/v5/networks/" + networkId + "/runtime", exception.getMessage())); }
        }
        return new BatchCommandReceipt(id, LocalDateTime.now(), children);
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
        network.setAttributes(request.attributes() == null ? new HashMap<>() : new HashMap<>(request.attributes()));
        network.setProperties(request.properties() == null ? new HashMap<>() : new HashMap<>(request.properties()));
        network.setScheduleCronExpression(blankToNull(request.scheduleCronExpression())); network.setPrevalidator(optionalValidator(request.prevalidatorId()));
        network.setValidator(optionalValidator(request.validatorId())); network.setTransformer(optionalTransformer(request.transformerId())); network.setSecondaryTransformer(optionalTransformer(request.secondaryTransformerId()));
    }

    private void replaceValidatorRules(Validator validator, List<RuleRequest> requests) { validator.getRules().clear(); if (requests != null) requests.forEach(r -> validator.getRules().add(validatorRule(r))); }
    private void replaceTransformerRules(Transformer transformer, List<RuleRequest> requests) { transformer.getRules().clear(); if (requests != null) requests.forEach(r -> transformer.getRules().add(transformerRule(r))); }

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
    private List<RuleTypeResponse> ruleTypes(String kind, List<RuleSchemaDefinition> definitions) { return definitions.stream().map(d -> new RuleTypeResponse(typeId(kind, d.getClassName()), kind, d.getClassName(), d.getName(), objectMapper.valueToTree(d.getSchema()))).sorted(Comparator.comparing(RuleTypeResponse::typeId)).toList(); }
    private String typeId(String kind, String className) { return kind + "--" + className.substring(className.lastIndexOf('.') + 1).replaceAll("([a-z])([A-Z])", "$1-$2").toLowerCase(); }

    private NetworkResponse networkResponse(Network n) { return new NetworkResponse(n.getId(), Boolean.TRUE.equals(n.getPublished()), n.getAcronym(), n.getName(), n.getInstitutionName(), n.getInstitutionAcronym(), n.getOriginURL(), n.getMetadataPrefix(), n.getMetadataStoreSchema(), n.getSets(), n.getAttributes(), n.getProperties(), n.getScheduleCronExpression(), id(n.getPrevalidator()), id(n.getValidator()), id(n.getTransformer()), id(n.getSecondaryTransformer())); }
    private ValidatorResponse validatorResponse(Validator v) { return new ValidatorResponse(v.getId(), v.getName(), v.getDescription(), v.getRules().stream().map(this::validatorRuleResponse).toList()); }
    private TransformerResponse transformerResponse(Transformer t) { return new TransformerResponse(t.getId(), t.getName(), t.getDescription(), t.getRules().stream().map(this::transformerRuleResponse).toList()); }
    private RuleResponse validatorRuleResponse(ValidatorRule r) { return ruleResponse(r.getId(), r.getName(), r.getDescription(), r.getMandatory(), r.getQuantifier() == null ? null : r.getQuantifier().name(), null, r.getJsonserialization(), "validator"); }
    private RuleResponse transformerRuleResponse(TransformerRule r) { return ruleResponse(r.getId(), r.getName(), r.getDescription(), null, null, r.getRunorder(), r.getJsonserialization(), "transformer"); }
    private RuleResponse ruleResponse(Long id, String name, String description, Boolean mandatory, String quantifier, Integer order, String json, String kind) { try { ObjectNode node = (ObjectNode) objectMapper.readTree(json); String className = node.remove("@class").asText(); return new RuleResponse(id, typeId(kind, className), className, name, description, mandatory, quantifier, order, node); } catch (Exception exception) { throw new ApiV5Exception(HttpStatus.INTERNAL_SERVER_ERROR, "RULE_SERIALIZATION_INVALID", "Stored rule cannot be represented"); } }
    private SnapshotResponse snapshotResponse(NetworkSnapshot s) { return new SnapshotResponse(s.getId(), s.getNetwork() == null ? null : s.getNetwork().getId(), s.getPreviousSnapshotId(), s.getStatus().name(), s.getIndexStatus().name(), s.getStartTime(), s.getLastIncrementalTime(), s.getEndTime(), s.getSize(), s.getValidSize(), s.getTransformedSize(), s.isDeleted()); }
    private RuntimeProcessResponse runtimeResponse(RunningProcessInfo p) { return new RuntimeProcessResponse(p.getProcessId(), p.getNetworkAcronym(), p.getActionType(), p.getStatus(), p.getStartTime(), p.getIncremental(), p.getVariables(), p.getEngineType(), "legacy".equals(p.getEngineType()) ? "NETWORK" : "PROCESS"); }
    private CommandReceipt receipt(Long id, CommandType type, String result, String message) { return new CommandReceipt(UUID.randomUUID().toString(), id, type, result, LocalDateTime.now(), "/api/v5/networks/" + id + "/runtime", message); }
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
