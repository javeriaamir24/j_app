import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

final DatabaseReference ordersRef =
FirebaseDatabase.instance.ref("orders");

String get currentUserId {
  return FirebaseAuth.instance.currentUser!.uid;
}


Future<void> saveOrder({
  required String name,
  required String phone,
  required String address,
  required String paymentMethod,
  required List<Map<String, dynamic>> items,
  required double subtotal,
  required double deliveryFee,
  required double total,
}) async {

  final orderRef = ordersRef.push();

  final order = {
    "userId": currentUserId,

    "customer": {
      "name": name,
      "phone": phone,
      "address": address,
    },

    "paymentMethod": paymentMethod,

    "orderDate": ServerValue.timestamp,

    "items": {
      for (final item in items)
        item["id"].toString(): {
          "name": item["name"],
          "price": item["price"],
          "image": item["image"],
          "quantity": item["quantity"],
        }
    },

    "subtotal": subtotal,
    "deliveryFee": deliveryFee,
    "totalPrice": total,

    "status": "pending",
  };

  await orderRef.set(order);
}


Future<void> deleteOrder(String orderId) async {
  await ordersRef.child(orderId).remove();
}


Future<String> getStatus(String customerId, String orderId) async {
  final snapshot = await FirebaseDatabase.instance
      .ref('orders')
      .child(customerId)
      .child(orderId)
      .child('status')
      .get();

  return snapshot.value?.toString() ?? 'pending';
}