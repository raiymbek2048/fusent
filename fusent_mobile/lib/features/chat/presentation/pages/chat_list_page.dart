import 'package:flutter/material.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  // Mock data for shop chats
  final List<Map<String, dynamic>> _mockChats = const [
    {
      'shopName': 'Fashion Store',
      'lastMessage': 'Спасибо за заказ!',
      'time': '2 мин',
      'unreadCount': 1,
      'avatarUrl': 'https://via.placeholder.com/150',
    },
    {
      'shopName': 'Tech Paradise',
      'lastMessage': 'Товар уже в пути',
      'time': '1 ч',
      'unreadCount': 0,
      'avatarUrl': 'https://via.placeholder.com/150',
    },
    {
      'shopName': 'Анна Иванова',
      'lastMessage': 'Отлично!',
      'time': '3 ч',
      'unreadCount': 0,
      'avatarUrl': 'https://via.placeholder.com/150',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сообщения'),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Поиск чатов и магазинов...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                // TODO: Filter chats
              },
            ),
          ),

          // Chat list
          Expanded(
            child: ListView.separated(
              itemCount: _mockChats.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: AppColors.divider,
              ),
              itemBuilder: (context, index) {
                final chat = _mockChats[index];
                return _buildChatItem(
                  context,
                  shopName: chat['shopName'] as String,
                  lastMessage: chat['lastMessage'] as String,
                  time: chat['time'] as String,
                  unreadCount: chat['unreadCount'] as int,
                  avatarUrl: chat['avatarUrl'] as String,
                  isShop: index < 2, // First two are shops
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(
    BuildContext context, {
    required String shopName,
    required String lastMessage,
    required String time,
    required int unreadCount,
    required String avatarUrl,
    required bool isShop,
  }) {
    return InkWell(
      onTap: () {
        context.push(
          '/chat/${shopName.hashCode}?shopName=$shopName&isShop=$isShop',
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.surface,
              child: Icon(
                isShop ? Icons.store : Icons.person,
                color: AppColors.textSecondary,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),

            // Chat details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop name with badge and time
                  Row(
                    children: [
                      // Shop name
                      Text(
                        shopName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Shop badge
                      if (isShop)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Магазин',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      const Spacer(),

                      // Time
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Last message and unread count
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Unread count badge
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
