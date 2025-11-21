abstract class SearchEvent {}

class SearchProducts extends SearchEvent {
  final String query;
  final String? categoryId;
  final String? shopId;
  final double? minPrice;
  final double? maxPrice;
  final String sortBy;
  final int page;

  SearchProducts({
    required this.query,
    this.categoryId,
    this.shopId,
    this.minPrice,
    this.maxPrice,
    this.sortBy = 'relevance',
    this.page = 0,
  });
}

class ClearSearch extends SearchEvent {}

class LoadMoreResults extends SearchEvent {}
