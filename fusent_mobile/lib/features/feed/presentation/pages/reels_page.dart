import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:fusent_mobile/features/feed/data/models/post_model.dart';

class ReelsPage extends StatefulWidget {
  final String? initialPostId;
  final String initialTab;

  const ReelsPage({
    super.key,
    this.initialPostId,
    this.initialTab = 'trending',
  });

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  final ApiClient _apiClient = ApiClient();
  late PageController _pageController;
  int _currentPage = 0;
  List<ReelItem> _reels = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadReels();
  }

  Future<void> _loadReels() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiClient.getFeed(type: 'public', size: 50);

      if (mounted && response.statusCode == 200) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final List<dynamic> content = data['content'] as List<dynamic>? ?? [];

        final List<PostModel> posts = content
            .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Filter for posts with video media
        final videoPosts = posts.where((post) {
          return post.media.any((media) => media.mediaType == MediaType.VIDEO);
        }).toList();

        setState(() {
          _reels = videoPosts.map((post) {
            final videoMedia = post.media.firstWhere(
              (media) => media.mediaType == MediaType.VIDEO,
            );

            return ReelItem(
              postId: post.id,
              videoUrl: videoMedia.url,
              username: post.ownerName,
              description: post.text ?? '',
              likes: post.likesCount,
              comments: post.commentsCount,
              shares: post.sharesCount,
              avatarUrl: '',
              isLiked: post.isLikedByCurrentUser,
            );
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading reels: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
      body: _isLoading && _reels.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _reels.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.videocam_off,
                        size: 80,
                        color: Colors.white54,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Нет видео',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: _reels.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return ReelVideoPlayer(
                      reel: _reels[index],
                      isActive: index == _currentPage,
                      onLikeToggle: (postId, isLiked) => _toggleLike(postId, isLiked, index),
                    );
                  },
                ),
    );
  }

  Future<void> _toggleLike(String postId, bool currentlyLiked, int index) async {
    // Optimistic update
    setState(() {
      _reels[index].isLiked = !currentlyLiked;
      _reels[index].likes += currentlyLiked ? -1 : 1;
    });

    try {
      if (currentlyLiked) {
        await _apiClient.unlikePost(postId);
      } else {
        await _apiClient.likePost(postId);
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
      // Revert on error
      if (mounted) {
        setState(() {
          _reels[index].isLiked = currentlyLiked;
          _reels[index].likes += currentlyLiked ? 1 : -1;
        });
      }
    }
  }
}

class ReelVideoPlayer extends StatefulWidget {
  final ReelItem reel;
  final bool isActive;
  final Function(String, bool) onLikeToggle;

  const ReelVideoPlayer({
    super.key,
    required this.reel,
    required this.isActive,
    required this.onLikeToggle,
  });

  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showPlayPause = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.reel.videoUrl),
    );

    try {
      await _controller.initialize();
      setState(() {
        _isInitialized = true;
      });
      if (widget.isActive) {
        _controller.play();
        _controller.setLooping(true);
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void didUpdateWidget(ReelVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.play();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _showPlayPause = true;
      } else {
        _controller.play();
        _showPlayPause = true;
      }
    });

    // Hide play/pause icon after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showPlayPause = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player
        _isInitialized
            ? GestureDetector(
                onTap: _togglePlayPause,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),

        // Play/Pause Indicator
        if (_showPlayPause)
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),

        // Right Side Actions
        Positioned(
          right: 12,
          bottom: 100,
          child: Column(
            children: [
              // Profile Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(widget.reel.avatarUrl),
                ),
              ),
              const SizedBox(height: 24),

              // Like Button
              _buildActionButton(
                icon: widget.reel.isLiked ? Icons.favorite : Icons.favorite_border,
                label: _formatNumber(widget.reel.likes),
                color: widget.reel.isLiked ? Colors.red : Colors.white,
                onTap: () {
                  widget.onLikeToggle(widget.reel.postId, widget.reel.isLiked);
                },
              ),
              const SizedBox(height: 24),

              // Comment Button
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: _formatNumber(widget.reel.comments),
                onTap: () {
                  // TODO: Open comments
                },
              ),
              const SizedBox(height: 24),

              // Share Button
              _buildActionButton(
                icon: Icons.send,
                label: _formatNumber(widget.reel.shares),
                onTap: () {
                  // TODO: Share
                },
              ),
              const SizedBox(height: 24),

              // More Button
              _buildActionButton(
                icon: Icons.more_vert,
                label: '',
                onTap: () {
                  _showBottomSheet(context);
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
              // Username
              Row(
                children: [
                  Text(
                    '@${widget.reel.username}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text(
                      'Подписаться',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                widget.reel.description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                maxLines: 2,
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
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
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

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.bookmark_border),
                title: const Text('Сохранить'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.person_add_outlined),
                title: const Text('Подписаться'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Скопировать ссылку'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.report_outlined, color: AppColors.error),
                title: const Text(
                  'Пожаловаться',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ReelItem {
  final String postId;
  final String videoUrl;
  final String username;
  final String description;
  int likes;
  final int comments;
  final int shares;
  final String avatarUrl;
  bool isLiked;

  ReelItem({
    required this.postId,
    required this.videoUrl,
    required this.username,
    required this.description,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.avatarUrl,
    required this.isLiked,
  });
}
