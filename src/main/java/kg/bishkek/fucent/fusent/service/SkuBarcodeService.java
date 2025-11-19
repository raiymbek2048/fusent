package kg.bishkek.fucent.fusent.service;

import java.util.UUID;

/**
 * Service for generating and validating SKU (Stock Keeping Unit) and barcodes
 */
public interface SkuBarcodeService {

    /**
     * Generate a unique SKU for a product variant
     * Format: {SHOP_ID_SHORT}-{CATEGORY_ID_SHORT}-{RANDOM_6_DIGITS}
     * Example: "SHP1A2B-CAT3C4-847392"
     *
     * @param shopId Shop ID
     * @param categoryId Category ID
     * @return Unique SKU string
     */
    String generateSku(UUID shopId, UUID categoryId);

    /**
     * Generate a unique EAN-13 barcode
     * Format: 13 digits with check digit
     * Prefix: 978 (bookland) or custom
     *
     * @return Unique barcode string
     */
    String generateBarcode();

    /**
     * Validate if SKU is unique
     *
     * @param sku SKU to validate
     * @return true if unique, false if already exists
     */
    boolean isSkuUnique(String sku);

    /**
     * Validate if SKU is unique for variant update (excluding current variant)
     *
     * @param sku SKU to validate
     * @param variantId Current variant ID to exclude from check
     * @return true if unique, false if already exists for another variant
     */
    boolean isSkuUniqueForUpdate(String sku, UUID variantId);

    /**
     * Validate if barcode is unique
     *
     * @param barcode Barcode to validate
     * @return true if unique, false if already exists
     */
    boolean isBarcodeUnique(String barcode);

    /**
     * Validate if barcode is unique for variant update (excluding current variant)
     *
     * @param barcode Barcode to validate
     * @param variantId Current variant ID to exclude from check
     * @return true if unique, false if already exists for another variant
     */
    boolean isBarcodeUniqueForUpdate(String barcode, UUID variantId);

    /**
     * Validate EAN-13 barcode format and check digit
     *
     * @param barcode Barcode to validate
     * @return true if valid EAN-13 format
     */
    boolean isValidEan13(String barcode);

    /**
     * Calculate EAN-13 check digit
     *
     * @param barcode First 12 digits of barcode
     * @return Check digit (0-9)
     */
    int calculateEan13CheckDigit(String barcode);
}
