import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:j_app/data/order_data.dart';
import 'package:j_app/widgets/bottom_nav_bar.dart';
import 'package:j_app/data/cart_data.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'cart_page_screen.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.black87,

        title: const Text(
          "My Orders",
        ),

        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
      ),

      body: ValueListenableBuilder(
        valueListenable: orderBox.listenable(),

        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                "No orders yet",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          final orders = box.values.toList().reversed.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(15),

            itemCount: orders.length,

            itemBuilder: (context, index) {
              final order =
              Map<String, dynamic>.from(orders[index]);

              final items =
              List<Map<String, dynamic>>.from(
                (order["items"] as List).map(
                      (item) => Map<String, dynamic>.from(item),
                ),
              );

              final dateTime =
              DateTime.parse(order["dateTime"]);

              final deliveredOn =
                  "${dateTime.day}/${dateTime.month}/${dateTime.year}";

              return Card(
                margin: const EdgeInsets.only(
                  bottom: 12,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),

                elevation: 2,

                child: Padding(
                  padding: const EdgeInsets.all(15),

                  child: Column(
                    children: [

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          // DELIVERED ON
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Delivered on",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  deliveredOn,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          // TOTAL PRICE
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Total Price",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  "\$${(
                                      order["total"] as num
                                  ).toDouble().toStringAsFixed(2)}",

                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFFC67C4E),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          // ALL ITEMS
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children: [
                                const Text(
                                  "All Items",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                ...items.map(
                                      (item) {
                                    return Text(
                                      "${item["name"]} × ${item["quantity"]}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // 👇 PUT REORDER BUTTON HERE
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton(
                          onPressed: () {

                            for (final item in items) {

                              final quantity =
                              (item["quantity"] as num).toInt();

                              for (int i = 0; i < quantity; i++) {
                                addToCart(item);
                              }
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CartPage(),
                              ),
                            );

                            Fluttertoast.showToast(
                              msg: "All Items Added to Cart",
                            );
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC67C4E),
                            foregroundColor: Colors.white,

                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),

                          child: const Text(
                            "Reorder",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 2,
      ),
    );
  }
}