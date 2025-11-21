import 'package:fusent_mobile/features/catalog/data/models/product_model.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<ProductModel> products;
  final bool hasReachedMax;
  final int currentPage;
  final String query;
  final int totalCount;

  SearchLoaded({
    required this.products,
    required this.hasReachedMax,
    required this.currentPage,
    required this.query,
    this.totalCount = 0,
  });

  SearchLoaded copyWith({
    List<ProductModel>? products,
    bool? hasReachedMax,
    int? currentPage,
    String? query,
    int? totalCount,
  }) {
    return SearchLoaded(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      query: query ?? this.query,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

class SearchError extends SearchState {
  final String message;

  SearchError({required this.message});
}

class SearchEmpty extends SearchState {
  final String query;

  SearchEmpty({required this.query});
}
