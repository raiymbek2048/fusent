import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:fusent_mobile/features/catalog/data/models/product_model.dart';
import 'package:fusent_mobile/features/search/presentation/bloc/search_event.dart';
import 'package:fusent_mobile/features/search/presentation/bloc/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ApiClient apiClient;

  SearchBloc({required this.apiClient}) : super(SearchInitial()) {
    on<SearchProducts>(_onSearchProducts);
    on<ClearSearch>(_onClearSearch);
    on<LoadMoreResults>(_onLoadMoreResults);
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<SearchState> emit,
  ) async {
    try {
      if (event.page == 0) {
        emit(SearchLoading());
      }

      final response = await apiClient.searchProducts(
        query: event.query,
        categoryId: event.categoryId,
        shopId: event.shopId,
        page: event.page,
        size: 20,
      );

      if (response.statusCode == 200 && response.data != null) {
        List<ProductModel> products = [];

        final data = response.data;
        if (data is Map && data['content'] is List) {
          products = (data['content'] as List)
              .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (data is List) {
          products = data
              .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        final totalCount = data is Map ? (data['totalElements'] ?? products.length) : products.length;

        if (event.page == 0) {
          if (products.isEmpty) {
            emit(SearchEmpty(query: event.query));
          } else {
            emit(SearchLoaded(
              products: products,
              hasReachedMax: products.length < 20,
              currentPage: 0,
              query: event.query,
              totalCount: totalCount,
            ));
          }
        } else {
          final currentState = state;
          if (currentState is SearchLoaded) {
            emit(currentState.copyWith(
              products: [...currentState.products, ...products],
              hasReachedMax: products.length < 20,
              currentPage: event.page,
            ));
          }
        }
      } else {
        emit(SearchError(message: 'Не удалось выполнить поиск'));
      }
    } catch (e) {
      emit(SearchError(message: e.toString()));
    }
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchInitial());
  }

  Future<void> _onLoadMoreResults(
    LoadMoreResults event,
    Emitter<SearchState> emit,
  ) async {
    final currentState = state;
    if (currentState is SearchLoaded && !currentState.hasReachedMax) {
      add(SearchProducts(
        query: currentState.query,
        page: currentState.currentPage + 1,
      ));
    }
  }
}
