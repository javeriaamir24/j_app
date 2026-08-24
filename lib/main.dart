import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'package:j_app/screens/splash_screen.dart';
import 'package:j_app/screens/customer/profile_page_screen.dart';

import 'package:j_app/screens/customer/customer_chat.dart';
import 'package:j_app/screens/customer/home_page_screen.dart';
import 'package:j_app/screens/customer/order_history_page.dart';
import 'package:j_app/screens/customer/cart_page_screen.dart';

import 'package:j_app/screens/admin/chat_screen.dart';
import 'package:j_app/screens/admin/users_page.dart';
import 'package:j_app/screens/admin/order_management/order_management.dart';
import 'package:j_app/screens/admin/product_management/product_management.dart';

import 'package:j_app/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.initialize();



  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,

      home: const SplashScreen(),

      routes: {
        '/home': (context) => const HomePage(),
        '/cart': (context) => const CartPage(),
        '/order_history': (context) => const OrderHistoryPage(),
        '/customer_chat': (context) => const CustomerChat(),
        '/profile': (context) => const ProfilePage(),

        '/users': (context) => const UsersPage(),
        '/products': (context) => ProductsPage(),
        '/order_manage': (context) => OrderManagement(),
      },
    ),
  );
}