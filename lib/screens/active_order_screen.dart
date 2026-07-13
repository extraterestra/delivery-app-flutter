import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../models/order_model.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';

class ActiveOrderScreen extends StatefulWidget {
  final Order order;
  const ActiveOrderScreen({super.key, required this.order});

  @override
  State<ActiveOrderScreen> createState() => _ActiveOrderScreenState();
}

class _ActiveOrderScreenState extends State<ActiveOrderScreen> {
  bool _isUpdating = false;
  Position? _currentPosition;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });
  }

  Future<void> _updateStatus(String newStatus) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isUpdating = true);
    try {
      await Provider.of<OrderProvider>(context, listen: false)
          .updateOrderStatus(widget.order.id, newStatus);
      await Provider.of<AuthProvider>(context, listen: false).fetchMe();
      if (newStatus == 'delivered') {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorMessage(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  void _launchNavigation(double lat, double lng) async {
    final url = 'google.navigation:q=$lat,$lng';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final webUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    
    final currentOrder = orderProvider.activeOrders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );

    final restaurantLatLng = LatLng(currentOrder.restaurant?.lat ?? 0, currentOrder.restaurant?.lng ?? 0);
    final customerLatLng = LatLng(currentOrder.customerLat, currentOrder.customerLng);
    final driverLatLng = _currentPosition != null 
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude) 
        : restaurantLatLng;

    // Calculate distance (simplified)
    double distanceKm = 0;
    if (_currentPosition != null) {
      final targetLat = currentOrder.status == 'accepted' ? restaurantLatLng.latitude : customerLatLng.latitude;
      final targetLng = currentOrder.status == 'accepted' ? restaurantLatLng.longitude : customerLatLng.longitude;
      
      distanceKm = Geolocator.distanceBetween(
        _currentPosition!.latitude, 
        _currentPosition!.longitude, 
        targetLat, 
        targetLng
      ) / 1000;
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.activeDelivery, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(currentOrder.restaurant?.name ?? '', style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(currentOrder.driverPayoutAmount ?? currentOrder.deliveryFee).toStringAsFixed(2)} zł', 
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)
                ),
                Text(l10n.distance(distanceKm.toStringAsFixed(0)), style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Map Section
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: restaurantLatLng,
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.rabka.dostawa',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: driverLatLng,
                          width: 40,
                          height: 40,
                          child: const Icon(LucideIcons.navigation, color: Colors.blue, size: 30),
                        ),
                        Marker(
                          point: restaurantLatLng,
                          width: 40,
                          height: 40,
                          child: const Icon(LucideIcons.mapPin, color: Colors.green, size: 35),
                        ),
                        Marker(
                          point: customerLatLng,
                          width: 40,
                          height: 40,
                          child: const Icon(LucideIcons.mapPin, color: Colors.red, size: 35),
                        ),
                      ],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [driverLatLng, restaurantLatLng, customerLatLng],
                          color: Colors.orange,
                          strokeWidth: 4,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Details Section
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _StatusTimeline(status: currentOrder.status),
                  const SizedBox(height: 16),
                  _DestinationCard(
                    title: currentOrder.status == 'accepted' ? l10n.pickupFrom : l10n.deliveryTo,
                    name: currentOrder.status == 'accepted' ? (currentOrder.restaurant?.name ?? '') : currentOrder.customerName,
                    address: currentOrder.status == 'accepted' ? (currentOrder.restaurant?.address ?? '') : currentOrder.customerAddress,
                    onNavigate: () {
                      if (currentOrder.status == 'accepted') {
                        _launchNavigation(restaurantLatLng.latitude, restaurantLatLng.longitude);
                      } else {
                        _launchNavigation(customerLatLng.latitude, customerLatLng.longitude);
                      }
                    },
                    onCall: () => _makePhoneCall(currentOrder.status == 'accepted' ? (currentOrder.restaurant?.phone ?? '') : currentOrder.customerPhone),
                  ),
                  const SizedBox(height: 16),
                  _InfoCard(
                    title: l10n.payout,
                    name: '${(currentOrder.driverPayoutAmount ?? currentOrder.deliveryFee).toStringAsFixed(2)} zł',
                    address: currentOrder.driverPaymentStatus == 'paid' ? l10n.paid : l10n.pending,
                    icon: LucideIcons.dollarSign,
                    color: const Color(0xFFE57C50),
                  ),
                  if (currentOrder.orderDetails != null) ...[
                    const SizedBox(height: 16),
                    _DetailsCard(details: currentOrder.orderDetails!),
                  ],
                  const SizedBox(height: 16),
                  _ActionButtons(
                    status: currentOrder.status,
                    isUpdating: _isUpdating,
                    onUpdate: _updateStatus,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final String status;
  const _StatusTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.deliveryStatus, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _Step(label: l10n.orderAccepted, isDone: true),
          _Connector(isDone: status != 'accepted'),
          _Step(
            label: l10n.pickedUpFromRestaurant,
            isDone: status == 'picked_up' || status == 'delivered',
          ),
          _Connector(isDone: status == 'delivered'),
          _Step(label: l10n.deliveredToCustomer, isDone: status == 'delivered'),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String label;
  final bool isDone;

  const _Step({required this.label, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isDone ? Colors.green : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDone ? Icons.check : Icons.circle,
            color: isDone ? Colors.white : Colors.grey[400],
            size: 14,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
            color: isDone ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _Connector extends StatelessWidget {
  final bool isDone;
  const _Connector({required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 11),
      height: 20,
      width: 2,
      color: isDone ? Colors.green : Colors.grey[200],
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final String title;
  final String name;
  final String address;
  final VoidCallback onNavigate;
  final VoidCallback onCall;

  const _DestinationCard({
    required this.title,
    required this.name,
    required this.address,
    required this.onNavigate,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(LucideIcons.store, color: Colors.orange, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    Text(address, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onNavigate,
                  icon: const Icon(LucideIcons.send, size: 18),
                  label: Text(l10n.navigate),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: onCall,
                icon: const Icon(LucideIcons.phone, color: Colors.grey),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String name;
  final String address;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.name,
    required this.address,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(address, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final String details;
  const _DetailsCard({required this.details});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.package, size: 16),
              const SizedBox(width: 8),
              Text(l10n.details, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(details, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final String status;
  final bool isUpdating;
  final Function(String) onUpdate;

  const _ActionButtons({
    required this.status,
    required this.isUpdating,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    String label = '';
    Color color = Colors.orange;
    String nextStatus = '';

    if (status == 'accepted') {
      label = l10n.iHavePickedUpOrder;
      nextStatus = 'picked_up';
    } else if (status == 'picked_up' || status == 'in_transit') {
      label = l10n.deliveredToCustomer;
      color = Colors.green;
      nextStatus = 'delivered';
    } else {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isUpdating ? null : () => onUpdate(nextStatus),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: isUpdating
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
