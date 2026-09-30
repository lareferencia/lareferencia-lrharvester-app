package org.lareferencia.backend.security;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class LocalUserDetailsService implements UserDetailsService {
    private final JdbcTemplate jdbc;

    public LocalUserDetailsService(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    @Override public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        LocalPrincipal principal = jdbc.query("SELECT id, username, password_hash, global_role, enabled FROM local_user WHERE lower(username)=lower(?)",
                rs -> rs.next() ? new LocalPrincipal(rs.getLong("id"), rs.getString("username"),
                        rs.getString("password_hash"), rs.getString("global_role"), LocalPrincipal.Kind.USER,
                        rs.getBoolean("enabled")) : null, username);
        if (principal == null) throw new UsernameNotFoundException("User was not found");
        return principal;
    }
}
