import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'signup_page_screen.dart';
import 'forget_password_page.dart';
import 'customer/home_page_screen.dart';
import 'admin/users_page.dart';
import 'first_Screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? emailError;
  String? passwordError;



  FirebaseAuth auth = FirebaseAuth.instance;
  final FlutterSecureStorage _storage =
  const FlutterSecureStorage();
  bool _isLoading = false;
  bool hidden = true;


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/coffee_icons.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Center(

            child: Container(
              width: 350,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(25),

              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  const Text(
                    "LOGIN",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),


                  const SizedBox(height: 30),


                  TextField(
                    style: TextStyle(color: Colors.white70),
                    cursorColor: Color(0xFFC67C4E),

                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      errorText: emailError,
                      hintStyle: const TextStyle(color: Colors.white70),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFC67C4E),
                          width: 2,
                        ),
                      ),

                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    style: TextStyle(color: Colors.white),
                    cursorColor: Color(0xFFC67C4E),

                    controller: passwordController,
                    obscureText: hidden,
                    decoration: InputDecoration(
                      hintText: "Password",
                      hintStyle: const TextStyle(color: Colors.white70),

                      errorText: passwordError,


                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFC67C4E),
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            hidden = !hidden;
                          });
                        },
                        icon: Icon(hidden ? Icons.visibility: Icons.visibility_off,color: const Color(0xFFC67C4E),),
                      ),
                    ),
                  ),

                  TextButton(onPressed: (){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ForgetPasswordPage(),),);
                  },child:const Text("Forget Password",style: TextStyle(decoration: TextDecoration.underline,color: const Color(0xFFC67C4E),),),
            ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: _isLoading
                        ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFC67C4E),
                      ),
                    )                        : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC67C4E),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          emailError = emailController.text.trim().isEmpty ? "Please enter your email" : null;
                          passwordError = passwordController.text.trim().isEmpty ? "Please enter your password" : null;
                        }
                        );
                        if (emailError == null && passwordError == null) {
                          login();
                        }
                        },
                      child: const Text("LOGIN"),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      const Text("Don't have an account? ",style: TextStyle(color: Colors.white70)),

                      TextButton(

                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupPage(),
                            ),
                          );
                        },
                        child: const Text("Sign Up",style: TextStyle(color: Color(0xFFC67C4E),),),
                      ),

                    ],
                  )

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> login() async {

    final String typedEmail =
    emailController.text.trim();

    final String typedPassword =
    passwordController.text.trim();

    if (typedEmail.isEmpty ||
        typedPassword.isEmpty) {

      Fluttertoast.showToast(
        msg: "Fill all the fields",
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
      await auth.signInWithEmailAndPassword(
        email: typedEmail,
        password: typedPassword,
      );
      User? user = userCredential.user;
      if (user == null) {
        throw Exception("User not found");
      }

      await user.reload();

      user = auth.currentUser;

      if (user == null ||
          !user.emailVerified) {
        await auth.signOut();
        if (mounted) {
          Fluttertoast.showToast(
            msg: "Verify your email first",
          );
        }
        return;
      }
      await _storage.write(
        key: 'saved_email',
        value: typedEmail,
      );
      await _storage.write(
        key: 'saved_password',
        value: typedPassword,
      );
      final DatabaseReference userRef =
      FirebaseDatabase.instance
          .ref("users/${user.uid}");
      final DataSnapshot snapshot =
      await userRef.get();
      if (!snapshot.exists) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: "User data not found",
          );
        }
        return;
      }

      final Map<dynamic, dynamic> userData =
      Map<dynamic, dynamic>.from(
        snapshot.value as Map,
      );
      final String? role =
      userData["role"]
          ?.toString()
          .toLowerCase();

      print("LOGIN EMAIL: ${user.email}");
      print("LOGIN UID: ${user.uid}");
      print("USER ROLE: $role");

      Fluttertoast.showToast(
        msg: "Logged In Successfully",
      );

      if (!mounted) {
        return;
      }if (role == "admin") {

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
      await auth.signOut();

      if (mounted) {
        Fluttertoast.showToast(
          msg: "Invalid user role",
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
            const FirstScreen(),
          ),
              (route) => false,
        );
      }

    } on FirebaseAuthException catch (e) {

      String message =
          "Authentication failed.";

      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {

        message =
        "Invalid email or password.";
      }

      else if (e.code == 'invalid-email') {

        message =
        "Invalid email format.";
      }

      else if (e.code == 'user-disabled') {

        message =
        "This account has been disabled.";
      }

      if (mounted) {
        Fluttertoast.showToast(
          msg: message,
        );
      }

    } catch (e) {

      print("LOGIN ERROR: $e");

      if (mounted) {
        Fluttertoast.showToast(
          msg: "An Unexpected Error Occurred",
        );
      }

    } finally {

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
