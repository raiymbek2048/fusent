package kg.bishkek.fucent.fusent.controller;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import kg.bishkek.fucent.fusent.enums.FollowTargetType;
import kg.bishkek.fucent.fusent.enums.OwnerType;
import kg.bishkek.fucent.fusent.enums.PostStatus;
import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.Follow;
import kg.bishkek.fucent.fusent.model.Post;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import kg.bishkek.fucent.fusent.repository.FollowRepository;
import kg.bishkek.fucent.fusent.repository.PostRepository;
import kg.bishkek.fucent.fusent.security.SecurityUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/debug")
@RequiredArgsConstructor
public class DebugController {

    private final FollowRepository followRepository;
    private final PostRepository postRepository;
    private final AppUserRepository userRepository;

    @PersistenceContext
    private EntityManager entityManager;

    @GetMapping("/follows-check")
    public ResponseEntity<Map<String, Object>> checkFollows() {
        Map<String, Object> result = new HashMap<>();

        try {
            var currentUserId = SecurityUtil.currentUserId(userRepository);
            var currentUser = userRepository.findById(currentUserId).orElseThrow();

            result.put("currentUser", Map.of(
                "id", currentUser.getId(),
                "email", currentUser.getEmail(),
                "role", currentUser.getRole()
            ));

            // 1. Все подписки текущего пользователя
            List<Follow> follows = followRepository.findByFollower(currentUser);
            result.put("myFollows", follows.stream().map(f -> Map.of(
                "id", f.getId(),
                "targetType", f.getTargetType(),
                "targetId", f.getTargetId(),
                "createdAt", f.getCreatedAt()
            )).toList());

            // 2. Все посты
            List<Post> allPosts = postRepository.findAll();
            result.put("allPosts", allPosts.stream().map(p -> Map.of(
                "id", p.getId(),
                "ownerType", p.getOwnerType(),
                "ownerId", p.getOwnerId(),
                "text", p.getText() != null ? p.getText() : "",
                "status", p.getStatus(),
                "createdAt", p.getCreatedAt()
            )).toList());

            // 3. Посты от подписок (используя репозиторий)
            var followingPosts = postRepository.findFollowingFeedByUser(
                currentUserId,
                PostStatus.ACTIVE,
                PageRequest.of(0, 20)
            );
            result.put("followingFeedPosts", followingPosts.stream().map(p -> Map.of(
                "id", p.getId(),
                "ownerType", p.getOwnerType(),
                "ownerId", p.getOwnerId(),
                "text", p.getText() != null ? p.getText() : "",
                "status", p.getStatus(),
                "createdAt", p.getCreatedAt()
            )).toList());

            // 4. Ручной запрос для проверки
            String sql = """
                SELECT p.id, p.owner_type, p.owner_id, p.text, p.status
                FROM post p
                WHERE EXISTS (
                    SELECT 1 FROM follow f
                    WHERE f.follower_id = :followerId
                    AND (
                        (f.target_type = 'MERCHANT' AND p.owner_type = 'MERCHANT' AND p.owner_id = f.target_id)
                        OR
                        (f.target_type = 'USER' AND p.owner_type = 'USER' AND p.owner_id = f.target_id)
                    )
                )
                AND p.status = 'ACTIVE'
                ORDER BY p.created_at DESC
                LIMIT 20
                """;

            var nativeQuery = entityManager.createNativeQuery(sql);
            nativeQuery.setParameter("followerId", currentUserId);
            List<Object[]> manualResults = nativeQuery.getResultList();

            result.put("manualQueryResults", manualResults.stream().map(row -> Map.of(
                "id", row[0],
                "ownerType", row[1],
                "ownerId", row[2],
                "text", row[3] != null ? row[3] : "",
                "status", row[4]
            )).toList());

            // 5. Проверка конкретных комбинаций
            if (!follows.isEmpty()) {
                Follow firstFollow = follows.get(0);
                OwnerType matchingOwnerType = firstFollow.getTargetType() == FollowTargetType.MERCHANT
                    ? OwnerType.MERCHANT
                    : OwnerType.USER;

                List<Post> matchingPosts = postRepository.findByOwnerTypeAndOwnerId(
                    matchingOwnerType,
                    firstFollow.getTargetId()
                );

                result.put("directMatchCheck", Map.of(
                    "followTargetType", firstFollow.getTargetType(),
                    "followTargetId", firstFollow.getTargetId(),
                    "searchedOwnerType", matchingOwnerType,
                    "foundPosts", matchingPosts.stream().map(p -> Map.of(
                        "id", p.getId(),
                        "ownerType", p.getOwnerType(),
                        "ownerId", p.getOwnerId(),
                        "text", p.getText() != null ? p.getText() : "",
                        "status", p.getStatus()
                    )).toList()
                ));
            }

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            result.put("error", e.getMessage());
            result.put("stackTrace", e.getStackTrace());
            return ResponseEntity.internalServerError().body(result);
        }
    }

    @GetMapping("/all-follows")
    public ResponseEntity<Map<String, Object>> getAllFollows() {
        Map<String, Object> result = new HashMap<>();

        try {
            // Все подписки в системе
            List<Follow> allFollows = followRepository.findAll();
            result.put("allFollows", allFollows.stream().map(f -> {
                var follower = f.getFollower();
                return Map.of(
                    "id", f.getId(),
                    "followerId", follower.getId(),
                    "followerEmail", follower.getEmail(),
                    "targetType", f.getTargetType(),
                    "targetId", f.getTargetId(),
                    "createdAt", f.getCreatedAt()
                );
            }).toList());

            // Все пользователи
            List<AppUser> allUsers = userRepository.findAll();
            result.put("allUsers", allUsers.stream().map(u -> Map.of(
                "id", u.getId(),
                "email", u.getEmail(),
                "role", u.getRole()
            )).toList());

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            result.put("error", e.getMessage());
            return ResponseEntity.internalServerError().body(result);
        }
    }
}
