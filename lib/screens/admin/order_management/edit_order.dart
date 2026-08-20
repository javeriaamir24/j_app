import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../models/order_model.dart';
import 'order_function.dart';

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
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,

        title: const Text(
          'Edit Order',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              'Order ID',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              widget.order.id,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Customer',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              widget.order.customer,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Order Status',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: _selectedStatus,

              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              items: _statuses.map((status) {

                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );

              }).toList(),

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

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton(

                onPressed:
                _isLoading ? null : _updateStatus,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: _isLoading

                    ? const SizedBox(
                  height: 22,
                  width: 22,

                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )

                    : const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}