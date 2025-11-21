package kg.bishkek.fucent.fusent.dto;

import lombok.*;
import java.time.LocalDateTime;

public class DeliveryAddressDtos {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AddressRequest {
        private String title;
        private String city;
        private String street;
        private String building;
        private String apartment;
        private String entrance;
        private String floor;
        private String intercom;
        private String phone;
        private String comment;
        private Boolean isDefault;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AddressResponse {
        private String id;
        private String title;
        private String city;
        private String street;
        private String building;
        private String apartment;
        private String entrance;
        private String floor;
        private String intercom;
        private String phone;
        private String comment;
        private Boolean isDefault;
        private LocalDateTime createdAt;
    }
}
