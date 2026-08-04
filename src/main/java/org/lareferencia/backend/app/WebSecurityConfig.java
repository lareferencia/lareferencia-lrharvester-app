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
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.ProviderManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.firewall.HttpFirewall;
import org.springframework.security.web.firewall.StrictHttpFirewall;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

/**
 * Spring Security 6 configuration (Spring Boot 3.x compatible)
 * Migrated from WebSecurityConfigurerAdapter (deprecated in Spring Security
 * 5.7, removed in 6.0)
 * 
 * Features:
 * - File-based user authentication (config/users.properties)
 * - Dual authentication: Form Login (browser) + HTTP Basic (API)
 * - BCrypt password encoding
 * - Automatic user reload on login attempt
 */
@Configuration
@EnableWebSecurity
public class WebSecurityConfig {

	private static final Logger logger = LoggerFactory.getLogger(WebSecurityConfig.class);

	private final FileBasedUserDetailsService userDetailsService;

	public WebSecurityConfig(FileBasedUserDetailsService userDetailsService) {
		this.userDetailsService = userDetailsService;
		logger.info("WebSecurityConfig instantiated with FileBasedUserDetailsService (users loaded: {})",
				userDetailsService.getUserCount());
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
		logger.info("DaoAuthenticationProvider configured with FileBasedUserDetailsService");
		return provider;
	}

	/**
	 * Create AuthenticationManager that uses ONLY our DaoAuthenticationProvider.
	 * This prevents Spring from adding default InMemoryUserDetailsManager.
	 */
	@Bean
	public AuthenticationManager authenticationManager(DaoAuthenticationProvider authenticationProvider) {
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

	/**
	 * Main security filter chain configuration
	 * Supports both Form Login (for browsers) and HTTP Basic (for APIs)
	 */
	@Bean
	public SecurityFilterChain securityFilterChain(HttpSecurity http, AuthenticationManager authenticationManager)
			throws Exception {
		http
				.cors(cors -> cors.configurationSource(corsConfigurationSource()))
				// Use ONLY our authentication manager
				.authenticationManager(authenticationManager)
				.authorizeHttpRequests(authz -> authz
						// Login page and its resources must be public
						.requestMatchers("/login", "/login.html").permitAll()

						// Static resources needed for login page (CSS, JS if any)
						.requestMatchers("/css/**", "/js/**", "/images/**", "/favicon.ico").permitAll()
						.requestMatchers("/fonts/**", "/libs/**", "/modules/**", "/schemas/**", "/services/**",
								"/hal-browser/**")
						.permitAll()

						// All other requests require ADMIN role (including index.html, REST, etc.)
						.anyRequest().hasRole("ADMIN"))
				// Form Login for browser access
				.formLogin(form -> form
						.loginPage("/login.html")
						.loginProcessingUrl("/login")
						.defaultSuccessUrl("/", true)
						.failureUrl("/login.html?error=true")
						.permitAll())
				// HTTP Basic for API/CLI access
				.httpBasic(httpBasic -> httpBasic.realmName("LA Referencia Platform"))
				// Logout configuration
				.logout(logout -> logout
						.logoutUrl("/logout")
						.logoutSuccessUrl("/login.html?logout=true")
						.invalidateHttpSession(true)
						.deleteCookies("JSESSIONID")
						.permitAll())
				.csrf(csrf -> csrf.disable())
				.sessionManagement(session -> session.maximumSessions(1))
				.exceptionHandling(exceptions -> exceptions
						.authenticationEntryPoint(new AjaxAwareAuthenticationEntryPoint("/login.html")));

		return http.build();
	}

	/**
	 * CORS configuration to allow credentials (HTTP Basic Auth) in cross-origin
	 * requests
	 */
	@Bean
	public CorsConfigurationSource corsConfigurationSource() {
		CorsConfiguration configuration = new CorsConfiguration();

		// Allow requests from any origin (adjust in production for specific origins)
		configuration.setAllowedOriginPatterns(Arrays.asList("*"));

		// Allow common HTTP methods
		configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));

		// Allow common headers including Authorization for HTTP Basic Auth
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
