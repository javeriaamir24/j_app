import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'first_Screen.dart';
import 'saved_screen.dart';
import 'customer/home_page_screen.dart';
import 'admin/users_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:j_app/firebase_options.dart';
import 'package:j_app/services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterSecureStorage _storage =
  const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    startApp();
  }

  Future<void> startApp() async {
    print("START APP");

    try {
      print("Initializing Firebase...");

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      print("Firebase initialized");

      print("Initializing notifications...");

      await NotificationService.initialize();

      print("Notifications initialized");

      await checkLogin();
    } catch (e, stackTrace) {
      print("START APP ERROR: $e");
      print(stackTrace);
    }
  }

  Future<void> checkLogin() async {
    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) {
      return;
    }

    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null || !user.emailVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const FirstScreen(),
        ),
      );

      return;
    }

    final snapshot = await FirebaseDatabase.instance
        .ref("users/${user.uid}/role")
        .get();

    final role = snapshot.value?.toString();

    if (!mounted) {
      return;
    }

    if (role == "admin") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const UsersPage(),
        ),
      );

      return;
    }

    if (role == "customer") {
      final String? remember =
      await _storage.read(
        key: 'remember_login',
      );

      if (!mounted) {
        return;
      }

      if (remember == 'true') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SavedScreen(),
          ),
        );

        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );

      return;
    }

    await FirebaseAuth.instance.signOut();

    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const FirstScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/images/app_icon.png",
          width: 120,
          height: 120,
        ),
      ),
    );
  }
}