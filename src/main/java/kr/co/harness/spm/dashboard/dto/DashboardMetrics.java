package kr.co.harness.spm.dashboard.dto;

public record DashboardMetrics(
        long priceDropCompetitorCount,
        long cheaperCompetitorCount,
        long marginRiskCount,
        long stockOutCount,
        long reviewSpikeCount
) {
}
