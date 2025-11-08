package kg.bishkek.fucent.fusent.controller;



import jakarta.validation.Valid;
import kg.bishkek.fucent.fusent.dto.ProductCreateRequest;
import kg.bishkek.fucent.fusent.dto.VariantCreateRequest;
import kg.bishkek.fucent.fusent.model.Category;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.model.ProductVariant;
import kg.bishkek.fucent.fusent.repository.CategoryRepository;
import kg.bishkek.fucent.fusent.service.CatalogService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping("/api/v1/catalog")
@RequiredArgsConstructor
public class CatalogController {
    private final CatalogService service;
    private final CategoryRepository categoryRepository;


    @GetMapping("/categories")
    public List<Category> getCategories() {
        return categoryRepository.findAll();
    }


    @PostMapping("/products")
    public Product createProduct(@Valid @RequestBody ProductCreateRequest req) { return service.createProduct(req); }


    @PostMapping("/variants")
    public ProductVariant createVariant(@Valid @RequestBody VariantCreateRequest req) { return service.createVariant(req); }
}