package kg.bishkek.fucent.fusent.dto;

import lombok.*;
import java.time.LocalDateTime;

public class PaymentMethodDtos {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PaymentMethodRequest {
        private String type;
        private String cardNumber;
        private String cardHolder;
        private String expiryDate;
        private String phone;
        private Boolean isDefault;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PaymentMethodResponse {
        private String id;
        private String type;
        private String cardNumber;
        private String cardHolder;
        private String expiryDate;
        private String phone;
        private Boolean isDefault;
        private LocalDateTime createdAt;
    }
}
