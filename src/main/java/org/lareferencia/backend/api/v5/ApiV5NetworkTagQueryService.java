package org.lareferencia.backend.api.v5;

import java.util.List;
import java.util.HashMap;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import jakarta.persistence.EntityManager;
import org.lareferencia.core.domain.Network;
import static org.lareferencia.backend.api.v5.ApiV5Dtos.*;

@Service
public class ApiV5NetworkTagQueryService {
    private final EntityManager em;
    private final ApiV5ManagementService management;
    public ApiV5NetworkTagQueryService(EntityManager em, ApiV5ManagementService management) {
        this.em = em; this.management = management;
    }
    @Transactional(readOnly = true)
    public PageResponse<NetworkResponse> list(int page, int size, List<Long> allowed, List<String> tags, String mode) {
        StringBuilder where = new StringBuilder(" where 1=1");
        var parameters = new HashMap<String, Object>();
        ApiV5NetworkTags.filter(where, parameters, tags, mode);
        if (allowed != null && allowed.isEmpty()) return new PageResponse<>(List.of(), page, size, 0, 0);
        if (allowed != null) { where.append(" and n.id in :allowed"); parameters.put("allowed", allowed); }
        var rows = em.createQuery("select n from Network n" + where + " order by n.id", Network.class);
        var count = em.createQuery("select count(n) from Network n" + where, Long.class);
        parameters.forEach((key, value) -> { rows.setParameter(key, value); count.setParameter(key, value); });
        long total = count.getSingleResult();
        var items = rows.setFirstResult(page * size).setMaxResults(size).getResultList().stream()
                .map(n -> management.networkResponse(n)).toList();
        return new PageResponse<>(items, page, size, total, (int) Math.ceil((double) total / size));
    }
    @Transactional(readOnly = true)
    public List<String> vocabulary(List<Long> allowed) {
        if (allowed != null && allowed.isEmpty()) return List.of();
        var query = em.createQuery("select distinct t from Network n join n.tags t"
                + (allowed == null ? "" : " where n.id in :allowed") + " order by t", String.class);
        if (allowed != null) query.setParameter("allowed", allowed);
        return query.getResultList();
    }
}
