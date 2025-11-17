import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  final FlutterSecureStorage _secureStorage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _expiresInKey = 'expires_in';
  static const String _userIdKey = 'user_id';

  TokenStorageService(this._secureStorage);

  // Save tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required int expiresIn,
    required String userId,
  }) async {
    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
      _secureStorage.write(key: _tokenTypeKey, value: tokenType),
      _secureStorage.write(key: _expiresInKey, value: expiresIn.toString()),
      _secureStorage.write(key: _userIdKey, value: userId),
    ]);
  }

  // Get access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  // Get token type
  Future<String?> getTokenType() async {
    return await _secureStorage.read(key: _tokenTypeKey);
  }

  // Get expires in
  Future<int?> getExpiresIn() async {
    final value = await _secureStorage.read(key: _expiresInKey);
    return value != null ? int.tryParse(value) : null;
  }

  // Get user ID
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  // Clear all tokens (logout)
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _tokenTypeKey),
      _secureStorage.delete(key: _expiresInKey),
      _secureStorage.delete(key: _userIdKey),
    ]);
  }

  // Clear all storage
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}
