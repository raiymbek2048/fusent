import 'package:flutter/material.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/features/feed/data/models/post_model.dart';
import 'package:go_router/go_router.dart';

/// Полноэкранная вертикальная лента как в TikTok/Reels
/// Каждый пост занимает весь экран, swipe вверх/вниз для переключения
class FullscreenSwipeableFeed extends StatefulWidget {
  final List<PostModel> posts;
  final Function(String postId, bool isLiked)? onLike;
  final Function(String postId)? onComment;
  final Function(String postId)? onShare;
  final VoidCallback? onLoadMore;

  const FullscreenSwipeableFeed({
    super.key,
    required this.posts,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onLoadMore,
  });

  @override
  State<FullscreenSwipeableFeed> createState() => _FullscreenSwipeableFeedState();
}

class _FullscreenSwipeableFeedState extends State<FullscreenSwipeableFeed> {
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

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    // Load more when reaching near the end
    if (page >= widget.posts.length - 2) {
      widget.onLoadMore?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.posts.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              Text(
                'Пока нет постов',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: _onPageChanged,
        itemCount: widget.posts.length,
        itemBuilder: (context, index) {
          final post = widget.posts[index];
          return _FullscreenPostItem(
            post: post,
            onLike: () => widget.onLike?.call(post.id, post.isLikedByCurrentUser),
            onComment: () => widget.onComment?.call(post.id),
            onShare: () => widget.onShare?.call(post.id),
          );
        },
      ),
    );
  }
}

class _FullscreenPostItem extends StatefulWidget {
  final PostModel post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const _FullscreenPostItem({
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
  });

  @override
  State<_FullscreenPostItem> createState() => _FullscreenPostItemState();
}

class _FullscreenPostItemState extends State<_FullscreenPostItem> {
  late PageController _imageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaUrls = widget.post.media.map((m) => m.url).toList();
    final hasMultipleImages = mediaUrls.length > 1;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image/Video
        if (mediaUrls.isNotEmpty)
          hasMultipleImages
              ? PageView.builder(
                  controller: _imageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  itemCount: mediaUrls.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      mediaUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.surface,
                          child: const Center(
                            child: Icon(Icons.image, size: 64, color: AppColors.textSecondary),
                          ),
                        );
                      },
                    );
                  },
                )
              : Image.network(
                  mediaUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.surface,
                      child: const Center(
                        child: Icon(Icons.image, size: 64, color: AppColors.textSecondary),
                      ),
                    );
                  },
                )
        else
          Container(
            color: AppColors.surface,
            child: const Center(
              child: Icon(Icons.image, size: 64, color: AppColors.textSecondary),
            ),
          ),

        // Gradient overlay for better text readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // Top Bar (Back button, page indicator)
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                    // Image counter for multiple images
                    if (hasMultipleImages)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/${mediaUrls.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Right Side Actions (like, comment, share)
        Positioned(
          right: 12,
          bottom: 120,
          child: Column(
            children: [
              // Like
              _ActionButton(
                icon: widget.post.isLikedByCurrentUser ? Icons.favorite : Icons.favorite_border,
                count: widget.post.likesCount,
                color: widget.post.isLikedByCurrentUser ? Colors.red : Colors.white,
                onTap: widget.onLike,
              ),
              const SizedBox(height: 20),
              // Comment
              _ActionButton(
                icon: Icons.chat_bubble_outline,
                count: widget.post.commentsCount,
                color: Colors.white,
                onTap: widget.onComment,
              ),
              const SizedBox(height: 20),
              // Share
              _ActionButton(
                icon: Icons.send_outlined,
                count: 0,
                color: Colors.white,
                onTap: widget.onShare,
              ),
              const SizedBox(height: 20),
              // Product link (if available)
              if (widget.post.linkedProductId != null)
                GestureDetector(
                  onTap: () {
                    context.push('/product/${widget.post.linkedProductId}');
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Bottom Info (username, description)
        Positioned(
          left: 12,
          right: 80,
          bottom: 24,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Username
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.surface,
                      child: const Icon(Icons.person, color: AppColors.textSecondary, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.post.ownerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(color: Colors.black, blurRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Description
                if (widget.post.text != null && widget.post.text!.isNotEmpty)
                  Text(
                    widget.post.text!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      shadows: [
                        Shadow(color: Colors.black, blurRadius: 4),
                      ],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),

        // Dot indicators for multiple images
        if (hasMultipleImages)
          Positioned(
            bottom: 100,
            left: 0,
            right: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                mediaUrls.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.count,
    required this.color,
    this.onTap,
  });

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          if (count > 0) ...[
            const SizedBox(height: 4),
            Text(
              _formatCount(count),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(color: Colors.black, blurRadius: 4),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
