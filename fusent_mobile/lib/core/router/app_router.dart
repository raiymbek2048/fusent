import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/feed/presentation/pages/feed_page.dart';
import '../../features/feed/presentation/pages/reels_page.dart';
import '../../features/catalog/presentation/pages/catalog_page.dart';
import '../../features/chat/presentation/pages/chat_list_page.dart';
import '../../features/chat/presentation/pages/chat_conversation_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/cart/presentation/pages/checkout_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/product/presentation/pages/product_detail_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/seller/presentation/pages/seller_dashboard_page.dart';
import '../../features/seller/presentation/pages/add_product_page.dart';
import '../../features/seller/presentation/pages/edit_product_page.dart';
import '../../features/seller/presentation/pages/my_products_page.dart';
import '../../features/seller/presentation/pages/create_post_page.dart';
import '../../features/seller/presentation/pages/my_posts_page.dart';
import '../../features/seller/presentation/pages/shops_management_page.dart';
import '../../features/seller/presentation/pages/employees_management_page.dart';
import '../../features/seller/presentation/pages/seller_orders_page.dart';
import '../../features/seller/presentation/pages/order_details_page.dart';
import '../../features/map/presentation/pages/shops_map_page.dart';
import '../../features/shop/presentation/pages/shop_profile_page.dart';
import '../../features/profile/presentation/pages/order_history_page.dart';
import '../../features/profile/presentation/pages/favorites_page.dart';
import '../../features/profile/presentation/pages/view_history_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/delivery_addresses_page.dart';
import '../../features/profile/presentation/pages/payment_methods_page.dart';
import '../../features/profile/presentation/pages/help_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Main App Routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'feed',
            name: 'feed',
            builder: (context, state) => const FeedPage(),
          ),
          GoRoute(
            path: 'catalog',
            name: 'catalog',
            builder: (context, state) => const CatalogPage(),
          ),
          GoRoute(
            path: 'chats',
            name: 'chats',
            builder: (context, state) => const ChatListPage(),
          ),
          GoRoute(
            path: 'cart',
            name: 'cart',
            builder: (context, state) => const CartPage(),
          ),
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),

      // Reels Page
      GoRoute(
        path: '/reels',
        name: 'reels',
        builder: (context, state) {
          final postId = state.uri.queryParameters['postId'];
          final tab = state.uri.queryParameters['tab'] ?? 'trending';
          return ReelsPage(initialPostId: postId, initialTab: tab);
        },
      ),

      // Product Detail
      GoRoute(
        path: '/product/:id',
        name: 'product',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return ProductDetailPage(productId: productId);
        },
      ),

      // Shop Profile
      GoRoute(
        path: '/shop/:shopId',
        name: 'shop-profile',
        builder: (context, state) {
          final shopId = state.pathParameters['shopId']!;
          final shopName = state.uri.queryParameters['shopName'];
          return ShopProfilePage(
            shopId: shopId,
            shopName: shopName,
          );
        },
      ),

      // Search
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchPage(),
      ),

      // Chat Conversation
      GoRoute(
        path: '/chat/:id',
        name: 'chat-conversation',
        builder: (context, state) {
          final chatId = state.pathParameters['id']!;
          final shopName = state.uri.queryParameters['shopName'] ?? 'Chat';
          final recipientId = state.uri.queryParameters['recipientId'];
          return ChatConversationPage(
            chatId: chatId,
            shopName: shopName,
            recipientId: recipientId,
          );
        },
      ),

      // Checkout
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) {
          final totalAmount = double.tryParse(
                state.uri.queryParameters['totalAmount'] ?? '0') ??
              0.0;
          final itemCount =
              int.tryParse(state.uri.queryParameters['itemCount'] ?? '0') ?? 0;
          return CheckoutPage(
            totalAmount: totalAmount,
            itemCount: itemCount,
          );
        },
      ),

      // Seller Routes
      GoRoute(
        path: '/seller/dashboard',
        name: 'seller-dashboard',
        builder: (context, state) => const SellerDashboardPage(),
      ),
      GoRoute(
        path: '/seller/add-product',
        name: 'add-product',
        builder: (context, state) => const AddProductPage(),
      ),
      GoRoute(
        path: '/seller/edit-product/:id',
        name: 'edit-product',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return EditProductPage(productId: productId);
        },
      ),
      GoRoute(
        path: '/seller/products',
        name: 'my-products',
        builder: (context, state) => const MyProductsPage(),
      ),
      GoRoute(
        path: '/seller/create-post',
        name: 'create-post',
        builder: (context, state) => const CreatePostPage(),
      ),
      GoRoute(
        path: '/seller/my-posts',
        name: 'my-posts',
        builder: (context, state) => const MyPostsPage(),
      ),
      GoRoute(
        path: '/seller/shops',
        name: 'seller-shops',
        builder: (context, state) => const ShopsManagementPage(),
      ),
      GoRoute(
        path: '/seller/employees',
        name: 'seller-employees',
        builder: (context, state) => const EmployeesManagementPage(),
      ),
      GoRoute(
        path: '/seller/orders',
        name: 'seller-orders',
        builder: (context, state) => const SellerOrdersPage(),
      ),
      GoRoute(
        path: '/seller/orders/:orderId',
        name: 'order-details',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderDetailsPage(orderId: orderId);
        },
      ),

      // Order History
      GoRoute(
        path: '/orders',
        name: 'order-history',
        builder: (context, state) => const OrderHistoryPage(),
      ),

      // Favorites
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const FavoritesPage(),
      ),

      // View History
      GoRoute(
        path: '/view-history',
        name: 'view-history',
        builder: (context, state) => const ViewHistoryPage(),
      ),

      // Edit Profile
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),

      // Notifications
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),

      // Delivery Addresses
      GoRoute(
        path: '/delivery-addresses',
        name: 'delivery-addresses',
        builder: (context, state) => const DeliveryAddressesPage(),
      ),

      // Payment Methods
      GoRoute(
        path: '/payment-methods',
        name: 'payment-methods',
        builder: (context, state) => const PaymentMethodsPage(),
      ),

      // Help
      GoRoute(
        path: '/help',
        name: 'help',
        builder: (context, state) => const HelpPage(),
      ),

      // Shops Map
      GoRoute(
        path: '/shops-map',
        name: 'shops-map',
        builder: (context, state) => const ShopsMapPage(),
      ),
    ],
  );
}
