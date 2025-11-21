import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:fusent_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:intl/intl.dart';

class SellerOrdersPage extends StatefulWidget {
  const SellerOrdersPage({super.key});

  @override
  State<SellerOrdersPage> createState() => _SellerOrdersPageState();
}

class _SellerOrdersPageState extends State<SellerOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiClient _apiClient = ApiClient();

  List<Map<String, dynamic>> _allOrders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() {
          _error = 'Не авторизован';
          _isLoading = false;
        });
        return;
      }

      final shopId = authState.user.shopId;
      print('DEBUG: User shopId = $shopId');
      print('DEBUG: User email = ${authState.user.email}');
      if (shopId == null || shopId.isEmpty) {
        setState(() {
          _error = 'У вас нет магазина (shopId: $shopId)';
          _isLoading = false;
        });
        return;
      }

      final response = await _apiClient.getShopOrders(shopId);
      print('DEBUG: Orders response = ${response.data}');
      final List<dynamic> ordersData = response.data as List<dynamic>;

      setState(() {
        _allOrders = ordersData.map((e) => e as Map<String, dynamic>).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading orders: $e');
      setState(() {
        _error = 'Ошибка загрузки заказов: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заказы'),
        backgroundColor: AppColors.background,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Новые'),
            Tab(text: 'В работе'),
            Tab(text: 'Готовые'),
            Tab(text: 'История'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList('new'),
          _buildOrdersList('processing'),
          _buildOrdersList('ready'),
          _buildOrdersList('history'),
        ],
      ),
    );
  }

  Widget _buildOrdersList(String status) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrders,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    final filteredOrders = _filterOrdersByStatus(status);

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(status),
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(filteredOrders[index]);
        },
      ),
    );
  }

  List<Map<String, dynamic>> _filterOrdersByStatus(String tabStatus) {
    return _allOrders.where((order) {
      final orderStatus = (order['status'] as String).toUpperCase();

      switch (tabStatus) {
        case 'new':
          return orderStatus == 'CREATED';
        case 'processing':
          return orderStatus == 'PAID';
        case 'ready':
          return orderStatus == 'FULFILLED';
        case 'history':
          return orderStatus == 'CANCELLED' || orderStatus == 'REFUNDED';
        default:
          return false;
      }
    }).toList();
  }

  String _getEmptyMessage(String status) {
    switch (status) {
      case 'new':
        return 'Нет новых заказов';
      case 'processing':
        return 'Нет заказов в работе';
      case 'ready':
        return 'Нет готовых заказов';
      case 'history':
        return 'История заказов пуста';
      default:
        return 'Нет заказов';
    }
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderId = order['id'] as String;
    final userId = order['userId'] as String;
    final status = order['status'] as String;
    final itemCount = order['itemCount'] as int;
    final totalAmount = (order['totalAmount'] as num).toDouble();
    final createdAtStr = order['createdAt'] as String?;
    final createdAt = createdAtStr != null ? DateTime.parse(createdAtStr) : DateTime.now();

    final timeAgo = _formatTimeAgo(createdAt);
    final statusLabel = _getStatusLabel(status);
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Заказ #${orderId.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'ID: ${userId.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                timeAgo,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            '$itemCount ${_pluralizeItems(itemCount)} на сумму ${totalAmount.toInt()} сом',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.push('/seller/orders/${order['id']}');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  child: const Text('Подробнее'),
                ),
              ),
              if (status.toUpperCase() == 'PENDING' || status.toUpperCase() == 'CREATED') ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _acceptOrder(orderId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Принять'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Только что';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${_pluralizeMinutes(difference.inMinutes)} назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${_pluralizeHours(difference.inHours)} назад';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${_pluralizeDays(difference.inDays)} назад';
    } else {
      return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
    }
  }

  String _pluralizeItems(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'товар';
    } else if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return 'товара';
    } else {
      return 'товаров';
    }
  }

  String _pluralizeMinutes(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'минуту';
    } else if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return 'минуты';
    } else {
      return 'минут';
    }
  }

  String _pluralizeHours(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'час';
    } else if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return 'часа';
    } else {
      return 'часов';
    }
  }

  String _pluralizeDays(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'день';
    } else if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return 'дня';
    } else {
      return 'дней';
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'CREATED':
        return 'Новый';
      case 'PAID':
        return 'Оплачен';
      case 'FULFILLED':
        return 'Выполнен';
      case 'CANCELLED':
        return 'Отменен';
      case 'REFUNDED':
        return 'Возврат';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CREATED':
        return AppColors.primary;
      case 'PAID':
        return AppColors.warning;
      case 'FULFILLED':
        return AppColors.success;
      case 'CANCELLED':
      case 'REFUNDED':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Future<void> _acceptOrder(String orderId) async {
    try {
      await _apiClient.updateOrderStatus(
        orderId: orderId,
        status: 'PAID',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Заказ принят')),
        );
        _loadOrders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Заказ #${(order['id'] as String).substring(0, 8)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Статус: ${_getStatusLabel(order['status'] as String)}'),
            const SizedBox(height: 8),
            Text('Товаров: ${order['itemCount']}'),
            const SizedBox(height: 8),
            Text('Сумма: ${(order['totalAmount'] as num).toInt()} сом'),
            const SizedBox(height: 8),
            Text('Дата: ${order['createdAt'] != null ? DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(order['createdAt'] as String)) : 'Не указана'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
