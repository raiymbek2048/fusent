package kg.bishkek.fucent.fusent.security;



import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;


import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;


@Service
public class JwtService {
    private final SecretKey key;
    private final String issuer;
    private final long expiresMinutes;


    public JwtService(
            @Value("${app.jwt.secret}") String secret,
            @Value("${app.jwt.issuer}") String issuer,
            @Value("${app.jwt.expires-in-min}") long expiresMinutes
    ) {
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.issuer = issuer;
        this.expiresMinutes = expiresMinutes;
    }


    public String generate(String subject, String role) {
        var now = Instant.now();
        return Jwts.builder()
                .subject(subject)
                .issuer(issuer)
                .claim("role", role)
                .issuedAt(Date.from(now))
                .expiration(Date.from(now.plusSeconds(60L * expiresMinutes)))
                .signWith(key)
                .compact();
    }


    public String getSubject(String token) {
        return Jwts.parser().verifyWith(key).build().parseSignedClaims(token).getPayload().getSubject();
    }


    public String getRole(String token) {
        return (String) Jwts.parser().verifyWith(key).build().parseSignedClaims(token).getPayload().get("role");
    }
}
