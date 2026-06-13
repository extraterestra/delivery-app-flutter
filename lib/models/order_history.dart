class OrderHistory {
  final String id;
  final String orderNumber;
  final DateTime date;
  final double amount;
  final String status;
  final String restaurantName;
  final String deliveryAddress;

  OrderHistory({
    required this.id,
    required this.orderNumber,
    required this.date,
    required this.amount,
    required this.status,
    required this.restaurantName,
    required this.deliveryAddress,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    return OrderHistory(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      date: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      amount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'COMPLETED',
      restaurantName: json['restaurant']?['name'] ?? 'Unknown Restaurant',
      deliveryAddress: json['deliveryAddress'] ?? 'No address',
    );
  }
}
