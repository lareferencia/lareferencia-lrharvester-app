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

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
//@EnableWebMvc
public class WebMvcConfiguration implements WebMvcConfigurer {
    
	
	@Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
		
//        
//		registry.addResourceHandler("/static/**")
//                .addResourceLocations("/static/"); 
//		
//		registry.addResourceHandler("/modules/**")
//        		.addResourceLocations("/modules/"); 
//
//		registry.addResourceHandler("/favicon.ico")
//        		.addResourceLocations("/static/favicon.ico"); 
		
//		 If using Spring Security – it's important to allow access to the static resources. We'll need to add the corresponding permissions for accessing the resource URL's:
//	    <intercept-url pattern="/files/**" access="permitAll" />
//	    <intercept-url pattern="/other-files/**/" access="permitAll" />
//	    <intercept-url pattern="/resources/**" access="permitAll" />
//		<intercept-url pattern="/js/**" access="permitAll" />
		 
    }
	


}
