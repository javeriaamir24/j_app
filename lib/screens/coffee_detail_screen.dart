import 'package:flutter/material.dart';
import 'package:j_app/data/cart_data.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'cart_page_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:j_app/data/wishlist_data.dart';
import 'wish_list_page.dart';


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

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.coffee["name"]),

        actions: [
          ValueListenableBuilder(
            valueListenable: wishlistBox.listenable(),

            builder: (context, box, _) {

              final isFavorite =
              isWishlisted(widget.coffee["name"]);

              return IconButton(
                onPressed: () {

                  if (isFavorite) {
                    removeFromWishlist(
                      widget.coffee["name"],
                    );

                    Fluttertoast.showToast(
                      msg: "Removed from Wishlist",
                    );
                  } else {
                    addToWishlist(widget.coffee);

                    Fluttertoast.showToast(
                      msg: "Added to Wishlist",
                    );
                  }
                },

                icon: Icon(
                  isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,

                  color: isFavorite
                      ? Color(0xFFC67C4E)
                      : Colors.grey,
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: cartBox.listenable(),

        builder: (context, box,_ ) {

          final quantity =
          getQuantity(widget.coffee["name"]);

          return Column(
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


              if (quantity == 0)

                ElevatedButton(
                  onPressed: () {

                    addToCart(widget.coffee);

                    Fluttertoast.showToast(
                      msg: "Added to Cart",
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFFC67C4E),
                    foregroundColor: Colors.white,
                  ),

                  child: const Text(
                    "Add to Cart",
                  ),
                )
              else
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {

                        final index =
                        cartItems.indexWhere(
                              (item) =>
                          item["name"] ==
                              widget.coffee["name"],
                        );

                        if (index != -1) {
                          decreaseQuantity(index);
                        }
                      },

                      icon: const Icon(
                        Icons.remove,
                      ),
                    ),


                    // QUANTITY
                    Container(
                      width: 50,
                      height: 40,

                      alignment: Alignment.center,

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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),


                    // PLUS
                    IconButton(
                      onPressed: () {

                        final index =
                        cartItems.indexWhere(
                              (item) =>
                          item["name"] ==
                              widget.coffee["name"],
                        );

                        if (index != -1) {
                          increaseQuantity(index);
                        }
                      },

                      icon: const Icon(
                        Icons.add,
                      ),
                    ),
                  ],
                ),


              const SizedBox(height: 25),


              if (quantity > 0)

                Padding(
                  padding: const EdgeInsets.symmetric(
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

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFFC67C4E),

                        foregroundColor:
                        Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),

                      child: const Text(
                        "Go to Cart",
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
    );
  }
}