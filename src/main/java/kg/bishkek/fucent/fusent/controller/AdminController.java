package kg.bishkek.fucent.fusent.controller;

import kg.bishkek.fucent.fusent.dto.AdminDtos.*;
import kg.bishkek.fucent.fusent.enums.MerchantApprovalStatus;
import kg.bishkek.fucent.fusent.enums.OrderStatus;
import kg.bishkek.fucent.fusent.enums.PostStatus;
import kg.bishkek.fucent.fusent.enums.Role;
import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.Merchant;
import kg.bishkek.fucent.fusent.model.Post;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.repository.*;
import kg.bishkek.fucent.fusent.service.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AppUserRepository userRepository;
    private final MerchantRepository merchantRepository;
    private final ProductRepository productRepository;
    private final PostRepository postRepository;
    private final OrderRepository orderRepository;
    private final JwtService jwtService;

    // ========== Dashboard Stats ==========
    @GetMapping("/stats")
    public ResponseEntity<?> getDashboardStats(@RequestHeader("Authorization") String authHeader) {
        if (!isAdmin(authHeader)) {
            return ResponseEntity.status(403).body(Map.of("error", "Access denied"));
        }

        DashboardStats stats = DashboardStats.builder()
                .totalUsers(userRepository.count())
                .totalSellers(userRepository.countByRole(Role.SELLER))
                .totalMerchants(merchantRepository.count())
                .pendingMerchants(merchantRepository.countByApprovalStatus(MerchantApprovalStatus.PENDING))
                .totalProducts(productRepository.count())
                .blockedProducts(productRepository.countByBlocked(true))
                .totalOrders(orderRepository.count())
                .pendingOrders(orderRepository.countByStatus(OrderStatus.CREATED))
                .build();

        return ResponseEntity.ok(stats);
    }

    // ========== Users Management ==========
    @GetMapping("/users")
    public ResponseEntity<?> getUsers(
            @RequestHeader("Authorization") String authHeader,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String role,
            @RequestParam(required = false) Boolean blocked) {
        if (!isAdmin(authHeader)) {
            return ResponseEntity.status(403).body(Map.of("error", "Access denied"));
        }

        Page<AppUser> users;
        PageRequest pageRequest = PageRequest.of(page, size);

        if (role != null && blocked != null) {
            users = userRepository.findByRoleAndBlocked(Role.valueOf(role), blocked, pageRequest);
        } else if (role != null) {
            users = userRepository.findByRole(Role.valueOf(role), pageRequest);
        } else if (blocked != null) {
            users = userRepository.findByBlocked(blocked, pageRequest);
        } else {
            users = userRepository.findAll(pageRequest);
        }

        return ResponseEntity.ok(users.map(this::toUserAdminResponse));
    }

    @PostMapping("/users/{userId}/block")
    public ResponseEntity<?> blockUser(
            @RequestHeader("Authorization") String authHeader,
            @PathVariable UUID userId,
            @RequestBody BlockRequest request) {
        if (!isAdmin(authHeader)) {
            return ResponseEntity.status(403).body(Map.of("error", "Access denied"));
        }

        AppUser user = userRepository.findById(userId).orElse(null);
        if (user == null) {
            return ResponseEntity.notFound().build();
        }

        user.setBlocked(true);
        user.setBlockedAt(Instant.now());
        user.setBlockedReason(request.getReason());
        userRepository.save(user);

        return ResponseEntity.ok(Map.of("message", "User blocked successfully"));
    }

    @PostMapping("/users/{userId}/unblock")
    public ResponseEntity<?> unblockUser(
            @RequestHeader("Authorization") String authHeader,
            @PathVariable UUID userId) {
        if (!isAdmin(authHeader)) {
            return ResponseEntity.status(403).body(Map.of("error", "Access denied"));
        }

        AppUser user = userRepository.findById(userId).orElse(null);
        if (user == null) {
            return ResponseEntity.notFound().build();
        }

        user.setBlocked(false);
        user.setBlockedAt(null);
        user.setBlockedReason(null);
        userRepository.save(user);

        return ResponseEntity.ok(Map.of("message", "User unblocked successfully"));
    }

    // ========== Merchants Management ==========
    @GetMapping("/merchants")
    public ResponseEntity<?> getMerchants(
            @RequestHeader("Authorization") String authHeader,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String status) {
        if (!isAdmin(authHeader)) {
            return ResponseEntity.status(403).body(Map.of("error", "Access denied"));
        }

        Page<Merchant> merchants;
        PageRequest pageRequest = PageRequest.of(page, size);

        if (status != null) {
            merchants = merchantRepository.findByApprovalStatus(
                    MerchantApprovalStatus.valueOf(status), pageRequest);
        } else {
            merchants = merchantRepository.findAll(pageRequest);
        }

        return ResponseEntity.ok(merchants.map(this::toMerchantAdminResponse));
    }

    @PostMapping("/merchants/{merchantId}/approve")
    public ResponseEntity<?> approveMerchant(
            @RequestHeader("Authorization") String authHeader,
            @PathVariable UUID merchantId,
            @RequestBody MerchantApprovalRequest request) {
        if (!isAdmin(authHeader)) {
            return ResponseEntity.status(403).body(Map.of("error", "Access denied"));
        }

        Merchant merchant = merchantRepository.findById(merchantId).orElse(null);
        if (merchant == null) {
            return ResponseEntity.notFound().build();
        }

        UUID adminId = extractUserId(authHeader);
        merchant.setApprovalStatus(request.getStatus());
        merchant.setApprovalNote(request.getNote());
        merchant.setApprovedAt(Instant.now());
        merchant.setApprovedBy(adminId);

        if (request.getStatus() == MerchantApprovalStatus.APPROVED) {
            merchant.setIsVerified(true);
        }

        merchantRepository.save(merchant);

        return ResponseEntity.ok(Map.of("message", "Merchant " + request.getStatus().name().toLowerCase()));
    }

    @PostMapping("/merchants/{merchantId}/block")
    public ResponseEntity<?> blockMerchant(
            @RequestHeader("Authorization") String authHeader,
            @PathVariable UUID merchantId,
            @RequestBody BlockRequest request) {
        if (!isAdmin(authHeader)) {
            return ResponseEntity.status(403).body(Map.of("error", "Access denied"));
        }

        Merchant merchant = merchantRepository.findById(merchantId).orElse(null);
        if (merchant == null) {
            return ResponseEntity.notFound().build();
        }

        merchant.setBlocked(true);
        merchant.setBlockedAt(Instant.now());
        merchant.setBlockedReason(request.getReason());
        merchantRepository.save(merchant);

        return ResponseEntity.ok(Map.of("message", "Merchant blocked successfully"));
    }

    @PostMapping("/merchants/{merchantId}/unblock")
    public ResponseEntity<?> unblockMerchant(
            @RequestHeader("Authorization") String authHeader,
            @PathVariable UUID merchantId) {
        if (!isAdmin(authHeader)) {
            return ResponseEntity.status(403).body(Map.of("error", "Access denied"));
        }

        Merchant merchant = merchantRepository.findById(merchantId).orElse(null);
        if (merchant == null) {
            return ResponseEntity.notFound().build();
        }

        merchant.setBlocked(false);
        merchant.setBlockedAt(null);
        merchant.setBlockedReason(null);
        merchantRepository.save(merchant);

        return ResponseEntity.ok(Map.of("message", "Merchant unblocked successfully"));
    }

    // ========== Products Management ==========
    @GetMapping("/products")
    public ResponseEntity<?> getProducts(
            @RequestHeader("Authorization") String authHeader,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) Boolean blocked) {
        if (!isAdmin(authHeader)) {
            return ResponseEntity.status(403).body(Map.of("error", "Access denied"));
        }

        Page<Product> products;
        PageRequest pageRequest = PageRequest.of(page, size);

        if (blocked != null) {
            products = productRepository.findByBlocked(blocked, pageRequest);
        } else {
            products = productRepository.findAll(pageRequest);
        }

        return ResponseEntity.ok(products.map(this::toProductAdminResponse));
    }

    @PostMapping("/products/{productId}/block")
    public ResponseEntity<?> blockProduct(
            @RequestHeader("Authorization") String authHeader,
            @PathVariable UUID productId,
            @RequestBody BlockRequest request) {
        if (!isAdmin(authHeader)) {
            return ResponseEntity.status(403).body(Map.of("error", "Access denied"));
        }

        Product product = productRepository.findById(productId).orElse(null);
        if (product == null) {
            return ResponseEntity.notFound().build();
        }

        product.setBlocked(true);
        product.setBlockedAt(Instant.now());
        product.setBlockedReason(request.getReason());
        productRepository.save(product);

        return ResponseEntity.ok(Map.of("message", "Product blocked successfully"));
    }

    @PostMapping("/products/{productId}/unblock")
    public ResponseEntity<?> unblockProduct(
            @RequestHeader("Authorization") String authHeader,
            @PathVariable UUID productId) {
        if (!isAdmin(authHeader)) {
            return ResponseEntity.status(403).body(Map.of("error", "Access denied"));
        }

        Product product = productRepository.findById(productId).orElse(null);
        if (product == null) {
            return ResponseEntity.notFound().build();
        }

        product.setBlocked(false);
        product.setBlockedAt(null);
        product.setBlockedReason(null);
        productRepository.save(product);

        return ResponseEntity.ok(Map.of("message", "Product unblocked successfully"));
    }

    // ========== Posts Management ==========
    @PostMapping("/posts/{postId}/block")
    public ResponseEntity<?> blockPost(
            @RequestHeader("Authorization") String authHeader,
            @PathVariable UUID postId,
            @RequestBody BlockRequest request) {
        if (!isAdmin(authHeader)) {
            return ResponseEntity.status(403).body(Map.of("error", "Access denied"));
        }

        Post post = postRepository.findById(postId).orElse(null);
        if (post == null) {
            return ResponseEntity.notFound().build();
        }

        post.setStatus(PostStatus.BLOCKED);
        postRepository.save(post);

        return ResponseEntity.ok(Map.of("message", "Post blocked successfully"));
    }

    @PostMapping("/posts/{postId}/unblock")
    public ResponseEntity<?> unblockPost(
            @RequestHeader("Authorization") String authHeader,
            @PathVariable UUID postId) {
        if (!isAdmin(authHeader)) {
            return ResponseEntity.status(403).body(Map.of("error", "Access denied"));
        }

        Post post = postRepository.findById(postId).orElse(null);
        if (post == null) {
            return ResponseEntity.notFound().build();
        }

        post.setStatus(PostStatus.ACTIVE);
        postRepository.save(post);

        return ResponseEntity.ok(Map.of("message", "Post unblocked successfully"));
    }

    // ========== Helper Methods ==========
    private boolean isAdmin(String authHeader) {
        try {
            String token = authHeader.replace("Bearer ", "");
            String email = jwtService.extractUsername(token);
            AppUser user = userRepository.findByEmail(email).orElse(null);
            return user != null && user.getRole() == Role.ADMIN;
        } catch (Exception e) {
            return false;
        }
    }

    private UUID extractUserId(String authHeader) {
        try {
            String token = authHeader.replace("Bearer ", "");
            String email = jwtService.extractUsername(token);
            AppUser user = userRepository.findByEmail(email).orElse(null);
            return user != null ? user.getId() : null;
        } catch (Exception e) {
            return null;
        }
    }

    private UserAdminResponse toUserAdminResponse(AppUser user) {
        return UserAdminResponse.builder()
                .id(user.getId())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .role(user.getRole().name())
                .blocked(user.getBlocked())
                .blockedAt(user.getBlockedAt())
                .blockedReason(user.getBlockedReason())
                .isVerified(user.getIsVerified())
                .createdAt(user.getCreatedAt())
                .build();
    }

    private MerchantAdminResponse toMerchantAdminResponse(Merchant merchant) {
        AppUser owner = userRepository.findById(merchant.getOwnerUserId()).orElse(null);
        return MerchantAdminResponse.builder()
                .id(merchant.getId())
                .name(merchant.getName())
                .description(merchant.getDescription())
                .ownerUserId(merchant.getOwnerUserId())
                .ownerEmail(owner != null ? owner.getEmail() : null)
                .blocked(merchant.getBlocked())
                .blockedAt(merchant.getBlockedAt())
                .blockedReason(merchant.getBlockedReason())
                .approvalStatus(merchant.getApprovalStatus())
                .approvalNote(merchant.getApprovalNote())
                .approvedAt(merchant.getApprovedAt())
                .isVerified(merchant.getIsVerified())
                .createdAt(merchant.getCreatedAt())
                .build();
    }

    private ProductAdminResponse toProductAdminResponse(Product product) {
        return ProductAdminResponse.builder()
                .id(product.getId())
                .name(product.getName())
                .shopName(product.getShop() != null ? product.getShop().getName() : null)
                .shopId(product.getShop() != null ? product.getShop().getId() : null)
                .blocked(product.getBlocked())
                .blockedAt(product.getBlockedAt())
                .blockedReason(product.getBlockedReason())
                .active(product.isActive())
                .createdAt(product.getCreatedAt())
                .build();
    }
}
