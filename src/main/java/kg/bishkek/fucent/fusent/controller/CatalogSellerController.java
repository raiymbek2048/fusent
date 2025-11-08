package kg.bishkek.fucent.fusent.controller;


import kg.bishkek.fucent.fusent.dto.ProductUpdateDtos.ProductActivateRequest;
import kg.bishkek.fucent.fusent.dto.ProductUpdateDtos.VariantPriceStockUpdate;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.model.ProductVariant;
import kg.bishkek.fucent.fusent.service.CatalogMutationsService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/seller/catalog")
@RequiredArgsConstructor
@PreAuthorize("hasRole('SELLER')")
public class CatalogSellerController {
    private final CatalogMutationsService svc;

    @PatchMapping("/variant/price-stock")
    public ProductVariant priceStock(@RequestBody VariantPriceStockUpdate req) {
        return svc.updatePriceStock(req);
    }

    @PatchMapping("/product/active")
    public Product setActive(@RequestBody ProductActivateRequest req) {
        return svc.setActive(req);
    }
}
