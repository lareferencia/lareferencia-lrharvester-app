package org.lareferencia.backend.api.v5;

import static org.junit.jupiter.api.Assertions.*;

import java.time.Instant;
import java.util.Map;

import org.junit.jupiter.api.Test;
import org.lareferencia.backend.api.v5.ApiV5Dtos.SnapshotResponse;
import org.lareferencia.core.domain.IndexingResult;
import org.lareferencia.core.domain.SnapshotIndexStatus;

import com.fasterxml.jackson.databind.ObjectMapper;

class ApiV5IndexingResultsTest {
    private final ObjectMapper mapper = new ObjectMapper().findAndRegisterModules();

    @Test void snapshotExposesIndependentResultsWithStringDatesAndTheLegacySummary() throws Exception {
        var results = Map.of(
                "frontendIndexerWorker", new IndexingResult(SnapshotIndexStatus.INDEXED,
                        "FRONTEND_INDEXING_ACTION", Instant.parse("2026-10-04T08:00:00Z"), null),
                "xoaiIndexerWorker", new IndexingResult(SnapshotIndexStatus.FAILED,
                        "XOAI_INDEXING_ACTION", Instant.parse("2026-10-04T08:01:00Z"), "Solr commit failed"));
        var snapshot = new SnapshotResponse(10L, 1L, null, "VALID", "FAILED", null, null, null,
                100, 90, 90, false, results);
        var json = mapper.readTree(mapper.writeValueAsString(snapshot));
        assertEquals("FAILED", json.path("indexStatus").asText());
        assertEquals("INDEXED", json.path("indexingResults").path("frontendIndexerWorker").path("status").asText());
        assertEquals("FAILED", json.path("indexingResults").path("xoaiIndexerWorker").path("status").asText());
        assertEquals("2026-10-04T08:01:00Z", json.path("indexingResults").path("xoaiIndexerWorker").path("finishedAt").asText());
        assertEquals("Solr commit failed", json.path("indexingResults").path("xoaiIndexerWorker").path("error").asText());
        assertFalse(json.path("indexingResults").has("generation"));
    }

    @Test void historicalLegacySuccessDoesNotInventIndividualResults() throws Exception {
        var snapshot = new SnapshotResponse(10L, 1L, null, "VALID", "INDEXED", null, null, null, 100, 90, 90, false);
        var json = mapper.readTree(mapper.writeValueAsString(snapshot));
        assertEquals("INDEXED", json.path("indexStatus").asText());
        assertTrue(json.path("indexingResults").isObject());
        assertEquals(0, json.path("indexingResults").size());
    }
}
