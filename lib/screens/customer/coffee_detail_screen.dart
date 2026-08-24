import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:j_app/data/cart_data.dart';
import 'package:j_app/widgets/wishlist_button.dart';
import 'cart_page_screen.dart';

class CoffeeDetailPage extends StatefulWidget {
  final Map<String, dynamic> coffee;

  const CoffeeDetailPage({
    super.key,
    required this.coffee,
  });

  @override
  State<CoffeeDetailPage> createState() =>
      _CoffeeDetailPageState();
}

class _CoffeeDetailPageState extends State<CoffeeDetailPage> {

  int quantity = 0;
  bool loading = true;

  int wishlistRefresh = 0;

  @override
  void initState() {
    super.initState();
    loadQuantity();
  }

  Future<void> loadQuantity() async {

    final productId = widget.coffee["id"];

    final currentQuantity =
    await getQuantity(productId);

    if (!mounted) return;

    setState(() {
      quantity = currentQuantity;
      loading = false;
    });
  }

  Future<void> addItem() async {

    final productId = widget.coffee["id"];

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

    final productId = widget.coffee["id"];

    await increaseQuantity(productId);

    await loadQuantity();
  }

  Future<void> decreaseItem() async {

    final productId = widget.coffee["id"];

    await decreaseQuantity(productId);

    await loadQuantity();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(
          widget.coffee["name"],
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
          color: Color(0xFFC67C4E),
        ),
      )

          : Column(
        children: [

          Image.asset(
            widget.coffee["image"],
          ),

          Text(
            widget.coffee["name"],
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          Text(
            widget.coffee["detailedDescription"],
            style: const TextStyle(
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 25),

          Text(
            "\$${widget.coffee["price"]}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 30),

          // ADD TO CART
          if (quantity == 0)

            ElevatedButton(
              onPressed: addItem,

              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFFC67C4E),
                foregroundColor: Colors.white,
              ),

              child: const Text(
                "Add to Cart",
              ),
            )

          // QUANTITY CONTROLS
          else

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
                  width: 50,
                  height: 40,

                  alignment:
                  Alignment.center,

                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(10),

                    border: Border.all(
                      color:
                      const Color(0xFFC67C4E),
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

          const SizedBox(height: 25),

          // GO TO CART
          if (quantity > 0)

            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: SizedBox(
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

                    backgroundColor:
                    const Color(0xFFC67C4E),

                    foregroundColor:
                    Colors.white,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                  ),

                  child: const Text(
                    "Go to Cart",

                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}