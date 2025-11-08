package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.enums.FollowTargetType;
import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.Follow;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface FollowRepository extends JpaRepository<Follow, UUID> {
    Optional<Follow> findByFollowerAndTargetTypeAndTargetId(
        AppUser follower, FollowTargetType targetType, UUID targetId);

    List<Follow> findByFollower(AppUser follower);

    List<Follow> findByTargetTypeAndTargetId(FollowTargetType targetType, UUID targetId);

    long countByTargetTypeAndTargetId(FollowTargetType targetType, UUID targetId);

    boolean existsByFollowerAndTargetTypeAndTargetId(
        AppUser follower, FollowTargetType targetType, UUID targetId);
}
