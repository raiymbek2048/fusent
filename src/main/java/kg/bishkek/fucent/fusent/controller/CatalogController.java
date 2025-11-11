package kg.bishkek.fucent.fusent.controller;



import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import kg.bishkek.fucent.fusent.dto.ProductCreateRequest;
import kg.bishkek.fucent.fusent.dto.VariantCreateRequest;
import kg.bishkek.fucent.fusent.model.Category;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.model.ProductVariant;
import kg.bishkek.fucent.fusent.repository.CategoryRepository;
import kg.bishkek.fucent.fusent.service.CatalogService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping("/api/v1/catalog")
@RequiredArgsConstructor
@Tag(name = "Catalog", description = "Product catalog and search")
public class CatalogController {
    private final CatalogService service;
    private final CategoryRepository categoryRepository;


    @GetMapping("/categories")
    @Operation(summary = "Get all categories")
    public List<Category> getCategories() {
        return categoryRepository.findAll();
    }


    @PostMapping("/products")
    @Operation(summary = "Create a new product")
    public Product createProduct(@Valid @RequestBody ProductCreateRequest req) { return service.createProduct(req); }

    @PutMapping("/products/{id}")
    @Operation(summary = "Update a product")
    public Product updateProduct(@PathVariable String id, @Valid @RequestBody ProductCreateRequest req) {
        return service.updateProduct(id, req);
    }

    @DeleteMapping("/products/{id}")
    @Operation(summary = "Delete a product")
    public void deleteProduct(@PathVariable String id) {
        service.deleteProduct(id);
    }

    @PostMapping("/variants")
    @Operation(summary = "Create a new product variant")
    public ProductVariant createVariant(@Valid @RequestBody VariantCreateRequest req) { return service.createVariant(req); }

    @GetMapping("/search")
    @Operation(summary = "Full-text search for products", description = "Search products by name and description using PostgreSQL full-text search")
    public Page<Product> searchProducts(
            @RequestParam String q,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return service.searchProducts(q, PageRequest.of(page, size));
    }

    @GetMapping("/autocomplete")
    @Operation(summary = "Autocomplete product suggestions", description = "Get product name suggestions for autocomplete")
    public Page<Product> autocomplete(
            @RequestParam String q,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        return service.autocompleteProducts(q, PageRequest.of(page, size));
    }
}