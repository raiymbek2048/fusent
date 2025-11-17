package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.ProductCreateRequest;
import kg.bishkek.fucent.fusent.dto.ProductUpdateRequest;
import kg.bishkek.fucent.fusent.dto.ProductUpdateDtos.ProductActivateRequest;
import kg.bishkek.fucent.fusent.dto.ProductUpdateDtos.VariantPriceStockUpdate;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.model.ProductVariant;
import kg.bishkek.fucent.fusent.repository.*;
import kg.bishkek.fucent.fusent.security.SecurityUtil;
import kg.bishkek.fucent.fusent.service.CatalogMutationsService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service @RequiredArgsConstructor
public class CatalogMutationsServiceImpl implements CatalogMutationsService {
    private final ProductRepository products;
    private final ProductVariantRepository variants;
    private final AppUserRepository users;
    private final ShopRepository shops;
    private final CategoryRepository categories;

    private void assertOwner(Product p) {
        var uid = SecurityUtil.currentUserId(users);
        if (!p.getShop().getMerchant().getOwnerUserId().equals(uid))
            throw new IllegalArgumentException("Not an owner of this shop");
    }

    @Transactional
    @Override
    public Product createProduct(ProductCreateRequest req) {
        // Validate shop ownership
        var shop = shops.findById(req.shopId()).orElseThrow(() ->
            new IllegalArgumentException("Shop not found"));
        var uid = SecurityUtil.currentUserId(users);
        if (!shop.getMerchant().getOwnerUserId().equals(uid))
            throw new IllegalArgumentException("Not an owner of this shop");

        // Get category
        var category = categories.findById(req.categoryId()).orElseThrow(() ->
            new IllegalArgumentException("Category not found"));

        // Create product
        var product = Product.builder()
                .shop(shop)
                .category(category)
                .name(req.name())
                .description(req.description())
                .imageUrl(req.imageUrl())
                .basePrice(req.basePrice())
                .active(true)
                .build();

        product = products.save(product);

        // Create default variant
        var defaultVariant = ProductVariant.builder()
                .product(product)
                .sku(product.getId().toString().substring(0, 8).toUpperCase())
                .name("Стандартный")
                .price(req.basePrice())
                .stockQty(req.initialStock() != null ? req.initialStock() : 0)
                .build();

        variants.save(defaultVariant);

        return product;
    }

    @Transactional
    @Override
    public Product updateProduct(UUID productId, ProductUpdateRequest req) {
        // Find existing product
        var product = products.findById(productId)
            .orElseThrow(() -> new IllegalArgumentException("Product not found"));

        // Check ownership
        assertOwner(product);

        // Update category if provided and different
        if (req.categoryId() != null && !product.getCategory().getId().equals(req.categoryId())) {
            var category = categories.findById(req.categoryId())
                .orElseThrow(() -> new IllegalArgumentException("Category not found"));
            product.setCategory(category);
        }

        // Update product fields
        if (req.name() != null) {
            product.setName(req.name());
        }
        if (req.description() != null) {
            product.setDescription(req.description());
        }
        if (req.imageUrl() != null) {
            product.setImageUrl(req.imageUrl());
        }
        if (req.basePrice() != null) {
            product.setBasePrice(req.basePrice());
        }

        // Update stock quantity in default variant if provided
        if (req.initialStock() != null) {
            var variantPage = variants.findAllByProduct_Id(productId,
                org.springframework.data.domain.PageRequest.of(0, 1));
            if (!variantPage.isEmpty()) {
                var defaultVariant = variantPage.getContent().get(0);
                defaultVariant.setStockQty(req.initialStock());
                variants.save(defaultVariant);
            }
        }

        // Save and return updated product
        return products.save(product);
    }

    @Transactional
    @Override
    public ProductVariant updatePriceStock(VariantPriceStockUpdate req) {
        var v = variants.findById(req.variantId()).orElseThrow();
        assertOwner(v.getProduct());
        if (req.price()!=null) v.setPrice(req.price());
        if (req.stockQty()!=null) v.setStockQty(req.stockQty());
        return variants.save(v);
    }

    @Transactional
    @Override
    public Product setActive(ProductActivateRequest req) {
        var p = products.findById(req.productId()).orElseThrow();
        assertOwner(p);
        p.setActive(req.active());
        return products.save(p);
    }
}
