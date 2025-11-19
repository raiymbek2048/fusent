package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.repository.ProductVariantRepository;
import kg.bishkek.fucent.fusent.service.SkuBarcodeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class SkuBarcodeServiceImpl implements SkuBarcodeService {

    private final ProductVariantRepository productVariantRepository;
    private final SecureRandom random = new SecureRandom();

    private static final String SKU_PREFIX = "SKU";
    private static final int SKU_RANDOM_DIGITS = 6;
    private static final int MAX_SKU_GENERATION_ATTEMPTS = 10;

    private static final String BARCODE_PREFIX = "978"; // Bookland prefix
    private static final int MAX_BARCODE_GENERATION_ATTEMPTS = 10;

    @Override
    public String generateSku(UUID shopId, UUID categoryId) {
        for (int attempt = 0; attempt < MAX_SKU_GENERATION_ATTEMPTS; attempt++) {
            String sku = buildSku(shopId, categoryId);

            if (!productVariantRepository.existsBySku(sku)) {
                log.debug("Generated unique SKU: {}", sku);
                return sku;
            }

            log.warn("SKU collision detected: {}, retrying...", sku);
        }

        // Fallback to UUID-based SKU if random generation keeps colliding
        String fallbackSku = SKU_PREFIX + "-" + UUID.randomUUID().toString().replace("-", "").substring(0, 12).toUpperCase();
        log.warn("Using fallback UUID-based SKU: {}", fallbackSku);
        return fallbackSku;
    }

    private String buildSku(UUID shopId, UUID categoryId) {
        // Extract short IDs from UUIDs (first 6 chars)
        String shopShort = shopId.toString().replace("-", "").substring(0, 6).toUpperCase();
        String categoryShort = categoryId.toString().replace("-", "").substring(0, 6).toUpperCase();

        // Generate random digits
        String randomPart = String.format("%0" + SKU_RANDOM_DIGITS + "d",
                random.nextInt((int) Math.pow(10, SKU_RANDOM_DIGITS)));

        return String.format("%s-%s-%s-%s", SKU_PREFIX, shopShort, categoryShort, randomPart);
    }

    @Override
    public String generateBarcode() {
        for (int attempt = 0; attempt < MAX_BARCODE_GENERATION_ATTEMPTS; attempt++) {
            String barcode = buildEan13Barcode();

            if (!productVariantRepository.existsByBarcode(barcode)) {
                log.debug("Generated unique barcode: {}", barcode);
                return barcode;
            }

            log.warn("Barcode collision detected: {}, retrying...", barcode);
        }

        throw new IllegalStateException("Failed to generate unique barcode after " +
                MAX_BARCODE_GENERATION_ATTEMPTS + " attempts");
    }

    private String buildEan13Barcode() {
        // Generate 9 random digits after the 3-digit prefix
        String randomPart = String.format("%09d", random.nextInt(1000000000));

        // Combine prefix + random = 12 digits
        String barcodeWithoutCheck = BARCODE_PREFIX + randomPart;

        // Calculate and append check digit
        int checkDigit = calculateEan13CheckDigit(barcodeWithoutCheck);

        return barcodeWithoutCheck + checkDigit;
    }

    @Override
    public int calculateEan13CheckDigit(String barcode) {
        if (barcode == null || barcode.length() != 12) {
            throw new IllegalArgumentException("Barcode must be exactly 12 digits for EAN-13 check digit calculation");
        }

        int sum = 0;
        for (int i = 0; i < 12; i++) {
            int digit = Character.getNumericValue(barcode.charAt(i));
            // Multiply odd positions (1,3,5...) by 1, even positions (2,4,6...) by 3
            sum += (i % 2 == 0) ? digit : digit * 3;
        }

        int remainder = sum % 10;
        return (remainder == 0) ? 0 : (10 - remainder);
    }

    @Override
    public boolean isValidEan13(String barcode) {
        if (barcode == null || !barcode.matches("\\d{13}")) {
            return false;
        }

        String barcodeWithoutCheck = barcode.substring(0, 12);
        int providedCheckDigit = Character.getNumericValue(barcode.charAt(12));
        int calculatedCheckDigit = calculateEan13CheckDigit(barcodeWithoutCheck);

        return providedCheckDigit == calculatedCheckDigit;
    }

    @Override
    public boolean isSkuUnique(String sku) {
        if (sku == null || sku.trim().isEmpty()) {
            return false;
        }
        return !productVariantRepository.existsBySku(sku);
    }

    @Override
    public boolean isSkuUniqueForUpdate(String sku, UUID variantId) {
        if (sku == null || sku.trim().isEmpty()) {
            return false;
        }
        return !productVariantRepository.existsBySkuAndIdNot(sku, variantId);
    }

    @Override
    public boolean isBarcodeUnique(String barcode) {
        if (barcode == null || barcode.trim().isEmpty()) {
            return true; // Null/empty barcodes are allowed
        }
        return !productVariantRepository.existsByBarcode(barcode);
    }

    @Override
    public boolean isBarcodeUniqueForUpdate(String barcode, UUID variantId) {
        if (barcode == null || barcode.trim().isEmpty()) {
            return true; // Null/empty barcodes are allowed
        }
        return !productVariantRepository.existsByBarcodeAndIdNot(barcode, variantId);
    }
}
