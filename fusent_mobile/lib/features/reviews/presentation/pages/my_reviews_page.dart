import 'package:flutter/material.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:fusent_mobile/features/reviews/data/models/review_model.dart';
import 'package:fusent_mobile/features/reviews/presentation/widgets/review_card.dart';

class MyReviewsPage extends StatefulWidget {
  final ApiClient apiClient;

  const MyReviewsPage({
    super.key,
    required this.apiClient,
  });

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  final _scrollController = ScrollController();

  List<ReviewModel> _reviews = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;

  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreReviews = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadReviews();
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

  Future<void> _loadReviews({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 0;
        _hasMoreReviews = true;
        _reviews.clear();
      });
    }

    try {
      setState(() => _isLoading = true);

      final response = await widget.apiClient.getMyReviews(
        page: _currentPage,
        size: _pageSize,
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
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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
      final response = await widget.apiClient.getMyReviews(
        page: _currentPage,
        size: _pageSize,
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

  Future<void> _deleteReview(String reviewId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Delete Review',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to delete this review?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await widget.apiClient.deleteReview(reviewId);

      if (mounted) {
        setState(() {
          _reviews.removeWhere((r) => r.id == reviewId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review deleted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete review: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Reviews',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadReviews(refresh: true),
        child: _isLoading && _reviews.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _reviews.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No reviews yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Your reviews will appear here',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Shop and Product labels for each review
                      ...List.generate(_reviews.length, (index) {
                        final review = _reviews[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Target label (shop or product name)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8, left: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    review.isForShop
                                        ? Icons.store
                                        : Icons.shopping_bag,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      review.isForShop
                                          ? 'Review for ${review.shopName ?? 'Shop'}'
                                          : 'Review for ${review.productName ?? 'Product'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Review card
                            ReviewCard(
                              review: review,
                              showActions: true,
                              onDeleteTap: () => _deleteReview(review.id),
                            ),

                            const SizedBox(height: 16),
                          ],
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
