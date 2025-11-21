package kg.bishkek.fucent.fusent.controller;

import kg.bishkek.fucent.fusent.dto.ProductResponse;
import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.service.FavoriteService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/favorites")
@RequiredArgsConstructor
public class FavoriteController {
    private final FavoriteService favoriteService;

    @GetMapping
    public ResponseEntity<List<ProductResponse>> getFavorites(@AuthenticationPrincipal AppUser user) {
        List<Product> products = favoriteService.getFavorites(user.getId());
        return ResponseEntity.ok(products.stream().map(this::toResponse).collect(Collectors.toList()));
    }

    @PostMapping("/{productId}")
    public ResponseEntity<Void> addToFavorites(
            @AuthenticationPrincipal AppUser user,
            @PathVariable UUID productId) {
        favoriteService.addToFavorites(user.getId(), productId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{productId}")
    public ResponseEntity<Void> removeFromFavorites(
            @AuthenticationPrincipal AppUser user,
            @PathVariable UUID productId) {
        favoriteService.removeFromFavorites(user.getId(), productId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{productId}/check")
    public ResponseEntity<Boolean> isFavorite(
            @AuthenticationPrincipal AppUser user,
            @PathVariable UUID productId) {
        return ResponseEntity.ok(favoriteService.isFavorite(user.getId(), productId));
    }

    private ProductResponse toResponse(Product p) {
        return new ProductResponse(
                p.getId(),
                p.getShop().getId(),
                p.getCategory() != null ? p.getCategory().getId() : null,
                p.getName(),
                p.getDescription(),
                p.getImageUrl(),
                p.getBasePrice(),
                p.isActive()
        );
    }
}
