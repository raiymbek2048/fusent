import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:fusent_mobile/features/feed/data/models/post_model.dart';

/// Страница для просмотра постов в вертикальном формате (как TikTok)
class PostsViewerPage extends StatefulWidget {
  final List<PostModel> posts;
  final int initialIndex;

  const PostsViewerPage({
    super.key,
    required this.posts,
    this.initialIndex = 0,
  });

  @override
  State<PostsViewerPage> createState() => _PostsViewerPageState();
}

class _PostsViewerPageState extends State<PostsViewerPage> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vertical feed
          PageView.builder(
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
              return PostViewerItem(
                post: post,
                isActive: index == _currentPage,
              );
            },
          ),

          // Back button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Отдельный элемент для отображения одного поста
class PostViewerItem extends StatefulWidget {
  final PostModel post;
  final bool isActive;

  const PostViewerItem({
    super.key,
    required this.post,
    required this.isActive,
  });

  @override
  State<PostViewerItem> createState() => _PostViewerItemState();
}

class _PostViewerItemState extends State<PostViewerItem> {
  final ApiClient _apiClient = ApiClient();
  bool _isFollowing = false;
  bool _isLoadingFollow = false;
  late bool _isLiked;
  late int _likesCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLikedByCurrentUser;
    _likesCount = widget.post.likesCount;
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
      } else {
        await _apiClient.followTarget(
          targetType: 'MERCHANT',
          targetId: widget.post.ownerId!,
        );
        setState(() {
          _isFollowing = true;
        });
      }
    } catch (e) {
      debugPrint('Error toggling follow: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFollow = false;
        });
      }
    }
  }

  Future<void> _toggleLike() async {
    final wasLiked = _isLiked;
    final oldCount = _likesCount;

    // Optimistic update
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });

    try {
      if (wasLiked) {
        await _apiClient.unlikePost(widget.post.id);
      } else {
        await _apiClient.likePost(widget.post.id);
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
      // Revert on error
      if (mounted) {
        setState(() {
          _isLiked = wasLiked;
          _likesCount = oldCount;
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
        // Background Image
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

        // Gradient overlay
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
                  Colors.black.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Right side actions
        Positioned(
          right: 12,
          bottom: 120,
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
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.surface,
                    child: Text(
                      widget.post.ownerName.isNotEmpty
                          ? widget.post.ownerName[0].toUpperCase()
                          : '?',
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
                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                label: _formatNumber(_likesCount),
                color: _isLiked ? Colors.red : Colors.white,
                onTap: _toggleLike,
              ),
              const SizedBox(height: 24),

              // Comment Button
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: _formatNumber(widget.post.commentsCount),
                onTap: () {
                  // TODO: Open comments
                },
              ),
              const SizedBox(height: 24),

              // Share Button
              _buildActionButton(
                icon: Icons.send,
                label: 'Поделиться',
                onTap: () {
                  // TODO: Share
                },
              ),
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
                  if (!_isFollowing)
                    OutlinedButton(
                      onPressed: _isLoadingFollow ? null : _toggleFollow,
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
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
}
