package kg.bishkek.fucent.fusent.repository;

import kg.bishkek.fucent.fusent.model.PlatformSetting;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface PlatformSettingRepository extends JpaRepository<PlatformSetting, UUID> {
    Optional<PlatformSetting> findBySettingKey(String settingKey);
}
