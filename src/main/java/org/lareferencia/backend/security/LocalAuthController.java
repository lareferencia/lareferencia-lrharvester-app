package org.lareferencia.backend.security;

import java.util.List;
import java.util.Map;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.security.web.context.SecurityContextRepository;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.security.web.csrf.CsrfTokenRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/v5")
public class LocalAuthController {
    public record LoginRequest(String username, String password) {}
    public record UserSession(String username, String displayName, List<String> roles, List<Long> readableNetworkIds,
            boolean serviceAccount) {}

    private final AuthenticationManager authenticationManager;
    private final SecurityContextRepository contexts = new HttpSessionSecurityContextRepository();
    private final LocalAuthorizationService authorization;
    private final CsrfTokenRepository csrfTokens;

    public LocalAuthController(@Qualifier("authenticationManager") AuthenticationManager authenticationManager,
            LocalAuthorizationService authorization, CsrfTokenRepository csrfTokens) {
        this.authenticationManager = authenticationManager; this.authorization = authorization; this.csrfTokens = csrfTokens;
    }

    @GetMapping("/auth/csrf") public Map<String, String> csrf(CsrfToken token, HttpServletRequest request,
            HttpServletResponse response) {
        token.getToken();
        csrfTokens.saveToken(token, request, response);
        return Map.of("token", token.getToken());
    }

    @PostMapping("/auth/login") public UserSession login(@RequestBody LoginRequest request, HttpServletRequest httpRequest,
            HttpServletResponse response) {
        try {
            if (request.username() == null || request.password() == null) throw new BadCredentialsException("Invalid credentials");
            Authentication result = authenticationManager.authenticate(
                    UsernamePasswordAuthenticationToken.unauthenticated(request.username(), request.password()));
            if (!(result.getPrincipal() instanceof LocalPrincipal principal) || principal.kind() != LocalPrincipal.Kind.USER)
                throw new BadCredentialsException("User login is not available for this identity");
            httpRequest.getSession(true);
            httpRequest.changeSessionId();
            SecurityContext context = SecurityContextHolder.createEmptyContext();
            context.setAuthentication(result);
            SecurityContextHolder.setContext(context);
            contexts.saveContext(context, httpRequest, response);
            return session(result);
        } catch (AuthenticationException exception) {
            SecurityContextHolder.clearContext();
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid username or password");
        }
    }

    @GetMapping("/me") public UserSession session(Authentication authentication) {
        LocalPrincipal principal = authorization.principal(authentication);
        return new UserSession(principal.getUsername(), principal.getUsername(),
                principal.getAuthorities().stream().map(a -> a.getAuthority().substring("ROLE_".length())).toList(),
                authorization.readableNetworkIds(authentication), principal.kind() == LocalPrincipal.Kind.SERVICE_ACCOUNT);
    }
}
