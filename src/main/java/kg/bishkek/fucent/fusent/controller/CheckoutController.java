package kg.bishkek.fucent.fusent.controller;



import jakarta.validation.Valid;
import kg.bishkek.fucent.fusent.dto.OrderDtos.*;
import kg.bishkek.fucent.fusent.model.Order;
import kg.bishkek.fucent.fusent.model.OrderItem;
import kg.bishkek.fucent.fusent.repository.OrderItemRepository;
import kg.bishkek.fucent.fusent.service.CheckoutService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;


@RestController
@RequestMapping("/api/v1/checkout")
@RequiredArgsConstructor
public class CheckoutController {
    private final CheckoutService checkoutService;
    private final OrderItemRepository orderItemRepository;

    @PostMapping
    public ResponseEntity<OrderResponse> checkout(@Valid @RequestBody CheckoutRequest request) {
        Order order = checkoutService.checkoutFromCart(
                request.shopId(), // Note: userId should come from authentication context
                request.shopId(),
                request.shippingAddress(),
                request.paymentMethod(),
                request.notes()
        );
        return ResponseEntity.ok(toOrderResponse(order));
    }

    @PostMapping("/{userId}")
    public ResponseEntity<OrderResponse> checkoutForUser(
            @PathVariable UUID userId,
            @Valid @RequestBody CheckoutRequest request) {
        Order order = checkoutService.checkoutFromCart(
                userId,
                request.shopId(),
                request.shippingAddress(),
                request.paymentMethod(),
                request.notes()
        );
        return ResponseEntity.ok(toOrderResponse(order));
    }

    private OrderResponse toOrderResponse(Order order) {
        List<OrderItem> items = orderItemRepository.findByOrderId(order.getId());
        return new OrderResponse(
                order.getId(),
                order.getUserId(),
                order.getShop().getId(),
                order.getShop().getName(),
                order.getStatus().name(),
                items.stream().map(this::toOrderItemResponse).collect(Collectors.toList()),
                order.getTotalAmount(),
                order.getCreatedAt(),
                order.getPaidAt(),
                null
        );
    }

    private OrderItemResponse toOrderItemResponse(OrderItem item) {
        var variant = item.getVariant();
        var product = variant.getProduct();
        return new OrderItemResponse(
                item.getId(),
                variant.getId(),
                variant.getSku(),
                product.getName(),
                product.getImageUrl(),
                item.getQty(),
                item.getPrice(),
                item.getSubtotal()
        );
    }
}
