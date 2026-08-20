import 'package:firebase_database/firebase_database.dart';
import 'package:j_app/models/order_model.dart';

Future<List<OrderModel>> getOrders() async {
  final snapshot =
  await FirebaseDatabase.instance
      .ref('orders')
      .get();

  if (snapshot.exists) {
    final allOrders =
    Map<dynamic, dynamic>.from(
      snapshot.value as Map,
    );

    final List<OrderModel> orders = [];
    for (final customerEntry in allOrders.entries) {

      final customerOrders = Map<dynamic, dynamic>.from(
        customerEntry.value as Map,
      );

      for (final orderEntry in customerOrders.entries) {

        final order =
        Map<dynamic, dynamic>.from(
          orderEntry.value as Map,
        );

        orders.add(
          OrderModel.fromMap(
            orderEntry.key,
            customerEntry.key,
            order,
          ),
        );
      }
    }

    return orders;
  }

  return [];
}


Future<void> updateOrderStatus(
    String customerId,
    String orderId,
    String newStatus,
    ) async {
  await FirebaseDatabase.instance
      .ref('orders')
      .child(customerId)
      .child(orderId)
      .update({
    'status': newStatus,
  });
}