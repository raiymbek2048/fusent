package kg.bishkek.fucent.fusent.service.impl;

import kg.bishkek.fucent.fusent.dto.AnalyticsDtos.*;
import kg.bishkek.fucent.fusent.model.Product;
import kg.bishkek.fucent.fusent.model.ProductMetricDaily;
import kg.bishkek.fucent.fusent.model.ProductVariant;
import kg.bishkek.fucent.fusent.model.Shop;
import kg.bishkek.fucent.fusent.model.ShopMetricDaily;
import kg.bishkek.fucent.fusent.repository.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.kafka.core.KafkaTemplate;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AnalyticsServiceImplTest {

    @Mock
    private AnalyticEventRawRepository analyticEventRepository;

    @Mock
    private ShopMetricDailyRepository shopMetricRepository;

    @Mock
    private ProductMetricDailyRepository productMetricRepository;

    @Mock
    private ShopRepository shopRepository;

    @Mock
    private ProductVariantRepository productVariantRepository;

    @Mock
    private KafkaTemplate<String, Object> kafkaTemplate;

    @InjectMocks
    private AnalyticsServiceImpl analyticsService;

    private Shop testShop;
    private ShopMetricDaily testShopMetric;
    private ProductVariant testVariant;
    private Product testProduct;
    private ProductMetricDaily testProductMetric;

    @BeforeEach
    void setUp() {
        testShop = Shop.builder()
            .id(UUID.randomUUID())
            .name("Test Shop")
            .build();

        testShopMetric = ShopMetricDaily.builder()
            .id(UUID.randomUUID())
            .shop(testShop)
            .day(LocalDate.now())
            .views(100)
            .clicks(50)
            .routeBuilds(20)
            .chatsStarted(10)
            .follows(5)
            .unfollows(2)
            .revenue(new BigDecimal("1000.00"))
            .build();

        testProduct = Product.builder()
            .id(UUID.randomUUID())
            .name("Test Product")
            .shop(testShop)
            .build();

        testVariant = ProductVariant.builder()
            .id(UUID.randomUUID())
            .product(testProduct)
            .sku("TEST-SKU-001")
            .price(99.99)
            .build();

        testProductMetric = ProductMetricDaily.builder()
            .id(UUID.randomUUID())
            .variant(testVariant)
            .day(LocalDate.now())
            .views(200)
            .clicks(80)
            .addToCart(30)
            .orders(15)
            .revenue(new BigDecimal("1499.85"))
            .build();
    }

    @Test
    void trackEvent_shouldSaveEventAndSendToKafka() {
        // Given
        TrackEventRequest request = new TrackEventRequest(
            "shop_view",
            UUID.randomUUID(),
            testShop.getId(),
            "SHOP",
            null
        );

        // When
        analyticsService.trackEvent(request);

        // Then
        verify(analyticEventRepository, times(1)).save(any());
        verify(kafkaTemplate, times(1)).send(eq("analytics-events"), eq(request));
    }

    @Test
    void getShopMetricsForDay_shouldReturnMetricsWhenExists() {
        // Given
        LocalDate day = LocalDate.now();
        when(shopRepository.findById(testShop.getId())).thenReturn(Optional.of(testShop));
        when(shopMetricRepository.findByShopAndDay(testShop, day))
            .thenReturn(Optional.of(testShopMetric));

        // When
        ShopMetricDailyResponse response = analyticsService.getShopMetricsForDay(testShop.getId(), day);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.shopId()).isEqualTo(testShop.getId());
        assertThat(response.shopName()).isEqualTo("Test Shop");
        assertThat(response.views()).isEqualTo(100);
        assertThat(response.clicks()).isEqualTo(50);
        assertThat(response.revenue()).isEqualTo(new BigDecimal("1000.00"));
    }

    @Test
    void getShopMetricsForDay_shouldReturnZeroMetricsWhenNotExists() {
        // Given
        LocalDate day = LocalDate.now();
        when(shopRepository.findById(testShop.getId())).thenReturn(Optional.of(testShop));
        when(shopMetricRepository.findByShopAndDay(testShop, day))
            .thenReturn(Optional.empty());

        // When
        ShopMetricDailyResponse response = analyticsService.getShopMetricsForDay(testShop.getId(), day);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.views()).isEqualTo(0);
        assertThat(response.clicks()).isEqualTo(0);
        assertThat(response.revenue()).isEqualTo(BigDecimal.ZERO);
    }

    @Test
    void getShopMetricsForDay_shouldThrowExceptionWhenShopNotFound() {
        // Given
        UUID nonExistentShopId = UUID.randomUUID();
        LocalDate day = LocalDate.now();
        when(shopRepository.findById(nonExistentShopId)).thenReturn(Optional.empty());

        // When & Then
        assertThatThrownBy(() -> analyticsService.getShopMetricsForDay(nonExistentShopId, day))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("Shop not found");
    }

    @Test
    void getShopMetricsSummary_shouldCalculateCorrectAggregates() {
        // Given
        LocalDate startDate = LocalDate.now().minusDays(6);
        LocalDate endDate = LocalDate.now();

        List<ShopMetricDaily> metrics = List.of(
            createShopMetric(testShop, LocalDate.now().minusDays(2), 100, 50, new BigDecimal("500.00")),
            createShopMetric(testShop, LocalDate.now().minusDays(1), 150, 75, new BigDecimal("750.00")),
            createShopMetric(testShop, LocalDate.now(), 200, 100, new BigDecimal("1000.00"))
        );

        when(shopRepository.findById(testShop.getId())).thenReturn(Optional.of(testShop));
        when(shopMetricRepository.findByShopAndDayBetween(testShop, startDate, endDate))
            .thenReturn(metrics);

        // When
        ShopMetricsSummaryResponse summary = analyticsService.getShopMetricsSummary(
            testShop.getId(), startDate, endDate
        );

        // Then
        assertThat(summary).isNotNull();
        assertThat(summary.totalViews()).isEqualTo(450L); // 100 + 150 + 200
        assertThat(summary.totalClicks()).isEqualTo(225L); // 50 + 75 + 100
        assertThat(summary.totalRevenue()).isEqualTo(new BigDecimal("2250.00")); // 500 + 750 + 1000
        assertThat(summary.avgViewsPerDay()).isEqualTo(150.0); // 450 / 3
        assertThat(summary.conversionRate()).isEqualTo(50.0); // (225 / 450) * 100
    }

    @Test
    void getProductMetricsForDay_shouldReturnMetricsWhenExists() {
        // Given
        LocalDate day = LocalDate.now();
        when(productVariantRepository.findById(testVariant.getId())).thenReturn(Optional.of(testVariant));
        when(productMetricRepository.findByVariantAndDay(testVariant, day))
            .thenReturn(Optional.of(testProductMetric));

        // When
        ProductMetricDailyResponse response = analyticsService.getProductMetricsForDay(
            testVariant.getId(), day
        );

        // Then
        assertThat(response).isNotNull();
        assertThat(response.variantId()).isEqualTo(testVariant.getId());
        assertThat(response.productName()).isEqualTo("Test Product");
        assertThat(response.views()).isEqualTo(200);
        assertThat(response.clicks()).isEqualTo(80);
        assertThat(response.addToCart()).isEqualTo(30);
        assertThat(response.orders()).isEqualTo(15);
    }

    @Test
    void getTopProducts_shouldReturnEmptyListWhenNoVariants() {
        // Given
        LocalDate startDate = LocalDate.now().minusDays(7);
        LocalDate endDate = LocalDate.now();
        when(shopRepository.findById(testShop.getId())).thenReturn(Optional.of(testShop));
        when(productVariantRepository.findAll()).thenReturn(List.of());

        // When
        List<ProductMetricDailyResponse> topProducts = analyticsService.getTopProducts(
            testShop.getId(), startDate, endDate, "revenue", 10
        );

        // Then
        assertThat(topProducts).isEmpty();
    }

    private ShopMetricDaily createShopMetric(Shop shop, LocalDate day, int views, int clicks, BigDecimal revenue) {
        return ShopMetricDaily.builder()
            .id(UUID.randomUUID())
            .shop(shop)
            .day(day)
            .views(views)
            .clicks(clicks)
            .routeBuilds(10)
            .chatsStarted(5)
            .follows(2)
            .unfollows(1)
            .revenue(revenue)
            .build();
    }
}
