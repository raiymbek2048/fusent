package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.ProductUpdateDtos.ProductActivateRequest;
import kg.bishkek.fucent.fusent.dto.ProductUpdateDtos.VariantPriceStockUpdate;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.model.ProductVariant;
import kg.bishkek.fucent.fusent.repository.AppUserRepository;
import kg.bishkek.fucent.fusent.repository.ProductRepository;
import kg.bishkek.fucent.fusent.repository.ProductVariantRepository;
import kg.bishkek.fucent.fusent.security.SecurityUtil;
import kg.bishkek.fucent.fusent.service.CatalogMutationsService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service @RequiredArgsConstructor
public class CatalogMutationsServiceImpl implements CatalogMutationsService {
    private final ProductRepository products;
    private final ProductVariantRepository variants;
    private final AppUserRepository users;

    private void assertOwner(Product p) {
        var uid = SecurityUtil.currentUserId(users);
        if (!p.getShop().getMerchant().getOwnerUserId().equals(uid))
            throw new IllegalArgumentException("Not an owner of this shop");
    }

    @Transactional
    @Override
    public ProductVariant updatePriceStock(VariantPriceStockUpdate req) {
        var v = variants.findById(req.variantId()).orElseThrow();
        assertOwner(v.getProduct());
        if (req.price()!=null) v.setPrice(req.price());
        if (req.stockQty()!=null) v.setStockQty(req.stockQty());
        return variants.save(v);
    }

    @Transactional
    @Override
    public Product setActive(ProductActivateRequest req) {
        var p = products.findById(req.productId()).orElseThrow();
        assertOwner(p);
        p.setActive(req.active());
        return products.save(p);
    }
}
