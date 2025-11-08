package kg.bishkek.fucent.fusent.service.impl;



import kg.bishkek.fucent.fusent.model.Cart;
import kg.bishkek.fucent.fusent.model.CartItem;
import kg.bishkek.fucent.fusent.model.Order;
import kg.bishkek.fucent.fusent.service.CartService;
import kg.bishkek.fucent.fusent.service.CheckoutService;
import kg.bishkek.fucent.fusent.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;


@Service
@RequiredArgsConstructor
public class CheckoutServiceImpl implements CheckoutService {
    private final CartService cartService;
    private final OrderService orderService;

    @Override
    @Transactional
    public Order checkoutFromCart(UUID userId, UUID shopId) {
        return checkoutFromCart(userId, shopId, null, null, null);
    }

    @Override
    @Transactional
    public Order checkoutFromCart(UUID userId, UUID shopId, String shippingAddress, String paymentMethod, String notes) {
        // Get cart with items
        Cart cart = cartService.getCartWithItems(userId);

        if (cart.getItems().isEmpty()) {
            throw new IllegalStateException("Cart is empty");
        }

        // Filter items by shop
        List<CartItem> shopItems = cart.getItems().stream()
                .filter(item -> item.getVariant().getProduct().getShop().getId().equals(shopId))
                .collect(Collectors.toList());

        if (shopItems.isEmpty()) {
            throw new IllegalArgumentException("No items from this shop in cart");
        }

        // Convert cart items to order items
        List<OrderService.Item> orderItems = shopItems.stream()
                .map(cartItem -> new OrderService.Item(
                        cartItem.getVariant().getId(),
                        cartItem.getQty()
                ))
                .collect(Collectors.toList());

        // Create order
        Order order = orderService.createOrder(userId, shopId, orderItems);

        // Remove checked out items from cart
        for (CartItem item : shopItems) {
            cartService.removeItem(userId, item.getVariant().getId());
        }

        return order;
    }
}
