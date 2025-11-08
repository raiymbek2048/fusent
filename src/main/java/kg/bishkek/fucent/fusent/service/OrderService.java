package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.model.Order;
import kg.bishkek.fucent.fusent.service.impl.OrderServiceImpl;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

public interface OrderService {

    @Transactional
    Order createOrder(UUID userId, UUID shopId, List<OrderServiceImpl.Item> items);
    public record Item(UUID variantId, int qty) {}


}
