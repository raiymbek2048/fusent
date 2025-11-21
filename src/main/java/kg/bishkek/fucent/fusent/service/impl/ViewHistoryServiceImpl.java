package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.model.ViewHistory;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import kg.bishkek.fucent.fusent.repository.ProductRepository;
import kg.bishkek.fucent.fusent.repository.ViewHistoryRepository;
import kg.bishkek.fucent.fusent.service.ViewHistoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ViewHistoryServiceImpl implements ViewHistoryService {

    private final ViewHistoryRepository viewHistoryRepository;
    private final AppUserRepository appUserRepository;
    private final ProductRepository productRepository;

    @Override
    @Transactional
    public void recordView(UUID userId, UUID productId) {
        AppUser user = appUserRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));

        // Update existing or create new
        viewHistoryRepository.findByUserIdAndProductId(userId, productId)
                .ifPresentOrElse(
                        vh -> vh.setViewedAt(LocalDateTime.now()),
                        () -> viewHistoryRepository.save(ViewHistory.builder()
                                .user(user)
                                .product(product)
                                .build())
                );
    }

    @Override
    @Transactional(readOnly = true)
    public List<Product> getViewHistory(UUID userId) {
        return viewHistoryRepository.findByUserIdOrderByViewedAtDesc(userId)
                .stream()
                .map(ViewHistory::getProduct)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void clearHistory(UUID userId) {
        viewHistoryRepository.deleteAllByUserId(userId);
    }
}
