package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5DarkDtos.*;

import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Locale;

import org.lareferencia.contrib.dark.domain.DarkTrackingRecord;
import org.lareferencia.contrib.dark.domain.DarkTrackingState;
import org.lareferencia.contrib.dark.repositories.DarkTrackingRepository;
import org.lareferencia.core.domain.Network;
import org.lareferencia.core.repository.jpa.NetworkRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class ApiV5DarkService {
    private static final String NAAN = "ark_naan";
    private final DarkTrackingRepository records;
    private final NetworkRepository networks;

    public ApiV5DarkService(DarkTrackingRepository records, NetworkRepository networks) {
        this.records = records;
        this.networks = networks;
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
        return new ApiV5Dtos.PageResponse<>(result.getContent().stream().map(this::record).toList(), page, size,
                result.getTotalElements(), result.getTotalPages());
    }

    public String networkNaan(Long networkId) {
        Network network = networks.findById(networkId).orElseThrow(() -> new ApiV5Exception(HttpStatus.NOT_FOUND,
                "NETWORK_NOT_FOUND", "Network " + networkId + " was not found"));
        Object value = network.getAttributes() == null ? null : network.getAttributes().get(NAAN);
        return value == null ? null : String.valueOf(value).trim();
    }

    private RecordResponse record(DarkTrackingRecord r) {
        return new RecordResponse(r.getArkNaan(), r.getOaiId(), r.getArk(), r.getTargetUrl(), r.getState().name(),
                r.getSourceMetadataHash(), r.getStagePayloadHash(), r.getLastError(), utc(r.getCreatedAt()),
                utc(r.getUpdatedAt()), utc(r.getLastStagedAt()), utc(r.getLastReconciledAt()), utc(r.getPublishedAt()));
    }

    private java.time.OffsetDateTime utc(LocalDateTime value) { return value == null ? null : value.atOffset(ZoneOffset.UTC); }
    private String normalize(String value) { return value == null || value.isBlank() ? null : value.trim(); }
}
