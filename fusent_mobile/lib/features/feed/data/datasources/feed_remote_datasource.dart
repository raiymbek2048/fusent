import 'package:dio/dio.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:fusent_mobile/core/network/api_endpoints.dart';
import 'package:fusent_mobile/features/feed/data/models/post_model.dart';
import 'package:fusent_mobile/features/feed/data/models/comment_model.dart';

abstract class FeedRemoteDataSource {
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

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  final ApiClient apiClient;

  FeedRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PostModel>> getPublicFeed({required int page, required int size}) async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.publicFeed,
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      // Backend returns Page<PostResponse>, extract content
      if (response.data is Map<String, dynamic>) {
        final content = response.data['content'] as List<dynamic>;
        return content
            .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Fallback if response is already a list
      return (response.data as List<dynamic>)
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<PostModel>> getFollowingFeed({required int page, required int size}) async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.followingFeed,
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      // Backend returns Page<PostResponse>, extract content
      if (response.data is Map<String, dynamic>) {
        final content = response.data['content'] as List<dynamic>;
        return content
            .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return (response.data as List<dynamic>)
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<PostModel> getPost(String postId) async {
    try {
      final path = ApiEndpoints.replacePathParams(
        ApiEndpoints.getPost,
        {'postId': postId},
      );
      final response = await apiClient.dio.get(path);
      return PostModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> likePost(String postId) async {
    try {
      await apiClient.dio.post(
        ApiEndpoints.likePost,
        data: {'postId': postId},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> unlikePost(String postId) async {
    try {
      final path = ApiEndpoints.replacePathParams(
        ApiEndpoints.unlikePost,
        {'postId': postId},
      );
      await apiClient.dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<bool> isPostLiked(String postId) async {
    try {
      final path = ApiEndpoints.replacePathParams(
        ApiEndpoints.isPostLiked,
        {'postId': postId},
      );
      final response = await apiClient.dio.get(path);
      return response.data as bool;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<int> getLikesCount(String postId) async {
    try {
      final path = ApiEndpoints.replacePathParams(
        ApiEndpoints.getLikesCount,
        {'postId': postId},
      );
      final response = await apiClient.dio.get(path);
      return response.data as int;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<CommentModel>> getComments({
    required String postId,
    required int page,
    required int size,
  }) async {
    try {
      final path = ApiEndpoints.replacePathParams(
        ApiEndpoints.getComments,
        {'postId': postId},
      );
      final response = await apiClient.dio.get(
        path,
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      // Backend returns Page<CommentResponse>, extract content
      if (response.data is Map<String, dynamic>) {
        final content = response.data['content'] as List<dynamic>;
        return content
            .map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return (response.data as List<dynamic>)
          .map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<CommentModel> createComment({
    required String postId,
    required String text,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.createComment,
        data: {
          'postId': postId,
          'text': text,
        },
      );
      return CommentModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      final path = ApiEndpoints.replacePathParams(
        ApiEndpoints.deleteComment,
        {'commentId': commentId},
      );
      await apiClient.dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> sharePost(String postId) async {
    try {
      await apiClient.dio.post(
        ApiEndpoints.sharePost,
        data: {'postId': postId},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<int> getSharesCount(String postId) async {
    try {
      final path = ApiEndpoints.replacePathParams(
        ApiEndpoints.getSharesCount,
        {'postId': postId},
      );
      final response = await apiClient.dio.get(path);
      return response.data as int;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> savePost(String postId) async {
    try {
      await apiClient.dio.post(
        ApiEndpoints.savePost,
        data: {'postId': postId},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> unsavePost(String postId) async {
    try {
      final path = ApiEndpoints.replacePathParams(
        ApiEndpoints.unsavePost,
        {'postId': postId},
      );
      await apiClient.dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<PostModel>> getTrendingFeed({
    required int page,
    required int size,
    required String timeWindow,
  }) async {
    try {
      Response response;

      switch (timeWindow) {
        case '24h':
          response = await apiClient.getTrending24Hours(page: page, size: size);
          break;
        case 'week':
          response = await apiClient.getTrendingWeek(page: page, size: size);
          break;
        default:
          response = await apiClient.getTrendingPosts(page: page, size: size);
      }

      // Backend returns Page<PostResponse>, extract content
      if (response.data is Map<String, dynamic>) {
        final content = response.data['content'] as List<dynamic>;
        return content
            .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return (response.data as List<dynamic>)
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> incrementViewCount(String postId) async {
    try {
      await apiClient.incrementViewCount(postId);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['message'] ?? 'Something went wrong';
        return Exception('Error $statusCode: $message');
      case DioExceptionType.cancel:
        return Exception('Request was cancelled');
      default:
        return Exception('Network error: ${error.message}');
    }
  }
}
