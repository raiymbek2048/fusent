import 'package:flutter/material.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:fusent_mobile/features/feed/data/models/post_model.dart';
import 'package:fusent_mobile/features/feed/presentation/pages/posts_viewer_page.dart';
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

  String? _actualShopId; // Real shop ID (if shop exists)
  String? _merchantId; // Merchant ID for fetching posts/products

  List<dynamic> _products = [];
  List<dynamic> _posts = [];
  List<dynamic> _reviews = [];
  bool _isLoadingProducts = false;
  bool _isLoadingPosts = false;
  bool _isLoadingReviews = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadShopData();
  }

  Future<void> _loadShopData() async {
    setState(() {
      _isLoadingShop = true;
    });

    try {
      debugPrint('=== SHOP PROFILE DEBUG START ===');
      debugPrint('Requesting shop/merchant with ID: ${widget.shopId}');

      // First try to load as shop ID
      try {
        final shopResponse = await _apiClient.getShopById(widget.shopId);

        if (mounted && shopResponse.statusCode == 200) {
          final shop = shopResponse.data as Map<String, dynamic>;
          _updateShopData(shop);
          return;
        }
      } catch (shopError) {
        debugPrint('Failed to load as shop ID: $shopError');
        debugPrint('Trying to load as merchant ID...');
      }

      // If shop ID failed, try loading as merchant ID
      // First get merchant details to extract owner user ID
      String? ownerUserId;
      try {
        final merchantResponse = await _apiClient.get('/api/v1/merchants/${widget.shopId}');
        if (merchantResponse.statusCode == 200) {
          final merchant = merchantResponse.data as Map<String, dynamic>;
          // Try both camelCase and snake_case field names
          ownerUserId = (merchant['ownerUserId'] ?? merchant['owner_id'])?.toString();
          debugPrint('Got merchant owner user ID: $ownerUserId');
        }
      } catch (e) {
        debugPrint('Not a merchant ID, treating as user ID: $e');
      }

      // If we couldn't get ownerUserId from merchant, use widget.shopId as fallback
      if (ownerUserId == null || ownerUserId.isEmpty) {
        ownerUserId = widget.shopId;
        debugPrint('Using shopId as ownerUserId fallback: $ownerUserId');
      }

      final sellerResponse = await _apiClient.get('/api/v1/shops/seller/$ownerUserId');

      debugPrint('Seller response status: ${sellerResponse.statusCode}');
      debugPrint('Seller response data: ${sellerResponse.data}');

      if (mounted && sellerResponse.statusCode == 200) {
        final shops = sellerResponse.data as List<dynamic>;

        if (shops.isNotEmpty) {
          // Use first shop for this merchant
          final shop = shops[0] as Map<String, dynamic>;
          _updateShopData(shop);
        } else {
          // No shops for this merchant - show merchant profile with placeholder data
          debugPrint('No shops found for merchant, showing placeholder');
          setState(() {
            _merchantId = widget.shopId; // This is actually merchant ID
            _shopData = {
              'name': widget.shopName ?? 'Магазин',
              'description': 'У этого продавца пока нет магазинов',
              'avatar': null,
              'coverImage': null,
              'rating': 0.0,
              'reviewsCount': 0,
              'followersCount': 0,
              'productsCount': 0,
              'isVerified': false,
              'location': '',
              'ownerId': ownerUserId, // Use actual owner user ID for chat
            };
          });

          // Load posts for the merchant (no products/reviews without a shop)
          _loadPosts();
        }
      } else {
        throw Exception('Failed to load merchant shops');
      }
    } catch (e) {
      debugPrint('Error loading shop data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось загрузить магазин'),
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

  void _updateShopData(Map<String, dynamic> shop) {
    debugPrint('Shop name: ${shop['name']}');
    debugPrint('Shop logoUrl: ${shop['logoUrl']}');
    debugPrint('Shop bannerUrl: ${shop['bannerUrl']}');
    debugPrint('Shop followersCount: ${shop['followersCount']}');
    debugPrint('Shop productsCount: ${shop['productsCount']}');
    debugPrint('Shop isVerified: ${shop['isVerified']}');
    debugPrint('=== SHOP PROFILE DEBUG END ===');

    setState(() {
      _actualShopId = shop['id']; // Store actual shop ID
      _merchantId = shop['merchantId']; // Store merchant ID

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

    // Load data for tabs
    _loadProducts();
    _loadPosts();
    _loadReviews();

    // Check follow status after merchantId is available
    _checkFollowStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkFollowStatus() async {
    // Only check follow status after merchantId is loaded
    if (_merchantId == null) {
      debugPrint('No merchant ID available for follow check');
      return;
    }

    try {
      final response = await _apiClient.isFollowingTarget(
        targetType: 'MERCHANT',
        targetId: _merchantId!,
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
    if (_merchantId == null) {
      debugPrint('Cannot toggle follow: merchantId is null');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isFollowing) {
        // Unfollow
        await _apiClient.unfollowTarget(
          targetType: 'MERCHANT',
          targetId: _merchantId!,
        );
        setState(() {
          _isFollowing = false;
          _shopData['followersCount']--;
        });
      } else {
        // Follow
        await _apiClient.followTarget(
          targetType: 'MERCHANT',
          targetId: _merchantId!,
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
      debugPrint('Error toggling follow: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось изменить подписку'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
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
              background: _shopData['coverImage'] != null
                  ? Image.network(
                      _shopData['coverImage'] as String,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.surface,
                        );
                      },
                    )
                  : Container(
                      color: AppColors.surface,
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
                          backgroundImage: _shopData['avatar'] != null
                              ? NetworkImage(_shopData['avatar'] as String)
                              : null,
                          child: _shopData['avatar'] == null
                              ? const Icon(
                                  Icons.store,
                                  size: 50,
                                  color: AppColors.textSecondary,
                                )
                              : null,
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
    if (_isLoadingProducts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_products.isEmpty) {
      return const Center(
        child: Text(
          'Нет товаров',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index] as Map<String, dynamic>;
        final imageUrl = (product['images'] as List<dynamic>?)?.isNotEmpty == true
            ? product['images'][0]
            : null;

        return GestureDetector(
          onTap: () {
            context.push('/product/${product['id']}');
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
                    child: imageUrl != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 40,
                                    color: AppColors.textSecondary,
                                  ),
                                );
                              },
                            ),
                          )
                        : const Center(
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
                        product['name'] ?? 'Без названия',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product['price'] ?? 0} сом',
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
    if (_isLoadingPosts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_posts.isEmpty) {
      return const Center(
        child: Text(
          'Нет постов',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index] as Map<String, dynamic>;
        final media = post['media'] as List<dynamic>?;
        final imageUrl = media?.isNotEmpty == true
            ? media![0]['url']
            : null;

        return GestureDetector(
          onTap: () {
            // Convert posts to PostModel objects
            final postModels = _posts.map((postJson) =>
              PostModel.fromJson(postJson as Map<String, dynamic>)
            ).toList();

            // Navigate to TikTok-style feed starting from this post
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostsViewerPage(
                  posts: postModels,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: Container(
            color: AppColors.surface,
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.image,
                          size: 40,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Icon(
                      Icons.image,
                      size: 40,
                      color: AppColors.textSecondary,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildReviewsList() {
    if (_isLoadingReviews) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reviews.isEmpty) {
      return const Center(
        child: Text(
          'Нет отзывов',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final review = _reviews[index] as Map<String, dynamic>;
        final rating = (review['rating'] ?? 0).toInt();
        final reviewerName = review['reviewerName'] ?? 'Пользователь';
        final comment = review['comment'] ?? '';
        final createdAt = review['createdAt'] as String?;

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
                    child: Text(
                      reviewerName.isNotEmpty ? reviewerName[0].toUpperCase() : 'П',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reviewerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              i < rating ? Icons.star : Icons.star_border,
                              size: 16,
                              color: Colors.amber,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  if (createdAt != null)
                    Text(
                      _formatDate(createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
              if (comment.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  comment,
                  style: const TextStyle(height: 1.5),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Сегодня';
      } else if (difference.inDays == 1) {
        return 'Вчера';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} дн. назад';
      } else if (difference.inDays < 30) {
        return '${(difference.inDays / 7).floor()} нед. назад';
      } else {
        return '${(difference.inDays / 30).floor()} мес. назад';
      }
    } catch (e) {
      return '';
    }
  }

  Future<void> _loadProducts() async {
    if (_actualShopId == null) {
      debugPrint('No shop ID, cannot load products');
      return;
    }

    setState(() {
      _isLoadingProducts = true;
    });

    try {
      final response = await _apiClient.get(
        '/api/v1/catalog/products?shopId=$_actualShopId&size=20',
      );

      if (mounted && response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        setState(() {
          _products = data['content'] as List<dynamic>;
        });
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
        });
      }
    }
  }

  Future<void> _loadPosts() async {
    if (_merchantId == null) {
      debugPrint('No merchant ID, cannot load posts');
      return;
    }

    setState(() {
      _isLoadingPosts = true;
    });

    try {
      final response = await _apiClient.get(
        '/api/v1/social/posts/by-owner?ownerType=MERCHANT&ownerId=$_merchantId&size=20',
      );

      if (mounted && response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        setState(() {
          _posts = data['content'] as List<dynamic>;
        });
      }
    } catch (e) {
      debugPrint('Error loading posts: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPosts = false;
        });
      }
    }
  }

  Future<void> _loadReviews() async {
    if (_actualShopId == null) {
      debugPrint('No shop ID, cannot load reviews');
      return;
    }

    setState(() {
      _isLoadingReviews = true;
    });

    try {
      final response = await _apiClient.get(
        '/api/v1/reviews/shops/$_actualShopId?size=20',
      );

      if (mounted && response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        setState(() {
          _reviews = data['content'] as List<dynamic>;
        });
      }
    } catch (e) {
      debugPrint('Error loading reviews: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
        });
      }
    }
  }
}
