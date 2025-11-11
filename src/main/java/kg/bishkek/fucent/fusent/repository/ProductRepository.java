package kg.bishkek.fucent.fusent.repository;



import kg.bishkek.fucent.fusent.model.AppUser;
import kg.bishkek.fucent.fusent.model.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.UUID;


public interface ProductRepository extends JpaRepository<Product, UUID> {
    // ProductRepository
    Page<Product> findAllByShopId(UUID shopId, Pageable pageable);
    Page<Product> findAllByCategoryId(UUID categoryId, Pageable pageable);
    Page<Product> findAllByNameContainingIgnoreCase(String q, Pageable pageable);

    // Methods with JOIN FETCH to eagerly load variants (fixes LazyInitializationException)
    @Query(value = "SELECT p FROM Product p LEFT JOIN FETCH p.variants",
           countQuery = "SELECT COUNT(p) FROM Product p")
    Page<Product> findAllWithVariants(Pageable pageable);

    @Query(value = "SELECT p FROM Product p LEFT JOIN FETCH p.variants WHERE p.shop.id = :shopId",
           countQuery = "SELECT COUNT(p) FROM Product p WHERE p.shop.id = :shopId")
    Page<Product> findAllByShopIdWithVariants(@Param("shopId") UUID shopId, Pageable pageable);

    @Query(value = "SELECT p FROM Product p LEFT JOIN FETCH p.variants WHERE p.category.id = :categoryId",
           countQuery = "SELECT COUNT(p) FROM Product p WHERE p.category.id = :categoryId")
    Page<Product> findAllByCategoryIdWithVariants(@Param("categoryId") UUID categoryId, Pageable pageable);

    @Query(value = "SELECT p FROM Product p LEFT JOIN FETCH p.variants WHERE LOWER(p.name) LIKE LOWER(CONCAT('%', :q, '%'))",
           countQuery = "SELECT COUNT(p) FROM Product p WHERE LOWER(p.name) LIKE LOWER(CONCAT('%', :q, '%'))")
    Page<Product> findAllByNameContainingIgnoreCaseWithVariants(@Param("q") String q, Pageable pageable);

    @Query("SELECT p FROM Product p LEFT JOIN FETCH p.variants WHERE p.id = :id")
    java.util.Optional<Product> findByIdWithVariants(@Param("id") UUID id);

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
     * Get products with variants from merchants that the user follows
     */
    @Query(value = """
        SELECT DISTINCT p FROM Product p
        LEFT JOIN FETCH p.variants
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
        """,
        countQuery = """
        SELECT COUNT(DISTINCT p) FROM Product p
        INNER JOIN p.shop s
        INNER JOIN s.merchant m
        WHERE EXISTS (
            SELECT 1 FROM Follow f
            WHERE f.follower = :follower
            AND f.targetType = 'MERCHANT'
            AND f.targetId = m.id
        )
        AND p.active = true
        """)
    Page<Product> findProductsFromFollowedMerchantsWithVariants(
        @Param("follower") AppUser follower,
        Pageable pageable
    );
}