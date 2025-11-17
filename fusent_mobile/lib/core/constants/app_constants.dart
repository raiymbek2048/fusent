class AppConstants {
  // App
  static const String appName = 'FUCENT';
  static const String appTagline = 'Маркетплейс нового поколения';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String languageKey = 'language';
  static const String themeKey = 'theme';

  // Pagination
  static const int defaultPageSize = 20;
  static const int storiesPageSize = 10;

  // Media
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int maxVideoSize = 100 * 1024 * 1024; // 100MB
  static const int maxPostMedia = 10;
  static const int maxStoryDuration = 15; // seconds

  // Stories
  static const int storyExpirationHours = 24;

  // Cart
  static const int cartItemMaxQuantity = 99;

  // Timeouts
  static const int connectionTimeout = 30; // seconds
  static const int receiveTimeout = 30; // seconds

  // Cache
  static const int cacheMaxAge = 300; // seconds

  // Map
  static const double defaultZoom = 14.0;
  static const double defaultLatitude = 42.8746; // Bishkek
  static const double defaultLongitude = 74.5698; // Bishkek

  // Regex patterns
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^\+996\d{9}$';
  static const String usernamePattern = r'^[a-zA-Z0-9_]{3,20}$';
}
