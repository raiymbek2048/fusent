package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.AuthDtos.*;
import kg.bishkek.fucent.fusent.enums.Role;
import kg.bishkek.fucent.fusent.exception.UnauthorizedException;
import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.Merchant;
import kg.bishkek.fucent.fusent.model.Shop;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import kg.bishkek.fucent.fusent.repository.MerchantRepository;
import kg.bishkek.fucent.fusent.repository.ShopRepository;
import kg.bishkek.fucent.fusent.service.AuthService;
import kg.bishkek.fucent.fusent.service.JwtService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthServiceImpl implements AuthService {

    private final AppUserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final MerchantRepository merchantRepository;
    private final ShopRepository shopRepository;

    @Value("${jwt.expiration:86400000}")
    private long jwtExpiration;

    @Override
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        // Check if user already exists
        if (userRepository.existsByEmail(request.email())) {
            throw new IllegalArgumentException("Email already registered");
        }

        // Validate account type and convert to role
        Role role;
        try {
            // Mobile app sends "buyer" or "seller", need to convert to uppercase
            role = Role.valueOf(request.accountType().toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Invalid account type. Must be buyer or seller");
        }

        // Create new user
        var user = AppUser.builder()
                .fullName(request.fullName())
                .email(request.email())
                .username(request.username())
                .phone(request.phone())
                .passwordHash(passwordEncoder.encode(request.password()))
                .role(role)
                .shopAddress(request.shopAddress())
                .hasSmartPOS(request.hasSmartPOS())
                .build();

        user = userRepository.save(user);

        // If user is SELLER, create Merchant and main Shop (головной филиал)
        if (role == Role.SELLER) {
            // Create Merchant
            String merchantName = request.fullName() + "'s Business";
            String merchantDescription = "Магазин " + request.fullName();

            var merchant = Merchant.builder()
                    .ownerUserId(user.getId())
                    .name(merchantName)
                    .description(merchantDescription)
                    .build();

            merchant = merchantRepository.save(merchant);
            log.info("Created merchant for seller: merchantId={}, name={}", merchant.getId(), merchant.getName());

            // Create main Shop (головной филиал)
            String shopName = request.fullName();
            String shopAddress = request.shopAddress() != null && !request.shopAddress().isBlank()
                    ? request.shopAddress()
                    : "Главный офис";

            var shop = Shop.builder()
                    .merchant(merchant)
                    .name(shopName)
                    .address(shopAddress)
                    .phone(request.phone())
                    .build();

            shop = shopRepository.save(shop);
            log.info("Created main shop for seller: shopId={}, name={}", shop.getId(), shop.getName());

            // Link user to the created shop
            user.setShop(shop);
            user = userRepository.save(user);
        }

        // Generate tokens
        var accessToken = jwtService.generateToken(user);
        var refreshToken = jwtService.generateRefreshToken(user);

        log.info("New user registered: email={}, role={}, username={}", user.getEmail(), user.getRole(), user.getUsernameField());

        return new AuthResponse(
                accessToken,
                refreshToken,
                jwtExpiration / 1000, // convert to seconds
                toUserInfo(user)
        );
    }

    @Override
    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest request) {
        // Authenticate user
        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.email(),
                            request.password()
                    )
            );
        } catch (Exception e) {
            log.error("Login failed for email: {}", request.email());
            throw new UnauthorizedException("Invalid email or password");
        }

        // Load user
        var user = userRepository.findByEmail(request.email())
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        // Generate tokens
        var accessToken = jwtService.generateToken(user);
        var refreshToken = jwtService.generateRefreshToken(user);

        log.info("User logged in: email={}", user.getEmail());

        return new AuthResponse(
                accessToken,
                refreshToken,
                jwtExpiration / 1000,
                toUserInfo(user)
        );
    }

    @Override
    @Transactional(readOnly = true)
    public AuthResponse refreshToken(RefreshTokenRequest request) {
        final String userEmail = jwtService.extractUsername(request.refreshToken());

        if (userEmail == null) {
            throw new UnauthorizedException("Invalid refresh token");
        }

        var user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        if (!jwtService.isTokenValid(request.refreshToken(), user)) {
            throw new UnauthorizedException("Invalid or expired refresh token");
        }

        var accessToken = jwtService.generateToken(user);
        var newRefreshToken = jwtService.generateRefreshToken(user);

        log.info("Token refreshed for user: email={}", user.getEmail());

        return new AuthResponse(
                accessToken,
                newRefreshToken,
                jwtExpiration / 1000,
                toUserInfo(user)
        );
    }

    @Override
    @Transactional
    public void changePassword(ChangePasswordRequest request) {
        // Get current authenticated user
        var authentication = org.springframework.security.core.context.SecurityContextHolder
                .getContext()
                .getAuthentication();

        if (authentication == null || !authentication.isAuthenticated()) {
            throw new UnauthorizedException("User not authenticated");
        }

        var userEmail = authentication.getName();
        var user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        // Verify current password
        if (!passwordEncoder.matches(request.currentPassword(), user.getPasswordHash())) {
            throw new UnauthorizedException("Current password is incorrect");
        }

        // Update password
        user.setPasswordHash(passwordEncoder.encode(request.newPassword()));
        userRepository.save(user);

        log.info("Password changed for user: email={}", user.getEmail());
    }

    private UserInfo toUserInfo(AppUser user) {
        String shopId = user.getShop() != null ? user.getShop().getId().toString() : null;
        return new UserInfo(
                user.getId().toString(),
                user.getFullName(),
                user.getEmail(),
                user.getUsernameField(),
                user.getPhone(),
                user.getRole().name(),
                shopId,
                user.getShopAddress(),
                user.getHasSmartPOS(),
                user.getCreatedAt()
        );
    }
}
