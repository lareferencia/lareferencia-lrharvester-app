package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5Dtos.NetworkRequest;
import static org.lareferencia.backend.api.v5.ApiV5NetworkTransferDtos.*;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.HashSet;

import org.apache.poi.openxml4j.util.ZipSecureFile;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.lareferencia.core.domain.ApplicationAction;
import org.lareferencia.core.domain.Network;
import org.lareferencia.core.domain.NetworkActionConfiguration;
import org.lareferencia.core.domain.Transformer;
import org.lareferencia.core.domain.Validator;
import org.lareferencia.core.repository.jpa.NetworkRepository;
import org.lareferencia.core.repository.jpa.TransformerRepository;
import org.lareferencia.core.repository.jpa.ValidatorRepository;
import org.lareferencia.core.task.ApplicationActionCatalogService;
import org.lareferencia.core.task.NetworkActionConfigurationService;
import org.lareferencia.core.task.NetworkActionkManager;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.scheduling.support.CronExpression;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;

/**
 * The spreadsheet deliberately contains one sheet only. Complex source values stay JSON
 * columns, so attributes and action policy can round-trip without a variable column set.
 */
@Service
public class ApiV5NetworkTransferService {
    static final String SHEET = "Fuentes";
    static final int FORMAT_VERSION = 1;
    static final List<String> COLUMNS = List.of("sourceId", "acronym", "name", "institutionName",
            "institutionAcronym", "published", "originUrl", "metadataPrefix", "metadataStoreSchema",
            "scheduleCronExpression", "attributeProfile", "attributesJson", "setsJson", "propertiesJson",
            "prevalidatorRef", "validatorRef", "transformerRef", "secondaryTransformerRef", "actionsJson");
    private static final int MAX_ROWS = 10_000;
    private static final int MAX_FILE_BYTES = 10 * 1024 * 1024;

    private final NetworkRepository networks;
    private final ValidatorRepository validators;
    private final TransformerRepository transformers;
    private final ApiV5ManagementService management;
    private final ApiV5AttributeProfileService profiles;
    private final NetworkActionConfigurationService actionConfigurations;
    private final ApplicationActionCatalogService actionCatalog;
    private final NetworkActionkManager actionManager;
    private final ObjectMapper json;

    public ApiV5NetworkTransferService(NetworkRepository networks, ValidatorRepository validators,
            TransformerRepository transformers, ApiV5ManagementService management, ApiV5AttributeProfileService profiles,
            NetworkActionConfigurationService actionConfigurations, ApplicationActionCatalogService actionCatalog,
            NetworkActionkManager actionManager, ObjectMapper json) {
        this.networks = networks; this.validators = validators; this.transformers = transformers;
        this.management = management; this.profiles = profiles; this.actionConfigurations = actionConfigurations;
        this.actionCatalog = actionCatalog; this.actionManager = actionManager; this.json = json;
    }

