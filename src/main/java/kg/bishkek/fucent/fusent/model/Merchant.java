package kg.bishkek.fucent.fusent.model;



import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;


import java.time.Instant;
import java.util.UUID;


@Entity
@Table(name = "merchant")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Merchant {
    @Id
    @GeneratedValue
    private UUID id;


    @Column(name = "owner_id", nullable = false)
    private UUID ownerUserId;


    @Column(nullable = false)
    private String name;


    private String description;


    private String payoutAccountNumber; // nullable
    private String payoutBankName; // nullable


    @Builder.Default
    @Column(nullable = false)
    private String payoutStatus = "pending"; // pending|active|suspended


    @Builder.Default
    @Column(nullable = false)
    private String buyEligibility = "manual_contact"; // manual_contact|online_purchase


    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private String settingsJson; // posEnabled, inventoryMode

    private String logoUrl; // nullable

    private String bannerUrl; // nullable

    @Builder.Default
    @Column(nullable = false)
    private Boolean isVerified = false;

    @CreationTimestamp
    private Instant createdAt;

    @UpdateTimestamp
    private Instant updatedAt;
}