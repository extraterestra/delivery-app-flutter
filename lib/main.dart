import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'config/env_config.dart';
import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';
import 'providers/locale_provider.dart';
import 'services/notification_service.dart';
import 'screens/auth_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/dashboard_screen.dart';

import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting('pl', null);
  await initializeDateFormatting('en', null);

  // Detectar el Flavor desde la plataforma (Android/iOS)
  final String? flavor = await const MethodChannel('flutter/platform').invokeMethod<String>('getFlavor');
  debugPrint('Running with flavor: $flavor');

  // Si no hay flavor (ej. en web o dev sin flag), usamos staging por defecto
  if (flavor == 'production') {
    EnvConfig.init(Environment.production);
  } else {
    EnvConfig.init(Environment.staging);
  }
  
  try {
    if (!kIsWeb) {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }

  final notificationService = NotificationService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
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
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      locale: localeProvider.locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
