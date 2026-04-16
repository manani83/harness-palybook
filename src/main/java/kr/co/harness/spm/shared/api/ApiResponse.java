package kr.co.harness.spm.shared.api;

import java.util.UUID;

public record ApiResponse<T>(T data, Meta meta) {

    public static <T> ApiResponse<T> ok(T data) {
        return new ApiResponse<>(data, Meta.of(null, false));
    }

    public static <T> ApiResponse<T> ok(T data, String nextCursor, boolean hasMore) {
        return new ApiResponse<>(data, Meta.of(nextCursor, hasMore));
    }

    public record Meta(String requestId, String nextCursor, boolean hasMore) {

        public static Meta of(String nextCursor, boolean hasMore) {
            return new Meta(UUID.randomUUID().toString(), nextCursor, hasMore);
        }
    }
}
