package kr.co.harness.spm.shared.exception;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import org.springframework.http.HttpStatus;

public class DomainException extends RuntimeException {

    private final HttpStatus status;
    private final String code;
    private final Map<String, List<String>> details;

    public DomainException(HttpStatus status, String code, String message) {
        this(status, code, message, Collections.emptyMap());
    }

    public DomainException(HttpStatus status, String code, String message, Map<String, List<String>> details) {
        super(message);
        this.status = status;
        this.code = code;
        this.details = details == null ? Collections.emptyMap() : Collections.unmodifiableMap(details);
    }

    public HttpStatus getStatus() {
        return status;
    }

    public String getCode() {
        return code;
    }

    public Map<String, List<String>> getDetails() {
        return details;
    }
}
