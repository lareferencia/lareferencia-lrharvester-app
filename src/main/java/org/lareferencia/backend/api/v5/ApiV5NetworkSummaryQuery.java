package org.lareferencia.backend.api.v5;

import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import org.lareferencia.core.domain.SnapshotIndexStatus;
import org.lareferencia.core.domain.SnapshotStatus;
import org.springframework.http.HttpStatus;

/** PostgreSQL selection of source IDs: all filters and ordering precede pagination. */
final class ApiV5NetworkSummaryQuery {
    record Filters(List<String> harvestStates, List<String> indexStates, String validHarvest, String indexer, boolean failuresOnly) {
        static Filters empty() { return new Filters(null, null, null, null, false); }
    }
    final Map<String, Object> parameters = new HashMap<>();
    final String from = " from network n"
            + " left join lateral (select ns.* from networksnapshot ns where ns.network_id=n.id and ns.deleted=false"
            + " order by ns.starttime desc, ns.id desc limit 1) s on true"
            + " left join lateral (select ns.id, ns.endtime, ns.starttime from networksnapshot ns"
            + " where ns.network_id=n.id and ns.deleted=false and ns.status=" + SnapshotStatus.VALID.ordinal()
            + " order by ns.starttime desc, ns.id desc limit 1) v on true";
    final StringBuilder where = new StringBuilder(" where true");
    final String order;

