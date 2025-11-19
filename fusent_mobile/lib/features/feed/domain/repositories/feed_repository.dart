import 'package:fusent_mobile/features/feed/data/models/post_model.dart';
import 'package:fusent_mobile/features/feed/data/models/comment_model.dart';

abstract class FeedRepository {
  Future<List<PostModel>> getPublicFeed({required int page, required int size});
  Future<List<PostModel>> getFollowingFeed({required int page, required int size});
  Future<List<PostModel>> getTrendingFeed({required int page, required int size, required String timeWindow});
  Future<PostModel> getPost(String postId);
  Future<void> likePost(String postId);
  Future<void> unlikePost(String postId);
  Future<bool> isPostLiked(String postId);
  Future<int> getLikesCount(String postId);
  Future<List<CommentModel>> getComments({required String postId, required int page, required int size});
  Future<CommentModel> createComment({required String postId, required String text});
  Future<void> deleteComment(String commentId);
  Future<void> sharePost(String postId);
  Future<int> getSharesCount(String postId);
  Future<void> savePost(String postId);
  Future<void> unsavePost(String postId);
  Future<void> incrementViewCount(String postId);
}
