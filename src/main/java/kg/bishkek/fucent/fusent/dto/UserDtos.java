package kg.bishkek.fucent.fusent.dto;

import java.time.Instant;

public class UserDtos {

    public record UserResponse(
            String id,
            String email,
            String role,
            Instant createdAt,
            Instant updatedAt,
            boolean verified
    ) {}
}
