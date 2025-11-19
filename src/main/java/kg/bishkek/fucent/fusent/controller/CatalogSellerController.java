package kg.bishkek.fucent.fusent.controller;


import jakarta.validation.Valid;
import kg.bishkek.fucent.fusent.dto.ProductCreateRequest;
import kg.bishkek.fucent.fusent.dto.ProductUpdateRequest;
import kg.bishkek.fucent.fusent.dto.ProductUpdateDtos.ProductActivateRequest;
import kg.bishkek.fucent.fusent.dto.ProductUpdateDtos.VariantPriceStockUpdate;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.model.ProductVariant;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import kg.bishkek.fucent.fusent.repository.ProductRepository;
import kg.bishkek.fucent.fusent.security.SecurityUtil;
import kg.bishkek.fucent.fusent.service.CatalogMutationsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/seller/catalog")
@RequiredArgsConstructor
@PreAuthorize("hasRole('SELLER') or hasRole('MERCHANT') or hasRole('ADMIN')")
public class CatalogSellerController {
    private final CatalogMutationsService svc;
    private final ProductRepository productRepository;
    private final AppUserRepository userRepository;

    @GetMapping("/products")
    @Transactional(readOnly = true)
    public List<Product> getMyProducts() {
        var userId = SecurityUtil.currentUserId(userRepository);
        return productRepository.findByShopMerchantOwnerUserId(userId);
    }

    @PostMapping("/product")
    @ResponseStatus(HttpStatus.CREATED)
    public Product createProduct(@Valid @RequestBody ProductCreateRequest req) {
        return svc.createProduct(req);
    }

    @PatchMapping("/variant/price-stock")
    public ProductVariant priceStock(@RequestBody VariantPriceStockUpdate req) {
        return svc.updatePriceStock(req);
    }

    @PatchMapping("/product/active")
    public Product setActive(@RequestBody ProductActivateRequest req) {
        return svc.setActive(req);
    }

    @GetMapping("/products/{id}")
    @Transactional(readOnly = true)
    public Product getProductById(@PathVariable UUID id) {
        var userId = SecurityUtil.currentUserId(userRepository);
        var product = productRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Product not found"));

        // Verify that the product belongs to the current seller
        if (!product.getShop().getMerchant().getOwnerUserId().equals(userId)) {
            throw new IllegalArgumentException("You don't have permission to access this product");
        }

        // Force load variants to populate stock field
        org.hibernate.Hibernate.initialize(product.getVariants());

        return product;
    }

    @PutMapping("/products/{id}")
    public Product updateProduct(@PathVariable UUID id, @Valid @RequestBody ProductUpdateRequest req) {
        var userId = SecurityUtil.currentUserId(userRepository);
        var product = productRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Product not found"));

        // Verify that the product belongs to the current seller
        if (!product.getShop().getMerchant().getOwnerUserId().equals(userId)) {
            throw new IllegalArgumentException("You don't have permission to update this product");
        }

        return svc.updateProduct(id, req);
    }

    @DeleteMapping("/products/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteProduct(@PathVariable UUID id) {
        var userId = SecurityUtil.currentUserId(userRepository);
        var product = productRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Product not found"));

        // Verify that the product belongs to the current seller
        if (!product.getShop().getMerchant().getOwnerUserId().equals(userId)) {
            throw new IllegalArgumentException("You don't have permission to delete this product");
        }

        productRepository.delete(product);
    }
}
