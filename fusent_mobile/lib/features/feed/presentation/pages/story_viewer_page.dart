import 'package:flutter/material.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'dart:async';

class StoryViewerPage extends StatefulWidget {
  final int initialStoryIndex;

  const StoryViewerPage({
    super.key,
    this.initialStoryIndex = 0,
  });

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage> {
  late PageController _pageController;
  int _currentUserStoryIndex = 0;

  // Mock data - replace with real data from backend
  final List<UserStory> _userStories = [
    UserStory(
      username: 'Fashion Store',
      avatarUrl: 'https://via.placeholder.com/150',
      stories: [
        Story(
          mediaUrl: 'https://via.placeholder.com/600',
          mediaType: StoryMediaType.image,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Story(
          mediaUrl: 'https://via.placeholder.com/600/FF0000',
          mediaType: StoryMediaType.image,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ],
    ),
    UserStory(
      username: 'Tech Paradise',
      avatarUrl: 'https://via.placeholder.com/150',
      stories: [
        Story(
          mediaUrl: 'https://via.placeholder.com/600/00FF00',
          mediaType: StoryMediaType.image,
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ],
    ),
    UserStory(
      username: 'Book World',
      avatarUrl: 'https://via.placeholder.com/150',
      stories: [
        Story(
          mediaUrl: 'https://via.placeholder.com/600/0000FF',
          mediaType: StoryMediaType.image,
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        Story(
          mediaUrl: 'https://via.placeholder.com/600/FFFF00',
          mediaType: StoryMediaType.image,
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
        Story(
          mediaUrl: 'https://via.placeholder.com/600/FF00FF',
          mediaType: StoryMediaType.image,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentUserStoryIndex = widget.initialStoryIndex;
    _pageController = PageController(initialPage: widget.initialStoryIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextUserStory() {
    if (_currentUserStoryIndex < _userStories.length - 1) {
      setState(() {
        _currentUserStoryIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _goToPreviousUserStory() {
    if (_currentUserStoryIndex > 0) {
      setState(() {
        _currentUserStoryIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: _userStories.length,
        onPageChanged: (index) {
          setState(() {
            _currentUserStoryIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return StoryViewWidget(
            userStory: _userStories[index],
            onStoryComplete: _goToNextUserStory,
            onStoryPrevious: _goToPreviousUserStory,
            onClose: () => Navigator.pop(context),
          );
        },
      ),
    );
  }
}

class StoryViewWidget extends StatefulWidget {
  final UserStory userStory;
  final VoidCallback onStoryComplete;
  final VoidCallback onStoryPrevious;
  final VoidCallback onClose;

  const StoryViewWidget({
    super.key,
    required this.userStory,
    required this.onStoryComplete,
    required this.onStoryPrevious,
    required this.onClose,
  });

  @override
  State<StoryViewWidget> createState() => _StoryViewWidgetState();
}

class _StoryViewWidgetState extends State<StoryViewWidget> {
  int _currentStoryIndex = 0;
  Timer? _storyTimer;
  double _progress = 0.0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _startStory();
  }

  @override
  void dispose() {
    _storyTimer?.cancel();
    super.dispose();
  }

  void _startStory() {
    _storyTimer?.cancel();
    _progress = 0.0;

    const duration = Duration(seconds: 5); // Story duration
    const interval = Duration(milliseconds: 50);
    final steps = duration.inMilliseconds / interval.inMilliseconds;

    _storyTimer = Timer.periodic(interval, (timer) {
      if (!_isPaused) {
        setState(() {
          _progress += 1 / steps;
          if (_progress >= 1.0) {
            _nextStory();
          }
        });
      }
    });
  }

  void _nextStory() {
    _storyTimer?.cancel();
    if (_currentStoryIndex < widget.userStory.stories.length - 1) {
      setState(() {
        _currentStoryIndex++;
      });
      _startStory();
    } else {
      widget.onStoryComplete();
    }
  }

  void _previousStory() {
    _storyTimer?.cancel();
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
      });
      _startStory();
    } else {
      widget.onStoryPrevious();
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.userStory.stories[_currentStoryIndex];

    return GestureDetector(
      onTapDown: (details) {
        _togglePause();
      },
      onTapUp: (details) {
        _togglePause();
        final screenWidth = MediaQuery.of(context).size.width;
        if (details.globalPosition.dx < screenWidth / 3) {
          _previousStory();
        } else if (details.globalPosition.dx > 2 * screenWidth / 3) {
          _nextStory();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Story Content
          if (story.mediaType == StoryMediaType.image)
            Image.network(
              story.mediaUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.surface,
                  child: const Center(
                    child: Icon(
                      Icons.image,
                      size: 100,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),

          // Gradient overlay at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
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
            ),
          ),

          // Progress bars
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            right: 8,
            child: Row(
              children: List.generate(
                widget.userStory.stories.length,
                (index) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: LinearProgressIndicator(
                      value: index < _currentStoryIndex
                          ? 1.0
                          : (index == _currentStoryIndex ? _progress : 0.0),
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Header (user info)
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 8,
            right: 8,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surface,
                  backgroundImage: NetworkImage(widget.userStory.avatarUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userStory.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatTimestamp(story.timestamp),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          shadows: const [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    _showOptionsBottomSheet(context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          // Pause indicator
          if (_isPaused)
            const Center(
              child: Icon(
                Icons.pause_circle_filled,
                color: Colors.white,
                size: 80,
              ),
            ),

          // Reply bar at bottom
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'Отправить сообщение...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.white),
                  onPressed: () {
                    // TODO: Like story
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    // TODO: Share story
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч назад';
    } else {
      return '${difference.inDays} д назад';
    }
  }

  void _showOptionsBottomSheet(BuildContext context) {
    _togglePause(); // Pause story while showing options
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
                onTap: () {
                  Navigator.pop(context);
                  _togglePause();
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add_outlined),
                title: const Text('Подписаться'),
                onTap: () {
                  Navigator.pop(context);
                  _togglePause();
                },
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Скопировать ссылку'),
                onTap: () {
                  Navigator.pop(context);
                  _togglePause();
                },
              ),
              ListTile(
                leading: const Icon(Icons.report_outlined, color: AppColors.error),
                title: const Text(
                  'Пожаловаться',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _togglePause();
                },
              ),
            ],
          ),
        );
      },
    ).then((_) {
      // Resume story when bottom sheet is dismissed
      if (_isPaused) {
        _togglePause();
      }
    });
  }
}

// Models
enum StoryMediaType { image, video }

class Story {
  final String mediaUrl;
  final StoryMediaType mediaType;
  final DateTime timestamp;

  Story({
    required this.mediaUrl,
    required this.mediaType,
    required this.timestamp,
  });
}

class UserStory {
  final String username;
  final String avatarUrl;
  final List<Story> stories;

  UserStory({
    required this.username,
    required this.avatarUrl,
    required this.stories,
  });
}
