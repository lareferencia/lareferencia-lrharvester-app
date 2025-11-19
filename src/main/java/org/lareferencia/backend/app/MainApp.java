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


import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.data.elasticsearch.ElasticsearchDataAutoConfiguration;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.ImportResource;
import org.springframework.context.support.PropertySourcesPlaceholderConfigurer;
import org.springframework.core.io.FileSystemResource;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.security.web.firewall.HttpFirewall;
import org.springframework.security.web.firewall.StrictHttpFirewall;
import org.springframework.core.io.Resource;




@SpringBootApplication

@EntityScan( basePackages= { "org.lareferencia.core.domain", 
							 "org.lareferencia.core.entity.domain" } )

@EnableJpaRepositories( basePackages={ 
							"org.lareferencia.core.repository.jpa", 
							"org.lareferencia.core.entity.repositories.jpa" } )

@EnableAutoConfiguration( exclude = { org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration.class, ElasticsearchDataAutoConfiguration.class })

@Configuration
@ComponentScan(basePackages =  {"org.lareferencia.backend", "org.lareferencia.core" })
@ImportResource({"classpath*:application-context.xml"})
public class MainApp {

	public static void main(String[] args) {

        System.setProperty("spring.shell.interactive.enabled", "false");
        System.setProperty("spring.shell.script.enabled", "false");

		
        SpringApplicationBuilder builder =  new SpringApplicationBuilder(MainApp.class);
        builder.initializers(new MainAppContextInitializer());
        // Add a handler for failures during application startup to provide a clearer message
        builder.listeners(new ApplicationFailureHandler());
        builder.run(args);
	}

    @Bean
    public HttpFirewall looseHttpFirewall() {
        StrictHttpFirewall firewall = new StrictHttpFirewall();
        firewall.setAllowUrlEncodedSlash(true);
        firewall.setAllowBackSlash(true);
        firewall.setAllowUrlEncodedPercent(true);
        firewall.setAllowUrlEncodedPeriod(true);
        return firewall;
    }

    @Bean
    static PropertySourcesPlaceholderConfigurer dirConfigurer() throws IOException {

        Path dir = Paths.get("config/application.properties.d");
        
        Resource[] resources = Files.list(dir)
            .filter(p -> p.toString().endsWith(".properties"))
            .sorted()
            .map(p -> new FileSystemResource(p.toFile()))
            .toArray(Resource[]::new);

        PropertySourcesPlaceholderConfigurer configurer = new PropertySourcesPlaceholderConfigurer();
        configurer.setLocations(resources);
        configurer.setIgnoreResourceNotFound(true);


        return configurer;
    }




}
