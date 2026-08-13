import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page_screen.dart';

class ForgetPasswordPage extends StatefulWidget{
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
  }

  class _ForgetPasswordPageState extends State<ForgetPasswordPage>{
  TextEditingController emailController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  bool _isLoading = false;
@override
    Widget build(BuildContext context){
    return Scaffold(
      body:
      Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text("Reset Your Password"),
          SizedBox(
            width: 300,
            child: TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 25),

          SizedBox(
            width: 300,
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
              ),
              onPressed: forget,
              child: const Text("Send"),
            ),
          ),

          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const  LoginPage(),
                ),
              );
            },
            child: const Text("Go back to Login Page"),
          ),
    ],),),);

  }
  void forget()  async{
    final email = emailController.text.trim();
    setState(() {
      _isLoading = true;
    });
    if(email.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter Email First"),),);
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try{
      await auth.sendPasswordResetEmail(
        email: email,);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("If an account exists for this email, a password reset link has been sent."),),);
      setState(() {
        _isLoading = false;
      });
    }
catch(e)
    {

      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something Went Wrong"),),);
      }

    finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }  }

}



