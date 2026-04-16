package kr.co.harness.spm.auth.dto;

public record TokenResponse(
        String accessToken,
        String refreshToken,
        MeResponse user
) {
}
