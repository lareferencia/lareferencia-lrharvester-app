package org.lareferencia.backend.app;

import java.nio.file.Files;
import java.nio.file.Path;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Routes browser navigation to the generated React application while keeping
 * the former AngularJS administration application available under /legacy.
 */
@Controller
public class FrontendController {

    private final Path frontendIndex;

    public FrontendController(@Value("${frontend.static-directory:static}") String staticDirectory) {
        this.frontendIndex = Path.of(staticDirectory).resolve("index.html");
    }

    @GetMapping({ "/", "/login", "/networks", "/networks/**", "/validators", "/validators/**",
            "/transformers", "/transformers/**", "/actions", "/actions/**", "/runtime", "/runtime/**" })
    public String frontend() {
        return Files.isRegularFile(frontendIndex) ? "forward:/index.html" : "redirect:/legacy/index.html";
    }

    @GetMapping({ "/legacy", "/legacy/" })
    public String legacy() {
        return "redirect:/legacy/index.html";
    }
}
