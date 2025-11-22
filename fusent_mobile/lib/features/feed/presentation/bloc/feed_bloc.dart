import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fusent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:fusent_mobile/features/feed/presentation/bloc/feed_event.dart';
import 'package:fusent_mobile/features/feed/presentation/bloc/feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final FeedRepository repository;
  FeedLoaded? _cachedFeedState; // Cache feed state when viewing comments

  FeedBloc({required this.repository}) : super(FeedInitial()) {
    on<LoadPublicFeed>(_onLoadPublicFeed);
    on<LoadFollowingFeed>(_onLoadFollowingFeed);
    on<LoadTrendingFeed>(_onLoadTrendingFeed);
    on<LikePostEvent>(_onLikePost);
    on<SavePostEvent>(_onSavePost);
    on<SharePostEvent>(_onSharePost);
    on<LoadCommentsEvent>(_onLoadComments);
    on<CreateCommentEvent>(_onCreateComment);
    on<IncrementViewCountEvent>(_onIncrementViewCount);
    on<RestoreCachedFeedEvent>(_onRestoreCachedFeed);
  }

  Future<void> _onLoadPublicFeed(
    LoadPublicFeed event,
    Emitter<FeedState> emit,
  ) async {
    try {
      if (event.refresh) {
        emit(FeedLoading());
      }

      final posts = await repository.getPublicFeed(
        page: event.page,
        size: 20,
      );

      if (event.page == 0) {
        final feedState = FeedLoaded(
          posts: posts,
          hasReachedMax: posts.isEmpty || posts.length < 20,
          currentPage: 0,
        );
        _cachedFeedState = feedState;
        emit(feedState);
      } else {
        final currentState = state;
        if (currentState is FeedLoaded) {
          final feedState = currentState.copyWith(
            posts: [...currentState.posts, ...posts],
            hasReachedMax: posts.isEmpty || posts.length < 20,
            currentPage: event.page,
          );
          _cachedFeedState = feedState;
          emit(feedState);
        }
      }
    } catch (e) {
      emit(FeedError(message: e.toString()));
    }
  }

  Future<void> _onLoadFollowingFeed(
    LoadFollowingFeed event,
    Emitter<FeedState> emit,
  ) async {
    try {
      if (event.refresh) {
        emit(FeedLoading());
      }

      final posts = await repository.getFollowingFeed(
        page: event.page,
        size: 20,
      );

      if (event.page == 0) {
        final feedState = FeedLoaded(
          posts: posts,
          hasReachedMax: posts.isEmpty || posts.length < 20,
          currentPage: 0,
        );
        _cachedFeedState = feedState;
        emit(feedState);
      } else {
        final currentState = state;
        if (currentState is FeedLoaded) {
          final feedState = currentState.copyWith(
            posts: [...currentState.posts, ...posts],
            hasReachedMax: posts.isEmpty || posts.length < 20,
            currentPage: event.page,
          );
          _cachedFeedState = feedState;
          emit(feedState);
        }
      }
    } catch (e) {
      emit(FeedError(message: e.toString()));
    }
  }

  Future<void> _onLikePost(
    LikePostEvent event,
    Emitter<FeedState> emit,
  ) async {
    try {
      // Optimistically update UI first
      final currentState = state;
      if (currentState is FeedLoaded) {
        final updatedPosts = currentState.posts.map((post) {
          if (post.id == event.postId) {
            return post.copyWith(
              isLikedByCurrentUser: !event.isLiked,
              likesCount: event.isLiked
                  ? post.likesCount - 1
                  : post.likesCount + 1,
            );
          }
          return post;
        }).toList();

        emit(currentState.copyWith(posts: updatedPosts));
      }

      // Then call API in background
      if (event.isLiked) {
        await repository.unlikePost(event.postId);
      } else {
        await repository.likePost(event.postId);
      }
    } catch (e) {
      // If API fails, revert the optimistic update
      final currentState = state;
      if (currentState is FeedLoaded) {
        final revertedPosts = currentState.posts.map((post) {
          if (post.id == event.postId) {
            return post.copyWith(
              isLikedByCurrentUser: event.isLiked,
              likesCount: event.isLiked
                  ? post.likesCount + 1
                  : post.likesCount - 1,
            );
          }
          return post;
        }).toList();

        emit(currentState.copyWith(posts: revertedPosts));
      }
    }
  }

  Future<void> _onSavePost(
    SavePostEvent event,
    Emitter<FeedState> emit,
  ) async {
    try {
      // Optimistically update UI first
      final currentState = state;
      if (currentState is FeedLoaded) {
        final updatedPosts = currentState.posts.map((post) {
          if (post.id == event.postId) {
            return post.copyWith(
              isSavedByCurrentUser: !event.isSaved,
            );
          }
          return post;
        }).toList();

        emit(currentState.copyWith(posts: updatedPosts));
      }

      // Then call API in background
      if (event.isSaved) {
        await repository.unsavePost(event.postId);
      } else {
        await repository.savePost(event.postId);
      }
    } catch (e) {
      // If API fails, revert the optimistic update
      final currentState = state;
      if (currentState is FeedLoaded) {
        final revertedPosts = currentState.posts.map((post) {
          if (post.id == event.postId) {
            return post.copyWith(
              isSavedByCurrentUser: event.isSaved,
            );
          }
          return post;
        }).toList();

        emit(currentState.copyWith(posts: revertedPosts));
      }
    }
  }

  Future<void> _onSharePost(
    SharePostEvent event,
    Emitter<FeedState> emit,
  ) async {
    try {
      emit(PostActionLoading(postId: event.postId, action: 'share'));

      await repository.sharePost(event.postId);

      // Update shares count
      final currentState = state;
      if (currentState is FeedLoaded) {
        final updatedPosts = currentState.posts.map((post) {
          if (post.id == event.postId) {
            return post.copyWith(
              sharesCount: post.sharesCount + 1,
            );
          }
          return post;
        }).toList();

        emit(currentState.copyWith(posts: updatedPosts));
      }

      emit(PostActionSuccess(postId: event.postId, action: 'share'));
    } catch (e) {
      emit(PostActionError(
        postId: event.postId,
        action: 'share',
        message: e.toString(),
      ));
    }
  }

  Future<void> _onLoadComments(
    LoadCommentsEvent event,
    Emitter<FeedState> emit,
  ) async {
    try {
      // Cache current feed state before transitioning to comments
      if (state is FeedLoaded) {
        _cachedFeedState = state as FeedLoaded;
      }

      final comments = await repository.getComments(
        postId: event.postId,
        page: event.page,
        size: 20,
      );

      emit(CommentsLoaded(
        postId: event.postId,
        comments: comments,
        hasReachedMax: comments.isEmpty || comments.length < 20,
      ));
    } catch (e) {
      emit(PostActionError(
        postId: event.postId,
        action: 'loadComments',
        message: e.toString(),
      ));
    }
  }

  Future<void> _onCreateComment(
    CreateCommentEvent event,
    Emitter<FeedState> emit,
  ) async {
    try {
      final comment = await repository.createComment(
        postId: event.postId,
        text: event.text,
      );

      // Update comments count in cached feed state regardless of current state
      if (_cachedFeedState != null) {
        final updatedPosts = _cachedFeedState!.posts.map((post) {
          if (post.id == event.postId) {
            return post.copyWith(
              commentsCount: post.commentsCount + 1,
            );
          }
          return post;
        }).toList();

        _cachedFeedState = _cachedFeedState!.copyWith(posts: updatedPosts);
      }

      // Update current state based on what it is
      final currentState = state;
      if (currentState is FeedLoaded) {
        final updatedPosts = currentState.posts.map((post) {
          if (post.id == event.postId) {
            return post.copyWith(
              commentsCount: post.commentsCount + 1,
            );
          }
          return post;
        }).toList();

        final feedState = currentState.copyWith(posts: updatedPosts);
        _cachedFeedState = feedState;
        emit(feedState);
      } else if (currentState is CommentsLoaded && currentState.postId == event.postId) {
        // If we're viewing comments, add new comment to the list without reloading
        final updatedComments = [comment, ...currentState.comments];
        emit(CommentsLoaded(
          postId: event.postId,
          comments: updatedComments,
          hasReachedMax: currentState.hasReachedMax,
        ));
      }
    } catch (e) {
      emit(PostActionError(
        postId: event.postId,
        action: 'comment',
        message: e.toString(),
      ));
    }
  }

  Future<void> _onLoadTrendingFeed(
    LoadTrendingFeed event,
    Emitter<FeedState> emit,
  ) async {
    try {
      if (event.refresh) {
        emit(FeedLoading());
      }

      final posts = await repository.getTrendingFeed(
        page: event.page,
        size: 20,
        timeWindow: event.timeWindow,
      );

      if (event.page == 0) {
        final feedState = FeedLoaded(
          posts: posts,
          hasReachedMax: posts.isEmpty || posts.length < 20,
          currentPage: 0,
        );
        _cachedFeedState = feedState;
        emit(feedState);
      } else {
        final currentState = state;
        if (currentState is FeedLoaded) {
          final feedState = currentState.copyWith(
            posts: [...currentState.posts, ...posts],
            hasReachedMax: posts.isEmpty || posts.length < 20,
            currentPage: event.page,
          );
          _cachedFeedState = feedState;
          emit(feedState);
        }
      }
    } catch (e) {
      emit(FeedError(message: e.toString()));
    }
  }

  Future<void> _onIncrementViewCount(
    IncrementViewCountEvent event,
    Emitter<FeedState> emit,
  ) async {
    try {
      await repository.incrementViewCount(event.postId);

      // Update views count locally
      final currentState = state;
      if (currentState is FeedLoaded) {
        final updatedPosts = currentState.posts.map((post) {
          if (post.id == event.postId) {
            return post.copyWith(
              viewsCount: post.viewsCount + 1,
            );
          }
          return post;
        }).toList();

        emit(currentState.copyWith(posts: updatedPosts));
      }
    } catch (e) {
      // Silently fail - view count is not critical
    }
  }

  Future<void> _onRestoreCachedFeed(
    RestoreCachedFeedEvent event,
    Emitter<FeedState> emit,
  ) async {
    if (_cachedFeedState != null) {
      emit(_cachedFeedState!);
    }
  }
}
