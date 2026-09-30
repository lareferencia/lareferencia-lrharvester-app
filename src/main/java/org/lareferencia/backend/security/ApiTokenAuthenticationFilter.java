package org.lareferencia.backend.security;

import java.io.IOException;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.security.core.context.SecurityContext;

public final class ApiTokenAuthenticationFilter extends OncePerRequestFilter {
    private final JdbcTemplate jdbc;
    public ApiTokenAuthenticationFilter(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    @Override protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        String header = request.getHeader("Authorization");
        if (request.getRequestURI().startsWith(request.getContextPath() + "/api/v5/")
                && header != null && header.startsWith("Bearer ")
                && SecurityContextHolder.getContext().getAuthentication() == null) {
            String value = header.substring(7).trim();
            if (!value.isEmpty()) {
                String hash = LocalIdentityService.hash(value);
                var principals = jdbc.query("SELECT a.id,a.name,a.enabled FROM local_api_token t JOIN local_service_account a ON a.id=t.service_account_id WHERE t.token_hash=? AND t.revoked_at IS NULL AND t.expires_at>CURRENT_TIMESTAMP AND a.enabled=TRUE",
                        (rs, row) -> new LocalPrincipal(rs.getLong(1), "service:" + rs.getString(2), "", "SERVICE_ACCOUNT",
                                LocalPrincipal.Kind.SERVICE_ACCOUNT, rs.getBoolean(3)), hash);
                if (!principals.isEmpty()) {
                    jdbc.update("UPDATE local_api_token SET last_used_at=CURRENT_TIMESTAMP WHERE token_hash=?", hash);
                    var authentication = UsernamePasswordAuthenticationToken.authenticated(principals.get(0), null, principals.get(0).getAuthorities());
                    authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContext context = SecurityContextHolder.createEmptyContext();
                    context.setAuthentication(authentication);
                    SecurityContextHolder.setContext(context);
                }
            }
        }
        chain.doFilter(request, response);
    }
}
