package kg.bishkek.fucent.fusent.controller;



import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import kg.bishkek.fucent.fusent.dto.OrderDtos.*;
import kg.bishkek.fucent.fusent.model.Order;
import kg.bishkek.fucent.fusent.model.OrderItem;
import kg.bishkek.fucent.fusent.repository.OrderItemRepository;
import kg.bishkek.fucent.fusent.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;


@RestController
@RequestMapping("/api/v1/orders")
@RequiredArgsConstructor
public class OrderController {
    private final OrderService service;
    private final OrderItemRepository orderItemRepository;


    public record CreateOrderRequest(@NotNull UUID userId, @NotNull UUID shopId, @NotNull List<OrderService.Item> items) {}


    @PostMapping
    public OrderResponse create(@RequestBody CreateOrderRequest req) {
        Order order = service.createOrder(req.userId(), req.shopId(), req.items());
        return toOrderResponse(order);
    }

    @GetMapping("/{id}")
    public ResponseEntity<OrderResponse> getById(@PathVariable UUID id) {
        return service.getOrderById(id)
                .map(order -> ResponseEntity.ok(toOrderResponse(order)))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<OrderSummary>> getUserOrders(@PathVariable UUID userId) {
        List<OrderSummary> orders = service.getOrdersByUserId(userId).stream()
                .map(this::toOrderSummary)
                .collect(Collectors.toList());
        return ResponseEntity.ok(orders);
    }

    @GetMapping("/shop/{shopId}")
    public ResponseEntity<List<OrderSummary>> getShopOrders(@PathVariable UUID shopId) {
        List<OrderSummary> orders = service.getOrdersByShopId(shopId).stream()
                .map(this::toOrderSummary)
                .collect(Collectors.toList());
        return ResponseEntity.ok(orders);
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<OrderResponse> updateStatus(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateOrderStatusRequest request) {
        Order order = service.updateOrderStatus(id, request.status());
        return ResponseEntity.ok(toOrderResponse(order));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> cancel(@PathVariable UUID id) {
        service.cancelOrder(id);
        return ResponseEntity.noContent().build();
    }

    private OrderResponse toOrderResponse(Order order) {
        List<OrderItem> items = orderItemRepository.findByOrderId(order.getId());
        return new OrderResponse(
                order.getId(),
                order.getUserId(),
                order.getShop().getId(),
                order.getShop().getName(),
                order.getStatus(),
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
                null, // TODO: implement product image support
                item.getQty(),
                item.getPrice(),
                item.getSubtotal()
        );
    }

    private OrderSummary toOrderSummary(Order order) {
        int itemCount = orderItemRepository.findByOrderId(order.getId()).size();
        return new OrderSummary(
                order.getId(),
                order.getShop().getId(),
                order.getShop().getName(),
                order.getStatus(),
                itemCount,
                order.getTotalAmount(),
                order.getCreatedAt()
        );
    }
}