package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5DarkDtos.*;

import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Locale;
import java.util.LinkedHashSet;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

import org.lareferencia.contrib.dark.domain.DarkTrackingRecord;
import org.lareferencia.contrib.dark.domain.DarkTrackingState;
import org.lareferencia.contrib.dark.repositories.DarkTrackingRepository;
import org.lareferencia.core.domain.Network;
import org.lareferencia.core.repository.jpa.NetworkRepository;
import org.lareferencia.contrib.dark.worker.DarkManualRunningContext;
import org.lareferencia.contrib.dark.services.DarkPreviewService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class ApiV5DarkService {
    private static final String NAAN = "ark_naan";
    private final DarkTrackingRepository records;
    private final NetworkRepository networks;
    private final DarkManualCommandLauncher commandLauncher;
    private final DarkManualCommandRegistry commandRegistry;
    private final DarkPreviewService previewService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public ApiV5DarkService(DarkTrackingRepository records, NetworkRepository networks,
            DarkManualCommandLauncher commandLauncher, DarkManualCommandRegistry commandRegistry,
            DarkPreviewService previewService) {
        this.records = records;
        this.networks = networks;
        this.commandLauncher = commandLauncher;
        this.commandRegistry = commandRegistry;
        this.previewService = previewService;
    }

    public Summary summary(String arkNaan) {
        var states = records.countByState(normalize(arkNaan)).stream()
                .map(item -> new StateCount(item.getState().name(), item.getCount())).toList();
        var naans = records.countByNaan().stream().map(item -> new NaanSummary(item.getArkNaan(), item.getCount())).toList();
        var naanStates = records.countByNaanAndState().stream()
                .map(item -> new NaanStateCount(item.getArkNaan(), item.getState().name(), item.getCount())).toList();
        long total = states.stream().mapToLong(StateCount::count).sum();
        return new Summary(total, states, naans, naanStates);
    }

    public ApiV5Dtos.PageResponse<RecordResponse> records(String arkNaan, String state, String q, int page, int size) {
        DarkTrackingState parsed = null;
        if (state != null && !state.isBlank()) {
            try { parsed = DarkTrackingState.valueOf(state.trim().toUpperCase(Locale.ROOT)); }
            catch (IllegalArgumentException e) { throw new ApiV5Exception(HttpStatus.BAD_REQUEST, "DARK_STATE_INVALID", "Unknown dARK state: " + state); }
        }
        String normalizedQuery = normalize(q);
        String queryPattern = normalizedQuery == null ? "" : "%" + normalizedQuery.toLowerCase(Locale.ROOT) + "%";
        Page<DarkTrackingRecord> result = records.search(normalize(arkNaan), parsed,
                normalizedQuery == null ? "" : normalizedQuery, queryPattern, PageRequest.of(page, size));
        Map<Long, String> sourceAcronyms = networks.findAll().stream()
                .collect(java.util.stream.Collectors.toMap(Network::getId, Network::getAcronym, (first, ignored) -> first));
        return new ApiV5Dtos.PageResponse<>(result.getContent().stream().map(item -> record(item, sourceAcronyms)).toList(), page, size,
                result.getTotalElements(), result.getTotalPages());
    }

    public String networkNaan(Long networkId) {
        Network network = network(networkId);
        Object value = network.getAttributes() == null ? null : network.getAttributes().get(NAAN);
        return value == null ? null : String.valueOf(value).trim();
    }

    public ManualCommandResponse launch(String arkNaan, String requestedBy,
            DarkManualRunningContext.Action action, List<String> requestedIds) {
        List<String> oaiIds = selectedOaiIds(requestedIds);
        List<DarkManualCommandLauncher.Selection> selections = sourceSelections(arkNaan, oaiIds,
                action == DarkManualRunningContext.Action.STAGE);
        DarkManualCommandRegistry.CommandStatus command = commandLauncher.launch(selections, requestedBy, action);
        if (command == null) {
            throw new ApiV5Exception(HttpStatus.SERVICE_UNAVAILABLE, "DARK_COMMAND_REJECTED",
                    "The legacy worker queue is full; retry after running commands finish");
        }
        return command(command);
    }

    public PreviewResponse preview(String arkNaan, List<String> requestedIds) {
        List<String> oaiIds = selectedOaiIds(requestedIds);
        List<DarkManualCommandLauncher.Selection> selections = sourceSelections(arkNaan, oaiIds, true);
        List<PreviewItem> items = selections.stream().flatMap(selection ->
                        previewService.preview(selection.network(), selection.sourceSnapshotId(), selection.oaiIds()).stream())
                .map(item -> new PreviewItem(item.oaiId(), item.ark(), item.localState(), item.valid(), item.error(), item.targetUrl(),
                        item.l1Bytes(), item.l2Bytes(), item.payloadBytes(), item.warnings(),
                        item.minimalMetadata() == null ? null : objectMapper.valueToTree(item.minimalMetadata()),
                        item.originalMetadata())).toList();
        return new PreviewResponse(items);
    }

    public ManualCommandResponse command(String commandId) {
        DarkManualCommandRegistry.CommandStatus command = commandRegistry.status(commandId);
        if (command == null) throw new ApiV5Exception(HttpStatus.NOT_FOUND, "DARK_COMMAND_NOT_FOUND",
                "Command " + commandId + " is unknown or its ephemeral status expired");
        return command(command);
    }

    private Network network(Long networkId) {
        return networks.findById(networkId).orElseThrow(() -> new ApiV5Exception(HttpStatus.NOT_FOUND,
                "NETWORK_NOT_FOUND", "Network " + networkId + " was not found"));
    }

    private List<DarkManualCommandLauncher.Selection> sourceSelections(String arkNaan, List<String> oaiIds,
            boolean sourceRequired) {
        String naan = normalize(arkNaan);
        if (naan == null) throw new ApiV5Exception(HttpStatus.BAD_REQUEST, "DARK_NAAN_REQUIRED", "A NAAN is required");
        List<DarkTrackingRecord> selected = records.findByIdArkNaanAndIdOaiIdIn(naan, oaiIds);
        Set<String> found = selected.stream().map(DarkTrackingRecord::getOaiId).collect(java.util.stream.Collectors.toSet());
        List<String> missing = oaiIds.stream().filter(id -> !found.contains(id)).toList();
        if (!missing.isEmpty()) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "DARK_RECORD_NOT_IN_NAAN",
                "Selected OAI identifiers do not belong to NAAN " + naan + ": " + missing);

        Map<Long, Network> networkById = new java.util.HashMap<>();
        for (Network candidate : networks.findAll()) {
            Object candidateNaan = candidate.getAttributes() == null ? null : candidate.getAttributes().get(NAAN);
            if (candidateNaan != null && naan.equals(String.valueOf(candidateNaan).trim())) networkById.put(candidate.getId(), candidate);
        }
        if (!sourceRequired) {
            Network network = networkById.values().stream().findFirst().orElseThrow(() ->
                    new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "DARK_NAAN_NETWORK_MISSING",
                            "No network is configured for NAAN " + naan));
            return List.of(new DarkManualCommandLauncher.Selection(network, null, oaiIds));
        }
        Map<SourceProvenance, List<String>> grouped = new LinkedHashMap<>();
        for (DarkTrackingRecord record : selected) {
            Long sourceNetworkId = record.getSourceNetworkId();
            Network source = sourceNetworkId == null ? null : networkById.get(sourceNetworkId);
            if (source == null || record.getSourceSnapshotId() == null) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY,
                    "SOURCE_NETWORK_MISSING", "Record " + record.getOaiId() + " has no resolvable source network and snapshot");
            grouped.computeIfAbsent(new SourceProvenance(source, record.getSourceSnapshotId()),
                    ignored -> new java.util.ArrayList<>()).add(record.getOaiId());
        }
        return grouped.entrySet().stream().map(entry -> new DarkManualCommandLauncher.Selection(
                entry.getKey().network(), entry.getKey().snapshotId(), List.copyOf(entry.getValue()))).toList();
    }

    private List<String> selectedOaiIds(List<String> requestedIds) {
        if (requestedIds == null || requestedIds.isEmpty()) {
            throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "DARK_SELECTION_REQUIRED",
                    "Select between 1 and 100 OAI identifiers");
        }
        LinkedHashSet<String> distinct = new LinkedHashSet<>();
        for (String value : requestedIds) {
            if (value == null || value.isBlank()) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY,
                    "DARK_SELECTION_INVALID", "OAI identifiers must not be blank");
            distinct.add(value.trim());
        }
        if (distinct.size() > 100) throw new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY,
                "DARK_SELECTION_LIMIT", "A dARK command may include at most 100 records");
        return List.copyOf(distinct);
    }

    private ManualCommandResponse command(DarkManualCommandRegistry.CommandStatus command) {
        return new ManualCommandResponse(command.commandId(), command.state(), command.action(), command.total(),
                command.phase(), command.processed(), command.succeeded(), command.skipped(), command.failed(),
                "/api/v5/dark/commands/" + command.commandId(),
                command.acceptedAt());
    }

    private RecordResponse record(DarkTrackingRecord r, Map<Long, String> sourceAcronyms) {
        return new RecordResponse(r.getArkNaan(), r.getOaiId(), r.getArk(), r.getTargetUrl(), r.getState().name(),
                r.getSourceMetadataHash(), r.getSourceNetworkId(), sourceAcronyms.get(r.getSourceNetworkId()), r.getSourceSnapshotId(), r.getStagePayloadHash(), r.getLastError(), utc(r.getCreatedAt()),
                utc(r.getUpdatedAt()), utc(r.getLastStagedAt()), utc(r.getLastReconciledAt()), utc(r.getPublishedAt()));
    }

    private java.time.OffsetDateTime utc(LocalDateTime value) { return value == null ? null : value.atOffset(ZoneOffset.UTC); }
    private String normalize(String value) { return value == null || value.isBlank() ? null : value.trim(); }
    private record SourceProvenance(Network network, Long snapshotId) { }
}
