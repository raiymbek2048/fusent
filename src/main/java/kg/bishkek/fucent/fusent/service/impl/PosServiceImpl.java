package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.PosSaleRequest;
import kg.bishkek.fucent.fusent.model.PosSale;
import kg.bishkek.fucent.fusent.repository.PosSaleRepository;
import kg.bishkek.fucent.fusent.repository.ProductVariantRepository;
import kg.bishkek.fucent.fusent.service.PosService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.RoundingMode;


@Service
@RequiredArgsConstructor
public class PosServiceImpl implements PosService {
    private final PosSaleRepository posSaleRepository;
    private final ProductVariantRepository variantRepository;


    @Transactional
    @Override
    public void recordSale(PosSaleRequest req) {
        if (posSaleRepository.existsByReceiptNumberAndShopId(req.receiptNumber(), req.shopId()))
            throw new IllegalArgumentException("Duplicate receipt");
        for (var it : req.items()) {
            var variant = variantRepository.findById(it.variantId()).orElseThrow();
            var sale = PosSale.builder()
                    .shopId(req.shopId())
                    .variant(variant)
                    .qty(it.qty())
                    .unitPrice(it.unitPrice())
                    .totalPrice(it.qty().multiply(it.unitPrice()))
                    .receiptNumber(req.receiptNumber())
                    .build();
            posSaleRepository.save(sale);
// naive stock decrement (no reservations yet)
            int qtyToDecrement = it.qty().setScale(0, RoundingMode.UP).intValue();
            variant.setStockQty(Math.max(0, variant.getStockQty() - qtyToDecrement));
            variantRepository.save(variant);
        }
    }
}
