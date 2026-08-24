package org.lareferencia.backend.api.v5;

import java.net.URI;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice(basePackages = "org.lareferencia.backend.api.v5")
public class ApiV5ExceptionHandler {
    @ExceptionHandler(ApiV5Exception.class)
    ResponseEntity<ProblemDetail> apiException(ApiV5Exception exception) {
        return ResponseEntity.status(exception.getStatus()).contentType(org.springframework.http.MediaType.APPLICATION_PROBLEM_JSON)
                .body(problem(exception.getStatus(), exception.getCode(), exception.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    ResponseEntity<ProblemDetail> validation(MethodArgumentNotValidException exception) {
        ProblemDetail problem = problem(HttpStatus.UNPROCESSABLE_ENTITY, "VALIDATION_ERROR", "Request validation failed");
        problem.setProperty("violations", exception.getBindingResult().getFieldErrors().stream()
                .map(error -> java.util.Map.of("field", error.getField(), "message", error.getDefaultMessage())).toList());
        return ResponseEntity.unprocessableEntity().contentType(org.springframework.http.MediaType.APPLICATION_PROBLEM_JSON).body(problem);
    }

    @ExceptionHandler(Exception.class)
    ResponseEntity<ProblemDetail> unexpected(Exception exception) {
        return ResponseEntity.internalServerError().contentType(org.springframework.http.MediaType.APPLICATION_PROBLEM_JSON)
                .body(problem(HttpStatus.INTERNAL_SERVER_ERROR, "INTERNAL_ERROR", "Unexpected server error"));
    }

    static ProblemDetail problem(HttpStatus status, String code, String detail) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(status, detail);
        problem.setType(URI.create("urn:lareferencia:api:v5:" + code.toLowerCase()));
        problem.setTitle(code);
        problem.setProperty("code", code);
        problem.setProperty("traceId", UUID.randomUUID().toString());
        return problem;
    }
}
