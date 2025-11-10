package kg.bishkek.fucent.fusent.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import kg.bishkek.fucent.fusent.model.Category;
import kg.bishkek.fucent.fusent.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/categories")
@RequiredArgsConstructor
@Tag(name = "Categories", description = "Category management")
public class CategoryController {

    private final CategoryRepository categoryRepository;

    @Operation(summary = "Get all categories")
    @GetMapping
    public ResponseEntity<List<Category>> getAllCategories() {
        return ResponseEntity.ok(categoryRepository.findAll());
    }

    @Operation(summary = "Get category by ID")
    @GetMapping("/{id}")
    public ResponseEntity<Category> getCategoryById(@PathVariable UUID id) {
        return categoryRepository.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @Operation(summary = "Create a new category")
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Category> createCategory(@Valid @RequestBody CategoryRequest request) {
        Category category = Category.builder()
            .name(request.name())
            .description(request.description())
            .active(request.active() != null ? request.active() : true)
            .sortOrder(request.sortOrder())
            .build();

        if (request.parentId() != null) {
            categoryRepository.findById(request.parentId()).ifPresent(category::setParent);
        }

        Category saved = categoryRepository.save(category);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @Operation(summary = "Update category")
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Category> updateCategory(
            @PathVariable UUID id,
            @Valid @RequestBody CategoryRequest request) {
        return categoryRepository.findById(id)
            .map(category -> {
                category.setName(request.name());
                category.setDescription(request.description());
                category.setActive(request.active() != null ? request.active() : category.getActive());
                category.setSortOrder(request.sortOrder());

                if (request.parentId() != null) {
                    categoryRepository.findById(request.parentId()).ifPresent(category::setParent);
                } else {
                    category.setParent(null);
                }

                return ResponseEntity.ok(categoryRepository.save(category));
            })
            .orElse(ResponseEntity.notFound().build());
    }

    @Operation(summary = "Delete category")
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteCategory(@PathVariable UUID id) {
        if (categoryRepository.existsById(id)) {
            categoryRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    public record CategoryRequest(
        String name,
        String description,
        Boolean active,
        UUID parentId,
        Integer sortOrder
    ) {}
}
