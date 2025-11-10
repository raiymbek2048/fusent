package kg.bishkek.fucent.fusent.model;



import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;


import java.time.Instant;
import java.util.UUID;


@Entity
@Table(name = "product")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Product {
    @Id @GeneratedValue
    private UUID id;


    @ManyToOne(optional = false)
    private Shop shop;


    @ManyToOne(optional = false)
    private Category category;


    @Column(nullable = false)
    private String name;


    @Column(length = 4000)
    private String description;

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @Column(name = "is_active")
    @Builder.Default
    private boolean active = true;


    @CreationTimestamp
    private Instant createdAt;
}