package kg.bishkek.fucent.fusent.controller;



import jakarta.validation.Valid;
import kg.bishkek.fucent.fusent.dto.CartDtos.*;
import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.Cart;
import kg.bishkek.fucent.fusent.model.CartItem;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.repository.ProductRepository;
import kg.bishkek.fucent.fusent.service.CartService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;
import java.util.stream.Collectors;


@RestController
@RequestMapping("/api/v1/cart")
@RequiredArgsConstructor
public class CartController {
    private final CartService cartService;
    private final ProductRepository productRepository;

    // Endpoints that use authenticated user (no userId in path)
    @GetMapping
    public ResponseEntity<CartResponse> getMyCart(@AuthenticationPrincipal AppUser user) {
        Cart cart = cartService.getCartWithItems(user.getId());
        return ResponseEntity.ok(toCartResponse(cart));
    }

    @GetMapping("/summary")
    public ResponseEntity<CartSummary> getMyCartSummary(@AuthenticationPrincipal AppUser user) {
        Cart cart = cartService.getCartWithItems(user.getId());
        return ResponseEntity.ok(new CartSummary(cart.getTotalItems(), cart.getTotalAmount()));
    }

    @PostMapping("/items")
    public ResponseEntity<CartItemResponse> addItemToMyCart(
            @AuthenticationPrincipal AppUser user,
            @Valid @RequestBody AddToCartRequest request) {
        CartItem item = cartService.addItem(user.getId(), request.variantId(), request.qty());
        return ResponseEntity.ok(toCartItemResponse(item));
    }

    @PutMapping("/items/{variantId}")
    public ResponseEntity<CartItemResponse> updateMyCartItem(
            @AuthenticationPrincipal AppUser user,
            @PathVariable UUID variantId,
            @Valid @RequestBody UpdateCartItemRequest request) {
        CartItem item = cartService.updateItemQuantity(user.getId(), variantId, request.qty());
        return ResponseEntity.ok(toCartItemResponse(item));
    }

    @DeleteMapping("/items/{variantId}")
    public ResponseEntity<Void> removeItemFromMyCart(
            @AuthenticationPrincipal AppUser user,
            @PathVariable UUID variantId) {
        cartService.removeItem(user.getId(), variantId);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping
    public ResponseEntity<Void> clearMyCart(@AuthenticationPrincipal AppUser user) {
        cartService.clearCart(user.getId());
        return ResponseEntity.noContent().build();
    }

    // Legacy endpoints for mobile app compatibility
    @PostMapping("/add")
    public ResponseEntity<CartItemResponse> addToCartLegacy(
            @AuthenticationPrincipal AppUser user,
            @Valid @RequestBody AddToCartLegacyRequest request) {
        // Convert productId string to UUID
        UUID productId = UUID.fromString(request.productId());

        // Get product with variants
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));

        // Get first variant
        if (product.getVariants() == null || product.getVariants().isEmpty()) {
            throw new RuntimeException("Product has no variants");
        }
        UUID variantId = product.getVariants().get(0).getId();

        // Add to cart using variantId
        CartItem item = cartService.addItem(user.getId(), variantId, request.quantity());
        return ResponseEntity.ok(toCartItemResponse(item));
    }

    @PostMapping("/remove")
    public ResponseEntity<Void> removeFromCartLegacy(
            @AuthenticationPrincipal AppUser user,
            @Valid @RequestBody RemoveFromCartLegacyRequest request) {
        // Convert productId string to UUID
        UUID productId = UUID.fromString(request.productId());

        // Get product with variants
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));

        // Get first variant
        if (product.getVariants() == null || product.getVariants().isEmpty()) {
            throw new RuntimeException("Product has no variants");
        }
        UUID variantId = product.getVariants().get(0).getId();

        // Remove from cart
        cartService.removeItem(user.getId(), variantId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/update")
    public ResponseEntity<CartItemResponse> updateCartItemLegacy(
            @AuthenticationPrincipal AppUser user,
            @Valid @RequestBody UpdateCartItemLegacyRequest request) {
        // Convert productId string to UUID
        UUID productId = UUID.fromString(request.productId());

        // Get product with variants
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));

        // Get first variant
        if (product.getVariants() == null || product.getVariants().isEmpty()) {
            throw new RuntimeException("Product has no variants");
        }
        UUID variantId = product.getVariants().get(0).getId();

        // Update cart item
        CartItem item = cartService.updateItemQuantity(user.getId(), variantId, request.quantity());
        return ResponseEntity.ok(toCartItemResponse(item));
    }

    // Legacy endpoints with userId parameter (for admin use)
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
