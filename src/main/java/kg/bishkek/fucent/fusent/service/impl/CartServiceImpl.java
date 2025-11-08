package kg.bishkek.fucent.fusent.service.impl;



import kg.bishkek.fucent.fusent.model.Cart;
import kg.bishkek.fucent.fusent.model.CartItem;
import kg.bishkek.fucent.fusent.model.ProductVariant;
import kg.bishkek.fucent.fusent.repository.CartItemRepository;
import kg.bishkek.fucent.fusent.repository.CartRepository;
import kg.bishkek.fucent.fusent.repository.ProductVariantRepository;
import kg.bishkek.fucent.fusent.service.CartService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;


@Service
@RequiredArgsConstructor
public class CartServiceImpl implements CartService {
    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final ProductVariantRepository variantRepository;

    @Override
    @Transactional
    public Cart getOrCreateCart(UUID userId) {
        return cartRepository.findByUserId(userId)
                .orElseGet(() -> {
                    Cart cart = Cart.builder()
                            .userId(userId)
                            .build();
                    return cartRepository.save(cart);
                });
    }

    @Override
    @Transactional
    public CartItem addItem(UUID userId, UUID variantId, int qty) {
        Cart cart = getOrCreateCart(userId);
        ProductVariant variant = variantRepository.findById(variantId)
                .orElseThrow(() -> new IllegalArgumentException("Product variant not found"));

        // Check if item already exists in cart
        return cartItemRepository.findByCartIdAndVariantId(cart.getId(), variantId)
                .map(existingItem -> {
                    existingItem.setQty(existingItem.getQty() + qty);
                    return cartItemRepository.save(existingItem);
                })
                .orElseGet(() -> {
                    CartItem newItem = CartItem.builder()
                            .cart(cart)
                            .variant(variant)
                            .qty(qty)
                            .build();
                    return cartItemRepository.save(newItem);
                });
    }

    @Override
    @Transactional
    public CartItem updateItemQuantity(UUID userId, UUID variantId, int qty) {
        if (qty <= 0) {
            removeItem(userId, variantId);
            return null;
        }

        Cart cart = getOrCreateCart(userId);
        CartItem item = cartItemRepository.findByCartIdAndVariantId(cart.getId(), variantId)
                .orElseThrow(() -> new IllegalArgumentException("Item not found in cart"));

        item.setQty(qty);
        return cartItemRepository.save(item);
    }

    @Override
    @Transactional
    public void removeItem(UUID userId, UUID variantId) {
        Cart cart = cartRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("Cart not found"));

        cartItemRepository.findByCartIdAndVariantId(cart.getId(), variantId)
                .ifPresent(cartItemRepository::delete);
    }

    @Override
    @Transactional
    public void clearCart(UUID userId) {
        Cart cart = cartRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("Cart not found"));

        cartItemRepository.deleteByCartId(cart.getId());
    }

    @Override
    @Transactional(readOnly = true)
    public Cart getCartWithItems(UUID userId) {
        return cartRepository.findByUserIdWithItems(userId)
                .orElseGet(() -> getOrCreateCart(userId));
    }

    @Override
    @Transactional(readOnly = true)
    public int getTotalItemsCount(UUID userId) {
        return cartRepository.findByUserId(userId)
                .map(Cart::getTotalItems)
                .orElse(0);
    }
}
