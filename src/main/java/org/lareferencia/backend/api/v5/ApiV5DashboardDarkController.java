package org.lareferencia.backend.api.v5;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;

import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;

import org.lareferencia.backend.security.LocalAuthorizationService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v5/dashboard/networks/{networkId}/dark")
public class ApiV5DashboardDarkController {
    private final LocalAuthorizationService authorization;
    private final DashboardDarkReport report;

    public ApiV5DashboardDarkController(LocalAuthorizationService authorization, DashboardDarkReport report) {
        this.authorization = authorization;
        this.report = report;
    }

    @GetMapping(produces = "application/json")
    public DashboardDarkReport.Results list(@PathVariable long networkId, @Valid @ModelAttribute DashboardDarkReport.Filters filters,
            @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "25") int size, Authentication auth) {
        requireRead(auth, networkId);
        return report.list(networkId, filters, page, size);
    }

    @GetMapping(value = "/export.csv", produces = "text/csv")
    public void export(@PathVariable long networkId, @Valid @ModelAttribute DashboardDarkReport.Filters filters,
            Authentication auth, HttpServletResponse response) throws IOException {
        requireRead(auth, networkId);
        response.setContentType("text/csv;charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"dark-network-" + networkId + ".csv\"");
        var writer = new BufferedWriter(new OutputStreamWriter(response.getOutputStream(), StandardCharsets.UTF_8));
        report.writeCsv(networkId, filters, writer);
        writer.flush();
    }

    private void requireRead(Authentication auth, long networkId) {
        authorization.requireDashboardAccess(auth);
        authorization.requireNetworkRead(auth, networkId);
    }
}
