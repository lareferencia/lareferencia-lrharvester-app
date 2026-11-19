package org.lareferencia.backend.api.v5;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.lareferencia.core.domain.Network;
import org.lareferencia.core.repository.jpa.NetworkRepository;
import org.lareferencia.core.task.*;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import java.util.List;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class ApiV5TaskAdmissionTest {
    private NetworkRepository networks;
    private NetworkActionkManager actions;
    private MockMvc mvc;

    @BeforeEach void setUp() {
        networks = mock(NetworkRepository.class);
        actions = mock(NetworkActionkManager.class);
        Network network = new Network(); org.springframework.test.util.ReflectionTestUtils.setField(network, "id", 1L); network.setAcronym("TEST");
        when(networks.findById(1L)).thenReturn(Optional.of(network));
        NetworkAction action = new NetworkAction(); action.setName("EXAMPLE");
        when(actions.getActions()).thenReturn(List.of(action));
        when(actions.getEngineType()).thenReturn("legacy");
        ApiV5ManagementService service = new ApiV5ManagementService(networks, null, null, null, null, null,
                actions, null, null, null, new ObjectMapper(), null, null);
        mvc = MockMvcBuilders.standaloneSetup(new ApiV5ManagementController(service, new ObjectMapper()))
                .setControllerAdvice(new ApiV5ExceptionHandler()).build();
    }

    @Test void fullQueueProduces503InsteadOfFalseAcceptance() throws Exception {
        when(actions.submitAction(eq("EXAMPLE"), eq(false), any())).thenThrow(new TaskSubmissionRejectedException("TASK_QUEUE_FULL"));
        mvc.perform(post("/api/v5/networks/1/commands").contentType("application/json")
                .content("{\"type\":\"RUN_ACTION\",\"actionName\":\"EXAMPLE\",\"incremental\":false}"))
                .andExpect(status().isServiceUnavailable()).andExpect(jsonPath("$.code").value("TASK_QUEUE_FULL"));
    }

    @Test void acceptanceReceiptUsesTheActualAdmittedPlanId() throws Exception {
        when(actions.submitAction(eq("EXAMPLE"), eq(false), any())).thenReturn(new TaskSubmission("admitted-plan", true,
                List.of("worker-1"), List.of(TaskManager.WorkerLaunchResult.QUEUED), null));
        mvc.perform(post("/api/v5/networks/1/commands").contentType("application/json")
                .content("{\"type\":\"RUN_ACTION\",\"actionName\":\"EXAMPLE\",\"incremental\":false}"))
                .andExpect(status().isAccepted()).andExpect(jsonPath("$.result").value("ACCEPTED"))
                .andExpect(jsonPath("$.requestId").value("admitted-plan"));
    }

    @Test void batchContinuesAfterNetworkActionPolicyRejection() throws Exception {
        Network other = new Network();
        org.springframework.test.util.ReflectionTestUtils.setField(other, "id", 2L);
        when(networks.findById(2L)).thenReturn(Optional.of(other));
        when(actions.submitAction(eq("EXAMPLE"), eq(false), any()))
                .thenThrow(new ApplicationActionPolicyException("ACTION_DISABLED", "Action is disabled for this network"))
                .thenReturn(new TaskSubmission("accepted-group", true, List.of("worker-2"),
                        List.of(TaskManager.WorkerLaunchResult.RUNNING), null));
        mvc.perform(post("/api/v5/network-command-batches").contentType("application/json")
                .content("""
                        {"networkIds":[1,2],"command":{"type":"RUN_ACTION","actionName":"EXAMPLE"}}
                        """))
                .andExpect(status().isAccepted())
                .andExpect(jsonPath("$.children.length()").value(2))
                .andExpect(jsonPath("$.children[0].networkId").value(1))
                .andExpect(jsonPath("$.children[0].result").value("REJECTED"))
                .andExpect(jsonPath("$.children[0].message").value("Action is disabled for this network"))
                .andExpect(jsonPath("$.children[1].networkId").value(2))
                .andExpect(jsonPath("$.children[1].result").value("ACCEPTED"))
                .andExpect(jsonPath("$.children[1].requestId").value("accepted-group"));
    }

    @Test void batchReportsQueueRejectionPerNetwork() throws Exception {
        when(actions.submitAction(eq("EXAMPLE"), eq(false), any())).thenThrow(new TaskSubmissionRejectedException("TASK_QUEUE_FULL"));
        mvc.perform(post("/api/v5/network-command-batches").contentType("application/json")
                .content("{\"networkIds\":[1],\"command\":{\"type\":\"RUN_ACTION\",\"actionName\":\"EXAMPLE\"}}"))
                .andExpect(status().isAccepted()).andExpect(jsonPath("$.children[0].result").value("REJECTED"));
    }
}
