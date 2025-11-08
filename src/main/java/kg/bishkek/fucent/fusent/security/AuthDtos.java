package kg.bishkek.fucent.fusent.security;



import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import kg.bishkek.fucent.fusent.enums.Role;


public class AuthDtos {
    public record RegisterRequest(
            @Email @NotBlank String email,
            @NotBlank String password,
            @NotNull Role role
    ) {}
    public record LoginRequest(@Email @NotBlank String email, @NotBlank String password) {}
    public record JwtResponse(String token) {}
}
