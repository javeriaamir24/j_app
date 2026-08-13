import 'package:hive_flutter/hive_flutter.dart';

final Box cartBox = Hive.box('cartBox');

List<Map<String, dynamic>> get cartItems {
  return cartBox.values
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

int getQuantity(String coffeeName){
  for(var item in cartBox.values){
    final cartItem = Map<String,dynamic>.from(item);
  if (cartItem["name"] == coffeeName){
  return cartItem["quantity"] ?? 0;
  }
  }
  return 0;
  }

void addToCart(Map<String, dynamic> coffee) {
  int? existingKey;
  for (var key in cartBox.keys) {
    final item = Map<String, dynamic>.from(cartBox.get(key));
    if (item["name"] == coffee["name"]) {
      existingKey = key;
      break;
    }
  }
  void removeFromCart(Map<String, dynamic> item) {
    cartItems.removeWhere(
          (cartItem) => cartItem["name"] == item["name"],
    );

    cartBox.put("cartItems", cartItems);
  }

  if (existingKey != null) {
    final item = Map<String, dynamic>.from(
      cartBox.get(existingKey),
    );
    item["quantity"]++;
    cartBox.put(existingKey, item);
  } else {
    cartBox.add({
      "name": coffee["name"],
      "description": coffee["description"],
      "price": coffee["price"],
      "image": coffee["image"],
      "quantity": 1,
    });
  }
}

void increaseQuantity(int index){
  final key = cartBox.keyAt(index);
  final item = Map<String, dynamic> .from(cartBox.get(key),);
  item["quantity"]++;
  cartBox.put(key,item);
}

void decreaseQuantity(int index) {
  final key = cartBox.keyAt(index);
  final item = Map<String, dynamic>.from(cartBox.get(key),);
  if (item["quantity"] > 1) {
    item["quantity"]--;
    cartBox.put(key, item);
  } else {
    cartBox.delete(key);
  }
}

void removeFromCart(Map<String, dynamic> item) {
  dynamic keyToDelete;

  for (var key in cartBox.keys) {
    final cartItem = Map<String, dynamic>.from(cartBox.get(key));

    if (cartItem["name"] == item["name"]) {
      keyToDelete = key;
      break;
    }
  }

  if (keyToDelete != null) {
    cartBox.delete(keyToDelete);
  }
}