    public byte[] exportXlsx() {
        try (Workbook workbook = new XSSFWorkbook(); ByteArrayOutputStream output = new ByteArrayOutputStream()) {
            Sheet sheet = workbook.createSheet(SHEET);
            Row header = sheet.createRow(0);
            for (int i = 0; i < COLUMNS.size(); i++) header.createCell(i).setCellValue(COLUMNS.get(i));
            int rowNumber = 1;
            for (Network network : networks.findAll().stream().sorted(Comparator.comparing(Network::getAcronym)).toList()) {
                Map<String, String> values = new LinkedHashMap<>();
                values.put("sourceId", value(network.getId())); values.put("acronym", network.getAcronym());
                values.put("name", network.getName()); values.put("institutionName", network.getInstitutionName());
                values.put("institutionAcronym", network.getInstitutionAcronym()); values.put("published", value(network.getPublished()));
                values.put("originUrl", network.getOriginURL()); values.put("metadataPrefix", network.getMetadataPrefix());
                values.put("metadataStoreSchema", network.getMetadataStoreSchema()); values.put("scheduleCronExpression", network.getScheduleCronExpression());
                values.put("attributeProfile", profileType(network));
                values.put("attributesJson", json.writeValueAsString(defaultMap(network.getAttributes())));
                values.put("setsJson", json.writeValueAsString(network.getSets() == null ? List.of() : network.getSets()));
                values.put("propertiesJson", json.writeValueAsString(defaultMap(network.getProperties())));
                values.put("prevalidatorRef", validatorName(network.getPrevalidator())); values.put("validatorRef", validatorName(network.getValidator()));
                values.put("transformerRef", transformerName(network.getTransformer())); values.put("secondaryTransformerRef", transformerName(network.getSecondaryTransformer()));
                values.put("actionsJson", json.writeValueAsString(actions(network)));
                Row row = sheet.createRow(rowNumber++);
                for (int i = 0; i < COLUMNS.size(); i++) row.createCell(i).setCellValue(safeExcel(values.get(COLUMNS.get(i))));
            }
            sheet.createFreezePane(0, 1);
            for (int i = 0; i < COLUMNS.size(); i++) sheet.setColumnWidth(i, Math.min(80 * 256, Math.max(12 * 256, COLUMNS.get(i).length() * 256 + 1024)));
            workbook.write(output);
            return output.toByteArray();
        } catch (IOException error) {
            throw new ApiV5Exception(HttpStatus.INTERNAL_SERVER_ERROR, "NETWORK_EXPORT_FAILED", "Could not generate the source XLSX: " + error.getMessage());
        }
    }

    public ImportValidationResponse validate(MultipartFile file, ImportMode mode) {
        return validateRows(read(file), mode == null ? ImportMode.UPSERT : mode);
    }

