package org.lareferencia.backend.api.v5;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;
import java.nio.file.Path;
import java.util.Optional;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import org.junit.jupiter.api.Test;
import org.lareferencia.core.domain.Validator;
import org.lareferencia.core.metadata.OAIRecordMetadata;
import org.lareferencia.core.repository.jpa.ValidatorRepository;
import org.lareferencia.core.service.validation.ValidationService;
import org.lareferencia.core.worker.validation.*;
import org.springframework.context.support.StaticMessageSource;
import org.springframework.test.util.ReflectionTestUtils;

class ApiV5ProfileCompatibilityTest {
    @Test void roundTripsBothNodoCentralProfilesAndExecutesTheirDeclaredTitlePolicy() throws Exception {
        var mapper = new ObjectMapper();
        var schemas = new ValidatorRuleSchemaService();
        ReflectionTestUtils.setField(schemas, "messageSource", new StaticMessageSource());
        schemas.init();
        var repository = mock(ValidatorRepository.class);
        var serializer = new RuleSerializer();
        var management = new ApiV5ManagementService(null, null, repository, null, null, null, null, null,
                schemas, serializer, mapper, null, null);
        var stored = new java.util.concurrent.atomic.AtomicReference<Validator>();
        when(repository.save(any(Validator.class))).thenAnswer(call -> {
            Validator model = call.getArgument(0);
            model.setId(1L);
            long id = 0;
            for (var rule : model.getRules()) rule.setId(++id);
            stored.set(model);
            return model;
        });
        when(repository.findById(1L)).thenAnswer(call -> Optional.of(stored.get()));
        var service = new ValidationService();
        ReflectionTestUtils.setField(service, "serializer", serializer);
        for (boolean upgraded : new boolean[] {false, true}) {
            var export = mapper.readTree(Path.of("../validators/validator-1-2-with-vocabulary-rules.json").toFile());
            var rules = (ArrayNode) export.at("/configuration/rules");
            if (!upgraded) {
                for (int i = 0; i < rules.size(); i++) {
                    if ("Title — Presence".equals(rules.get(i).path("name").asText())) {
                        rules.remove(i);
                        break;
                    }
                }
            }
            var imported = management.importValidator(export);
            assertEquals(upgraded ? 17 : 16, imported.rules().size());
            var portable = mapper.valueToTree(management.exportValidator(1L));
            assertEquals(imported, management.importValidator(portable));
            var validator = service.createValidatorFromModel(stored.get());
            var xml = new OAIRecordMetadata("fixture", """
                <metadata><element name="dc"><element name="title"><element name="none">
                <field name="value"/></element></element></element></metadata>
                """);
            xml.addFieldOcurrence("dc.date.none", "2025");
            xml.addFieldOcurrence("dc.identifier.none", "https://example.org/item");
            xml.addFieldOcurrence("dc.creator.none", "Autor");
            xml.addFieldOcurrence("dc.rights.none", "info:eu-repo/semantics/openAccess");
            xml.addFieldOcurrence("dc.type.none", "info:eu-repo/semantics/article");
            assertEquals(!upgraded, validator.validate(xml, new ValidatorResult()).isValid());
            xml.removeFieldOcurrence("dc.title.*");
            assertEquals(!upgraded, validator.validate(xml, new ValidatorResult()).isValid());
            xml.addFieldOcurrence("dc.title.none", "Título");
            assertTrue(validator.validate(xml, new ValidatorResult()).isValid());
            xml.addFieldOcurrence("dc.title.none", "Title");
            assertTrue(validator.validate(xml, new ValidatorResult()).isValid());
        }
    }
    @Test void exportsAndReimportsLegacyTransformerWithoutRewritingItsSource() throws Exception {
        var mapper = new ObjectMapper();
        var schemas = new ValidatorRuleSchemaService();
        ReflectionTestUtils.setField(schemas, "messageSource", new StaticMessageSource());
        schemas.init();
        var repository = mock(org.lareferencia.core.repository.jpa.TransformerRepository.class);
        var serializer = new RuleSerializer();
        var management = new ApiV5ManagementService(null, null, null, repository, null, null, null, null,
                schemas, serializer, mapper, null, null);
        var source = new org.lareferencia.core.domain.Transformer();
        source.setName("Historical");
        var row = new org.lareferencia.core.domain.TransformerRule();
        row.setId(123L);
        row.setRunorder(7);
        row.setName("Normalize");
        String raw = """
                {"@class":"org.lareferencia.backend.validation.transformer.FieldContentNormalizeRule",
                "fieldName":"dc.type","removeInvalidOccurrences":true,
                "validationRule":{"@class":"org.lareferencia.backend.validation.validator.RegexFieldContentValidatorRule",
                "regexString":"org.lareferencia.backend.validation.validator.Literal"}}
                """;
        row.setJsonserialization(raw);
        source.getRules().add(row);
        when(repository.findById(8L)).thenReturn(Optional.of(source));
        when(repository.save(any())).thenAnswer(call -> call.getArgument(0));
        var portable = mapper.valueToTree(management.exportTransformer(8L));
        var restored = management.importTransformer(portable).rules().get(0);
        assertEquals("org.lareferencia.core.worker.validation.transformer.FieldContentNormalizeRule", restored.className());
        assertEquals(7, restored.runOrder());
        assertEquals("org.lareferencia.core.worker.validation.validator.RegexFieldContentValidatorRule",
                restored.configuration().at("/validationRule/@class").asText());
        assertEquals("org.lareferencia.backend.validation.validator.Literal",
                restored.configuration().at("/validationRule/regexString").asText());
        assertEquals(raw, row.getJsonserialization());
    }
}
