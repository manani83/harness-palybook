package kr.co.harness.spm.dashboard.controller;

import java.util.UUID;
import kr.co.harness.spm.dashboard.dto.DashboardSummaryResponse;
import kr.co.harness.spm.dashboard.service.DashboardSummaryService;
import kr.co.harness.spm.shared.api.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/dashboard")
public class DashboardController {

    private final DashboardSummaryService dashboardSummaryService;

    public DashboardController(DashboardSummaryService dashboardSummaryService) {
        this.dashboardSummaryService = dashboardSummaryService;
    }

    @GetMapping("/summary")
    public ResponseEntity<ApiResponse<DashboardSummaryResponse>> summary(
            @RequestParam UUID organizationId,
            @RequestParam(defaultValue = "24h") String range
    ) {
        return ResponseEntity.ok(ApiResponse.ok(dashboardSummaryService.getSummary(organizationId, range)));
    }
}
