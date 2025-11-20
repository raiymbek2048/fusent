import 'package:flutter/material.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:fusent_mobile/features/catalog/data/models/product_model.dart';
import 'package:fusent_mobile/features/catalog/data/models/product_variant_model.dart';
import 'package:fusent_mobile/features/reviews/presentation/pages/reviews_page.dart';
import 'package:fusent_mobile/features/feed/presentation/widgets/share_bottom_sheet.dart';
import 'package:go_router/go_router.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final ApiClient _apiClient = ApiClient();

  ProductModel? _product;
  bool _isLoading = true;
  String? _error;

  int _currentImageIndex = 0;
  bool _isFavorite = false;
  ProductVariantModel? _selectedVariant;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _apiClient.getProductDetail(widget.productId);

      if (response.statusCode == 200 && response.data != null) {
        final product = ProductModel.fromJson(response.data);

        setState(() {
          _product = product;
          // Select first variant by default if available
          if (product.variants.isNotEmpty) {
            _selectedVariant = product.variants.first;
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Не удалось загрузить товар';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Ошибка: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Загрузка...')),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_error != null || _product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ошибка')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(_error ?? 'Товар не найден'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProduct,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    final product = _product!;
    final images = product.getAllImageUrls();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image Gallery AppBar
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: images.isNotEmpty
                  ? Stack(
                      children: [
                        PageView.builder(
                          itemCount: images.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.surface,
                                  child: const Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 100,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        // Image Indicators
                        if (images.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(images.length, (index) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: _currentImageIndex == index ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _currentImageIndex == index
                                        ? AppColors.primary
                                        : Colors.white.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              }),
                            ),
                          ),
                      ],
                    )
                  : Container(
                      color: AppColors.surface,
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          size: 100,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ShareBottomSheet(
                      productId: widget.productId,
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
              ),
            ],
          ),

          // Product Details
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price
                      Text(
                        '${_selectedVariant?.price.toStringAsFixed(0) ?? product.basePrice.toStringAsFixed(0)} сом',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Product Name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Stock Status
                      Row(
                        children: [
                          Icon(
                            (_selectedVariant?.inStock ?? product.stock > 0)
                                ? Icons.check_circle
                                : Icons.cancel,
                            size: 16,
                            color: (_selectedVariant?.inStock ?? product.stock > 0)
                                ? Colors.green
                                : AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (_selectedVariant?.inStock ?? product.stock > 0)
                                ? 'В наличии (${_selectedVariant?.stockQuantity ?? product.stock} шт.)'
                                : 'Нет в наличии',
                            style: TextStyle(
                              color: (_selectedVariant?.inStock ?? product.stock > 0)
                                  ? Colors.green
                                  : AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Rating and Reviews
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewsPage(
                                productId: widget.productId,
                                productName: product.name,
                                apiClient: _apiClient,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Row(
                              children: List.generate(5, (index) {
                                return const Icon(
                                  Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                );
                              }),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Посмотреть отзывы',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Variants Selection
                      if (product.variants.isNotEmpty) ...[
                        const Text(
                          'Варианты',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: product.variants.map((variant) {
                            final isSelected = _selectedVariant?.id == variant.id;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedVariant = variant;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : AppColors.surface,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      variant.displayName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        color: isSelected ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                    if (!variant.inStock) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Нет в наличии',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isSelected ? Colors.white70 : AppColors.error,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                      ],

                      // Description
                      if (product.description != null && product.description!.isNotEmpty) ...[
                        const Text(
                          'Описание',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product.description!,
                          style: const TextStyle(
                            height: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                      ],

                      // Reviews Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Отзывы',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReviewsPage(
                                    productId: widget.productId,
                                    productName: product.name,
                                    apiClient: _apiClient,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Все отзывы →'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Variant selection warning
              if (product.variants.isNotEmpty && _selectedVariant == null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.error,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Выберите вариант товара',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: (product.variants.isEmpty || _selectedVariant != null) &&
                              (_selectedVariant?.inStock ?? product.stock > 0)
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Добавлено в корзину: ${product.name}${_selectedVariant != null ? ' (${_selectedVariant!.displayName})' : ''}',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          : null,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text('В корзину'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: (product.variants.isEmpty || _selectedVariant != null) &&
                              (_selectedVariant?.inStock ?? product.stock > 0)
                          ? () {
                              // Navigate to checkout page
                              final variantId = _selectedVariant?.id ?? '';
                              context.push('/checkout?productId=${product.id}&variantId=$variantId&quantity=1');
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                      ),
                      icon: const Icon(Icons.shopping_bag),
                      label: const Text('Купить сейчас'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
