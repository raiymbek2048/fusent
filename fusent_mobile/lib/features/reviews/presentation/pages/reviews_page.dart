import 'package:flutter/material.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:fusent_mobile/features/reviews/data/models/review_model.dart';
import 'package:fusent_mobile/features/reviews/data/models/review_summary_model.dart';
import 'package:fusent_mobile/features/reviews/presentation/widgets/rating_summary_widget.dart';
import 'package:fusent_mobile/features/reviews/presentation/widgets/review_card.dart';
import 'package:fusent_mobile/features/reviews/presentation/widgets/write_review_dialog.dart';

class ReviewsPage extends StatefulWidget {
  final String? shopId;
  final String? productId;
  final String? shopName;
  final String? productName;
  final ApiClient apiClient;

  const ReviewsPage({
    super.key,
    this.shopId,
    this.productId,
    this.shopName,
    this.productName,
    required this.apiClient,
  }) : assert(
          (shopId != null && productId == null) ||
              (shopId == null && productId != null),
          'Either shopId or productId must be provided, but not both',
        );

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final _scrollController = ScrollController();

  ReviewSummaryModel? _summary;
  List<ReviewModel> _reviews = [];

  bool _isLoadingSummary = true;
  bool _isLoadingReviews = true;
  bool _isLoadingMore = false;
  bool _canWriteReview = false;

  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreReviews = true;

  String _sortBy = 'createdAt';
  String _sortDirection = 'DESC';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreReviews) {
        _loadMoreReviews();
      }
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadSummary(),
      _loadReviews(),
      _checkCanWriteReview(),
    ]);
  }

  Future<void> _loadSummary() async {
    try {
      setState(() => _isLoadingSummary = true);

      final response = widget.shopId != null
          ? await widget.apiClient.getShopReviewSummary(widget.shopId!)
          : await widget.apiClient.getProductReviewSummary(widget.productId!);

      if (mounted) {
        setState(() {
          _summary = ReviewSummaryModel.fromJson(response.data);
          _isLoadingSummary = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSummary = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load summary: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadReviews({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 0;
        _hasMoreReviews = true;
        _reviews.clear();
      });
    }

    try {
      setState(() => _isLoadingReviews = true);

      final response = widget.shopId != null
          ? await widget.apiClient.getShopReviews(
              shopId: widget.shopId!,
              page: _currentPage,
              size: _pageSize,
              sortBy: _sortBy,
              sortDirection: _sortDirection,
            )
          : await widget.apiClient.getProductReviews(
              productId: widget.productId!,
              page: _currentPage,
              size: _pageSize,
              sortBy: _sortBy,
              sortDirection: _sortDirection,
            );

      if (mounted) {
        final reviewsData = response.data['content'] as List;
        final newReviews = reviewsData
            .map((json) => ReviewModel.fromJson(json))
            .toList();

        setState(() {
          if (refresh) {
            _reviews = newReviews;
          } else {
            _reviews.addAll(newReviews);
          }
          _hasMoreReviews = !response.data['last'];
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingReviews = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load reviews: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadMoreReviews() async {
    if (_isLoadingMore || !_hasMoreReviews) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      final response = widget.shopId != null
          ? await widget.apiClient.getShopReviews(
              shopId: widget.shopId!,
              page: _currentPage,
              size: _pageSize,
              sortBy: _sortBy,
              sortDirection: _sortDirection,
            )
          : await widget.apiClient.getProductReviews(
              productId: widget.productId!,
              page: _currentPage,
              size: _pageSize,
              sortBy: _sortBy,
              sortDirection: _sortDirection,
            );

      if (mounted) {
        final reviewsData = response.data['content'] as List;
        final newReviews = reviewsData
            .map((json) => ReviewModel.fromJson(json))
            .toList();

        setState(() {
          _reviews.addAll(newReviews);
          _hasMoreReviews = !response.data['last'];
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _currentPage--;
        });
      }
    }
  }

  Future<void> _checkCanWriteReview() async {
    try {
      final response = widget.shopId != null
          ? await widget.apiClient.canReviewShop(widget.shopId!)
          : await widget.apiClient.canReviewProduct(widget.productId!);

      if (mounted) {
        setState(() {
          _canWriteReview = response.data['canReview'] ?? false;
        });
      }
    } catch (e) {
      // Silently fail - just means user can't write review
      setState(() => _canWriteReview = false);
    }
  }

  Future<void> _showWriteReviewDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => WriteReviewDialog(
        shopId: widget.shopId,
        productId: widget.productId,
        shopName: widget.shopName,
        productName: widget.productName,
        onSubmit: _submitReview,
      ),
    );

    if (result == true) {
      // Refresh reviews and summary
      await _loadData();
    }
  }

  Future<void> _submitReview(int rating, String? title, String? comment) async {
    if (widget.shopId != null) {
      await widget.apiClient.createShopReview(
        shopId: widget.shopId!,
        rating: rating,
        title: title,
        comment: comment,
      );
    } else {
      await widget.apiClient.createProductReview(
        productId: widget.productId!,
        rating: rating,
        title: title,
        comment: comment,
      );
    }
  }

  Future<void> _markHelpful(String reviewId) async {
    try {
      await widget.apiClient.markReviewHelpful(
        reviewId: reviewId,
        helpful: true,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Marked as helpful'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Refresh to get updated count
      await _loadReviews(refresh: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark as helpful: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _changeSortOrder(String sortBy, String sortDirection) {
    if (_sortBy != sortBy || _sortDirection != sortDirection) {
      setState(() {
        _sortBy = sortBy;
        _sortDirection = sortDirection;
      });
      _loadReviews(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isForShop = widget.shopId != null;
    final targetName = isForShop ? widget.shopName : widget.productName;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (targetName != null)
              Text(
                targetName,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        actions: [
          // Sort dropdown
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: AppColors.textPrimary),
            onSelected: (value) {
              switch (value) {
                case 'newest':
                  _changeSortOrder('createdAt', 'DESC');
                  break;
                case 'oldest':
                  _changeSortOrder('createdAt', 'ASC');
                  break;
                case 'highest':
                  _changeSortOrder('rating', 'DESC');
                  break;
                case 'lowest':
                  _changeSortOrder('rating', 'ASC');
                  break;
                case 'helpful':
                  _changeSortOrder('helpfulCount', 'DESC');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'newest',
                child: Text('Newest First'),
              ),
              const PopupMenuItem(
                value: 'oldest',
                child: Text('Oldest First'),
              ),
              const PopupMenuItem(
                value: 'highest',
                child: Text('Highest Rating'),
              ),
              const PopupMenuItem(
                value: 'lowest',
                child: Text('Lowest Rating'),
              ),
              const PopupMenuItem(
                value: 'helpful',
                child: Text('Most Helpful'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadData(),
        child: _isLoadingSummary && _isLoadingReviews
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Summary
                  if (_summary != null)
                    RatingSummaryWidget(
                      summary: _summary!,
                      onWriteReviewTap: _canWriteReview ? _showWriteReviewDialog : null,
                    ),

                  const SizedBox(height: 24),

                  // Reviews count header
                  Text(
                    '${_summary?.totalReviews ?? 0} Reviews',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Reviews list
                  if (_reviews.isEmpty && !_isLoadingReviews)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No reviews yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    ...List.generate(_reviews.length, (index) {
                      final review = _reviews[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ReviewCard(
                          review: review,
                          onHelpfulTap: () => _markHelpful(review.id),
                        ),
                      );
                    }),

                  // Loading more indicator
                  if (_isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),

                  // End of list indicator
                  if (!_hasMoreReviews && _reviews.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'No more reviews',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
