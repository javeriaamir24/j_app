import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:j_app/data/wishlist_data.dart';
import 'package:j_app/widgets/bottom_nav_bar.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wishlist"),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),

      body: ValueListenableBuilder(
        valueListenable: wishlistBox.listenable(),

        builder: (context, box, _) {

          final items = wishlistItems;

          if (items.isEmpty) {
            return const Center(
              child: Text(
                "Your wishlist is empty",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: items.length,

            itemBuilder: (context, index) {

              final item = items[index];

              return Card(
                margin: const EdgeInsets.all(10),

                child: ListTile(
                  leading: Image.asset(
                    item["image"],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),

                  title: Text(
                    item["name"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(
                    "\$${item["price"]}",
                  ),

                  trailing: IconButton(
                    icon: const Icon(
                      Icons.favorite,
                      color: Color(0xFFC67C4E),
                    ),

                    onPressed: () {
                      removeFromWishlist(
                        item["name"],
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 3,
      ),
    );
  }
}