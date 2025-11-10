package kg.bishkek.fucent.fusent.service.impl;



import kg.bishkek.fucent.fusent.enums.OrderStatus;
import kg.bishkek.fucent.fusent.model.Order;
import kg.bishkek.fucent.fusent.model.OrderItem;
import kg.bishkek.fucent.fusent.model.ProductVariant;
import kg.bishkek.fucent.fusent.repository.OrderRepository;
import kg.bishkek.fucent.fusent.repository.OrderItemRepository;
import kg.bishkek.fucent.fusent.repository.ProductVariantRepository;
import kg.bishkek.fucent.fusent.repository.ShopRepository;
import kg.bishkek.fucent.fusent.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;


@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final ProductVariantRepository variantRepository;
    private final ShopRepository shopRepository;

    @Transactional
    @Override
    public Order createOrder(UUID userId, UUID shopId, List<Item> items) {
        var shop = shopRepository.findById(shopId).orElseThrow();
        BigDecimal total = BigDecimal.ZERO;
        var order = Order.builder().userId(userId).shop(shop).totalAmount(BigDecimal.ZERO).build();
        order = orderRepository.save(order);
        for (var i : items) {
            ProductVariant v = variantRepository.findById(i.variantId()).orElseThrow();
            if (!v.getProduct().getShop().getId().equals(shopId))
                throw new IllegalArgumentException("All items must belong to the same shop");
            var price = v.getPrice();
            var subtotal = price.multiply(BigDecimal.valueOf(i.qty()));
            total = total.add(subtotal);
            var oi = OrderItem.builder().order(order).variant(v).qty(i.qty()).price(price).subtotal(subtotal).build();
            orderItemRepository.save(oi);
        }
        order.setTotalAmount(total);
        return orderRepository.save(order);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Order> getOrderById(UUID orderId) {
        return orderRepository.findByIdWithShop(orderId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Order> getOrdersByUserId(UUID userId) {
        return orderRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Order> getOrdersByShopId(UUID shopId) {
        return orderRepository.findByShopIdOrderByCreatedAtDesc(shopId);
    }

    @Override
    @Transactional
    public Order updateOrderStatus(UUID orderId, String status) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found"));

        // Convert string to enum
        OrderStatus newStatus = OrderStatus.valueOf(status.toUpperCase());

        // Validate status transitions
        OrderStatus currentStatus = order.getStatus();
        if (currentStatus == OrderStatus.CANCELLED) {
            throw new IllegalStateException("Cannot update status of cancelled order");
        }

        order.setStatus(newStatus);

        // Update timestamps based on status
        if (newStatus == OrderStatus.PAID && order.getPaidAt() == null) {
            order.setPaidAt(Instant.now());
        }

        return orderRepository.save(order);
    }

    @Override
    @Transactional
    public void cancelOrder(UUID orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found"));

        if (order.getStatus() == OrderStatus.PAID || order.getStatus() == OrderStatus.FULFILLED) {
            throw new IllegalStateException("Cannot cancel paid or fulfilled orders");
        }

        order.setStatus(OrderStatus.CANCELLED);
        orderRepository.save(order);
    }
}