package kg.bishkek.fucent.fusent.service.impl;



import kg.bishkek.fucent.fusent.model.Order;
import kg.bishkek.fucent.fusent.model.OrderItem;
import kg.bishkek.fucent.fusent.model.ProductVariant;
import kg.bishkek.fucent.fusent.repository.OrderRepository;
import kg.bishkek.fucent.fusent.repository.ProductVariantRepository;
import kg.bishkek.fucent.fusent.repository.ShopRepository;
import kg.bishkek.fucent.fusent.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


import java.util.List;
import java.util.UUID;


@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {
    private final OrderRepository orderRepository;
    private final ProductVariantRepository variantRepository;
    private final ShopRepository shopRepository;

    @Transactional
    @Override
    public Order createOrder(UUID userId, UUID shopId, List<Item> items) {
        var shop = shopRepository.findById(shopId).orElseThrow();
        double total = 0d;
        var order = Order.builder().userId(userId).shop(shop).totalAmount(0d).build();
        order = orderRepository.save(order);
        for (var i : items) {
            ProductVariant v = variantRepository.findById(i.variantId()).orElseThrow();
            if (!v.getProduct().getShop().getId().equals(shopId))
                throw new IllegalArgumentException("All items must belong to the same shop");
            var price = v.getPrice();
            var subtotal = price * i.qty();
            total += subtotal;
            var oi = OrderItem.builder().order(order).variant(v).qty(i.qty()).price(price).subtotal(subtotal).build();
// persist via EntityManager or separate repository if needed
        }
        order.setTotalAmount(total);
        return order;
    }

}