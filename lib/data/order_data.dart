import 'package:hive_flutter/hive_flutter.dart';

final Box orderBox = Hive.box('orderBox');

void deleteOrder(int index) {
  final key = orderBox.keyAt(index);
  orderBox.delete(key);
}


void saveOrder({
  required String name,
  required String phone,
  required String address,
  required String paymentMethod,
  required List<Map<String, dynamic>> items,
  required double subtotal,
  required double deliveryFee,
  required double total,
}) {
  final order = {
    "orderId": orderBox.length + 1,
    "name": name,
    "phone": phone,
    "address": address,
    "paymentMethod": paymentMethod,
    "dateTime": DateTime.now().toIso8601String(),

    "items": items.map((item) {
      return {
        "name": item["name"],
        "price": item["price"],
        "quantity": item["quantity"],
        "image": item["image"],
      };
    }).toList(),

    "subtotal": subtotal,
    "deliveryFee": deliveryFee,
    "total": total,
    "status": "Placed",
  };

  orderBox.add(order);
}

