import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';

import 'customer/home_page_screen.dart';
import 'login_page_screen.dart';
import 'admin/users_page.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {

  final FlutterSecureStorage _storage =
  const FlutterSecureStorage();

  String? savedEmail;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadSavedEmail();
  }

  // =========================================================
  // LOAD SAVED EMAIL
  // =========================================================

  Future<void> loadSavedEmail() async {

    final email = await _storage.read(
      key: 'saved_email',
    );

    if (!mounted) {
      return;
    }

    setState(() {
      savedEmail = email;
    });
  }

  // =========================================================
  // CONTINUE LOGIN
  // =========================================================

  Future<void> continueLogin() async {

    setState(() {
      loading = true;
    });

    try {

      // GET SAVED LOGIN DETAILS

      final email = await _storage.read(
        key: 'saved_email',
      );

      final password = await _storage.read(
        key: 'saved_password',
      );

      // IF DETAILS ARE MISSING

      if (email == null || password == null) {

        await goToLogin();

        return;
      }

      // =====================================================
      // FIREBASE LOGIN
      // =====================================================

      final UserCredential credential =
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;

      if (user == null) {
        throw Exception("User not found");
      }

      // Refresh Firebase user

      await user.reload();

      final currentUser =
          FirebaseAuth.instance.currentUser;

      // =====================================================
      // CHECK EMAIL VERIFICATION
      // =====================================================

      if (currentUser == null ||
          !currentUser.emailVerified) {

        await FirebaseAuth.instance.signOut();

        throw Exception("Email not verified");
      }

      // =====================================================
      // GET USER ROLE
      // =====================================================

      final snapshot =
      await FirebaseDatabase.instance
          .ref("users/${currentUser.uid}/role")
          .get();

      final role =
      snapshot.value
          ?.toString()
          .toLowerCase();

      print("SAVED LOGIN ROLE: $role");

      if (!mounted) {
        return;
      }

      Fluttertoast.showToast(
        msg: "Welcome Back!",
      );

      if (role == "admin") {

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
            const UsersPage(),
          ),
              (route) => false,
        );

        return;
      }
      if (role == "customer") {

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
            const HomePage(),
          ),
              (route) => false,
        );

        return;
      }

      // =====================================================
      // INVALID ROLE
      // =====================================================

      await FirebaseAuth.instance.signOut();

      await _storage.delete(
        key: 'saved_email',
      );

      await _storage.delete(
        key: 'saved_password',
      );

      await _storage.delete(
        key: 'remember_login',
      );

      Fluttertoast.showToast(
        msg: "Invalid user role",
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const LoginPage(),
        ),
            (route) => false,
      );

    } catch (e) {

      print("SAVED LOGIN ERROR: $e");

      await _storage.delete(
        key: 'saved_email',
      );

      await _storage.delete(
        key: 'saved_password',
      );

      await _storage.delete(
        key: 'remember_login',
      );

      await FirebaseAuth.instance.signOut();

      if (!mounted) {
        return;
      }

      Fluttertoast.showToast(
        msg: "Please login again",
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const LoginPage(),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          loading = false;
        });

      }
    }
  }

  // =========================================================
  // GO TO LOGIN
  // =========================================================

  Future<void> goToLogin() async {

    await _storage.delete(
      key: 'remember_login',
    );

    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const LoginPage(),
      ),
    );
  }

  // =========================================================
  // USE ANOTHER ACCOUNT
  // =========================================================

  Future<void> useAnotherAccount() async {

    await FirebaseAuth.instance.signOut();

    await _storage.delete(
      key: 'saved_email',
    );

    await _storage.delete(
      key: 'saved_password',
    );

    await _storage.delete(
      key: 'remember_login',
    );

    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const LoginPage(),
      ),
    );
  }

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        toolbarHeight: 100,

        backgroundColor: Colors.black87,

        title: const Text(
          "Saved Login",
        ),

        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
      ),

      body: Center(

        child: Padding(
          padding: const EdgeInsets.all(25),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              const SizedBox(height: 20),

              const Text(
                "Welcome Back!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                savedEmail ?? "Loading...",

                style: const TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(

                  onPressed:
                  loading
                      ? null
                      : continueLogin,

                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFFC67C4E),

                    foregroundColor:
                    Colors.white,
                  ),

                  child: loading

                      ? const SizedBox(
                    width: 25,
                    height: 25,

                    child:
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )

                      : const Text(
                    "CONTINUE",
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(

                onPressed:
                loading
                    ? null
                    : useAnotherAccount,

                child: const Text(
                  "Use Another Account",

                  style: TextStyle(
                    color: Color(0xFFC67C4E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}