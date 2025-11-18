import 'package:dio/dio.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:fusent_mobile/core/network/api_endpoints.dart';
import 'package:fusent_mobile/features/seller/data/models/shop_model.dart';

class ShopService {
  final ApiClient _apiClient;

  ShopService(this._apiClient);

  /// Get all shops for the current seller
  Future<List<ShopModel>> getMyShops() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.myShops);
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => ShopModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load shops: ${e.message}');
    }
  }

  /// Get shop by ID
  Future<ShopModel> getShopById(String shopId) async {
    try {
      final url = ApiEndpoints.replacePathParams(
        ApiEndpoints.shopDetail,
        {'id': shopId},
      );
      final response = await _apiClient.get(url);
      return ShopModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to load shop: ${e.message}');
    }
  }

  /// Create a new shop
  Future<ShopModel> createShop(CreateShopRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.createShop,
        data: request.toJson(),
      );
      return ShopModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to create shop: ${e.message}');
    }
  }

  /// Update an existing shop
  Future<ShopModel> updateShop(String shopId, UpdateShopRequest request) async {
    try {
      final url = ApiEndpoints.replacePathParams(
        ApiEndpoints.updateShop,
        {'id': shopId},
      );
      final response = await _apiClient.put(
        url,
        data: request.toJson(),
      );
      return ShopModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to update shop: ${e.message}');
    }
  }

  /// Delete a shop
  Future<void> deleteShop(String shopId) async {
    try {
      final url = ApiEndpoints.replacePathParams(
        ApiEndpoints.deleteShop,
        {'id': shopId},
      );
      await _apiClient.delete(url);
    } on DioException catch (e) {
      throw Exception('Failed to delete shop: ${e.message}');
    }
  }
}
