package org.lareferencia.backend.security;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.OffsetDateTime;
import java.util.Base64;
import java.util.HexFormat;
import java.util.List;
import java.util.Locale;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class LocalIdentityService {
    private final JdbcTemplate jdbc;
    private final PasswordEncoder passwords;
    private final SecureRandom random = new SecureRandom();

    public LocalIdentityService(JdbcTemplate jdbc, PasswordEncoder passwords) {
        this.jdbc = jdbc; this.passwords = passwords;
    }

    public record UserView(long id, String username, String role, boolean enabled, List<NetworkGrant> networks) {}
    public record NetworkGrant(long id, String acronym, String name) {}
    public record ServiceView(long id, String name, boolean enabled, List<NetworkGrant> networks) {}
    public record TokenView(long id, String prefix, OffsetDateTime createdAt, OffsetDateTime expiresAt,
            OffsetDateTime lastUsedAt, OffsetDateTime revokedAt) {}
    public record IssuedToken(TokenView token, String value) {}

    public List<UserView> users() {
        return jdbc.query("SELECT id, username, global_role, enabled FROM local_user ORDER BY username",
                (rs, row) -> user(rs.getLong(1), rs.getString(2), rs.getString(3), rs.getBoolean(4)));
    }

    public UserView user(String username) {
        return jdbc.query("SELECT id, username, global_role, enabled FROM local_user WHERE lower(username)=lower(?)",
                rs -> rs.next() ? user(rs.getLong(1), rs.getString(2), rs.getString(3), rs.getBoolean(4)) : null, username);
    }

    @Transactional public UserView createUser(String username, String password, String role, List<Long> networks) {
        String canonicalUsername = canonicalUsername(username);
        String normalizedRole = normalizeRole(role);
        if (password == null || password.length() < 12 || password.length() > 200)
            throw new IllegalArgumentException("Password must contain between 12 and 200 characters");
        if (requiresNetworkGrant(normalizedRole) && (networks == null || networks.isEmpty()))
            throw new IllegalArgumentException("A reader or dashboard user must be assigned at least one network");
        jdbc.update("INSERT INTO local_user(username,password_hash,global_role) VALUES (?,?,?)",
                canonicalUsername, passwords.encode(password), normalizedRole);
        long id = jdbc.queryForObject("SELECT id FROM local_user WHERE username=?", Long.class, canonicalUsername);
        replaceGrants("local_user_network_read", "user_id", id, networks);
        return user(canonicalUsername);
    }

    @Transactional public UserView updateUser(String username, String role, Boolean enabled, String password,
            List<Long> networks) {
        if (password != null && !password.isBlank() && (password.length() < 12 || password.length() > 200))
            throw new IllegalArgumentException("Password must contain between 12 and 200 characters");
        Long id = jdbc.query("SELECT id FROM local_user WHERE lower(username)=lower(?)", rs -> rs.next() ? rs.getLong(1) : null, username);
        if (id == null) return null;
        String canonicalRole = role == null ? null : normalizeRole(role);
        String currentRole = jdbc.queryForObject("SELECT global_role FROM local_user WHERE id=?", String.class, id);
        String resultingRole = canonicalRole == null ? currentRole : canonicalRole;
        if (requiresNetworkGrant(resultingRole) && (networks != null && networks.isEmpty()
                || networks == null && jdbc.queryForObject("SELECT COUNT(*) FROM local_user_network_read WHERE user_id=?", Integer.class, id) == 0))
            throw new IllegalArgumentException("A reader or dashboard user must be assigned at least one network");
        boolean removingLastAdmin = "ADMIN".equals(currentRole)
                && ((canonicalRole != null && !"ADMIN".equals(canonicalRole)) || Boolean.FALSE.equals(enabled));
        if (removingLastAdmin && adminCount() <= 1)
            throw new IllegalStateException("Cannot disable or demote the last administrator");
        if (role != null || enabled != null) jdbc.update("UPDATE local_user SET global_role=COALESCE(?,global_role), enabled=COALESCE(?,enabled), updated_at=CURRENT_TIMESTAMP WHERE id=?",
                canonicalRole, enabled, id);
        if (password != null && !password.isBlank()) jdbc.update("UPDATE local_user SET password_hash=?, updated_at=CURRENT_TIMESTAMP WHERE id=?", passwords.encode(password), id);
        if (networks != null) replaceGrants("local_user_network_read", "user_id", id, networks);
        if (role != null || enabled != null || (password != null && !password.isBlank()))
            jdbc.update("DELETE FROM spring_session WHERE principal_name=(SELECT username FROM local_user WHERE id=?)", id);
        return user(username);
    }

    @Transactional public void deleteUser(String username) {
        Long id = jdbc.query("SELECT id FROM local_user WHERE lower(username)=lower(?)", rs -> rs.next() ? rs.getLong(1) : null, username);
        if (id == null) return;
        String role = jdbc.queryForObject("SELECT global_role FROM local_user WHERE id=?", String.class, id);
        if ("ADMIN".equals(role) && adminCount() <= 1) throw new IllegalStateException("Cannot delete the last administrator");
        jdbc.update("DELETE FROM spring_session WHERE principal_name=(SELECT username FROM local_user WHERE id=?)", id);
        jdbc.update("DELETE FROM local_user WHERE id=?", id);
    }

    public List<ServiceView> serviceAccounts() {
        return jdbc.query("SELECT id,name,enabled FROM local_service_account ORDER BY name",
                (rs, row) -> service(rs.getLong(1), rs.getString(2), rs.getBoolean(3)));
    }

    @Transactional public ServiceView createServiceAccount(String name, List<Long> networks) {
        if (name == null || name.isBlank() || name.trim().length() > 120) throw new IllegalArgumentException("Service account name is required and must be at most 120 characters");
        jdbc.update("INSERT INTO local_service_account(name) VALUES (?)", name.trim());
        long id = jdbc.queryForObject("SELECT id FROM local_service_account WHERE name=?", Long.class, name.trim());
        replaceGrants("local_service_account_network_read", "service_account_id", id, networks);
        return service(id, name.trim(), true);
    }

    @Transactional public ServiceView updateServiceAccount(long id, Boolean enabled, List<Long> networks) {
        if (enabled != null) jdbc.update("UPDATE local_service_account SET enabled=? WHERE id=?", enabled, id);
        if (networks != null) replaceGrants("local_service_account_network_read", "service_account_id", id, networks);
        if (Boolean.FALSE.equals(enabled)) jdbc.update("UPDATE local_api_token SET revoked_at=CURRENT_TIMESTAMP WHERE service_account_id=? AND revoked_at IS NULL", id);
        return jdbc.query("SELECT id,name,enabled FROM local_service_account WHERE id=?",
                rs -> rs.next() ? service(rs.getLong(1), rs.getString(2), rs.getBoolean(3)) : null, id);
    }

    public void deleteServiceAccount(long id) { jdbc.update("DELETE FROM local_service_account WHERE id=?", id); }

    @Transactional public IssuedToken issueToken(long serviceId, OffsetDateTime expiresAt) {
        if (expiresAt == null || !expiresAt.isAfter(OffsetDateTime.now())) throw new IllegalArgumentException("Token expiry must be in the future");
        if (expiresAt.isAfter(OffsetDateTime.now().plusYears(5))) throw new IllegalArgumentException("Token expiry must be within five years");
        if (jdbc.queryForObject("SELECT COUNT(*) FROM local_service_account WHERE id=? AND enabled=TRUE", Integer.class, serviceId) == 0)
            throw new IllegalArgumentException("Active service account was not found");
        byte[] bytes = new byte[32]; random.nextBytes(bytes);
        String token = "lrh_" + Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        String prefix = token.substring(0, 12);
        jdbc.update("INSERT INTO local_api_token(service_account_id,token_prefix,token_hash,expires_at) VALUES (?,?,?,?)",
                serviceId, prefix, hash(token), expiresAt);
        long tokenId = jdbc.queryForObject("SELECT id FROM local_api_token WHERE token_hash=?", Long.class, hash(token));
        return new IssuedToken(token(tokenId), token);
    }

    public List<TokenView> tokens(long serviceId) {
        return jdbc.query("SELECT id,token_prefix,created_at,expires_at,last_used_at,revoked_at FROM local_api_token WHERE service_account_id=? ORDER BY id DESC",
                (rs, row) -> new TokenView(rs.getLong(1), rs.getString(2), rs.getObject(3, OffsetDateTime.class),
                        rs.getObject(4, OffsetDateTime.class), rs.getObject(5, OffsetDateTime.class), rs.getObject(6, OffsetDateTime.class)), serviceId);
    }

    public void revokeToken(long serviceId, long tokenId) {
        jdbc.update("UPDATE local_api_token SET revoked_at=CURRENT_TIMESTAMP WHERE id=? AND service_account_id=? AND revoked_at IS NULL", tokenId, serviceId);
    }

    private TokenView token(long id) {
        return jdbc.queryForObject("SELECT id,token_prefix,created_at,expires_at,last_used_at,revoked_at FROM local_api_token WHERE id=?",
                (rs, row) -> new TokenView(rs.getLong(1), rs.getString(2), rs.getObject(3, OffsetDateTime.class),
                        rs.getObject(4, OffsetDateTime.class), rs.getObject(5, OffsetDateTime.class), rs.getObject(6, OffsetDateTime.class)), id);
    }

    private UserView user(long id, String username, String role, boolean enabled) {
        return new UserView(id, username, role, enabled, grants("local_user_network_read", "user_id", id));
    }
    private ServiceView service(long id, String name, boolean enabled) {
        return new ServiceView(id, name, enabled, grants("local_service_account_network_read", "service_account_id", id));
    }
    private List<NetworkGrant> grants(String table, String column, long id) {
        return jdbc.query("SELECT n.id,n.acronym,n.name FROM " + table + " g JOIN network n ON n.id=g.network_id WHERE g." + column + "=? ORDER BY n.acronym",
                (rs, row) -> new NetworkGrant(rs.getLong(1), rs.getString(2), rs.getString(3)), id);
    }
    private void replaceGrants(String table, String column, long id, List<Long> networkIds) {
        jdbc.update("DELETE FROM " + table + " WHERE " + column + "=?", id);
        if (networkIds == null) return;
        for (Long networkId : networkIds.stream().distinct().toList()) {
            if (networkId == null || jdbc.queryForObject("SELECT COUNT(*) FROM network WHERE id=?", Integer.class, networkId) == 0)
                throw new IllegalArgumentException("Unknown network id: " + networkId);
            jdbc.update("INSERT INTO " + table + "(" + column + ",network_id) VALUES (?,?)", id, networkId);
        }
    }
    private String normalizeRole(String role) {
        String normalized = role == null ? "" : role.trim().toUpperCase();
        if (!List.of("ADMIN", "READER", "DASHBOARD").contains(normalized)) throw new IllegalArgumentException("Role must be ADMIN, READER or DASHBOARD");
        return normalized;
    }
    private boolean requiresNetworkGrant(String role) { return "READER".equals(role) || "DASHBOARD".equals(role); }
    private String canonicalUsername(String username) {
        String canonical = username == null ? "" : username.trim().toLowerCase(Locale.ROOT);
        if (!canonical.matches("[a-z0-9._@+-]{3,100}")) throw new IllegalArgumentException("Username must be 3-100 characters using letters, digits, . _ @ + or -");
        return canonical;
    }
    private int adminCount() { return jdbc.queryForObject("SELECT COUNT(*) FROM local_user WHERE global_role='ADMIN' AND enabled=TRUE", Integer.class); }
    public static String hash(String token) {
        try { return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(token.getBytes(StandardCharsets.UTF_8))); }
        catch (Exception exception) { throw new IllegalStateException(exception); }
    }
}
