import 'package:hive_flutter/hive_flutter.dart';

final Box wishlistBox = Hive.box('wishlistBox');

bool isWishlisted(String coffeeName) {
  for (var item in wishlistBox.values) {
    final coffee = Map<String, dynamic>.from(item);

    if (coffee["name"] == coffeeName) {
      return true;
    }
  }

  return false;
}

void addToWishlist(Map<String, dynamic> coffee) {
  wishlistBox.add({
    "name": coffee["name"],
    "description": coffee["description"],
    "price": coffee["price"],
    "image": coffee["image"],
    "category": coffee["category"],
  });
}

void removeFromWishlist(String coffeeName) {
  for (var key in wishlistBox.keys) {
    final item = Map<String, dynamic>.from(
      wishlistBox.get(key),
    );

    if (item["name"] == coffeeName) {
      wishlistBox.delete(key);
      break;
    }
  }
}

List<Map<String, dynamic>> get wishlistItems {
  return wishlistBox.values
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

