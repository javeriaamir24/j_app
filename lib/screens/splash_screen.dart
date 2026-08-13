import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'first_Screen.dart';
import 'saved_screen.dart';
import 'home_page_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  final FlutterSecureStorage _storage =
  const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {

    await Future.delayed(
      const Duration(seconds: 2),
    );

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
          builder: (context) =>
          const SavedScreen(),
        ),
      );

      return;
    }

    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user != null &&
        user.emailVerified) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const HomePage(),
        ),
      );

      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const FirstScreen(),
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