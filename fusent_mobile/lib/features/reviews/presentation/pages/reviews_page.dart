import 'package:flutter/material.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';

class ReviewsPage extends StatefulWidget {
  final String productId;
  final double averageRating;
  final int totalReviews;

  const ReviewsPage({
    super.key,
    required this.productId,
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  String _selectedFilter = 'all';
  final Map<String, int> _ratingDistribution = {
    '5': 65,
    '4': 20,
    '3': 10,
    '2': 3,
    '1': 2,
  };

  // Mock data
  final List<Review> _reviews = [
    Review(
      id: '1',
      userName: 'Анна Иванова',
      userAvatar: 'https://via.placeholder.com/150',
      rating: 5.0,
      comment: 'Отличный товар! Качество на высоте, быстрая доставка. Рекомендую!',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      images: [
        'https://via.placeholder.com/300',
        'https://via.placeholder.com/300',
      ],
      likes: 12,
      isVerifiedPurchase: true,
    ),
    Review(
      id: '2',
      userName: 'Петр Сидоров',
      userAvatar: 'https://via.placeholder.com/150',
      rating: 4.0,
      comment: 'Хороший товар, но доставка задержалась на пару дней.',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      images: [],
      likes: 5,
      isVerifiedPurchase: true,
    ),
    Review(
      id: '3',
      userName: 'Мария Петрова',
      userAvatar: 'https://via.placeholder.com/150',
      rating: 5.0,
      comment: 'Превзошло ожидания! Буду заказывать еще.',
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      images: ['https://via.placeholder.com/300'],
      likes: 8,
      isVerifiedPurchase: false,
    ),
  ];

  List<Review> get _filteredReviews {
    if (_selectedFilter == 'all') {
      return _reviews;
    } else if (_selectedFilter == 'with_photo') {
      return _reviews.where((r) => r.images.isNotEmpty).toList();
    } else {
      final rating = int.parse(_selectedFilter);
      return _reviews.where((r) => r.rating.floor() == rating).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Отзывы'),
        backgroundColor: AppColors.background,
        actions: [
          TextButton.icon(
            onPressed: () {
              _showWriteReviewDialog();
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Написать'),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Rating Summary
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Average Rating
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Text(
                              widget.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < widget.averageRating.floor()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                );
                              }),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${widget.totalReviews} отзывов',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Rating Distribution
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [5, 4, 3, 2, 1].map((star) {
                            final percentage =
                                _ratingDistribution[star.toString()]! /
                                    widget.totalReviews *
                                    100;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Text(
                                    '$star',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 14),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: percentage / 100,
                                      backgroundColor: AppColors.divider,
                                      valueColor: const AlwaysStoppedAnimation(
                                          AppColors.primary),
                                      minHeight: 4,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 35,
                                    child: Text(
                                      '${percentage.toInt()}%',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Filter Chips
          SliverToBoxAdapter(
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip('Все', 'all'),
                  _buildFilterChip('С фото', 'with_photo'),
                  _buildFilterChip('5 звезд', '5'),
                  _buildFilterChip('4 звезды', '4'),
                  _buildFilterChip('3 звезды', '3'),
                  _buildFilterChip('2 звезды', '2'),
                  _buildFilterChip('1 звезда', '1'),
                ],
              ),
            ),
          ),

          // Reviews List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final review = _filteredReviews[index];
                return _buildReviewCard(review);
              },
              childCount: _filteredReviews.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.background,
                backgroundImage: NetworkImage(review.userAvatar),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.userName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (review.isVerifiedPurchase) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 16,
                            color: AppColors.success,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _formatTimestamp(review.timestamp),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, size: 20),
                onPressed: () {
                  // TODO: Show options
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Rating
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating.floor() ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 16,
              );
            }),
          ),

          const SizedBox(height: 8),

          // Comment
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),

          // Images
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        review.images[index],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  // TODO: Like review
                },
                icon: const Icon(Icons.thumb_up_outlined, size: 16),
                label: Text('Полезно (${review.likes})'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: () {
                  // TODO: Reply to review
                },
                icon: const Icon(Icons.reply, size: 16),
                label: const Text('Ответить'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Сегодня';
    } else if (difference.inDays == 1) {
      return 'Вчера';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дней назад';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} недель назад';
    } else {
      return '${(difference.inDays / 30).floor()} месяцев назад';
    }
  }

  void _showWriteReviewDialog() {
    double rating = 5.0;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Написать отзыв',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Оценка',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 40,
                        ),
                        onPressed: () {
                          setModalState(() {
                            rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Комментарий',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Расскажите о вашем опыте использования...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Submit review
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                      ),
                      child: const Text('Отправить'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// Models
class Review {
  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime timestamp;
  final List<String> images;
  final int likes;
  final bool isVerifiedPurchase;

  Review({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.timestamp,
    required this.images,
    required this.likes,
    required this.isVerifiedPurchase,
  });
}
