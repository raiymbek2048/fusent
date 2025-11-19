import 'dart:convert';

class ProductVariantModel {
  final String id;
  final String productId;
  final String sku;
  final String? name;
  final String? barcode;
  final Map<String, dynamic>? attributes; // {"size":"42","color":"black"}
  final double price;
  final int stockQuantity;
  final DateTime? updatedAt;

  ProductVariantModel({
    required this.id,
    required this.productId,
    required this.sku,
    this.name,
    this.barcode,
    this.attributes,
    required this.price,
    required this.stockQuantity,
    this.updatedAt,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    // Parse attributesJson if it's a string
    Map<String, dynamic>? parsedAttributes;
    if (json['attributesJson'] != null) {
      if (json['attributesJson'] is String) {
        try {
          parsedAttributes = jsonDecode(json['attributesJson'] as String);
        } catch (e) {
          parsedAttributes = null;
        }
      } else if (json['attributesJson'] is Map) {
        parsedAttributes = json['attributesJson'] as Map<String, dynamic>;
      }
    }

    return ProductVariantModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      sku: json['sku'] as String,
      name: json['name'] as String?,
      barcode: json['barcode'] as String?,
      attributes: parsedAttributes,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: json['stockQuantity'] as int? ?? 0,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'sku': sku,
      'name': name,
      'barcode': barcode,
      'attributesJson': attributes != null ? jsonEncode(attributes) : null,
      'price': price,
      'stockQuantity': stockQuantity,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Helper methods to get specific attributes
  String? get size => attributes?['size'] as String?;
  String? get color => attributes?['color'] as String?;

  // Get display name for the variant
  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;

    List<String> parts = [];
    if (size != null) parts.add('Размер $size');
    if (color != null) parts.add(color!);

    if (parts.isNotEmpty) return parts.join(', ');
    return sku;
  }

  bool get inStock => stockQuantity > 0;
}
