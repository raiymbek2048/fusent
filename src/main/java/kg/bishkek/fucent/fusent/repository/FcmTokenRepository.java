package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.FcmToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface FcmTokenRepository extends JpaRepository<FcmToken, String> {

    Optional<FcmToken> findByToken(String token);

    List<FcmToken> findByUserAndIsActiveTrue(AppUser user);

    List<FcmToken> findByUserIdAndIsActiveTrue(UUID userId);

    Optional<FcmToken> findByUserAndDeviceId(AppUser user, String deviceId);

    void deleteByToken(String token);
}
