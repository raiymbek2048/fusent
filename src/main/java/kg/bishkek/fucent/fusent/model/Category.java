package kg.bishkek.fucent.fusent.model;



import jakarta.persistence.*;
import lombok.*;
import java.util.UUID;


@Entity
@Table(name = "category")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Category {
    @Id @GeneratedValue
    private UUID id;


    @Column(nullable = false)
    private String name;
    private String description;

    @Column(name = "is_active")
    private Boolean active = true;

    @ManyToOne
    private Category parent;


    private Integer sortOrder;
}