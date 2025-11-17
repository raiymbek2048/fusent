import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String username;
  final String phone;
  final String role; // 'BUYER' or 'SELLER'
  final String? shopAddress;
  final bool? hasSmartPOS;
  final String? profileImage;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.username,
    required this.phone,
    required this.role,
    this.shopAddress,
    this.hasSmartPOS,
    this.profileImage,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      shopAddress: json['shopAddress'] as String?,
      hasSmartPOS: json['hasSmartPOS'] as bool?,
      profileImage: json['profileImage'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'username': username,
      'phone': phone,
      'role': role,
      if (shopAddress != null) 'shopAddress': shopAddress,
      if (hasSmartPOS != null) 'hasSmartPOS': hasSmartPOS,
      if (profileImage != null) 'profileImage': profileImage,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? username,
    String? phone,
    String? role,
    String? shopAddress,
    bool? hasSmartPOS,
    String? profileImage,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      shopAddress: shopAddress ?? this.shopAddress,
      hasSmartPOS: hasSmartPOS ?? this.hasSmartPOS,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        username,
        phone,
        role,
        shopAddress,
        hasSmartPOS,
        profileImage,
        createdAt,
      ];
}
