import 'package:flutter/material.dart';
import 'dart:async';
import '../models/order_model.dart';
import '../models/order_history.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class OrderProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final NotificationService? _notificationService;
  List<Order> _availableOrders = [];
  List<Order> _activeOrders = [];
  List<Order> _completedOrders = [];
  List<OrderHistory> _orderHistory = [];
  bool _loading = false;
  Timer? _pollTimer;
  static const int _pollIntervalSeconds = 15;
  String? _currentUserId;

  List<Order> get availableOrders => _availableOrders;
  List<Order> get activeOrders => _activeOrders;
  List<Order> get completedOrders => _completedOrders;
  List<OrderHistory> get orderHistory => _orderHistory;
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
    _startPeriodicPolling();
  }

  void setCurrentUserId(String? userId) {
    final changed = _currentUserId != userId;
    _currentUserId = userId;
    if (changed && userId != null) {
      fetchOrders();
    }
  }

  void _startPeriodicPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: _pollIntervalSeconds), (_) {
      fetchOrders();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _listenToNotifications() {
    _notificationService?.onMessage.listen((_) {
      fetchOrders();
    });
  }

  Future<void> fetchOrders() async {
    if (_loading) return;
    _loading = true;
    notifyListeners();

    try {
      final List<dynamic> data = await _apiService.request('/api/driver/orders');
      final allOrders = data.map((json) => Order.fromJson(json)).toList();

      _availableOrders = allOrders
          .where((o) => ['pending', 'confirmed'].contains(o.status))
          .toList();

      _activeOrders = allOrders
          .where((o) =>
              o.driverId == _currentUserId &&
              ['accepted', 'picked_up', 'in_transit'].contains(o.status))
          .toList();

      _completedOrders = allOrders
          .where((o) => o.driverId == _currentUserId && o.status == 'delivered')
          .toList();
      
      // Update local history from the same list as the backend doesn't have a separate endpoint
      _orderHistory = _completedOrders.map<OrderHistory>((o) => OrderHistory(
        id: o.id,
        orderNumber: o.id.substring(0, 8).toUpperCase(), // Usamos parte del ID como número de orden
        restaurantName: o.restaurant?.name ?? 'Restaurant',
        deliveryAddress: o.customerAddress,
        amount: o.driverPayoutAmount ?? o.deliveryFee,
        status: o.status,
        date: o.deliveredAt ?? DateTime.now(),
      )).toList();

    } catch (e) {
      debugPrint('[OrderProvider] fetchOrders failed: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderHistory() async {
    // History is now updated within fetchOrders locally
    return;
  }

  Future<void> acceptOrder(String orderId) async {
    await _apiService.request('/api/driver/orders/$orderId/accept', method: 'POST');
    await fetchOrders();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _apiService.request(
      '/api/driver/orders/$orderId/status',
      method: 'PATCH',
      body: {'status': status},
    );
    await fetchOrders();
  }

  Future<void> setAvailability(bool available) async {
    await _apiService.request(
      '/api/auth/profile',
      method: 'PATCH',
      body: {'is_available': available},
    );
  }
}
