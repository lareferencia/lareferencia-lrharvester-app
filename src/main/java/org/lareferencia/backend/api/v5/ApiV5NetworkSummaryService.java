package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5Dtos.*;

import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import org.lareferencia.core.domain.Network;
import org.lareferencia.core.domain.NetworkSnapshot;
import org.lareferencia.core.domain.SnapshotIndexStatus;
import org.lareferencia.core.domain.SnapshotStatus;
import org.lareferencia.core.task.NetworkActionkManager;
import org.lareferencia.core.worker.NetworkRunningContext;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;

@Service
public class ApiV5NetworkSummaryService {
    private static final Set<String> SORT_FIELDS = Set.of("id", "acronym", "name", "institutionName", "published");

    private final EntityManager entityManager;
    private final NetworkActionkManager actions;

    public ApiV5NetworkSummaryService(EntityManager entityManager, NetworkActionkManager actions) {
        this.entityManager = entityManager;
        this.actions = actions;
    }

    @Transactional(readOnly = true)
    public PageResponse<NetworkSummaryResponse> list(int page, int size, String sort, String q, String acronym,
            String name, String institutionName, Boolean published, String snapshotStatus, String indexStatus) {
        SortSelection sorting = sort(sort);
        SnapshotStatus parsedSnapshotStatus = enumValue(SnapshotStatus.class, snapshotStatus, "SNAPSHOT_STATUS_INVALID");
        SnapshotIndexStatus parsedIndexStatus = enumValue(SnapshotIndexStatus.class, indexStatus, "INDEX_STATUS_INVALID");

        QueryParts parts = queryParts(q, acronym, name, institutionName, published, parsedSnapshotStatus, parsedIndexStatus);
        TypedQuery<Network> query = entityManager.createQuery(
                "select n from Network n" + parts.where() + " order by n." + sorting.field() + " " + sorting.direction(),
                Network.class);
        TypedQuery<Long> count = entityManager.createQuery("select count(n) from Network n" + parts.where(), Long.class);
        parts.parameters().forEach((key, value) -> { query.setParameter(key, value); count.setParameter(key, value); });
        query.setFirstResult(page * size).setMaxResults(size);

        List<Network> networks = query.getResultList();
        long total = count.getSingleResult();
        Map<Long, NetworkSnapshot> latest = latestSnapshots(networks, false);
        Map<Long, NetworkSnapshot> lastValid = latestSnapshots(networks, true);
        List<NetworkSummaryResponse> items = networks.stream()
                .map(network -> response(network, latest.get(network.getId()), lastValid.get(network.getId())))
                .toList();
        return new PageResponse<>(items, page, size, total, (int) Math.ceil((double) total / size));
    }

    private QueryParts queryParts(String q, String acronym, String name, String institutionName, Boolean published,
            SnapshotStatus snapshotStatus, SnapshotIndexStatus indexStatus) {
        StringBuilder where = new StringBuilder(" where 1=1");
        Map<String, Object> parameters = new HashMap<>();
        like(where, parameters, "q", q,
                " and (lower(cast(n.acronym as string)) like :q or lower(cast(n.name as string)) like :q or lower(cast(n.institutionName as string)) like :q)");
        like(where, parameters, "acronym", acronym, " and lower(cast(n.acronym as string)) like :acronym");
        like(where, parameters, "name", name, " and lower(cast(n.name as string)) like :name");
        like(where, parameters, "institutionName", institutionName,
                " and lower(cast(n.institutionName as string)) like :institutionName");
        if (published != null) { where.append(" and n.published = :published"); parameters.put("published", published); }
        if (snapshotStatus != null || indexStatus != null) {
            where.append(" and exists (select 1 from NetworkSnapshot ns where ns.network.id=n.id and ns.deleted=false")
                    .append(" and ns.startTime=(select max(last.startTime) from NetworkSnapshot last where last.network.id=n.id and last.deleted=false)");
            if (snapshotStatus != null) { where.append(" and ns.status=:snapshotStatus"); parameters.put("snapshotStatus", snapshotStatus); }
            if (indexStatus != null) { where.append(" and ns.indexStatus=:indexStatus"); parameters.put("indexStatus", indexStatus); }
            where.append(")");
        }
        return new QueryParts(where.toString(), parameters);
    }

