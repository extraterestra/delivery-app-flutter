import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';
import 'services/notification_service.dart';
import 'screens/auth_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase first (required for NotificationService)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization warning: $e');
  }

  final notificationService = NotificationService();

  // Defer notification service initialization until after the UI is visible
  // to avoid blocking system services during cold startup.
  void _deferredInit() async {
    try {
      await notificationService.init();
    } catch (e) {
      print('Notification service init failed: $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (_) => OrderProvider(notificationService),
          update: (_, authProvider, orderProvider) {
            final provider = orderProvider ?? OrderProvider(notificationService);
            provider.setCurrentUserId(authProvider.user?.id);
            return provider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
  // Start deferred initialization (non-blocking)
  _deferredInit();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rabka Dostawa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.user != null) {
      return const DashboardScreen();
    }

    return const AuthScreen();
  }
}
