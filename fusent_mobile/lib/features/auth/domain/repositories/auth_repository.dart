import 'package:dartz/dartz.dart';
import 'package:fusent_mobile/core/errors/failures.dart';
import 'package:fusent_mobile/features/auth/data/models/auth_response_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponseModel>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthResponseModel>> register({
    required String fullName,
    required String email,
    required String username,
    required String phone,
    required String password,
    required String accountType,
    String? shopAddress,
    bool? hasSmartPOS,
  });

  Future<Either<Failure, AuthResponseModel>> loginWithGoogle({
    required String idToken,
  });

  Future<Either<Failure, AuthResponseModel>> loginWithTelegram({
    required String telegramData,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, AuthResponseModel>> refreshToken({
    required String refreshToken,
  });
}
