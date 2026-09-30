/*
 *   Copyright (c) 2013-2022. LA Referencia / Red CLARA and others
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU Affero General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Affero General Public License for more details.
 *
 *   You should have received a copy of the GNU Affero General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *   This file is part of LA Referencia software platform LRHarvester v4.x
 *   For any further information please contact Lautaro Matas <lmatas@gmail.com>
 */

package org.lareferencia.backend.app;

import java.util.Arrays;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.ProviderManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.csrf.CookieCsrfTokenRepository;
import org.springframework.security.web.csrf.CsrfFilter;
import org.springframework.security.web.csrf.CsrfTokenRequestAttributeHandler;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.http.MediaType;
import org.springframework.security.web.firewall.HttpFirewall;
import org.springframework.security.web.firewall.StrictHttpFirewall;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.session.jdbc.config.annotation.web.http.EnableJdbcHttpSession;
import org.lareferencia.backend.security.ApiTokenAuthenticationFilter;
import org.lareferencia.backend.security.LocalPrincipal;
import org.lareferencia.backend.security.LocalUserDetailsService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Spring Security 6 configuration (Spring Boot 3.x compatible)
 * Migrated from WebSecurityConfigurerAdapter (deprecated in Spring Security
 * 5.7, removed in 6.0)
 * 
 * Features:
 * - Local database-backed authentication for API v5
 * - BCrypt password encoding
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@EnableJdbcHttpSession
public class WebSecurityConfig {

	private static final Logger logger = LoggerFactory.getLogger(WebSecurityConfig.class);

	private final LocalUserDetailsService userDetailsService;

    @Value("${security.api-v5.allowed-origins:}")
    private String apiV5AllowedOrigins;

    @Value("${security.api-v5.cookies-secure:true}")
    private boolean apiV5CookiesSecure;

	public WebSecurityConfig(LocalUserDetailsService userDetailsService) {
		this.userDetailsService = userDetailsService;
		logger.info("WebSecurityConfig instantiated with local database identities");
	}

