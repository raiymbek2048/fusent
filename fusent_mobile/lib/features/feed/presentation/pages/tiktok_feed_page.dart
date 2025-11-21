import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/core/di/injection_container.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:fusent_mobile/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:fusent_mobile/features/feed/presentation/bloc/feed_event.dart';
import 'package:fusent_mobile/features/feed/presentation/bloc/feed_state.dart';
import 'package:fusent_mobile/features/feed/data/models/post_model.dart';
import 'package:fusent_mobile/features/feed/presentation/widgets/stories_list.dart';
import 'package:fusent_mobile/features/feed/presentation/widgets/comments_bottom_sheet.dart';
import 'package:fusent_mobile/features/feed/presentation/widgets/share_bottom_sheet.dart';
import 'package:fusent_mobile/features/feed/presentation/pages/posts_viewer_page.dart';

class TikTokFeedPage extends StatefulWidget {
  const TikTokFeedPage({super.key});

  @override
  State<TikTokFeedPage> createState() => _TikTokFeedPageState();
}

class _TikTokFeedPageState extends State<TikTokFeedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FeedBloc _followingBloc;
  late FeedBloc _interestingBloc;
  late FeedBloc _trendsBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Create separate BLoC instances for each tab
    _followingBloc = sl<FeedBloc>();
    _interestingBloc = sl<FeedBloc>();
    _trendsBloc = sl<FeedBloc>();

    // Load initial data for all feeds
    _followingBloc.add(const LoadFollowingFeed(refresh: true));
    _interestingBloc.add(const LoadPublicFeed(refresh: true));
    _trendsBloc.add(const LoadPublicFeed(refresh: true));

    // Listen to tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        if (_tabController.index == 0) {
          // Подписки
          if (_followingBloc.state is FeedInitial) {
            _followingBloc.add(const LoadFollowingFeed(refresh: true));
          }
        } else if (_tabController.index == 1) {
          // Интересное
          if (_interestingBloc.state is FeedInitial) {
            _interestingBloc.add(const LoadPublicFeed(refresh: true));
          }
        } else {
          // Тренды
          if (_trendsBloc.state is FeedInitial) {
            _trendsBloc.add(const LoadPublicFeed(refresh: true));
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _followingBloc.close();
    _interestingBloc.close();
    _trendsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main Content - TabBarView with vertical swipe feeds
          TabBarView(
            controller: _tabController,
            children: [
              // Подписки feed - со сторисами
              BlocProvider.value(
                value: _followingBloc,
                child: _buildVerticalFeed(_followingBloc, feedType: 'following', hasStories: true),
              ),
              // Интересное feed - grid layout
              BlocProvider.value(
                value: _interestingBloc,
                child: _buildGridFeed(_interestingBloc),
              ),
              // Тренды feed - со сторисами
              BlocProvider.value(
                value: _trendsBloc,
                child: _buildVerticalFeed(_trendsBloc, feedType: 'trending', hasStories: true),
              ),
            ],
          ),

          // Top UI Overlay
          _buildTopBar(),

          // Stories List - только на Подписки (0) и Тренды (2)
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, child) {
              final shouldShowStories = _tabController.index == 0 || _tabController.index == 2;
              if (!shouldShowStories) return const SizedBox.shrink();

              return const Positioned(
                top: 115,
                left: 0,
                right: 0,
                child: StoriesList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
          child: AnimatedBuilder(
            animation: _tabController,
            builder: (context, child) {
              final isInterestingTab = _tabController.index == 1;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tab Switcher
                  SizedBox(
                    height: 48,
                    child: TabBar(
                      controller: _tabController,
                      indicator: const UnderlineTabIndicator(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 3.0,
                        ),
                        insets: EdgeInsets.symmetric(horizontal: 20.0),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white54,
                      labelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                      dividerColor: Colors.transparent,
                      isScrollable: false,
                      indicatorPadding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                      tabs: const [
                        Tab(text: 'Подписки'),
                        Tab(text: 'Интересное'),
                        Tab(text: 'Тренды'),
                      ],
                    ),
                  ),
                  // Search Field - только на Интересное (индекс 1)
                  if (isInterestingTab) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GestureDetector(
                        onTap: () {
                          context.push('/search');
                        },
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[850]!.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(23),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: Colors.grey[400],
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Поиск магазинов...',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalFeed(FeedBloc bloc, {required String feedType, required bool hasStories}) {
    return BlocBuilder<FeedBloc, FeedState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is FeedLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (state is FeedError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.white70,
                ),
                const SizedBox(height: 16),
                Text(
                  'Ошибка загрузки',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (feedType == 'following') {
                      bloc.add(const LoadFollowingFeed(refresh: true));
                    } else {
                      bloc.add(const LoadPublicFeed(refresh: true));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }

        if (state is FeedLoaded) {
          if (state.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Пока нет постов',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feedType == 'following'
                        ? 'Подпишитесь на магазины,\nчтобы видеть их посты'
                        : 'Скоро здесь появятся\nинтересные публикации',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return TikTokVerticalFeed(
            posts: state.posts,
            hasStories: hasStories,
            onLike: (postId, isLiked) {
              bloc.add(LikePostEvent(postId: postId, isLiked: isLiked));
            },
            onComment: (postId, commentsCount) {
              // Save current feed state
              final currentState = bloc.state;

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => BlocProvider.value(
                  value: bloc,
                  child: CommentsBottomSheet(
                    postId: postId,
                    commentsCount: commentsCount,
                  ),
                ),
              ).then((_) {
                // Restore feed state when bottom sheet closes
                if (currentState is FeedLoaded) {
                  bloc.emit(currentState);
                }
              });
            },
            onShare: (postId) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => ShareBottomSheet(
                  postId: postId,
                ),
              );
            },
            onSave: (postId, isSaved) {
              bloc.add(SavePostEvent(postId: postId, isSaved: isSaved));
            },
            onRefresh: () async {
              if (feedType == 'following') {
                bloc.add(const LoadFollowingFeed(refresh: true));
              } else {
                bloc.add(const LoadPublicFeed(refresh: true));
              }
              // Wait a bit for the refresh to complete
              await Future.delayed(const Duration(milliseconds: 500));
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildGridFeed(FeedBloc bloc) {
    return BlocBuilder<FeedBloc, FeedState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is FeedLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (state is FeedError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.white70,
                ),
                const SizedBox(height: 16),
                Text(
                  'Ошибка загрузки',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    bloc.add(const LoadPublicFeed(refresh: true));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }

        if (state is FeedLoaded) {
          if (state.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Пока нет постов',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Скоро здесь появятся\nинтересные публикации',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return InterestingGridView(
            posts: state.posts,
            onRefresh: () async {
              bloc.add(const LoadPublicFeed(refresh: true));
              await Future.delayed(const Duration(milliseconds: 500));
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// Vertical Feed Widget similar to TikTok
class TikTokVerticalFeed extends StatefulWidget {
  final List<PostModel> posts;
  final bool hasStories;
  final Function(String, bool) onLike;
  final Function(String, int) onComment;
  final Function(String) onShare;
  final Function(String, bool) onSave;
  final Future<void> Function() onRefresh;

  const TikTokVerticalFeed({
    super.key,
    required this.posts,
    required this.hasStories,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onSave,
    required this.onRefresh,
  });

  @override
  State<TikTokVerticalFeed> createState() => _TikTokVerticalFeedState();
}

class _TikTokVerticalFeedState extends State<TikTokVerticalFeed> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: widget.hasStories ? 100 : 0),
      child: RefreshIndicator(
        onRefresh: widget.onRefresh,
        backgroundColor: Colors.grey[900],
        color: Colors.white,
        displacement: 40,
        strokeWidth: 2.5,
        child: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: widget.posts.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            final post = widget.posts[index];
            return PostFeedItem(
              post: post,
              isActive: index == _currentPage,
              onLike: () => widget.onLike(post.id, post.isLikedByCurrentUser),
              onComment: () => widget.onComment(post.id, post.commentsCount),
              onShare: () => widget.onShare(post.id),
              onSave: () => widget.onSave(post.id, false),
            );
          },
        ),
      ),
    );
  }
}

// Individual Post Item
class PostFeedItem extends StatefulWidget {
  final PostModel post;
  final bool isActive;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onSave;

  const PostFeedItem({
    super.key,
    required this.post,
    required this.isActive,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onSave,
  });

  @override
  State<PostFeedItem> createState() => _PostFeedItemState();
}

class _PostFeedItemState extends State<PostFeedItem> {
  final ApiClient _apiClient = ApiClient();
  bool _isFollowing = false;
  bool _isLoadingFollow = false;

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    if (widget.post.ownerId == null) return;

    try {
      final response = await _apiClient.isFollowingTarget(
        targetType: 'MERCHANT',
        targetId: widget.post.ownerId!,
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
    if (widget.post.ownerId == null) return;

    setState(() {
      _isLoadingFollow = true;
    });

    try {
      if (_isFollowing) {
        await _apiClient.unfollowTarget(
          targetType: 'MERCHANT',
          targetId: widget.post.ownerId!,
        );
        setState(() {
          _isFollowing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Вы отписались'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        await _apiClient.followTarget(
          targetType: 'MERCHANT',
          targetId: widget.post.ownerId!,
        );
        setState(() {
          _isFollowing = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Вы подписались'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error toggling follow: $e');
      if (mounted) {
        // Check if it's an authentication error
        String errorMessage = 'Не удалось изменить подписку';
        if (e.toString().contains('403') || e.toString().contains('401')) {
          errorMessage = 'Сессия истекла. Пожалуйста, войдите снова';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFollow = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstMedia = widget.post.media.isNotEmpty ? widget.post.media.first : null;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image/Video
        if (firstMedia != null && firstMedia.url.isNotEmpty)
          Image.network(
            firstMedia.url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.surface,
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 80,
                    color: Colors.white38,
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.black,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          )
        else
          Container(
            color: Colors.black,
            child: Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 80,
                color: Colors.white38,
              ),
            ),
          ),

        // Gradient overlays for better text visibility
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 200,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Right Side Actions
        Positioned(
          right: 12,
          bottom: widget.post.linkedProductId != null ? 160 : 80,
          child: Column(
            children: [
              // Profile Avatar
              GestureDetector(
                onTap: () {
                  if (widget.post.ownerId != null &&
                      widget.post.ownerName.isNotEmpty) {
                    context.push('/shop/${widget.post.ownerId}?shopName=${Uri.encodeComponent(widget.post.ownerName)}');
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.surface,
                    child: Text(
                      widget.post.ownerName.isNotEmpty
                          ? widget.post.ownerName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Like Button
              _buildActionButton(
                icon: widget.post.isLikedByCurrentUser
                    ? Icons.favorite
                    : Icons.favorite_border,
                label: _formatNumber(widget.post.likesCount),
                color:
                    widget.post.isLikedByCurrentUser ? Colors.red : Colors.white,
                onTap: widget.onLike,
              ),
              const SizedBox(height: 16),

              // Comment Button
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: _formatNumber(widget.post.commentsCount),
                onTap: widget.onComment,
              ),
              const SizedBox(height: 16),

              // Share Button
              _buildActionButton(
                icon: Icons.send,
                label: 'Поделиться',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ShareBottomSheet(
                      postId: widget.post.id,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Save/Bookmark Button
              _buildActionButton(
                icon: Icons.bookmark_border,
                label: '',
                onTap: widget.onSave,
              ),
            ],
          ),
        ),

        // Product Button - Large button ABOVE description
        if (widget.post.linkedProductId != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 100,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  context.push('/product/${widget.post.linkedProductId}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Перейти к товару',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Bottom Info - BELOW product button
        Positioned(
          left: 12,
          right: 80,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username and Follow button
              Row(
                children: [
                  Text(
                    '@${widget.post.ownerName.isNotEmpty ? widget.post.ownerName : 'unknown'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _isLoadingFollow ? null : _toggleFollow,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: _isFollowing ? Colors.grey : Colors.white,
                        width: 2,
                      ),
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      backgroundColor: Colors.transparent,
                    ),
                    child: Text(
                      _isFollowing ? 'Подписан' : 'Подписаться',
                      style: TextStyle(
                        color: _isFollowing ? Colors.grey : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              if (widget.post.text != null && widget.post.text!.isNotEmpty)
                Text(
                  widget.post.text!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

// Grid View Widget for Interesting Tab
class InterestingGridView extends StatelessWidget {
  final List<PostModel> posts;
  final Future<void> Function() onRefresh;

  const InterestingGridView({
    super.key,
    required this.posts,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 130),
      child: RefreshIndicator(
        onRefresh: onRefresh,
        backgroundColor: Colors.grey[900],
        color: Colors.white,
        displacement: 40,
        strokeWidth: 2.5,
        child: GridView.builder(
          padding: const EdgeInsets.all(2),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: 0.75,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final firstMedia = post.media.isNotEmpty ? post.media.first : null;

            return GestureDetector(
              onTap: () {
                // Open vertical feed starting from this post
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostsViewerPage(
                      posts: posts,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                ),
                child: firstMedia != null && firstMedia.url.isNotEmpty
                    ? Image.network(
                        firstMedia.url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[850],
                            child: Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 40,
                                color: Colors.white38,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[850],
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white54,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[850],
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 40,
                            color: Colors.white38,
                          ),
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
