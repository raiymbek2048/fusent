package kg.bishkek.fucent.fusent.controller;



import jakarta.validation.Valid;
import kg.bishkek.fucent.fusent.dto.CartDtos.*;
import kg.bishkek.fucent.fusent.model.Cart;
import kg.bishkek.fucent.fusent.model.CartItem;
import kg.bishkek.fucent.fusent.service.CartService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;
import java.util.stream.Collectors;


@RestController
@RequestMapping("/api/v1/cart")
@RequiredArgsConstructor
public class CartController {
    private final CartService cartService;

    @GetMapping("/{userId}")
    public ResponseEntity<CartResponse> getCart(@PathVariable UUID userId) {
        Cart cart = cartService.getCartWithItems(userId);
        return ResponseEntity.ok(toCartResponse(cart));
    }

    @GetMapping("/{userId}/summary")
    public ResponseEntity<CartSummary> getCartSummary(@PathVariable UUID userId) {
        Cart cart = cartService.getCartWithItems(userId);
        return ResponseEntity.ok(new CartSummary(cart.getTotalItems(), cart.getTotalAmount()));
    }

    @PostMapping("/{userId}/items")
    public ResponseEntity<CartItemResponse> addItem(
            @PathVariable UUID userId,
            @Valid @RequestBody AddToCartRequest request) {
        CartItem item = cartService.addItem(userId, request.variantId(), request.qty());
        return ResponseEntity.ok(toCartItemResponse(item));
    }

    @PutMapping("/{userId}/items/{variantId}")
    public ResponseEntity<CartItemResponse> updateItem(
            @PathVariable UUID userId,
            @PathVariable UUID variantId,
            @Valid @RequestBody UpdateCartItemRequest request) {
        CartItem item = cartService.updateItemQuantity(userId, variantId, request.qty());
        return ResponseEntity.ok(toCartItemResponse(item));
    }

    @DeleteMapping("/{userId}/items/{variantId}")
    public ResponseEntity<Void> removeItem(
            @PathVariable UUID userId,
            @PathVariable UUID variantId) {
        cartService.removeItem(userId, variantId);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{userId}")
    public ResponseEntity<Void> clearCart(@PathVariable UUID userId) {
        cartService.clearCart(userId);
        return ResponseEntity.noContent().build();
    }

    private CartResponse toCartResponse(Cart cart) {
        return new CartResponse(
                cart.getId(),
                cart.getUserId(),
                cart.getItems().stream()
                        .map(this::toCartItemResponse)
                        .collect(Collectors.toList()),
                cart.getTotalItems(),
                cart.getTotalAmount(),
                cart.getCreatedAt(),
                cart.getUpdatedAt()
        );
    }

    private CartItemResponse toCartItemResponse(CartItem item) {
        var variant = item.getVariant();
        var product = variant.getProduct();
        return new CartItemResponse(
                item.getId(),
                variant.getId(),
                variant.getSku(),
                product.getName(),
                product.getImageUrl(),
                product.getShop().getId(),
                product.getShop().getName(),
                variant.getPrice(),
                item.getQty(),
                item.getSubtotal(),
                variant.getStockQty(),
                item.getAddedAt()
        );
    }
}
