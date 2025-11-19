import 'package:flutter/material.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/features/feed/data/models/post_model.dart';
import 'package:fusent_mobile/features/feed/presentation/widgets/post_card.dart';

/// Вертикальная swipeable лента постов (как в TikTok/Reels)
/// Swipe вверх/вниз для переключения между постами
class SwipeableFeed extends StatefulWidget {
  final List<PostModel> posts;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoadMore;
  final Function(String postId, bool isLiked)? onLike;
  final Function(String postId)? onComment;
  final Function(String postId)? onShare;
  final Function(String postId, bool isSaved)? onSave;

  const SwipeableFeed({
    super.key,
    required this.posts,
    this.onRefresh,
    this.onLoadMore,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
  });

  @override
  State<SwipeableFeed> createState() => _SwipeableFeedState();
}

class _SwipeableFeedState extends State<SwipeableFeed> {
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
    if (page >= widget.posts.length - 3) {
      widget.onLoadMore?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Пока нет постов',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      onPageChanged: _onPageChanged,
      itemCount: widget.posts.length,
      itemBuilder: (context, index) {
        final post = widget.posts[index];
        final mediaUrls = post.media.map((m) => m.url).toList();

        return PostCard(
          username: post.ownerName,
          userAvatar: '',
          postImages: mediaUrls.isNotEmpty ? mediaUrls : null,
          postImage: mediaUrls.isNotEmpty ? mediaUrls.first : '',
          description: post.text ?? '',
          likes: post.likesCount,
          comments: post.commentsCount,
          isLiked: post.isLikedByCurrentUser,
          linkedProductId: post.linkedProductId,
          onLike: () {
            widget.onLike?.call(post.id, post.isLikedByCurrentUser);
          },
          onComment: () {
            widget.onComment?.call(post.id);
          },
          onShare: () {
            widget.onShare?.call(post.id);
          },
          onSave: () {
            widget.onSave?.call(post.id, false); // TODO: track saved state
          },
        );
      },
    );
  }
}