    @Transactional
    public ImportResult importXlsx(MultipartFile file, ImportMode mode, String username) {
        ImportMode effectiveMode = mode == null ? ImportMode.UPSERT : mode;
        List<SourceRow> rows = read(file);
        ImportValidationResponse validation = validateRows(rows, effectiveMode);
        if (validation.invalidRows() > 0) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY,
                "NETWORK_IMPORT_INVALID", "The XLSX has " + validation.invalidRows() + " invalid source rows; run validation for details");
        int created = 0, updated = 0;
        for (SourceRow row : rows) {
            Network existing = networks.findByAcronym(row.acronym());
            NetworkRequest request = request(row);
            Long id;
            if (existing == null) { id = management.createNetwork(request).id(); created++; }
            else { id = management.replaceNetwork(existing.getId(), request).id(); updated++; }
            for (ActionRow action : row.actions()) actionConfigurations.replace(networks.findById(id).orElseThrow(),
                    actionManager.getEngineType(), action.actionKey(), action.enabled(), action.scheduleEnabled(), action.configuration(), username);
        }
        return new ImportResult(validation, created, updated);
    }

    private ImportValidationResponse validateRows(List<SourceRow> rows, ImportMode mode) {
        List<ImportRowResult> result = new ArrayList<>(); Set<String> seen = new HashSet<>();
        for (SourceRow row : rows) {
            List<String> errors = new ArrayList<>(), warnings = new ArrayList<>();
            if (row.parseError() != null) errors.add(row.parseError());
            if (blank(row.acronym()) || !row.acronym().matches("^[A-Za-z0-9][A-Za-z0-9._-]*$") || row.acronym().length() > 10) errors.add("acronym is invalid");
            if (!blank(row.acronym()) && !seen.add(row.acronym())) errors.add("acronym appears more than once in this XLSX");
            Network existing = blank(row.acronym()) ? null : networks.findByAcronym(row.acronym());
            if (mode == ImportMode.CREATE_ONLY && existing != null) errors.add("source already exists");
            if (mode == ImportMode.UPDATE_ONLY && existing == null) errors.add("source does not exist");
            if (blank(row.name())) errors.add("name is required"); if (blank(row.institutionName())) errors.add("institutionName is required");
            validateUrl(row.originUrl(), errors); validateCron(row.scheduleCronExpression(), errors);
            validateProfile(row, errors); resolveValidator(row.prevalidatorRef(), "prevalidatorRef", errors); resolveValidator(row.validatorRef(), "validatorRef", errors);
            resolveTransformer(row.transformerRef(), "transformerRef", errors); resolveTransformer(row.secondaryTransformerRef(), "secondaryTransformerRef", errors);
            for (ActionRow action : row.actions()) validateAction(action, errors);
            String operation = existing == null ? "CREATE" : "UPDATE";
            result.add(new ImportRowResult(row.row(), row.acronym(), operation, List.copyOf(errors), List.copyOf(warnings)));
        }
        long invalid = result.stream().filter(row -> !row.valid()).count();
        return new ImportValidationResponse("lareferencia-network-xlsx", FORMAT_VERSION, mode, rows.size(), (int) (rows.size() - invalid), (int) invalid, result);
    }

    private void validateAction(ActionRow action, List<String> errors) {
        if (blank(action.actionKey())) { errors.add("actionKey is required in actionsJson"); return; }
        if (action.configuration() == null || !action.configuration().isObject()) {
            errors.add("action " + action.actionKey() + ": configuration must be a JSON object");
            return;
        }
        try {
            ApplicationAction application = actionCatalog.require(actionManager.getEngineType(), action.actionKey());
            ObjectNode effective = application.getConfiguration() != null && application.getConfiguration().isObject()
                    ? (ObjectNode) application.getConfiguration().deepCopy() : json.createObjectNode();
            merge(effective, action.configuration()); actionCatalog.validateConfiguration(application.getDefinition().path("schema"), effective);
        } catch (RuntimeException error) { errors.add("action " + action.actionKey() + ": " + error.getMessage()); }
    }

    private NetworkRequest request(SourceRow row) {
        Map<String, Object> attributes = new HashMap<>(row.attributes());
        if (!blank(row.profileType())) attributes.put("@class", profiles.get(row.profileType()).className());
        return new NetworkRequest(row.acronym(), row.name(), row.institutionName(), blankToNull(row.institutionAcronym()), row.published(), row.originUrl(),
                blankToNull(row.metadataPrefix()), blankToNull(row.metadataStoreSchema()), row.sets(), attributes, row.properties(),
                blankToNull(row.scheduleCronExpression()), validatorId(row.prevalidatorRef()), validatorId(row.validatorRef()),
                transformerId(row.transformerRef()), transformerId(row.secondaryTransformerRef()));
    }

    private List<SourceRow> read(MultipartFile file) {
        if (file == null || file.isEmpty()) throw new ApiV5Exception(HttpStatus.BAD_REQUEST, "NETWORK_IMPORT_FILE_REQUIRED", "An XLSX file is required");
        if (file.getSize() > MAX_FILE_BYTES) throw new ApiV5Exception(HttpStatus.PAYLOAD_TOO_LARGE, "NETWORK_IMPORT_FILE_TOO_LARGE", "The XLSX must be at most 10 MiB");
        try {
            ZipSecureFile.setMinInflateRatio(0.01d);
            try (Workbook workbook = WorkbookFactory.create(new ByteArrayInputStream(file.getBytes()))) {
                Sheet sheet = workbook.getSheet(SHEET);
                if (sheet == null) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "NETWORK_IMPORT_SHEET_INVALID", "The XLSX must contain a 'Fuentes' sheet");
                if (sheet.getLastRowNum() > MAX_ROWS) throw new ApiV5Exception(HttpStatus.PAYLOAD_TOO_LARGE, "NETWORK_IMPORT_ROWS_TOO_MANY", "The XLSX contains more than " + MAX_ROWS + " rows");
                Map<String, Integer> columns = columns(sheet.getRow(0)); DataFormatter formatter = new DataFormatter(); List<SourceRow> rows = new ArrayList<>();
                for (int index = 1; index <= sheet.getLastRowNum(); index++) {
                    Row excelRow = sheet.getRow(index); if (excelRow == null || empty(excelRow, formatter)) continue;
                    rows.add(parse(index + 1, excelRow, columns, formatter));
                }
                return rows;
            }
        } catch (ApiV5Exception error) { throw error; }
        catch (Exception error) { throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "NETWORK_IMPORT_XLSX_INVALID", "Could not read XLSX: " + error.getMessage()); }
    }

    private Map<String, Integer> columns(Row header) {
        if (header == null) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "NETWORK_IMPORT_HEADER_INVALID", "The Fuentes sheet has no header");
        Map<String, Integer> result = new HashMap<>(); DataFormatter formatter = new DataFormatter();
        for (Cell cell : header) result.put(formatter.formatCellValue(cell).trim(), cell.getColumnIndex());
        for (String required : List.of("acronym", "name", "institutionName", "originUrl")) if (!result.containsKey(required))
            throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "NETWORK_IMPORT_HEADER_INVALID", "Missing required column " + required);
        return result;
    }

    private SourceRow parse(int rowNumber, Row row, Map<String, Integer> columns, DataFormatter formatter) {
        try {
            String profile = cell(row, columns, "attributeProfile", formatter);
            Map<String, Object> attributes = object(cell(row, columns, "attributesJson", formatter));
            List<String> sets = list(cell(row, columns, "setsJson", formatter));
            Map<String, Boolean> properties = boolMap(cell(row, columns, "propertiesJson", formatter));
            List<ActionRow> actions = actions(cell(row, columns, "actionsJson", formatter));
            return new SourceRow(rowNumber, cell(row, columns, "acronym", formatter), cell(row, columns, "name", formatter),
                    cell(row, columns, "institutionName", formatter), cell(row, columns, "institutionAcronym", formatter),
                    bool(cell(row, columns, "published", formatter)), cell(row, columns, "originUrl", formatter),
                    cell(row, columns, "metadataPrefix", formatter), cell(row, columns, "metadataStoreSchema", formatter),
                    cell(row, columns, "scheduleCronExpression", formatter), profile, attributes, sets, properties,
                    cell(row, columns, "prevalidatorRef", formatter), cell(row, columns, "validatorRef", formatter),
                    cell(row, columns, "transformerRef", formatter), cell(row, columns, "secondaryTransformerRef", formatter), actions, null);
        } catch (Exception error) {
            return new SourceRow(rowNumber, cell(row, columns, "acronym", formatter), "", "", "", false, "", "", "", "", "", Map.of(), List.of(), Map.of(), "", "", "", "", List.of(), "Invalid row: " + error.getMessage());
        }
    }

    private String cell(Row row, Map<String, Integer> columns, String name, DataFormatter formatter) {
        Integer index = columns.get(name); if (index == null) return ""; Cell cell = row.getCell(index); if (cell == null) return "";
        if (cell.getCellType() == CellType.FORMULA) throw new IllegalArgumentException("formulas are not allowed");
        String value = formatter.formatCellValue(cell); return value == null ? "" : value.trim();
    }

    private boolean empty(Row row, DataFormatter formatter) { for (Cell cell : row) if (!formatter.formatCellValue(cell).trim().isEmpty()) return false; return true; }
    private Map<String, Object> object(String value) throws IOException { return blank(value) ? Map.of() : json.readValue(value, new TypeReference<Map<String, Object>>() {}); }
    private List<String> list(String value) throws IOException { return blank(value) ? List.of() : json.readValue(value, new TypeReference<List<String>>() {}); }
    private Map<String, Boolean> boolMap(String value) throws IOException { return blank(value) ? Map.of() : json.readValue(value, new TypeReference<Map<String, Boolean>>() {}); }
    private List<ActionRow> actions(String value) throws IOException { return blank(value) ? List.of() : json.readValue(value, new TypeReference<List<ActionRow>>() {}); }
    private boolean bool(String value) { if (blank(value)) return false; if (!"true".equalsIgnoreCase(value) && !"false".equalsIgnoreCase(value)) throw new IllegalArgumentException("published must be true or false"); return Boolean.parseBoolean(value); }

    private void validateUrl(String value, List<String> errors) { try { URI uri = URI.create(value); if (uri.getScheme() == null || uri.getHost() == null) throw new IllegalArgumentException(); } catch (Exception error) { errors.add("originUrl is invalid"); } }
    private void validateCron(String value, List<String> errors) { if (!blank(value) && !CronExpression.isValidExpression(value)) errors.add("scheduleCronExpression is invalid"); }
    private void validateProfile(SourceRow row, List<String> errors) { try { if (!blank(row.profileType())) profiles.get(row.profileType()); else profiles.validateReference(row.attributes()); } catch (RuntimeException error) { errors.add(error.getMessage()); } }
    private void resolveValidator(String name, String field, List<String> errors) { try { validatorId(name); } catch (RuntimeException error) { errors.add(field + ": " + error.getMessage()); } }
    private void resolveTransformer(String name, String field, List<String> errors) { try { transformerId(name); } catch (RuntimeException error) { errors.add(field + ": " + error.getMessage()); } }
    private Long validatorId(String name) { if (blank(name)) return null; List<Validator> found = validators.findAll().stream().filter(item -> name.equals(item.getName())).toList(); if (found.size() != 1) throw new IllegalArgumentException(found.isEmpty() ? "validator not found: " + name : "validator reference is ambiguous: " + name); return found.get(0).getId(); }
    private Long transformerId(String name) { if (blank(name)) return null; List<Transformer> found = transformers.findAll().stream().filter(item -> name.equals(item.getName())).toList(); if (found.size() != 1) throw new IllegalArgumentException(found.isEmpty() ? "transformer not found: " + name : "transformer reference is ambiguous: " + name); return found.get(0).getId(); }

    private List<ActionRow> actions(Network network) { return actionConfigurations.list(network).stream().sorted(Comparator.comparing(row -> row.getApplicationAction().getActionKey())).map(row -> new ActionRow(row.getApplicationAction().getActionKey(), row.isEnabled(), row.isScheduleEnabled(), row.getConfiguration())).toList(); }
    private String profileType(Network network) { Object clazz = defaultMap(network.getAttributes()).get("@class"); if (!(clazz instanceof String className)) return ""; return profiles.list().stream().filter(profile -> className.equals(profile.className())).map(profile -> profile.typeId()).findFirst().orElse(""); }
    private String validatorName(Validator value) { return value == null ? "" : value.getName(); }
    private String transformerName(Transformer value) { return value == null ? "" : value.getName(); }
    private static String safeExcel(String value) { if (value == null) return ""; return value.startsWith("=") || value.startsWith("+") || value.startsWith("-") || value.startsWith("@") ? "'" + value : value; }
    private static String value(Object value) { return value == null ? "" : String.valueOf(value); }
    private static <T> Map<String, T> defaultMap(Map<String, T> value) { return value == null ? Map.of() : value; }
    private static boolean blank(String value) { return value == null || value.isBlank(); }
    private static String blankToNull(String value) { return blank(value) ? null : value; }
    private void merge(ObjectNode target, JsonNode source) { if (source == null || !source.isObject()) return; source.fields().forEachRemaining(entry -> { if (entry.getValue().isObject() && target.path(entry.getKey()).isObject()) merge((ObjectNode) target.path(entry.getKey()), entry.getValue()); else target.set(entry.getKey(), entry.getValue()); }); }

    public record ActionRow(String actionKey, boolean enabled, boolean scheduleEnabled, JsonNode configuration) { }
    record SourceRow(int row, String acronym, String name, String institutionName, String institutionAcronym, boolean published,
            String originUrl, String metadataPrefix, String metadataStoreSchema, String scheduleCronExpression, String profileType,
            Map<String, Object> attributes, List<String> sets, Map<String, Boolean> properties, String prevalidatorRef,
            String validatorRef, String transformerRef, String secondaryTransformerRef, List<ActionRow> actions, String parseError) { }
}
