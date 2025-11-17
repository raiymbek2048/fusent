import 'package:dartz/dartz.dart';
import 'package:fusent_mobile/core/errors/failures.dart';
import 'package:fusent_mobile/features/auth/data/models/auth_response_model.dart';
import 'package:fusent_mobile/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthResponseModel>> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(
      email: email,
      password: password,
    );
  }
}
