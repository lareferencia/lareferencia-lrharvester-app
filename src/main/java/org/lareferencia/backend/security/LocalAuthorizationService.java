package org.lareferencia.backend.security;

import java.util.List;

import org.lareferencia.backend.api.v5.ApiV5Exception;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

@Service
public class LocalAuthorizationService {
    private final JdbcTemplate jdbc;
    public LocalAuthorizationService(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    public boolean isAdmin(Authentication authentication) {
        LocalPrincipal principal = principal(authentication);
        return principal.kind() == LocalPrincipal.Kind.USER && "ADMIN".equals(principal.role());
    }

    public List<Long> readableNetworkIds(Authentication authentication) {
        LocalPrincipal principal = principal(authentication);
        if (principal.kind() == LocalPrincipal.Kind.USER && "ADMIN".equals(principal.role())) {
            return jdbc.query("SELECT id FROM network ORDER BY id", (rs, row) -> rs.getLong(1));
        }
        String sql = principal.kind() == LocalPrincipal.Kind.USER
                ? "SELECT network_id FROM local_user_network_read WHERE user_id=? ORDER BY network_id"
                : "SELECT network_id FROM local_service_account_network_read WHERE service_account_id=? ORDER BY network_id";
        return jdbc.query(sql, (rs, row) -> rs.getLong(1), principal.id());
    }

    public boolean canReadNetwork(Authentication authentication, long networkId) {
        LocalPrincipal principal = principal(authentication);
        if (principal.kind() == LocalPrincipal.Kind.USER && "ADMIN".equals(principal.role())) return true;
        String sql = principal.kind() == LocalPrincipal.Kind.USER
                ? "SELECT EXISTS(SELECT 1 FROM local_user_network_read WHERE user_id=? AND network_id=?)"
                : "SELECT EXISTS(SELECT 1 FROM local_service_account_network_read WHERE service_account_id=? AND network_id=?)";
        return Boolean.TRUE.equals(jdbc.queryForObject(sql, Boolean.class, principal.id(), networkId));
    }

    public void requireNetworkRead(Authentication authentication, long networkId) {
        if (!jdbc.queryForObject("SELECT EXISTS(SELECT 1 FROM network WHERE id=?)", Boolean.class, networkId))
            throw new ApiV5Exception(HttpStatus.NOT_FOUND, "NETWORK_NOT_FOUND", "Network " + networkId + " was not found");
        if (!canReadNetwork(authentication, networkId))
            throw new ApiV5Exception(HttpStatus.FORBIDDEN, "NETWORK_ACCESS_DENIED", "Read access to this network is not granted");
    }

    public void requireSnapshotRead(Authentication authentication, long snapshotId) {
        Long networkId = jdbc.query("SELECT network_id FROM networksnapshot WHERE id=?", rs -> {
            if (!rs.next()) return null;
            long value = rs.getLong(1);
            return rs.wasNull() ? null : value;
        }, snapshotId);
        if (networkId == null) throw new ApiV5Exception(HttpStatus.NOT_FOUND, "SNAPSHOT_NOT_FOUND", "Snapshot " + snapshotId + " was not found");
        requireNetworkRead(authentication, networkId);
    }

    public LocalPrincipal principal(Authentication authentication) {
        if (authentication == null || !(authentication.getPrincipal() instanceof LocalPrincipal principal))
            throw new ApiV5Exception(HttpStatus.UNAUTHORIZED, "UNAUTHORIZED", "Authentication is required");
        return principal;
    }

    public void requireAdmin(Authentication authentication) {
        if (!isAdmin(authentication)) throw new ApiV5Exception(HttpStatus.FORBIDDEN, "FORBIDDEN", "Administrator role is required");
    }

    public void requireDashboardAccess(Authentication authentication) {
        LocalPrincipal principal = principal(authentication);
        if (principal.kind() != LocalPrincipal.Kind.USER
                || !List.of("ADMIN", "DASHBOARD").contains(principal.role()))
            throw new ApiV5Exception(HttpStatus.FORBIDDEN, "FORBIDDEN", "Dashboard role is required");
    }
}
