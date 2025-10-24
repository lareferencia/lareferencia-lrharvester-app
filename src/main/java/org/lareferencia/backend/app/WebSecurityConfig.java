
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

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.firewall.HttpFirewall;
import org.springframework.security.web.firewall.StrictHttpFirewall;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

/**
 * Spring Security 6 configuration (Spring Boot 3.x compatible)
 * Migrated from WebSecurityConfigurerAdapter (deprecated in Spring Security 5.7, removed in 6.0)
 */
@Configuration
@EnableWebSecurity
public class WebSecurityConfig {

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
	 * Replaces the old configure(HttpSecurity http) method
	 */
	@Bean
	public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
		http
			.cors(cors -> cors.configurationSource(corsConfigurationSource()))
			.authorizeHttpRequests(authz -> authz
				// Solo estos endpoints requieren autenticación
				.requestMatchers("/rest/**").authenticated()
				.requestMatchers("/private/**").authenticated()
				
				// Todo lo demás es público
				.anyRequest().permitAll()
			)
			.httpBasic(httpBasic -> httpBasic.realmName("LA Referencia Backend"))
			.csrf(csrf -> csrf.disable())
			.sessionManagement(session -> session.maximumSessions(1));
		
		return http.build();
	}

	/**
	 * CORS configuration to allow credentials (HTTP Basic Auth) in cross-origin requests
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



