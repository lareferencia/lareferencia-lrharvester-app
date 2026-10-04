package org.lareferencia.backend.api.v5;

import java.util.List;
import java.util.LinkedHashSet;
import java.util.Locale;
import java.util.Map;
import org.springframework.http.HttpStatus;

final class ApiV5NetworkTags {
    private ApiV5NetworkTags() {}
    static List<String> normalize(List<String> values) {
        if (values == null) return List.of();
        if (values.size() > 50) throw invalid("At most 50 tags are allowed");
        LinkedHashSet<String> result = new LinkedHashSet<>();
        for (String value : values) {
            if (value == null) throw invalid("Tags must be strings");
            String tag = java.text.Normalizer.normalize(value.trim(), java.text.Normalizer.Form.NFC).toLowerCase(Locale.ROOT);
            if (tag.isEmpty() || tag.length() > 100 || tag.chars().anyMatch(Character::isISOControl))
                throw invalid("Tags must contain 1 to 100 characters without control characters");
            result.add(tag);
        }
        return List.copyOf(result);
    }
    static void filter(StringBuilder where, Map<String, Object> parameters, List<String> values, String mode) {
        if (mode != null && !mode.equals("all") && !mode.equals("any")) throw invalid("tagMode must be all or any");
        List<String> tags = normalize(values);
        if (tags.isEmpty()) return;
        if ("any".equals(mode)) {
            where.append(" and exists (select t from Network nt join nt.tags t where nt.id=n.id and t in :tags)");
            parameters.put("tags", tags);
        } else {
            for (int i = 0; i < tags.size(); i++) {
                where.append(" and :tag").append(i).append(" member of n.tags");
                parameters.put("tag" + i, tags.get(i));
            }
        }
    }
    private static ApiV5Exception invalid(String message) {
        return new ApiV5Exception(HttpStatus.BAD_REQUEST, "NETWORK_TAGS_INVALID", message);
    }
}
