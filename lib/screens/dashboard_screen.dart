import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import 'orders_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final profile = authProvider.profile;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Gradient
            Container(
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Witaj, ${profile?.fullName.split(' ')[0] ?? 'Kierowco'}!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            orderProvider.activeOrders.isEmpty
                                ? 'Brak aktywnych dostaw'
                                : 'Masz ${orderProvider.activeOrders.length} aktywną dostawę',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: const Icon(LucideIcons.user, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Stats Cards
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Dzisiaj',
                        '${orderProvider.todayEarnings.toStringAsFixed(2)} zł',
                        '${orderProvider.todayDeliveriesCount} dostaw',
                        LucideIcons.dollarSign,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Łącznie',
                        '${profile?.totalEarnings.toStringAsFixed(2) ?? '0.00'} zł',
                        '${orderProvider.completedOrders.length} dostaw',
                        LucideIcons.trendingUp,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Szybkie działania',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Available Orders Card
                  _buildActionCard(
                    'Dostępne zamówienia',
                    '${orderProvider.availableOrders.length} oczekujących',
                    LucideIcons.package,
                    Colors.amber,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OrdersScreen()),
                    ),
                    badge: orderProvider.availableOrders.length,
                  ),

                  const SizedBox(height: 12),

                  // Active Delivery Card (Show only if active)
                  if (orderProvider.activeOrders.isNotEmpty)
                    _buildActionCard(
                      'Aktywna dostawa',
                      'Kliknij, aby kontynuować',
                      LucideIcons.clock,
                      Colors.orange,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OrdersScreen()),
                      ),
                      isPrimary: true,
                    ),

                  const SizedBox(height: 12),

                  // History Card
                  _buildActionCard(
                    'Historia dostaw',
                    '${orderProvider.completedOrders.length} ukończonych',
                    LucideIcons.checkCircle,
                    Colors.green,
                    onTap: () {
                      // TODO: Implement History Screen
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subValue, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(subValue, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
    int? badge,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? Border.all(color: Colors.orange, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            if (badge != null && badge > 0)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                child: Text(
                  badge.toString(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              )
            else
              const Icon(LucideIcons.chevronRight, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
