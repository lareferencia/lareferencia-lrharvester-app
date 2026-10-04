package org.lareferencia.backend.api.v5;

import static org.junit.jupiter.api.Assertions.*;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.lareferencia.core.domain.SnapshotStatus;

class ApiV5ValidationStatesTest {
    private ApiV5NetworkSummaryQuery query(List<String> states, boolean failures) {
        return new ApiV5NetworkSummaryQuery("attention,asc",null,null,null,null,null,null,null,null,null,null,
            new ApiV5NetworkSummaryQuery.Filters(states,null,null,null,failures));
    }
    @Test void failuresIncludeValidationFailureAndNeverMatchValidating() {
        var query = query(null,true);
        assertTrue(query.where.toString().contains("s.status in (3,13)"));
        assertFalse(query.where.toString().contains("s.status in (3,12)"));
        assertTrue(query.from.contains("ns.status="+SnapshotStatus.VALID.ordinal()));
    }
    @Test void runningFilterIncludesValidationAndStoppedFilterIncludesValidationStop() {
        assertTrue(query(List.of("running"),false).where.toString().contains("s.status in (1,2,12)"));
        assertTrue(query(List.of("stopped"),false).where.toString().contains("s.status in (5,14)"));
    }
}
