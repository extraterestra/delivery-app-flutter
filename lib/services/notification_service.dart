import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  FirebaseMessaging? _fcm;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Stream to notify listeners (like OrderProvider) about new order updates
  final _onMessageController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get onMessage => _onMessageController.stream;

  Future<void> init() async {
    FirebaseMessaging? fcmInstance;
    try {
      fcmInstance = FirebaseMessaging.instance;
      _fcm = fcmInstance;
    } catch (e) {
      if (kDebugMode) {
        print('Firebase Messaging not supported or initialized: $e');
      }
      return;
    }

    if (fcmInstance == null) return;

    // Request permission
    NotificationSettings settings = await fcmInstance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
      
      // Get token for backend integration
      String? token = await fcmInstance.getToken();
      if (kDebugMode) {
        print("FCM Token: $token");
      }
      // TODO: Send this token to your backend API to register the device

      // Configure local notifications for foreground messages
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      await _localNotifications.initialize(initializationSettings);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showLocalNotification(message);
        _onMessageController.add(message); // Notify listeners
      });
    }
  }

  void dispose() {
    _onMessageController.close();
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    if (kDebugMode) {
      print("Handling a background message: ${message.messageId}");
    }
  }

  void _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'orders_channel',
            'New Orders',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  }
}
