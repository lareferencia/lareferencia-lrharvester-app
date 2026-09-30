package org.lareferencia.backend.security;

import java.util.Collection;
import java.util.List;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

public final class LocalPrincipal implements UserDetails {
    public enum Kind { USER, SERVICE_ACCOUNT }

    private final long id;
    private final String username;
    private final String password;
    private final String role;
    private final Kind kind;
    private final boolean enabled;

    public LocalPrincipal(long id, String username, String password, String role, Kind kind, boolean enabled) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.role = role;
        this.kind = kind;
        this.enabled = enabled;
    }

    public long id() { return id; }
    public Kind kind() { return kind; }
    public String role() { return role; }
    @Override public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + (kind == Kind.SERVICE_ACCOUNT ? "SERVICE_ACCOUNT" : role)));
    }
    @Override public String getPassword() { return password; }
    @Override public String getUsername() { return username; }
    @Override public boolean isEnabled() { return enabled; }
    @Override public boolean isAccountNonExpired() { return true; }
    @Override public boolean isAccountNonLocked() { return true; }
    @Override public boolean isCredentialsNonExpired() { return true; }
}
