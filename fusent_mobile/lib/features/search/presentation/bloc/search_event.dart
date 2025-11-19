abstract class SearchEvent {}

class SearchProducts extends SearchEvent {
  final String query;
  final String? categoryId;
  final String? shopId;
  final double? minPrice;
  final double? maxPrice;
  final int page;

  SearchProducts({
    required this.query,
    this.categoryId,
    this.shopId,
    this.minPrice,
    this.maxPrice,
    this.page = 0,
  });
}

class ClearSearch extends SearchEvent {}

class LoadMoreResults extends SearchEvent {}
