package kg.bishkek.fucent.fusent.controller;

import kg.bishkek.fucent.fusent.enums.FollowTargetType;
import kg.bishkek.fucent.fusent.enums.OwnerType;
import kg.bishkek.fucent.fusent.enums.PostStatus;
import kg.bishkek.fucent.fusent.enums.PostType;
import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.Follow;
import kg.bishkek.fucent.fusent.model.Merchant;
import kg.bishkek.fucent.fusent.model.Post;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import kg.bishkek.fucent.fusent.repository.FollowRepository;
import kg.bishkek.fucent.fusent.repository.MerchantRepository;
import kg.bishkek.fucent.fusent.repository.PostRepository;
import kg.bishkek.fucent.fusent.security.SecurityUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/test-data")
@RequiredArgsConstructor
public class TestDataController {

    private final FollowRepository followRepository;
    private final PostRepository postRepository;
    private final AppUserRepository userRepository;
    private final MerchantRepository merchantRepository;

    @PostMapping("/follow-seller")
    @Transactional
    public ResponseEntity<Map<String, Object>> followSeller() {
        Map<String, Object> result = new HashMap<>();

        try {
            var currentUserId = SecurityUtil.currentUserId(userRepository);
            var currentUser = userRepository.findById(currentUserId).orElseThrow();

            // Находим seller пользователя
            var seller = userRepository.findByEmail("seller@fusent.kg")
                .orElseThrow(() -> new RuntimeException("Seller not found"));

            // Находим merchant продавца
            var merchant = merchantRepository.findAll().stream()
                .filter(m -> m.getOwner().getId().equals(seller.getId()))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Merchant not found"));

            // Создаем подписку на merchant
            var existingFollow = followRepository.findByFollowerAndTargetTypeAndTargetId(
                currentUser, FollowTargetType.MERCHANT, merchant.getId()
            );

            Follow merchantFollow;
            if (existingFollow.isEmpty()) {
                merchantFollow = Follow.builder()
                    .follower(currentUser)
                    .targetType(FollowTargetType.MERCHANT)
                    .targetId(merchant.getId())
                    .build();
                merchantFollow = followRepository.save(merchantFollow);
                result.put("merchantFollowCreated", true);
            } else {
                merchantFollow = existingFollow.get();
                result.put("merchantFollowCreated", false);
                result.put("merchantFollowAlreadyExists", true);
            }

            // Создаем подписку на seller как USER
            var existingUserFollow = followRepository.findByFollowerAndTargetTypeAndTargetId(
                currentUser, FollowTargetType.USER, seller.getId()
            );

            Follow userFollow;
            if (existingUserFollow.isEmpty()) {
                userFollow = Follow.builder()
                    .follower(currentUser)
                    .targetType(FollowTargetType.USER)
                    .targetId(seller.getId())
                    .build();
                userFollow = followRepository.save(userFollow);
                result.put("userFollowCreated", true);
            } else {
                userFollow = existingUserFollow.get();
                result.put("userFollowCreated", false);
                result.put("userFollowAlreadyExists", true);
            }

            result.put("currentUser", currentUser.getEmail());
            result.put("merchantFollow", Map.of(
                "id", merchantFollow.getId(),
                "targetType", merchantFollow.getTargetType(),
                "targetId", merchantFollow.getTargetId(),
                "merchantName", merchant.getName()
            ));
            result.put("userFollow", Map.of(
                "id", userFollow.getId(),
                "targetType", userFollow.getTargetType(),
                "targetId", userFollow.getTargetId(),
                "sellerEmail", seller.getEmail()
            ));

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            result.put("error", e.getMessage());
            return ResponseEntity.internalServerError().body(result);
        }
    }

    @PostMapping("/create-test-posts")
    @Transactional
    public ResponseEntity<Map<String, Object>> createTestPosts() {
        Map<String, Object> result = new HashMap<>();

        try {
            // Находим seller
            var seller = userRepository.findByEmail("seller@fusent.kg")
                .orElseThrow(() -> new RuntimeException("Seller not found"));

            // Находим merchant
            var merchant = merchantRepository.findAll().stream()
                .filter(m -> m.getOwner().getId().equals(seller.getId()))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Merchant not found"));

            // Создаем пост от MERCHANT
            Post merchantPost = Post.builder()
                .ownerType(OwnerType.MERCHANT)
                .ownerId(merchant.getId())
                .text("Тестовый пост от магазина: " + merchant.getName())
                .postType(PostType.PHOTO)
                .status(PostStatus.ACTIVE)
                .build();
            merchantPost = postRepository.save(merchantPost);

            // Создаем пост от USER (seller)
            Post userPost = Post.builder()
                .ownerType(OwnerType.USER)
                .ownerId(seller.getId())
                .text("Тестовый пост от пользователя: " + seller.getEmail())
                .postType(PostType.PHOTO)
                .status(PostStatus.ACTIVE)
                .build();
            userPost = postRepository.save(userPost);

            result.put("merchantPost", Map.of(
                "id", merchantPost.getId(),
                "ownerType", merchantPost.getOwnerType(),
                "ownerId", merchantPost.getOwnerId(),
                "text", merchantPost.getText(),
                "status", merchantPost.getStatus()
            ));

            result.put("userPost", Map.of(
                "id", userPost.getId(),
                "ownerType", userPost.getOwnerType(),
                "ownerId", userPost.getOwnerId(),
                "text", userPost.getText(),
                "status", userPost.getStatus()
            ));

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            result.put("error", e.getMessage());
            return ResponseEntity.internalServerError().body(result);
        }
    }

    @DeleteMapping("/cleanup")
    @Transactional
    public ResponseEntity<Map<String, Object>> cleanup() {
        Map<String, Object> result = new HashMap<>();

        try {
            var currentUserId = SecurityUtil.currentUserId(userRepository);
            var currentUser = userRepository.findById(currentUserId).orElseThrow();

            // Удаляем все подписки текущего пользователя
            var follows = followRepository.findByFollower(currentUser);
            followRepository.deleteAll(follows);

            result.put("deletedFollows", follows.size());
            result.put("message", "Все подписки удалены");

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            result.put("error", e.getMessage());
            return ResponseEntity.internalServerError().body(result);
        }
    }
}
