import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/core/network/api_client.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final ApiClient _apiClient = ApiClient();
  List<CartItem> _cartItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiClient.getCart();

      if (mounted && response.statusCode == 200) {
        final Map<String, dynamic> cartData = response.data as Map<String, dynamic>;
        final List<dynamic> items = cartData['items'] as List<dynamic>? ?? [];

        setState(() {
          _cartItems = items.map((item) {
            final itemMap = item as Map<String, dynamic>;
            final product = itemMap['product'] as Map<String, dynamic>?;
            final shop = product?['shop'] as Map<String, dynamic>?;
            final variants = product?['variants'] as List<dynamic>?;
            final firstVariant = variants?.isNotEmpty == true ? variants!.first as Map<String, dynamic> : null;

            return CartItem(
              id: itemMap['id'] ?? product?['id'] ?? '',
              productId: product?['id'] ?? '',
              name: product?['name'] ?? 'Товар',
              shopName: shop?['name'] ?? 'Магазин',
              price: (firstVariant?['price'] ?? product?['currentPrice'] ?? 0).toDouble().toInt(),
              quantity: itemMap['quantity'] ?? 1,
              imageUrl: (product?['images'] as List<dynamic>?)?.isNotEmpty == true
                  ? (product!['images'] as List<dynamic>).first as String
                  : '',
              isAvailable: product?['isActive'] ?? true,
              errorMessage: (product?['isActive'] == false) ? 'Товар недоступен' : null,
            );
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось загрузить корзину: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeItem(String productId, int index) async {
    try {
      final response = await _apiClient.removeFromCart(productId: productId);

      if (mounted && response.statusCode == 200) {
        setState(() {
          _cartItems.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Товар удален из корзины'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error removing item: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось удалить товар: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _updateQuantity(String productId, int newQuantity, int index) async {
    // Optimistic update
    final oldQuantity = _cartItems[index].quantity;
    setState(() {
      _cartItems[index].quantity = newQuantity;
    });

    try {
      final response = await _apiClient.updateCartItem(
        productId: productId,
        quantity: newQuantity,
      );

      if (response.statusCode != 200) {
        // Revert on error
        if (mounted) {
          setState(() {
            _cartItems[index].quantity = oldQuantity;
          });
        }
      }
    } catch (e) {
      debugPrint('Error updating quantity: $e');
      // Revert on error
      if (mounted) {
        setState(() {
          _cartItems[index].quantity = oldQuantity;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось обновить количество: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  double get _totalPrice {
    return _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get _deliveryFee {
    return _totalPrice >= 100 ? 0 : 100;
  }

  double get _grandTotal {
    return _totalPrice + _deliveryFee;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
        actions: [
          if (_cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                _showClearCartDialog();
              },
            ),
        ],
      ),
      body: _isLoading && _cartItems.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _cartItems.isEmpty
              ? _buildEmptyCart()
              : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cartItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildCartItem(_cartItems[index], index);
                    },
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Корзина пуста',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Добавьте товары из каталога',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to catalog page
              context.go('/catalog');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(200, 48),
            ),
            child: const Text(
              'Перейти в каталог',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: !item.isAvailable
            ? Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.imageUrl.isNotEmpty
                  ? Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: AppColors.textSecondary,
                        );
                      },
                    )
                  : const Icon(
                      Icons.image_outlined,
                      size: 40,
                      color: AppColors.textSecondary,
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with name and delete button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.store,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.shopName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: AppColors.error,
                      onPressed: () => _removeItem(item.productId, index),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Error message if not available
                if (!item.isAvailable && item.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.errorMessage!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Quantity and Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity Controls
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: item.isAvailable && item.quantity > 1
                                ? () => _updateQuantity(item.productId, item.quantity - 1, index)
                                : null,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                            color: AppColors.textPrimary,
                          ),
                          Container(
                            width: 32,
                            alignment: Alignment.center,
                            child: Text(
                              '${item.quantity}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: item.isAvailable
                                ? () => _updateQuantity(item.productId, item.quantity + 1, index)
                                : null,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                            color: AppColors.textPrimary,
                          ),
                        ],
                      ),
                    ),

                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${item.price * item.quantity} сом',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (item.quantity > 1)
                          Text(
                            '${item.price} сом × ${item.quantity}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final hasUnavailableItems = _cartItems.any((item) => !item.isAvailable);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Товары
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Товары (${_cartItems.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${_totalPrice.toStringAsFixed(0)} сом',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Доставка
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _deliveryFee == 0 ? Icons.local_shipping : Icons.delivery_dining,
                      size: 16,
                      color: _deliveryFee == 0 ? AppColors.success : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Доставка',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  _deliveryFee == 0 ? 'Бесплатно' : '${_deliveryFee.toStringAsFixed(0)} сом',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _deliveryFee == 0 ? AppColors.success : AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            if (_deliveryFee > 0 && _totalPrice < 100) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Добавьте товаров на ${(100 - _totalPrice).toStringAsFixed(0)} сом для бесплатной доставки',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Divider
            Container(
              height: 1,
              color: AppColors.divider,
            ),
            const SizedBox(height: 16),

            // Итого
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Итого',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${_grandTotal.toStringAsFixed(0)} сом',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Оформить заказ button
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: hasUnavailableItems
                    ? null
                    : () {
                        context.push(
                          '/checkout?totalAmount=$_grandTotal&itemCount=${_cartItems.length}',
                        );
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: AppColors.textSecondary.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: Icon(
                  hasUnavailableItems ? Icons.error_outline : Icons.shopping_cart_checkout,
                  size: 22,
                ),
                label: Text(
                  hasUnavailableItems ? 'Удалите недоступные товары' : 'Оформить заказ',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Очистить корзину?'),
          content: const Text('Все товары будут удалены из корзины'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _cartItems.clear();
                });
                Navigator.pop(context);
              },
              child: const Text(
                'Очистить',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CartItem {
  final String id;
  final String productId;
  final String name;
  final String shopName;
  final int price;
  int quantity;
  final String imageUrl;
  final bool isAvailable;
  final String? errorMessage;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.shopName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    this.isAvailable = true,
    this.errorMessage,
  });
}
