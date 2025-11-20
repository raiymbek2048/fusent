package kg.bishkek.fucent.fusent.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.Instant;
import java.util.UUID;

public class EmployeeDtos {

    public record CreateEmployeeRequest(
            @NotBlank(message = "Full name is required")
            String fullName,

            @NotBlank(message = "Email is required")
            @Email(message = "Invalid email format")
            String email,

            @NotBlank(message = "Password is required")
            String password,

            String phone,

            @NotNull(message = "Shop ID is required")
            UUID shopId
    ) {}

    public record UpdateEmployeeShopRequest(
            @NotNull(message = "Shop ID is required")
            UUID shopId
    ) {}

    public record UpdateEmployeeRequest(
            @NotBlank(message = "Full name is required")
            String fullName,

            @NotBlank(message = "Email is required")
            @Email(message = "Invalid email format")
            String email,

            String phone,

            String password  // Optional - only update if provided
    ) {}

    public record EmployeeResponse(
            UUID id,
            String fullName,
            String email,
            String phone,
            UUID shopId,
            String shopName,
            Instant createdAt
    ) {}
}
