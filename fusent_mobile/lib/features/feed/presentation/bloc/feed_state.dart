import 'package:equatable/equatable.dart';
import 'package:fusent_mobile/features/feed/data/models/post_model.dart';
import 'package:fusent_mobile/features/feed/data/models/comment_model.dart';

abstract class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object?> get props => [];
}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<PostModel> posts;
  final bool hasReachedMax;
  final int currentPage;

  const FeedLoaded({
    required this.posts,
    this.hasReachedMax = false,
    this.currentPage = 0,
  });

  FeedLoaded copyWith({
    List<PostModel>? posts,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return FeedLoaded(
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [posts, hasReachedMax, currentPage];
}

class FeedError extends FeedState {
  final String message;

  const FeedError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PostActionLoading extends FeedState {
  final String postId;
  final String action; // 'like', 'save', 'share', 'comment'

  const PostActionLoading({required this.postId, required this.action});

  @override
  List<Object?> get props => [postId, action];
}

class PostActionSuccess extends FeedState {
  final String postId;
  final String action;
  final PostModel? updatedPost;

  const PostActionSuccess({
    required this.postId,
    required this.action,
    this.updatedPost,
  });

  @override
  List<Object?> get props => [postId, action, updatedPost];
}

class PostActionError extends FeedState {
  final String postId;
  final String action;
  final String message;

  const PostActionError({
    required this.postId,
    required this.action,
    required this.message,
  });

  @override
  List<Object?> get props => [postId, action, message];
}

class CommentsLoaded extends FeedState {
  final String postId;
  final List<CommentModel> comments;
  final bool hasReachedMax;

  const CommentsLoaded({
    required this.postId,
    required this.comments,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [postId, comments, hasReachedMax];
}

class CommentCreated extends FeedState {
  final CommentModel comment;

  const CommentCreated({required this.comment});

  @override
  List<Object?> get props => [comment];
}
