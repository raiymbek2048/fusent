import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:fusent_mobile/features/search/presentation/bloc/search_bloc.dart';
import 'package:fusent_mobile/features/search/presentation/bloc/search_event.dart';
import 'package:fusent_mobile/features/search/presentation/bloc/search_state.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  final String? initialQuery;

  const SearchPage({
    super.key,
    this.initialQuery,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  String? _selectedCategoryId;
  String? _selectedShopId;
  double? _minPrice;
  double? _maxPrice;
  String _sortBy = 'relevance';
  List<String> _searchHistory = [];
  bool _showHistory = true;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _showHistory = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _performSearch());
    }
    _scrollController.addListener(_onScroll);
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus && _searchController.text.isEmpty) {
        setState(() => _showHistory = true);
      }
    });
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('search_history') ?? [];
    });
  }

  Future<void> _saveSearchHistory(String query) async {
    if (query.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    _searchHistory.remove(query);
    _searchHistory.insert(0, query);
    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.sublist(0, 10);
    }
    await prefs.setStringList('search_history', _searchHistory);
  }

  Future<void> _clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('search_history');
    setState(() => _searchHistory = []);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<SearchBloc>().add(LoadMoreResults());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    _saveSearchHistory(query);
    setState(() => _showHistory = false);

    context.read<SearchBloc>().add(
          SearchProducts(
            query: query,
            categoryId: _selectedCategoryId,
            shopId: _selectedShopId,
            minPrice: _minPrice,
            maxPrice: _maxPrice,
            sortBy: _sortBy,
          ),
        );
  }

  void _showFiltersBottomSheet() {
    final minController = TextEditingController(text: _minPrice?.toString() ?? '');
    final maxController = TextEditingController(text: _maxPrice?.toString() ?? '');
    String tempSort = _sortBy;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Фильтры',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Сортировка', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('По релевантности'),
                    selected: tempSort == 'relevance',
                    onSelected: (_) => setModalState(() => tempSort = 'relevance'),
                  ),
                  ChoiceChip(
                    label: const Text('Сначала дешёвые'),
                    selected: tempSort == 'price_asc',
                    onSelected: (_) => setModalState(() => tempSort = 'price_asc'),
                  ),
                  ChoiceChip(
                    label: const Text('Сначала дорогие'),
                    selected: tempSort == 'price_desc',
                    onSelected: (_) => setModalState(() => tempSort = 'price_desc'),
                  ),
                  ChoiceChip(
                    label: const Text('Новинки'),
                    selected: tempSort == 'newest',
                    onSelected: (_) => setModalState(() => tempSort = 'newest'),
                  ),
                  ChoiceChip(
                    label: const Text('Популярные'),
                    selected: tempSort == 'popular',
                    onSelected: (_) => setModalState(() => tempSort = 'popular'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Цена', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minController,
                      decoration: const InputDecoration(
                        labelText: 'От',
                        border: OutlineInputBorder(),
                        suffixText: 'сом',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: maxController,
                      decoration: const InputDecoration(
                        labelText: 'До',
                        border: OutlineInputBorder(),
                        suffixText: 'сом',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _minPrice = null;
                          _maxPrice = null;
                          _sortBy = 'relevance';
                        });
                        Navigator.pop(context);
                        _performSearch();
                      },
                      child: const Text('Сбросить'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _minPrice = double.tryParse(minController.text);
                          _maxPrice = double.tryParse(maxController.text);
                          _sortBy = tempSort;
                        });
                        Navigator.pop(context);
                        _performSearch();
                      },
                      child: const Text('Применить'),
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

  Widget _buildSearchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_searchHistory.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'История поиска',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: _clearSearchHistory,
                  child: const Text('Очистить'),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _searchHistory.length,
            itemBuilder: (context, index) {
              final query = _searchHistory[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(query),
                trailing: IconButton(
                  icon: const Icon(Icons.north_west, size: 18),
                  onPressed: () {
                    _searchController.text = query;
                    _searchController.selection = TextSelection.fromPosition(
                      TextPosition(offset: query.length),
                    );
                  },
                ),
                onTap: () {
                  _searchController.text = query;
                  _performSearch();
                },
              );
            },
          ),
        ] else
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.search, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text(
                    'Введите запрос для поиска',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(apiClient: ApiClient()),
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            autofocus: widget.initialQuery == null,
            decoration: InputDecoration(
              hintText: 'Поиск товаров...',
              border: InputBorder.none,
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<SearchBloc>().add(ClearSearch());
                        setState(() => _showHistory = true);
                      },
                    )
                  : null,
            ),
            onSubmitted: (_) => _performSearch(),
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) _showHistory = true;
              });
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: _showFiltersBottomSheet,
              tooltip: 'Фильтры',
            ),
          ],
        ),
        body: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (_showHistory && (state is SearchInitial || _searchController.text.isEmpty)) {
              return SingleChildScrollView(child: _buildSearchHistory());
            }

            if (state is SearchInitial) {
              return SingleChildScrollView(child: _buildSearchHistory());
            }

            if (state is SearchLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is SearchError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }

            if (state is SearchEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 80, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    Text(
                      'Ничего не найдено по запросу "${state.query}"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }

            if (state is SearchLoaded) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: AppColors.surface,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Найдено: ${state.totalCount} товаров',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        Text(
                          _getSortLabel(),
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: state.products.length + (state.hasReachedMax ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index >= state.products.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          );
                        }

                        final product = state.products[index];
                        final images = product.getAllImageUrls();
                        final imageUrl = images.isNotEmpty ? images.first : null;

                        return GestureDetector(
                          onTap: () => context.push('/product/${product.id}'),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    ),
                                    child: imageUrl != null
                                        ? ClipRRect(
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                            child: Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              errorBuilder: (context, error, stackTrace) {
                                                return const Center(
                                                  child: Icon(Icons.image, size: 40, color: AppColors.textSecondary),
                                                );
                                              },
                                            ),
                                          )
                                        : const Center(
                                            child: Icon(Icons.image, size: 40, color: AppColors.textSecondary),
                                          ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${product.currentPrice.toStringAsFixed(0)} сом',
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'price_asc':
        return 'Сначала дешёвые';
      case 'price_desc':
        return 'Сначала дорогие';
      case 'newest':
        return 'Новинки';
      case 'popular':
        return 'Популярные';
      default:
        return 'По релевантности';
    }
  }
}
