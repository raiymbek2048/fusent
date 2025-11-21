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
              'isLive': storyMap['isLive'] ?? false,
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
        height: 90,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: 90,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            isLive: story['isLive'] as bool,
          );
        },
      ),
    );
  }

  Widget _buildAddStoryButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[800]!, width: 1.5),
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          const SizedBox(
            width: 56,
            child: Text(
              'Ваша',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white70,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
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
    required bool isLive,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isLive
                        ? const LinearGradient(
                            colors: [Colors.red, Colors.pink],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : hasNewStory
                            ? LinearGradient(
                                colors: [AppColors.primary, AppColors.secondary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                    border: !hasNewStory && !isLive
                        ? Border.all(color: Colors.grey[800]!, width: 1.5)
                        : null,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey[900],
                      backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl.isEmpty
                          ? const Icon(Icons.person, color: Colors.white54, size: 20)
                          : null,
                    ),
                  ),
                ),
                // LIVE badge
                if (isLive)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 56,
              child: Text(
                username,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
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
