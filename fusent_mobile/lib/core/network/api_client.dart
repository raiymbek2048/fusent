import 'package:dio/dio.dart';
import 'package:fusent_mobile/core/network/api_endpoints.dart';

class ApiClient {
  late final Dio _dio;
  String? _accessToken;

  ApiClient({String? baseUrl}) {
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
          // Handle errors globally
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

  // Chat endpoints
  Future<Response> getChats() async {
    return await _dio.get(ApiEndpoints.chats);
  }

  Future<Response> getMessages(String chatId, {int page = 1}) async {
    final path = ApiEndpoints.replacePathParams(
      ApiEndpoints.messages,
      {'id': chatId},
    );
    return await _dio.get(
      path,
      queryParameters: {'page': page},
    );
  }

  Future<Response> sendMessage(String chatId, String message) async {
    final path = ApiEndpoints.replacePathParams(
      ApiEndpoints.sendMessage,
      {'id': chatId},
    );
    return await _dio.post(
      path,
      data: {'message': message},
    );
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
}
