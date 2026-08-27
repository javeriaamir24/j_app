import 'package:flutter/material.dart';
import 'package:j_app/data/cart_data.dart';
import 'package:j_app/widgets/customers_bottom_nav_bar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'check_out_page_screen.dart';
import 'package:j_app/screens/customer/coffee_detail_screen.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double deliveryFee = 0.0;
  bool loadingDeliveryFee = true;

  static const Color brown = Color(0xFFC67C4E);

  @override
  void initState() {
    super.initState();
    loadDeliveryFee();
  }

  Future<void> loadDeliveryFee() async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref("settings/deliveryFee")
          .get();

      if (!mounted) return;

      setState(() {
        if (snapshot.exists) {
          deliveryFee =
              double.tryParse(snapshot.value.toString()) ?? 0.0;
        } else {
          deliveryFee = 0.0;
        }

        loadingDeliveryFee = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        deliveryFee = 0.0;
        loadingDeliveryFee = false;
      });

      print("Delivery fee error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.black87,
        title: const Text(
          "My Cart",
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
      ),

      body: StreamBuilder(
        stream: usersRef
            .child(userId)
            .child("cart")
            .onValue,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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

          final data = snapshot.data?.snapshot.value;

          if (data == null) {
            return const Center(
              child: Text(
                "Your cart is empty",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            );
          }

          final Map<String, dynamic> cartData =
          Map<String, dynamic>.from(data as Map);

          final items = cartData.entries.map((entry) {
            final item =
            Map<String, dynamic>.from(entry.value);

            item["productId"] = entry.key;

            return item;
          }).toList();

          if (items.isEmpty) {
            return const Center(
              child: Text(
                "Your cart is empty",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            );
          }

          double subtotal = 0;

          for (var item in items) {
            subtotal +=
                (item["price"] as num).toDouble() *
                    (item["quantity"] as num).toInt();
          }

          final total = subtotal + deliveryFee;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,

                  itemBuilder: (context, index) {
                    final item = items[index];

                    final productId = item["productId"];

                    final Map<String, dynamic> coffee = {
                      "id": item["id"] ?? productId,
                      "name": item["name"] ?? "",
                      "description": item["description"] ?? "",
                      "detailedDescription":
                      item["detailedDescription"] ?? "",
                      "price": item["price"] ?? 0,
                      "image": item["image"] ?? "",
                      "category": item["category"] ?? "",
                    };

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CoffeeDetailPage(
                                  coffee: coffee,
                                ),
                          ),
                        );
                      },

                      child: Card(
                        margin: const EdgeInsets.all(10),

                        child: Padding(
                          padding: const EdgeInsets.all(10),

                          child: Row(
                            children: [
                              item["image"]
                                  .toString()
                                  .startsWith("http")
                                  ? Image.network(
                                item["image"].toString(),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,

                                errorBuilder: (
                                    context,
                                    error,
                                    stackTrace,
                                    ) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color:
                                    Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                                  : Image.asset(
                                item["image"].toString(),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,

                                errorBuilder: (
                                    context,
                                    error,
                                    stackTrace,
                                    ) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color:
                                    Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.coffee,
                                      color: Colors.black87,
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      item["name"]
                                          ?.toString() ??
                                          "",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight:
                                        FontWeight.bold,
                                      ),
                                    ),

                                    Text(
                                      "\$${item["price"]}",
                                    ),

                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () async {
                                            await decreaseQuantity(
                                              productId,
                                            );
                                          },

                                          icon: const Icon(
                                            Icons.remove,
                                          ),
                                        ),

                                        Text(
                                          "${item["quantity"]}",

                                          style:
                                          const TextStyle(
                                            fontSize: 18,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                        ),

                                        IconButton(
                                          onPressed: () async {
                                            await increaseQuantity(
                                              productId,
                                            );
                                          },

                                          icon: const Icon(
                                            Icons.add,
                                          ),
                                        ),

                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: brown,
                                          ),

                                          onPressed: () async {
                                            await removeFromCart(
                                              productId,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                      children: [
                        const Text(
                          "Subtotal:",
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),

                        Text(
                          "\$${subtotal.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                      children: [
                        const Text(
                          "Delivery:",
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),

                        loadingDeliveryFee
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            color: brown,
                          ),
                        )
                            : Text(
                          "\$${deliveryFee.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),

                    const Divider(),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                      children: [
                        const Text(
                          "Total:",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "\$${total.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),

                child: SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brown,
                      foregroundColor: Colors.white,
                    ),

                    onPressed: loadingDeliveryFee
                        ? null
                        : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const CheckOutPage(),
                        ),
                      );
                    },

                    child: Text(
                      loadingDeliveryFee
                          ? "LOADING..."
                          : "Check Out",

                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: const BottomNavBar(
          selectedIndex: 1,
        ),
      ),
    );
  }
}