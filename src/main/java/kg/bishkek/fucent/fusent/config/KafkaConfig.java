package kg.bishkek.fucent.fusent.config;

import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.TopicBuilder;

/**
 * Kafka configuration - defines topics and their partitions
 */
@Configuration
public class KafkaConfig {

    // Analytics topics
    @Bean
    public NewTopic analyticsRawTopic() {
        return TopicBuilder.name("analytics.raw")
                .partitions(3)
                .replicas(1)
                .build();
    }

    // POS topics
    @Bean
    public NewTopic posSalesTopic() {
        return TopicBuilder.name("pos.sales")
                .partitions(3)
                .replicas(1)
                .build();
    }

    // Inventory topics
    @Bean
    public NewTopic inventoryUpdatedTopic() {
        return TopicBuilder.name("inventory.updated")
                .partitions(3)
                .replicas(1)
                .build();
    }

    // Notification topics
    @Bean
    public NewTopic notifyOrderTopic() {
        return TopicBuilder.name("notify.order")
                .partitions(2)
                .replicas(1)
                .build();
    }

    @Bean
    public NewTopic notifyChatTopic() {
        return TopicBuilder.name("notify.chat")
                .partitions(2)
                .replicas(1)
                .build();
    }

    @Bean
    public NewTopic notifyPosTopic() {
        return TopicBuilder.name("notify.pos")
                .partitions(2)
                .replicas(1)
                .build();
    }

    @Bean
    public NewTopic notifyModerationTopic() {
        return TopicBuilder.name("notify.moderation")
                .partitions(2)
                .replicas(1)
                .build();
    }

    // Ads topics
    @Bean
    public NewTopic adsEventsTopic() {
        return TopicBuilder.name("ads.events")
                .partitions(2)
                .replicas(1)
                .build();
    }
}
