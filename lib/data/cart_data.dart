import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

final DatabaseReference usersRef = FirebaseDatabase.instance.ref("users");

String get userId {
  return FirebaseAuth.instance.currentUser!.uid;
}

Future<List<Map<String, dynamic>>> getCartItems() async {

  final snapshot = await usersRef
      .child(userId)
      .child("cart")
      .get();

  if (!snapshot.exists) {
    return [];
  }

  final data =
  Map<String, dynamic>.from(snapshot.value as Map);

  return data.entries.map((entry) {

    final item =
    Map<String, dynamic>.from(entry.value);

    item["productId"] = entry.key;

    return item;

  }).toList();
}

Future<void> clearCart() async {

  await usersRef
      .child(userId)
      .child("cart")
      .remove();
}

Future<int> getQuantity(String coffeeId) async {

  final snapshot = await usersRef
      .child(userId)
      .child("cart")
      .child(coffeeId)
      .child("quantity")
      .get();

  if (!snapshot.exists) {
    return 0;
  }

  return (snapshot.value as num).toInt();
}

Future<void> addToCart(Map<String, dynamic> coffee, String coffeeId,) async {

  final itemRef = usersRef
      .child(userId)
      .child("cart")
      .child(coffeeId);

  final snapshot = await itemRef.get();

  if (snapshot.exists) {

    final data =
    Map<String, dynamic>.from(
      snapshot.value as Map,
    );

    final currentQuantity =
    (data["quantity"] as num).toInt();

    await itemRef.update({
      "quantity": currentQuantity + 1,
    });

  } else {

    await itemRef.set({

      "id": coffeeId,

      "name": coffee["name"],
      "description": coffee["description"],
      "image": coffee["image"],
      "price": coffee["price"],

      "quantity": 1,
    });
  }
}

Future<void> increaseQuantity(String coffeeId,) async {

  final quantityRef = usersRef
      .child(userId)
      .child("cart")
      .child(coffeeId)
      .child("quantity");

  final snapshot =
  await quantityRef.get();

  if (!snapshot.exists) {
    return;
  }

  final quantity =
  (snapshot.value as num).toInt();

  await quantityRef.set(
    quantity + 1,
  );
}

Future<void> decreaseQuantity(String coffeeId,) async {

  final itemRef = usersRef
      .child(userId)
      .child("cart")
      .child(coffeeId);

  final quantityRef =
  itemRef.child("quantity");

  final snapshot =
  await quantityRef.get();

  if (!snapshot.exists) {
    return;
  }

  final quantity =
  (snapshot.value as num).toInt();

  if (quantity > 1) {

    await quantityRef.set(
      quantity - 1,
    );

  } else {

    await itemRef.remove();
  }
}

Future<void> removeFromCart(String coffeeId,) async {
  await usersRef
      .child(userId)
      .child("cart")
      .child(coffeeId)
      .remove();
}
