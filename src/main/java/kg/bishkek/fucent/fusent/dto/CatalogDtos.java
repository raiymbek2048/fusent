package kg.bishkek.fucent.fusent.dto;

// kg.bishkek.fucent.fusent.dto.CatalogDtos.java

import java.util.UUID;

public class CatalogDtos {
    public record ProductFilter(UUID shopId, UUID categoryId, String q, int page, int size) {}
    public record Paged<T>(java.util.List<T> items, long total, int page, int size) {}
}

