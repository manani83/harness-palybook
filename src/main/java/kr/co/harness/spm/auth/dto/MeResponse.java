package kr.co.harness.spm.auth.dto;

import java.util.List;
import java.util.UUID;

public record MeResponse(
        UUID id,
        String email,
        String name,
        List<OrganizationSummary> organizations
) {
    public record OrganizationSummary(
            UUID id,
            String name,
            String role,
            String status
    ) {
    }
}
