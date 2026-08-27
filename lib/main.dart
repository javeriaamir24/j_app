import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'package:j_app/services/notification_service.dart';
import 'package:j_app/services/navigation_service.dart';

import 'package:j_app/screens/splash_screen.dart';

// CUSTOMER
import 'package:j_app/screens/customer/profile_page_screen.dart';
import 'package:j_app/screens/customer/customer_chat.dart';
import 'package:j_app/screens/customer/home_page_screen.dart';
import 'package:j_app/screens/customer/order_history_page.dart';
import 'package:j_app/screens/customer/cart_page_screen.dart';

// ADMIN
import 'package:j_app/screens/admin/chat_screen.dart';
import 'package:j_app/screens/admin/users_page.dart';
import 'package:j_app/screens/admin/order_management/order_management.dart';
import 'package:j_app/screens/admin/product_management/product_management.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // System UI
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // DO NOT initialize NotificationService here.
  // MaterialApp must exist first.

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();

    // Wait until MaterialApp + Navigator are created.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NotificationService.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // VERY IMPORTANT
      navigatorKey: NavigationService.navigatorKey,

      home: const SplashScreen(),

      routes: {
        // CUSTOMER
        '/home': (context) =>
        const HomePage(),

        '/cart': (context) =>
        const CartPage(),

        '/order_history': (context) =>
        const OrderHistoryPage(),

        '/customer_chat': (context) =>
        const CustomerChat(),

        '/profile': (context) =>
        const ProfilePage(),

        // ADMIN
        '/users': (context) =>
        const UsersPage(),

        '/products': (context) =>
            ProductsPage(),

        '/order_manage': (context) =>
            OrderManagement(),
      },
    );
  }
}