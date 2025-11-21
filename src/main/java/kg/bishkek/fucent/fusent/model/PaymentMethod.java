package kg.bishkek.fucent.fusent.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "payment_method")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PaymentMethod {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private AppUser user;

    @Column(nullable = false)
    private String type; // CARD, CASH, ELSOM, MBANK, O_DENGI

    @Column(name = "card_number")
    private String cardNumber; // masked: **** **** **** 1234

    @Column(name = "card_holder")
    private String cardHolder;

    @Column(name = "expiry_date")
    private String expiryDate;

    private String phone; // for mobile wallets

    @Column(name = "is_default")
    private Boolean isDefault = false;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
