import 'package:flutter/material.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/features/feed/presentation/pages/tiktok_feed_page.dart';
import 'package:fusent_mobile/features/catalog/presentation/pages/catalog_page.dart';
import 'package:fusent_mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:fusent_mobile/features/chat/presentation/pages/chat_list_page.dart';
import 'package:fusent_mobile/features/cart/presentation/pages/cart_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TikTokFeedPage(),
    const CatalogPage(),
    const ChatListPage(),
    const CartPage(),
    const ProfilePage(),
  ];

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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Лента',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: 'Каталог',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                label: Text('2'),
                child: Icon(Icons.chat_bubble_outline),
              ),
              activeIcon: Badge(
                label: Text('2'),
                child: Icon(Icons.chat_bubble),
              ),
              label: 'Чат',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                label: Text('3'),
                child: Icon(Icons.shopping_cart_outlined),
              ),
              activeIcon: Badge(
                label: Text('3'),
                child: Icon(Icons.shopping_cart),
              ),
              label: 'Корзина',
            ),
            BottomNavigationBarItem(
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

