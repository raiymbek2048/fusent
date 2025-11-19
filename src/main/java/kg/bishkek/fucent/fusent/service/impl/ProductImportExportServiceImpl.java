package kg.bishkek.fucent.fusent.service.impl;

import com.opencsv.bean.CsvToBeanBuilder;
import com.opencsv.bean.StatefulBeanToCsv;
import com.opencsv.bean.StatefulBeanToCsvBuilder;
import com.opencsv.exceptions.CsvDataTypeMismatchException;
import com.opencsv.exceptions.CsvRequiredFieldEmptyException;
import kg.bishkek.fucent.fusent.dto.ProductImportExportDtos.*;
import kg.bishkek.fucent.fusent.model.*;
import kg.bishkek.fucent.fusent.repository.*;
import kg.bishkek.fucent.fusent.service.ProductImportExportService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.*;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProductImportExportServiceImpl implements ProductImportExportService {

    private final ProductRepository productRepository;
    private final ProductVariantRepository productVariantRepository;
    private final ShopRepository shopRepository;
    private final CategoryRepository categoryRepository;

    private static final String[] CSV_HEADERS = {
            "Product Name", "Description", "Category", "Base Price",
            "Variant Name", "SKU", "Barcode", "Variant Price",
            "Stock", "Attributes", "Active", "Image URL"
    };

    @Override
    public byte[] exportToCSV(UUID shopId) throws IOException {
        log.info("Exporting products to CSV for shop: {}", shopId);

        Shop shop = shopRepository.findById(shopId)
                .orElseThrow(() -> new IllegalArgumentException("Shop not found: " + shopId));

        List<Product> products = productRepository.findByShopIdOrderByCreatedAtDesc(shopId);
        List<ProductExportRow> rows = convertProductsToExportRows(products);

        StringWriter writer = new StringWriter();
        StatefulBeanToCsv<ProductExportRow> beanToCsv = new StatefulBeanToCsvBuilder<ProductExportRow>(writer)
                .build();

        try {
            beanToCsv.write(rows);
        } catch (CsvDataTypeMismatchException | CsvRequiredFieldEmptyException e) {
            throw new IOException("Error writing CSV data", e);
        }

        return writer.toString().getBytes(StandardCharsets.UTF_8);
    }

    @Override
    public byte[] exportToXLSX(UUID shopId) throws IOException {
        log.info("Exporting products to XLSX for shop: {}", shopId);

        Shop shop = shopRepository.findById(shopId)
                .orElseThrow(() -> new IllegalArgumentException("Shop not found: " + shopId));

        List<Product> products = productRepository.findByShopIdOrderByCreatedAtDesc(shopId);
        List<ProductExportRow> rows = convertProductsToExportRows(products);

        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("Products");

        // Create header row
        Row headerRow = sheet.createRow(0);
        CellStyle headerStyle = createHeaderCellStyle(workbook);

        for (int i = 0; i < CSV_HEADERS.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(CSV_HEADERS[i]);
            cell.setCellStyle(headerStyle);
        }

        // Create data rows
        int rowNum = 1;
        for (ProductExportRow row : rows) {
            Row dataRow = sheet.createRow(rowNum++);
            fillExportRow(dataRow, row);
        }

        // Auto-size columns
        for (int i = 0; i < CSV_HEADERS.length; i++) {
            sheet.autoSizeColumn(i);
        }

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        workbook.write(outputStream);
        workbook.close();

        return outputStream.toByteArray();
    }

    @Override
    @Transactional
    public ImportResultDto importFromCSV(MultipartFile file, UUID shopId, boolean updateExisting, boolean skipErrors) throws IOException {
        log.info("Importing products from CSV for shop: {}", shopId);

        long startTime = System.currentTimeMillis();
        Shop shop = shopRepository.findById(shopId)
                .orElseThrow(() -> new IllegalArgumentException("Shop not found: " + shopId));

        List<ProductExportRow> rows = new CsvToBeanBuilder<ProductExportRow>(
                new InputStreamReader(file.getInputStream(), StandardCharsets.UTF_8))
                .withType(ProductExportRow.class)
                .withIgnoreLeadingWhiteSpace(true)
                .build()
                .parse();

        return processImport(rows, shop, updateExisting, skipErrors, System.currentTimeMillis() - startTime);
    }

    @Override
    @Transactional
    public ImportResultDto importFromXLSX(MultipartFile file, UUID shopId, boolean updateExisting, boolean skipErrors) throws IOException {
        log.info("Importing products from XLSX for shop: {}", shopId);

        long startTime = System.currentTimeMillis();
        Shop shop = shopRepository.findById(shopId)
                .orElseThrow(() -> new IllegalArgumentException("Shop not found: " + shopId));

        List<ProductExportRow> rows = parseXLSX(file.getInputStream());

        return processImport(rows, shop, updateExisting, skipErrors, System.currentTimeMillis() - startTime);
    }

    @Override
    public byte[] getTemplateCSV() throws IOException {
        StringWriter writer = new StringWriter();
        StatefulBeanToCsv<ProductExportRow> beanToCsv = new StatefulBeanToCsvBuilder<ProductExportRow>(writer)
                .build();

        List<ProductExportRow> template = List.of(createTemplateRow());

        try {
            beanToCsv.write(template);
        } catch (CsvDataTypeMismatchException | CsvRequiredFieldEmptyException e) {
            throw new IOException("Error writing CSV template", e);
        }

        return writer.toString().getBytes(StandardCharsets.UTF_8);
    }

    @Override
    public byte[] getTemplateXLSX() throws IOException {
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("Products");

        // Create header row
        Row headerRow = sheet.createRow(0);
        CellStyle headerStyle = createHeaderCellStyle(workbook);

        for (int i = 0; i < CSV_HEADERS.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(CSV_HEADERS[i]);
            cell.setCellStyle(headerStyle);
        }

        // Create example row
        Row exampleRow = sheet.createRow(1);
        fillExportRow(exampleRow, createTemplateRow());

        // Auto-size columns
        for (int i = 0; i < CSV_HEADERS.length; i++) {
            sheet.autoSizeColumn(i);
        }

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        workbook.write(outputStream);
        workbook.close();

        return outputStream.toByteArray();
    }

    // ==================== Private Helper Methods ====================

    private List<ProductExportRow> convertProductsToExportRows(List<Product> products) {
        List<ProductExportRow> rows = new ArrayList<>();

        for (Product product : products) {
            // If product has no variants, create a single row with default variant data
            if (product.getVariants() == null || product.getVariants().isEmpty()) {
                rows.add(ProductExportRow.builder()
                        .productName(product.getName())
                        .description(product.getDescription())
                        .categoryName(product.getCategory().getName())
                        .basePrice(product.getBasePrice() != null ? product.getBasePrice().toString() : "")
                        .variantName("Default")
                        .sku("")
                        .barcode("")
                        .variantPrice(product.getBasePrice() != null ? product.getBasePrice().toString() : "")
                        .stock("0")
                        .attributes("{}")
                        .active(String.valueOf(product.isActive()))
                        .imageUrl(product.getImageUrl())
                        .build());
            } else {
                // Create one row per variant
                for (ProductVariant variant : product.getVariants()) {
                    rows.add(ProductExportRow.builder()
                            .productName(product.getName())
                            .description(product.getDescription())
                            .categoryName(product.getCategory().getName())
                            .basePrice(product.getBasePrice() != null ? product.getBasePrice().toString() : "")
                            .variantName(variant.getName() != null ? variant.getName() : "Default")
                            .sku(variant.getSku())
                            .barcode(variant.getBarcode())
                            .variantPrice(variant.getPrice().toString())
                            .stock(String.valueOf(variant.getStockQty()))
                            .attributes(variant.getAttributesJson() != null ? variant.getAttributesJson() : "{}")
                            .active(String.valueOf(product.isActive()))
                            .imageUrl(product.getImageUrl())
                            .build());
                }
            }
        }

        return rows;
    }

    private ImportResultDto processImport(List<ProductExportRow> rows, Shop shop, boolean updateExisting, boolean skipErrors, long startTime) {
        int successCount = 0;
        List<String> errors = new ArrayList<>();
        List<String> warnings = new ArrayList<>();

        // Group rows by product name (multiple rows can belong to same product if they have different variants)
        Map<String, List<ProductImportRow>> productGroups = groupRowsByProduct(rows);

        for (Map.Entry<String, List<ProductImportRow>> entry : productGroups.entrySet()) {
            String productName = entry.getKey();
            List<ProductImportRow> variants = entry.getValue();

            try {
                ProductImportRow firstRow = variants.get(0);

                // Validate all variants for this product
                boolean allValid = true;
                for (ProductImportRow row : variants) {
                    validateRow(row, shop);
                    if (!row.isValid()) {
                        allValid = false;
                        errors.addAll(row.getValidationErrors());
                    }
                }

                if (!allValid && !skipErrors) {
                    continue;
                }

                // Find or create product
                Category category = findOrCreateCategory(firstRow.getCategoryName());
                Product product = findOrCreateProduct(productName, shop, category, firstRow, updateExisting);

                // Create/update variants
                for (ProductImportRow variantRow : variants) {
                    if (!variantRow.isValid() && skipErrors) {
                        warnings.add("Skipped invalid variant: " + variantRow.getSku());
                        continue;
                    }

                    createOrUpdateVariant(product, variantRow, updateExisting);
                }

                successCount++;

            } catch (Exception e) {
                String error = "Error importing product '" + productName + "': " + e.getMessage();
                errors.add(error);
                log.error(error, e);

                if (!skipErrors) {
                    throw new RuntimeException(error, e);
                }
            }
        }

        long processingTime = System.currentTimeMillis() - startTime;

        return ImportResultDto.builder()
                .totalRows(rows.size())
                .successCount(successCount)
                .errorCount(errors.size())
                .errors(errors)
                .warnings(warnings)
                .processingTimeMs(processingTime)
                .build();
    }

    private Map<String, List<ProductImportRow>> groupRowsByProduct(List<ProductExportRow> rows) {
        Map<String, List<ProductImportRow>> groups = new LinkedHashMap<>();

        for (ProductExportRow row : rows) {
            ProductImportRow importRow = convertToImportRow(row);
            groups.computeIfAbsent(importRow.getProductName(), k -> new ArrayList<>()).add(importRow);
        }

        return groups;
    }

    private ProductImportRow convertToImportRow(ProductExportRow row) {
        return ProductImportRow.builder()
                .productName(row.getProductName())
                .description(row.getDescription())
                .categoryName(row.getCategoryName())
                .basePrice(parseDecimal(row.getBasePrice()))
                .variantName(row.getVariantName())
                .sku(row.getSku())
                .barcode(row.getBarcode())
                .variantPrice(parseDecimal(row.getVariantPrice()))
                .stock(parseInt(row.getStock()))
                .attributesJson(row.getAttributes())
                .active(parseBoolean(row.getActive()))
                .imageUrl(row.getImageUrl())
                .build();
    }

    private void validateRow(ProductImportRow row, Shop shop) {
        if (row.getProductName() == null || row.getProductName().trim().isEmpty()) {
            row.addValidationError("Product name is required");
        }

        if (row.getCategoryName() == null || row.getCategoryName().trim().isEmpty()) {
            row.addValidationError("Category is required");
        }

        if (row.getBasePrice() == null || row.getBasePrice().compareTo(BigDecimal.ZERO) < 0) {
            row.addValidationError("Base price must be a positive number");
        }

        if (row.getVariantPrice() == null || row.getVariantPrice().compareTo(BigDecimal.ZERO) < 0) {
            row.addValidationError("Variant price must be a positive number");
        }

        if (row.getSku() == null || row.getSku().trim().isEmpty()) {
            row.addValidationError("SKU is required");
        }

        if (row.getStock() == null || row.getStock() < 0) {
            row.addValidationError("Stock must be a non-negative integer");
        }
    }

    private Category findOrCreateCategory(String categoryName) {
        return categoryRepository.findByName(categoryName)
                .orElseGet(() -> {
                    Category newCategory = Category.builder()
                            .name(categoryName)
                            .build();
                    return categoryRepository.save(newCategory);
                });
    }

    private Product findOrCreateProduct(String productName, Shop shop, Category category, ProductImportRow row, boolean updateExisting) {
        Optional<Product> existing = productRepository.findByShopAndName(shop, productName);

        if (existing.isPresent()) {
            if (updateExisting) {
                Product product = existing.get();
                product.setDescription(row.getDescription());
                product.setBasePrice(row.getBasePrice());
                product.setActive(row.getActive());
                product.setImageUrl(row.getImageUrl());
                product.setCategory(category);
                return productRepository.save(product);
            }
            return existing.get();
        }

        // Create new product
        Product newProduct = Product.builder()
                .shop(shop)
                .category(category)
                .name(productName)
                .description(row.getDescription())
                .basePrice(row.getBasePrice())
                .active(row.getActive())
                .imageUrl(row.getImageUrl())
                .build();

        return productRepository.save(newProduct);
    }

    private void createOrUpdateVariant(Product product, ProductImportRow row, boolean updateExisting) {
        Optional<ProductVariant> existing = productVariantRepository.findBySku(row.getSku());

        if (existing.isPresent()) {
            if (updateExisting) {
                ProductVariant variant = existing.get();
                variant.setName(row.getVariantName());
                variant.setPrice(row.getVariantPrice());
                variant.setStockQty(row.getStock());
                variant.setBarcode(row.getBarcode());
                variant.setAttributesJson(row.getAttributesJson());
                productVariantRepository.save(variant);
            }
            return;
        }

        // Create new variant
        ProductVariant newVariant = ProductVariant.builder()
                .product(product)
                .sku(row.getSku())
                .name(row.getVariantName())
                .price(row.getVariantPrice())
                .stockQty(row.getStock())
                .barcode(row.getBarcode())
                .attributesJson(row.getAttributesJson())
                .build();

        productVariantRepository.save(newVariant);
    }

    private List<ProductExportRow> parseXLSX(InputStream inputStream) throws IOException {
        List<ProductExportRow> rows = new ArrayList<>();
        Workbook workbook = new XSSFWorkbook(inputStream);
        Sheet sheet = workbook.getSheetAt(0);

        // Skip header row
        for (int i = 1; i <= sheet.getLastRowNum(); i++) {
            Row row = sheet.getRow(i);
            if (row == null) continue;

            ProductExportRow exportRow = ProductExportRow.builder()
                    .productName(getCellValueAsString(row.getCell(0)))
                    .description(getCellValueAsString(row.getCell(1)))
                    .categoryName(getCellValueAsString(row.getCell(2)))
                    .basePrice(getCellValueAsString(row.getCell(3)))
                    .variantName(getCellValueAsString(row.getCell(4)))
                    .sku(getCellValueAsString(row.getCell(5)))
                    .barcode(getCellValueAsString(row.getCell(6)))
                    .variantPrice(getCellValueAsString(row.getCell(7)))
                    .stock(getCellValueAsString(row.getCell(8)))
                    .attributes(getCellValueAsString(row.getCell(9)))
                    .active(getCellValueAsString(row.getCell(10)))
                    .imageUrl(getCellValueAsString(row.getCell(11)))
                    .build();

            rows.add(exportRow);
        }

        workbook.close();
        return rows;
    }

    private void fillExportRow(Row row, ProductExportRow data) {
        row.createCell(0).setCellValue(data.getProductName());
        row.createCell(1).setCellValue(data.getDescription());
        row.createCell(2).setCellValue(data.getCategoryName());
        row.createCell(3).setCellValue(data.getBasePrice());
        row.createCell(4).setCellValue(data.getVariantName());
        row.createCell(5).setCellValue(data.getSku());
        row.createCell(6).setCellValue(data.getBarcode());
        row.createCell(7).setCellValue(data.getVariantPrice());
        row.createCell(8).setCellValue(data.getStock());
        row.createCell(9).setCellValue(data.getAttributes());
        row.createCell(10).setCellValue(data.getActive());
        row.createCell(11).setCellValue(data.getImageUrl());
    }

    private CellStyle createHeaderCellStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        style.setFont(font);
        style.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        return style;
    }

    private ProductExportRow createTemplateRow() {
        return ProductExportRow.builder()
                .productName("Example Product")
                .description("Product description goes here")
                .categoryName("Electronics")
                .basePrice("99.99")
                .variantName("Standard")
                .sku("SKU-EXAMPLE-001")
                .barcode("1234567890123")
                .variantPrice("99.99")
                .stock("100")
                .attributes("{\"color\":\"Black\",\"size\":\"M\"}")
                .active("true")
                .imageUrl("https://example.com/image.jpg")
                .build();
    }

    private String getCellValueAsString(Cell cell) {
        if (cell == null) return "";

        return switch (cell.getCellType()) {
            case STRING -> cell.getStringCellValue();
            case NUMERIC -> String.valueOf((long) cell.getNumericCellValue());
            case BOOLEAN -> String.valueOf(cell.getBooleanCellValue());
            case FORMULA -> cell.getCellFormula();
            default -> "";
        };
    }

    private BigDecimal parseDecimal(String value) {
        if (value == null || value.trim().isEmpty()) return BigDecimal.ZERO;
        try {
            return new BigDecimal(value.trim());
        } catch (NumberFormatException e) {
            return BigDecimal.ZERO;
        }
    }

    private Integer parseInt(String value) {
        if (value == null || value.trim().isEmpty()) return 0;
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private Boolean parseBoolean(String value) {
        if (value == null || value.trim().isEmpty()) return true;
        return Boolean.parseBoolean(value.trim());
    }
}
