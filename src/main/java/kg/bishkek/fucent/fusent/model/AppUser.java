package kg.bishkek.fucent.fusent.model;



import jakarta.persistence.*;
import kg.bishkek.fucent.fusent.enums.Role;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;


import java.time.Instant;
import java.util.Collection;
import java.util.List;
import java.util.UUID;


@Entity
@Table(name = "app_user", indexes = {@Index(name = "idx_user_email", columnList = "email", unique = true)})
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class AppUser implements UserDetails {
    @Id @GeneratedValue
    private UUID id;


    @Column(nullable = false, unique = true)
    private String email;


    @Column(nullable = false)
    private String passwordHash;


    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role = Role.BUYER;


    @CreationTimestamp
    private Instant createdAt;


    @Override public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + role.name()));
    }
    @Override public String getPassword() { return passwordHash; }
    @Override public String getUsername() { return email; }
    @Override public boolean isAccountNonExpired() { return true; }
    @Override public boolean isAccountNonLocked() { return true; }
    @Override public boolean isCredentialsNonExpired() { return true; }
    @Override public boolean isEnabled() { return true; }
}