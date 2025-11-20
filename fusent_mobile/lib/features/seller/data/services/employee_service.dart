import 'package:dio/dio.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:fusent_mobile/core/network/api_endpoints.dart';
import 'package:fusent_mobile/features/seller/data/models/employee_model.dart';

class EmployeeService {
  final ApiClient _apiClient;

  EmployeeService(this._apiClient);

  /// Get all employees
  Future<List<EmployeeModel>> getAllEmployees() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.employees);
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => EmployeeModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load employees: ${e.message}');
    }
  }

  /// Get employees by shop ID
  Future<List<EmployeeModel>> getEmployeesByShop(String shopId) async {
    try {
      final url = ApiEndpoints.replacePathParams(
        ApiEndpoints.employeesByShop,
        {'shopId': shopId},
      );
      final response = await _apiClient.get(url);
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => EmployeeModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load employees: ${e.message}');
    }
  }

  /// Get employee by ID
  Future<EmployeeModel> getEmployeeById(String employeeId) async {
    try {
      final url = ApiEndpoints.replacePathParams(
        ApiEndpoints.employeeDetail,
        {'id': employeeId},
      );
      final response = await _apiClient.get(url);
      return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to load employee: ${e.message}');
    }
  }

  /// Create a new employee
  Future<EmployeeModel> createEmployee(CreateEmployeeRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.createEmployee,
        data: request.toJson(),
      );
      return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to create employee: ${e.message}');
    }
  }

  /// Update employee details
  Future<EmployeeModel> updateEmployee(String employeeId, UpdateEmployeeRequest request) async {
    try {
      final url = ApiEndpoints.replacePathParams(
        ApiEndpoints.updateEmployee,
        {'id': employeeId},
      );
      final response = await _apiClient.put(
        url,
        data: request.toJson(),
      );
      return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to update employee: ${e.message}');
    }
  }

  /// Update employee's shop assignment
  Future<EmployeeModel> updateEmployeeShop(String employeeId, UpdateEmployeeShopRequest request) async {
    try {
      final url = ApiEndpoints.replacePathParams(
        ApiEndpoints.updateEmployeeShop,
        {'id': employeeId},
      );
      final response = await _apiClient.put(
        url,
        data: request.toJson(),
      );
      return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to update employee shop: ${e.message}');
    }
  }

  /// Delete an employee
  Future<void> deleteEmployee(String employeeId) async {
    try {
      final url = ApiEndpoints.replacePathParams(
        ApiEndpoints.deleteEmployee,
        {'id': employeeId},
      );
      await _apiClient.delete(url);
    } on DioException catch (e) {
      throw Exception('Failed to delete employee: ${e.message}');
    }
  }
}
