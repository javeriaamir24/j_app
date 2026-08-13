import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:j_app/widgets/bottom_nav_bar.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  User? user;

  TextEditingController newPasswordController =
  TextEditingController();

  TextEditingController confirmPasswordController =
  TextEditingController();

  bool hiddenNewPassword = true;
  bool hiddenConfirmPassword = true;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    user = auth.currentUser;
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 100,

        title:  Text(
          user?.displayName ?? "No name",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Stack(
        children: [


          SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [

                const SizedBox(height: 30),
                const SizedBox(height: 30),

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        "Account Information",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Email",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        user?.email ?? "",
                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Email Verification",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        user?.emailVerified == true
                            ? "Verified"
                            : "Not Verified",

                        style: TextStyle(
                          color: user?.emailVerified == true
                              ? const Color(0xFFC67C4E)
                              : Colors.white,

                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const SizedBox(height: 30),

                // CHANGE PASSWORD
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        "Change Password",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // NEW PASSWORD
                      TextField(
                        controller: newPasswordController,

                        obscureText: hiddenNewPassword,

                        style: const TextStyle(
                          color: Colors.white,
                        ),

                        decoration: InputDecoration(
                          hintText: "New Password",

                          hintStyle: const TextStyle(
                            color: Colors.white70,
                          ),

                          focusedBorder:
                          const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFC67C4E),
                              width: 2,
                            ),
                          ),

                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                hiddenNewPassword =
                                !hiddenNewPassword;
                              });
                            },

                            icon: Icon(
                              hiddenNewPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,

                              color:
                              const Color(0xFFC67C4E),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // CONFIRM PASSWORD
                      TextField(
                        controller: confirmPasswordController,

                        obscureText:
                        hiddenConfirmPassword,

                        style: const TextStyle(
                          color: Colors.white,
                        ),

                        decoration: InputDecoration(
                          hintText:
                          "Confirm New Password",

                          hintStyle: const TextStyle(
                            color: Colors.white70,
                          ),

                          focusedBorder:
                          const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFC67C4E),
                              width: 2,
                            ),
                          ),

                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                hiddenConfirmPassword =
                                !hiddenConfirmPassword;
                              });
                            },

                            icon: Icon(
                              hiddenConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,

                              color:
                              const Color(0xFFC67C4E),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // BUTTON
                      SizedBox(
                        width: double.infinity,

                        child: isLoading
                            ? const Center(
                          child:
                          CircularProgressIndicator(
                            color:
                            Color(0xFFC67C4E),
                          ),
                        )
                            : ElevatedButton(
                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(
                                0xFFC67C4E),

                            foregroundColor:
                            Colors.white,

                            padding:
                            const EdgeInsets
                                .symmetric(
                              vertical: 14,
                            ),

                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                  15),
                            ),
                          ),

                          onPressed: changePassword,

                          child: const Text(
                            "CHANGE PASSWORD",

                            style: TextStyle(
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 4,
      ),
    );
  }

  void changePassword() async {
    String newPassword =
    newPasswordController.text.trim();

    String confirmPassword =
    confirmPasswordController.text.trim();

    if (newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      Fluttertoast.showToast(
        msg: "Fill all the fields",
      );

      return;
    }

    if (newPassword.length < 6) {
      Fluttertoast.showToast(
        msg: "Password must be at least 6 characters",
      );

      return;
    }

    if (newPassword != confirmPassword) {
      Fluttertoast.showToast(
        msg: "Passwords do not match",
      );

      return;
    }

    if (user == null) {
      Fluttertoast.showToast(
        msg: "User not found",
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await user!.updatePassword(newPassword);

      newPasswordController.clear();
      confirmPasswordController.clear();

      Fluttertoast.showToast(
        msg: "Password changed successfully",
      );
    }

    on FirebaseAuthException catch (e) {
      String message =
          "Unable to change password";

      if (e.code == "requires-recent-login") {
        message =
        "Please login again before changing your password";
      } else if (e.code == "weak-password") {
        message = "Password is too weak";
      }

      Fluttertoast.showToast(
        msg: message,
      );
    }

    catch (e) {
      Fluttertoast.showToast(
        msg: "An unexpected error occurred",
      );
    }

    finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}