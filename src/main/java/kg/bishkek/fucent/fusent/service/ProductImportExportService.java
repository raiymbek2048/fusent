package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.ProductImportExportDtos.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.UUID;

/**
 * Service for importing and exporting products in CSV/XLSX format
 */
public interface ProductImportExportService {

    /**
     * Export products from a shop to CSV format
     *
     * @param shopId Shop ID to export products from
     * @return Byte array containing CSV data
     */
    byte[] exportToCSV(UUID shopId) throws IOException;

    /**
     * Export products from a shop to XLSX format
     *
     * @param shopId Shop ID to export products from
     * @return Byte array containing XLSX data
     */
    byte[] exportToXLSX(UUID shopId) throws IOException;

    /**
     * Import products from CSV file
     *
     * @param file CSV file to import
     * @param shopId Shop ID to import products into
     * @param updateExisting If true, update existing products by SKU
     * @param skipErrors If true, continue on errors instead of rolling back
     * @return Import result with statistics and errors
     */
    ImportResultDto importFromCSV(MultipartFile file, UUID shopId, boolean updateExisting, boolean skipErrors) throws IOException;

    /**
     * Import products from XLSX file
     *
     * @param file XLSX file to import
     * @param shopId Shop ID to import products into
     * @param updateExisting If true, update existing products by SKU
     * @param skipErrors If true, continue on errors instead of rolling back
     * @return Import result with statistics and errors
     */
    ImportResultDto importFromXLSX(MultipartFile file, UUID shopId, boolean updateExisting, boolean skipErrors) throws IOException;

    /**
     * Get template CSV file for importing products
     *
     * @return Byte array containing template CSV with headers and example row
     */
    byte[] getTemplateCSV() throws IOException;

    /**
     * Get template XLSX file for importing products
     *
     * @return Byte array containing template XLSX with headers and example row
     */
    byte[] getTemplateXLSX() throws IOException;
}
