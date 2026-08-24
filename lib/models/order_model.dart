class OrderModel {
  final String id;
  final String customerId;
  final String customer;
  final String orderDate;
  final String paymentMethod;
  final double subtotal;
  final double deliveryFee;
  final double totalPrice;
  final dynamic items;
  final String status;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customer,
    required this.orderDate,
    required this.paymentMethod,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalPrice,
    required this.items,
    required this.status,
  });

  factory OrderModel.fromMap(
      String id,
      String customerId,
      Map<dynamic, dynamic> data,
      ) {
    final customerData = data['customer'];

    String customerName = '';

    if (customerData is Map) {
      customerName =
          customerData['name']?.toString() ?? '';
    } else {
      customerName =
          customerData?.toString() ?? '';
    }

    return OrderModel(
      id: id,
      customerId: customerId,
      customer: customerName,
      orderDate: data['orderDate']?.toString() ?? '',
      paymentMethod:
      data['paymentMethod']?.toString() ?? '',
      subtotal:
      (data['subtotal'] ?? 0).toDouble(),
      deliveryFee:
      (data['deliveryFee'] ?? 0).toDouble(),
      totalPrice:
      (data['totalPrice'] ?? 0).toDouble(),
      items: data['items'],
      status:
      data['status']?.toString() ?? 'Pending',
    );
  }
}