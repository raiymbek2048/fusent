package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.CatalogDtos;
import kg.bishkek.fucent.fusent.model.Product;
import org.springframework.data.domain.Page;

public interface CatalogQueryService {
    Page<Product> search(CatalogDtos.ProductFilter f);
}
