package org.lareferencia.backend.api.v5;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.lareferencia.backend.security.LocalAuthorizationService;
import org.lareferencia.core.domain.Network;
import org.lareferencia.core.domain.NetworkSnapshot;
import org.lareferencia.core.domain.SnapshotStatus;
import org.lareferencia.core.repository.jpa.NetworkRepository;
import org.lareferencia.core.repository.jpa.NetworkSnapshotRepository;
import org.lareferencia.core.service.validation.IValidationStatisticsService;
import org.lareferencia.core.service.validation.OccurrenceCount;
import org.lareferencia.core.service.validation.ValidationStatObservation;
import org.lareferencia.core.service.validation.ValidationStatsObservationsResult;
import org.lareferencia.core.service.validation.ValidationStatsResult;
import org.lareferencia.core.util.date.DateHelper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** Read-only v2 dashboard response shapes, isolated from the native v5 API. */
@RestController
@RequestMapping("/api/v5/dashboard")
public class ApiV5DashboardCompatibilityController {
    private static final Logger log = LoggerFactory.getLogger(ApiV5DashboardCompatibilityController.class);
    private final NetworkRepository networks;
    private final NetworkSnapshotRepository snapshots;
    private final IValidationStatisticsService statistics;
    private final LocalAuthorizationService authorization;
    private final DateHelper dates;

    public ApiV5DashboardCompatibilityController(NetworkRepository networks, NetworkSnapshotRepository snapshots,
            IValidationStatisticsService statistics, LocalAuthorizationService authorization, DateHelper dates) {
        this.networks = networks;
        this.snapshots = snapshots;
        this.statistics = statistics;
        this.authorization = authorization;
        this.dates = dates;
    }

    @GetMapping("/harvesting/source/list")
    public Page<Source> sources(Pageable pageable, Authentication authentication) {
        authorization.requireDashboardAccess(authentication);
        List<Long> allowed = authorization.readableNetworkIds(authentication);
        if (allowed.isEmpty()) return Page.empty(pageable);
        return networks.findByIdIn(allowed, pageable).map(Source::new);
    }

    @GetMapping("/harvesting/source/{acronym}")
    public Source source(@PathVariable String acronym, Authentication authentication) {
        return new Source(network(acronym, authentication));
    }

    @GetMapping("/harvesting/source/{acronym}/history")
    public Page<Harvest> history(@PathVariable String acronym, Pageable pageable, Authentication authentication) {
        return snapshots.findByNetworkAndStatus(network(acronym, authentication), SnapshotStatus.VALID,
                historyPage(pageable)).map(Harvest::new);
    }

    @GetMapping("/harvesting/source/{acronym}/history/{startDate}/{endDate}")
    public Page<Harvest> historyBetween(@PathVariable String acronym, @PathVariable String startDate,
            @PathVariable String endDate, Pageable pageable, Authentication authentication) {
        Network network = network(acronym, authentication);
        LocalDateTime from;
        LocalDateTime to;
        try {
            from = dates.parseDate(startDate).toLocalDate().atStartOfDay();
            to = dates.parseDate(endDate).toLocalDate().atTime(LocalTime.MAX);
        } catch (RuntimeException exception) {
            throw new ApiV5Exception(HttpStatus.BAD_REQUEST, "INVALID_DATE", "Invalid history date range");
        }
        return snapshots.findByNetworkAndStatusAndEndTimeBetween(network, SnapshotStatus.VALID,
                from, to, historyPage(pageable)).map(Harvest::new);
    }

    @GetMapping("/harvesting/source/{acronym}/lkg")
    public Harvest lastGood(@PathVariable String acronym, Authentication authentication) {
        NetworkSnapshot snapshot = snapshots.findLastGoodKnowByNetworkID(network(acronym, authentication).getId());
        if (snapshot == null) throw new ApiV5Exception(HttpStatus.NOT_FOUND, "SNAPSHOT_NOT_FOUND", "No valid snapshot was found");
        return new Harvest(snapshot);
    }

