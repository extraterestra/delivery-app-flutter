double? _parseNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) {
    final s = value.trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }
  return null;
}

double _parseDoubleOrZero(dynamic value) {
  final v = _parseNullableDouble(value);
  return v ?? 0.0;
}

class Restaurant {
  final String name;
  final String address;
  final String? phone;
  final double lat;
  final double lng;

  Restaurant({
    required this.name,
    required this.address,
    this.phone,
    required this.lat,
    required this.lng,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      lat: _parseDoubleOrZero(json['lat']),
      lng: _parseDoubleOrZero(json['lng']),
    );
  }
}

class Order {
  final String id;
  final String status;
  final DateTime createdAt;
  final double deliveryFee;
  final int? estimatedTimeMinutes;
  final String customerName;
  final String customerAddress;
  final String customerPhone;
  final String? orderDetails;
  final double customerLat;
  final double customerLng;
  final Restaurant? restaurant;
  final DateTime? deliveredAt;
  final double? driverPayoutAmount;

  Order({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.deliveryFee,
    this.estimatedTimeMinutes,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhone,
    this.orderDetails,
    required this.customerLat,
    required this.customerLng,
    this.restaurant,
    this.deliveredAt,
    this.driverPayoutAmount,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      deliveryFee: _parseDoubleOrZero(json['delivery_fee']),
      estimatedTimeMinutes: json['estimated_time_minutes'],
      customerName: json['customer_name'],
      customerAddress: json['customer_address'],
      customerPhone: json['customer_phone'],
      orderDetails: json['order_details'],
      customerLat: _parseDoubleOrZero(json['customer_lat']),
      customerLng: _parseDoubleOrZero(json['customer_lng']),
      restaurant: json['restaurant'] != null ? Restaurant.fromJson(json['restaurant']) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at']) : null,
      driverPayoutAmount: json['driver_payout_amount'] != null ? _parseNullableDouble(json['driver_payout_amount']) : null,
    );
  }
}
