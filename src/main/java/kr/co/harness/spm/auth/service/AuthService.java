package kr.co.harness.spm.auth.service;

import java.security.Principal;
import kr.co.harness.spm.auth.dto.LoginRequest;
import kr.co.harness.spm.auth.dto.MeResponse;
import kr.co.harness.spm.auth.dto.RefreshRequest;
import kr.co.harness.spm.auth.dto.TokenResponse;
import kr.co.harness.spm.shared.security.JwtTokenProvider;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    public AuthService(PasswordEncoder passwordEncoder, JwtTokenProvider jwtTokenProvider) {
        this.passwordEncoder = passwordEncoder;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    public TokenResponse login(LoginRequest request) {
        throw new UnsupportedOperationException("Auth login is not implemented yet");
    }

    public TokenResponse refresh(RefreshRequest request) {
        throw new UnsupportedOperationException("Auth refresh is not implemented yet");
    }

    public void logout(Authentication authentication) {
        throw new UnsupportedOperationException("Auth logout is not implemented yet");
    }

    public MeResponse me(Authentication authentication) {
        throw new UnsupportedOperationException("Current user lookup is not implemented yet");
    }
}
