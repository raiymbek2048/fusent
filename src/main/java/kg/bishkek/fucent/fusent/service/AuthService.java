package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.AuthDtos.*;

public interface AuthService {
    AuthResponse register(RegisterRequest request);

    AuthResponse login(LoginRequest request);

    AuthResponse refreshToken(RefreshTokenRequest request);

    void changePassword(ChangePasswordRequest request);
}
