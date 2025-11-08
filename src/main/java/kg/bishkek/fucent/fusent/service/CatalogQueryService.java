package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.CatalogDtos;
import kg.bishkek.fucent.fusent.model.Product;

public interface CatalogQueryService {
    CatalogDtos.Paged<Product> search(CatalogDtos.ProductFilter f);
}
