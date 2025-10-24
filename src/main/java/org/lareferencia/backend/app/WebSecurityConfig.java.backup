
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

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.builders.WebSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.web.firewall.DefaultHttpFirewall;
import org.springframework.security.web.firewall.HttpFirewall;
import org.springframework.security.web.firewall.StrictHttpFirewall;

@Configuration
@EnableWebSecurity
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

	@Bean
	public HttpFirewall httpFirewall() {
		StrictHttpFirewall firewall = new StrictHttpFirewall();
		firewall.setAllowUrlEncodedDoubleSlash(true); // <— permite %2F%2F
		firewall.setAllowUrlEncodedPercent(true);      // <— permite %25


		// opcional: firewall.setAllowUrlEncodedSlash(true); // permite %2F
		return firewall;
	}

	
	 @Override
	  protected void configure(HttpSecurity http) throws Exception {

	    http
	      .httpBasic().and()
	      .authorizeRequests()
	      	.antMatchers(HttpMethod.GET, "/**").hasRole("USER")
	        .antMatchers(HttpMethod.POST, "/**").hasRole("USER")
	        .antMatchers(HttpMethod.PUT, "/**").hasRole("USER")
	        .antMatchers(HttpMethod.PATCH, "/**").hasRole("USER").and()
	      .csrf().disable();
	  }

	@Bean
	public HttpFirewall allowAllFirewall() {
		return new DefaultHttpFirewall(); // <— permite todas las URLs
	}

	@Override
	public void configure(WebSecurity web) {
		web.httpFirewall(allowAllFirewall());
	}
	
}



