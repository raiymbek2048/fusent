import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusent_mobile/features/auth/data/models/user_model.dart';
import 'package:fusent_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:fusent_mobile/features/auth/domain/usecases/register_usecase.dart';
import 'package:fusent_mobile/features/auth/domain/usecases/logout_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
    on<TelegramLoginRequested>(_onTelegramLoginRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginUseCase(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (authResponse) => emit(AuthAuthenticated(
        user: authResponse.user,
        accessToken: authResponse.accessToken,
      )),
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await registerUseCase(
      fullName: event.fullName,
      email: event.email,
      username: event.username,
      phone: event.phone,
      password: event.password,
      accountType: event.accountType,
      shopAddress: event.shopAddress,
      hasSmartPOS: event.hasSmartPOS,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (authResponse) => emit(AuthAuthenticated(
        user: authResponse.user,
        accessToken: authResponse.accessToken,
      )),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await logoutUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthInitial()),
    );
  }

  Future<void> _onGoogleLoginRequested(
    GoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    // TODO: Implement Google Sign In
    emit(const AuthError('Google Sign In not implemented yet'));
  }

  Future<void> _onTelegramLoginRequested(
    TelegramLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    // TODO: Implement Telegram Sign In
    emit(const AuthError('Telegram Sign In not implemented yet'));
  }
}
