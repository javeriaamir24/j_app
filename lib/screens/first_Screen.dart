import 'package:flutter/material.dart';
import 'login_page_screen.dart';
class FirstScreen extends StatefulWidget{
  const FirstScreen ({super.key});
  
  @override
  State <FirstScreen> createState() => _FirstScreen();
}

class _FirstScreen extends State<FirstScreen>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.black,image: DecorationImage(image: AssetImage("assets/images/coffee_background.webp"),),),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children:[

              const Text("Fall in Love with Coffee in Blissful Delight!",
                  textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 40)),
              const SizedBox(height: 12),
              const Text("Welcome to our cozy coffee corner, where every cup is delightful for you",
                  textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 15)),


              const SizedBox(height: 25,width: 100,),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC67C4E),
                    foregroundColor: Colors.white,


                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );

                  },
                  child: const Text("Get Started"),
                ),
              ),
              const SizedBox(height: 20),


            ],
          ),
        ),
      ),
      );
  }
}

