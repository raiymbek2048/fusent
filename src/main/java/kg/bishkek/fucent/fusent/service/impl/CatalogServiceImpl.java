package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.ProductCreateRequest;
import kg.bishkek.fucent.fusent.dto.VariantCreateRequest;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.model.ProductVariant;
import kg.bishkek.fucent.fusent.repository.*;
import kg.bishkek.fucent.fusent.security.SecurityUtil;
import kg.bishkek.fucent.fusent.service.CatalogService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CatalogServiceImpl implements CatalogService {
    private final ProductRepository productRepository;
    private final ProductVariantRepository variantRepository;
    private final CategoryRepository categoryRepository;
    private final ShopRepository shopRepository;
    private final AppUserRepository users;

    @Override
    @Transactional
    public Product createProduct(ProductCreateRequest req) {
        var shop = shopRepository.findById(req.shopId()).orElseThrow();
        var currentUserId = SecurityUtil.currentUserId(users);

        // Проверка владельца магазина
        if (!shop.getMerchant().getOwnerUserId().equals(currentUserId)) {
            throw new IllegalArgumentException("Not an owner of this shop");
        }

        var cat = categoryRepository.findById(req.categoryId()).orElseThrow();

        var p = Product.builder()
                .shop(shop)
                .category(cat)
                .name(req.name())
                .description(req.description())
                .imageUrl(req.imageUrl())
                .basePrice(req.basePrice())
                .build();

        p = productRepository.save(p);

        // Автоматически создаем вариант по умолчанию с базовой ценой
        var defaultVariant = ProductVariant.builder()
                .product(p)
                .sku("DEFAULT-" + p.getId())
                .price(req.basePrice())
                .stockQty(0)
                .build();

        variantRepository.save(defaultVariant);

        return p;
    }

    @Override
    @Transactional
    public ProductVariant createVariant(VariantCreateRequest req) {
        var product = productRepository.findById(req.productId()).orElseThrow();

        // Проверка владельца (создавать варианты может только владелец магазина продукта)
        var currentUserId = SecurityUtil.currentUserId(users);
        if (!product.getShop().getMerchant().getOwnerUserId().equals(currentUserId)) {
            throw new IllegalArgumentException("Not an owner of this product's shop");
        }

        // (Опционально) Проверка уникальности SKU в рамках продукта
        // if (variantRepository.existsByProductIdAndSkuIgnoreCase(product.getId(), req.sku())) {
        //     throw new IllegalArgumentException("SKU already exists for this product");
        // }

        var v = ProductVariant.builder()
                .product(product)
                .sku(req.sku())
                .barcode(req.barcode())
                .attributesJson(req.attributesJson())
                .price(req.price())
                .stockQty(req.stockQty())
                .build();

        return variantRepository.save(v);
    }

    @Override
    public Page<Product> searchProducts(String query, Pageable pageable) {
        // Prepare search query for PostgreSQL full-text search
        // Replace spaces with & for AND operation in tsquery
        String searchQuery = query.trim().replace(" ", " & ");

        try {
            return productRepository.fullTextSearch(searchQuery, pageable);
        } catch (Exception e) {
            // Fallback to simple search if full-text search fails
            return productRepository.findAllByNameContainingIgnoreCase(query, pageable);
        }
    }

    @Override
    public Page<Product> autocompleteProducts(String query, Pageable pageable) {
        return productRepository.searchForAutocomplete(query, pageable);
    }
}
