package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.ProductUpdateDtos;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.model.ProductVariant;
import org.springframework.transaction.annotation.Transactional;

public interface CatalogMutationsService {
    @Transactional
    ProductVariant updatePriceStock(ProductUpdateDtos.VariantPriceStockUpdate req);

    @Transactional
    Product setActive(ProductUpdateDtos.ProductActivateRequest req);
}
