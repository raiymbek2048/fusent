package kg.bishkek.fucent.fusent.config;

import kg.bishkek.fucent.fusent.enums.*;
import kg.bishkek.fucent.fusent.model.*;
import kg.bishkek.fucent.fusent.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Configuration
@RequiredArgsConstructor
@Slf4j
public class DataSeeder {

    private final AppUserRepository userRepository;
    private final MerchantRepository merchantRepository;
    private final CategoryRepository categoryRepository;
    private final ShopRepository shopRepository;
    private final ProductRepository productRepository;
    private final ProductVariantRepository variantRepository;
    private final PostRepository postRepository;
    private final PostMediaRepository postMediaRepository;
    private final PostTagRepository postTagRepository;
    private final LikeRepository likeRepository;
    private final CommentRepository commentRepository;
    private final PasswordEncoder passwordEncoder;

    @Bean
    CommandLineRunner seedData() {
        return args -> {
            // Check if data already exists
            if (userRepository.count() > 0) {
                log.info("Database already contains data. Skipping seed.");
                return;
            }

            log.info("Starting database seeding...");

            // 1. Create test users
            var users = createUsers();
            log.info("Created {} users", users.size());

            // 2. Create categories
            var categories = createCategories();
            log.info("Created {} categories", categories.size());

            // 3. Create merchants
            var merchants = createMerchants(users);
            log.info("Created {} merchants", merchants.size());

            // 4. Create shops
            var shops = createShops(merchants);
            log.info("Created {} shops", shops.size());

            // 4. Create products
            var products = createProducts(shops, categories);
            log.info("Created {} products", products.size());

            // 5. Create product variants
            var variants = createVariants(products);
            log.info("Created {} product variants", variants.size());

            // 6. Create social posts
            var posts = createPosts(shops);
            log.info("Created {} posts", posts.size());

            // 7. Create likes and comments
            createSocialInteractions(posts, users);
            log.info("Created social interactions");

            log.info("Database seeding completed successfully!");
        };
    }

    private List<AppUser> createUsers() {
        List<AppUser> users = new ArrayList<>();

        // Admin user
        users.add(AppUser.builder()
                .email("admin@fusent.kg")
                .passwordHash(passwordEncoder.encode("admin123"))
                .role(Role.ADMIN)
                .build());

        // Seller users
        users.add(AppUser.builder()
                .email("fashion.store@fusent.kg")
                .passwordHash(passwordEncoder.encode("seller123"))
                .role(Role.SELLER)
                .build());

        users.add(AppUser.builder()
                .email("tech.shop@fusent.kg")
                .passwordHash(passwordEncoder.encode("seller123"))
                .role(Role.SELLER)
                .build());

        users.add(AppUser.builder()
                .email("home.decor@fusent.kg")
                .passwordHash(passwordEncoder.encode("seller123"))
                .role(Role.SELLER)
                .build());

        // Buyer users
        for (int i = 1; i <= 5; i++) {
            users.add(AppUser.builder()
                    .email("buyer" + i + "@test.kg")
                    .passwordHash(passwordEncoder.encode("buyer123"))
                    .role(Role.BUYER)
                    .build());
        }

        return userRepository.saveAll(users);
    }

    private List<Category> createCategories() {
        List<Category> categories = new ArrayList<>();

        categories.add(Category.builder()
                .name("Одежда")
                .description("Мужская и женская одежда")
                .active(true)
                .build());

        categories.add(Category.builder()
                .name("Электроника")
                .description("Смартфоны, ноутбуки, аксессуары")
                .active(true)
                .build());

        categories.add(Category.builder()
                .name("Дом и интерьер")
                .description("Мебель, декор, текстиль")
                .active(true)
                .build());

        categories.add(Category.builder()
                .name("Обувь")
                .description("Мужская и женская обувь")
                .active(true)
                .build());

        categories.add(Category.builder()
                .name("Спорт и отдых")
                .description("Спортивная одежда и инвентарь")
                .active(true)
                .build());

        return categoryRepository.saveAll(categories);
    }

