package kg.bishkek.fucent.fusent.model;



import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;


import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalTime;
import java.util.UUID;


@Entity
@Table(name = "shop")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Shop {
    @Id @GeneratedValue
    private UUID id;
    @ManyToOne(optional = false)
    private AppUser owner;
    private String description;
    private String city;
    private BigDecimal geoLat;
    private BigDecimal geoLon;
    private LocalTime openTime;
    private LocalTime closeTime;
    private String daysOfWeek;
    @Column(nullable = false)
    private Boolean active = true;
    @ManyToOne(optional = false)
    private Merchant merchant;


    @Column(nullable = false)
    private String name;


    private String address;
    private String phone;


    private Double lat;
    private Double lon;


    @Column(nullable = false)
    private String posStatus = "inactive"; // inactive|active


    @CreationTimestamp
    private Instant createdAt;
}
