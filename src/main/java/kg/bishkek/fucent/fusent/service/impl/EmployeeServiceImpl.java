package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.EmployeeDtos.*;
import kg.bishkek.fucent.fusent.enums.Role;
import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.Merchant;
import kg.bishkek.fucent.fusent.model.Shop;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import kg.bishkek.fucent.fusent.repository.MerchantRepository;
import kg.bishkek.fucent.fusent.repository.ShopRepository;
import kg.bishkek.fucent.fusent.security.SecurityUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class EmployeeServiceImpl implements kg.bishkek.fucent.fusent.service.EmployeeService {
    private final AppUserRepository users;
    private final ShopRepository shops;
    private final MerchantRepository merchants;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public EmployeeResponse createEmployee(CreateEmployeeRequest request) {
        var currentUserId = SecurityUtil.currentUserId(users);
        log.info("Creating employee: email={}, shopId={}, currentUserId={}",
            request.email(), request.shopId(), currentUserId);

        // Get the merchant for the current user
        Merchant merchant = merchants.findByOwnerUserId(currentUserId)
            .orElseThrow(() -> new IllegalArgumentException("You are not a merchant owner"));

        // Validate that the shop exists and belongs to the merchant
        Shop shop = shops.findById(request.shopId())
            .orElseThrow(() -> new IllegalArgumentException("Shop not found"));

        if (!shop.getMerchant().getId().equals(merchant.getId())) {
            throw new IllegalArgumentException("Shop does not belong to your merchant account");
        }

        // Check if user with this email already exists
        if (users.existsByEmail(request.email())) {
            throw new IllegalArgumentException("User with this email already exists");
        }

        // Create the employee
        AppUser employee = AppUser.builder()
            .fullName(request.fullName())
            .email(request.email())
            .phone(request.phone())
            .passwordHash(passwordEncoder.encode(request.password()))
            .role(Role.SELLER)
            .shop(shop)
            .build();

        employee = users.save(employee);
        log.info("Employee created successfully: id={}, email={}", employee.getId(), employee.getEmail());

        return toEmployeeResponse(employee);
    }

    @Override
    @Transactional(readOnly = true)
    public List<EmployeeResponse> getMyEmployees() {
        var currentUserId = SecurityUtil.currentUserId(users);
        log.info("Fetching employees for current user: {}", currentUserId);

        // Get the merchant for the current user
        Merchant merchant = merchants.findByOwnerUserId(currentUserId)
            .orElseThrow(() -> new IllegalArgumentException("You are not a merchant owner"));

        List<AppUser> employees = users.findByShop_Merchant_IdAndRole(merchant.getId(), Role.SELLER);
        log.info("Found {} employees for merchant {}", employees.size(), merchant.getId());

        return employees.stream()
            .map(this::toEmployeeResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<EmployeeResponse> getEmployeesByShop(UUID shopId) {
        var currentUserId = SecurityUtil.currentUserId(users);
        log.info("Fetching employees for shop: {}, currentUserId: {}", shopId, currentUserId);

        // Get the merchant for the current user
        Merchant merchant = merchants.findByOwnerUserId(currentUserId)
            .orElseThrow(() -> new IllegalArgumentException("You are not a merchant owner"));

        // Verify shop exists and belongs to the merchant
        Shop shop = shops.findById(shopId)
            .orElseThrow(() -> new IllegalArgumentException("Shop not found"));

        if (!shop.getMerchant().getId().equals(merchant.getId())) {
            throw new IllegalArgumentException("Shop does not belong to your merchant account");
        }

        List<AppUser> employees = users.findByShop_IdAndRole(shopId, Role.SELLER);
        log.info("Found {} employees for shop {}", employees.size(), shopId);

        return employees.stream()
            .map(this::toEmployeeResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public EmployeeResponse updateEmployeeShop(UUID employeeId, UpdateEmployeeShopRequest request) {
        var currentUserId = SecurityUtil.currentUserId(users);
        log.info("Updating employee shop: employeeId={}, newShopId={}, currentUserId={}",
            employeeId, request.shopId(), currentUserId);

        // Get the merchant for the current user
        Merchant merchant = merchants.findByOwnerUserId(currentUserId)
            .orElseThrow(() -> new IllegalArgumentException("You are not a merchant owner"));

        // Find the employee
        AppUser employee = users.findById(employeeId)
            .orElseThrow(() -> new IllegalArgumentException("Employee not found"));

        // Verify the employee is a seller
        if (employee.getRole() != Role.SELLER) {
            throw new IllegalArgumentException("User is not an employee");
        }

        // Verify the current shop belongs to the merchant
        if (employee.getShop() != null &&
            !employee.getShop().getMerchant().getId().equals(merchant.getId())) {
            throw new IllegalArgumentException("Employee does not belong to your merchant account");
        }

        // Validate that the new shop exists and belongs to the merchant
        Shop newShop = shops.findById(request.shopId())
            .orElseThrow(() -> new IllegalArgumentException("Shop not found"));

        if (!newShop.getMerchant().getId().equals(merchant.getId())) {
            throw new IllegalArgumentException("Shop does not belong to your merchant account");
        }

        // Update the employee's shop
        employee.setShop(newShop);
        employee = users.save(employee);
        log.info("Employee shop updated successfully: employeeId={}, newShopId={}",
            employeeId, newShop.getId());

        return toEmployeeResponse(employee);
    }

    @Override
    @Transactional
    public void deleteEmployee(UUID employeeId) {
        var currentUserId = SecurityUtil.currentUserId(users);
        log.info("Deleting employee: employeeId={}, currentUserId={}", employeeId, currentUserId);

        // Get the merchant for the current user
        Merchant merchant = merchants.findByOwnerUserId(currentUserId)
            .orElseThrow(() -> new IllegalArgumentException("You are not a merchant owner"));

        // Find the employee
        AppUser employee = users.findById(employeeId)
            .orElseThrow(() -> new IllegalArgumentException("Employee not found"));

        // Verify the employee is a seller
        if (employee.getRole() != Role.SELLER) {
            throw new IllegalArgumentException("User is not an employee");
        }

        // Verify the employee belongs to the merchant
        if (employee.getShop() == null ||
            !employee.getShop().getMerchant().getId().equals(merchant.getId())) {
            throw new IllegalArgumentException("Employee does not belong to your merchant account");
        }

        // Delete the employee
        users.delete(employee);
        log.info("Employee deleted successfully: employeeId={}", employeeId);
    }

    private EmployeeResponse toEmployeeResponse(AppUser employee) {
        return new EmployeeResponse(
            employee.getId(),
            employee.getFullName(),
            employee.getEmail(),
            employee.getPhone(),
            employee.getShop() != null ? employee.getShop().getId() : null,
            employee.getShop() != null ? employee.getShop().getName() : null,
            employee.getCreatedAt()
        );
    }
}
