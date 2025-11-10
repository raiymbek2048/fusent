package kg.bishkek.fucent.fusent.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kg.bishkek.fucent.fusent.dto.UserDtos.UserResponse;
import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
@Tag(name = "Users", description = "User management")
public class UserController {

    private final AppUserRepository userRepository;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Get all users (Admin only)")
    public ResponseEntity<Page<UserResponse>> getAllUsers(
            @RequestParam(required = false) String role,
            Pageable pageable
    ) {
        Page<AppUser> users;

        if (role != null && !role.isEmpty()) {
            users = userRepository.findByRole(AppUser.Role.valueOf(role), pageable);
        } else {
            users = userRepository.findAll(pageable);
        }

        return ResponseEntity.ok(users.map(this::toUserResponse));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Get user by ID (Admin only)")
    public ResponseEntity<UserResponse> getUserById(@PathVariable java.util.UUID id) {
        AppUser user = userRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        return ResponseEntity.ok(toUserResponse(user));
    }

    private UserResponse toUserResponse(AppUser user) {
        return new UserResponse(
                user.getId().toString(),
                user.getEmail(),
                user.getRole().name(),
                user.getCreatedAt(),
                user.getUpdatedAt(),
                true  // verified - adjust based on your verification logic
        );
    }
}
