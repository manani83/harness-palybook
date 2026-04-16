package kr.co.harness.spm.shared.api;

import java.util.Collections;
import java.util.List;
import java.util.Map;

public record ErrorResponse(ApiError error) {

    public static ErrorResponse of(String code, String message) {
        return of(code, message, Collections.emptyMap());
    }

    public static ErrorResponse of(String code, String message, Map<String, List<String>> details) {
        return new ErrorResponse(new ApiError(code, message, details == null ? Collections.emptyMap() : details));
    }

    public record ApiError(String code, String message, Map<String, List<String>> details) {
    }
}