    private Map<Long, NetworkSnapshot> latestSnapshots(List<Network> networks, boolean validOnly) {
        if (networks.isEmpty()) return Map.of();
        List<Long> ids = networks.stream().map(Network::getId).toList();
        String status = validOnly ? " and ns.status=:validStatus" : "";
        String jpql = "select ns from NetworkSnapshot ns where ns.network.id in :ids and ns.deleted=false" + status
                + " and ns.startTime=(select max(last.startTime) from NetworkSnapshot last where last.network.id=ns.network.id and last.deleted=false"
                + (validOnly ? " and last.status=:validStatus" : "") + ")";
        TypedQuery<NetworkSnapshot> query = entityManager.createQuery(jpql, NetworkSnapshot.class).setParameter("ids", ids);
        if (validOnly) query.setParameter("validStatus", SnapshotStatus.VALID);
        Map<Long, NetworkSnapshot> result = new HashMap<>();
        query.getResultList().forEach(snapshot -> result.put(snapshot.getNetwork().getId(), snapshot));
        return result;
    }

    private NetworkSummaryResponse response(Network network, NetworkSnapshot latest, NetworkSnapshot valid) {
        String context = NetworkRunningContext.buildID(network);
        List<String> running = actions.getRunningTasksByRunningContextID(context);
        List<String> queued = actions.getQueuedTasksByRunningContextID(context);
        List<String> scheduled = actions.getScheduledTasksByRunningContextID(context);
        RuntimeStateResponse runtime = new RuntimeStateResponse(running.size(), queued.size(), scheduled.size(),
                List.copyOf(running), List.copyOf(queued), List.copyOf(scheduled));
        return new NetworkSummaryResponse(network.getId(), Boolean.TRUE.equals(network.getPublished()),
                network.getAcronym(), network.getName(), network.getInstitutionName(), network.getInstitutionAcronym(),
                latest == null ? null : snapshot(latest), valid == null ? null : valid.getId(),
                valid == null ? null : utc(valid.getEndTime()), runtime);
    }

    private SnapshotResponse snapshot(NetworkSnapshot snapshot) {
        return new SnapshotResponse(snapshot.getId(), snapshot.getNetwork() == null ? null : snapshot.getNetwork().getId(),
                snapshot.getPreviousSnapshotId(), snapshot.getStatus().name(), snapshot.getIndexStatus().name(),
                utc(snapshot.getStartTime()), utc(snapshot.getLastIncrementalTime()), utc(snapshot.getEndTime()),
                snapshot.getSize(), snapshot.getValidSize(), snapshot.getTransformedSize(), snapshot.isDeleted());
    }

    private void like(StringBuilder where, Map<String, Object> parameters, String key, String value, String clause) {
        if (value != null && !value.isBlank()) {
            where.append(clause);
            parameters.put(key, "%" + value.trim().toLowerCase(Locale.ROOT) + "%");
        }
    }

    private SortSelection sort(String value) {
        String[] parts = value == null || value.isBlank() ? new String[] { "id", "asc" } : value.split(",", -1);
        String field = parts[0];
        String direction = parts.length > 1 ? parts[1].toLowerCase(Locale.ROOT) : "asc";
        if (!SORT_FIELDS.contains(field) || !("asc".equals(direction) || "desc".equals(direction))) {
            throw new ApiV5Exception(HttpStatus.BAD_REQUEST, "SORT_INVALID",
                    "sort must use id, acronym, name, institutionName or published and asc/desc");
        }
        return new SortSelection(field, direction);
    }

    private <E extends Enum<E>> E enumValue(Class<E> type, String value, String code) {
        if (value == null || value.isBlank()) return null;
        try { return Enum.valueOf(type, value.toUpperCase(Locale.ROOT)); }
        catch (IllegalArgumentException exception) {
            throw new ApiV5Exception(HttpStatus.BAD_REQUEST, code, "Unknown " + type.getSimpleName() + " value");
        }
    }

    static OffsetDateTime utc(LocalDateTime value) { return value == null ? null : value.atOffset(ZoneOffset.UTC); }

    private record QueryParts(String where, Map<String, Object> parameters) {}
    private record SortSelection(String field, String direction) {}
}
