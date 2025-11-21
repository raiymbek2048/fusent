package kg.bishkek.fucent.fusent.controller;

import kg.bishkek.fucent.fusent.dto.DeliveryAddressDtos.*;
import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.DeliveryAddress;
import kg.bishkek.fucent.fusent.repository.DeliveryAddressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/addresses")
@RequiredArgsConstructor
public class DeliveryAddressController {

    private final DeliveryAddressRepository addressRepository;

    @GetMapping
    public ResponseEntity<List<AddressResponse>> getAddresses(@AuthenticationPrincipal AppUser user) {
        List<DeliveryAddress> addresses = addressRepository.findByUserIdOrderByIsDefaultDescCreatedAtDesc(user.getId());
        return ResponseEntity.ok(addresses.stream().map(this::toResponse).collect(Collectors.toList()));
    }

    @PostMapping
    @Transactional
    public ResponseEntity<AddressResponse> createAddress(
            @AuthenticationPrincipal AppUser user,
            @RequestBody AddressRequest request) {

        DeliveryAddress address = DeliveryAddress.builder()
                .user(user)
                .title(request.getTitle())
                .city(request.getCity())
                .street(request.getStreet())
                .building(request.getBuilding())
                .apartment(request.getApartment())
                .entrance(request.getEntrance())
                .floor(request.getFloor())
                .intercom(request.getIntercom())
                .phone(request.getPhone())
                .comment(request.getComment())
                .isDefault(request.getIsDefault() != null && request.getIsDefault())
                .build();

        if (Boolean.TRUE.equals(address.getIsDefault())) {
            addressRepository.clearDefaultExcept(user.getId(), UUID.randomUUID());
        }

        address = addressRepository.save(address);
        return ResponseEntity.ok(toResponse(address));
    }

    @PutMapping("/{addressId}")
    @Transactional
    public ResponseEntity<AddressResponse> updateAddress(
            @AuthenticationPrincipal AppUser user,
            @PathVariable UUID addressId,
            @RequestBody AddressRequest request) {

        DeliveryAddress address = addressRepository.findByIdAndUserId(addressId, user.getId())
                .orElseThrow(() -> new RuntimeException("Address not found"));

        address.setTitle(request.getTitle());
        address.setCity(request.getCity());
        address.setStreet(request.getStreet());
        address.setBuilding(request.getBuilding());
        address.setApartment(request.getApartment());
        address.setEntrance(request.getEntrance());
        address.setFloor(request.getFloor());
        address.setIntercom(request.getIntercom());
        address.setPhone(request.getPhone());
        address.setComment(request.getComment());

        if (Boolean.TRUE.equals(request.getIsDefault())) {
            addressRepository.clearDefaultExcept(user.getId(), addressId);
            address.setIsDefault(true);
        }

        address = addressRepository.save(address);
        return ResponseEntity.ok(toResponse(address));
    }

    @DeleteMapping("/{addressId}")
    public ResponseEntity<Void> deleteAddress(
            @AuthenticationPrincipal AppUser user,
            @PathVariable UUID addressId) {

        DeliveryAddress address = addressRepository.findByIdAndUserId(addressId, user.getId())
                .orElseThrow(() -> new RuntimeException("Address not found"));

        addressRepository.delete(address);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{addressId}/default")
    @Transactional
    public ResponseEntity<AddressResponse> setDefault(
            @AuthenticationPrincipal AppUser user,
            @PathVariable UUID addressId) {

        DeliveryAddress address = addressRepository.findByIdAndUserId(addressId, user.getId())
                .orElseThrow(() -> new RuntimeException("Address not found"));

        addressRepository.clearDefaultExcept(user.getId(), addressId);
        address.setIsDefault(true);
        address = addressRepository.save(address);

        return ResponseEntity.ok(toResponse(address));
    }

    private AddressResponse toResponse(DeliveryAddress address) {
        return AddressResponse.builder()
                .id(address.getId().toString())
                .title(address.getTitle())
                .city(address.getCity())
                .street(address.getStreet())
                .building(address.getBuilding())
                .apartment(address.getApartment())
                .entrance(address.getEntrance())
                .floor(address.getFloor())
                .intercom(address.getIntercom())
                .phone(address.getPhone())
                .comment(address.getComment())
                .isDefault(address.getIsDefault())
                .createdAt(address.getCreatedAt())
                .build();
    }
}
