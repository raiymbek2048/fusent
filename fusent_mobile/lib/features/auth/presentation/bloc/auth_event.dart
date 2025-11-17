part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String username;
  final String phone;
  final String password;
  final String accountType;
  final String? shopAddress;
  final bool? hasSmartPOS;

  const RegisterRequested({
    required this.fullName,
    required this.email,
    required this.username,
    required this.phone,
    required this.password,
    required this.accountType,
    this.shopAddress,
    this.hasSmartPOS,
  });

  @override
  List<Object?> get props => [
        fullName,
        email,
        username,
        phone,
        password,
        accountType,
        shopAddress,
        hasSmartPOS,
      ];
}

class LogoutRequested extends AuthEvent {}

class GoogleLoginRequested extends AuthEvent {}

class TelegramLoginRequested extends AuthEvent {}
