import 'package:flutter/material.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:go_router/go_router.dart';

class ShopProfilePage extends StatefulWidget {
  final String shopId;
  final String? shopName;

  const ShopProfilePage({
    super.key,
    required this.shopId,
    this.shopName,
  });

  @override
  State<ShopProfilePage> createState() => _ShopProfilePageState();
}

class _ShopProfilePageState extends State<ShopProfilePage>
    with SingleTickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();
  late TabController _tabController;
  bool _isFollowing = false;
  bool _isLoading = false;
  bool _isLoadingShop = true;

  Map<String, dynamic> _shopData = {
    'name': 'Загрузка...',
    'description': '',
    'avatar': null,
    'coverImage': null,
    'rating': 0.0,
    'reviewsCount': 0,
    'followersCount': 0,
    'productsCount': 0,
    'isVerified': false,
    'location': '',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadShopData();
    _checkFollowStatus();
  }

  Future<void> _loadShopData() async {
    setState(() {
      _isLoadingShop = true;
    });

    try {
      final response = await _apiClient.getShopById(widget.shopId);

      if (mounted && response.statusCode == 200) {
        final shop = response.data as Map<String, dynamic>;

        setState(() {
          _shopData = {
            'name': shop['name'] ?? 'Без названия',
            'description': shop['description'] ?? '',
            'avatar': shop['logoUrl'],
            'coverImage': shop['bannerUrl'],
            'rating': (shop['averageRating'] ?? 0.0).toDouble(),
            'reviewsCount': shop['totalReviews'] ?? 0,
            'followersCount': shop['followersCount'] ?? 0,
            'productsCount': shop['productsCount'] ?? 0,
            'isVerified': shop['isVerified'] ?? false,
            'location': shop['address'] ?? '',
            'ownerId': shop['ownerId'],
          };
        });
      }
    } catch (e) {
      debugPrint('Error loading shop data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось загрузить магазин: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingShop = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkFollowStatus() async {
    try {
      final response = await _apiClient.isFollowingTarget(
        targetType: 'MERCHANT',
        targetId: widget.shopId,
      );

      if (mounted && response.statusCode == 200) {
        setState(() {
          _isFollowing = response.data as bool? ?? false;
        });
      }
    } catch (e) {
      // Silently fail - user might not be authenticated
      debugPrint('Error checking follow status: $e');
    }
  }

  Future<void> _toggleFollow() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isFollowing) {
        // Unfollow
        await _apiClient.unfollowTarget(
          targetType: 'MERCHANT',
          targetId: widget.shopId,
        );
        setState(() {
          _isFollowing = false;
          _shopData['followersCount']--;
        });
      } else {
        // Follow
        await _apiClient.followTarget(
          targetType: 'MERCHANT',
          targetId: widget.shopId,
        );
        setState(() {
          _isFollowing = true;
          _shopData['followersCount']++;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFollowing ? 'Вы подписались на магазин' : 'Вы отписались от магазина'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Cover Image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                _shopData['coverImage'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surface,
                  );
                },
              ),
            ),
          ),

          // Shop Info
          SliverToBoxAdapter(
            child: Column(
              children: [
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Column(
                    children: [
                      // Shop Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.background,
                            width: 4,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.surface,
                          child: const Icon(
                            Icons.store,
                            size: 50,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Shop Name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _shopData['name'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_shopData['isVerified']) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.verified,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Location
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _shopData['location'],
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Stats Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn(
                              '${_shopData['productsCount']}',
                              'Товаров',
                            ),
                            _buildStatColumn(
                              '${_shopData['followersCount']}',
                              'Подписчиков',
                            ),
                            _buildStatColumn(
                              '${_shopData['rating']}',
                              'Рейтинг',
                              icon: Icons.star,
                              iconColor: Colors.amber,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _shopData['description'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _toggleFollow,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isFollowing ? AppColors.surface : AppColors.primary,
                                  foregroundColor: _isFollowing ? AppColors.textPrimary : Colors.white,
                                  minimumSize: const Size(0, 48),
                                ),
                                icon: Icon(
                                  _isFollowing ? Icons.check : Icons.add,
                                ),
                                label: Text(
                                  _isFollowing ? 'Подписан' : 'Подписаться',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: OutlinedButton.icon(
                                onPressed: _shopData['ownerId'] != null
                                    ? () {
                                        context.push(
                                          '/chat/${widget.shopId}?shopName=${_shopData['name']}&recipientId=${_shopData['ownerId']}',
                                        );
                                      }
                                    : null,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.border),
                                  minimumSize: const Size(0, 48),
                                ),
                                icon: const Icon(Icons.chat_bubble_outline),
                                label: const Text('Написать'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tabs
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.divider),
                          ),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textSecondary,
                          indicatorColor: AppColors.primary,
                          tabs: const [
                            Tab(text: 'Товары'),
                            Tab(text: 'Посты'),
                            Tab(text: 'Отзывы'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductsGrid(),
                _buildPostsGrid(),
                _buildReviewsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, {IconData? icon, Color? iconColor}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: iconColor),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildProductsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            context.push('/product/$index');
          },
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
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 40,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Товар #${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(index + 1) * 1000} сом',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildPostsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemCount: 15,
      itemBuilder: (context, index) {
        return Container(
          color: AppColors.surface,
          child: const Center(
            child: Icon(
              Icons.image,
              size: 40,
              color: AppColors.textSecondary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Пользователь',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              i < 4 ? Icons.star : Icons.star_border,
                              size: 16,
                              color: Colors.amber,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    '2 дня назад',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Отличный магазин! Быстрая доставка, качественные товары.',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        );
      },
    );
  }
}
