import 'package:flutter/material.dart';
import 'package:j_app/screens/customer_chat.dart';
import 'package:j_app/screens/home_page_screen.dart';
import 'package:j_app/screens/order_history_page.dart';
import 'package:j_app/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:j_app/screens/profile_page_screen.dart';
import 'package:j_app/screens/cart_page_screen.dart';
import 'package:j_app/screens/customer_chat.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('cartBox');
  await Hive.openBox('orderBox');
  await Hive.openBox('wishlistBox');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,

      home: const SplashScreen(),

      routes: {
        '/home': (context) => const HomePage(),
        '/cart': (context) => const CartPage(),
        '/order': (context) => const OrderHistoryPage(),
        '/chat': (context) => const CustomerChat(),
        '/profile': (context) => const ProfilePage(),



      },
    ),
  );
}