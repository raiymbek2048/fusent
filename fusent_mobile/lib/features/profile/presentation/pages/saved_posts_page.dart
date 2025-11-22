import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:fusent_mobile/features/feed/data/models/post_model.dart';
import 'package:fusent_mobile/features/feed/presentation/pages/posts_viewer_page.dart';

class SavedPostsPage extends StatefulWidget {
  const SavedPostsPage({super.key});

  @override
  State<SavedPostsPage> createState() => _SavedPostsPageState();
}

class _SavedPostsPageState extends State<SavedPostsPage> {
  final ApiClient _apiClient = ApiClient();
  List<PostModel> _savedPosts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSavedPosts();
  }

  Future<void> _loadSavedPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiClient.getSavedPosts();
      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      final List<dynamic> content = data['content'] as List<dynamic>;

      setState(() {
        _savedPosts = content
            .map((item) {
              // Each item is a SavedPostResponse with a 'post' field
              final postData = item['post'] as Map<String, dynamic>;
              return PostModel.fromJson(postData);
            })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки сохраненных постов: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Сохраненные посты'),
        backgroundColor: AppColors.background,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSavedPosts,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (_savedPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Нет сохраненных постов',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSavedPosts,
      child: GridView.builder(
        padding: const EdgeInsets.all(2),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          childAspectRatio: 1,
        ),
        itemCount: _savedPosts.length,
        itemBuilder: (context, index) {
          final post = _savedPosts[index];
          final firstMedia = post.media.isNotEmpty ? post.media.first : null;

          return GestureDetector(
            onTap: () {
              // Navigate to posts viewer starting at tapped post
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PostsViewerPage(
                    posts: _savedPosts,
                    initialIndex: index,
                  ),
                ),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                firstMedia?.url != null && firstMedia!.url.isNotEmpty
                    ? Image.network(
                        firstMedia.url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.surface,
                            child: Icon(
                              Icons.image,
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: AppColors.surface,
                        child: Icon(
                          Icons.image,
                          color: AppColors.textSecondary,
                        ),
                      ),

                // Video indicator
                if (firstMedia != null && firstMedia.mediaType.name == 'VIDEO')
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 24,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),

                // Multiple images indicator
                if (post.media.length > 1)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.collections,
                      color: Colors.white,
                      size: 20,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),

                // Likes count overlay (bottom left)
                Positioned(
                  bottom: 4,
                  left: 4,
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 16,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatNumber(post.likesCount),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