    private List<Merchant> createMerchants(List<AppUser> users) {
        List<Merchant> merchants = new ArrayList<>();

        // Get seller users
        AppUser seller1 = users.stream()
                .filter(u -> u.getEmail().equals("fashion.store@fusent.kg"))
                .findFirst().orElseThrow();

        AppUser seller2 = users.stream()
                .filter(u -> u.getEmail().equals("tech.shop@fusent.kg"))
                .findFirst().orElseThrow();

        AppUser seller3 = users.stream()
                .filter(u -> u.getEmail().equals("home.decor@fusent.kg"))
                .findFirst().orElseThrow();

        merchants.add(Merchant.builder()
                .ownerUserId(seller1.getId())
                .name("Fashion Store Merchant")
                .description("Модная одежда и аксессуары")
                .payoutStatus("active")
                .buyEligibility("online_purchase")
                .build());

        merchants.add(Merchant.builder()
                .ownerUserId(seller2.getId())
                .name("TechnoWorld Merchant")
                .description("Официальный дилер электроники")
                .payoutStatus("active")
                .buyEligibility("online_purchase")
                .build());

        merchants.add(Merchant.builder()
                .ownerUserId(seller3.getId())
                .name("Уютный Дом Merchant")
                .description("Товары для дома")
                .payoutStatus("active")
                .buyEligibility("online_purchase")
                .build());

        return merchantRepository.saveAll(merchants);
    }

    private List<Shop> createShops(List<Merchant> merchants) {
        List<Shop> shops = new ArrayList<>();

        Merchant merchant1 = merchants.get(0);
        Merchant merchant2 = merchants.get(1);
        Merchant merchant3 = merchants.get(2);

        shops.add(Shop.builder()
                .merchant(merchant1)
                .name("Fashion Store Bishkek")
                .phone("+996 555 123 456")
                .address("ТЦ Дордой, 2-этаж, бутик 245")
                .lat(new BigDecimal("42.8746"))
                .lon(new BigDecimal("74.5698"))
                .posStatus("active")
                .build());

        shops.add(Shop.builder()
                .merchant(merchant2)
                .name("TechnoWorld KG")
                .phone("+996 700 987 654")
                .address("пр. Чуй 156, ТЦ Vefa Center")
                .lat(new BigDecimal("42.8765"))
                .lon(new BigDecimal("74.6123"))
                .posStatus("active")
                .build());

        shops.add(Shop.builder()
                .merchant(merchant3)
                .name("Уютный Дом")
                .phone("+996 550 111 222")
                .address("ул. Токтогула 123")
                .lat(new BigDecimal("42.8700"))
                .lon(new BigDecimal("74.5900"))
                .posStatus("active")
                .build());

        return shopRepository.saveAll(shops);
    }

    private List<Product> createProducts(List<Shop> shops, List<Category> categories) {
        List<Product> products = new ArrayList<>();

        Shop fashionShop = shops.get(0);
        Shop techShop = shops.get(1);
        Shop homeShop = shops.get(2);

        Category clothing = categories.stream()
                .filter(c -> c.getName().equals("Одежда"))
                .findFirst().orElseThrow();

        Category electronics = categories.stream()
                .filter(c -> c.getName().equals("Электроника"))
                .findFirst().orElseThrow();

        Category home = categories.stream()
                .filter(c -> c.getName().equals("Дом и интерьер"))
                .findFirst().orElseThrow();

        // Fashion products
        products.add(Product.builder()
                .shop(fashionShop)
                .category(clothing)
                .name("Зимняя куртка North Face")
                .description("Теплая зимняя куртка, водонепроницаемая, подходит для суровых зим Кыргызстана")
                .imageUrl("https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400")
                .active(true)
                .build());

        products.add(Product.builder()
                .shop(fashionShop)
                .category(clothing)
                .name("Джинсы Levi's 501")
                .description("Классические джинсы Levi's, оригинал, прямой крой")
                .imageUrl("https://images.unsplash.com/photo-1542272604-787c3835535d?w=400")
                .active(true)
                .build());

        products.add(Product.builder()
                .shop(fashionShop)
                .category(clothing)
                .name("Платье вечернее")
                .description("Элегантное вечернее платье, идеально для торжественных мероприятий")
                .imageUrl("https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400")
                .active(true)
                .build());

        // Tech products
        products.add(Product.builder()
                .shop(techShop)
                .category(electronics)
                .name("iPhone 15 Pro")
                .description("Новейший iPhone с титановым корпусом, A17 Pro чип, невероятная камера")
                .imageUrl("https://images.unsplash.com/photo-1678685888221-cda773a3dcdb?w=400")
                .active(true)
                .build());

        products.add(Product.builder()
                .shop(techShop)
                .category(electronics)
                .name("Samsung Galaxy S24 Ultra")
                .description("Флагманский смартфон Samsung с S Pen, 200MP камера")
                .imageUrl("https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400")
                .active(true)
                .build());

        products.add(Product.builder()
                .shop(techShop)
                .category(electronics)
                .name("AirPods Pro 2")
                .description("Беспроводные наушники Apple с активным шумоподавлением")
                .imageUrl("https://images.unsplash.com/photo-1606841837239-c5a1a4a07af7?w=400")
                .active(true)
                .build());

        // Home products
        products.add(Product.builder()
                .shop(homeShop)
                .category(home)
                .name("Диван угловой")
                .description("Удобный угловой диван, раскладной, обивка из велюра")
                .imageUrl("https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400")
                .active(true)
                .build());

        products.add(Product.builder()
                .shop(homeShop)
                .category(home)
                .name("Набор посуды Luminarc")
                .description("Набор посуды на 6 персон, закаленное стекло, Франция")
                .imageUrl("https://images.unsplash.com/photo-1584990347449-39b4aa001b29?w=400")
                .active(true)
                .build());

        return productRepository.saveAll(products);
    }

