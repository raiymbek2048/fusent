import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fusent_mobile/core/constants/app_colors.dart';
import 'package:fusent_mobile/core/di/injection_container.dart';
import 'package:fusent_mobile/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:fusent_mobile/features/feed/presentation/bloc/feed_event.dart';
import 'package:fusent_mobile/features/feed/presentation/bloc/feed_state.dart';
import 'package:fusent_mobile/features/feed/presentation/widgets/stories_list.dart';
import 'package:fusent_mobile/features/feed/presentation/widgets/post_card.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FeedBloc _followingBloc;
  late FeedBloc _exploreBloc;
  late FeedBloc _trendsBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Create separate BLoC instances for each tab
    _followingBloc = sl<FeedBloc>();
    _exploreBloc = sl<FeedBloc>();
    _trendsBloc = sl<FeedBloc>();

    // Load initial data for following feed
    _followingBloc.add(const LoadFollowingFeed(refresh: true));

    // Listen to tab changes to load data
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        switch (_tabController.index) {
          case 0: // Подписки
            if (_followingBloc.state is FeedInitial) {
              _followingBloc.add(const LoadFollowingFeed(refresh: true));
            }
            break;
          case 1: // Интересное
            if (_exploreBloc.state is FeedInitial) {
              _exploreBloc.add(const LoadPublicFeed(refresh: true));
            }
            break;
          case 2: // Тренды
            if (_trendsBloc.state is FeedInitial) {
              _trendsBloc.add(const LoadTrendingFeed(refresh: true));
            }
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _followingBloc.close();
    _exploreBloc.close();
    _trendsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // App Bar with Tabs
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: AppColors.background,
                elevation: 0,
                title: const Text(
                  'FUCENT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {
                      context.push('/favorites');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      context.push('/notifications');
                    },
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48 + 120), // Tab bar + Stories
                  child: Column(
                    children: [
                      // Tab Bar
                      Container(
                        color: AppColors.background,
                        child: TabBar(
                          controller: _tabController,
                          indicatorColor: AppColors.primary,
                          indicatorWeight: 2,
                          labelColor: AppColors.textPrimary,
                          unselectedLabelColor: AppColors.textSecondary,
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          tabs: const [
                            Tab(text: 'Подписки'),
                            Tab(text: 'Интересное'),
                            Tab(text: 'Тренды'),
                          ],
                        ),
                      ),

                      // Stories List
                      const StoriesList(),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // Подписки - вертикальная лента
              BlocProvider.value(
                value: _followingBloc,
                child: _buildVerticalFeed(_followingBloc, isFollowing: true),
              ),
              // Интересное - grid 3 колонки
              BlocProvider.value(
                value: _exploreBloc,
                child: _buildGridFeed(_exploreBloc),
              ),
              // Тренды - вертикальная лента
              BlocProvider.value(
                value: _trendsBloc,
                child: _buildVerticalFeed(_trendsBloc, isFollowing: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Вертикальная лента как в Instagram (для Подписки и Тренды)
  Widget _buildVerticalFeed(FeedBloc bloc, {required bool isFollowing}) {
    return BlocBuilder<FeedBloc, FeedState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is FeedLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is FeedError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Ошибка загрузки',
                  style: TextStyle(color: AppColors.error),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (isFollowing) {
                      bloc.add(const LoadFollowingFeed(refresh: true));
                    } else if (_tabController.index == 2) {
                      bloc.add(const LoadTrendingFeed(refresh: true));
                    } else {
                      bloc.add(const LoadPublicFeed(refresh: true));
                    }
                  },
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

          return RefreshIndicator(
            onRefresh: () async {
              if (isFollowing) {
                bloc.add(const LoadFollowingFeed(refresh: true));
              } else if (_tabController.index == 2) {
                bloc.add(const LoadTrendingFeed(refresh: true));
              } else {
                bloc.add(const LoadPublicFeed(refresh: true));
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: state.posts.length,
              itemBuilder: (context, index) {
                final post = state.posts[index];
                final firstMedia = post.media.isNotEmpty ? post.media.first : null;

                return PostCard(
                  username: post.ownerName,
                  userAvatar: '',
                  postImage: firstMedia?.url ?? '',
                  description: post.text ?? '',
                  likes: post.likesCount,
                  comments: post.commentsCount,
                  isLiked: post.isLikedByCurrentUser,
                  isSaved: post.isSavedByCurrentUser,
                  linkedProductId: post.linkedProductId,
                  onLike: () {
                    bloc.add(LikePostEvent(
                      postId: post.id,
                      isLiked: post.isLikedByCurrentUser,
                    ));
                  },
                  onComment: () {
                    // TODO: Open comments
                  },
                  onShare: () {
                    bloc.add(SharePostEvent(postId: post.id));
                  },
                  onSave: () {
                    bloc.add(SavePostEvent(postId: post.id, isSaved: post.isSavedByCurrentUser));
                  },
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // Grid 3 колонки как в Instagram Explore
  Widget _buildGridFeed(FeedBloc bloc) {
    return BlocBuilder<FeedBloc, FeedState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is FeedLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is FeedError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Ошибка загрузки',
                  style: TextStyle(color: AppColors.error),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    bloc.add(const LoadPublicFeed(refresh: true));
                  },
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
                  Icon(Icons.explore_outlined, size: 64, color: AppColors.textSecondary),
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

          return RefreshIndicator(
            onRefresh: () async {
              bloc.add(const LoadPublicFeed(refresh: true));
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                childAspectRatio: 1,
              ),
              itemCount: state.posts.length,
              itemBuilder: (context, index) {
                final post = state.posts[index];
                final firstMedia = post.media.isNotEmpty ? post.media.first : null;

                return GestureDetector(
                  onTap: () {
                    // TODO: Open post detail
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
                    ],
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
