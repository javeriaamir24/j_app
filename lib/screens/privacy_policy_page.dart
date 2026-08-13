import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
          "Privacy Policy",
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

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: coffeeBrown.withOpacity(0.10),
                borderRadius: BorderRadius.circular(15),
              ),

              child: const Text(
                "Your privacy is important to us. This Privacy Policy "
                    "explains what information The Cafe may collect, how "
                    "we use it, and how we protect it when you use our "
                    "application.",
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ),

            _section(
              "1. Information We Collect",
              "When you use The Cafe, we may collect information "
                  "necessary to provide our services. This may include "
                  "your name, phone number, email address, delivery "
                  "address, order information, and account information.",
            ),

            _section(
              "2. How We Use Your Information",
              "We may use your information to create and manage "
                  "your account, process orders, deliver your purchases, "
                  "provide customer support, communicate with you, and "
                  "improve the application and our services.",
            ),

            _section(
              "3. Account Information",
              "If you create an account, information associated with "
                  "your account may be stored securely so that you can "
                  "access your account and use features such as order "
                  "history and account management.",
            ),

            _section(
              "4. Payment Information",
              "Payment information may be processed through third-party "
                  "payment providers. Sensitive card information, such as "
                  "your card security code, should not be stored unnecessarily "
                  "by The Cafe.",
            ),

            _section(
              "5. Order Information",
              "Information about your orders, including purchased "
                  "items, order date and time, total amount, delivery "
                  "information, and selected payment method may be stored "
                  "so that your orders can be processed and your order "
                  "history can be displayed.",
            ),

            _section(
              "6. Chat and Communication",
              "If chat functionality is available in The Cafe, "
                  "messages sent through the application may be stored "
                  "and processed to provide communication between users "
                  "and the relevant service or support personnel.",
            ),

            _section(
              "7. Data Security",
              "We take reasonable measures to protect information "
                  "associated with The Cafe. However, no electronic "
                  "storage system or method of transmitting information "
                  "over the internet can be guaranteed to be completely "
                  "secure.",
            ),

            _section(
              "8. Third-Party Services",
              "The Cafe may use third-party services such as Firebase "
                  "and payment providers. These services may process "
                  "information according to their own privacy policies "
                  "and terms of service.",
            ),

            _section(
              "9. Data Retention",
              "Information may be retained for as long as necessary "
                  "to provide our services, maintain account and order "
                  "records, comply with applicable requirements, or "
                  "resolve disputes and service-related issues.",
            ),

            _section(
              "10. Children's Privacy",
              "The Cafe is not specifically designed to collect "
                  "personal information from children. Users should "
                  "provide accurate information and use the application "
                  "responsibly.",
            ),

            _section(
              "11. Changes to This Privacy Policy",
              "We may update this Privacy Policy from time to time "
                  "to reflect changes in our application, services, or "
                  "legal requirements. Any changes will be reflected "
                  "within the application.",
            ),

            _section(
              "12. Contact Us",
              "If you have questions or concerns about this Privacy "
                  "Policy or how your information is handled, you can "
                  "contact The Cafe through the contact information "
                  "provided within the application.",
            ),

            const SizedBox(height: 25),

            Center(
              child: Text(
                "Last updated: August 2026",
                style: TextStyle(
                  color: coffeeBrown,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _section(
      String title,
      String text,
      ) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            text,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}