    @GetMapping("/validation/source/{acronym}/{snapshotId}")
    public ValidationStatsResult summary(@PathVariable String acronym, @PathVariable Long snapshotId,
            Authentication authentication) {
        NetworkSnapshot snapshot = snapshot(acronym, snapshotId, authentication);
        try {
            return statistics.queryValidatorRulesStatsBySnapshot(snapshot, List.of());
        } catch (Exception exception) {
            throw diagnosticFailure(exception);
        }
    }

    @GetMapping("/validation/source/stats/{acronym}/{snapshotId}/query")
    public ValidationStatsObservationsResult query(@PathVariable String acronym, @PathVariable Long snapshotId,
            @RequestParam(required = false) List<String> filters,
            @RequestParam(defaultValue = "0") int pageNumber, @RequestParam(defaultValue = "20") int pageSize,
            Authentication authentication) {
        snapshot(acronym, snapshotId, authentication);
        try {
            return statistics.queryValidationStatsObservationsBySnapshotID(snapshotId,
                    filters == null ? List.of() : filters, page(pageNumber, pageSize));
        } catch (Exception exception) {
            throw diagnosticFailure(exception);
        }
    }

    @GetMapping("/validation/source/{acronym}/{snapshotId}/records")
    public Page<Record> records(@PathVariable String acronym, @PathVariable Long snapshotId,
            @RequestParam(name = "is_valid", required = false) Boolean valid,
            @RequestParam(name = "is_transformed", required = false) Boolean transformed,
            @RequestParam(name = "valid_rules", required = false) List<String> validRules,
            @RequestParam(name = "invalid_rules", required = false) List<String> invalidRules,
            @RequestParam(name = "oai_identifier", required = false) String identifier,
            @RequestParam(defaultValue = "0") int pageNumber, @RequestParam(defaultValue = "20") int pageSize,
            Authentication authentication) {
        snapshot(acronym, snapshotId, authentication);
        Pageable pageable = page(pageNumber, pageSize);
        List<String> filters = new ArrayList<>();
        if (identifier != null) filters.add("identifier@@" + identifier);
        if (valid != null) filters.add("isValid@@" + valid);
        if (transformed != null) filters.add("isTransformed@@" + transformed);
        if (validRules != null) validRules.forEach(id -> filters.add("validRulesID@@" + id));
        if (invalidRules != null) invalidRules.forEach(id -> filters.add("invalidRulesID@@" + id));
        try {
            ValidationStatsObservationsResult result = statistics.queryValidationStatsObservationsBySnapshotID(
                    snapshotId, filters, pageable);
            return new PageImpl<>(result.getContent().stream().map(Record::new).toList(), pageable,
                    result.getTotalElements());
        } catch (Exception exception) {
            throw diagnosticFailure(exception);
        }
    }

    @GetMapping("/validation/source/{acronym}/{snapshotId}/valid_occrs/{ruleId}")
    public List<ValueCount> validOccurrences(@PathVariable String acronym, @PathVariable Long snapshotId,
            @PathVariable Long ruleId, Authentication authentication) {
        return occurrences(acronym, snapshotId, ruleId, authentication, true);
    }

    @GetMapping("/validation/source/{acronym}/{snapshotId}/invalid_occrs/{ruleId}")
    public List<ValueCount> invalidOccurrences(@PathVariable String acronym, @PathVariable Long snapshotId,
            @PathVariable Long ruleId, Authentication authentication) {
        return occurrences(acronym, snapshotId, ruleId, authentication, false);
    }

    private List<ValueCount> occurrences(String acronym, Long snapshotId, Long ruleId,
            Authentication authentication, boolean valid) {
        snapshot(acronym, snapshotId, authentication);
        try {
            var result = statistics.queryValidRuleOccurrencesCountBySnapshotID(snapshotId, ruleId, List.of());
            List<OccurrenceCount> items = valid ? result.getValidRuleOccrs() : result.getInvalidRuleOccrs();
            return items == null ? List.of() : items.stream().map(item -> new ValueCount(item.getValue(), item.getCount())).toList();
        } catch (Exception exception) {
            throw diagnosticFailure(exception);
        }
    }

