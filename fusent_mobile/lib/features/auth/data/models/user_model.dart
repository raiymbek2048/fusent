import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String username;
  final String phone;
  final String role; // 'BUYER', 'SELLER', 'MERCHANT', or 'ADMIN'

  // Profile fields
  final String? avatarUrl;
  final String? bio;
  final String? address;
  final String? city;
  final String? country;
  final String? dateOfBirth;
  final String? gender; // MALE, FEMALE, OTHER

  // Status fields
  final bool isVerified;
  final bool isActive;

  // Social links
  final String? telegramUsername;
  final String? instagramUsername;

  // Statistics
  final int followersCount;
  final int followingCount;
  final int postsCount;

  // Shop info (for sellers)
  final String? shopId;
  final String? shopAddress;
  final bool? hasSmartPOS;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.username,
    required this.phone,
    required this.role,
    this.avatarUrl,
    this.bio,
    this.address,
    this.city,
    this.country,
    this.dateOfBirth,
    this.gender,
    this.isVerified = false,
    this.isActive = true,
    this.telegramUsername,
    this.instagramUsername,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.shopId,
    this.shopAddress,
    this.hasSmartPOS,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      telegramUsername: json['telegramUsername'] as String?,
      instagramUsername: json['instagramUsername'] as String?,
      followersCount: json['followersCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
      postsCount: json['postsCount'] as int? ?? 0,
      shopId: json['shopId'] as String?,
      shopAddress: json['shopAddress'] as String?,
      hasSmartPOS: json['hasSmartPOS'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
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
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (bio != null) 'bio': bio,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (country != null) 'country': country,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (gender != null) 'gender': gender,
      'isVerified': isVerified,
      'isActive': isActive,
      if (telegramUsername != null) 'telegramUsername': telegramUsername,
      if (instagramUsername != null) 'instagramUsername': instagramUsername,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      if (shopId != null) 'shopId': shopId,
      if (shopAddress != null) 'shopAddress': shopAddress,
      if (hasSmartPOS != null) 'hasSmartPOS': hasSmartPOS,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? username,
    String? phone,
    String? role,
    String? avatarUrl,
    String? bio,
    String? address,
    String? city,
    String? country,
    String? dateOfBirth,
    String? gender,
    bool? isVerified,
    bool? isActive,
    String? telegramUsername,
    String? instagramUsername,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    String? shopId,
    String? shopAddress,
    bool? hasSmartPOS,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      telegramUsername: telegramUsername ?? this.telegramUsername,
      instagramUsername: instagramUsername ?? this.instagramUsername,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      shopId: shopId ?? this.shopId,
      shopAddress: shopAddress ?? this.shopAddress,
      hasSmartPOS: hasSmartPOS ?? this.hasSmartPOS,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
        avatarUrl,
        bio,
        address,
        city,
        country,
        dateOfBirth,
        gender,
        isVerified,
        isActive,
        telegramUsername,
        instagramUsername,
        followersCount,
        followingCount,
        postsCount,
        shopId,
        shopAddress,
        hasSmartPOS,
        createdAt,
        updatedAt,
      ];
}
