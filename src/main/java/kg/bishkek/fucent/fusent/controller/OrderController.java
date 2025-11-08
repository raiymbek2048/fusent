package kg.bishkek.fucent.fusent.controller;



import jakarta.validation.constraints.NotNull;
import kg.bishkek.fucent.fusent.model.Order;
import kg.bishkek.fucent.fusent.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;


import java.util.List;
import java.util.UUID;


@RestController
@RequestMapping("/api/v1/orders")
@RequiredArgsConstructor
public class OrderController {
    private final OrderService service;


    public record CreateOrderRequest(@NotNull UUID userId, @NotNull UUID shopId, @NotNull List<OrderService.Item> items) {}


    @PostMapping
    public Order create(@RequestBody CreateOrderRequest req) { return service.createOrder(req.userId(), req.shopId(), req.items()); }
}