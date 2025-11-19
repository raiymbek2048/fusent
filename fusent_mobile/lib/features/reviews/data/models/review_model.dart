enum ReviewStatus { ACTIVE, HIDDEN, FLAGGED, DELETED }

class ReviewModel {
  final String id;
  final String reviewerId;
  final String reviewerName;

  // Either shopId or productId will be set
  final String? shopId;
  final String? shopName;
  final String? productId;
  final String? productName;

  final String? orderId;

  final int rating; // 1-5
  final String? title;
  final String? comment;

  final bool isVerifiedPurchase;
  final int helpfulCount;

  final ReviewStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewModel({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    this.shopId,
    this.shopName,
    this.productId,
    this.productName,
    this.orderId,
    required this.rating,
    this.title,
    this.comment,
    required this.isVerifiedPurchase,
    required this.helpfulCount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      reviewerId: json['reviewerId'] as String,
      reviewerName: json['reviewerName'] as String? ?? 'Unknown',
      shopId: json['shopId'] as String?,
      shopName: json['shopName'] as String?,
      productId: json['productId'] as String?,
      productName: json['productName'] as String?,
      orderId: json['orderId'] as String?,
      rating: json['rating'] as int,
      title: json['title'] as String?,
      comment: json['comment'] as String?,
      isVerifiedPurchase: json['isVerifiedPurchase'] as bool? ?? false,
      helpfulCount: json['helpfulCount'] as int? ?? 0,
      status: ReviewStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ReviewStatus.ACTIVE,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'shopId': shopId,
      'shopName': shopName,
      'productId': productId,
      'productName': productName,
      'orderId': orderId,
      'rating': rating,
      'title': title,
      'comment': comment,
      'isVerifiedPurchase': isVerifiedPurchase,
      'helpfulCount': helpfulCount,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isForShop => shopId != null && productId == null;
  bool get isForProduct => productId != null && shopId == null;
}
