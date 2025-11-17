import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fusent_mobile/core/network/api_client.dart';
import 'package:fusent_mobile/core/services/token_storage_service.dart';
import 'package:fusent_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fusent_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:fusent_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:fusent_mobile/features/auth/domain/usecases/register_usecase.dart';
import 'package:fusent_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:fusent_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fusent_mobile/features/feed/data/datasources/feed_remote_datasource.dart';
import 'package:fusent_mobile/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:fusent_mobile/features/feed/domain/repositories/feed_repository.dart';
import 'package:fusent_mobile/features/feed/presentation/bloc/feed_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // Services
  sl.registerLazySingleton(() => TokenStorageService(sl()));

  // Network
  sl.registerLazySingleton(() => ApiClient());

  // Restore token from storage
  final tokenStorage = sl<TokenStorageService>();
  final apiClient = sl<ApiClient>();
  final accessToken = await tokenStorage.getAccessToken();
  if (accessToken != null) {
    apiClient.setAccessToken(accessToken);
  }

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => FeedBloc(repository: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      apiClient: sl(),
      tokenStorage: sl(),
    ),
  );

  sl.registerLazySingleton<FeedRepository>(
    () => FeedRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<FeedRemoteDataSource>(
    () => FeedRemoteDataSourceImpl(apiClient: sl()),
  );
}
