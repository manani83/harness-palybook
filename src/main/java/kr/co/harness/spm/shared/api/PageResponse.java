package kr.co.harness.spm.shared.api;

import java.util.List;

public record PageResponse<T>(List<T> data, ApiResponse.Meta meta) {

    public static <T> PageResponse<T> of(List<T> data, String nextCursor, boolean hasMore) {
        return new PageResponse<>(data, ApiResponse.Meta.of(nextCursor, hasMore));
    }
}