    ApiV5NetworkSummaryQuery(String sort, String q, String acronym, String name, String institution,
            Boolean published, String snapshotStatus, String indexStatus, List<Long> allowed,
            List<String> tags, String tagMode, Filters filters) {
        like("q", q, "(lower(n.acronym) like :q or lower(n.name) like :q or lower(n.institutionname) like :q)");
        like("acronym", acronym, "lower(n.acronym) like :acronym");
        like("name", name, "lower(n.name) like :name");
        like("institution", institution, "lower(n.institutionname) like :institution");
        if (published != null) add("n.published=:published", "published", published);
        if (allowed != null) {
            if (allowed.isEmpty()) where.append(" and false");
            else add("n.id in (:allowed)", "allowed", allowed);
        }
        if (tagMode != null && !Set.of("all", "any").contains(tagMode)) throw invalid("NETWORK_TAGS_INVALID", "tagMode must be all or any");
        List<String> normalizedTags = ApiV5NetworkTags.normalize(tags);
        if (!normalizedTags.isEmpty()) {
            if ("any".equals(tagMode)) add("exists (select 1 from network_tag t where t.network_id=n.id and t.tag in (:tags))", "tags", normalizedTags);
            else for (int i=0; i<normalizedTags.size(); i++) add("exists (select 1 from network_tag t where t.network_id=n.id and t.tag=:tag" + i + ")", "tag"+i, normalizedTags.get(i));
        }
        if (snapshotStatus != null && !snapshotStatus.isBlank()) add("s.status=:snapshotStatus", "snapshotStatus", parse(SnapshotStatus.class, snapshotStatus).ordinal());
        String index = "case s.indexstatus when " + SnapshotIndexStatus.FAILED.ordinal() + " then 'FAILED' when "
                + SnapshotIndexStatus.INDEXED.ordinal() + " then 'INDEXED' else 'UNKNOWN' end";
        String globalIndex = index;
        if (filters.indexer() != null && !filters.indexer().isBlank()) {
            if (filters.indexer().length()>200) throw invalid("INDEXER_INVALID", "Indexer name is too long");
            parameters.put("indexer", filters.indexer());
            index = "coalesce(jsonb_extract_path_text(s.indexing_results, 'results', :indexer, 'status'), 'UNKNOWN')";
        }
        if (indexStatus != null && !indexStatus.isBlank()) add(index+"=:indexStatus", "indexStatus", parse(SnapshotIndexStatus.class,indexStatus).name());
        if (filters.harvestStates()!=null && !filters.harvestStates().isEmpty()) {
            if (filters.harvestStates().size()>20) throw invalid("HARVEST_STATE_INVALID", "Too many harvest states");
            where.append(" and (").append(String.join(" or ", filters.harvestStates().stream().map(this::harvestState).toList())).append(")");
        }
        if (filters.indexStates()!=null && !filters.indexStates().isEmpty()) {
            if (filters.indexStates().size()>20) throw invalid("INDEX_STATUS_INVALID", "Too many index states");
            List<String> states=filters.indexStates().stream().map(value -> parse(SnapshotIndexStatus.class,value).name()).distinct().toList();
            add(index+" in (:indexStates)", "indexStates", states);
        }
        if (filters.validHarvest()!=null && !filters.validHarvest().isBlank()) where.append(" and ").append(switch (filters.validHarvest()) {
            case "latest" -> "v.id=s.id";
            case "previous" -> "v.id is not null and v.id<>s.id";
            case "none" -> "v.id is null";
            case "any" -> "v.id is not null";
            default -> throw invalid("VALID_HARVEST_INVALID", "Unknown valid harvest selection");
        });
        String harvestFailure="s.status="+SnapshotStatus.HARVESTING_FINISHED_ERROR.ordinal();
        String indexFailure="("+globalIndex+"='FAILED' or s.status="+SnapshotStatus.INDEXING_FINISHED_ERROR.ordinal()+")";
        if (filters.failuresOnly()) where.append(" and (").append(harvestFailure).append(" or ").append(indexFailure).append(")");
        String[] sorting = (sort == null || sort.isBlank() ? "acronym,asc" : sort).split(",",-1);
        if (sorting.length>2 || sorting.length==0) throw invalid("SORT_INVALID", "Use field,asc or field,desc");
        String direction=sorting.length==2 ? sorting[1].toLowerCase(Locale.ROOT) : "asc";
        if (!Set.of("asc","desc").contains(direction)) throw invalid("SORT_INVALID", "Use asc or desc");
        String expression = switch (sorting[0]) {
            case "id" -> "n.id";
            case "acronym" -> "lower(n.acronym)";
            case "name" -> "lower(n.name)";
            case "institutionName" -> "lower(n.institutionname)";
            case "published" -> "n.published";
            case "tags" -> "(select array_agg(t.tag order by t.tag) from network_tag t where t.network_id=n.id)";
            case "latestSnapshot" -> "coalesce(s.endtime, s.starttime)";
            case "lastValidSnapshot" -> "coalesce(v.endtime, v.starttime)";
            case "indexStatus" -> "case when "+index+"='FAILED' then 0 when "+index+"='UNKNOWN' then 1 else 2 end";
            case "snapshotStatus" -> snapshotOrder();
            case "attention" -> "case when "+harvestFailure+" and v.id is null then 0 when "+harvestFailure+" then 1 when "+indexFailure
                    + " then 2 when s.status="+SnapshotStatus.HARVESTING_STOPPED.ordinal()+" then 3 when v.id is null then 4 else 5 end";
            default -> throw invalid("SORT_INVALID", "Unsupported source sort field");
        };
        order=" order by "+expression+" "+direction+" nulls last, lower(n.acronym) asc, n.id asc";
    }
    private static String snapshotOrder() {
        List<SnapshotStatus> states = List.of(SnapshotStatus.HARVESTING_FINISHED_ERROR,
                SnapshotStatus.INDEXING_FINISHED_ERROR, SnapshotStatus.HARVESTING_STOPPED,
                SnapshotStatus.RETRYING, SnapshotStatus.HARVESTING, SnapshotStatus.INDEXING,
                SnapshotStatus.INITIALIZED, SnapshotStatus.UNKNOWN, SnapshotStatus.HARVESTING_FINISHED_VALID,
                SnapshotStatus.EMPTY_INCREMENTAL, SnapshotStatus.VALID, SnapshotStatus.INDEXING_FINISHED_VALID);
        StringBuilder result = new StringBuilder("case s.status");
        for (int i=0; i<states.size(); i++) result.append(" when ").append(states.get(i).ordinal()).append(" then ").append(i);
        return result.append(" else ").append(states.size()).append(" end").toString();
    }
    private String harvestState(String value) {
        return switch(value) {
            case "valid" -> "s.status="+SnapshotStatus.VALID.ordinal();
            case "error" -> "s.status="+SnapshotStatus.HARVESTING_FINISHED_ERROR.ordinal();
            case "running" -> "s.status in ("+SnapshotStatus.HARVESTING.ordinal()+","+SnapshotStatus.RETRYING.ordinal()+")";
            case "stopped" -> "s.status="+SnapshotStatus.HARVESTING_STOPPED.ordinal();
            case "finished" -> "s.status="+SnapshotStatus.HARVESTING_FINISHED_VALID.ordinal();
            case "none" -> "s.id is null";
            default -> "s.status="+parse(SnapshotStatus.class,value).ordinal();
        };
    }
    private void like(String key,String value,String condition) {
        if (value!=null && !value.isBlank()) add(condition,key,"%"+value.trim().toLowerCase(Locale.ROOT)+"%");
    }
    private void add(String condition,String key,Object value) { where.append(" and ").append(condition); parameters.put(key,value); }
    private static <E extends Enum<E>> E parse(Class<E> type,String value) {
        try { return Enum.valueOf(type,value.toUpperCase(Locale.ROOT)); }
        catch (IllegalArgumentException error) { throw invalid(type == SnapshotStatus.class ? "SNAPSHOT_STATUS_INVALID" : "INDEX_STATUS_INVALID", "Unknown "+type.getSimpleName()+" value"); }
    }
    private static ApiV5Exception invalid(String code,String message) { return new ApiV5Exception(HttpStatus.BAD_REQUEST,code,message); }
}