    private Network network(String acronym, Authentication authentication) {
        authorization.requireDashboardAccess(authentication);
        Network network = networks.findByAcronym(acronym);
        if (network == null) throw new ApiV5Exception(HttpStatus.NOT_FOUND, "NETWORK_NOT_FOUND", "Network was not found");
        authorization.requireNetworkRead(authentication, network.getId());
        return network;
    }

    private NetworkSnapshot snapshot(String acronym, Long snapshotId, Authentication authentication) {
        authorization.requireDashboardAccess(authentication);
        authorization.requireSnapshotRead(authentication, snapshotId);
        NetworkSnapshot snapshot = snapshots.findById(snapshotId).orElseThrow(() ->
                new ApiV5Exception(HttpStatus.NOT_FOUND, "SNAPSHOT_NOT_FOUND", "Snapshot was not found"));
        if (!snapshot.getNetwork().getAcronym().equals(acronym))
            throw new ApiV5Exception(HttpStatus.NOT_FOUND, "SNAPSHOT_NOT_FOUND", "Snapshot was not found for this network");
        return snapshot;
    }

    private Pageable historyPage(Pageable pageable) {
        return pageable.getSort().isSorted() ? pageable
                : PageRequest.of(pageable.getPageNumber(), pageable.getPageSize(), Sort.by("endTime").descending());
    }

    private Pageable page(int number, int size) {
        if (number < 0 || size < 1 || size > 1000)
            throw new ApiV5Exception(HttpStatus.BAD_REQUEST, "INVALID_PAGE", "Invalid page number or size");
        return PageRequest.of(number, size);
    }

    private ApiV5Exception diagnosticFailure(Exception exception) {
        log.error("Dashboard diagnostic query failed", exception);
        return new ApiV5Exception(HttpStatus.UNPROCESSABLE_ENTITY, "DIAGNOSTIC_QUERY_FAILED", "Dashboard diagnostic query failed");
    }

    public record Source(Long id, String name, String acronym, String institutionName,
            String institutionAcronym, Map<String, Object> attributes, @JsonProperty("public") Boolean isPublic) {
        Source(Network network) {
            this(network.getId(), network.getName(), network.getAcronym(), network.getInstitutionName(),
                    network.getInstitutionAcronym(), network.getAttributes() == null ? Map.of() : network.getAttributes(),
                    network.getPublished());
        }
    }

    public record Harvest(Long id, LocalDateTime startTime, LocalDateTime endTime, String status,
            Integer harvestedSize, Integer validSize, Integer transformedSize, @JsonProperty("deleted") Boolean isDeleted) {
        Harvest(NetworkSnapshot snapshot) {
            this(snapshot.getId(), snapshot.getStartTime(), snapshot.getEndTime(), snapshot.getStatus().toString(),
                    snapshot.getSize(), snapshot.getValidSize(), snapshot.getTransformedSize(), snapshot.isDeleted());
        }
    }

    public record Record(String id, String identifier, Long snapshotID, String origin, String setSpec,
            String metadataPrefix, Boolean isValid, Boolean isTransformed,
            Map<String, List<String>> validOccurrencesByRuleID,
            Map<String, List<String>> invalidOccurrencesByRuleID,
            List<String> validRulesID, List<String> invalidRulesID) {
        Record(ValidationStatObservation item) {
            this(item.getId(), item.getIdentifier(), item.getSnapshotId(), item.getOrigin(), item.getSetSpec(),
                    item.getMetadataPrefix(), item.getIsValid(), item.getIsTransformed(),
                    item.getValidOccurrencesByRuleID(), item.getInvalidOccurrencesByRuleID(),
                    item.getValidRulesIDList(), item.getInvalidRulesIDList());
        }
    }

    public record ValueCount(String value, Integer count) {}
}
