import 'package:equatable/equatable.dart';

class ShopModel extends Equatable {
  final String id;
  final String merchantId;
  final String merchantName;
  final String sellerId;
  final String name;
  final String? address;
  final String? phone;
  final double? lat;
  final double? lon;
  final String? posStatus;
  final DateTime? lastHeartbeatAt;
  final DateTime createdAt;
  final double? rating;
  final int? totalReviews;

  const ShopModel({
    required this.id,
    required this.merchantId,
    required this.merchantName,
    required this.sellerId,
    required this.name,
    this.address,
    this.phone,
    this.lat,
    this.lon,
    this.posStatus,
    this.lastHeartbeatAt,
    required this.createdAt,
    this.rating,
    this.totalReviews,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] as String,
      merchantId: json['merchantId'] as String,
      merchantName: json['merchantName'] as String,
      sellerId: json['sellerId'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      lat: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
      lon: json['lon'] != null ? (json['lon'] as num).toDouble() : null,
      posStatus: json['posStatus'] as String?,
      lastHeartbeatAt: json['lastHeartbeatAt'] != null
          ? DateTime.parse(json['lastHeartbeatAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      totalReviews: json['totalReviews'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchantId': merchantId,
      'merchantName': merchantName,
      'sellerId': sellerId,
      'name': name,
      'address': address,
      'phone': phone,
      'lat': lat,
      'lon': lon,
      'posStatus': posStatus,
      'lastHeartbeatAt': lastHeartbeatAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'rating': rating,
      'totalReviews': totalReviews,
    };
  }

  @override
  List<Object?> get props => [
        id,
        merchantId,
        merchantName,
        sellerId,
        name,
        address,
        phone,
        lat,
        lon,
        posStatus,
        lastHeartbeatAt,
        createdAt,
        rating,
        totalReviews,
      ];
}

class CreateShopRequest {
  final String? merchantId;
  final String name;
  final String? address;
  final String? phone;
  final double? lat;
  final double? lon;

  CreateShopRequest({
    this.merchantId,
    required this.name,
    this.address,
    this.phone,
    this.lat,
    this.lon,
  });

  Map<String, dynamic> toJson() {
    return {
      if (merchantId != null) 'merchantId': merchantId,
      'name': name,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
    };
  }
}

class UpdateShopRequest {
  final String name;
  final String? address;
  final String? phone;
  final double? lat;
  final double? lon;

  UpdateShopRequest({
    required this.name,
    this.address,
    this.phone,
    this.lat,
    this.lon,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
    };
  }
}