    private List<ProductVariant> createVariants(List<Product> products) {
        List<ProductVariant> variants = new ArrayList<>();

        for (Product product : products) {
            if (product.getName().contains("куртка")) {
                // Jacket variants by size
                variants.add(createVariant(product, "NF-WJ-001-S", null, new BigDecimal("12500.00"), 5));
                variants.add(createVariant(product, "NF-WJ-001-M", null, new BigDecimal("12500.00"), 10));
                variants.add(createVariant(product, "NF-WJ-001-L", null, new BigDecimal("12500.00"), 8));
                variants.add(createVariant(product, "NF-WJ-001-XL", null, new BigDecimal("12500.00"), 3));

            } else if (product.getName().contains("Джинсы")) {
                variants.add(createVariant(product, "LEVI-501-30", "{\"size\":\"30\",\"color\":\"Синий\"}", new BigDecimal("5500.00"), 15));
                variants.add(createVariant(product, "LEVI-501-32", "{\"size\":\"32\",\"color\":\"Синий\"}", new BigDecimal("5500.00"), 12));
                variants.add(createVariant(product, "LEVI-501-34", "{\"size\":\"34\",\"color\":\"Черный\"}", new BigDecimal("5500.00"), 8));

            } else if (product.getName().contains("Платье")) {
                variants.add(createVariant(product, "DRESS-001-S", "{\"size\":\"S\",\"color\":\"Красное\"}", new BigDecimal("8900.00"), 5));
                variants.add(createVariant(product, "DRESS-001-M", "{\"size\":\"M\",\"color\":\"Черное\"}", new BigDecimal("8900.00"), 7));

            } else if (product.getName().contains("iPhone 15")) {
                variants.add(createVariant(product, "IPHONE15PRO-128-BLK", "{\"memory\":\"128GB\",\"color\":\"Black Titanium\"}", new BigDecimal("95000.00"), 3));
                variants.add(createVariant(product, "IPHONE15PRO-256-BLU", "{\"memory\":\"256GB\",\"color\":\"Blue Titanium\"}", new BigDecimal("105000.00"), 2));

            } else if (product.getName().contains("Samsung")) {
                variants.add(createVariant(product, "S24U-256-BLK", "{\"memory\":\"256GB\",\"color\":\"Phantom Black\"}", new BigDecimal("89000.00"), 5));
                variants.add(createVariant(product, "S24U-512-GRY", "{\"memory\":\"512GB\",\"color\":\"Titanium Gray\"}", new BigDecimal("99000.00"), 2));

            } else if (product.getName().contains("AirPods")) {
                variants.add(createVariant(product, "AIRPODSPRO2-WHT", null, new BigDecimal("28000.00"), 10));

            } else if (product.getName().contains("Диван")) {
                variants.add(createVariant(product, "SOFA-001-GRY", "{\"color\":\"Серый\",\"side\":\"Левый угол\"}", new BigDecimal("45000.00"), 2));
                variants.add(createVariant(product, "SOFA-001-BEI", "{\"color\":\"Бежевый\",\"side\":\"Правый угол\"}", new BigDecimal("45000.00"), 1));

            } else if (product.getName().contains("посуды")) {
                variants.add(createVariant(product, "LUM-SET-001", null, new BigDecimal("3500.00"), 20));
            }
        }

        return variantRepository.saveAll(variants);
    }

