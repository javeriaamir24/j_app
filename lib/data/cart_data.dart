import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

final DatabaseReference usersRef =
FirebaseDatabase.instance.ref("users");

String get userId {
  return FirebaseAuth.instance.currentUser!.uid;
}

Future<List<Map<String, dynamic>>> getCartItems() async {
  final snapshot = await usersRef
      .child(userId)
      .child("cart")
      .get();

  if (!snapshot.exists || snapshot.value == null) {
    return [];
  }

  final rawData = snapshot.value;

  if (rawData is! Map) {
    return [];
  }

  final data = Map<String, dynamic>.from(rawData);

  return data.entries.map((entry) {
    final rawItem = entry.value;

    if (rawItem is! Map) {
      return <String, dynamic>{
        "productId": entry.key.toString(),
        "id": entry.key.toString(),
        "name": "Unknown Coffee",
        "description": "No description available.",
        "detailedDescription": "No description available.",
        "image": "",
        "price": 0.0,
        "quantity": 0,
      };
    }

    final item = Map<String, dynamic>.from(rawItem);

    item["productId"] = entry.key.toString();
    item["id"] = item["id"]?.toString() ?? entry.key.toString();

    item["name"] =
        item["name"]?.toString() ?? "Unknown Coffee";

    item["description"] =
        item["description"]?.toString() ??
            "No description available.";

    item["detailedDescription"] =
        item["detailedDescription"]?.toString() ??
            item["description"]?.toString() ??
            "No description available.";

    item["image"] =
        item["image"]?.toString() ?? "";

    item["price"] =
    item["price"] is num
        ? (item["price"] as num).toDouble()
        : double.tryParse(
      item["price"]?.toString() ?? "0",
    ) ??
        0.0;

    item["quantity"] =
    item["quantity"] is num
        ? (item["quantity"] as num).toInt()
        : int.tryParse(
      item["quantity"]?.toString() ?? "0",
    ) ??
        0;

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
  if (coffeeId.isEmpty) {
    return 0;
  }

  final snapshot = await usersRef
      .child(userId)
      .child("cart")
      .child(coffeeId)
      .child("quantity")
      .get();

  if (!snapshot.exists || snapshot.value == null) {
    return 0;
  }

  if (snapshot.value is num) {
    return (snapshot.value as num).toInt();
  }

  return int.tryParse(
    snapshot.value.toString(),
  ) ??
      0;
}

Future<void> addToCart(
    Map<String, dynamic> coffee,
    String coffeeId,
    ) async {
  if (coffeeId.isEmpty) {
    return;
  }

  final itemRef = usersRef
      .child(userId)
      .child("cart")
      .child(coffeeId);

  final snapshot = await itemRef.get();

  if (snapshot.exists && snapshot.value != null) {
    final rawData = snapshot.value;

    if (rawData is Map) {
      final data =
      Map<String, dynamic>.from(rawData);

      final currentQuantity =
      data["quantity"] is num
          ? (data["quantity"] as num).toInt()
          : int.tryParse(
        data["quantity"]?.toString() ?? "0",
      ) ??
          0;

      await itemRef.update({
        "quantity": currentQuantity + 1,
      });
    }
  } else {
    final name =
        coffee["name"]?.toString() ?? "Unknown Coffee";

    final description =
        coffee["description"]?.toString() ??
            "No description available.";

    final detailedDescription =
        coffee["detailedDescription"]?.toString() ??
            description;

    final image =
        coffee["image"]?.toString() ?? "";

    final price =
    coffee["price"] is num
        ? (coffee["price"] as num).toDouble()
        : double.tryParse(
      coffee["price"]?.toString() ?? "0",
    ) ??
        0.0;

    await itemRef.set({
      "id": coffeeId,
      "name": name,
      "description": description,
      "detailedDescription": detailedDescription,
      "image": image,
      "price": price,
      "quantity": 1,
    });
  }
}

Future<void> increaseQuantity(
    String coffeeId,
    ) async {
  if (coffeeId.isEmpty) {
    return;
  }

  final quantityRef = usersRef
      .child(userId)
      .child("cart")
      .child(coffeeId)
      .child("quantity");

  final snapshot = await quantityRef.get();

  if (!snapshot.exists || snapshot.value == null) {
    return;
  }

  final quantity =
  snapshot.value is num
      ? (snapshot.value as num).toInt()
      : int.tryParse(
    snapshot.value.toString(),
  ) ??
      0;

  await quantityRef.set(quantity + 1);
}

Future<void> decreaseQuantity(
    String coffeeId,
    ) async {
  if (coffeeId.isEmpty) {
    return;
  }

  final itemRef = usersRef
      .child(userId)
      .child("cart")
      .child(coffeeId);

  final quantityRef =
  itemRef.child("quantity");

  final snapshot = await quantityRef.get();

  if (!snapshot.exists || snapshot.value == null) {
    return;
  }

  final quantity =
  snapshot.value is num
      ? (snapshot.value as num).toInt()
      : int.tryParse(
    snapshot.value.toString(),
  ) ??
      0;

  if (quantity > 1) {
    await quantityRef.set(quantity - 1);
  } else {
    await itemRef.remove();
  }
}

Future<void> removeFromCart(
    String coffeeId,
    ) async {
  if (coffeeId.isEmpty) {
    return;
  }

  await usersRef
      .child(userId)
      .child("cart")
      .child(coffeeId)
      .remove();
}