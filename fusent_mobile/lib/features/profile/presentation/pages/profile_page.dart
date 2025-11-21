import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/features/auth/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Extract user data from auth state
        final user = state is AuthAuthenticated ? state.user : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Профиль'),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/notifications'),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  // TODO: Open settings
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Profile Header
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.surface,
                            backgroundImage: user?.avatarUrl != null
                                ? NetworkImage(user!.avatarUrl!)
                                : null,
                            child: user?.avatarUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppColors.textSecondary,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.background,
                                  width: 2,
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  // TODO: Change profile photo
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.fullName ?? 'User',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${user?.username ?? 'username'}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (user?.bio != null) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            user!.bio!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Публикации', '${user?.postsCount ?? 0}'),
                      _buildStatItem('Подписчики', _formatCount(user?.followersCount ?? 0)),
                      _buildStatItem('Подписки', _formatCount(user?.followingCount ?? 0)),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.push('/edit-profile'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text('Редактировать'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO: Share profile
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: const Text('Поделиться'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(height: 1),

                // Menu Items
                // Seller Dashboard - Only show for SELLER, MERCHANT, or ADMIN
                if (user?.role == 'SELLER' || user?.role == 'MERCHANT' || user?.role == 'ADMIN') ...[
                  _buildMenuItem(
                    icon: Icons.store,
                    title: 'Панель продавца',
                    onTap: () {
                      context.push('/seller/dashboard');
                    },
                    iconColor: AppColors.primary,
                  ),
                  const Divider(height: 1),
                ],
            _buildMenuItem(
              icon: Icons.shopping_bag_outlined,
              title: 'Мои заказы',
              onTap: () => context.push('/orders'),
            ),
            _buildMenuItem(
              icon: Icons.favorite_border,
              title: 'Избранное',
              onTap: () => context.push('/favorites'),
            ),
            _buildMenuItem(
              icon: Icons.history,
              title: 'История просмотров',
              onTap: () => context.push('/view-history'),
            ),
            _buildMenuItem(
              icon: Icons.payment_outlined,
              title: 'Способы оплаты',
              onTap: () => context.push('/payment-methods'),
            ),
            _buildMenuItem(
              icon: Icons.location_on_outlined,
              title: 'Адреса доставки',
              onTap: () => context.push('/delivery-addresses'),
            ),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Помощь',
              onTap: () => context.push('/help'),
            ),
            _buildMenuItem(
              icon: Icons.logout,
              title: 'Выход',
              onTap: () {
                _showLogoutDialog(context);
              },
              isDestructive: true,
            ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? (isDestructive ? AppColors.error : AppColors.textPrimary),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
          fontWeight: iconColor != null ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              // Get AuthBloc from context and trigger logout
              context.read<AuthBloc>().add(LogoutRequested());

              // Wait a bit for logout to complete
              await Future.delayed(const Duration(milliseconds: 100));

              // Navigate to login
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: Text(
              'Выйти',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
