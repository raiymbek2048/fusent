package kg.bishkek.fucent.fusent.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.Instant;

public class AuthDtos {

    public record RegisterRequest(
            @NotBlank(message = "Email is required")
            @Email(message = "Email must be valid")
            String email,

            @NotBlank(message = "Password is required")
            @Size(min = 6, message = "Password must be at least 6 characters")
            String password,

            @NotBlank(message = "Role is required")
            String role // BUYER, SELLER, ADMIN
    ) {}

    public record LoginRequest(
            @NotBlank(message = "Email is required")
            @Email(message = "Email must be valid")
            String email,

            @NotBlank(message = "Password is required")
            String password
    ) {}

    public record RefreshTokenRequest(
            @NotBlank(message = "Refresh token is required")
            String refreshToken
    ) {}

    public record AuthResponse(
            String accessToken,
            String refreshToken,
            String tokenType,
            long expiresIn,
            UserInfo user
    ) {
        public AuthResponse(String accessToken, String refreshToken, long expiresIn, UserInfo user) {
            this(accessToken, refreshToken, "Bearer", expiresIn, user);
        }
    }

    public record UserInfo(
            String id,
            String email,
            String role,
            Instant createdAt
    ) {}

    public record ChangePasswordRequest(
            @NotBlank(message = "Current password is required")
            String currentPassword,

            @NotBlank(message = "New password is required")
            @Size(min = 6, message = "New password must be at least 6 characters")
            String newPassword
    ) {}
}
