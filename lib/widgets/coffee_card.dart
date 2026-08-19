import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:j_app/data/cart_data.dart';
import 'package:j_app/data/wishlist_data.dart';
import 'package:j_app/screens/customer/coffee_detail_screen.dart';
import 'package:j_app/widgets/wishlist_button.dart';

class CoffeeCard extends StatelessWidget {
  final Map<String, dynamic> coffee;
  final double width;
  final double imageHeight;
  final double padding;
  final double nameSize;
  final double priceSize;

  const CoffeeCard({
    super.key,
    required this.coffee,
    this.width = double.infinity,
    this.imageHeight = 120,
    this.padding = 15,
    this.nameSize = 20,
    this.priceSize = 18,
  });

  Future<void> addItemToCart() async {

    final productId = coffee["id"];

    await addToCart(
      coffee,
      productId,
    );

    Fluttertoast.showToast(
      msg: "Added to Cart",
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,

      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CoffeeDetailPage(
                coffee: coffee,
              ),
            ),
          );
        },

        child: Card(
          margin: const EdgeInsets.only(right: 10),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          clipBehavior: Clip.antiAlias,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Stack(
                children: [

                  Image.asset(
                    coffee["image"],
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),

                  Positioned(
                    top: 8,
                    right: 8,

                    child: WishlistButton(
                      coffee: coffee,
                    ),
                  ),
                ],
              ),

              Padding(
                padding: EdgeInsets.all(padding),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(
                      coffee["name"],

                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: nameSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      coffee["description"],

                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                      children: [

                        Text(
                          "\$${coffee["price"]}",

                          style: TextStyle(
                            fontSize: priceSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        InkWell(

                          onTap: addItemToCart,

                          child: Container(
                            width: 30,
                            height: 30,

                            decoration: BoxDecoration(
                              color:
                              const Color(0xFFC67C4E),

                              borderRadius:
                              BorderRadius.circular(10),
                            ),

                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
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
  }
}