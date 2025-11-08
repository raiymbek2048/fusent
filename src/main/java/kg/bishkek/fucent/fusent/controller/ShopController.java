package kg.bishkek.fucent.fusent.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kg.bishkek.fucent.fusent.model.Shop;
import kg.bishkek.fucent.fusent.repository.ShopRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/shops")
@RequiredArgsConstructor
@Tag(name = "Shops", description = "Shop browsing and search")
public class ShopController {

    private final ShopRepository shopRepository;

    @Operation(summary = "Get all shops with pagination")
    @GetMapping
    public ResponseEntity<Page<Shop>> getAllShops(Pageable pageable) {
        return ResponseEntity.ok(shopRepository.findAll(pageable));
    }

    @Operation(summary = "Get shop by ID")
    @GetMapping("/{id}")
    public ResponseEntity<Shop> getShopById(@PathVariable UUID id) {
        return shopRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @Operation(summary = "Get shops by seller ID")
    @GetMapping("/seller/{sellerId}")
    public ResponseEntity<List<Shop>> getShopsBySeller(@PathVariable UUID sellerId) {
        return ResponseEntity.ok(shopRepository.findByMerchantId(sellerId));
    }

    @Operation(summary = "Search shops by name")
    @GetMapping("/search")
    public ResponseEntity<Page<Shop>> searchShops(
            @RequestParam String query,
            Pageable pageable) {
        return ResponseEntity.ok(shopRepository.findByNameContainingIgnoreCase(query, pageable));
    }
}
