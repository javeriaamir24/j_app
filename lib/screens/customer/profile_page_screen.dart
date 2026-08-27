import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:j_app/widgets/customers_bottom_nav_bar.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  User? user;

  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool hiddenNewPassword = true;
  bool hiddenConfirmPassword = true;
  bool isLoading = false;
  bool uploadingImage = false;

  File? selectedProfileImage;
  static const Color brown = Color(0xFFC67C4E);

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

  Future<void> pickProfileImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result == null ||
        result.files.single.path == null) {
      return;
    }

    setState(() {
      selectedProfileImage =
          File(result.files.single.path!);
    });

    await uploadProfileImage();
  }

  Future<String?> uploadImage(File imageFile) async {
    const cloudName = 'qaakxnsu';
    const uploadPreset = 'cafe_profiles';

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest(
      'POST',
      url,
    );

    request.fields['upload_preset'] = uploadPreset;

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      ),
    );

    final response = await request.send();

    final responseData =
    await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseData);

      return data['secure_url'];
    }

    print(
      'Cloudinary error: $responseData',
    );

    return null;
  }

  Future<void> uploadProfileImage() async {
    if (selectedProfileImage == null ||
        user == null) {
      return;
    }

    setState(() {
      uploadingImage = true;
    });

    try {
      final imageUrl = await uploadImage(
        selectedProfileImage!,
      );

      if (imageUrl == null) {
        throw Exception(
          "Image upload failed",
        );
      }

      // Save image URL in Firebase Authentication
      await user!.updatePhotoURL(imageUrl);

      // Save image URL in Realtime Database
      await FirebaseDatabase.instance
          .ref("users")
          .child(user!.uid)
          .update({
        "profile_picture": imageUrl,
      });

      // Reload Firebase user
      await user!.reload();

      user = auth.currentUser;

      if (!mounted) return;

      setState(() {});

      Fluttertoast.showToast(
        msg: "Profile picture updated",
      );
    } catch (e) {
      print(
        "Profile image error: $e",
      );

      Fluttertoast.showToast(
        msg: "Failed to upload profile picture",
      );
    } finally {
      if (mounted) {
        setState(() {
          uploadingImage = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final photoUrl = user?.photoURL;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 100,

        title: Text(
          user?.displayName ?? "No name",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 20),

            Stack(
              children: [
                Container(
                  width: 130,
                  height: 130,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: brown,
                      width: 3,
                    ),
                  ),

                  child: ClipOval(
                    child: uploadingImage
                        ? const Center(
                      child: CircularProgressIndicator(
                        color: brown,
                      ),
                    )
                        : photoUrl != null && photoUrl.isNotEmpty
                        ? Image.network(
                      photoUrl,
                      width: 130,
                      height: 130,
                      fit: BoxFit.cover,
                      errorBuilder: (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return const Icon(
                          Icons.person,
                          size: 70,
                          color: Colors.black54,
                        );
                      },
                    )
                        : const Icon(
                      Icons.person,
                      size: 70,
                      color: Colors.black54,
                    ),
                  ),
                ),

                Positioned(
                  right: 0,
                  bottom: 0,

                  child: GestureDetector(
                    onTap: uploadingImage
                        ? null
                        : pickProfileImage,

                    child: Container(
                      width: 42,
                      height: 42,

                      decoration:
                      const BoxDecoration(
                        color: brown,
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Text(
              user?.displayName ?? "No name",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius:
                BorderRadius.circular(20),
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

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
                    overflow:
                    TextOverflow.ellipsis,

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
                      color:
                      user?.emailVerified == true
                          ? brown
                          : Colors.white,

                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius:
                BorderRadius.circular(20),
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

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

                  TextField(
                    controller:
                    newPasswordController,

                    obscureText:
                    hiddenNewPassword,

                    style: const TextStyle(
                      color: Colors.white,
                    ),

                    decoration:
                    InputDecoration(
                      hintText:
                      "New Password",

                      hintStyle:
                      const TextStyle(
                        color: Colors.white70,
                      ),

                      focusedBorder:
                      const UnderlineInputBorder(
                        borderSide:
                        BorderSide(
                          color: brown,
                          width: 2,
                        ),
                      ),

                      suffixIcon:
                      IconButton(
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
                          color: brown,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller:
                    confirmPasswordController,

                    obscureText:
                    hiddenConfirmPassword,

                    style: const TextStyle(
                      color: Colors.white,
                    ),

                    decoration:
                    InputDecoration(
                      hintText:
                      "Confirm New Password",

                      hintStyle:
                      const TextStyle(
                        color: Colors.white70,
                      ),

                      focusedBorder:
                      const UnderlineInputBorder(
                        borderSide:
                        BorderSide(
                          color: brown,
                          width: 2,
                        ),
                      ),

                      suffixIcon:
                      IconButton(
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
                          color: brown,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,

                    child: isLoading
                        ? const Center(
                      child:
                      CircularProgressIndicator(
                        color: brown,
                      ),
                    )
                        : ElevatedButton(
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        brown,
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
                          BorderRadius
                              .circular(15),
                        ),
                      ),

                      onPressed:
                      changePassword,

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

      bottomNavigationBar: SafeArea(
        top: false,
        child: const BottomNavBar(
          selectedIndex: 4,
        ),
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
        msg:
        "Password must be at least 6 characters",
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
      await user!.updatePassword(
        newPassword,
      );

      newPasswordController.clear();
      confirmPasswordController.clear();

      Fluttertoast.showToast(
        msg:
        "Password changed successfully",
      );
    } on FirebaseAuthException catch (e) {
      String message =
          "Unable to change password";

      if (e.code ==
          "requires-recent-login") {
        message =
        "Please login again before changing your password";
      } else if (e.code ==
          "weak-password") {
        message = "Password is too weak";
      }

      Fluttertoast.showToast(
        msg: message,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg:
        "An unexpected error occurred",
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}