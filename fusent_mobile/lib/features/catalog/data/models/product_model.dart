import 'package:fusent_mobile/features/catalog/data/models/product_variant_model.dart';

class ProductModel {
  final String id;
  final String shopId;
  final String categoryId;
  final String name;
  final String? description;
  final String? imageUrl;
  final double basePrice;
  final bool active;
  final DateTime createdAt;
  final int stock;
  final List<ProductVariantModel> variants;

  ProductModel({
    required this.id,
    required this.shopId,
    required this.categoryId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.basePrice,
    required this.active,
    required this.createdAt,
    required this.stock,
    this.variants = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      shopId: json['shopId'] as String,
      categoryId: json['categoryId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      active: json['active'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      stock: json['stock'] as int? ?? 0,
      variants: (json['variants'] as List<dynamic>?)
              ?.map((v) => ProductVariantModel.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'basePrice': basePrice,
      'active': active,
      'createdAt': createdAt.toIso8601String(),
      'stock': stock,
      'variants': variants.map((v) => v.toJson()).toList(),
    };
  }

  // Helper method to get all image URLs from variants
  List<String> getAllImageUrls() {
    List<String> images = [];
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // Split comma-separated URLs
      images.addAll(imageUrl!.split(',').map((url) => url.trim()).where((url) => url.isNotEmpty));
    }
    return images;
  }

  // Get the first available price (from variants if available, otherwise basePrice)
  double get currentPrice {
    if (variants.isNotEmpty) {
      return variants.first.price;
    }
    return basePrice;
  }
}
