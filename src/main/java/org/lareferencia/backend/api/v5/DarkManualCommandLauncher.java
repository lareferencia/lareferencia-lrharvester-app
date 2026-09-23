package org.lareferencia.backend.api.v5;

import org.lareferencia.contrib.dark.worker.DarkManualRunningContext;
import org.lareferencia.core.domain.Network;
import org.lareferencia.core.task.TaskManager;
import org.lareferencia.core.task.TaskManager.WorkerLaunchResult;
import org.lareferencia.core.worker.IWorker;
import org.lareferencia.core.worker.NetworkRunningContext;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.ArrayList;

/** Launches selected dARK commands through the legacy TaskManager. */
@Service
public class DarkManualCommandLauncher {
    private final ApplicationContext applicationContext;
    private final TaskManager taskManager;
    private final DarkManualCommandRegistry registry;

    public DarkManualCommandLauncher(ApplicationContext applicationContext, TaskManager taskManager,
            DarkManualCommandRegistry registry) {
        this.applicationContext = applicationContext;
        this.taskManager = taskManager;
        this.registry = registry;
    }

    @SuppressWarnings("unchecked")
    public DarkManualCommandRegistry.CommandStatus launch(List<Selection> selections, String requestedBy,
            DarkManualRunningContext.Action action) {
        String beanName = action == DarkManualRunningContext.Action.STAGE ? "darkStageWorker" : "darkReconcileWorker";
        String commandId = UUID.randomUUID().toString();
        List<IWorker<?>> workers = new ArrayList<>();
        int total = selections.stream().mapToInt(selection -> selection.oaiIds().size()).sum();
        DarkManualRunningContext commandContext = null;
        for (Selection selection : selections) {
            IWorker<NetworkRunningContext> worker = (IWorker<NetworkRunningContext>) applicationContext.getBean(beanName);
            DarkManualRunningContext context = new DarkManualRunningContext(commandId, selection.network(), selection.sourceSnapshotId(),
                    requestedBy, action, selection.oaiIds());
            worker.setRunningContext(context);
            workers.add(worker);
            if (commandContext == null) commandContext = context;
        }
        List<WorkerLaunchResult> results = taskManager.launchWorkersWithResult(workers);
        if (results.stream().anyMatch(result -> result == WorkerLaunchResult.REJECTED)) return null;
        registry.register(commandContext, total, workers);
        return registry.status(commandId);
    }

    /** A command is split by immutable source provenance, but retains one ephemeral command id. */
    public record Selection(Network network, Long sourceSnapshotId, List<String> oaiIds) { }
}
