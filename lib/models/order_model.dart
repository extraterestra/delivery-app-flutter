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
  final String? id;
  final String name;
  final String address;
  final String? phone;
  final double lat;
  final double lng;

  Restaurant({
    this.id,
    required this.name,
    required this.address,
    this.phone,
    required this.lat,
    required this.lng,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id']?.toString(),
      name: (json['name'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      phone: json['phone']?.toString(),
      lat: _parseDoubleOrZero(json['lat']),
      lng: _parseDoubleOrZero(json['lng']),
    );
  }
}

class Order {
  final String id;
  final String? restaurantId;
  final String? driverId;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double deliveryFee;
  final int? estimatedTimeMinutes;
  final String customerName;
  final String customerAddress;
  final String customerPhone;
  final String? orderDetails;
  final double customerLat;
  final double customerLng;
  final Restaurant? restaurant;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final double? driverPayoutAmount;
  final String? driverPaymentStatus;
  final DateTime? driverPaidAt;

  Order({
    required this.id,
    this.restaurantId,
    this.driverId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.deliveryFee,
    this.estimatedTimeMinutes,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhone,
    this.orderDetails,
    required this.customerLat,
    required this.customerLng,
    this.restaurant,
    this.pickedUpAt,
    this.deliveredAt,
    this.driverPayoutAmount,
    this.driverPaymentStatus,
    this.driverPaidAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      restaurantId: json['restaurant_id']?.toString(),
      driverId: json['driver_id']?.toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      deliveryFee: _parseDoubleOrZero(json['delivery_fee']),
      estimatedTimeMinutes: json['estimated_time_minutes'] is int
          ? json['estimated_time_minutes']
          : int.tryParse('${json['estimated_time_minutes'] ?? ''}'),
      customerName: (json['customer_name'] ?? '').toString(),
      customerAddress: (json['customer_address'] ?? '').toString(),
      customerPhone: (json['customer_phone'] ?? '').toString(),
      orderDetails: json['order_details']?.toString(),
      customerLat: _parseDoubleOrZero(json['customer_lat']),
      customerLng: _parseDoubleOrZero(json['customer_lng']),
      restaurant: json['restaurant'] != null ? Restaurant.fromJson(json['restaurant']) : null,
      pickedUpAt: json['picked_up_at'] != null ? DateTime.tryParse(json['picked_up_at'].toString()) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.tryParse(json['delivered_at'].toString()) : null,
      driverPayoutAmount: json['driver_payout_amount'] != null ? _parseNullableDouble(json['driver_payout_amount']) : null,
      driverPaymentStatus: json['driver_payment_status']?.toString(),
      driverPaidAt: json['driver_paid_at'] != null ? DateTime.tryParse(json['driver_paid_at'].toString()) : null,
    );
  }
}
