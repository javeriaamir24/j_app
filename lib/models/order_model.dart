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
  final String phone;
  final String address;

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
    required this.phone,
    required this.address,
  });

  factory OrderModel.fromMap(
      String id,
      String customerId,
      Map<dynamic, dynamic> data,
      ) {
    final customerData = data['customer'];

    String customerName = '';
    String customerPhone = '';
    String customerAddress = '';


    if (customerData is Map) {
      customerName =
          customerData['name']?.toString() ?? '';
      customerPhone =
          customerData['phone']?.toString() ?? '';

      customerAddress =
          customerData['address']?.toString() ?? '';
    } else {
      customerName =
          customerData?.toString() ?? '';
    }

    return OrderModel(
      id: id,
      customerId: customerId,
      customer: customerName,
      phone: customerPhone,
      address: customerAddress,
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