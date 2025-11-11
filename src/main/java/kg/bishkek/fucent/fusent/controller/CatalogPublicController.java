package kg.bishkek.fucent.fusent.controller;

import kg.bishkek.fucent.fusent.dto.CatalogDtos.ProductFilter;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.model.ProductVariant;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import kg.bishkek.fucent.fusent.repository.ProductRepository;
import kg.bishkek.fucent.fusent.repository.ProductVariantRepository;
import kg.bishkek.fucent.fusent.security.SecurityUtil;
import kg.bishkek.fucent.fusent.service.CatalogQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/public/catalog")
@RequiredArgsConstructor
public class CatalogPublicController {
    private final CatalogQueryService q;
    private final ProductRepository products;
    private final ProductVariantRepository variants;
    private final AppUserRepository users;

    @GetMapping("/products")
    @Transactional(readOnly = true)
    public Page<Product> products(
            @RequestParam(required=false) UUID shopId,
            @RequestParam(required=false) UUID categoryId,
            @RequestParam(required=false) String qtext,
            @RequestParam(defaultValue="0") int page,
            @RequestParam(defaultValue="20") int size
    ) {
        return q.search(new ProductFilter(shopId, categoryId, qtext, page, size));
    }

    @GetMapping("/products/{id}")
    @Transactional(readOnly = true)
    public Product product(@PathVariable UUID id) {
        Product p = products.findById(id).orElseThrow();
        // Force load variants within transaction
        if (p.getVariants() != null) {
            p.getVariants().size();
        }
        return p;
    }

    @GetMapping("/products/{id}/variants")
    public org.springframework.data.domain.Page<ProductVariant> variants(
            @PathVariable UUID id,
            @RequestParam(defaultValue="0") int page,
            @RequestParam(defaultValue="20") int size
    ) {
        return variants.findAllByProductId(id, PageRequest.of(page, size));
    }

    @GetMapping("/products/following")
    @PreAuthorize("isAuthenticated()")
    @Transactional(readOnly = true)
    public Page<Product> followingProducts(
            @RequestParam(defaultValue="0") int page,
            @RequestParam(defaultValue="20") int size
    ) {
        var currentUserId = SecurityUtil.currentUserId(users);
        var currentUser = users.findById(currentUserId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

        Page<Product> productPage = products.findProductsFromFollowedMerchants(
            currentUser,
            PageRequest.of(page, size, Sort.by("createdAt").descending())
        );

        // Force load variants within transaction
        productPage.getContent().forEach(product -> {
            if (product.getVariants() != null) {
                product.getVariants().size();
            }
        });

        return productPage;
    }
}

