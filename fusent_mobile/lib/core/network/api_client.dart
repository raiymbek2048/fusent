import 'package:dio/dio.dart';
import 'package:fusent_mobile/core/network/api_endpoints.dart';

class ApiClient {
  late final Dio _dio;
  String? _accessToken;

  // Singleton pattern
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient({String? baseUrl}) {
    return _instance;
  }

  ApiClient._internal({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add authorization token if available
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          // Handle 401/403 errors (unauthorized/forbidden - token expired or invalid)
          if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
            // Clear the expired/invalid token
            _accessToken = null;

            // You can add additional logic here to:
            // - Navigate to login page
            // - Show a message to the user
            // - Refresh the token
          }

          return handler.next(error);
        },
      ),
    );

    // Add logging in debug mode
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );
  }

  Dio get dio => _dio;

  void setAccessToken(String token) {
    _accessToken = token;
  }

  void clearAccessToken() {
    _accessToken = null;
  }

  // Generic HTTP methods
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.delete(path, data: data, queryParameters: queryParameters);
  }

  // Auth endpoints
  Future<Response> login({
    required String email,
    required String password,
  }) async {
    return await _dio.post(
      '/api/v1/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
  }

  Future<Response> register({
    required String fullName,
    required String email,
    required String username,
    required String phone,
    required String password,
    required String accountType,
    String? shopAddress,
    bool? hasSmartPOS,
  }) async {
    return await _dio.post(
      '/api/v1/auth/register',
      data: {
        'fullName': fullName,
        'email': email,
        'username': username,
        'phone': phone,
        'password': password,
        'accountType': accountType,
        if (shopAddress != null) 'shopAddress': shopAddress,
        if (hasSmartPOS != null) 'hasSmartPOS': hasSmartPOS,
      },
    );
  }

  Future<Response> loginWithGoogle({required String idToken}) async {
    return await _dio.post(
      '/api/v1/auth/google',
      data: {'idToken': idToken},
    );
  }

  Future<Response> loginWithTelegram({required String telegramData}) async {
    return await _dio.post(
      '/api/v1/auth/telegram',
      data: {'telegramData': telegramData},
    );
  }

  Future<Response> refreshToken({required String refreshToken}) async {
    return await _dio.post(
      '/api/v1/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
  }

  Future<Response> logout() async {
    return await _dio.post(ApiEndpoints.logout);
  }

  // Product endpoints
  Future<Response> getProducts({
    int page = 0,
    int size = 20,
    String? categoryId,
    String? qtext,
  }) async {
    return await _dio.get(
      ApiEndpoints.products,
      queryParameters: {
        'page': page,
        'size': size,
        if (categoryId != null) 'categoryId': categoryId,
        if (qtext != null) 'qtext': qtext,
      },
    );
  }

  Future<Response> getProductDetail(String productId) async {
    final path = ApiEndpoints.replacePathParams(
      ApiEndpoints.productDetail,
      {'id': productId},
    );
    return await _dio.get(path);
  }

  Future<Response> searchProducts({
    required String query,
    String? categoryId,
    String? shopId,
    int page = 0,
    int size = 20,
  }) async {
    return await _dio.get(
      ApiEndpoints.products,
      queryParameters: {
        if (query.isNotEmpty) 'qtext': query,
        if (categoryId != null) 'categoryId': categoryId,
        if (shopId != null) 'shopId': shopId,
        'page': page,
        'size': size,
      },
    );
  }

  Future<Response> autocomplete({
    required String query,
    int page = 0,
    int size = 10,
  }) async {
    return await _dio.get(
      ApiEndpoints.autocompleteProducts,
      queryParameters: {
        'q': query,
        'page': page,
        'size': size,
      },
    );
  }

  // Feed endpoints
  Future<Response> getFeed({
    int page = 0,
    int size = 20,
    String type = 'public', // public, following
  }) async {
    String endpoint;
    switch (type) {
      case 'following':
        endpoint = ApiEndpoints.followingFeed;
        break;
      default:
        endpoint = ApiEndpoints.publicFeed;
    }

    return await _dio.get(
      endpoint,
      queryParameters: {
        'page': page,
        'size': size,
      },
    );
  }

  // Like/Unlike endpoints
  Future<Response> likePost(String postId) async {
    return await _dio.post(
      ApiEndpoints.likePost,
      data: {'postId': postId},
    );
  }

  Future<Response> unlikePost(String postId) async {
    final path = ApiEndpoints.replacePathParams(
      ApiEndpoints.unlikePost,
      {'postId': postId},
    );
    return await _dio.delete(path);
  }

  // Comment endpoints
  Future<Response> createComment({
    required String postId,
    required String text,
  }) async {
    return await _dio.post(
      ApiEndpoints.createComment,
      data: {
        'postId': postId,
        'text': text,
      },
    );
  }

  Future<Response> getComments({
    required String postId,
    int page = 0,
    int size = 20,
  }) async {
    final path = ApiEndpoints.replacePathParams(
      ApiEndpoints.getComments,
      {'postId': postId},
    );
    return await _dio.get(
      path,
      queryParameters: {
        'page': page,
        'size': size,
      },
    );
  }

  Future<Response> deleteComment(String commentId) async {
    final path = ApiEndpoints.replacePathParams(
      ApiEndpoints.deleteComment,
      {'commentId': commentId},
    );
    return await _dio.delete(path);
  }

  // Share endpoints
  Future<Response> sharePost(String postId) async {
    return await _dio.post(
      ApiEndpoints.sharePost,
      data: {'postId': postId},
    );
  }

  // Saved posts endpoints
  Future<Response> savePost(String postId) async {
    return await _dio.post(
      ApiEndpoints.savePost,
      data: {'postId': postId},
    );
  }

  Future<Response> unsavePost(String postId) async {
    final path = ApiEndpoints.replacePathParams(
      ApiEndpoints.unsavePost,
      {'postId': postId},
    );
    return await _dio.delete(path);
  }

  // Cart endpoints
  Future<Response> getCart() async {
    return await _dio.get(ApiEndpoints.cart);
  }

  Future<Response> addToCart({
    required String productId,
    required int quantity,
  }) async {
    return await _dio.post(
      ApiEndpoints.addToCart,
      data: {
        'productId': productId,
        'quantity': quantity,
      },
    );
  }

  Future<Response> removeFromCart({
    required String productId,
  }) async {
    return await _dio.post(
      ApiEndpoints.removeFromCart,
      data: {
        'productId': productId,
      },
    );
  }

  Future<Response> updateCartItem({
    required String productId,
    required int quantity,
  }) async {
    return await _dio.post(
      ApiEndpoints.updateCartItem,
      data: {
        'productId': productId,
        'quantity': quantity,
      },
    );
  }

  // Modern cart endpoints using variantId
  Future<Response> updateCartItemByVariant({
    required String variantId,
    required int quantity,
  }) async {
    return await _dio.put(
      '/api/v1/cart/items/$variantId',
      data: {
        'qty': quantity,
      },
    );
  }

  Future<Response> removeFromCartByVariant({
    required String variantId,
  }) async {
    return await _dio.delete('/api/v1/cart/items/$variantId');
  }

  // Chat endpoints
  Future<Response> createOrGetConversation({
    required String recipientId,
  }) async {
    return await _dio.post(
      ApiEndpoints.createConversation,
      data: {
        'recipientId': recipientId,
      },
    );
  }

  Future<Response> getConversations() async {
    return await _dio.get(ApiEndpoints.conversations);
  }

  Future<Response> getConversationById(String conversationId) async {
    final path = ApiEndpoints.replacePathParams(
      ApiEndpoints.conversationById,
      {'conversationId': conversationId},
    );
    return await _dio.get(path);
  }

  Future<Response> getConversationMessages(
    String conversationId, {
    int page = 0,
    int size = 50,
  }) async {
    final path = ApiEndpoints.replacePathParams(
      ApiEndpoints.conversationMessages,
      {'conversationId': conversationId},
    );
    return await _dio.get(
      path,
      queryParameters: {
        'page': page,
        'size': size,
      },
    );
  }

  Future<Response> sendChatMessage({
    required String recipientId,
    required String messageText,
  }) async {
    return await _dio.post(
      ApiEndpoints.sendChatMessage,
      data: {
        'recipientId': recipientId,
        'messageText': messageText,
      },
    );
  }

  Future<Response> sendMessage(Map<String, dynamic> messageData) async {
    return await _dio.post(
      ApiEndpoints.sendChatMessage,
      data: messageData,
    );
  }

  Future<Response> markChatMessageAsRead(String messageId) async {
    final path = ApiEndpoints.replacePathParams(
      ApiEndpoints.markMessageRead,
      {'messageId': messageId},
    );
    return await _dio.patch(path);
  }

  Future<Response> getUnreadMessagesCount() async {
    return await _dio.get(ApiEndpoints.unreadCount);
  }

  // Stories endpoints
  Future<Response> getStories() async {
    return await _dio.get(ApiEndpoints.stories);
  }

  Future<Response> viewStory(String storyId) async {
    final path = ApiEndpoints.replacePathParams(
      ApiEndpoints.viewStory,
      {'id': storyId},
    );
    return await _dio.post(path);
  }

  // Shop endpoints
  Future<Response> getAllShops({int page = 0, int size = 20}) async {
    return await _dio.get(
      ApiEndpoints.shops,
      queryParameters: {
        'page': page,
        'size': size,
      },
    );
  }

  Future<Response> getShopById(String shopId) async {
    final path = ApiEndpoints.replacePathParams(
      ApiEndpoints.shopDetail,
      {'id': shopId},
    );
    return await _dio.get(path);
  }

  Future<Response> getShopProducts(String shopId, {int page = 0, int size = 20}) async {
    final path = ApiEndpoints.replacePathParams(
      ApiEndpoints.shopProducts,
      {'id': shopId},
    );
    return await _dio.get(
      path,
      queryParameters: {
        'page': page,
        'size': size,
      },
    );
  }

  // Seller Catalog endpoints
  Future<Response> getMyProducts() async {
    return await _dio.get(ApiEndpoints.getMyProducts);
  }

  Future<Response> createProduct({
    required String shopId,
    required String categoryId,
    required String name,
    String? description,
    String? imageUrl,
    required double basePrice,
    int? initialStock,
  }) async {
    return await _dio.post(
      ApiEndpoints.createProduct,
      data: {
        'shopId': shopId,
        'categoryId': categoryId,
        'name': name,
        if (description != null) 'description': description,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'basePrice': basePrice,
        if (initialStock != null) 'initialStock': initialStock,
      },
    );
  }

  Future<Response> getProductById(String productId) async {
    return await _dio.get('/api/v1/seller/catalog/products/$productId');
  }

  Future<Response> updateProduct(String productId, Map<String, dynamic> data) async {
    return await _dio.put('/api/v1/seller/catalog/products/$productId', data: data);
  }

  Future<Response> deleteProduct(String productId) async {
    return await _dio.delete('/api/v1/seller/catalog/products/$productId');
  }

  // Post endpoints
  Future<Response> createPost({
    required String text,
    required String postType, // TEXT, PHOTO, VIDEO, PRODUCT
    String? visibility, // PUBLIC, FOLLOWERS, PRIVATE
    List<Map<String, dynamic>>? media,
    String? linkedProductId,
  }) async {
    return await _dio.post(
      ApiEndpoints.createPost,
      data: {
        'text': text,
        'postType': postType,
        if (visibility != null) 'visibility': visibility,
        if (media != null && media.isNotEmpty) 'media': media,
        if (linkedProductId != null) 'linkedProductId': linkedProductId,
      },
    );
  }

  Future<Response> getPostsByOwner({
    required String ownerType, // USER or MERCHANT
    required String ownerId,
    int page = 0,
    int size = 20,
  }) async {
    return await _dio.get(
      ApiEndpoints.postsByOwner,
      queryParameters: {
        'ownerType': ownerType,
        'ownerId': ownerId,
        'page': page,
        'size': size,
      },
    );
  }

  Future<Response> getMyPosts({
    int page = 0,
    int size = 20,
  }) async {
    return await _dio.get(
      '/api/v1/social/posts/my-posts',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );
  }

  // Media upload endpoints
  Future<Response> uploadProductImage(String filePath) async {
    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });

    return await _dio.post(
      ApiEndpoints.uploadProductImage,
      data: formData,
    );
  }

  Future<Response> uploadPostMedia(String filePath) async {
    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });

    return await _dio.post(
      ApiEndpoints.uploadPostMedia,
      data: formData,
    );
  }

  // ==================== Reviews API ====================

  // Create review for shop
  Future<Response> createShopReview({
    required String shopId,
    required int rating,
    String? orderId,
    String? title,
    String? comment,
  }) async {
    return await _dio.post(
      '/api/reviews/shops',
      data: {
        'shopId': shopId,
        'rating': rating,
        if (orderId != null) 'orderId': orderId,
        if (title != null) 'title': title,
        if (comment != null) 'comment': comment,
      },
    );
  }

  // Create review for product
  Future<Response> createProductReview({
    required String productId,
    required int rating,
    String? orderId,
    String? title,
    String? comment,
  }) async {
    return await _dio.post(
      '/api/reviews/products',
      data: {
        'productId': productId,
        'rating': rating,
        if (orderId != null) 'orderId': orderId,
        if (title != null) 'title': title,
        if (comment != null) 'comment': comment,
      },
    );
  }

  // Get shop reviews
  Future<Response> getShopReviews({
    required String shopId,
    int page = 0,
    int size = 20,
    String sortBy = 'createdAt',
    String sortDirection = 'DESC',
  }) async {
    return await _dio.get(
      '/api/reviews/shops/$shopId',
      queryParameters: {
        'page': page,
        'size': size,
        'sortBy': sortBy,
        'sortDirection': sortDirection,
      },
    );
  }

  // Get product reviews
  Future<Response> getProductReviews({
    required String productId,
    int page = 0,
    int size = 20,
    String sortBy = 'createdAt',
    String sortDirection = 'DESC',
  }) async {
    return await _dio.get(
      '/api/reviews/products/$productId',
      queryParameters: {
        'page': page,
        'size': size,
        'sortBy': sortBy,
        'sortDirection': sortDirection,
      },
    );
  }

  // Get shop review summary
  Future<Response> getShopReviewSummary(String shopId) async {
    return await _dio.get('/api/reviews/shops/$shopId/summary');
  }

  // Get product review summary
  Future<Response> getProductReviewSummary(String productId) async {
    return await _dio.get('/api/reviews/products/$productId/summary');
  }

  // Get my reviews
  Future<Response> getMyReviews({
    int page = 0,
    int size = 20,
  }) async {
    return await _dio.get(
      '/api/reviews/me',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );
  }

  // Mark review as helpful
  Future<Response> markReviewHelpful({
    required String reviewId,
    required bool helpful,
  }) async {
    return await _dio.post(
      '/api/reviews/$reviewId/helpful',
      data: {'helpful': helpful},
    );
  }

  // Delete review
  Future<Response> deleteReview(String reviewId) async {
    return await _dio.delete('/api/reviews/$reviewId');
  }

  // Check if user can review shop
  Future<Response> canReviewShop(String shopId) async {
    return await _dio.get('/api/reviews/shops/$shopId/can-review');
  }

  // Check if user can review product
  Future<Response> canReviewProduct(String productId) async {
    return await _dio.get('/api/reviews/products/$productId/can-review');
  }

  // ==================== Trending API ====================

  // Get trending posts
  Future<Response> getTrendingPosts({
    int page = 0,
    int size = 20,
  }) async {
    return await _dio.get(
      '/api/v1/trending/posts',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );
  }

  // Get trending posts from last 24 hours
  Future<Response> getTrending24Hours({
    int page = 0,
    int size = 20,
  }) async {
    return await _dio.get(
      '/api/v1/trending/posts/24h',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );
  }

  // Get trending posts from last week
  Future<Response> getTrendingWeek({
    int page = 0,
    int size = 20,
  }) async {
    return await _dio.get(
      '/api/v1/trending/posts/week',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );
  }

  // Get trending posts with custom time window
  Future<Response> getTrendingCustom({
    required int hoursAgo,
    int page = 0,
    int size = 20,
  }) async {
    return await _dio.get(
      '/api/v1/trending/posts/custom',
      queryParameters: {
        'hoursAgo': hoursAgo,
        'page': page,
        'size': size,
      },
    );
  }

  // Increment view count for a post
  Future<Response> incrementViewCount(String postId) async {
    return await _dio.post('/api/v1/trending/posts/$postId/view');
  }

  // Update trending score for a post
  Future<Response> updatePostTrendingScore(String postId) async {
    return await _dio.post('/api/v1/trending/posts/$postId/update-score');
  }

  // Manually trigger trending scores update
  Future<Response> updateAllTrendingScores() async {
    return await _dio.post('/api/v1/trending/update-scores');
  }

  // Follow endpoints
  Future<Response> followTarget({
    required String targetType,
    required String targetId,
  }) async {
    return await _dio.post(
      ApiEndpoints.follow,
      data: {
        'targetType': targetType,
        'targetId': targetId,
      },
    );
  }

  Future<Response> unfollowTarget({
    required String targetType,
    required String targetId,
  }) async {
    final path = ApiEndpoints.replacePathParams(
      ApiEndpoints.unfollow,
      {
        'targetType': targetType,
        'targetId': targetId,
      },
    );
    return await _dio.delete(path);
  }

  Future<Response> isFollowingTarget({
    required String targetType,
    required String targetId,
  }) async {
    final path = ApiEndpoints.replacePathParams(
      ApiEndpoints.isFollowing,
      {
        'targetType': targetType,
        'targetId': targetId,
      },
    );
    return await _dio.get(path);
  }

  Future<Response> getFollowStats({
    required String targetType,
    required String targetId,
  }) async {
    final path = ApiEndpoints.replacePathParams(
      ApiEndpoints.getFollowStats,
      {
        'targetType': targetType,
        'targetId': targetId,
      },
    );
    return await _dio.get(path);
  }

  // Order endpoints
  Future<Response> getShopOrders(String shopId) async {
    return await _dio.get('/api/v1/orders/shop/$shopId');
  }

  Future<Response> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    return await _dio.put(
      '/api/v1/orders/$orderId/status',
      data: {'status': status},
    );
  }

  Future<Response> getOrderDetails(String orderId) async {
    return await _dio.get('/api/v1/orders/$orderId');
  }

  Future<Response> getUserOrders(String userId) async {
    return await _dio.get('/api/v1/orders/user/$userId');
  }

  // Favorites endpoints
  Future<Response> getFavorites() async {
    return await _dio.get('/api/v1/favorites');
  }

  Future<Response> addToFavorites(String productId) async {
    return await _dio.post('/api/v1/favorites/$productId');
  }

  Future<Response> removeFromFavorites(String productId) async {
    return await _dio.delete('/api/v1/favorites/$productId');
  }

  Future<Response> checkIsFavorite(String productId) async {
    return await _dio.get('/api/v1/favorites/$productId/check');
  }

  // View History endpoints
  Future<Response> getViewHistory() async {
    return await _dio.get('/api/v1/view-history');
  }

  Future<Response> recordProductView(String productId) async {
    return await _dio.post('/api/v1/view-history/$productId');
  }

  Future<Response> clearViewHistory() async {
    return await _dio.delete('/api/v1/view-history');
  }

  // Notifications endpoints
  Future<Response> getUserNotifications({int page = 0, int size = 20}) async {
    return await _dio.get('/api/v1/notifications/user', queryParameters: {
      'page': page,
      'size': size,
    });
  }

  Future<Response> markNotificationAsRead(String notificationId) async {
    return await _dio.patch('/api/v1/notifications/$notificationId/read');
  }

  Future<Response> markAllNotificationsAsRead() async {
    return await _dio.patch('/api/v1/notifications/mark-all-read');
  }

  Future<Response> getUnreadNotificationsCount() async {
    return await _dio.get('/api/v1/notifications/unread-count');
  }

  // Delivery Address endpoints
  Future<Response> getDeliveryAddresses() async {
    return await _dio.get('/api/v1/addresses');
  }

  Future<Response> createDeliveryAddress(Map<String, dynamic> data) async {
    return await _dio.post('/api/v1/addresses', data: data);
  }

  Future<Response> updateDeliveryAddress(String id, Map<String, dynamic> data) async {
    return await _dio.put('/api/v1/addresses/$id', data: data);
  }

  Future<Response> deleteDeliveryAddress(String id) async {
    return await _dio.delete('/api/v1/addresses/$id');
  }

  Future<Response> setDefaultAddress(String id) async {
    return await _dio.patch('/api/v1/addresses/$id/default');
  }

  // Payment Methods endpoints
  Future<Response> getPaymentMethods() async {
    return await _dio.get('/api/v1/payment-methods');
  }

  Future<Response> createPaymentMethod(Map<String, dynamic> data) async {
    return await _dio.post('/api/v1/payment-methods', data: data);
  }

  Future<Response> deletePaymentMethod(String id) async {
    return await _dio.delete('/api/v1/payment-methods/$id');
  }

  Future<Response> setDefaultPaymentMethod(String id) async {
    return await _dio.patch('/api/v1/payment-methods/$id/default');
  }

  // Profile endpoints
  Future<Response> updateProfile({
    String? fullName,
    String? username,
    String? phone,
    String? bio,
    String? address,
    String? city,
    String? telegramUsername,
    String? instagramUsername,
  }) async {
    return await _dio.put('/api/v1/profile/me', data: {
      if (fullName != null) 'fullName': fullName,
      if (username != null) 'username': username,
      if (phone != null) 'phone': phone,
      if (bio != null) 'bio': bio,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (telegramUsername != null) 'telegramUsername': telegramUsername,
      if (instagramUsername != null) 'instagramUsername': instagramUsername,
    });
  }

  // Checkout endpoint
  Future<Response> checkout({
    required String shopId,
    String? shippingAddress,
    String? paymentMethod,
    String? notes,
  }) async {
    return await _dio.post(
      '/api/v1/checkout',
      data: {
        'shopId': shopId,
        if (shippingAddress != null) 'shippingAddress': shippingAddress,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
        if (notes != null) 'notes': notes,
      },
    );
  }

  // Shops endpoints
  Future<Response> getAllShops({int page = 0, int size = 1000}) async {
    return await _dio.get(
      '/api/v1/shops',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );
  }
}
