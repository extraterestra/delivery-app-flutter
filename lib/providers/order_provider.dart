import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class OrderProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final NotificationService? _notificationService;
  List<Order> _availableOrders = [];
  List<Order> _activeOrders = [];
  List<Order> _completedOrders = [];
  bool _loading = false;

  List<Order> get availableOrders => _availableOrders;
  List<Order> get activeOrders => _activeOrders;
  List<Order> get completedOrders => _completedOrders;
  bool get loading => _loading;

  double get todayEarnings {
    final now = DateTime.now();
    return _completedOrders.where((order) {
      if (order.deliveredAt == null) return false;
      return order.deliveredAt!.year == now.year &&
          order.deliveredAt!.month == now.month &&
          order.deliveredAt!.day == now.day;
    }).fold(0.0, (sum, order) => sum + (order.driverPayoutAmount ?? order.deliveryFee));
  }

  int get todayDeliveriesCount {
    final now = DateTime.now();
    return _completedOrders.where((order) {
      if (order.deliveredAt == null) return false;
      return order.deliveredAt!.year == now.year &&
          order.deliveredAt!.month == now.month &&
          order.deliveredAt!.day == now.day;
    }).length;
  }

  OrderProvider([this._notificationService]) {
    _apiService.init();
    _listenToNotifications();
  }

  void _listenToNotifications() {
    _notificationService?.onMessage.listen((message) {
      print('New notification received! Refreshing orders...');
      fetchOrders();
    });
  }

  Future<void> fetchOrders() async {
    _loading = true;
    notifyListeners();
    try {
      print('Fetching available orders from: /api/orders/delivery/available');
      final List<dynamic> data = await _apiService.request('/api/orders/delivery/available');
      print('Received ${data.length} available orders');
      _availableOrders = data.map((json) {
        try {
          return Order.fromJson(json);
        } catch (e) {
          print('Error parsing order JSON: $e');
          print('JSON data: $json');
          rethrow;
        }
      }).toList();
      
      final List<dynamic> activeData = await _apiService.request('/api/orders/delivery/active');
      _activeOrders = activeData.map((json) => Order.fromJson(json)).toList();

      final List<dynamic> completedData = await _apiService.request('/api/orders/delivery/history');
      _completedOrders = completedData.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      print('FATAL Error fetching orders: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _apiService.request(
        '/api/orders/$orderId/status',
        method: 'PATCH',
        body: {'status': status},
      );
      await fetchOrders();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acceptOrder(String orderId) async {
    await updateOrderStatus(orderId, 'accepted');
  }
}
