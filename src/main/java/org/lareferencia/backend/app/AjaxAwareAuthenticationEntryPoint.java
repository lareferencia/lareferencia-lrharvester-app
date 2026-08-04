package org.lareferencia.backend.app;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.LoginUrlAuthenticationEntryPoint;

/**
 * Custom AuthenticationEntryPoint that suppresses the WWW-Authenticate header
 * (which triggers the browser's Basic Auth popup) for Ajax/XHR requests.
 */
public class AjaxAwareAuthenticationEntryPoint extends LoginUrlAuthenticationEntryPoint {

    public AjaxAwareAuthenticationEntryPoint(String loginFormUrl) {
        super(loginFormUrl);
    }

    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response,
            AuthenticationException authException)
            throws IOException, ServletException {

        // Check if the request is an Ajax request or expects JSON
        String ajaxHeader = request.getHeader("X-Requested-With");
        String acceptHeader = request.getHeader("Accept");

        boolean isAjax = "XMLHttpRequest".equals(ajaxHeader)
                || (acceptHeader != null && acceptHeader.contains("application/json"));

        if (isAjax) {
            // It is an Ajax request, just return 401 Unauthorized WITHOUT the
            // WWW-Authenticate header
            // This prevents the browser from showing the native login popup
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
        } else {
            // For standard browser navigation or CLI tools, proceed with default behavior
            // (Redirect to login form OR send WWW-Authenticate header if configured
            // elsewhere,
            // but since we extend LoginUrlAuthenticationEntryPoint, standard behavior is
            // redirect)

            // However, we want to support Basic Auth for CLI tools (curl) which don't send
            // X-Requested-With
            // but also don't necessarily accept text/html as primary.
            // If the client explicitly wants HTML (browser navigation), redirect.
            // If the client doesn't want HTML (likely CLI/API), send 401 with Basic Auth
            // challenge.

            if (acceptHeader != null && acceptHeader.contains("text/html")) {
                super.commence(request, response, authException);
            } else {
                // For all other requests (API, assets, etc.), return 401 Unauthorized
                // WITHOUT the WWW-Authenticate header to prevent browser popups.
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
            }
        }
    }
}
