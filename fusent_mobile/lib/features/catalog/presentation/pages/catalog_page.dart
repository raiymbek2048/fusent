import 'package:flutter/material.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:fusent_mobile/core/di/injection_container.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:fusent_mobile/features/catalog/presentation/widgets/filter_bottom_sheet.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String? _selectedCategory;
  final List<String> _categories = [
    'Все',
    'Одежда',
    'Электроника',
    'Спорт',
    'Красота',
  ];

  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiClient = sl<ApiClient>();
      final response = await apiClient.getProducts();

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        // Determine where the list of products is:
        List<dynamic> productsData = [];
        if (data is List) {
          productsData = data;
        } else if (data is Map) {
          // common wrappers
          if (data['content'] is List) {
            productsData = data['content'] as List<dynamic>;
          } else if (data['data'] is List) {
            productsData = data['data'] as List<dynamic>;
          } else if (data['items'] is List) {
            productsData = data['items'] as List<dynamic>;
          } else if (data['products'] is List) {
            productsData = data['products'] as List<dynamic>;
          } else {
            // Server returned a single product as Map (or an unexpected structure).
            // If it's a single product, wrap it into a list so UI can handle it.
            if (_looksLikeProductMap(data)) {
              productsData = [data];
            } else {
              productsData = [];
            }
          }
        } else {
          productsData = [];
        }

        setState(() {
          _products = productsData.map<Map<String, dynamic>>((product) {
            if (product is! Map) product = <String, dynamic>{};

            // Safely parse id/name/basePrice/imageUrl
            final id = product['id']?.toString() ?? '';
            final name = product['name']?.toString() ?? 'Без названия';
            final price = _toDouble(product['basePrice']);
            String? imageUrl;
            if (product.containsKey('imageUrl')) {
              imageUrl = product['imageUrl']?.toString();
            } else if (product.containsKey('image')) {
              imageUrl = product['image']?.toString();
            }

            // Determine stock from variants safely
            int stock = 0;
            final variants = product['variants'];
            if (variants is List && variants.isNotEmpty) {
              final first = variants.first;
              if (first is Map) {
                stock = _toInt(first['stockQty'] ?? first['stock']);
              } else {
                // variant is primitive — ignore
                stock = 0;
              }
            } else if (product.containsKey('stock')) {
              stock = _toInt(product['stock']);
            }

            // rating may be in product['rating'] or absent
            final rating = _toDouble(product['rating']);

            // Get shop name if available
            String shopName = 'Магазин';
            if (product.containsKey('shop')) {
              final shop = product['shop'];
              if (shop is Map && shop.containsKey('name')) {
                shopName = shop['name']?.toString() ?? 'Магазин';
              }
            }

            // Calculate discount percentage if there's an old price
            int? discountPercent;
            double? oldPrice;
            if (product.containsKey('oldPrice')) {
              oldPrice = _toDouble(product['oldPrice']);
              if (oldPrice > price && price > 0) {
                discountPercent = (((oldPrice - price) / oldPrice) * 100).round();
              }
            }

            return {
              'id': id,
              'name': name,
              'price': price,
              'oldPrice': oldPrice,
              'discountPercent': discountPercent,
              'stock': stock,
              'imageUrl': imageUrl,
              'rating': rating,
              'shopName': shopName,
            };
          }).toList();

          _isLoading = false;
        });
      } else {
        // non-200 or empty body
        setState(() {
          _isLoading = false;
          _errorMessage = 'Не удалось загрузить данные (код ${response.statusCode})';
        });
      }
    } on DioException catch (e) {
      String errorMessage = 'Ошибка при загрузке товаров';

      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'];
        } else if (data is String) {
          errorMessage = data;
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }

      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Неизвестная ошибка: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

// Helpers:

  bool _looksLikeProductMap(Map data) {
    // crude heuristic: contains id or name or basePrice
    return data.containsKey('id') || data.containsKey('name') || data.containsKey('basePrice');
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? (double.tryParse(v)?.toInt() ?? 0);
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.push('/search');
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const FilterBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // "Показать на карте" button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                context.push('/shops-map');
              },
              icon: const Icon(Icons.map),
              label: const Text('Показать на карте'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Category chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category ||
                    (_selectedCategory == null && category == 'Все');
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                      _loadProducts();
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Products grid
          Expanded(
            child: _buildProductsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadProducts,
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Товары не найдены',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return _buildProductCard(
            productId: product['id'],
            name: product['name'],
            price: product['price'],
            oldPrice: product['oldPrice'],
            discountPercent: product['discountPercent'],
            imageUrl: product['imageUrl'] ?? '',
            rating: product['rating'] ?? 0.0,
            shopName: product['shopName'] ?? 'Магазин',
          );
        },
      ),
    );
  }

  void _showMapModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'Карта магазинов',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Map placeholder (will be replaced with GoogleMap)
                  Expanded(
                    child: Container(
                      color: AppColors.surface,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Карта будет здесь',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductCard({
    required String productId,
    required String name,
    required double price,
    required double? oldPrice,
    required int? discountPercent,
    required String imageUrl,
    required double rating,
    required String shopName,
  }) {
    return GestureDetector(
      onTap: () {
        context.push('/product/$productId');
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with discount badge
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      color: AppColors.background,
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Discount badge
                  if (discountPercent != null && discountPercent > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-$discountPercent%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product name
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating and shop name
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),

                        // Shop name
                        Text(
                          shopName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Price (with old price if available)
                        Row(
                          children: [
                            if (oldPrice != null && oldPrice > 0) ...[
                              Text(
                                '${oldPrice.round()} сом',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              '${price.round()} сом',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
