package kg.bishkek.fucent.fusent.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.Instant;

public class AuthDtos {

    public record RegisterRequest(
            @NotBlank(message = "Full name is required")
            String fullName,

            @NotBlank(message = "Email is required")
            @Email(message = "Email must be valid")
            String email,

            @NotBlank(message = "Username is required")
            String username,

            @NotBlank(message = "Phone is required")
            String phone,

            @NotBlank(message = "Password is required")
            String password,

            @NotBlank(message = "Account type is required")
            String accountType, // buyer, seller

            String shopAddress, // Optional, for sellers

            Boolean hasSmartPOS // Optional, for sellers
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
            String fullName,
            String email,
            String username,
            String phone,
            String role,
            String shopId,
            String shopAddress,
            Boolean hasSmartPOS,
            Instant createdAt
    ) {}

    public record ChangePasswordRequest(
            @NotBlank(message = "Current password is required")
            String currentPassword,

            @NotBlank(message = "New password is required")
            String newPassword
    ) {}
}
