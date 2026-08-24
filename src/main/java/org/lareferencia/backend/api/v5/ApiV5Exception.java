package org.lareferencia.backend.api.v5;

import org.springframework.http.HttpStatus;

public class ApiV5Exception extends RuntimeException {
    private final HttpStatus status;
    private final String code;

    public ApiV5Exception(HttpStatus status, String code, String message) {
        super(message);
        this.status = status;
        this.code = code;
    }

    public HttpStatus getStatus() { return status; }
    public String getCode() { return code; }
}
