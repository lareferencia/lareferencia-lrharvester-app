/*
 *   Copyright (c) 2013-2022. LA Referencia / Red CLARA and others
 */
package org.lareferencia.backend.app;

import java.sql.SQLException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.event.ApplicationFailedEvent;
import org.springframework.context.ApplicationListener;

/**
 * Listener to catch startup failures and provide a user-friendly message for DB connection errors.
 */
public class ApplicationFailureHandler implements ApplicationListener<ApplicationFailedEvent> {

    private static final Logger LOG = LoggerFactory.getLogger(ApplicationFailureHandler.class);

    @Override
    public void onApplicationEvent(ApplicationFailedEvent event) {
        Throwable ex = event.getException();
        Throwable root = rootCause(ex);

        // If the root cause is a SQL exception or the message contains connection related errors,
        // print a friendly message to the user and log the details.
        if (isConnectionFailure(root)) {
            String friendly = buildFriendlyMessage(root);
            // print to stderr so it is visible on startup logs
            System.err.println(friendly);
            LOG.error("Application startup failed due to database connectivity issue: {}", root.getMessage());
            LOG.debug("Full exception will follow for debugging.", ex);
            // Exit immediately to prevent Spring Boot from printing the stacktrace to the terminal
            System.exit(1);
        }
    }

    private Throwable rootCause(Throwable t) {
        Throwable result = t;
        while (result != null && result.getCause() != null && result.getCause() != result) {
            result = result.getCause();
        }
        return result == null ? t : result;
    }

    boolean isConnectionFailure(Throwable t) {
        if (t == null) return false;
        if (t instanceof SQLException) return true;
        String msg = t.getMessage();
        if (msg == null) return false;
        msg = msg.toLowerCase();
        // common connection refused messages
        return msg.contains("connection refused") || msg.contains("connection to") || msg.contains("connection timed out") || msg.contains("no pgsql") || msg.contains("could not open jpa") || msg.contains("cannot create transaction");
    }

    String buildFriendlyMessage(Throwable root) {
        StringBuilder sb = new StringBuilder();
        sb.append("\n========================================\n");
        sb.append("LA Referencia: application failed to start.\n");
        sb.append("Probable cause: could not connect to the database.\n");
        sb.append("Please verify that PostgreSQL is running and accessible at the configured host and port.\n");
        sb.append("Technical message: ").append(root.getMessage()).append("\n");
        sb.append("More details in the logs (DEBUG level).\n");
        sb.append("========================================\n");
        return sb.toString();
    }
}
