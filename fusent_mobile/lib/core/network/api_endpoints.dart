class ApiEndpoints {
  // Base URL - change this to your backend URL
  static const String baseUrl = 'http://192.168.1.217:8080';

  // Auth Endpoints
  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String logout = '/api/v1/auth/logout';
  static const String refreshToken = '/api/v1/auth/refresh';
  static const String googleAuth = '/api/v1/auth/google';
  static const String telegramAuth = '/api/v1/auth/telegram';

  // User Endpoints
  static const String profile = '/api/v1/users/profile';
  static const String updateProfile = '/api/v1/users/profile';
  static const String followUser = '/api/v1/users/{id}/follow';
  static const String unfollowUser = '/api/v1/users/{id}/unfollow';

  // Product Endpoints
  static const String products = '/api/v1/public/catalog/products';
  static const String productDetail = '/api/v1/public/catalog/products/{id}';
  static const String searchProducts = '/api/v1/products/search';
  static const String filterProducts = '/api/v1/products/filter';

  // Post/Feed Endpoints (Social Controller)
  static const String publicFeed = '/api/v1/social/feed/public';
  static const String followingFeed = '/api/v1/social/feed/following';
  static const String createPost = '/api/v1/social/posts';
  static const String getPost = '/api/v1/social/posts/{postId}';
  static const String updatePost = '/api/v1/social/posts/{postId}';
  static const String deletePost = '/api/v1/social/posts/{postId}';
  static const String postsByOwner = '/api/v1/social/posts/by-owner';
  static const String postsByShop = '/api/v1/social/shops/{shopId}/posts';

  // Like Endpoints
  static const String likePost = '/api/v1/social/likes';
  static const String unlikePost = '/api/v1/social/posts/{postId}/likes';
  static const String isPostLiked = '/api/v1/social/posts/{postId}/liked';
  static const String getLikesCount = '/api/v1/social/posts/{postId}/likes/count';

  // Comment Endpoints
  static const String createComment = '/api/v1/social/comments';
  static const String deleteComment = '/api/v1/social/comments/{commentId}';
  static const String getComments = '/api/v1/social/posts/{postId}/comments';
  static const String flagComment = '/api/v1/social/comments/{commentId}/flag';

  // Share Endpoints
  static const String sharePost = '/api/v1/social/shares';
  static const String unsharePost = '/api/v1/social/shares/{postId}';
  static const String isPostShared = '/api/v1/social/shares/{postId}/is-shared';
  static const String getSharesCount = '/api/v1/social/posts/{postId}/shares/count';

  // Follow Endpoints
  static const String follow = '/api/v1/social/follows';
  static const String unfollow = '/api/v1/social/follows/{targetType}/{targetId}';
  static const String isFollowing = '/api/v1/social/follows/{targetType}/{targetId}/is-following';
  static const String getFollowing = '/api/v1/social/users/{userId}/following';
  static const String getFollowers = '/api/v1/social/follows/{targetType}/{targetId}/followers';
  static const String getFollowStats = '/api/v1/social/follows/{targetType}/{targetId}/stats';

  // Saved Posts Endpoints
  static const String savePost = '/api/v1/social/saved-posts';
  static const String unsavePost = '/api/v1/social/saved-posts/{postId}';
  static const String isPostSaved = '/api/v1/social/saved-posts/{postId}/is-saved';
  static const String getSavedPosts = '/api/v1/social/saved-posts';

  // Stories Endpoints
  static const String stories = '/api/v1/stories';
  static const String createStory = '/api/v1/stories';
  static const String viewStory = '/api/v1/stories/{id}/view';

  // Cart Endpoints
  static const String cart = '/api/v1/cart';
  static const String addToCart = '/api/v1/cart/add';
  static const String removeFromCart = '/api/v1/cart/remove';
  static const String updateCartItem = '/api/v1/cart/update';

  // Order Endpoints
  static const String orders = '/api/v1/orders';
  static const String createOrder = '/api/v1/orders';
  static const String orderDetail = '/api/v1/orders/{id}';

  // Chat Endpoints
  static const String chats = '/api/v1/chats';
  static const String messages = '/api/v1/chats/{id}/messages';
  static const String sendMessage = '/api/v1/chats/{id}/messages';

  // Shop/Merchant Endpoints
  static const String shops = '/api/v1/shops';
  static const String myShops = '/api/v1/shops/my';
  static const String shopDetail = '/api/v1/shops/{id}';
  static const String shopProducts = '/api/v1/shops/{id}/products';
  static const String createShop = '/api/v1/shops';
  static const String updateShop = '/api/v1/shops/{id}';
  static const String deleteShop = '/api/v1/shops/{id}';

  // Seller Catalog Endpoints
  static const String getMyProducts = '/api/v1/seller/catalog/products';
  static const String createProduct = '/api/v1/seller/catalog/product';
  static const String updatePriceStock = '/api/v1/seller/catalog/variant/price-stock';
  static const String setProductActive = '/api/v1/seller/catalog/product/active';

  // Review Endpoints
  static const String reviews = '/api/v1/products/{id}/reviews';
  static const String createReview = '/api/v1/products/{id}/reviews';

  // Notification Endpoints
  static const String notifications = '/api/v1/notifications';
  static const String markAsRead = '/api/v1/notifications/{id}/read';

  // Media Upload Endpoints
  static const String uploadProductImage = '/api/v1/media/upload/product';
  static const String uploadPostMedia = '/api/v1/media/upload/posts';
  static const String uploadAvatar = '/api/v1/media/upload/avatar';
  static const String uploadShopMedia = '/api/v1/media/upload/shop';
  static const String deleteMedia = '/api/v1/media';

  // Employee Endpoints
  static const String employees = '/api/v1/employees';
  static const String createEmployee = '/api/v1/employees';
  static const String employeeDetail = '/api/v1/employees/{id}';
  static const String updateEmployeeShop = '/api/v1/employees/{id}/shop';
  static const String deleteEmployee = '/api/v1/employees/{id}';
  static const String employeesByShop = '/api/v1/employees/shop/{shopId}';

  // Helper method to replace path parameters
  static String replacePathParams(String path, Map<String, String> params) {
    String result = path;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}
