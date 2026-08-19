import 'package:flutter/material.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

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
          "Terms & Conditions",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
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
                "By using The Cafe application, you agree to follow "
                    "these Terms & Conditions. Please read them carefully "
                    "before using the application or placing an order.",
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ),

            _section(
              "1. Use of the Application",
              "You agree to use The Cafe only for lawful purposes "
                  "and in accordance with these Terms & Conditions. "
                  "You are responsible for the information you provide "
                  "when using the application.",
            ),

            _section(
              "2. User Accounts",
              "Users may be required to create an account to access "
                  "certain features. You are responsible for maintaining "
                  "the security of your account and for activities "
                  "performed through your account.",
            ),

            _section(
              "3. Orders",
              "Orders can be placed through The Cafe by selecting "
                  "available products and providing the required delivery "
                  "information. Orders may be subject to product "
                  "availability and confirmation.",
            ),

            _section(
              "4. Product Availability",
              "Products displayed in the application may not always "
                  "be available. The Cafe reserves the right to modify "
                  "product availability, descriptions, images, prices, "
                  "or other product information when necessary.",
            ),

            _section(
              "5. Pricing",
              "Prices displayed in The Cafe may change from time to "
                  "time. The price shown during checkout is the price "
                  "applicable to the order when it is placed.",
            ),

            _section(
              "6. Payment",
              "The Cafe may support different payment methods, "
                  "including cash on delivery and card payments. Users "
                  "are responsible for selecting an appropriate payment "
                  "method and completing payment according to the "
                  "instructions provided.",
            ),

            _section(
              "7. Delivery",
              "Users are responsible for providing accurate and "
                  "complete delivery information. Incorrect or incomplete "
                  "delivery information may result in delays or unsuccessful "
                  "delivery.",
            ),

            _section(
              "8. Order Cancellation",
              "Orders may be cancelled according to the cancellation "
                  "rules provided by The Cafe. Once an order has entered "
                  "the preparation or delivery process, cancellation "
                  "may not be possible.",
            ),

            _section(
              "9. Refunds",
              "Refunds, where applicable, will be handled according "
                  "to the applicable refund policy and the circumstances "
                  "of the order. Refund eligibility may depend on the "
                  "payment method and status of the order.",
            ),

            _section(
              "10. User Conduct",
              "Users must not misuse The Cafe, attempt to access "
                  "unauthorized information, interfere with the operation "
                  "of the application, provide fraudulent information, "
                  "or use the service for unlawful activities.",
            ),

            _section(
              "11. Intellectual Property",
              "The Cafe application, including its design, branding, "
                  "graphics, text, images, logos, and other materials, "
                  "may be protected by applicable intellectual property "
                  "laws and may not be reproduced or distributed without "
                  "appropriate permission.",
            ),

            _section(
              "12. Service Availability",
              "We aim to keep The Cafe available and functional, "
                  "but we cannot guarantee that the application will "
                  "always operate without interruptions, errors, or "
                  "temporary unavailability.",
            ),

            _section(
              "13. Changes to the Service",
              "The Cafe may modify, update, suspend, or discontinue "
                  "parts of the application, products, or features when "
                  "necessary to improve or maintain the service.",
            ),

            _section(
              "14. Changes to These Terms",
              "These Terms & Conditions may be updated from time "
                  "to time. Updated terms will be reflected within "
                  "the application. Continued use of The Cafe after "
                  "changes are made may indicate acceptance of the "
                  "updated terms.",
            ),

            _section(
              "15. Contact",
              "If you have questions regarding these Terms & "
                  "Conditions, please contact The Cafe through the "
                  "contact information provided within the application.",
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