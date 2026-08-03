import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../l10n/app_localizations.dart';
import '../models/order_model.dart';
import '../providers/order_provider.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late Order _currentOrder;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    if (_currentOrder.items.isEmpty) {
      _loadOrderDetails();
    }
  }

  Future<void> _loadOrderDetails() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<OrderProvider>(context, listen: false);
    final updatedOrder = await provider.fetchOrderDetails(_currentOrder.id);
    if (updatedOrder != null && mounted) {
      setState(() {
        _currentOrder = updatedOrder;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orderDetailsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrderDetails,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadOrderDetails,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Header Info
                    _buildInfoCard(context),
                    const SizedBox(height: 20),
                    Text(
                      l10n.details,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    // Items List
                    if (_currentOrder.items.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(_currentOrder.orderDetails ?? l10n.noAvailableOrders),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _currentOrder.items.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = _currentOrder.items[index];
                          return _buildItemRow(context, item);
                        },
                      ),
                    const Divider(height: 32, thickness: 2),
                    _buildSummaryRow(context, l10n),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(LucideIcons.store, _currentOrder.restaurant?.name ?? ''),
            const SizedBox(height: 8),
            _buildInfoRow(LucideIcons.mapPin, _currentOrder.restaurant?.address ?? ''),
            const Divider(height: 24),
            _buildInfoRow(LucideIcons.user, _currentOrder.customerName),
            const SizedBox(height: 8),
            _buildInfoRow(LucideIcons.navigation, _currentOrder.customerAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(BuildContext context, OrderItem item) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Text(
                'x${item.quantity}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          if (item.weight != null)
            Text(
              '${l10n.unitWeight}: ${l10n.weight(item.weight!.toStringAsFixed(2))}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          if (item.notes != null && item.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Note: ${item.notes}',
                style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: Colors.orange),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.totalWeight(''),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          l10n.weight(_currentOrder.calculatedTotalWeight.toStringAsFixed(2)),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
        ),
      ],
    );
  }
}
