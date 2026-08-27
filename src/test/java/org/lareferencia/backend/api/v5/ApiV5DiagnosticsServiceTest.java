package org.lareferencia.backend.api.v5;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import java.util.List;

import org.junit.jupiter.api.Test;

import static org.lareferencia.backend.api.v5.ApiV5Dtos.*;

class ApiV5DiagnosticsServiceTest {
    private final ApiV5DiagnosticsService service = new ApiV5DiagnosticsService(null, null, null, null, null);

    @Test
    void translatesPublicFiltersWithoutExposingInternalSyntax() {
        List<String> translated = service.translate(List.of(
                new DiagnosticFilter(DiagnosticFilterField.IDENTIFIER, DiagnosticFilterOperator.CONTAINS, "oai:test"),
                new DiagnosticFilter(DiagnosticFilterField.VALID, DiagnosticFilterOperator.EQ, true),
                new DiagnosticFilter(DiagnosticFilterField.RULE_INVALID, DiagnosticFilterOperator.EQ, 42)));

        assertEquals(List.of("identifier@@\"oai:test\"", "is_valid@@\"true\"", "invalid_rules@@\"42\""),
                translated);
    }

    @Test
    void rejectsUnsafeRuleIdentifiers() {
        assertThrows(ApiV5Exception.class, () -> service.translate(List.of(
                new DiagnosticFilter(DiagnosticFilterField.RULE_VALID, DiagnosticFilterOperator.EQ, "1 OR 1=1"))));
    }
}
