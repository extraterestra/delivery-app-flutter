import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
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

  bool _isSameLocalDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  double _orderAmount(Order order) => order.driverPayoutAmount ?? order.deliveryFee;

  List<Order> get todayCompletedOrders {
    final now = DateTime.now();
    return _completedOrders.where((order) {
      final deliveredAt = order.deliveredAt;
      return deliveredAt != null && _isSameLocalDay(deliveredAt.toLocal(), now);
    }).toList();
  }

  double get todayEarnings {
    return todayCompletedOrders.fold(0.0, (sum, order) => sum + _orderAmount(order));
  }

  int get todayDeliveriesCount => todayCompletedOrders.length;

  double get totalEarnings {
    return _completedOrders.fold(0.0, (sum, order) => sum + _orderAmount(order));
  }

  int get totalDeliveriesCount => _completedOrders.length;

  Map<String, List<Order>> groupedCompletedOrdersByDate(String locale) {
    final groupedOrders = <String, List<Order>>{};

    for (final order in _completedOrders) {
      final deliveredAt = order.deliveredAt;
      if (deliveredAt == null) continue;

      final localDeliveredAt = deliveredAt.toLocal();
      final dateKey = DateFormat('d MMM yyyy', locale).format(localDeliveredAt);
      groupedOrders.putIfAbsent(dateKey, () => []).add(order);
    }

    return groupedOrders;
  }

  List<String> sortedCompletedOrderDateKeys(String locale) {
    final groupedOrders = groupedCompletedOrdersByDate(locale);
    final sortedDates = groupedOrders.keys.toList();
    sortedDates.sort((a, b) {
      final dateA = groupedOrders[a]!.first.deliveredAt!.toLocal();
      final dateB = groupedOrders[b]!.first.deliveredAt!.toLocal();
      return dateB.compareTo(dateA);
    });
    return sortedDates;
  }

  double completedOrderGroupEarnings(List<Order> orders) {
    return orders.fold(0.0, (sum, order) => sum + _orderAmount(order));
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
              ['accepted', 'picked_up', 'in_transit', 'in_delivery', 'ready'].contains(o.status))
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

  Future<Order?> fetchOrderDetails(String orderId) async {
    try {
      final dynamic data = await _apiService.request('/api/driver/orders/$orderId');
      final order = Order.fromJson(data);
      
      // Update in available orders
      final indexAvailable = _availableOrders.indexWhere((o) => o.id == orderId);
      if (indexAvailable != -1) {
        _availableOrders[indexAvailable] = order;
      }
      
      // Update in active orders
      final indexActive = _activeOrders.indexWhere((o) => o.id == orderId);
      if (indexActive != -1) {
        _activeOrders[indexActive] = order;
      }

      notifyListeners();
      return order;
    } catch (e) {
      debugPrint('[OrderProvider] fetchOrderDetails failed: $e');
      return null;
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
