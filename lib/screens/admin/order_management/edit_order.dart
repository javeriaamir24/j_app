import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../models/order_model.dart';
import 'order_function.dart';
import 'package:j_app/widgets/admin_bottom_nav_bar.dart';

class EditOrderPage extends StatefulWidget {
  final OrderModel order;

  const EditOrderPage({
    super.key,
    required this.order,
  });

  @override
  State<EditOrderPage> createState() => _EditOrderPageState();
}

class _EditOrderPageState extends State<EditOrderPage> {
  static const Color brown = Color(0xFFC67C4E);

  String _selectedStatus = '';
  bool _isLoading = false;

  final List<String> _statuses = [
    'Pending',
    'Preparing',
    'Ready',
    'Out for Delivery',
    'Delivered',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();

    _selectedStatus = widget.order.status;
  }

  Future<void> _updateStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await updateOrderStatus(
        widget.order.customerId,
        widget.order.id,
        _selectedStatus,
      );

      Fluttertoast.showToast(
        msg: 'Order status updated successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to update order status',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: const Text(
          "Order Details",
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
        centerTitle: false,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            _sectionTitle("Order Information"),

            const SizedBox(height: 10),

            _infoCard(
              children: [
                _infoRow(
                  "Order ID",
                  widget.order.id,
                ),

                _infoRow(
                  "Customer",
                  widget.order.customer,
                ),

                _infoRow(
                  "Date",
                  _formatDate(widget.order.orderDate),
                ),

                _infoRow(
                  "Payment Method",
                  widget.order.paymentMethod,
                ),
              ],
            ),

            const SizedBox(height: 25),


            _sectionTitle("Customer Information"),

            const SizedBox(height: 10),

            _infoCard(
              children: [
                _infoRow(
                  "Name",
                  widget.order.customer,
                ),

                _infoRow(
                  "Phone",
                  widget.order.phone,
                ),

                _infoRow(
                  "Address",
                  widget.order.address,
                ),
              ],
            ),

            const SizedBox(height: 25),


            _sectionTitle("Ordered Items"),

            const SizedBox(height: 10),

            ...widget.order.items.map(
                  (item) {
                final price =
                    (item["price"] as num?)
                        ?.toDouble() ??
                        0.0;

                final quantity =
                    (item["quantity"] as num?)
                        ?.toInt() ??
                        0;

                final itemTotal =
                    price * quantity;

                return Container(
                  margin: const EdgeInsets.only(
                    bottom: 10,
                  ),

                  padding: const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(18),

                    border: Border.all(
                      color: Colors.black,
                      width: 0.5,
                    ),
                  ),

                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(12),

                        child: _buildImage(
                          item["image"],
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [
                            Text(
                              item["name"]
                                  ?.toString() ??
                                  "",

                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "$quantity × \$${price.toStringAsFixed(2)}",
                            ),
                          ],
                        ),
                      ),

                      Text(
                        "\$${itemTotal.toStringAsFixed(2)}",

                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            _sectionTitle("Payment Summary"),

            const SizedBox(height: 10),

            _infoCard(
              children: [
                _priceRow(
                  "Subtotal",
                  widget.order.subtotal,
                ),

                const SizedBox(height: 10),

                _priceRow(
                  "Delivery",
                  widget.order.deliveryFee,
                ),

                const Divider(),

                _priceRow(
                  "Total",
                  widget.order.totalPrice,
                  bold: true,
                ),
              ],
            ),

            const SizedBox(height: 25),


            _sectionTitle("Update Order Status"),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: _selectedStatus,

              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),

                contentPadding:
                const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),

              items: _statuses.map(
                    (status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                },
              ).toList(),

              onChanged: _isLoading
                  ? null
                  : (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton(
                onPressed:
                _isLoading
                    ? null
                    : _updateStatus,

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  Colors.black87,

                  foregroundColor:
                  Colors.white,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),

                child: _isLoading
                    ? const SizedBox(
                  height: 22,
                  width: 22,

                  child:
                  CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  "Save Changes",

                  style:
                  TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar:
      const AdminNavBar(
        selectedIndex: 2,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,

      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }


  Widget _infoCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(15),

        border: Border.all(
          color: Colors.black,
          width: 0.5,
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: children,
      ),
    );
  }


  Widget _infoRow(
      String title,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 120,

            child: Text(
              title,

              style:
              const TextStyle(
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(
      String title,
      double value, {
        bool bold = false,
      }) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,

      children: [
        Text(
          title,

          style: TextStyle(
            fontSize:
            bold ? 20 : 16,

            fontWeight: bold
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),

        Text(
          "\$${value.toStringAsFixed(2)}",

          style: TextStyle(
            fontSize:
            bold ? 20 : 16,

            fontWeight: bold
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildImage(dynamic image) {
    final path =
        image?.toString() ?? "";

    if (path.startsWith("http")) {
      return Image.network(
        path,
        width: 70,
        height: 70,
        fit: BoxFit.cover,

        errorBuilder:
            (context, error, stackTrace) {
          return _imagePlaceholder();
        },
      );
    }

    return Image.asset(
      path,
      width: 70,
      height: 70,
      fit: BoxFit.cover,

      errorBuilder:
          (context, error, stackTrace) {
        return _imagePlaceholder();
      },
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 70,
      height: 70,

      color: Colors.grey.shade200,

      child: const Icon(
        Icons.coffee,
        color: Colors.black87,
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final parsed =
      DateTime.parse(date);

      final day =
      parsed.day
          .toString()
          .padLeft(2, '0');

      final month =
      parsed.month
          .toString()
          .padLeft(2, '0');

      final year =
      parsed.year.toString();

      final hour =
      parsed.hour
          .toString()
          .padLeft(2, '0');

      final minute =
      parsed.minute
          .toString()
          .padLeft(2, '0');

      return "$day/$month/$year  $hour:$minute";
    } catch (e) {
      return date;
    }
  }
}