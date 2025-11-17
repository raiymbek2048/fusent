import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/feed/presentation/pages/feed_page.dart';
import '../../features/feed/presentation/pages/reels_page.dart';
import '../../features/catalog/presentation/pages/catalog_page.dart';
import '../../features/chat/presentation/pages/chat_list_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/product/presentation/pages/product_detail_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/seller/presentation/pages/seller_dashboard_page.dart';
import '../../features/seller/presentation/pages/add_product_page.dart';
import '../../features/seller/presentation/pages/edit_product_page.dart';
import '../../features/seller/presentation/pages/my_products_page.dart';
import '../../features/seller/presentation/pages/create_post_page.dart';
import '../../features/seller/presentation/pages/my_posts_page.dart';

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

      // Search
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchPage(),
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
    ],
  );
}
