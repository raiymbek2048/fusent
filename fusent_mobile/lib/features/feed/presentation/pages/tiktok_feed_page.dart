import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/core/di/injection_container.dart';
import 'package:fusent_mobile/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:fusent_mobile/features/feed/presentation/bloc/feed_event.dart';
import 'package:fusent_mobile/features/feed/presentation/bloc/feed_state.dart';
import 'package:fusent_mobile/features/feed/data/models/post_model.dart';
import 'package:fusent_mobile/features/feed/presentation/widgets/stories_list.dart';
import 'package:fusent_mobile/features/feed/presentation/widgets/comments_bottom_sheet.dart';

class TikTokFeedPage extends StatefulWidget {
  const TikTokFeedPage({super.key});

  @override
  State<TikTokFeedPage> createState() => _TikTokFeedPageState();
}

class _TikTokFeedPageState extends State<TikTokFeedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FeedBloc _followingBloc;
  late FeedBloc _trendsBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Create separate BLoC instances for each tab
    _followingBloc = sl<FeedBloc>();
    _trendsBloc = sl<FeedBloc>();

    // Load initial data for trending feed (default tab)
    _trendsBloc.add(const LoadPublicFeed(refresh: true));

    // Listen to tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        if (_tabController.index == 0) {
          // Подписки
          if (_followingBloc.state is FeedInitial) {
            _followingBloc.add(const LoadFollowingFeed(refresh: true));
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
              // Подписки feed
              BlocProvider.value(
                value: _followingBloc,
                child: _buildVerticalFeed(_followingBloc, isFollowing: true),
              ),
              // Тренды feed
              BlocProvider.value(
                value: _trendsBloc,
                child: _buildVerticalFeed(_trendsBloc, isFollowing: false),
              ),
            ],
          ),

          // Top UI Overlay
          _buildTopBar(),

          // Stories List
          Positioned(
            top: 110,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const StoriesList(),
            ),
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // FUCENT Logo
              Text(
                'FUCENT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),

              // Tab Switcher
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  dividerColor: Colors.transparent,
                  isScrollable: true,
                  tabAlignment: TabAlignment.center,
                  tabs: const [
                    Tab(text: 'Подписки'),
                    Tab(text: 'Тренды'),
                  ],
                ),
              ),

              // Search icon
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                onPressed: () {
                  context.push('/search');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalFeed(FeedBloc bloc, {required bool isFollowing}) {
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
                    if (isFollowing) {
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
                    isFollowing
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
              bloc.add(SharePostEvent(postId: postId));
            },
            onSave: (postId, isSaved) {
              bloc.add(SavePostEvent(postId: postId, isSaved: isSaved));
            },
            onRefresh: () {
              if (isFollowing) {
                bloc.add(const LoadFollowingFeed(refresh: true));
              } else {
                bloc.add(const LoadPublicFeed(refresh: true));
              }
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
  final Function(String, bool) onLike;
  final Function(String, int) onComment;
  final Function(String) onShare;
  final Function(String, bool) onSave;
  final VoidCallback onRefresh;

  const TikTokVerticalFeed({
    super.key,
    required this.posts,
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
    return PageView.builder(
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
    );
  }
}

// Individual Post Item
class PostFeedItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final firstMedia = post.media.isNotEmpty ? post.media.first : null;

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
          bottom: 120,
          child: Column(
            children: [
              // Profile Avatar
              GestureDetector(
                onTap: () {
                  if (post.ownerId != null) {
                    context.push('/shop/${post.ownerId}?shopName=${Uri.encodeComponent(post.ownerName)}');
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.surface,
                    child: Text(
                      post.ownerName[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Like Button
              _buildActionButton(
                icon: post.isLikedByCurrentUser
                    ? Icons.favorite
                    : Icons.favorite_border,
                label: _formatNumber(post.likesCount),
                color:
                    post.isLikedByCurrentUser ? Colors.red : Colors.white,
                onTap: onLike,
              ),
              const SizedBox(height: 24),

              // Comment Button
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: _formatNumber(post.commentsCount),
                onTap: onComment,
              ),
              const SizedBox(height: 24),

              // Share Button
              _buildActionButton(
                icon: Icons.send,
                label: 'Поделиться',
                onTap: () {
                  _showShareSheet(context);
                  onShare();
                },
              ),
              const SizedBox(height: 24),

              // Save/Bookmark Button
              _buildActionButton(
                icon: Icons.bookmark_border,
                label: '',
                onTap: onSave,
              ),

              // Linked Product indicator
              if (post.linkedProductId != null) ...[
                const SizedBox(height: 24),
                _buildActionButton(
                  icon: Icons.shopping_bag_outlined,
                  label: '',
                  color: AppColors.primary,
                  onTap: () {
                    context.push('/product/${post.linkedProductId}');
                  },
                ),
              ],
            ],
          ),
        ),

        // Bottom Info
        Positioned(
          left: 12,
          right: 80,
          bottom: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username and Follow button
              Row(
                children: [
                  Text(
                    '@${post.ownerName}',
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
                    onPressed: () {
                      // TODO: Follow shop
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      backgroundColor: Colors.transparent,
                    ),
                    child: const Text(
                      'Подписаться',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              if (post.text != null && post.text!.isNotEmpty)
                Text(
                  post.text!,
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
            padding: const EdgeInsets.all(10),
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
            child: Icon(icon, color: color, size: 28),
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

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            const Text(
              'Поделиться',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Share Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: Icons.copy,
                  label: 'Копировать',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ссылка скопирована'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _buildShareOption(
                  icon: Icons.telegram,
                  label: 'Telegram',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Share via Telegram
                  },
                ),
                _buildShareOption(
                  icon: Icons.message,
                  label: 'SMS',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Share via SMS
                  },
                ),
                _buildShareOption(
                  icon: Icons.more_horiz,
                  label: 'Еще',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Show system share sheet
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
