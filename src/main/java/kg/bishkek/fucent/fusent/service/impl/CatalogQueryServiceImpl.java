package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.service.CatalogQueryService;

import kg.bishkek.fucent.fusent.dto.CatalogDtos.ProductFilter;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;

@Service @RequiredArgsConstructor
public class CatalogQueryServiceImpl implements CatalogQueryService {
    private final ProductRepository products;
    @Override
    public Page<Product> search(ProductFilter f) {
        var pageable = PageRequest.of(Math.max(f.page(),0), Math.max(f.size(),1), Sort.by("name").ascending());
        Page<Product> page;
        // Use methods with JOIN FETCH to eagerly load variants and avoid LazyInitializationException
        if (f.shopId()!=null)      page = products.findAllByShopIdWithVariants(f.shopId(), pageable);
        else if (f.categoryId()!=null) page = products.findAllByCategoryIdWithVariants(f.categoryId(), pageable);
        else if (f.q()!=null && !f.q().isBlank()) page = products.findAllByNameContainingIgnoreCaseWithVariants(f.q(), pageable);
        else page = products.findAllWithVariants(pageable);
        return page;
    }
}
