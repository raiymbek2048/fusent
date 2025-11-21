package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.model.SavedItem;

import java.util.List;
import java.util.UUID;

public interface FavoriteService {
    SavedItem addToFavorites(UUID userId, UUID productId);
    void removeFromFavorites(UUID userId, UUID productId);
    List<Product> getFavorites(UUID userId);
    boolean isFavorite(UUID userId, UUID productId);
}
