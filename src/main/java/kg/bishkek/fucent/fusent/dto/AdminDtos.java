package kg.bishkek.fucent.fusent.dto;

import kg.bishkek.fucent.fusent.enums.MerchantApprovalStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.UUID;

public class AdminDtos {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class BlockRequest {
        private String reason;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MerchantApprovalRequest {
        private MerchantApprovalStatus status;
        private String note;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UserAdminResponse {
        private UUID id;
        private String email;
        private String fullName;
        private String role;
        private Boolean blocked;
        private Instant blockedAt;
        private String blockedReason;
        private Boolean isVerified;
        private Instant createdAt;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MerchantAdminResponse {
        private UUID id;
        private String name;
        private String description;
        private UUID ownerUserId;
        private String ownerEmail;
        private Boolean blocked;
        private Instant blockedAt;
        private String blockedReason;
        private MerchantApprovalStatus approvalStatus;
        private String approvalNote;
        private Instant approvedAt;
        private Boolean isVerified;
        private Instant createdAt;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ProductAdminResponse {
        private UUID id;
        private String name;
        private String shopName;
        private UUID shopId;
        private Boolean blocked;
        private Instant blockedAt;
        private String blockedReason;
        private Boolean active;
        private Instant createdAt;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DashboardStats {
        private long totalUsers;
        private long totalSellers;
        private long totalMerchants;
        private long pendingMerchants;
        private long totalProducts;
        private long blockedProducts;
        private long totalOrders;
        private long pendingOrders;
    }
}
