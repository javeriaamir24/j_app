import 'package:flutter/material.dart';
import 'login_page_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; //for authentication
import 'package:firebase_database/firebase_database.dart'; //for database
import 'package:fluttertoast/fluttertoast.dart';




class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {


  //------------------connecting real time data base------------
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  //------------------connecting real time data base------------


  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController =
  TextEditingController();

  String? emailError;
  String? passwordError;
  String? confirmPasswordError;
  String? nameError;


  //------------------connecting Authentication------------
  FirebaseAuth auth = FirebaseAuth.instance;
  //------------------connecting Authentication------------

  bool _isLoading = false;
  bool hidden = true;
bool hidden2 = true;


  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
            child: SingleChildScrollView(
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
                      "SIGN UP",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),

                    TextField(
                      controller: nameController,
                      cursorColor: Color(0xFFC67C4E),

                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Full Name",
                        hintStyle: const TextStyle(color: Colors.white70),
                        errorText: nameError,
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
                      controller: emailController,
                      cursorColor: Color(0xFFC67C4E),

                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: const TextStyle(color: Colors.white70),
                        errorText: emailError,


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
                      controller: passwordController,
                      cursorColor: Color(0xFFC67C4E),

                      obscureText: hidden,
                      style: const TextStyle(color: Colors.white),
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
                          icon: Icon(
                            hidden
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: const Color(0xFFC67C4E),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: confirmPasswordController,
                      cursorColor: Color(0xFFC67C4E),

                      obscureText: hidden2,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        hintStyle: const TextStyle(color: Colors.white70),
                        errorText: confirmPasswordError,


                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFFC67C4E),
                            width: 2,
                          ),
                        ),

                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              hidden2 = !hidden2;
                            });
                          },
                          icon: Icon(
                            hidden2
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: const Color(0xFFC67C4E),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: _isLoading
                          ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFC67C4E),
                        ),
                      )
                          : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC67C4E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            emailError = emailController.text.trim().isEmpty
                                ? "Fill all Fields"
                                : null;

                            passwordError = passwordController.text.trim().isEmpty
                                ? "Fill all Fields"
                                : null;

                            confirmPasswordError =
                            confirmPasswordController.text.trim().isEmpty
                                ? "Fill all Fields"
                                : null;

                            nameError = nameController.text.trim().isEmpty
                                ? "Fill all Fields"
                                : null;
                          });

                          if (emailError == null &&
                              passwordError == null &&
                              confirmPasswordError == null &&
                              nameError == null) {
                            signup();
                          }
                        },
                        child: const Text(
                          "CREATE ACCOUNT",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        const Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.white70),
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Log In",
                            style: TextStyle(
                              color: Color(0xFFC67C4E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
                ),
    ),
    ),
            ),
    ],
      ),
    );
  }


  void signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Fluttertoast.showToast(msg: "Fill All the fields");

      return;
    }

    if (!email.contains("@") || !email.contains(".")) {
      Fluttertoast.showToast(msg: "Invalid Email");

      return;
    }

    if (password != confirmPassword) {
      Fluttertoast.showToast(msg: "Passwords do not match");

      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user!.sendEmailVerification();


      //------------------connecting real time data base------------
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);

        String uid = userCredential.user!.uid;
        await database.child("users").child(uid).set({
          "name": name,
          "email": email,
          "password": password,
        });
      }
      //------------------connecting real time data base------------


      if (mounted) {
        Fluttertoast.showToast(msg: "Verification email sent");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
     on FirebaseAuthException catch (e) {
      String message = 'Registration failed.';
      if (e.code == 'weak-password') {
        message = 'The password is too weak (min 6 characters).';
      } else if (e.code == 'email-already-in-use') {
        message = 'This email is already registered.';
      } else if (e.code == 'invalid-email') {
        message = 'The format of the email address is invalid.';
      }

      if (mounted) {
        Fluttertoast.showToast(msg: message);
      }
    }

      catch (e) {
      if (mounted) {
            Fluttertoast.showToast(msg: "An unexpected error occured");

      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }}}