    private ProductVariant createVariant(Product product, String sku, String attributes, BigDecimal price, Integer stock) {
        return ProductVariant.builder()
                .product(product)
                .sku(sku)
                .attributesJson(attributes)
                .price(price)
                .stockQty(stock)
                .build();
    }

    private List<Post> createPosts(List<Shop> shops) {
        List<Post> posts = new ArrayList<>();

        for (Shop shop : shops) {
            // Create 2-3 posts per shop
            if (shop.getName().contains("Fashion")) {
                posts.add(createPost(shop,
                    "🔥 Новая коллекция зимних курток! Скидки до 30% до конца недели! ❄️",
                    PostType.PHOTO, PostVisibility.PUBLIC));

                posts.add(createPost(shop,
                    "Джинсы Levi's 501 - классика, которая никогда не выходит из моды. В наличии все размеры! 👖",
                    PostType.PHOTO, PostVisibility.PUBLIC));

            } else if (shop.getName().contains("Techno")) {
                posts.add(createPost(shop,
                    "📱 iPhone 15 Pro в наличии! Titanium корпус, невероятная камера, гарантия 1 год!",
                    PostType.PHOTO, PostVisibility.PUBLIC));

                posts.add(createPost(shop,
                    "🎧 AirPods Pro 2 со скидкой 15%! Активное шумоподавление для комфорта в городе.",
                    PostType.PHOTO, PostVisibility.PUBLIC));

            } else if (shop.getName().contains("Уютный")) {
                posts.add(createPost(shop,
                    "🛋️ Угловые диваны со скидкой! Создайте уют в вашем доме. Доставка бесплатно по Бишкеку!",
                    PostType.PHOTO, PostVisibility.PUBLIC));
            }
        }

        return postRepository.saveAll(posts);
    }

    private Post createPost(Shop shop, String text, PostType type, PostVisibility visibility) {
        return Post.builder()
                .ownerType(OwnerType.SHOP)
                .ownerId(shop.getId())
                .text(text)
                .postType(type)
                .visibility(visibility)
                .status(PostStatus.ACTIVE)
                .likesCount(0)
                .commentsCount(0)
                .sharesCount(0)
                .build();
    }

    private void createSocialInteractions(List<Post> posts, List<AppUser> users) {
        // Get buyer users
        List<AppUser> buyers = users.stream()
                .filter(u -> u.getRole() == Role.BUYER)
                .toList();

        if (buyers.isEmpty() || posts.isEmpty()) {
            return;
        }

        // Add likes to posts
        for (int i = 0; i < Math.min(posts.size(), 3); i++) {
            Post post = posts.get(i);

            // 2-3 likes per post
            for (int j = 0; j < Math.min(buyers.size(), 3); j++) {
                AppUser buyer = buyers.get(j);

                Like like = Like.builder()
                        .post(post)
                        .user(buyer)
                        .build();

                likeRepository.save(like);

                // Update post likes count
                post.setLikesCount(post.getLikesCount() + 1);
            }

            postRepository.save(post);
        }

        // Add comments to first post
        if (!posts.isEmpty() && !buyers.isEmpty()) {
            Post firstPost = posts.get(0);

            Comment comment1 = Comment.builder()
                    .post(firstPost)
                    .user(buyers.get(0))
                    .text("Отличные цены! Когда можно приехать посмотреть?")
                    .isFlagged(false)
                    .verifiedPurchase(false)
                    .build();

            commentRepository.save(comment1);

            if (buyers.size() > 1) {
                Comment comment2 = Comment.builder()
                        .post(firstPost)
                        .user(buyers.get(1))
                        .text("Очень понравилось качество! Рекомендую!")
                        .isFlagged(false)
                        .verifiedPurchase(true)
                        .build();

                commentRepository.save(comment2);
            }

            firstPost.setCommentsCount(firstPost.getCommentsCount() + 2);
            postRepository.save(firstPost);
        }
    }
}
