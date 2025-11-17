package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.ProductCreateRequest;
import kg.bishkek.fucent.fusent.dto.ProductUpdateRequest;
import kg.bishkek.fucent.fusent.dto.ProductUpdateDtos;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.model.ProductVariant;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

public interface CatalogMutationsService {
    @Transactional
    Product createProduct(ProductCreateRequest req);

    @Transactional
    Product updateProduct(UUID productId, ProductUpdateRequest req);

    @Transactional
    ProductVariant updatePriceStock(ProductUpdateDtos.VariantPriceStockUpdate req);

    @Transactional
    Product setActive(ProductUpdateDtos.ProductActivateRequest req);
}
