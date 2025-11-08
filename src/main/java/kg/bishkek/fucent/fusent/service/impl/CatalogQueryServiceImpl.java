package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.service.CatalogQueryService;

import kg.bishkek.fucent.fusent.dto.CatalogDtos.Paged;
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
    public Paged<Product> search(ProductFilter f) {
        var pageable = PageRequest.of(Math.max(f.page(),0), Math.max(f.size(),1), Sort.by("name").ascending());
        Page<Product> page;
        if (f.shopId()!=null)      page = products.findAllByShopId(f.shopId(), pageable);
        else if (f.categoryId()!=null) page = products.findAllByCategoryId(f.categoryId(), pageable);
        else if (f.q()!=null && !f.q().isBlank()) page = products.findAllByNameContainingIgnoreCase(f.q(), pageable);
        else page = products.findAll(pageable);
        return new Paged<>(page.getContent(), page.getTotalElements(), page.getNumber(), page.getSize());
    }
}
