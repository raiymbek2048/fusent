import 'package:flutter/material.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:fusent_mobile/features/feed/presentation/pages/story_viewer_page.dart';

class StoriesList extends StatefulWidget {
  const StoriesList({super.key});

  @override
  State<StoriesList> createState() => _StoriesListState();
}

class _StoriesListState extends State<StoriesList> {
  final ApiClient _apiClient = ApiClient();
  List<Map<String, dynamic>> _stories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiClient.getStories();

      if (mounted && response.statusCode == 200) {
        final List<dynamic> stories = response.data as List<dynamic>;

        setState(() {
          _stories = stories.map((story) {
            final storyMap = story as Map<String, dynamic>;
            final owner = storyMap['owner'] as Map<String, dynamic>?;

            return {
              'id': storyMap['id'],
              'username': owner?['fullName'] ?? owner?['username'] ?? 'User',
              'avatarUrl': owner?['avatarUrl'] ?? '',
              'hasViewed': storyMap['hasViewed'] ?? false,
              'mediaUrl': storyMap['mediaUrl'],
            };
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading stories: $e');
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
    if (_isLoading && _stories.isEmpty) {
      return Container(
        height: 120,
        color: AppColors.background,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: 120,
      color: AppColors.background,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: _stories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddStoryButton();
          }
          final story = _stories[index - 1];
          return _buildStoryItem(
            context,
            storyId: story['id'] as String,
            username: story['username'] as String,
            avatarUrl: story['avatarUrl'] as String,
            hasNewStory: !(story['hasViewed'] as bool),
          );
        },
      ),
    );
  }

  Widget _buildAddStoryButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: const Icon(
              Icons.add,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ваша',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStoryItem(
    BuildContext context, {
    required String storyId,
    required String username,
    required String avatarUrl,
    required bool hasNewStory,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () async {
          // Mark story as viewed
          try {
            await _apiClient.viewStory(storyId);
          } catch (e) {
            debugPrint('Error marking story as viewed: $e');
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StoryViewerPage(
                initialStoryIndex: 0,
              ),
            ),
          );
        },
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasNewStory
                    ? LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                border: !hasNewStory
                    ? Border.all(color: AppColors.border, width: 2)
                    : null,
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                ),
                padding: const EdgeInsets.all(2),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.surface,
                  backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl.isEmpty
                      ? const Icon(Icons.person, color: AppColors.textSecondary)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 72,
              child: Text(
                username,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
