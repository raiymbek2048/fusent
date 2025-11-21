import 'package:flutter/material.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:intl/intl.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final ApiClient _apiClient = ApiClient();
  Map<String, dynamic>? _orderDetails;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiClient.getOrderDetails(widget.orderId);
      setState(() {
        _orderDetails = response.data as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки заказа: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Заказ #${widget.orderId.substring(0, 8)}'),
        backgroundColor: AppColors.background,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrderDetails,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (_orderDetails == null) {
      return const Center(child: Text('Заказ не найден'));
    }

    final status = _orderDetails!['status'] as String;
    final totalAmount = (_orderDetails!['totalAmount'] as num).toDouble();
    final items = _orderDetails!['items'] as List<dynamic>? ?? [];
    final createdAt = _orderDetails!['createdAt'] != null
        ? DateTime.parse(_orderDetails!['createdAt'] as String)
        : null;

    return RefreshIndicator(
      onRefresh: _loadOrderDetails,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(status, createdAt),
            const SizedBox(height: 16),
            _buildItemsSection(items),
            const SizedBox(height: 16),
            _buildTotalSection(totalAmount),
            const SizedBox(height: 16),
            _buildActionsSection(status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String status, DateTime? createdAt) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getStatusIcon(status),
              color: _getStatusColor(status),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusLabel(status),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(status),
                  ),
                ),
                if (createdAt != null)
                  Text(
                    DateFormat('dd.MM.yyyy HH:mm').format(createdAt),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(List<dynamic> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Товары (${items.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => _buildItemTile(item as Map<String, dynamic>)),
        ],
      ),
    );
  }

  Widget _buildItemTile(Map<String, dynamic> item) {
    final productName = item['productName'] as String? ?? 'Товар';
    final variantName = item['variantName'] as String? ?? '';
    final qty = item['qty'] as int? ?? 1;
    final price = (item['price'] as num?)?.toDouble() ?? 0;
    final subtotal = (item['subtotal'] as num?)?.toDouble() ?? (price * qty);
    final imageUrl = item['productImage'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: AppColors.border,
                      child: const Icon(Icons.image, color: AppColors.textSecondary),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: AppColors.border,
                    child: const Icon(Icons.image, color: AppColors.textSecondary),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (variantName.isNotEmpty)
                  Text(
                    variantName,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  '$qty × ${price.toInt()} сом',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${subtotal.toInt()} сом',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection(double totalAmount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Итого:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${totalAmount.toInt()} сом',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(String status) {
    final List<Widget> actions = [];

    if (status.toUpperCase() == 'CREATED') {
      actions.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _updateStatus('PAID'),
            icon: const Icon(Icons.check),
            label: const Text('Принять заказ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      );
      actions.add(const SizedBox(width: 12));
      actions.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _updateStatus('CANCELLED'),
            icon: const Icon(Icons.close, color: AppColors.error),
            label: const Text('Отклонить', style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      );
    } else if (status.toUpperCase() == 'PAID') {
      actions.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _updateStatus('FULFILLED'),
            icon: const Icon(Icons.done_all),
            label: const Text('Выполнен'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Row(children: actions);
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      await _apiClient.updateOrderStatus(
        orderId: widget.orderId,
        status: newStatus,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Статус обновлен: ${_getStatusLabel(newStatus)}')),
        );
        _loadOrderDetails();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'CREATED':
        return 'Новый';
      case 'PAID':
        return 'В работе';
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

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'CREATED':
        return Icons.fiber_new;
      case 'PAID':
        return Icons.schedule;
      case 'FULFILLED':
        return Icons.check_circle;
      case 'CANCELLED':
        return Icons.cancel;
      case 'REFUNDED':
        return Icons.undo;
      default:
        return Icons.help_outline;
    }
  }
}
