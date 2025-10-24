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


import org.lareferencia.core.metadata.IMetadataRecordStoreService;
import org.lareferencia.core.metadata.MetadataRecordStoreServiceImpl;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.data.elasticsearch.ElasticsearchDataAutoConfiguration;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.ImportResource;
import org.springframework.context.annotation.Scope;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.security.web.firewall.HttpFirewall;
import org.springframework.security.web.firewall.StrictHttpFirewall;


@SpringBootApplication

@EntityScan( basePackages= { "org.lareferencia.backend.domain", 
							 "org.lareferencia.core.entity.domain" } )

@EnableJpaRepositories( basePackages={ 
							"org.lareferencia.backend.repositories.jpa", 
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

	
	/** Metadata Store Service  */
	@Bean(name="metadataStoreService")
	@Scope("prototype")
	public IMetadataRecordStoreService metadaStoreService() {
        return new MetadataRecordStoreServiceImpl();
    }
	
}
