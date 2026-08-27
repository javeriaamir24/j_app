import 'package:flutter/material.dart';
import 'package:j_app/models/order_model.dart';
import 'package:j_app/widgets/admin_bottom_nav_bar.dart';

import 'order_function.dart';
import 'edit_order.dart';

class OrderManagement extends StatefulWidget {
  const OrderManagement({super.key});

  @override
  State<OrderManagement> createState() => _OrderManagementState();
}

class _OrderManagementState extends State<OrderManagement> {

  late Future<List<OrderModel>> _ordersFuture;

  String _formatDate(String date) {
    try {
      final parsed = DateTime.parse(date).toLocal();

      final day =
      parsed.day.toString().padLeft(2, '0');

      final month =
      parsed.month.toString().padLeft(2, '0');

      final year =
      parsed.year.toString();

      int hour = parsed.hour;

      final minute =
      parsed.minute.toString().padLeft(2, '0');

      final period =
      hour >= 12 ? "PM" : "AM";

      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour -= 12;
      }

      return "$day/$month/$year  $hour:$minute $period";
    } catch (e) {
      return date;
    }
  }

  @override
  void initState() {
    super.initState();

    _loadOrders();
  }

  void _loadOrders() {
    _ordersFuture = getOrders();
  }

  void _refreshOrders() {
    setState(() {
      _loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,

        title: const Text(
          'Order Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      body: FutureBuilder<List<OrderModel>>(
        future: _ordersFuture,

        builder: (context, snapshot) {

          // Loading
          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black87,
              ),
            );
          }

          // Error
          if (snapshot.hasError) {

            return const Center(

              child: Text(
                'Something went wrong',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            );
          }

          final orders = snapshot.data ?? [];

          // Empty
          if (orders.isEmpty) {

            return const Center(
              child: Text(
                'No orders available',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
            );
          }

          // Orders
          return ListView.builder(

            padding: const EdgeInsets.all(16),

            itemCount: orders.length,

            itemBuilder: (context, index) {

              final order = orders[index];

              return Card(
                color: Colors.white,

                elevation: 3,

                margin: const EdgeInsets.only(
                  bottom: 14,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      Row(
                        children: [

                          Expanded(
                            child: Text(
                              'Order #${order.id}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),

                          IconButton(
                            tooltip: 'Edit Status',

                            onPressed: () async {

                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditOrderPage(
                                        order: order,
                                      ),
                                ),
                              );

                              _refreshOrders();
                            },

                            icon: const Icon(
                              Icons.edit,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),

                      const Divider(),

                      const SizedBox(height: 5),

                      // Customer
                      Text(
                        'Customer: ${order.customer}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Date
                      Text(
                        'Date: ${_formatDate(order.orderDate)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 8),


                      Text(
                        'Payment: ${order.paymentMethod}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Total
                      Text(
                        'Total: \$ ${order.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight:
                          FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Status
                      Row(
                        children: [

                          const Text(
                            'Status: ',
                            style: TextStyle(
                              fontWeight:
                              FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),

                          Text(
                            order.status,
                            style: TextStyle(
                              fontWeight:
                              FontWeight.bold,
                              color: order.status ==
                                  'Delivered'
                                  ? Colors.green
                                  : order.status ==
                                  'Cancelled'
                                  ? Colors.red
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: const AdminNavBar(
          selectedIndex: 2,
        ),
      ),
    );
  }
}