	@Bean
	public PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder();
	}

	@Bean
	public DaoAuthenticationProvider authenticationProvider(PasswordEncoder passwordEncoder) {
		DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
		provider.setUserDetailsService(userDetailsService);
		provider.setPasswordEncoder(passwordEncoder);
		// Hide user not found exceptions (returns BadCredentials instead)
		provider.setHideUserNotFoundExceptions(true);
		logger.info("DaoAuthenticationProvider configured for local v5 identities");
		return provider;
	}

	/**
	 * Create an AuthenticationManager that uses ONLY our DaoAuthenticationProvider.
	 * This prevents Spring from adding default InMemoryUserDetailsManager.
	 */
	@Bean
	public org.springframework.security.authentication.AuthenticationManager authenticationManager(DaoAuthenticationProvider authenticationProvider) {
		return new ProviderManager(authenticationProvider);
	}

	@Bean
	public HttpFirewall httpFirewall() {
		StrictHttpFirewall firewall = new StrictHttpFirewall();
		firewall.setAllowUrlEncodedDoubleSlash(true);
		firewall.setAllowUrlEncodedPercent(true);
		firewall.setAllowUrlEncodedSlash(true);
		firewall.setAllowSemicolon(true);
		return firewall;
	}

	/** API v5 uses session cookies for the browser and bearer tokens for integrations. */
	@Bean
	public SecurityFilterChain apiV5SecurityFilterChain(HttpSecurity http, JdbcTemplate jdbc) throws Exception {
		CookieCsrfTokenRepository csrfRepository = apiV5CsrfTokenRepository();
		CsrfTokenRequestAttributeHandler csrfRequestHandler = new CsrfTokenRequestAttributeHandler();
		csrfRequestHandler.setCsrfRequestAttributeName(null);
		http.cors(cors -> cors.configurationSource(apiV5CorsConfigurationSource()))
				.csrf(csrf -> csrf.csrfTokenRepository(csrfRepository).csrfTokenRequestHandler(csrfRequestHandler)
						.requireCsrfProtectionMatcher(WebSecurityConfig::requiresCsrf))
				.sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED))
				.logout(logout -> logout.logoutUrl("/api/v5/auth/logout")
						.invalidateHttpSession(true)
						.clearAuthentication(true)
						.deleteCookies("SESSION", "JSESSIONID", "XSRF-TOKEN")
						.logoutSuccessHandler((request, response, authentication) ->
								response.setStatus(HttpServletResponse.SC_NO_CONTENT)))
				.authorizeHttpRequests(auth -> auth.requestMatchers("/api/v5/auth/csrf", "/api/v5/auth/login",
						"/api/v5/openapi", "/api/v5/openapi/**", "/api/v5/docs", "/api/v5/docs/**", "/api/v5/swagger-ui/**",
						"/", "/admin/**", "/dashboard/**", "/favicon.ico").permitAll()
					.requestMatchers("/api/v5/me").authenticated()
					.requestMatchers("/api/v5/dashboard/**").hasAnyRole("ADMIN", "DASHBOARD")
					.requestMatchers("/api/v5/**").hasAnyRole("ADMIN", "READER", "SERVICE_ACCOUNT")
					.anyRequest().denyAll())
				.exceptionHandling(exceptions -> exceptions.authenticationEntryPoint((request, response, exception) -> writeApiError(response, 401, "UNAUTHORIZED"))
						.accessDeniedHandler((request, response, exception) -> {
							Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
							boolean anonymous = authentication == null || authentication instanceof AnonymousAuthenticationToken;
							writeApiError(response, anonymous ? 401 : 403, anonymous ? "UNAUTHORIZED" : "FORBIDDEN");
						}));
		http.addFilterBefore(new ApiTokenAuthenticationFilter(jdbc), CsrfFilter.class);
		return http.build();
	}

	static boolean requiresCsrf(HttpServletRequest request) {
		if (!CsrfFilter.DEFAULT_CSRF_MATCHER.matches(request)) return false;
		Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
		return !(authentication != null && authentication.getPrincipal() instanceof LocalPrincipal principal
				&& principal.kind() == LocalPrincipal.Kind.SERVICE_ACCOUNT);
	}

	@Bean
	public CookieCsrfTokenRepository apiV5CsrfTokenRepository() {
		CookieCsrfTokenRepository repository = CookieCsrfTokenRepository.withHttpOnlyFalse();
		repository.setCookiePath("/");
		repository.setCookieCustomizer(cookie -> cookie.secure(apiV5CookiesSecure).sameSite("Lax"));
		return repository;
	}

	private CorsConfigurationSource apiV5CorsConfigurationSource() {
		CorsConfiguration configuration = new CorsConfiguration();
		if (apiV5AllowedOrigins != null && !apiV5AllowedOrigins.isBlank()) {
			configuration.setAllowedOrigins(Arrays.stream(apiV5AllowedOrigins.split(",")).map(String::trim).filter(s -> !s.isEmpty()).toList());
			configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
			configuration.setAllowedHeaders(Arrays.asList("Authorization", "Content-Type", "X-Confirm-Network-Deletion", "X-XSRF-TOKEN"));
			configuration.setAllowCredentials(true);
		}
		UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
		source.registerCorsConfiguration("/api/v5/**", configuration);
		return source;
	}

	private void writeApiError(HttpServletResponse response, int status, String code) throws java.io.IOException {
		response.setStatus(status);
		response.setContentType(MediaType.APPLICATION_PROBLEM_JSON_VALUE);
		response.getWriter().write("{\"type\":\"urn:lareferencia:api:v5:" + code.toLowerCase() + "\",\"title\":\"" + code + "\",\"status\":" + status + ",\"code\":\"" + code + "\"}");
	}

	/** CORS configuration for credentialed React browser requests. */
	@Bean
	public CorsConfigurationSource corsConfigurationSource() {
		CorsConfiguration configuration = new CorsConfiguration();

		// Allow requests from any origin (adjust in production for specific origins)
		configuration.setAllowedOriginPatterns(Arrays.asList("*"));

		// Allow common HTTP methods
		configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));

		// Allow the bearer token and CSRF headers used by v5 clients.
		configuration.setAllowedHeaders(Arrays.asList("*"));

		// CRITICAL: Allow credentials (cookies, authorization headers, etc.)
		configuration.setAllowCredentials(true);

		// How long the response from a pre-flight request can be cached
		configuration.setMaxAge(3600L);

		UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
		source.registerCorsConfiguration("/**", configuration);

		return source;
	}

}
