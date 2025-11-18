import 'package:equatable/equatable.dart';

class EmployeeModel extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String shopId;
  final String shopName;
  final DateTime createdAt;

  const EmployeeModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.shopId,
    required this.shopName,
    required this.createdAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      shopId: json['shopId'] as String,
      shopName: json['shopName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'shopId': shopId,
      'shopName': shopName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        shopId,
        shopName,
        createdAt,
      ];
}

class CreateEmployeeRequest {
  final String fullName;
  final String email;
  final String password;
  final String? phone;
  final String shopId;

  CreateEmployeeRequest({
    required this.fullName,
    required this.email,
    required this.password,
    this.phone,
    required this.shopId,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      if (phone != null) 'phone': phone,
      'shopId': shopId,
    };
  }
}

class UpdateEmployeeShopRequest {
  final String shopId;

  UpdateEmployeeShopRequest({
    required this.shopId,
  });

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
    };
  }
}
