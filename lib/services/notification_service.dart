import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:j_app/services/navigation_service.dart';
import 'package:j_app/screens/customer/customer_chat.dart';
import 'package:j_app/screens/customer/order_history_page.dart';
import 'package:j_app/screens/admin/chat_screen.dart';
import 'package:j_app/screens/admin/order_management/order_management.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  await Firebase.initializeApp();

  print('Background notification received');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
}

class NotificationService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    // Ask notification permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    final token = await _messaging.getToken();

    print('FCM TOKEN: $token');

    if (token != null) {
      await saveToken(token);
    }

    // Token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      saveToken(newToken);
    });

    // Foreground notification
    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) {
        print('Foreground notification received');

        print(
          'Title: ${message.notification?.title}',
        );

        print(
          'Body: ${message.notification?.body}',
        );

        print(
          'Data: ${message.data}',
        );
      },
    );

    // Notification tapped while app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(
          (RemoteMessage message) {
        print('Notification tapped from background');

        print(
          'Title: ${message.notification?.title}',
        );

        print(
          'Body: ${message.notification?.body}',
        );

        print(
          'Data: ${message.data}',
        );

        handleNotificationTap(message);
      },
    );

    // Notification tapped while app was completely closed
    final initialMessage =
    await _messaging.getInitialMessage();

    if (initialMessage != null) {
      print('App opened from notification');

      print(
        'Title: ${initialMessage.notification?.title}',
      );

      print(
        'Body: ${initialMessage.notification?.body}',
      );

      print(
        'Data: ${initialMessage.data}',
      );

      // Wait until MaterialApp and Navigator are ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleNotificationTap(initialMessage);
      });
    }
  }

  static Future<void> saveToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('No logged-in user. Token not saved.');
      return;
    }

    try {
      await FirebaseDatabase.instance
          .ref('users/${user.uid}')
          .update({
        'fcmToken': token,
      });

      print('FCM token saved');
    } catch (e) {
      print('FCM token save error: $e');
    }
  }

  static void handleNotificationTap(
      RemoteMessage message) {
    final data = message.data;

    final type = data['type']?.toString();

    print('Handling notification type: $type');

    if (type == null || type.isEmpty) {
      print('Notification type is missing');
      return;
    }

    switch (type) {
      case 'chat_customer':
        _openAdminChat(data);
        break;

      case 'chat_admin':
        _openCustomerChat();
        break;

      case 'order_placed':
        _openOrderManagement();
        break;

      case 'order_status':
        _openOrderHistory();
        break;

      default:
        print(
          'Unknown notification type: $type',
        );
    }
  }

  static void _openCustomerChat() {
    final navigator = NavigationService.navigator;

    if (navigator == null) {
      print('Navigator not ready');
      return;
    }

    navigator.push(
      MaterialPageRoute(
        builder: (context) =>
        const CustomerChat(),
      ),
    );
  }

  static void _openAdminChat(
      Map<String, dynamic> data) {
    final navigator = NavigationService.navigator;

    if (navigator == null) {
      print('Navigator not ready');
      return;
    }



    final customerId =
        data['customerId']?.toString() ??
            data['senderId']?.toString() ??
            data['receiverId']?.toString();

    final customerName =
        data['customerName']?.toString() ??
            data['senderName']?.toString() ??
            'Customer';

    if (customerId == null ||
        customerId.isEmpty) {
      print(
        'Customer ID missing from chat notification',
      );

      return;
    }

    navigator.push(
      MaterialPageRoute(
        builder: (context) => AdminChat(
          customerId: customerId,
          customerName: customerName,
        ),
      ),
    );
  }

  static void _openOrderManagement() {
    final navigator = NavigationService.navigator;

    if (navigator == null) {
      print('Navigator not ready');
      return;
    }

    navigator.push(
      MaterialPageRoute(
        builder: (context) =>
            OrderManagement(),
      ),
    );
  }

  static void _openOrderHistory() {
    final navigator = NavigationService.navigator;

    if (navigator == null) {
      print('Navigator not ready');
      return;
    }

    navigator.push(
      MaterialPageRoute(
        builder: (context) =>
        const OrderHistoryPage(),
      ),
    );
  }
}