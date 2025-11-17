import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String fullName;
  final String email;
  final String username;
  final String phone;
  final String password;
  final String accountType; // buyer or seller
  final String? shopAddress;
  final bool? hasSmartPOS;

  RegisterRequest({
    required this.fullName,
    required this.email,
    required this.username,
    required this.phone,
    required this.password,
    required this.accountType,
    this.shopAddress,
    this.hasSmartPOS,
  });

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final UserInfo user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class UserInfo {
  final String id;
  final String fullName;
  final String email;
  final String username;
  final String phone;
  final String role;
  final String? shopAddress;
  final bool? hasSmartPOS;
  final String? createdAt;

  UserInfo({
    required this.id,
    required this.fullName,
    required this.email,
    required this.username,
    required this.phone,
    required this.role,
    this.shopAddress,
    this.hasSmartPOS,
    this.createdAt,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}

@JsonSerializable()
class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);
}
