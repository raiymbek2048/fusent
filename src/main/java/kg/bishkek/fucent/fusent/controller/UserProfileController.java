package kg.bishkek.fucent.fusent.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kg.bishkek.fucent.fusent.dto.UserProfileDto;
import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@Tag(name = "User Profile", description = "API для управления профилем пользователя")
@RestController
@RequestMapping("/api/v1/profile")
@RequiredArgsConstructor
public class UserProfileController {

    private final AppUserRepository userRepository;

    @Operation(summary = "Получить свой профиль", description = "Получение полной информации о текущем пользователе")
    @GetMapping("/me")
    public ResponseEntity<UserProfileDto.Response> getMyProfile(
            @AuthenticationPrincipal AppUser user
    ) {
        UserProfileDto.Response response = UserProfileDto.Response.builder()
                .id(user.getId().toString())
                .fullName(user.getFullName())
                .username(user.getUsernameField())
                .email(user.getEmail())
                .phone(user.getPhone())
                .role(user.getRole())
                .avatarUrl(user.getAvatarUrl())
                .bio(user.getBio())
                .address(user.getAddress())
                .city(user.getCity())
                .country(user.getCountry())
                .dateOfBirth(user.getDateOfBirth())
                .gender(user.getGender())
                .isVerified(user.getIsVerified())
                .isActive(user.getIsActive())
                .telegramUsername(user.getTelegramUsername())
                .instagramUsername(user.getInstagramUsername())
                .followersCount(user.getFollowersCount())
                .followingCount(user.getFollowingCount())
                .postsCount(user.getPostsCount())
                .shopId(user.getShop() != null ? user.getShop().getId().toString() : null)
                .shopAddress(user.getShopAddress())
                .hasSmartPOS(user.getHasSmartPOS())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();

        return ResponseEntity.ok(response);
    }

    @Operation(summary = "Обновить профиль", description = "Обновление информации профиля пользователя")
    @PutMapping("/me")
    public ResponseEntity<UserProfileDto.Response> updateProfile(
            @AuthenticationPrincipal AppUser user,
            @RequestBody UserProfileDto.UpdateRequest request
    ) {
        // Update user fields
        if (request.getFullName() != null) user.setFullName(request.getFullName());
        if (request.getUsername() != null) user.setUsername(request.getUsername());
        if (request.getPhone() != null) user.setPhone(request.getPhone());
        if (request.getBio() != null) user.setBio(request.getBio());
        if (request.getAddress() != null) user.setAddress(request.getAddress());
        if (request.getCity() != null) user.setCity(request.getCity());
        if (request.getCountry() != null) user.setCountry(request.getCountry());
        if (request.getDateOfBirth() != null) user.setDateOfBirth(request.getDateOfBirth());
        if (request.getGender() != null) user.setGender(request.getGender());
        if (request.getTelegramUsername() != null) user.setTelegramUsername(request.getTelegramUsername());
        if (request.getInstagramUsername() != null) user.setInstagramUsername(request.getInstagramUsername());

        userRepository.save(user);

        return getMyProfile(user);
    }

    @Operation(summary = "Обновить аватар", description = "Обновление URL аватара пользователя")
    @PatchMapping("/me/avatar")
    public ResponseEntity<UserProfileDto.Response> updateAvatar(
            @AuthenticationPrincipal AppUser user,
            @RequestBody UserProfileDto.UpdateAvatarRequest request
    ) {
        user.setAvatarUrl(request.getAvatarUrl());
        userRepository.save(user);

        return getMyProfile(user);
    }

    @Operation(summary = "Получить публичный профиль", description = "Получение публичной информации о пользователе по ID")
    @GetMapping("/{userId}")
    public ResponseEntity<UserProfileDto.PublicProfile> getPublicProfile(
            @PathVariable String userId
    ) {
        // TODO: Load user from repository by ID

        // For now, return mock response
        UserProfileDto.PublicProfile response = UserProfileDto.PublicProfile.builder()
                .id(userId)
                .fullName("Mock User")
                .username("mockuser")
                .bio("This is a mock profile")
                .isVerified(false)
                .followersCount(0)
                .followingCount(0)
                .postsCount(0)
                .build();

        return ResponseEntity.ok(response);
    }
}
