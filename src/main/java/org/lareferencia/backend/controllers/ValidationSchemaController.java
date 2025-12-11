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

package org.lareferencia.backend.controllers;

import java.util.List;
import java.util.Locale;

import org.lareferencia.core.worker.validation.RuleSchemaDefinition;
import org.lareferencia.core.worker.validation.ValidatorRuleSchemaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * REST controller for validation rule schema endpoints.
 * Provides dynamic JSON schema definitions for validator rules.
 */
@RestController
@RequestMapping("/public/validation")
@CrossOrigin
public class ValidationSchemaController {

    @Autowired
    private ValidatorRuleSchemaService schemaService;

    /**
     * Returns all validator rule schema definitions.
     * Used by the frontend to dynamically generate forms.
     */
    @GetMapping("/validator-rules-schemas")
    public List<RuleSchemaDefinition> getRuleSchemas(Locale locale,
            @RequestParam(required = false, name = "locale") String localeParam) {
        Locale effectiveLocale = locale;
        if (localeParam != null) {
            effectiveLocale = Locale.forLanguageTag(localeParam);
        }
        return schemaService.getAllRuleSchemas(effectiveLocale);
    }

    /**
     * Returns all transformer rule schema definitions.
     * Used by the frontend to dynamically generate forms.
     */
    @GetMapping("/transformer-rules-schemas")
    public List<RuleSchemaDefinition> getTransformerSchemas(Locale locale,
            @RequestParam(required = false, name = "locale") String localeParam) {
        Locale effectiveLocale = locale;
        if (localeParam != null) {
            effectiveLocale = Locale.forLanguageTag(localeParam);
        }
        return schemaService.getAllTransformerSchemas(effectiveLocale);
    }
}
