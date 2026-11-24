package org.lareferencia.backend.api.v5;

import static org.springframework.format.annotation.DateTimeFormat.ISO.DATE;

import java.io.IOException;
import java.io.Writer;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Locale;
import javax.sql.DataSource;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.AssertTrue;
import org.lareferencia.contrib.dark.domain.DarkTrackingState;
import org.lareferencia.contrib.dark.domain.DarkTrackingStateConverter;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class DashboardDarkReport {
    public record Filters(DarkTrackingState state, @DateTimeFormat(iso = DATE) LocalDate from,
            @DateTimeFormat(iso = DATE) LocalDate to, String q) {
        @AssertTrue(message = "from must not follow to")
        public boolean isDateRangeValid() {
            return from == null || to == null || !from.isAfter(to);
        }
    }
    public record Row(String ark, String oaiId, DarkTrackingState state,
            @JsonFormat(shape = JsonFormat.Shape.STRING) OffsetDateTime updatedAt) {}
    public record Results(List<Row> content, long totalElements) {}

    private static final DarkTrackingStateConverter STATES = new DarkTrackingStateConverter();
    private static final RowMapper<Row> ROW = (rs, index) -> new Row(rs.getString("ark"), rs.getString("oai_id"),
            STATES.convertToEntityAttribute(rs.getString("state")),
            rs.getObject("updated_at", LocalDateTime.class).atOffset(ZoneOffset.UTC));
    private final NamedParameterJdbcTemplate jdbc;

    public DashboardDarkReport(DataSource dataSource) {
        var template = new JdbcTemplate(dataSource);
        // PostgreSQL uses a server cursor inside the read transaction during large downloads.
        template.setFetchSize(512);
        this.jdbc = new NamedParameterJdbcTemplate(template);
    }

    private record Selection(String where, MapSqlParameterSource params) {
        String rows() {
            return "select ark, oai_id, state, updated_at " + where + " order by updated_at desc, ark";
        }
    }

    private Selection selection(long network, Filters filters) {
        // A NAAN can be shared. Only recorded source provenance establishes network ownership.
        String where = "from dark_tracking_record where source_network_id = :network and ark <> ''";
        var params = new MapSqlParameterSource("network", network);
        if (filters.state() != null) {
            where += " and state = :state";
            params.addValue("state", filters.state().getValue());
        }
        if (filters.from() != null) {
            where += " and updated_at >= :start";
            params.addValue("start", filters.from().atStartOfDay());
        }
        if (filters.to() != null) {
            where += " and updated_at < :end";
            params.addValue("end", filters.to().plusDays(1).atStartOfDay());
        }
        if (filters.q() != null && !filters.q().isBlank()) {
            String literal = filters.q().strip().toLowerCase(Locale.ROOT)
                    .replace("!", "!!").replace("%", "!%").replace("_", "!_");
            where += " and (lower(ark) like :term escape '!' or lower(oai_id) like :term escape '!')";
            params.addValue("term", "%" + literal + "%");
        }
        return new Selection(where, params);
    }

    public Results list(long network, Filters filters, int page, int size) {
        if (page < 0 || size < 1 || size > 200) {
            throw new ApiV5Exception(HttpStatus.BAD_REQUEST, "INVALID_PAGE", "Expected page >= 0 and size between 1 and 200");
        }
        var query = selection(network, filters);
        long count = jdbc.queryForObject("select count(*) " + query.where(), query.params(), Long.class);
        var params = query.params().addValue("size", size).addValue("offset", (long) page * size);
        return new Results(jdbc.query(query.rows() + " limit :size offset :offset", params, ROW), count);
    }

    public void writeCsv(long network, Filters filters, Writer writer) throws IOException {
        var query = selection(network, filters);
        try (var rows = jdbc.queryForStream(query.rows(), query.params(), ROW)) {
            writer.write("\uFEFFark;oai_id;state;updated_at_utc\r\n");
            var iterator = rows.iterator();
            while (iterator.hasNext()) {
                Row row = iterator.next();
                writer.write(csvCell(row.ark()) + ";" + csvCell(row.oaiId()) + ";" + row.state()
                        + ";" + row.updatedAt() + "\r\n");
            }
        }
    }

    private static String csvCell(String value) {
        // Identifiers are external text. Prevent spreadsheet formula interpretation.
        String trimmed = value.stripLeading();
        if (!trimmed.isEmpty() && "=+-@".indexOf(trimmed.charAt(0)) >= 0) value = "'" + value;
        return "\"" + value.replace("\"", "\"\"") + "\"";
    }
}
