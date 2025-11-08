package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.model.Cart;
import kg.bishkek.fucent.fusent.model.CartItem;

import java.util.UUID;

public interface CartService {

    /**
     * Get or create cart for user
     */
    Cart getOrCreateCart(UUID userId);

    /**
     * Add item to cart or update quantity if already exists
     */
    CartItem addItem(UUID userId, UUID variantId, int qty);

    /**
     * Update item quantity in cart
     */
    CartItem updateItemQuantity(UUID userId, UUID variantId, int qty);

    /**
     * Remove item from cart
     */
    void removeItem(UUID userId, UUID variantId);

    /**
     * Clear all items from cart
     */
    void clearCart(UUID userId);

    /**
     * Get cart with all items loaded
     */
    Cart getCartWithItems(UUID userId);

    /**
     * Get total items count in cart
     */
    int getTotalItemsCount(UUID userId);
}
