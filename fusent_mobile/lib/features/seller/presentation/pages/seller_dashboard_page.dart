import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fusent_mobile/core/di/injection_container.dart';
import 'package:fusent_mobile/core/network/api_client.dart';

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiClient _apiClient = sl<ApiClient>();

  // Stats data
  int _ordersToday = 0;
  double _revenueToday = 0;
  int _viewsToday = 0;
  int _followersCount = 0;
  double _ordersGrowth = 0;
  double _revenueGrowth = 0;
  double _viewsGrowth = 0;
  double _followersGrowth = 0;

  List<Map<String, dynamic>> _recentOrders = [];
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      // Load products from seller catalog
      final productsResponse =
          await _apiClient.get('/api/v1/seller/catalog/products');
      if (productsResponse.statusCode == 200 && productsResponse.data != null) {
        final data = productsResponse.data;
        List<dynamic> productsList = [];
        if (data is List) {
          productsList = data;
        } else if (data is Map && data['content'] is List) {
          productsList = data['content'];
        }
        setState(() {
          _products = productsList.cast<Map<String, dynamic>>();
        });
      }

      // Load my posts
      final postsResponse =
          await _apiClient.get('/api/v1/social/posts/my-posts');
      if (postsResponse.statusCode == 200 && postsResponse.data != null) {
        final data = postsResponse.data;
        List<dynamic> postsList = [];
        if (data is List) {
          postsList = data;
        } else if (data is Map && data['content'] is List) {
          postsList = data['content'];
        }
        setState(() {
          _posts = postsList.cast<Map<String, dynamic>>();
        });
      }

      // Set mock stats for now (TODO: create stats endpoint)
      setState(() {
        _ordersToday = 0;
        _revenueToday = 0;
        _viewsToday = 0;
        _followersCount = 0;
      });
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Панель продавца',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Tech Paradise',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') _showLogoutDialog(context);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Выйти', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Обзор'),
            Tab(text: 'Товары'),
            Tab(text: 'Заказы'),
            Tab(text: 'Аналитика'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildProductsTab(),
          _buildOrdersTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.shopping_cart,
                    value: _ordersToday.toString(),
                    label: 'Заказы сегодня',
                    growth: _ordersGrowth,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.attach_money,
                    value: '₸ ${_formatNumber(_revenueToday)}',
                    label: 'Выручка',
                    growth: _revenueGrowth,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.visibility,
                    value: _formatNumber(_viewsToday.toDouble()),
                    label: 'Просмотры',
                    growth: _viewsGrowth,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.favorite,
                    value: _followersCount.toString(),
                    label: 'Подписчики',
                    growth: _followersGrowth,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Быстрые действия',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.add,
                    label: 'Добавить товар',
                    isPrimary: true,
                    onTap: () => context.push('/seller/add-product'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.post_add,
                    label: 'Новая публикация',
                    isPrimary: false,
                    onTap: () => context.push('/seller/create-post'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Orders
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Последние заказы',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.push('/seller/orders'),
                  child: const Text('Все →'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_recentOrders.isEmpty)
              _buildEmptyState('Пока нет заказов', Icons.shopping_bag_outlined)
            else
              ..._recentOrders.map((order) => _OrderCard(order: order)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: _products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text('Нет товаров',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/seller/add-product'),
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить товар'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _products.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/seller/add-product'),
                      icon: const Icon(Icons.add),
                      label: const Text('Добавить товар'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  );
                }
                final product = _products[index - 1];
                return _ProductCard(product: product);
              },
            ),
    );
  }

  Widget _buildOrdersTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: _recentOrders.isEmpty
          ? _buildEmptyState('Нет заказов', Icons.shopping_bag_outlined)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _recentOrders.length,
              itemBuilder: (context, index) {
                return _OrderCard(order: _recentOrders[index]);
              },
            ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Статистика за 7 дней',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: 8),
                  Text('График продаж',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _AnalyticsSummaryCard(
            title: 'Всего продаж',
            value: '${_ordersToday * 7}',
            subtitle: 'за последние 7 дней',
          ),
          const SizedBox(height: 12),
          _AnalyticsSummaryCard(
            title: 'Общая выручка',
            value: '₸ ${_formatNumber(_revenueToday * 7)}',
            subtitle: 'за последние 7 дней',
          ),
          const SizedBox(height: 12),
          _AnalyticsSummaryCard(
            title: 'Средний чек',
            value: _ordersToday > 0
                ? '₸ ${_formatNumber(_revenueToday / _ordersToday)}'
                : '₸ 0',
            subtitle: 'средняя сумма заказа',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)} ${number.toInt() % 1000}';
    }
    return number.toStringAsFixed(0);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutRequested());
              context.go('/login');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final double growth;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.growth,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = growth >= 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 20),
              Text(
                '${isPositive ? '+' : ''}${growth.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: isPositive ? AppColors.success : AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isPrimary ? Colors.white : AppColors.textPrimary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final orderId = order['id']?.toString() ?? '';
    final status = order['status']?.toString() ?? 'NEW';
    final customerName = order['customerName']?.toString() ?? 'Покупатель';
    final itemsCount = order['itemsCount'] ?? 1;
    final total = order['total'] ?? 0;

    Color statusColor;
    String statusText;
    switch (status.toUpperCase()) {
      case 'NEW':
        statusColor = AppColors.warning;
        statusText = 'Новый';
        break;
      case 'CONFIRMED':
        statusColor = AppColors.info;
        statusText = 'Подтвержден';
        break;
      case 'READY':
        statusColor = AppColors.success;
        statusText = 'Готов';
        break;
      case 'DELIVERED':
        statusColor = AppColors.success;
        statusText = 'Доставлен';
        break;
      case 'CANCELLED':
        statusColor = AppColors.error;
        statusText = 'Отменен';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '#${orderId.length > 4 ? orderId.substring(0, 4) : orderId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$customerName • $itemsCount товара • $total сом',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/seller/order/$orderId'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Открыть'),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final name = product['name']?.toString() ?? 'Товар';
    final price = product['basePrice'] ?? 0;
    final stock = product['stock'] ?? 0;
    final imageUrl = product['imageUrl']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  )
                : Icon(Icons.image, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('$price сом • В наличии: $stock',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                context.push('/seller/edit-product/${product['id']}'),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _AnalyticsSummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
