package kg.bishkek.fucent.fusent.kafka;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class PosEventConsumer {

    @KafkaListener(topics = "pos-events", groupId = "pos-processor")
    public void consumePosEvent(String message) {
        try {
            log.info("Processing POS event: {}", message);

            // TODO: Process POS events
            // - Update inventory
            // - Calculate buy eligibility
            // - Sync with shop metrics

        } catch (Exception e) {
            log.error("Error processing POS event: {}", message, e);
        }
    }
}
