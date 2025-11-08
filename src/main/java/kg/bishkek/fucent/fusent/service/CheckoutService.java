package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.model.Order;

import java.util.UUID;

public interface CheckoutService {

    /**
     * Create order from user's cart
     * Clears the cart after successful order creation
     */
    Order checkoutFromCart(UUID userId, UUID shopId);

    /**
     * Create order from user's cart with additional checkout details
     */
    Order checkoutFromCart(UUID userId, UUID shopId, String shippingAddress, String paymentMethod, String notes);
}
