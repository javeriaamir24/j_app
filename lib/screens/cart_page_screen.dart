import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:j_app/data/cart_data.dart';
import 'package:j_app/widgets/bottom_nav_bar.dart';
import 'check_out_page_screen.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.black87,
        title: const Text("My Cart",)
,        titleTextStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 30,),
      ),

      body: ValueListenableBuilder(
        valueListenable: cartBox.listenable(),

        builder: (context, box, _) {

          final items = cartItems;

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

          return Column(
            children: [

              Expanded(
                child: ListView.builder(
                  itemCount: items.length,

                  itemBuilder: (context, index) {

                    final item = items[index];

                    return Card(
                      margin: const EdgeInsets.all(10),

                      child: Padding(
                        padding: const EdgeInsets.all(10),

                        child: Row(
                          children: [

                            Image.asset(
                              item["image"],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,

                                children: [

                                  Text(
                                    item["name"],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Text(
                                    "\$${item["price"]}",
                                  ),

                                  Row(
                                    children: [

                                      IconButton(
                                        onPressed: () {
                                          decreaseQuantity(index);
                                        },

                                        icon: const Icon(
                                          Icons.remove,
                                        ),
                                      ),

                                      Text(
                                        "${item["quantity"]}",

                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      IconButton(
                                        onPressed: () {
                                          increaseQuantity(index);
                                        },

                                        icon: const Icon(
                                          Icons.add,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Color(0xFFC67C4E),
                                        ),
                                        onPressed: () {
                                          removeFromCart(item);
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
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),

                child: Row(
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
                      "\$${totalPrice.toStringAsFixed(2)}",

                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
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
                      backgroundColor: const Color(0xFFC67C4E),
                      foregroundColor: Colors.white,
                    ),

                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckOutPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Check Out",
                      style: TextStyle(
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
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 1,
      ),
    );
  }

  double get totalPrice {

    double total = 0;

    for (var item in cartItems) {
      total +=
          item["price"] * item["quantity"];
    }

    return total;
  }
}