import 'package:firebase_database/firebase_database.dart';
import 'package:j_app/models/order_model.dart';
import 'package:j_app/services/notification_sender.dart';

Future<List<OrderModel>> getOrders() async {
  final snapshot =
  await FirebaseDatabase.instance.ref('orders').get();

  if (!snapshot.exists || snapshot.value == null) {
    return [];
  }

  final allOrders =
  Map<dynamic, dynamic>.from(snapshot.value as Map);

  final List<OrderModel> orders = [];

  for (final customerEntry in allOrders.entries) {
    final String customerId =
    customerEntry.key.toString();

    final customerOrders =
    Map<dynamic, dynamic>.from(
      customerEntry.value as Map,
    );

    for (final orderEntry in customerOrders.entries) {
      final String orderId =
      orderEntry.key.toString();

      final orderData =
      Map<dynamic, dynamic>.from(
        orderEntry.value as Map,
      );

      orders.add(
        OrderModel.fromMap(
          orderId,
          customerId,
          orderData,
        ),
      );
    }
  }

  // Latest orders first
  orders.sort((a, b) {
    final dateA = DateTime.tryParse(a.orderDate) ??
        DateTime.fromMillisecondsSinceEpoch(0);

    final dateB = DateTime.tryParse(b.orderDate) ??
        DateTime.fromMillisecondsSinceEpoch(0);

    return dateB.compareTo(dateA);
  });

  return orders;
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

  await NotificationSender.sendNotification(
    receiverId: customerId,
    senderName: "The Cafe",
    message: "your order's status is updated!",
    type: "order_status"
  );
}