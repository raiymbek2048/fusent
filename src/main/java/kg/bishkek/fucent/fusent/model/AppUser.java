package kg.bishkek.fucent.fusent.model;



import jakarta.persistence.*;
import kg.bishkek.fucent.fusent.enums.Role;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;


import java.time.Instant;
import java.util.Collection;
import java.util.List;
import java.util.UUID;


@Entity
@Table(name = "app_user", indexes = {@Index(name = "idx_user_email", columnList = "email", unique = true)})
@Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class AppUser implements UserDetails {
    @Id @GeneratedValue
    private UUID id;


    @Column(nullable = false)
    private String fullName;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(unique = true)
    private String username;

    @Column
    private String phone;

    @Column(nullable = false)
    private String passwordHash;

    @Column(nullable = false)
    @Builder.Default
    private Role role = Role.BUYER;

    // Profile fields
    @Column(length = 500)
    private String avatarUrl;

    @Column(length = 1000)
    private String bio;

    @Column
    private String address;

    @Column
    private String city;

    @Column
    private String country;

    @Column
    private String dateOfBirth;

    @Column
    private String gender; // MALE, FEMALE, OTHER

    @Column(nullable = false)
    @Builder.Default
    private Boolean isVerified = false;

    @Column(nullable = false)
    @Builder.Default
    private Boolean isActive = true;

    @Column(nullable = false)
    @Builder.Default
    private Boolean blocked = false;

    private Instant blockedAt;

    @Column(length = 500)
    private String blockedReason;

    // Social links
    @Column
    private String telegramUsername;

    @Column
    private String instagramUsername;

    // Statistics (can be calculated, but cached here for performance)
    @Column(nullable = false)
    @Builder.Default
    private Integer followersCount = 0;

    @Column(nullable = false)
    @Builder.Default
    private Integer followingCount = 0;

    @Column(nullable = false)
    @Builder.Default
    private Integer postsCount = 0;

    // Shop-related fields (for sellers)
    @Column
    private String shopAddress;

    @Column
    private Boolean hasSmartPOS;

    @ManyToOne
    @JoinColumn(name = "shop_id")
    private Shop shop;


    @CreationTimestamp
    private Instant createdAt;

    @UpdateTimestamp
    private Instant updatedAt;


    // Manual getters (no @Getter annotation to avoid conflict with UserDetails)
    public UUID getId() { return id; }
    public String getFullName() { return fullName; }
    public String getEmail() { return email; }
    public String getUsernameField() { return username; } // Renamed to avoid confusion
    public String getPhone() { return phone; }
    public String getPasswordHash() { return passwordHash; }
    public Role getRole() { return role; }

    // Profile getters
    public String getAvatarUrl() { return avatarUrl; }
    public String getBio() { return bio; }
    public String getAddress() { return address; }
    public String getCity() { return city; }
    public String getCountry() { return country; }
    public String getDateOfBirth() { return dateOfBirth; }
    public String getGender() { return gender; }
    public Boolean getIsVerified() { return isVerified; }
    public Boolean getIsActive() { return isActive; }
    public Boolean getBlocked() { return blocked; }
    public Instant getBlockedAt() { return blockedAt; }
    public String getBlockedReason() { return blockedReason; }

    // Social links getters
    public String getTelegramUsername() { return telegramUsername; }
    public String getInstagramUsername() { return instagramUsername; }

    // Statistics getters
    public Integer getFollowersCount() { return followersCount; }
    public Integer getFollowingCount() { return followingCount; }
    public Integer getPostsCount() { return postsCount; }

    // Shop getters
    public String getShopAddress() { return shopAddress; }
    public Boolean getHasSmartPOS() { return hasSmartPOS; }
    public Shop getShop() { return shop; }

    // Timestamps
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }

    // UserDetails interface methods
    @Override public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + role.name()));
    }
    @Override public String getPassword() { return passwordHash; }
    @Override public String getUsername() { return email; } // For Spring Security (uses email for auth)
    @Override public boolean isAccountNonExpired() { return true; }
    @Override public boolean isAccountNonLocked() { return true; }
    @Override public boolean isCredentialsNonExpired() { return true; }
    @Override public boolean isEnabled() { return true; }
}