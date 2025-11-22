import 'package:flutter/material.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/features/feed/presentation/pages/tiktok_feed_page.dart';
import 'package:fusent_mobile/features/catalog/presentation/pages/catalog_page.dart';
import 'package:fusent_mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:fusent_mobile/features/chat/presentation/pages/chat_list_page.dart';
import 'package:fusent_mobile/features/cart/presentation/pages/cart_page.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:fusent_mobile/core/di/injection_container.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  int _unreadChatsCount = 0;
  int _cartItemsCount = 0;

  final List<Widget> _screens = [
    const TikTokFeedPage(),
    const CatalogPage(),
    const ChatListPage(),
    const CartPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadBadgeCounts();
  }

  Future<void> _loadBadgeCounts() async {
    try {
      final apiClient = sl<ApiClient>();

      // Load unread chats count
      final chatsResponse = await apiClient.getConversations();
      if (chatsResponse.statusCode == 200 && chatsResponse.data != null) {
        final List<dynamic> chats = chatsResponse.data is List
            ? chatsResponse.data
            : (chatsResponse.data['content'] ?? []);

        final unreadCount = chats.where((chat) {
          return chat['unreadCount'] != null && chat['unreadCount'] > 0;
        }).length;

        setState(() {
          _unreadChatsCount = unreadCount;
        });
      }

      // Load cart items count
      final cartResponse = await apiClient.getCart();
      if (cartResponse.statusCode == 200 && cartResponse.data != null) {
        final items = cartResponse.data['items'] as List?;
        if (items != null) {
          final totalItems = items.fold<int>(0, (sum, item) {
            return sum + (item['quantity'] as int? ?? 0);
          });

          setState(() {
            _cartItemsCount = totalItems;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading badge counts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Лента',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: 'Каталог',
            ),
            BottomNavigationBarItem(
              icon: _unreadChatsCount > 0
                  ? Badge(
                      label: Text('$_unreadChatsCount'),
                      child: const Icon(Icons.chat_bubble_outline),
                    )
                  : const Icon(Icons.chat_bubble_outline),
              activeIcon: _unreadChatsCount > 0
                  ? Badge(
                      label: Text('$_unreadChatsCount'),
                      child: const Icon(Icons.chat_bubble),
                    )
                  : const Icon(Icons.chat_bubble),
              label: 'Чат',
            ),
            BottomNavigationBarItem(
              icon: _cartItemsCount > 0
                  ? Badge(
                      label: Text('$_cartItemsCount'),
                      child: const Icon(Icons.shopping_cart_outlined),
                    )
                  : const Icon(Icons.shopping_cart_outlined),
              activeIcon: _cartItemsCount > 0
                  ? Badge(
                      label: Text('$_cartItemsCount'),
                      child: const Icon(Icons.shopping_cart),
                    )
                  : const Icon(Icons.shopping_cart),
              label: 'Корзина',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}

