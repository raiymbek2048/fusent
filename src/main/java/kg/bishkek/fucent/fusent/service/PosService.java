package kg.bishkek.fucent.fusent.service;

import kg.bishkek.fucent.fusent.dto.PosSaleRequest;
import org.springframework.transaction.annotation.Transactional;

public interface PosService {
    @Transactional
    void recordSale(PosSaleRequest req);
}
