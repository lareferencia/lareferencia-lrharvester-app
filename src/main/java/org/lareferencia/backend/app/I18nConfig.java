package org.lareferencia.backend.app;

import org.lareferencia.core.util.ConfigPathResolver;
import org.springframework.context.MessageSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.support.ReloadableResourceBundleMessageSource;

@Configuration
public class I18nConfig {

    @Bean
    public MessageSource messageSource() {
        ReloadableResourceBundleMessageSource messageSource = new ReloadableResourceBundleMessageSource();
        // Read from ${app.config.dir}/i18n/messages
        messageSource.setBasename("file:" + ConfigPathResolver.resolve("i18n/messages"));
        messageSource.setDefaultEncoding("UTF-8");
        messageSource.setCacheSeconds(3600); // Cache for 1 hour
        messageSource.setUseCodeAsDefaultMessage(true);
        return messageSource;
    }
}
