package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.ProductCreateRequest;
import kg.bishkek.fucent.fusent.dto.VariantCreateRequest;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.model.ProductVariant;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface CatalogService {
    Product createProduct(ProductCreateRequest req);

    Product updateProduct(String id, ProductCreateRequest req);

    void deleteProduct(String id);

    ProductVariant createVariant(VariantCreateRequest req);

    Page<Product> searchProducts(String query, Pageable pageable);

    Page<Product> autocompleteProducts(String query, Pageable pageable);
}
