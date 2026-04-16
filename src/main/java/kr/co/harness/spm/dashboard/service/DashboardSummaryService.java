package kr.co.harness.spm.dashboard.service;

import java.util.UUID;
import kr.co.harness.spm.dashboard.dto.DashboardSummaryResponse;
import org.springframework.stereotype.Service;

@Service
public class DashboardSummaryService {

    public DashboardSummaryResponse getSummary(UUID organizationId, String range) {
        throw new UnsupportedOperationException("Dashboard summary is not implemented yet");
    }
}
