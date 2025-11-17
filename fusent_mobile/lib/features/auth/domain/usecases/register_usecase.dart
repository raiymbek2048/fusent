import 'package:dartz/dartz.dart';
import 'package:fusent_mobile/core/errors/failures.dart';
import 'package:fusent_mobile/features/auth/data/models/auth_response_model.dart';
import 'package:fusent_mobile/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, AuthResponseModel>> call({
    required String fullName,
    required String email,
    required String username,
    required String phone,
    required String password,
    required String accountType,
    String? shopAddress,
    bool? hasSmartPOS,
  }) async {
    return await repository.register(
      fullName: fullName,
      email: email,
      username: username,
      phone: phone,
      password: password,
      accountType: accountType,
      shopAddress: shopAddress,
      hasSmartPOS: hasSmartPOS,
    );
  }
}
