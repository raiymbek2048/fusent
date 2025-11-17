import 'package:fusent_mobile/features/feed/data/datasources/feed_remote_datasource.dart';
import 'package:fusent_mobile/features/feed/data/models/post_model.dart';
import 'package:fusent_mobile/features/feed/data/models/comment_model.dart';
import 'package:fusent_mobile/features/feed/domain/repositories/feed_repository.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource remoteDataSource;

  FeedRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PostModel>> getPublicFeed({required int page, required int size}) async {
    try {
      return await remoteDataSource.getPublicFeed(page: page, size: size);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PostModel>> getFollowingFeed({required int page, required int size}) async {
    try {
      return await remoteDataSource.getFollowingFeed(page: page, size: size);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PostModel> getPost(String postId) async {
    try {
      return await remoteDataSource.getPost(postId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> likePost(String postId) async {
    try {
      await remoteDataSource.likePost(postId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> unlikePost(String postId) async {
    try {
      await remoteDataSource.unlikePost(postId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isPostLiked(String postId) async {
    try {
      return await remoteDataSource.isPostLiked(postId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> getLikesCount(String postId) async {
    try {
      return await remoteDataSource.getLikesCount(postId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CommentModel>> getComments({
    required String postId,
    required int page,
    required int size,
  }) async {
    try {
      return await remoteDataSource.getComments(
        postId: postId,
        page: page,
        size: size,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CommentModel> createComment({
    required String postId,
    required String text,
  }) async {
    try {
      return await remoteDataSource.createComment(postId: postId, text: text);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      await remoteDataSource.deleteComment(commentId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sharePost(String postId) async {
    try {
      await remoteDataSource.sharePost(postId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> getSharesCount(String postId) async {
    try {
      return await remoteDataSource.getSharesCount(postId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> savePost(String postId) async {
    try {
      await remoteDataSource.savePost(postId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> unsavePost(String postId) async {
    try {
      await remoteDataSource.unsavePost(postId);
    } catch (e) {
      rethrow;
    }
  }
}
