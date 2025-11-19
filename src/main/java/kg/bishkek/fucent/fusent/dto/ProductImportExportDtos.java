package kg.bishkek.fucent.fusent.dto;

import com.opencsv.bean.CsvBindByName;
import com.opencsv.bean.CsvBindByPosition;
import lombok.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class ProductImportExportDtos {

    /**
     * DTO for exporting/importing a single product variant row
     * Each row represents one product variant
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ProductExportRow {
        @CsvBindByName(column = "Product Name")
        @CsvBindByPosition(position = 0)
        private String productName;

        @CsvBindByName(column = "Description")
        @CsvBindByPosition(position = 1)
        private String description;

        @CsvBindByName(column = "Category")
        @CsvBindByPosition(position = 2)
        private String categoryName;

        @CsvBindByName(column = "Base Price")
        @CsvBindByPosition(position = 3)
        private String basePrice;

        @CsvBindByName(column = "Variant Name")
        @CsvBindByPosition(position = 4)
        private String variantName;

        @CsvBindByName(column = "SKU")
        @CsvBindByPosition(position = 5)
        private String sku;

        @CsvBindByName(column = "Barcode")
        @CsvBindByPosition(position = 6)
        private String barcode;

        @CsvBindByName(column = "Variant Price")
        @CsvBindByPosition(position = 7)
        private String variantPrice;

        @CsvBindByName(column = "Stock")
        @CsvBindByPosition(position = 8)
        private String stock;

        @CsvBindByName(column = "Attributes")
        @CsvBindByPosition(position = 9)
        private String attributes; // JSON string: {"size":"M","color":"Red"}

        @CsvBindByName(column = "Active")
        @CsvBindByPosition(position = 10)
        private String active;

        @CsvBindByName(column = "Image URL")
        @CsvBindByPosition(position = 11)
        private String imageUrl;
    }

    /**
     * DTO for import result
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ImportResultDto {
        private int totalRows;
        private int successCount;
        private int errorCount;
        @Builder.Default
        private List<String> errors = new ArrayList<>();
        @Builder.Default
        private List<String> warnings = new ArrayList<>();
        private long processingTimeMs;
    }

    /**
     * Request DTO for import
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ImportRequest {
        private String shopId;
        private boolean updateExisting; // If true, update existing products by SKU
        private boolean skipErrors; // If true, continue on errors instead of rolling back
    }

    /**
     * Internal DTO for processing import data
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ProductImportRow {
        private String productName;
        private String description;
        private String categoryName;
        private BigDecimal basePrice;
        private String variantName;
        private String sku;
        private String barcode;
        private BigDecimal variantPrice;
        private Integer stock;
        private String attributesJson;
        private Boolean active;
        private String imageUrl;

        // Validation errors for this row
        @Builder.Default
        private List<String> validationErrors = new ArrayList<>();

        public boolean isValid() {
            return validationErrors.isEmpty();
        }

        public void addValidationError(String error) {
            validationErrors.add(error);
        }
    }

    /**
     * Response DTO for export
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ExportResultDto {
        private int totalProducts;
        private int totalVariants;
        private String format; // CSV or XLSX
        private long fileSizeBytes;
        private String downloadUrl;
    }
}
