import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:j_app/widgets/customers_bottom_nav_bar.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  static const Color brown = Color(0xFFC67C4E);

  Future<List<Map<String, dynamic>>> getOrders() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return [];
    }

    final snapshot = await FirebaseDatabase.instance
        .ref("orders/${user.uid}")
        .get();

    if (!snapshot.exists || snapshot.value == null) {
      return [];
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    final orders = data.entries.map((entry) {
      final order = Map<String, dynamic>.from(entry.value);

      order["orderId"] = entry.key;

      return order;
    }).toList();

    orders.sort((a, b) {
      final dateA = DateTime.tryParse(
        a["orderDate"]?.toString() ?? "",
      ) ??
          DateTime.fromMillisecondsSinceEpoch(0);

      final dateB = DateTime.tryParse(
        b["orderDate"]?.toString() ?? "",
      ) ??
          DateTime.fromMillisecondsSinceEpoch(0);

      return dateB.compareTo(dateA);
    });

    return orders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.black87,
        automaticallyImplyLeading: false,
        title: const Text(
          "Order History",
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: brown,
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

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
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

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              final customer =
              Map<String, dynamic>.from(
                order["customer"] ?? {},
              );

              final items =
              _convertItems(order["items"]);

              final total =
                  (order["totalPrice"] as num?)
                      ?.toDouble() ??
                      0.0;

              final status =
                  order["status"]?.toString() ??
                      "Pending";

              final orderDate =
                  order["orderDate"]?.toString() ??
                      "";

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OrderDetailsPage(
                            order: order,
                          ),
                    ),
                  );
                },

                child: Container(
                  margin:
                  const EdgeInsets.only(
                    bottom: 15,
                  ),

                  padding:
                  const EdgeInsets.all(15),

                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(18),

                    border: Border.all(
                      color: Colors.black,
                      width: 0.5,
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                        children: [
                          Expanded(
                            child: Text(
                              "Order #${order["orderId"]}",
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,

                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),

                          _statusBadge(status),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        _formatDate(orderDate),
                        style:
                        const TextStyle(
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        items.isEmpty
                            ? "No items"
                            : items
                            .map(
                              (item) =>
                          "${item["name"]} × ${item["quantity"]}",
                        )
                            .join(", "),
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                      ),

                      const Divider(
                        height: 25,
                      ),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                        children: [
                          const Text(
                            "Total",
                            style:
                            TextStyle(
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          Text(
                            "\$${total.toStringAsFixed(2)}",
                            style:
                            const TextStyle(
                              fontSize: 18,
                              fontWeight:
                              FontWeight.bold,
                            ),
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

      bottomNavigationBar: SafeArea(
        top: false,
        child: const BottomNavBar(
          selectedIndex: 2,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _convertItems(
      dynamic data) {
    if (data == null) {
      return [];
    }

    if (data is List) {
      return data
          .where((item) => item != null)
          .map(
            (item) =>
        Map<String, dynamic>.from(item),
      )
          .toList();
    }

    if (data is Map) {
      return data.values
          .where((item) => item != null)
          .map(
            (item) =>
        Map<String, dynamic>.from(item),
      )
          .toList();
    }

    return [];
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),


      child: Text(
        status,
        style: TextStyle(
          color: _statusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "delivered":
        return Colors.green;

      case "cancelled":
        return Colors.red;

      case "processing":
        return Colors.blue;

      case "pending":
        return Colors.orange;

      default:
        return brown;
    }
  }

  String _formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);

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

      return "$day/$month/$year  $hour:$minute";
    } catch (e) {
      return date;
    }
  }
}

class OrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsPage({
    super.key,
    required this.order,
  });

  static const Color brown = Color(0xFFC67C4E);

  @override
  Widget build(BuildContext context) {
    final customer =
    Map<String, dynamic>.from(
      order["customer"] ?? {},
    );

    final items =
    _convertItems(order["items"]);

    final subtotal =
        (order["subtotal"] as num?)
            ?.toDouble() ??
            0.0;

    final deliveryFee =
        (order["deliveryFee"] as num?)
            ?.toDouble() ??
            0.0;

    final total =
        (order["totalPrice"] as num?)
            ?.toDouble() ??
            0.0;

    final paymentMethod =
        order["paymentMethod"]?.toString() ??
            "";

    final status =
        order["status"]?.toString() ??
            "Pending";

    final orderDate =
        order["orderDate"]?.toString() ??
            "";

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.black87,
        title: const Text(
          "Order Details",
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            _sectionTitle(
              "Order Information",
            ),

            const SizedBox(height: 10),

            _infoCard(
              children: [
                _infoRow(
                  "Order ID",
                  order["orderId"]
                      ?.toString() ??
                      "",
                ),

                _infoRow(
                  "Date",
                  _formatDate(orderDate),
                ),

                _infoRow(
                  "Status",
                  status,
                ),

                _infoRow(
                  "Payment Method",
                  paymentMethod,
                ),
              ],
            ),

            const SizedBox(height: 25),

            _sectionTitle(
              "Customer Information",
            ),

            const SizedBox(height: 10),

            _infoCard(
              children: [
                _infoRow(
                  "Name",
                  customer["name"]
                      ?.toString() ??
                      "",
                ),

                _infoRow(
                  "Phone",
                  customer["phone"]
                      ?.toString() ??
                      "",
                ),

                _infoRow(
                  "Address",
                  customer["address"]
                      ?.toString() ??
                      "",
                ),
              ],
            ),

            const SizedBox(height: 25),

            _sectionTitle(
              "Ordered Items",
            ),

            const SizedBox(height: 10),

            ...items.map(
                  (item) {
                final price =
                    (item["price"] as num?)
                        ?.toDouble() ??
                        0.0;

                final quantity =
                    (item["quantity"] as num?)
                        ?.toInt() ??
                        0;

                final itemTotal =
                    price * quantity;

                return Container(
                  margin:
                  const EdgeInsets.only(
                    bottom: 10,
                  ),

                  padding:
                  const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(
                      18,
                    ),

                    border: Border.all(
                      color: Colors.black,
                      width: 0.5,
                    ),
                  ),

                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),

                        child: _buildImage(
                          item["image"],
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [
                            Text(
                              item["name"]
                                  ?.toString() ??
                                  "",

                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            Text(
                              "$quantity × \$${price.toStringAsFixed(2)}",
                            ),
                          ],
                        ),
                      ),

                      Text(
                        "\$${itemTotal.toStringAsFixed(2)}",

                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            _sectionTitle(
              "Payment Summary",
            ),

            const SizedBox(height: 10),

            _infoCard(
              children: [
                _priceRow(
                  "Subtotal",
                  subtotal,
                ),

                const SizedBox(
                  height: 10,
                ),

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

            const SizedBox(height: 25),
          ],
        ),
      ),

      bottomNavigationBar:
      const BottomNavBar(
        selectedIndex: 2,
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

  Widget _infoCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,

      padding:
      const EdgeInsets.all(15),

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

  Widget _infoRow(
      String title,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 120,

            child: Text(
              title,
              style:
              const TextStyle(
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(value),
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
      MainAxisAlignment
          .spaceBetween,

      children: [
        Text(
          title,
          style: TextStyle(
            fontSize:
            bold ? 20 : 16,
            fontWeight: bold
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),

        Text(
          "\$${value.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize:
            bold ? 20 : 16,
            fontWeight: bold
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildImage(dynamic image) {
    final path =
        image?.toString() ?? "";

    if (path.startsWith("http")) {
      return Image.network(
        path,
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
      path,
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

  static List<Map<String, dynamic>>
  _convertItems(dynamic data) {
    if (data == null) {
      return [];
    }

    if (data is List) {
      return data
          .where((item) => item != null)
          .map(
            (item) =>
        Map<String, dynamic>.from(
          item,
        ),
      )
          .toList();
    }

    if (data is Map) {
      return data.values
          .where((item) => item != null)
          .map(
            (item) =>
        Map<String, dynamic>.from(
          item,
        ),
      )
          .toList();
    }

    return [];
  }

  static String _formatDate(String date) {
    try {
      final parsed =
      DateTime.parse(date);

      final day =
      parsed.day.toString().padLeft(
        2,
        '0',
      );

      final month =
      parsed.month.toString().padLeft(
        2,
        '0',
      );

      final year =
      parsed.year.toString();

      final hour =
      parsed.hour.toString().padLeft(
        2,
        '0',
      );

      final minute =
      parsed.minute.toString().padLeft(
        2,
        '0',
      );

      return "$day/$month/$year  $hour:$minute";
    } catch (e) {
      return date;
    }
  }
}