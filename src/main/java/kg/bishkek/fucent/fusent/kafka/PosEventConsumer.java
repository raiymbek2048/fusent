package kg.bishkek.fucent.fusent.kafka;

import com.fasterxml.jackson.databind.ObjectMapper;
import kg.bishkek.fucent.fusent.dto.PosSaleRequest;
import kg.bishkek.fucent.fusent.service.PosService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class PosEventConsumer {

    private final PosService posService;
    private final ObjectMapper objectMapper;

    @KafkaListener(topics = "pos.sales", groupId = "pos-processor")
    public void consumePosSale(String message) {
        try {
            log.info("Processing POS sale event: {}", message);

            // Deserialize JSON to PosSaleRequest
            PosSaleRequest saleRequest = objectMapper.readValue(message, PosSaleRequest.class);

            // Process the sale (updates inventory, records sale)
            posService.recordSale(saleRequest);

            log.info("Successfully processed POS sale: receiptNumber={}, shopId={}, items={}",
                    saleRequest.receiptNumber(), saleRequest.shopId(), saleRequest.items().size());

        } catch (Exception e) {
            log.error("Error processing POS sale event: {}", message, e);
            // TODO: Consider dead letter queue for failed messages
        }
    }
}
