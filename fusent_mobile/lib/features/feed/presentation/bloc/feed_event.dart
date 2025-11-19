import 'package:equatable/equatable.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class LoadPublicFeed extends FeedEvent {
  final int page;
  final bool refresh;

  const LoadPublicFeed({this.page = 0, this.refresh = false});

  @override
  List<Object?> get props => [page, refresh];
}

class LoadFollowingFeed extends FeedEvent {
  final int page;
  final bool refresh;

  const LoadFollowingFeed({this.page = 0, this.refresh = false});

  @override
  List<Object?> get props => [page, refresh];
}

class LikePostEvent extends FeedEvent {
  final String postId;
  final bool isLiked;

  const LikePostEvent({required this.postId, required this.isLiked});

  @override
  List<Object?> get props => [postId, isLiked];
}

class SavePostEvent extends FeedEvent {
  final String postId;
  final bool isSaved;

  const SavePostEvent({required this.postId, required this.isSaved});

  @override
  List<Object?> get props => [postId, isSaved];
}

class SharePostEvent extends FeedEvent {
  final String postId;

  const SharePostEvent({required this.postId});

  @override
  List<Object?> get props => [postId];
}

class LoadCommentsEvent extends FeedEvent {
  final String postId;
  final int page;

  const LoadCommentsEvent({required this.postId, this.page = 0});

  @override
  List<Object?> get props => [postId, page];
}

class CreateCommentEvent extends FeedEvent {
  final String postId;
  final String text;

  const CreateCommentEvent({required this.postId, required this.text});

  @override
  List<Object?> get props => [postId, text];
}

class LoadTrendingFeed extends FeedEvent {
  final int page;
  final bool refresh;
  final String timeWindow; // 'all', '24h', 'week'

  const LoadTrendingFeed({
    this.page = 0,
    this.refresh = false,
    this.timeWindow = 'all',
  });

  @override
  List<Object?> get props => [page, refresh, timeWindow];
}

class IncrementViewCountEvent extends FeedEvent {
  final String postId;

  const IncrementViewCountEvent({required this.postId});

  @override
  List<Object?> get props => [postId];
}
