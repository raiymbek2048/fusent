package kg.bishkek.fucent.fusent.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import kg.bishkek.fucent.fusent.dto.SkuBarcodeDtos.*;
import kg.bishkek.fucent.fusent.model.ProductVariant;
import kg.bishkek.fucent.fusent.repository.ProductVariantRepository;
import kg.bishkek.fucent.fusent.service.SkuBarcodeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/sku-barcode")
@RequiredArgsConstructor
@Tag(name = "SKU & Barcode", description = "SKU and Barcode generation and validation")
@PreAuthorize("hasRole('SELLER') or hasRole('MERCHANT') or hasRole('ADMIN')")
public class SkuBarcodeController {

    private final SkuBarcodeService skuBarcodeService;
    private final ProductVariantRepository productVariantRepository;

    @Operation(summary = "Generate unique SKU", description = "Generate a unique SKU for a product variant")
    @PostMapping("/generate-sku")
    public ResponseEntity<SkuResponse> generateSku(@Valid @RequestBody GenerateSkuRequest request) {
        UUID shopId = UUID.fromString(request.getShopId());
        UUID categoryId = UUID.fromString(request.getCategoryId());

        String sku = skuBarcodeService.generateSku(shopId, categoryId);

        return ResponseEntity.ok(SkuResponse.builder()
                .sku(sku)
                .isUnique(true)
                .build());
    }

    @Operation(summary = "Generate unique barcode", description = "Generate a unique EAN-13 barcode")
    @PostMapping("/generate-barcode")
    public ResponseEntity<BarcodeResponse> generateBarcode() {
        String barcode = skuBarcodeService.generateBarcode();

        return ResponseEntity.ok(BarcodeResponse.builder()
                .barcode(barcode)
                .isUnique(true)
                .isValidFormat(skuBarcodeService.isValidEan13(barcode))
                .build());
    }

    @Operation(summary = "Validate SKU uniqueness", description = "Check if SKU is unique")
    @PostMapping("/validate-sku")
    public ResponseEntity<ValidationResponse> validateSku(@Valid @RequestBody ValidateSkuRequest request) {
        boolean isUnique;

        if (request.getVariantId() != null && !request.getVariantId().isEmpty()) {
            // Update scenario - check if SKU is unique for other variants
            UUID variantId = UUID.fromString(request.getVariantId());
            isUnique = skuBarcodeService.isSkuUniqueForUpdate(request.getSku(), variantId);
        } else {
            // Create scenario - check if SKU is unique globally
            isUnique = skuBarcodeService.isSkuUnique(request.getSku());
        }

        String message = isUnique
                ? "SKU is unique and available"
                : "SKU already exists. Please use a different SKU";

        return ResponseEntity.ok(ValidationResponse.builder()
                .isValid(isUnique)
                .message(message)
                .build());
    }

    @Operation(summary = "Validate barcode uniqueness and format", description = "Check if barcode is unique and valid EAN-13 format")
    @PostMapping("/validate-barcode")
    public ResponseEntity<ValidationResponse> validateBarcode(@Valid @RequestBody ValidateBarcodeRequest request) {
        // Check format first (if provided)
        if (request.getBarcode() != null && !request.getBarcode().isEmpty()) {
            boolean isValidFormat = skuBarcodeService.isValidEan13(request.getBarcode());
            if (!isValidFormat) {
                return ResponseEntity.ok(ValidationResponse.builder()
                        .isValid(false)
                        .message("Invalid EAN-13 barcode format. Must be 13 digits with valid check digit")
                        .build());
            }
        }

        // Check uniqueness
        boolean isUnique;
        if (request.getVariantId() != null && !request.getVariantId().isEmpty()) {
            // Update scenario
            UUID variantId = UUID.fromString(request.getVariantId());
            isUnique = skuBarcodeService.isBarcodeUniqueForUpdate(request.getBarcode(), variantId);
        } else {
            // Create scenario
            isUnique = skuBarcodeService.isBarcodeUnique(request.getBarcode());
        }

        String message = isUnique
                ? "Barcode is unique and available"
                : "Barcode already exists. Please use a different barcode";

        return ResponseEntity.ok(ValidationResponse.builder()
                .isValid(isUnique)
                .message(message)
                .build());
    }

    @Operation(summary = "Find product by SKU", description = "Search for a product variant by SKU")
    @GetMapping("/find-by-sku/{sku}")
    public ResponseEntity<ProductVariantInfo> findBySku(@PathVariable String sku) {
        Optional<ProductVariant> variant = productVariantRepository.findBySku(sku);

        if (variant.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        ProductVariant pv = variant.get();
        return ResponseEntity.ok(ProductVariantInfo.builder()
                .id(pv.getId().toString())
                .sku(pv.getSku())
                .barcode(pv.getBarcode())
                .productName(pv.getProduct().getName())
                .variantName(pv.getName())
                .build());
    }

    @Operation(summary = "Find product by barcode", description = "Search for a product variant by barcode")
    @GetMapping("/find-by-barcode/{barcode}")
    public ResponseEntity<ProductVariantInfo> findByBarcode(@PathVariable String barcode) {
        Optional<ProductVariant> variant = productVariantRepository.findByBarcode(barcode);

        if (variant.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        ProductVariant pv = variant.get();
        return ResponseEntity.ok(ProductVariantInfo.builder()
                .id(pv.getId().toString())
                .sku(pv.getSku())
                .barcode(pv.getBarcode())
                .productName(pv.getProduct().getName())
                .variantName(pv.getName())
                .build());
    }
}
