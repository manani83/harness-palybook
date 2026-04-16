package kr.co.harness.spm.shared.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.time.Clock;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.UUID;
import kr.co.harness.spm.config.JwtProperties;
import org.springframework.stereotype.Component;
import org.springframework.util.Assert;

@Component
public class JwtTokenProvider {

    private final JwtProperties jwtProperties;
    private final Clock clock;
    private final Key signingKey;

    public JwtTokenProvider(JwtProperties jwtProperties, Clock utcClock) {
        this.jwtProperties = jwtProperties;
        this.clock = utcClock;
        Assert.hasText(jwtProperties.getSecret(), "JWT secret must not be blank");
        Assert.isTrue(jwtProperties.getSecret().getBytes(StandardCharsets.UTF_8).length >= 32, "JWT secret must be at least 32 bytes");
        this.signingKey = Keys.hmacShaKeyFor(jwtProperties.getSecret().getBytes(StandardCharsets.UTF_8));
    }

    public String createAccessToken(String subject) {
        return createToken(subject, jwtProperties.getAccessTokenTtl());
    }

    public String createRefreshToken(String subject) {
        return createToken(subject, jwtProperties.getRefreshTokenTtl());
    }

    public boolean isValid(String token) {
        try {
            parseClaims(token);
            return true;
        } catch (RuntimeException exception) {
            return false;
        }
    }

    public Claims parseClaims(String token) {
        return parser(token).getBody();
    }

    public String extractSubject(String token) {
        return parseClaims(token).getSubject();
    }

    public String extractJti(String token) {
        return parseClaims(token).getId();
    }

    private Jws<Claims> parser(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(signingKey)
                .build()
                .parseClaimsJws(token);
    }

    private String createToken(String subject, java.time.Duration ttl) {
        Instant now = Instant.now(clock);
        Instant expiresAt = now.plus(ttl.toMillis(), ChronoUnit.MILLIS);
        return Jwts.builder()
                .setIssuer(jwtProperties.getIssuer())
                .setSubject(subject)
                .setId(UUID.randomUUID().toString())
                .setIssuedAt(Date.from(now))
                .setExpiration(Date.from(expiresAt))
                .signWith(signingKey, SignatureAlgorithm.HS256)
                .compact();
    }
}
