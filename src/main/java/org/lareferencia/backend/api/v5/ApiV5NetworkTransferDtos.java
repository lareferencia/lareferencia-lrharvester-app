package org.lareferencia.backend.api.v5;

import java.util.List;

/** DTOs for the portable, one-sheet XLSX source transfer format. */
public final class ApiV5NetworkTransferDtos {
    private ApiV5NetworkTransferDtos() { }

    public enum ImportMode { CREATE_ONLY, UPDATE_ONLY, UPSERT }

    public record ImportRowResult(int row, String acronym, String operation, List<String> errors, List<String> warnings) {
        public boolean valid() { return errors == null || errors.isEmpty(); }
    }

    public record ImportValidationResponse(String format, int version, ImportMode mode, int totalRows,
            int validRows, int invalidRows, List<ImportRowResult> rows) { }

    public record ImportResult(ImportValidationResponse validation, int created, int updated) { }
}
