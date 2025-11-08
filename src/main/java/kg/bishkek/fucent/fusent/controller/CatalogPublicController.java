package kg.bishkek.fucent.fusent.controller;

import kg.bishkek.fucent.fusent.dto.CatalogDtos.Paged;
import kg.bishkek.fucent.fusent.dto.CatalogDtos.ProductFilter;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.model.ProductVariant;
import kg.bishkek.fucent.fusent.repository.ProductRepository;
import kg.bishkek.fucent.fusent.repository.ProductVariantRepository;
import kg.bishkek.fucent.fusent.service.CatalogQueryService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/public/catalog")
@RequiredArgsConstructor
public class CatalogPublicController {
    private final CatalogQueryService q;
    private final ProductRepository products;
    private final ProductVariantRepository variants;

    @GetMapping("/products")
    public Paged<Product> products(
            @RequestParam(required=false) UUID shopId,
            @RequestParam(required=false) UUID categoryId,
            @RequestParam(required=false) String qtext,
            @RequestParam(defaultValue="0") int page,
            @RequestParam(defaultValue="20") int size
    ) {
        return q.search(new ProductFilter(shopId, categoryId, qtext, page, size));
    }

    @GetMapping("/products/{id}")
    public Product product(@PathVariable UUID id) { return products.findById(id).orElseThrow(); }

    @GetMapping("/products/{id}/variants")
    public org.springframework.data.domain.Page<ProductVariant> variants(
            @PathVariable UUID id,
            @RequestParam(defaultValue="0") int page,
            @RequestParam(defaultValue="20") int size
    ) {
        return variants.findAllByProductId(id, PageRequest.of(page, size));
    }
}

