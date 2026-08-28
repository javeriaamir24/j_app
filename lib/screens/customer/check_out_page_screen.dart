import 'package:flutter/material.dart';
import 'package:j_app/data/cart_data.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:j_app/widgets/customers_bottom_nav_bar.dart';
import 'package:j_app/services/checkout_storage_service.dart';
import 'order_confirmation_page.dart';
import 'package:j_app/services/payment_service.dart';

class CheckOutPage extends StatefulWidget {
  const CheckOutPage({super.key});

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  List<Map<String, dynamic>> items = [];

  bool loadingCart = true;
  bool loadingDeliveryFee = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  String selectedPayment = "Cash on Delivery";
  bool hidden = true;
  bool _isProcessingPayment = false;

  double deliveryFee = 0.0;

  static const Color brown = Color(0xFFC67C4E);

  @override
  void initState() {
    super.initState();

    loadCart();
    loadSavedCheckoutDetails();
    loadDeliveryFee();
  }

  Future<void> loadDeliveryFee() async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref("settings/deliveryFee")
          .get();

      if (!mounted) return;

      if (snapshot.exists) {
        setState(() {
          deliveryFee =
              double.tryParse(snapshot.value.toString()) ?? 0.0;
          loadingDeliveryFee = false;
        });
      } else {
        setState(() {
          deliveryFee = 0.0;
          loadingDeliveryFee = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        deliveryFee = 0.0;
        loadingDeliveryFee = false;
      });

      print("Delivery fee error: $e");
    }
  }

  Future<bool> askToSaveDetails() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Save checkout details?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Would you like to save your checkout details for your next order?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'No',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: brown,
              ),
              child: const Text(
                'Yes',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> loadSavedCheckoutDetails() async {
    final saved =
    await CheckoutStorageService.loadCheckoutDetails();

    if (!mounted) return;

    setState(() {
      nameController.text = saved['name'] ?? '';
      phoneController.text = saved['phone'] ?? '';
      addressController.text = saved['address'] ?? '';

      selectedPayment = saved['paymentMethod'] ?? "Cash on Delivery";


    });
  }

  Future<void> loadCart() async {
    final cart = await getCartItems();

    if (!mounted) return;

    setState(() {
      items = cart;
      loadingCart = false;
    });
  }

  double calculateSubtotal() {
    double subtotal = 0;

    for (var item in items) {
      subtotal +=
          (item["price"] as num).toDouble() *
              (item["quantity"] as num).toInt();
    }

    return subtotal;
  }

  double calculateTotal() {
    return calculateSubtotal() + deliveryFee;
  }

  bool validateCardFields() {
    final cardNumber = cardNumberController.text.replaceAll(' ', '').trim();
    final cardHolder = cardHolderController.text.trim();
    final expiry = expiryController.text.trim();
    final cvv = cvvController.text.trim();

    if (cardNumber.isEmpty || cardHolder.isEmpty || expiry.isEmpty || cvv.isEmpty) {
      Fluttertoast.showToast(
        msg: "Fill all card details",
      );
      return false;
    }

    if (cardNumber.length < 13 || cardNumber.length > 19) {
      Fluttertoast.showToast(
        msg: "Enter a valid card number",
      );
      return false;
    }

    if (cvv.length < 3 || cvv.length > 4) {
      Fluttertoast.showToast(
        msg: "Enter a valid CVV",
      );
      return false;
    }

    return true;
  }

  Future<void> placeOrder() async {
    if (_isProcessingPayment) return;

    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: "Fill all delivery fields",
      );
      return;
    }

    if (selectedPayment == "Card") {
      if (!validateCardFields()) {
        return;
      }
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Fluttertoast.showToast(
        msg: "Please login first",
      );
      return;
    }

    final shouldSave = await askToSaveDetails();

    if (shouldSave) {
      await CheckoutStorageService.saveCheckoutDetails(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        paymentMethod: selectedPayment,
      );
    }

    final subtotal = calculateSubtotal();
    final total = calculateTotal();

    try {
      setState(() {
        _isProcessingPayment = true;
      });
//card
      if (selectedPayment == "Card") {
        final orderId = FirebaseDatabase.instance
            .ref("orders/${user.uid}")
            .push()
            .key!;

        final amountInCents = (total * 100).round();

        final paymentResult =
        await PaymentService.createPaymentIntent(
          amount: amountInCents,
          userId: user.uid,
          orderId: orderId,
          email: user.email ?? "",
          name: nameController.text.trim(),
          accountNumber: cardNumberController.text
              .replaceAll(" ", "")
              .trim(),
          exp: expiryController.text.trim().length == 4
              ? "${expiryController.text.trim().substring(0, 2)}/${expiryController.text.trim().substring(2, 4)}"
              : expiryController.text.trim(),
          cvv: cvvController.text.trim(),
        );

        if (paymentResult == null) {
          Fluttertoast.showToast(
            msg: "Payment failed",
          );
          return;
        }

        final status = paymentResult["status"];
        final paymentIntentId = paymentResult["paymentIntentId"];
        final customerId = paymentResult["customerId"];

        print("Payment Intent: $paymentIntentId");
        print("Customer: $customerId");
        print("Payment Status: $status");

        if (status == "succeeded") {
          Fluttertoast.showToast(
            msg: "Payment successful",
          );
        } else {
          Fluttertoast.showToast(
            msg: "Payment status: $status",
          );
        }

        return;
      }
//cod
      final orderRef = FirebaseDatabase.instance
          .ref("orders/${user.uid}")
          .push();

      final orderDate = DateTime.now().toIso8601String();

      await orderRef.set({
        "orderDate": orderDate,
        "customer": {
          "name": nameController.text.trim(),
          "phone": phoneController.text.trim(),
          "address": addressController.text.trim(),
        },
        "paymentMethod": selectedPayment,
        "paymentStatus": "Pending",
        "subtotal": subtotal,
        "deliveryFee": deliveryFee,
        "totalPrice": total,
        "status": "Pending",
        "items": items.map((item) {
          return {
            "id": item["id"],
            "name": item["name"],
            "description": item["description"],
            "price": item["price"],
            "image": item["image"],
            "quantity": item["quantity"],
          };
        }).toList(),
      });

      await clearCart();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationPage(
            orderId: orderRef.key ?? "",
            orderDate: orderDate,
            customer: {
              "name": nameController.text.trim(),
              "phone": phoneController.text.trim(),
              "address": addressController.text.trim(),
            },
            paymentMethod: selectedPayment,
            items: List<Map<String, dynamic>>.from(items),
            subtotal: subtotal,
            deliveryFee: deliveryFee,
            total: total,
          ),
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to place order",
      );

      print("Order error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cardNumberController.dispose();
    cardHolderController.dispose();
    expiryController.dispose();
    cvvController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = calculateSubtotal();
    final total = calculateTotal();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.black87,
        title: const Text("Check Out"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
      ),
      body: loadingCart || loadingDeliveryFee
          ? const Center(
        child: CircularProgressIndicator(
          color: brown,
        ),
      )
          : items.isEmpty
          ? const Center(
        child: Text(
          "Your cart is empty",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Delivery Information",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: nameController,
              cursorColor: brown,
              decoration: _inputDecoration(
                label: "Name",
                hint: "Enter Your Name",
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: phoneController,
              maxLength: 11,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              cursorColor: brown,
              decoration: _inputDecoration(
                label: "Phone Number",
                hint: "Enter Your Phone Number",
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: addressController,
              cursorColor: brown,
              maxLines: 3,
              decoration: _inputDecoration(
                label: "Address",
                hint: "Enter Your Address",
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Payment Method",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            RadioListTile<String>(
              activeColor: brown,
              value: "Cash on Delivery",
              groupValue: selectedPayment,
              onChanged: (value) {
                setState(() {
                  selectedPayment = value!;
                });
              },
              title: const Text("Cash on Delivery"),
            ),
            RadioListTile<String>(
              activeColor: brown,
              value: "Card",
              groupValue: selectedPayment,
              onChanged: (value) {
                setState(() {
                  selectedPayment = value!;
                });
              },
              title: const Text("Card"),
            ),
            if (selectedPayment == "Card") ...[
              const SizedBox(height: 10),
              TextField(
                controller: cardNumberController,
                keyboardType: TextInputType.number,
                cursorColor: brown,
                decoration: _inputDecoration(
                  label: "Card Number",
                  hint: "1234 5678 9012 3456",
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: cardHolderController,
                cursorColor: brown,
                decoration: _inputDecoration(
                  label: "Card Holder Name",
                  hint: "Enter name on card",
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: expiryController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      cursorColor: brown,
                      decoration: _inputDecoration(
                        label: "Expiry Date",
                        hint: "MMYY",
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: cvvController,
                      maxLength: 3,
                      keyboardType: TextInputType.number,
                      obscureText: hidden,
                      cursorColor: brown,
                      decoration: _inputDecoration(
                        label: "CVV",
                        hint: "123",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              hidden = !hidden;
                            });
                          },
                          icon: Icon(
                            hidden
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: brown,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            const Text(
              "Order Summary",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              itemCount: items.length,
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = items[index];

                final itemTotal =
                    (item["price"] as num).toDouble() *
                        (item["quantity"] as num).toInt();

                return Container(
                  margin: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.black,
                      width: 0.5,
                    ),
                  ),
                  child: ListTile(
                    contentPadding:
                    const EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius:
                      BorderRadius.circular(12),
                      child: _buildProductImage(
                        item["image"],
                      ),
                    ),
                    title: Text(
                      item["name"]?.toString() ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${item["quantity"]} × \$${item["price"]}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "\$${itemTotal.toStringAsFixed(2)}",
                        ),
                        IconButton(
                          onPressed: () async {
                            await removeFromCart(
                              item["productId"],
                            );
                            await loadCart();
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: brown,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            _priceRow(
              "Subtotal",
              subtotal,
            ),
            const SizedBox(height: 10),
            _priceRow(
              "Delivery",
              deliveryFee,
            ),
            const Divider(),
            _priceRow(
              "Total",
              total,
              bold: true,
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loadingDeliveryFee
                    ? null
                    : placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brown,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                  Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  loadingDeliveryFee
                      ? "LOADING..."
                      : "PLACE ORDER",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 1,
      ),

    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.black,
      ),
      hintText: hint,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.black,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: brown,
          width: 2,
        ),
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
            fontSize: bold ? 20 : 16,
            fontWeight: bold
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        Text(
          "\$${value.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: bold ? 20 : 16,
            fontWeight: bold
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(dynamic image) {
    final imagePath = image?.toString() ?? "";

    if (imagePath.startsWith("http")) {
      return Image.network(
        imagePath,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _imagePlaceholder();
        },
      );
    }

    return Image.asset(
      imagePath,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _imagePlaceholder();
      },
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.coffee,
        color: Colors.black87,
      ),
    );
  }
}