package org.lareferencia.backend.app;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.servlet.view.RedirectView;

/**
 * Routes browser navigation to the generated frontend applications.
 */
@Controller
public class FrontendController {

    @GetMapping("/")
    public RedirectView root() {
        return new RedirectView("/admin/");
    }

    @GetMapping({ "/admin", "/admin/", "/admin/login", "/admin/networks", "/admin/networks/**",
            "/admin/validators", "/admin/validators/**", "/admin/transformers", "/admin/transformers/**",
            "/admin/actions", "/admin/actions/**", "/admin/runtime", "/admin/runtime/**", "/admin/dark",
            "/admin/dark/**", "/admin/users", "/admin/users/**", "/admin/forbidden" })
    public String adminFrontend() {
        return "forward:/admin/index.html";
    }

    @GetMapping({ "/dashboard", "/dashboard/" })
    public RedirectView dashboardRoot() {
        return new RedirectView("/dashboard/es/");
    }

    @GetMapping({ "/dashboard/en", "/dashboard/en/", "/dashboard/en/login", "/dashboard/en/user/**",
            "/dashboard/en/statistics/**", "/dashboard/en/*/validation/**", "/dashboard/en/*/harvesting/**" })
    public String dashboardEnglish() {
        return "forward:/dashboard/en/index.html";
    }

    @GetMapping({ "/dashboard/es", "/dashboard/es/", "/dashboard/es/login", "/dashboard/es/user/**",
            "/dashboard/es/statistics/**", "/dashboard/es/*/validation/**", "/dashboard/es/*/harvesting/**" })
    public String dashboardSpanish() {
        return "forward:/dashboard/es/index.html";
    }

    @GetMapping({ "/dashboard/pt", "/dashboard/pt/", "/dashboard/pt/login", "/dashboard/pt/user/**",
            "/dashboard/pt/statistics/**", "/dashboard/pt/*/validation/**", "/dashboard/pt/*/harvesting/**" })
    public String dashboardPortuguese() {
        return "forward:/dashboard/pt/index.html";
    }
}
