package kg.bishkek.fucent.fusent.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "platform_setting", indexes = {
    @Index(name = "idx_platform_setting_key", columnList = "setting_key")
})
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class PlatformSetting {
    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "setting_key", nullable = false, unique = true, length = 100)
    private String settingKey;

    @Column(name = "setting_value", columnDefinition = "TEXT")
    private String settingValue;

    @Column(name = "value_type", nullable = false, length = 20)
    @Builder.Default
    private String valueType = "string"; // string, number, boolean, json

    @Column(columnDefinition = "TEXT")
    private String description;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private Instant updatedAt;
}
