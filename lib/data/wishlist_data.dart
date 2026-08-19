import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

final DatabaseReference database = FirebaseDatabase.instance.ref();

Future<bool> isWishlisted(String productId) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return false;

  final snapshot = await database
      .child("users")
      .child(user.uid)
      .child("wishlist")
      .child(productId)
      .get();

  return snapshot.exists;
}

Future<void> addToWishlist(Map<String, dynamic> coffee, String productId,) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return;

  await database
      .child("users")
      .child(user.uid)
      .child("wishlist")
      .child(productId)
      .set({
    "name": coffee["name"],
    "description": coffee["description"],
    "price": coffee["price"],
    "image": coffee["image"],
    "category": coffee["category"],
  });
}

Future<void> removeFromWishlist(String productId) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return;

  await database
      .child("users")
      .child(user.uid)
      .child("wishlist")
      .child(productId)
      .remove();
}

Future<List<Map<String, dynamic>>> getWishlistItems() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return [];

  final snapshot = await database
      .child("users")
      .child(user.uid)
      .child("wishlist")
      .get();

  if (!snapshot.exists) {
    return [];
  }

  final List<Map<String, dynamic>> items = [];

  for (final child in snapshot.children) {
    final data = Map<String, dynamic>.from(
      child.value as Map,
    );

    data["id"] = child.key;

    items.add(data);
  }

  return items;
}