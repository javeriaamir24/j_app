import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  await Firebase.initializeApp();

  print('Background notification received');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
}

class NotificationService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static Future<void> initialize() async {

    // Register background message handler ONCE
    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    // Ask for notification permission
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

    // Listen for token changes
    _messaging.onTokenRefresh.listen((newToken) {
      saveToken(newToken);
    });

    // Foreground notifications
    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) {
        print('Foreground notification received');

        print(
          'Title: ${message.notification?.title}',
        );

        print(
          'Body: ${message.notification?.body}',
        );
      },
    );

    // Notification tapped while app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(
          (RemoteMessage message) {
        print('Notification tapped');

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
    }
  }

  static Future<void> saveToken(String token) async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    await FirebaseDatabase.instance
        .ref('users/${user.uid}')
        .update({
      'fcmToken': token,
    });

    print('FCM token saved');
  }
}