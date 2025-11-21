package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.model.SavedItem;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import kg.bishkek.fucent.fusent.repository.ProductRepository;
import kg.bishkek.fucent.fusent.repository.SavedItemRepository;
import kg.bishkek.fucent.fusent.service.FavoriteService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FavoriteServiceImpl implements FavoriteService {
    private final SavedItemRepository savedItemRepository;
    private final AppUserRepository userRepository;
    private final ProductRepository productRepository;

    @Override
    @Transactional
    public SavedItem addToFavorites(UUID userId, UUID productId) {
        AppUser user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));

        return savedItemRepository.findByUserAndProduct(user, product)
                .orElseGet(() -> savedItemRepository.save(
                        SavedItem.builder()
                                .user(user)
                                .product(product)
                                .build()
                ));
    }

    @Override
    @Transactional
    public void removeFromFavorites(UUID userId, UUID productId) {
        AppUser user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));

        savedItemRepository.findByUserAndProduct(user, product)
                .ifPresent(savedItemRepository::delete);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Product> getFavorites(UUID userId) {
        AppUser user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return savedItemRepository.findByUser(user).stream()
                .map(SavedItem::getProduct)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isFavorite(UUID userId, UUID productId) {
        AppUser user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));

        return savedItemRepository.existsByUserAndProduct(user, product);
    }
}
