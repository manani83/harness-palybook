package kr.co.harness.spm.dashboard.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record DashboardActionItemResponse(
        UUID monitoredProductId,
        String title,
        String reason,
        String severity,
        BigDecimal currentLowestEffectivePrice,
        BigDecimal minMarginPrice
) {
}
