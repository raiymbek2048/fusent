package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.ProductCreateRequest;
import kg.bishkek.fucent.fusent.dto.VariantCreateRequest;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.model.ProductVariant;

public interface CatalogService {
    Product createProduct(ProductCreateRequest req);

    ProductVariant createVariant(VariantCreateRequest req);
}
