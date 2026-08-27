package org.lareferencia.backend.api.v5;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;

@Configuration
public class ApiV5OpenApiConfiguration {
    @Bean
    OpenAPI harvesterManagementV5OpenApi() {
        return new OpenAPI().info(new Info().title("LA Referencia Harvester Management API").version("v5")
                .description("Explicit administrative and operational API; legacy Data REST is not part of this contract."))
                .addSecurityItem(new SecurityRequirement().addList("basicAuth"))
                .addSecurityItem(new SecurityRequirement().addList("bearerAuth"))
                .schemaRequirement("basicAuth", new SecurityScheme().type(SecurityScheme.Type.HTTP).scheme("basic"))
                .schemaRequirement("bearerAuth", new SecurityScheme().type(SecurityScheme.Type.HTTP).scheme("bearer")
                        .bearerFormat("JWT"));
    }
}
