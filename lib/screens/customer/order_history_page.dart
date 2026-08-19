import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:j_app/widgets/customers_bottom_nav_bar.dart';
import 'package:j_app/data/cart_data.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'cart_page_screen.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {

  final DatabaseReference ordersRef = FirebaseDatabase.instance.ref("orders");
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

      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseAuth.instance.currentUser == null
            ? const Stream.empty()
            : ordersRef
            .child(FirebaseAuth.instance.currentUser!.uid)
            .onValue,

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFC67C4E),
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Something went wrong",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.snapshot.value == null) {
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

          final data = snapshot.data!.snapshot.value;

          final Map<String, dynamic> orders =
          Map<String, dynamic>.from(data as Map);

          final orderList = orders.entries.toList().reversed.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(15),

            itemCount: orderList.length,

            itemBuilder: (context, index) {

              final order =
              Map<String, dynamic>.from(orderList[index].value);

              final items = List<Map<String, dynamic>>.from(
                (order["items"] as List).map(
                      (item) => Map<String, dynamic>.from(item),
                ),
              );

              final dateTime =
              DateTime.parse(order["orderDate"]);

              final orderDate =
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
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          Expanded(
                            flex: 2,

                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children: [

                                const Text(
                                  "Order Date",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  orderDate,

                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

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
                                  "\$${(order["totalPrice"] as num).toDouble().toStringAsFixed(2)}",

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
                                        fontWeight:
                                        FontWeight.w500,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton(
                          onPressed: () async {

                            for (final item in items) {

                              final productId = item["id"];

                              final quantity =
                              (item["quantity"] as num).toInt();

                              for (int i = 0; i < quantity; i++) {

                                await addToCart(
                                  item,
                                  productId,
                                );
                              }
                            }

                            if (!mounted) return;

                            Fluttertoast.showToast(
                              msg: "All Items Added to Cart",
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CartPage(),
                              ),
                            );
                          },
                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFFC67C4E),

                            foregroundColor:
                            Colors.white,

                            padding:
                            const EdgeInsets.symmetric(
                              vertical: 12,
                            ),

                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                          ),

                          child: const Text(
                            "Reorder",

                            style: TextStyle(
                              fontWeight:
                              FontWeight.bold,
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