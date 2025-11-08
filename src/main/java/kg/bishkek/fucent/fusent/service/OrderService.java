package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.model.Order;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface OrderService {

    @Transactional
    Order createOrder(UUID userId, UUID shopId, List<Item> items);

    Optional<Order> getOrderById(UUID orderId);

    List<Order> getOrdersByUserId(UUID userId);

    List<Order> getOrdersByShopId(UUID shopId);

    @Transactional
    Order updateOrderStatus(UUID orderId, String status);

    @Transactional
    void cancelOrder(UUID orderId);

    record Item(UUID variantId, int qty) {}
}
