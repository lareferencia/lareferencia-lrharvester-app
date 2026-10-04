package org.lareferencia.backend.api.v5;

import static org.lareferencia.backend.api.v5.ApiV5Dtos.*;

import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.lareferencia.core.domain.Network;
import org.lareferencia.core.domain.NetworkSnapshot;
import org.lareferencia.core.domain.SnapshotStatus;
import org.lareferencia.core.task.NetworkActionkManager;
import org.lareferencia.core.worker.NetworkRunningContext;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.lareferencia.core.worker.indexing.BaseIndexerWorker;

import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;

@Service
public class ApiV5NetworkSummaryService {

    private final EntityManager entityManager;
    private final NetworkActionkManager actions;

    public ApiV5NetworkSummaryService(EntityManager entityManager, NetworkActionkManager actions) {
        this.entityManager = entityManager;
        this.actions = actions;
    }

    @Transactional(readOnly = true, isolation = Isolation.REPEATABLE_READ)
    public PageResponse<NetworkSummaryResponse> list(int page, int size, String sort, String q, String acronym,
            String name, String institutionName, Boolean published, String snapshotStatus, String indexStatus) {
        return list(page, size, sort, q, acronym, name, institutionName, published, snapshotStatus, indexStatus, null);
    }

    @Transactional(readOnly = true, isolation = Isolation.REPEATABLE_READ)
    public PageResponse<NetworkSummaryResponse> list(int page, int size, String sort, String q, String acronym,
            String name, String institutionName, Boolean published, String snapshotStatus, String indexStatus,
            List<Long> allowedNetworkIds) {
        return list(page, size, sort, q, acronym, name, institutionName, published, snapshotStatus, indexStatus, allowedNetworkIds, null, null);
    }

    @Transactional(readOnly = true, isolation = Isolation.REPEATABLE_READ)
    public PageResponse<NetworkSummaryResponse> list(int page, int size, String sort, String q, String acronym,
            String name, String institutionName, Boolean published, String snapshotStatus, String indexStatus,
            List<Long> allowedNetworkIds, List<String> tags, String tagMode) {
        return list(page, size, sort, q, acronym, name, institutionName, published, snapshotStatus, indexStatus,
                allowedNetworkIds, tags, tagMode, ApiV5NetworkSummaryQuery.Filters.empty());
    }

    @Transactional(readOnly = true, isolation = Isolation.REPEATABLE_READ)
    public PageResponse<NetworkSummaryResponse> list(int page, int size, String sort, String q, String acronym,
            String name, String institutionName, Boolean published, String snapshotStatus, String indexStatus,
            List<Long> allowedNetworkIds, List<String> tags, String tagMode, ApiV5NetworkSummaryQuery.Filters filters) {
        var selection = new ApiV5NetworkSummaryQuery(sort, q, acronym, name, institutionName, published,
                snapshotStatus, indexStatus, allowedNetworkIds, tags, tagMode, filters);
        var rows = entityManager.createNativeQuery("select n.id" + selection.from + selection.where + selection.order);
        var count = entityManager.createNativeQuery("select count(*)" + selection.from + selection.where);
        // An indexer can occur only in ORDER BY; bind it only to queries that use it.
        selection.parameters.forEach((key, value) -> {
            if (rows.getParameters().stream().anyMatch(parameter -> key.equals(parameter.getName()))) rows.setParameter(key, value);
            if (count.getParameters().stream().anyMatch(parameter -> key.equals(parameter.getName()))) count.setParameter(key, value);
        });
        List<?> rawIds = rows.setFirstResult(page * size).setMaxResults(size).getResultList();
        List<Long> ids = rawIds.stream().map(value -> ((Number) value).longValue()).toList();
        long total = ((Number) count.getSingleResult()).longValue();
        if (ids.isEmpty()) return new PageResponse<>(List.of(), page, size, total, (int) Math.ceil((double) total / size));
        Map<Long, Network> byId = new HashMap<>();
        entityManager.createQuery("select n from Network n where n.id in :ids", Network.class)
                .setParameter("ids", ids).getResultList().forEach(network -> byId.put(network.getId(), network));
        List<Network> networks = ids.stream().map(byId::get).toList();
        Map<Long, NetworkSnapshot> latest = latestSnapshots(networks, false);
        Map<Long, NetworkSnapshot> lastValid = latestSnapshots(networks, true);
        List<NetworkSummaryResponse> items = networks.stream()
                .map(network -> response(network, latest.get(network.getId()), lastValid.get(network.getId()))).toList();
        return new PageResponse<>(items, page, size, total, (int) Math.ceil((double) total / size));
    }

    @Autowired
    private ApplicationContext applicationContext;

    @Transactional(readOnly = true, isolation = Isolation.REPEATABLE_READ)
    public List<String> indexers(List<Long> allowedNetworkIds) {
        var names = new java.util.TreeSet<String>();
        java.util.Collections.addAll(names, applicationContext.getBeanNamesForType(
                BaseIndexerWorker.class, true, false));
        if (allowedNetworkIds != null && allowedNetworkIds.isEmpty()) return List.copyOf(names);
        var query = entityManager.createNativeQuery("select distinct keys.name from networksnapshot ns"
                + " cross join lateral jsonb_object_keys(coalesce(ns.indexing_results->'results', cast('{}' as jsonb))) keys(name)"
                + (allowedNetworkIds == null ? "" : " where ns.network_id in (:allowed)"));
        if (allowedNetworkIds != null) query.setParameter("allowed", allowedNetworkIds);
        query.getResultList().forEach(value -> names.add(value.toString()));
        return List.copyOf(names);
    }

    private Map<Long, NetworkSnapshot> latestSnapshots(List<Network> networks, boolean validOnly) {
        if (networks.isEmpty()) return Map.of();
        List<Long> ids = networks.stream().map(Network::getId).toList();
        String status = validOnly ? " and ns.status=:validStatus" : "";
        String jpql = "select ns from NetworkSnapshot ns where ns.network.id in :ids and ns.deleted=false" + status
                + " and not exists (select 1 from NetworkSnapshot last where last.network.id=ns.network.id and last.deleted=false"
                + (validOnly ? " and last.status=:validStatus" : "")
                + " and (last.startTime>ns.startTime or (last.startTime=ns.startTime and last.id>ns.id)))";
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
                valid == null ? null : utc(valid.getEndTime()), runtime, network.getTags().stream().sorted().toList());
    }

    private SnapshotResponse snapshot(NetworkSnapshot snapshot) {
        return new SnapshotResponse(snapshot.getId(), snapshot.getNetwork() == null ? null : snapshot.getNetwork().getId(),
                snapshot.getPreviousSnapshotId(), snapshot.getStatus().name(), snapshot.getIndexStatus().name(),
                utc(snapshot.getStartTime()), utc(snapshot.getLastIncrementalTime()), utc(snapshot.getEndTime()),
                snapshot.getSize(), snapshot.getValidSize(), snapshot.getTransformedSize(), snapshot.isDeleted(),
                snapshot.getIndexingResults().results());
    }

    static OffsetDateTime utc(LocalDateTime value) { return value == null ? null : value.atOffset(ZoneOffset.UTC); }
}
