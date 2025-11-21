package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.model.Product;
import java.util.List;
import java.util.UUID;

public interface ViewHistoryService {
    void recordView(UUID userId, UUID productId);
    List<Product> getViewHistory(UUID userId);
    void clearHistory(UUID userId);
}
