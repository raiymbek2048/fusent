class ReviewSummaryModel {
  final double averageRating;
  final int totalReviews;
  final int fiveStarCount;
  final int fourStarCount;
  final int threeStarCount;
  final int twoStarCount;
  final int oneStarCount;
  final int verifiedPurchaseCount;

  ReviewSummaryModel({
    required this.averageRating,
    required this.totalReviews,
    required this.fiveStarCount,
    required this.fourStarCount,
    required this.threeStarCount,
    required this.twoStarCount,
    required this.oneStarCount,
    required this.verifiedPurchaseCount,
  });

  factory ReviewSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReviewSummaryModel(
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      fiveStarCount: json['fiveStarCount'] as int? ?? 0,
      fourStarCount: json['fourStarCount'] as int? ?? 0,
      threeStarCount: json['threeStarCount'] as int? ?? 0,
      twoStarCount: json['twoStarCount'] as int? ?? 0,
      oneStarCount: json['oneStarCount'] as int? ?? 0,
      verifiedPurchaseCount: json['verifiedPurchaseCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'fiveStarCount': fiveStarCount,
      'fourStarCount': fourStarCount,
      'threeStarCount': threeStarCount,
      'twoStarCount': twoStarCount,
      'oneStarCount': oneStarCount,
      'verifiedPurchaseCount': verifiedPurchaseCount,
    };
  }

  // Helper methods
  double getStarPercentage(int starCount) {
    if (totalReviews == 0) return 0.0;
    return (starCount / totalReviews) * 100;
  }

  int getStarCount(int stars) {
    switch (stars) {
      case 5:
        return fiveStarCount;
      case 4:
        return fourStarCount;
      case 3:
        return threeStarCount;
      case 2:
        return twoStarCount;
      case 1:
        return oneStarCount;
      default:
        return 0;
    }
  }
}
