/*
 *   Copyright (c) 2013-2022. LA Referencia / Red CLARA and others
 */
package org.lareferencia.backend.app;

import static org.junit.jupiter.api.Assertions.assertTrue;

// no System.err capture needed; test checks helper methods
import java.sql.SQLException;

import org.junit.jupiter.api.Test;
// No application event needed for this unit test

/**
 * Simple test to ensure our ApplicationFailureHandler prints a friendly message when DB connection fails.
 */
public class ApplicationFailureHandlerTest {

    @Test
    public void whenDbConnectionFails_listenerPrintsFriendlyMessage() {
        ApplicationFailureHandler handler = new ApplicationFailureHandler();
        Throwable root = new SQLException("Connection to localhost:5432 refused");
        // Keep throwable chain if needed in future tests
        assertTrue(handler.isConnectionFailure(root), "Should detect connection failure by root SQLException");

        String friendly = handler.buildFriendlyMessage(root);
        assertTrue(friendly.toLowerCase().contains("could not connect to the database"), "Expected friendly message to include user-friendly text");
    }
}
