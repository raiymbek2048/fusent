package kg.bishkek.fucent.fusent.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import kg.bishkek.fucent.fusent.dto.ProductImportExportDtos.*;
import kg.bishkek.fucent.fusent.service.ProductImportExportService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/seller/products")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Product Import/Export", description = "APIs for importing and exporting products in CSV/XLSX format")
@SecurityRequirement(name = "Bearer Authentication")
public class ProductImportExportController {

    private final ProductImportExportService importExportService;

    @GetMapping("/export/csv")
    @PreAuthorize("hasRole('SELLER') or hasRole('MERCHANT') or hasRole('ADMIN')")
    @Operation(summary = "Export products to CSV", description = "Export all products from a shop to CSV format")
    public ResponseEntity<byte[]> exportToCSV(@RequestParam UUID shopId) {
        try {
            log.info("Exporting products to CSV for shop: {}", shopId);
            byte[] csvData = importExportService.exportToCSV(shopId);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.parseMediaType("text/csv"));
            headers.setContentDispositionFormData("attachment", "products_" + shopId + ".csv");
            headers.setContentLength(csvData.length);

            return ResponseEntity.ok()
                    .headers(headers)
                    .body(csvData);

        } catch (IOException e) {
            log.error("Error exporting products to CSV", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/export/xlsx")
    @PreAuthorize("hasRole('SELLER') or hasRole('MERCHANT') or hasRole('ADMIN')")
    @Operation(summary = "Export products to XLSX", description = "Export all products from a shop to Excel (XLSX) format")
    public ResponseEntity<byte[]> exportToXLSX(@RequestParam UUID shopId) {
        try {
            log.info("Exporting products to XLSX for shop: {}", shopId);
            byte[] xlsxData = importExportService.exportToXLSX(shopId);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"));
            headers.setContentDispositionFormData("attachment", "products_" + shopId + ".xlsx");
            headers.setContentLength(xlsxData.length);

            return ResponseEntity.ok()
                    .headers(headers)
                    .body(xlsxData);

        } catch (IOException e) {
            log.error("Error exporting products to XLSX", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @PostMapping("/import/csv")
    @PreAuthorize("hasRole('SELLER') or hasRole('MERCHANT') or hasRole('ADMIN')")
    @Operation(summary = "Import products from CSV", description = "Import products from CSV file into a shop")
    public ResponseEntity<ImportResultDto> importFromCSV(
            @RequestParam("file") MultipartFile file,
            @RequestParam UUID shopId,
            @RequestParam(defaultValue = "false") boolean updateExisting,
            @RequestParam(defaultValue = "true") boolean skipErrors
    ) {
        try {
            log.info("Importing products from CSV for shop: {}", shopId);

            if (file.isEmpty()) {
                return ResponseEntity.badRequest().build();
            }

            if (!file.getOriginalFilename().endsWith(".csv")) {
                return ResponseEntity.badRequest().build();
            }

            ImportResultDto result = importExportService.importFromCSV(
                    file,
                    shopId,
                    updateExisting,
                    skipErrors
            );

            return ResponseEntity.ok(result);

        } catch (IOException e) {
            log.error("Error importing products from CSV", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        } catch (IllegalArgumentException e) {
            log.error("Invalid shop ID", e);
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping("/import/xlsx")
    @PreAuthorize("hasRole('SELLER') or hasRole('MERCHANT') or hasRole('ADMIN')")
    @Operation(summary = "Import products from XLSX", description = "Import products from Excel (XLSX) file into a shop")
    public ResponseEntity<ImportResultDto> importFromXLSX(
            @RequestParam("file") MultipartFile file,
            @RequestParam UUID shopId,
            @RequestParam(defaultValue = "false") boolean updateExisting,
            @RequestParam(defaultValue = "true") boolean skipErrors
    ) {
        try {
            log.info("Importing products from XLSX for shop: {}", shopId);

            if (file.isEmpty()) {
                return ResponseEntity.badRequest().build();
            }

            if (!file.getOriginalFilename().endsWith(".xlsx")) {
                return ResponseEntity.badRequest().build();
            }

            ImportResultDto result = importExportService.importFromXLSX(
                    file,
                    shopId,
                    updateExisting,
                    skipErrors
            );

            return ResponseEntity.ok(result);

        } catch (IOException e) {
            log.error("Error importing products from XLSX", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        } catch (IllegalArgumentException e) {
            log.error("Invalid shop ID", e);
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/templates/csv")
    @PreAuthorize("hasRole('SELLER') or hasRole('MERCHANT') or hasRole('ADMIN')")
    @Operation(summary = "Get CSV template", description = "Download CSV template file for importing products")
    public ResponseEntity<byte[]> getCSVTemplate() {
        try {
            byte[] csvData = importExportService.getTemplateCSV();

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.parseMediaType("text/csv"));
            headers.setContentDispositionFormData("attachment", "product_import_template.csv");
            headers.setContentLength(csvData.length);

            return ResponseEntity.ok()
                    .headers(headers)
                    .body(csvData);

        } catch (IOException e) {
            log.error("Error generating CSV template", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/templates/xlsx")
    @PreAuthorize("hasRole('SELLER') or hasRole('MERCHANT') or hasRole('ADMIN')")
    @Operation(summary = "Get XLSX template", description = "Download Excel (XLSX) template file for importing products")
    public ResponseEntity<byte[]> getXLSXTemplate() {
        try {
            byte[] xlsxData = importExportService.getTemplateXLSX();

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"));
            headers.setContentDispositionFormData("attachment", "product_import_template.xlsx");
            headers.setContentLength(xlsxData.length);

            return ResponseEntity.ok()
                    .headers(headers)
                    .body(xlsxData);

        } catch (IOException e) {
            log.error("Error generating XLSX template", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}
