package kg.bishkek.fucent.fusent.repository;



import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.model.Shop;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;


public interface ProductRepository extends JpaRepository<Product, UUID> {
    // ProductRepository
    Page<Product> findAllByShop_Id(UUID shopId, Pageable pageable);
    Page<Product> findAllByCategory_Id(UUID categoryId, Pageable pageable);
    Page<Product> findAllByNameContainingIgnoreCase(String q, Pageable pageable);

    // Find all products by seller's user ID with variants eagerly loaded
    @Query("""
        SELECT DISTINCT p FROM Product p
        LEFT JOIN FETCH p.variants
        INNER JOIN p.shop s
        INNER JOIN s.merchant m
        WHERE m.ownerUserId = :userId
        ORDER BY p.createdAt DESC
        """)
    List<Product> findByShopMerchantOwnerUserId(@Param("userId") UUID userId);

    /**
     * Full-text search using PostgreSQL tsvector
     * Searches in both Russian and English with weighted ranking
     */
    @Query(value = """
        SELECT p.*, ts_rank(p.search_vector, query) AS rank
        FROM product p,
             to_tsquery('russian', :searchQuery) query
        WHERE p.search_vector @@ query
           OR to_tsvector('english', p.name || ' ' || COALESCE(p.description, '')) @@ to_tsquery('english', :searchQuery)
        ORDER BY rank DESC
        """,
        countQuery = """
        SELECT count(*)
        FROM product p
        WHERE p.search_vector @@ to_tsquery('russian', :searchQuery)
           OR to_tsvector('english', p.name || ' ' || COALESCE(p.description, '')) @@ to_tsquery('english', :searchQuery)
        """,
        nativeQuery = true)
    Page<Product> fullTextSearch(@Param("searchQuery") String searchQuery, Pageable pageable);

    /**
     * Simple search for autocomplete suggestions
     */
    @Query("SELECT p FROM Product p WHERE " +
           "LOWER(p.name) LIKE LOWER(CONCAT('%', :query, '%')) " +
           "ORDER BY p.name")
    Page<Product> searchForAutocomplete(@Param("query") String query, Pageable pageable);

    /**
     * Get products from merchants that the user follows
     */
    @Query("""
        SELECT DISTINCT p FROM Product p
        INNER JOIN p.shop s
        INNER JOIN s.merchant m
        WHERE EXISTS (
            SELECT 1 FROM Follow f
            WHERE f.follower = :follower
            AND f.targetType = 'MERCHANT'
            AND f.targetId = m.id
        )
        AND p.active = true
        ORDER BY p.createdAt DESC
        """)
    Page<Product> findProductsFromFollowedMerchants(
        @Param("follower") AppUser follower,
        Pageable pageable
    );

    /**
     * Find all products by shop ID, ordered by creation date (for export)
     */
    @Query("SELECT p FROM Product p LEFT JOIN FETCH p.variants WHERE p.shop.id = :shopId ORDER BY p.createdAt DESC")
    List<Product> findByShopIdOrderByCreatedAtDesc(@Param("shopId") UUID shopId);

    /**
     * Find product by shop and name (for import - checking duplicates)
     */
    Optional<Product> findByShopAndName(Shop shop, String name);
}