package kg.bishkek.fucent.fusent.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

public class SkuBarcodeDtos {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class GenerateSkuRequest {
        private String shopId;
        private String categoryId;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SkuResponse {
        private String sku;
        private boolean isUnique;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class BarcodeResponse {
        private String barcode;
        private boolean isUnique;
        private boolean isValidFormat;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ValidateSkuRequest {
        private String sku;
        private String variantId; // Optional: for update validation
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ValidateBarcodeRequest {
        private String barcode;
        private String variantId; // Optional: for update validation
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ValidationResponse {
        private boolean isValid;
        private String message;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ProductVariantInfo {
        private String id;
        private String sku;
        private String barcode;
        private String productName;
        private String variantName;
    }
}
