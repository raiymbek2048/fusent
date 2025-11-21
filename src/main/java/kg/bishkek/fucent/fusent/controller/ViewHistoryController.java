package kg.bishkek.fucent.fusent.controller;

import kg.bishkek.fucent.fusent.dto.ProductResponse;
import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.service.ViewHistoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/view-history")
@RequiredArgsConstructor
public class ViewHistoryController {

    private final ViewHistoryService viewHistoryService;

    @GetMapping
    public ResponseEntity<List<ProductResponse>> getViewHistory(@AuthenticationPrincipal AppUser user) {
        List<Product> products = viewHistoryService.getViewHistory(user.getId());
        return ResponseEntity.ok(products.stream().map(this::toResponse).collect(Collectors.toList()));
    }

    @PostMapping("/{productId}")
    public ResponseEntity<Void> recordView(
            @AuthenticationPrincipal AppUser user,
            @PathVariable UUID productId) {
        viewHistoryService.recordView(user.getId(), productId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping
    public ResponseEntity<Void> clearHistory(@AuthenticationPrincipal AppUser user) {
        viewHistoryService.clearHistory(user.getId());
        return ResponseEntity.noContent().build();
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
