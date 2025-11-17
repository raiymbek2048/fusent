import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fusent_mobile/core/errors/failures.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:fusent_mobile/core/services/token_storage_service.dart';
import 'package:fusent_mobile/features/auth/data/models/auth_response_model.dart';
import 'package:fusent_mobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;
  final TokenStorageService tokenStorage;

  AuthRepositoryImpl({
    required this.apiClient,
    required this.tokenStorage,
  });

  @override
  Future<Either<Failure, AuthResponseModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.login(
        email: email,
        password: password,
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      // Save tokens to secure storage
      await tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        tokenType: authResponse.tokenType,
        expiresIn: authResponse.expiresIn,
        userId: authResponse.user.id,
      );

      // Set access token in API client
      apiClient.setAccessToken(authResponse.accessToken);

      return Right(authResponse);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponseModel>> register({
    required String fullName,
    required String email,
    required String username,
    required String phone,
    required String password,
    required String accountType,
    String? shopAddress,
    bool? hasSmartPOS,
  }) async {
    try {
      final response = await apiClient.register(
        fullName: fullName,
        email: email,
        username: username,
        phone: phone,
        password: password,
        accountType: accountType,
        shopAddress: shopAddress,
        hasSmartPOS: hasSmartPOS,
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      // Save tokens to secure storage
      await tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        tokenType: authResponse.tokenType,
        expiresIn: authResponse.expiresIn,
        userId: authResponse.user.id,
      );

      // Set access token in API client
      apiClient.setAccessToken(authResponse.accessToken);

      return Right(authResponse);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponseModel>> loginWithGoogle({
    required String idToken,
  }) async {
    try {
      final response = await apiClient.loginWithGoogle(idToken: idToken);
      final authResponse = AuthResponseModel.fromJson(response.data);

      // Save tokens to secure storage
      await tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        tokenType: authResponse.tokenType,
        expiresIn: authResponse.expiresIn,
        userId: authResponse.user.id,
      );

      // Set access token in API client
      apiClient.setAccessToken(authResponse.accessToken);

      return Right(authResponse);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponseModel>> loginWithTelegram({
    required String telegramData,
  }) async {
    try {
      final response =
          await apiClient.loginWithTelegram(telegramData: telegramData);
      final authResponse = AuthResponseModel.fromJson(response.data);

      // Save tokens to secure storage
      await tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        tokenType: authResponse.tokenType,
        expiresIn: authResponse.expiresIn,
        userId: authResponse.user.id,
      );

      // Set access token in API client
      apiClient.setAccessToken(authResponse.accessToken);

      return Right(authResponse);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Clear tokens from storage first
      await tokenStorage.clearTokens();

      // Clear access token in API client
      apiClient.clearAccessToken();

      // Note: We don't call the backend logout endpoint because:
      // 1. JWT tokens are stateless - logout happens client-side
      // 2. Calling the endpoint with an expired token will fail
      // In the future, we can implement token blacklisting in Redis if needed

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponseModel>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await apiClient.refreshToken(refreshToken: refreshToken);
      final authResponse = AuthResponseModel.fromJson(response.data);

      // Save new tokens to secure storage
      await tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        tokenType: authResponse.tokenType,
        expiresIn: authResponse.expiresIn,
        userId: authResponse.user.id,
      );

      // Set access token in API client
      apiClient.setAccessToken(authResponse.accessToken);

      return Right(authResponse);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timeout');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        // Safely extract message from response
        String message = 'Unknown error';
        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] ?? 'Unknown error';
        } else if (responseData is String && responseData.isNotEmpty) {
          message = responseData;
        }

        if (statusCode == 401) {
          return UnauthorizedFailure(message);
        } else if (statusCode == 403) {
          return UnauthorizedFailure('Access forbidden: $message');
        } else if (statusCode == 404) {
          return NotFoundFailure(message);
        } else if (statusCode == 400) {
          return ValidationFailure(message);
        } else {
          return ServerFailure(message);
        }
      case DioExceptionType.cancel:
        return const ServerFailure('Request cancelled');
      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection');
      default:
        return ServerFailure(error.message ?? 'Unknown error');
    }
  }
}
