package kr.co.harness.spm.dashboard.dto;

import java.time.Instant;
import java.util.List;

public record DashboardSummaryResponse(
        Instant asOf,
        DashboardMetrics metrics,
        List<DashboardActionItemResponse> actionItems
) {
}
