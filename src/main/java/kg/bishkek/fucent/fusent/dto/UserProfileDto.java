package kg.bishkek.fucent.fusent.dto;

import kg.bishkek.fucent.fusent.enums.Role;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

public class UserProfileDto {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Response {
        private String id;
        private String fullName;
        private String username;
        private String email;
        private String phone;
        private Role role;

        // Profile fields
        private String avatarUrl;
        private String bio;
        private String address;
        private String city;
        private String country;
        private String dateOfBirth;
        private String gender;

        // Status
        private Boolean isVerified;
        private Boolean isActive;

        // Social links
        private String telegramUsername;
        private String instagramUsername;

        // Statistics
        private Integer followersCount;
        private Integer followingCount;
        private Integer postsCount;

        // Shop info (if seller)
        private String shopId;
        private String shopAddress;
        private Boolean hasSmartPOS;

        // Timestamps
        private Instant createdAt;
        private Instant updatedAt;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UpdateRequest {
        private String fullName;
        private String username;
        private String phone;
        private String bio;
        private String address;
        private String city;
        private String country;
        private String dateOfBirth;
        private String gender; // MALE, FEMALE, OTHER
        private String telegramUsername;
        private String instagramUsername;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UpdateAvatarRequest {
        private String avatarUrl;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PublicProfile {
        private String id;
        private String fullName;
        private String username;
        private String avatarUrl;
        private String bio;
        private Boolean isVerified;

        // Statistics
        private Integer followersCount;
        private Integer followingCount;
        private Integer postsCount;

        // Social links
        private String telegramUsername;
        private String instagramUsername;

        // Shop info (if seller)
        private String shopId;
        private Role role;
    }
}
