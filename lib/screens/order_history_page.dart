import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:j_app/data/order_data.dart';
import 'package:j_app/widgets/bottom_nav_bar.dart';

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

              return Card(

                margin: const EdgeInsets.only(
                  bottom: 15,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(15),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                        children: [

                          const Text(
                            "Order",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            order["status"],
                            style: const TextStyle(
                              color: Color(0xFFC67C4E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Order ID: ${order["orderId"]}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "${dateTime.day}/${dateTime.month}/${dateTime.year} "
                            "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}",
                      ),

                      const Divider(),

                      ...items.map((item) {

                        return Padding(
                          padding:
                          const EdgeInsets.symmetric(
                            vertical: 5,
                          ),

                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,

                            children: [

                              Expanded(
                                child: Text(
                                  "${item["name"]} × ${item["quantity"]}",
                                  style: const TextStyle(
                                    fontWeight:
                                    FontWeight.w500,
                                  ),
                                ),
                              ),

                              Text(
                                "\$${(
                                    (item["price"] as num)
                                        .toDouble() *
                                        (item["quantity"] as num)
                                            .toInt()
                                ).toStringAsFixed(2)}",
                              ),
                            ],
                          ),
                        );
                      }),

                      const Divider(),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                        children: [

                          const Text("Subtotal"),

                          Text(
                            "\$${(
                                order["subtotal"] as num
                            ).toDouble().toStringAsFixed(2)}",
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                        children: [

                          const Text("Delivery"),

                          Text(
                            "\$${(
                                order["deliveryFee"] as num
                            ).toDouble().toStringAsFixed(2)}",
                          ),
                        ],
                      ),

                      const Divider(),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                        children: [

                          const Text(
                            "Total",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            "\$${(
                                order["total"] as num
                            ).toDouble().toStringAsFixed(2)}",

                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC67C4E),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Payment: ${order["paymentMethod"]}",
                      ),

                      const SizedBox(height: 5),

                      Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      Text(
                        "Delivery to: ${order["address"]}",
                        style: const TextStyle(
                        ),
                      ),
                        IconButton(
                        icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFFC67C4E),
              ),
              onPressed: () {
              deleteOrder(index);
              },
              ),
                    ],
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