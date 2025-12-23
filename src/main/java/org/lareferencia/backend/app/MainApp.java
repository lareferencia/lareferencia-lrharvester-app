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
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.lareferencia.core.util.ConfigPathResolver;

import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.data.elasticsearch.ElasticsearchDataAutoConfiguration;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.boot.autoconfigure.security.servlet.UserDetailsServiceAutoConfiguration;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.context.event.ApplicationEnvironmentPreparedEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.ImportResource;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.support.ResourcePropertySource;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.security.web.firewall.HttpFirewall;
import org.springframework.security.web.firewall.StrictHttpFirewall;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@SpringBootApplication

@EntityScan(basePackages = { "org.lareferencia.core.domain",
        "org.lareferencia.core.entity.domain" })

@EnableJpaRepositories(basePackages = {
        "org.lareferencia.core.repository.jpa",
        "org.lareferencia.core.entity.repositories.jpa" })

@EnableTransactionManagement

// Exclude UserDetailsServiceAutoConfiguration to prevent Spring from creating a
// default user
// (We provide our own FileBasedUserDetailsService in WebSecurityConfig)
@EnableAutoConfiguration(exclude = {
        UserDetailsServiceAutoConfiguration.class,
        ElasticsearchDataAutoConfiguration.class })

@Configuration
@ComponentScan(basePackages = { "org.lareferencia.backend", "org.lareferencia.core" })
@ImportResource({ "classpath*:application-context.xml" })
public class MainApp {

    public static void main(String[] args) {
        // Export config directory as system property for XML context files
        // Must be set BEFORE Spring starts to be available for ${app.config.dir} in XML
        System.setProperty(ConfigPathResolver.CONFIG_DIR_PROPERTY, ConfigPathResolver.getConfigDir());

        System.setProperty("spring.shell.interactive.enabled", "false");
        System.setProperty("spring.shell.script.enabled", "false");

        SpringApplicationBuilder builder = new SpringApplicationBuilder(MainApp.class);
        builder.initializers(new MainAppContextInitializer());
        builder.listeners(new ApplicationFailureHandler());

        // Load properties from directory
        builder.listeners(new PropertiesDirectoryListener());

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

    /**
     * Listener that loads properties from
     * ${app.config.dir}/application.properties.d/*.properties
     */
    private static class PropertiesDirectoryListener
            implements ApplicationListener<ApplicationEnvironmentPreparedEvent> {

        @Override
        public void onApplicationEvent(ApplicationEnvironmentPreparedEvent event) {
            Path dir = ConfigPathResolver.resolvePath("application.properties.d");

            if (!Files.exists(dir) || !Files.isDirectory(dir)) {
                System.out.println("[PropertiesLoader] Directory not found: " + dir);
                return;
            }

            try (Stream<Path> stream = Files.list(dir)) {
                ConfigurableEnvironment env = event.getEnvironment();

                List<Path> propertyFiles = stream
                        .filter(p -> p.toString().endsWith(".properties"))
                        .sorted()
                        .collect(Collectors.toList());

                for (Path file : propertyFiles) {
                    try {
                        ResourcePropertySource source = new ResourcePropertySource(
                                "custom-" + file.getFileName().toString(),
                                new FileSystemResource(file.toFile()));
                        env.getPropertySources().addLast(source);
                        System.out.println("[PropertiesLoader] Loaded: " + file.getFileName());
                    } catch (IOException e) {
                        System.err.println("[PropertiesLoader] Failed to load: " + file + " - " + e.getMessage());
                    }
                }

            } catch (IOException e) {
                System.err.println("[PropertiesLoader] Error listing directory: " + e.getMessage());
            }
        }
    }
}
