import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:j_app/data/cart_data.dart';
import 'package:j_app/widgets/wishlist_button.dart';
import 'cart_page_screen.dart';
import 'package:j_app/widgets/customers_bottom_nav_bar.dart';

class CoffeeDetailPage extends StatefulWidget {
  final Map<String, dynamic> coffee;

  const CoffeeDetailPage({
    super.key,
    required this.coffee,
  });

  @override
  State<CoffeeDetailPage> createState() => _CoffeeDetailPageState();
}

class _CoffeeDetailPageState extends State<CoffeeDetailPage> {
  int quantity = 0;
  bool loading = true;
  int wishlistRefresh = 0;

  static const Color brown = Color(0xFFC67C4E);


  @override
  void initState() {
    super.initState();
    loadQuantity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: Text(
          coffeeName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          WishlistButton(
            coffee: widget.coffee,
            refresh: wishlistRefresh,
            onChanged: () {
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
      body: loading
          ? const Center(
        child: CircularProgressIndicator(
          color: brown,
        ),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildCoffeeImage(),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    coffeeName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "\$${coffeePrice.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: brown,
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    coffeeDescription,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  if (quantity == 0)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: addItem,
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor: brown,
                          foregroundColor: Colors.white,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "ADD TO CART",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        const Text(
                          "Quantity",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: decreaseItem,
                              icon: const Icon(
                                Icons.remove,
                              ),
                            ),

                            Container(
                              width: 55,
                              height: 42,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(10),
                                border: Border.all(
                                  color: brown,
                                ),
                              ),
                              child: Text(
                                "$quantity",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),

                            IconButton(
                              onPressed: increaseItem,
                              icon: const Icon(
                                Icons.add,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const CartPage(),
                                ),
                              );
                            },
                            style:
                            ElevatedButton.styleFrom(
                              backgroundColor: brown,
                              foregroundColor:
                              Colors.white,
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "GO TO CART",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: const BottomNavBar(
          selectedIndex: 0,
        ),
      ),
    );
  }

  String get productId {
    return widget.coffee["id"]?.toString() ??
        widget.coffee["productId"]?.toString() ??
        "";
  }

  String get coffeeName {
    return widget.coffee["name"]?.toString() ?? "Coffee";
  }

  String get coffeeImage {
    return widget.coffee["image"]?.toString() ?? "";
  }

  String get coffeeDescription {
    return widget.coffee["detailedDescription"]?.toString() ??
        widget.coffee["description"]?.toString() ??
        "No description available.";
  }

  double get coffeePrice {
    final price = widget.coffee["price"];

    if (price is num) {
      return price.toDouble();
    }

    return double.tryParse(price?.toString() ?? "0") ?? 0.0;
  }


  Future<void> loadQuantity() async {
    if (productId.isEmpty) {
      if (!mounted) return;

      setState(() {
        quantity = 0;
        loading = false;
      });

      return;
    }

    final currentQuantity = await getQuantity(productId);

    if (!mounted) return;

    setState(() {
      quantity = currentQuantity;
      loading = false;
    });
  }

  Future<void> addItem() async {
    if (productId.isEmpty) {
      Fluttertoast.showToast(
        msg: "Product information is missing",
      );
      return;
    }

    await addToCart(
      widget.coffee,
      productId,
    );

    await loadQuantity();

    Fluttertoast.showToast(
      msg: "Added to Cart",
    );
  }

  Future<void> increaseItem() async {
    if (productId.isEmpty) return;

    await increaseQuantity(productId);

    await loadQuantity();
  }

  Future<void> decreaseItem() async {
    if (productId.isEmpty) return;

    await decreaseQuantity(productId);

    await loadQuantity();
  }

  Widget buildCoffeeImage() {
    if (coffeeImage.isEmpty) {
      return Container(
        width: double.infinity,
        height: 280,
        color: Colors.grey.shade200,
        child: const Icon(
          Icons.coffee,
          size: 60,
          color: Colors.black87,
        ),
      );
    }

    if (coffeeImage.startsWith("http")) {
      return Image.network(
        coffeeImage,
        width: double.infinity,
        height: 280,
        fit: BoxFit.cover,
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return Container(
            width: double.infinity,
            height: 280,
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.broken_image,
              size: 50,
              color: Colors.grey,
            ),
          );
        },
      );
    }

    return Image.asset(
      coffeeImage,
      width: double.infinity,
      height: 280,
      fit: BoxFit.cover,
      errorBuilder: (
          context,
          error,
          stackTrace,
          ) {
        return Container(
          width: double.infinity,
          height: 280,
          color: Colors.grey.shade200,
          child: const Icon(
            Icons.coffee,
            size: 50,
            color: Colors.black87,
          ),
        );
      },
    );
  }
}