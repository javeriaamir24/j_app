import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  static const Color coffeeBrown = Color(0xFFC67C4E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: const Text(
          "About Us",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [



            const SizedBox(height: 20),

            const Center(
              child: Text(
                "The Cafe",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                "Good coffee. Good moments.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ),

            const SizedBox(height: 30),

            _sectionTitle("Who We Are"),

            _sectionText(
              "The Cafe is a coffee ordering application created to "
                  "make ordering your favorite coffee simple, quick, and "
                  "convenient. Our goal is to provide a smooth ordering "
                  "experience from browsing our menu to placing and "
                  "receiving your order.",
            ),

            _sectionTitle("Our Mission"),

            _sectionText(
              "Our mission is to bring great coffee and convenient "
                  "service together in one place. We aim to provide "
                  "quality beverages, an easy ordering process, and a "
                  "pleasant experience for every customer who chooses "
                  "The Cafe.",
            ),

            _sectionTitle("What We Offer"),

            _bullet("A variety of coffee and beverages"),
            _bullet("Easy and convenient online ordering"),
            _bullet("Multiple payment options"),
            _bullet("Order history and order details"),
            _bullet("A simple and user-friendly experience"),

            _sectionTitle("Our Vision"),

            _sectionText(
              "We want The Cafe to become a convenient place where "
                  "coffee lovers can discover, order, and enjoy their "
                  "favorite drinks without unnecessary hassle. We "
                  "believe that great coffee is not only about the drink "
                  "itself, but also about the experience surrounding it.",
            ),

            const SizedBox(height: 25),



            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


  static Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        bottom: 8,
      ),
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static Widget _sectionText(String text) {
    return Text(
      text,
      textAlign: TextAlign.justify,
      style: const TextStyle(
        fontSize: 15,
        height: 1.6,
        color: Colors.black87,
      ),
    );
  }

  static Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Icon(
            Icons.check_circle,
            size: 20,
            color: coffeeBrown,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}