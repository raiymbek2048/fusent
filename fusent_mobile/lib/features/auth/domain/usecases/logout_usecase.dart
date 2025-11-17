import 'package:dartz/dartz.dart';
import 'package:fusent_mobile/core/errors/failures.dart';
import 'package:fusent_mobile/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}
