import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:j_app/data/wishlist_data.dart';
import 'package:j_app/widgets/customers_bottom_nav_bar.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Please login first",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    final wishlistRef = FirebaseDatabase.instance
        .ref("users/${user.uid}/wishlist");

    return Scaffold(

      appBar: AppBar(
        title: const Text("Wishlist"),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<DatabaseEvent>(

        stream: wishlistRef.onValue,

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFC67C4E),
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.snapshot.value == null) {

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

          final data =
              snapshot.data!.snapshot.value;

          if (data is! Map) {
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

          final items = data.entries.map((entry) {

            final item =
            Map<String, dynamic>.from(
              entry.value as Map,
            );

            item["id"] = entry.key;

            return item;

          }).toList();

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

                margin:
                const EdgeInsets.all(10),

                child: ListTile(

                  leading:
                  item["image"]
                      .toString()
                      .startsWith("http")
                      ? Image.network(
                    item["image"],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,

                    errorBuilder: (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      );
                    },
                  )
                      : Image.asset(
                    item["image"],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,

                    errorBuilder: (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.coffee,
                          color: Colors.black87,
                        ),
                      );
                    },
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

                    onPressed: () async {

                      await removeFromWishlist(
                        item["id"],
                      );
                    },
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
          selectedIndex: 0,
        ),
      ),
    );
  }
}