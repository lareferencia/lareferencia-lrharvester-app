package org.lareferencia.backend.api.v5;

import org.lareferencia.contrib.dark.worker.DarkManualRunningContext;
import org.lareferencia.contrib.dark.worker.DarkManualProgress;
import org.lareferencia.contrib.dark.worker.DarkReconcileWorker;
import org.lareferencia.contrib.dark.worker.DarkStageWorker;
import org.lareferencia.core.task.TaskManager;
import org.lareferencia.core.worker.IWorker;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.beans.factory.annotation.Value;

/** In-memory status for selected legacy dARK commands; deliberately non-durable. */
@Service
public class DarkManualCommandRegistry {
    private final Duration retention;
    private final Map<String, Entry> commands = new ConcurrentHashMap<>();
    private final TaskManager taskManager;

    public DarkManualCommandRegistry(TaskManager taskManager,
            @Value("${dark.manual.command-retention-hours:1}") long retentionHours) {
        this.taskManager = taskManager;
        this.retention = Duration.ofHours(Math.max(1, retentionHours));
    }

    public void register(DarkManualRunningContext context, int total, java.util.List<IWorker<?>> workers) {
        commands.put(context.getCommandId(), new Entry(context, total, java.util.List.copyOf(workers), OffsetDateTime.now(ZoneOffset.UTC)));
        purgeExpired();
    }

    public CommandStatus status(String commandId) {
        Entry entry = commands.get(commandId);
        if (entry == null) return null;
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        if (entry.acceptedAt().plus(retention).isBefore(now)) {
            commands.remove(commandId, entry);
            return null;
        }

        String state = state(entry);
        DarkManualProgress progress = progress(entry.workers());
        return new CommandStatus(entry.context().getCommandId(), entry.context().getAction().name(), state,
                entry.total(), progress.phase(), progress.processed(), progress.succeeded(),
                progress.skipped(), progress.failed(), entry.acceptedAt());
    }

    private void purgeExpired() {
        OffsetDateTime cutoff = OffsetDateTime.now(ZoneOffset.UTC).minus(retention);
        commands.entrySet().removeIf(entry -> entry.getValue().acceptedAt().isBefore(cutoff));
    }

    private String state(Entry entry) {
        boolean queued = false;
        boolean running = false;
        boolean cancelled = false;
        boolean failures = false;
        boolean executionFailures = false;
        for (IWorker<?> worker : entry.workers()) {
            var execution = taskManager.getWorkerSnapshot(worker);
            if (execution.isPresent()) {
                switch (execution.get().state()) {
                    case QUEUED -> queued = true;
                    case DISPATCHED, RUNNING, CANCEL_REQUESTED -> running = true;
                    case CANCELLED -> cancelled = true;
                    case FAILED -> executionFailures = true;
                    default -> { }
                }
            } else {
                var future = worker.getScheduledFuture();
                if (future == null) queued = true;
                else if (future.isCancelled()) cancelled = true;
                else if (!future.isDone()) running = true;
            }
            failures |= progress(worker).failed() > 0;
        }
        if (running) return "RUNNING";
        if (queued) return "QUEUED";
        if (cancelled || executionFailures) return "FAILED";
        return failures ? "PARTIAL" : "SUCCEEDED";
    }

    private DarkManualProgress progress(java.util.List<IWorker<?>> workers) {
        int processed = 0, succeeded = 0, skipped = 0, failed = 0;
        String phase = "QUEUED";
        for (IWorker<?> worker : workers) {
            DarkManualProgress item = progress(worker);
            phase = item.phase(); processed += item.processed(); succeeded += item.succeeded();
            skipped += item.skipped(); failed += item.failed();
        }
        return new DarkManualProgress(phase, processed, succeeded, skipped, failed);
    }

    private DarkManualProgress progress(IWorker<?> worker) {
        if (worker instanceof DarkStageWorker stageWorker) return stageWorker.getManualProgress();
        if (worker instanceof DarkReconcileWorker reconcileWorker) return reconcileWorker.getManualProgress();
        return new DarkManualProgress("QUEUED", 0, 0, 0, 0);
    }

    private record Entry(DarkManualRunningContext context, int total, java.util.List<IWorker<?>> workers, OffsetDateTime acceptedAt) { }

    public record CommandStatus(String commandId, String action, String state, int total, String phase,
            int processed, int succeeded, int skipped, int failed, OffsetDateTime acceptedAt) { }
}
