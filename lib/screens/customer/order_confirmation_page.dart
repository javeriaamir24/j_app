import 'package:flutter/material.dart';
import 'package:j_app/widgets/customers_bottom_nav_bar.dart';
import 'package:j_app/screens/customer/home_page_screen.dart';

class OrderConfirmationPage extends StatelessWidget {
  final String orderId;
  final String orderDate;
  final Map<String, dynamic> customer;
  final String paymentMethod;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double deliveryFee;
  final double total;

  const OrderConfirmationPage({
    super.key,
    required this.orderId,
    required this.orderDate,
    required this.customer,
    required this.paymentMethod,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  static const Color brown = Color(0xFFC67C4E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.black87,
        automaticallyImplyLeading: false,
        title: const Text("Order Confirmation"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: brown,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 45,
                ),
              ),
            ),

            const SizedBox(height: 15),

            const Center(
              child: Text(
                "Order Placed Successfully!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            const Center(
              child: Text(
                "Thank you for ordering from The Cafe.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),
            ),

            const SizedBox(height: 25),

            _sectionTitle("Order Information"),

            const SizedBox(height: 10),

            _detailCard(
              children: [
                _detailRow(
                  "Order ID",
                  orderId,
                ),
                _detailRow(
                  "Date",
                  _formatDate(orderDate),
                ),
                _detailRow(
                  "Payment",
                  paymentMethod,
                ),
                _detailRow(
                  "Status",
                  "Pending",
                ),
              ],
            ),

            const SizedBox(height: 25),

            _sectionTitle("Delivery Information"),

            const SizedBox(height: 10),

            _detailCard(
              children: [
                _detailRow(
                  "Name",
                  customer["name"]?.toString() ?? "",
                ),
                _detailRow(
                  "Phone",
                  customer["phone"]?.toString() ?? "",
                ),
                _detailRow(
                  "Address",
                  customer["address"]?.toString() ?? "",
                ),
              ],
            ),

            const SizedBox(height: 25),

            _sectionTitle("Order Items"),

            const SizedBox(height: 10),

            ...items.map(
                  (item) {
                final price =
                    (item["price"] as num?)?.toDouble() ?? 0;

                final quantity =
                    (item["quantity"] as num?)?.toInt() ?? 0;

                final itemTotal =
                    price * quantity;

                return Container(
                  margin: const EdgeInsets.only(
                    bottom: 10,
                  ),

                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(20),

                    border: Border.all(
                      color: Colors.black,
                      width: 0.5,
                    ),
                  ),

                  child: ListTile(
                    contentPadding:
                    const EdgeInsets.all(10),

                    leading: ClipRRect(
                      borderRadius:
                      BorderRadius.circular(12),

                      child: _buildImage(
                        item["image"],
                      ),
                    ),

                    title: Text(
                      item["name"]?.toString() ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      "$quantity × \$${price.toStringAsFixed(2)}",
                    ),

                    trailing: Text(
                      "\$${itemTotal.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            _sectionTitle("Payment Summary"),

            const SizedBox(height: 10),

            _detailCard(
              children: [
                _priceRow(
                  "Subtotal",
                  subtotal,
                ),

                const SizedBox(height: 10),

                _priceRow(
                  "Delivery",
                  deliveryFee,
                ),

                const Divider(),

                _priceRow(
                  "Total",
                  total,
                  bold: true,
                ),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const HomePage(),
                    ),
                        (route) => false,
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: brown,
                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),

                child: const Text(
                  "BACK TO HOME",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),

      bottomNavigationBar:
      const BottomNavBar(
        selectedIndex: 1,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _detailCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(15),

        border: Border.all(
          color: Colors.black,
          width: 0.5,
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _detailRow(
      String title,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 12),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 100,

            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(
      String title,
      double value, {
        bool bold = false,
      }) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,

      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: bold ? 20 : 16,
            fontWeight: bold
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),

        Text(
          "\$${value.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: bold ? 20 : 16,
            fontWeight: bold
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildImage(dynamic image) {
    final imagePath =
        image?.toString() ?? "";

    if (imagePath.startsWith("http")) {
      return Image.network(
        imagePath,
        width: 70,
        height: 70,
        fit: BoxFit.cover,

        errorBuilder:
            (context, error, stackTrace) {
          return _imagePlaceholder();
        },
      );
    }

    return Image.asset(
      imagePath,
      width: 70,
      height: 70,
      fit: BoxFit.cover,

      errorBuilder:
          (context, error, stackTrace) {
        return _imagePlaceholder();
      },
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey.shade200,

      child: const Icon(
        Icons.coffee,
        color: Colors.black87,
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final parsed =
      DateTime.parse(date);

      final day =
      parsed.day.toString().padLeft(2, '0');

      final month =
      parsed.month.toString().padLeft(2, '0');

      final year =
      parsed.year.toString();

      final hour =
      parsed.hour.toString().padLeft(2, '0');

      final minute =
      parsed.minute.toString().padLeft(2, '0');

      return "$day/$month/$year $hour:$minute";
    } catch (e) {
      return date;
    }
  }
}