import 'package:flutter/material.dart';
import 'package:j_app/data/cart_data.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'order_history_page.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';


class CheckOutPage extends StatefulWidget {
  const CheckOutPage({super.key});

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {

  List<Map<String, dynamic>> items = [];bool loadingCart = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  String selectedPayment = "Cash on Delivery";
  bool hidden = true;

  double deliveryFee = 2.00;

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    final cart = await getCartItems();

    if (!mounted) return;

    setState(() {
      items = cart;
      loadingCart = false;
    });
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

  double calculateSubtotal() {
    double subtotal = 0;

    for (var item in items) {
      subtotal +=
          (item["price"] as num).toDouble() * (item["quantity"] as num).toInt();
    }

    return subtotal;
  }

  double calculateTotal() {
    return calculateSubtotal() + deliveryFee;
  }

  Future<void> placeOrder() async {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: "Fill all delivery fields",
      );
      return;
    }

    if (selectedPayment == "Card") {
      if (cardNumberController.text.trim().isEmpty ||
          cardHolderController.text.trim().isEmpty ||
          expiryController.text.trim().isEmpty ||
          cvvController.text.trim().isEmpty) {
        Fluttertoast.showToast(
          msg: "Fill all card details",
        );
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

    final subtotal = calculateSubtotal();
    final total = calculateTotal();

    try {
      final orderRef = FirebaseDatabase.instance
          .ref("orders/${user.uid}")
          .push();

      await orderRef.set({
        "orderDate": DateTime.now().toIso8601String(),
        "customer": {
          "name": nameController.text.trim(),
          "phone": phoneController.text.trim(),
          "address": addressController.text.trim(),
        },
        "paymentMethod": selectedPayment,
        "subtotal": subtotal,
        "deliveryFee": deliveryFee,
        "totalPrice": total,

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

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Order Placed",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            content: Text(
              selectedPayment == "Card"
                  ? "Your payment was successful and your order has been placed."
                  : "Your order has been placed successfully.",
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                      const OrderHistoryPage(),
                    ),
                  );
                },

                child: const Text(
                  "OK",
                  style: TextStyle(
                    color: Color(0xFFC67C4E),
                  ),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to place order",
      );

      print("Order error: $e");
    }
  }
  @override
  Widget build(BuildContext context) {

    final subtotal = calculateSubtotal();
    final total = calculateTotal();

    return Scaffold(

      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.black87,
        title: const Text("Check Out",)
        ,        titleTextStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 30,),
      ),

      body: loadingCart
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFC67C4E),
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
              cursorColor: const Color(0xFFC67C4E),

              decoration: InputDecoration(
                labelText: "Name",
                labelStyle: const TextStyle(
                  color: Colors.black,
                ),
                hintText: "Enter Your Name",

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFC67C4E),
                  ),
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
                    color: Color(0xFFC67C4E),
                    width: 2,
                  ),
                ),
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
              cursorColor: const Color(0xFFC67C4E),

              decoration: InputDecoration(
                labelText: "Phone Number",
                labelStyle: const TextStyle(
                  color: Colors.black,
                ),
                hintText: "Enter Your Phone Number",


                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFC67C4E),
                  ),
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
                    color: Color(0xFFC67C4E),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: addressController,
              cursorColor: const Color(0xFFC67C4E),
              maxLines: 3,

              decoration: InputDecoration(
                labelText: "Address",
                labelStyle: const TextStyle(
                  color: Colors.black,
                ),
                hintText: "Enter Your Address",

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFC67C4E),
                  ),
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
                    color: Color(0xFFC67C4E),
                    width: 2,
                  ),
                ),
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
              activeColor: Color(0xFFC67C4E),
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
              activeColor: const Color(0xFFC67C4E),

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
                cursorColor: const Color(0xFFC67C4E),

                decoration: InputDecoration(
                  labelText: "Card Number",
                  hintText: "1234 5678 9012 3456",

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
                      color: Color(0xFFC67C4E),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: cardHolderController,
                cursorColor: const Color(0xFFC67C4E),

                decoration: InputDecoration(
                  labelText: "Card Holder Name",
                  hintText: "Enter name on card",

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
                      color: Color(0xFFC67C4E),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [

                  Expanded(
                    child: TextField(
                      controller: expiryController,
                      keyboardType: TextInputType.number,
                      cursorColor: const Color(0xFFC67C4E),

                      decoration: InputDecoration(
                        labelText: "Expiry Date",
                        hintText: "MM/YY",

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
                            color: Color(0xFFC67C4E),
                            width: 2,
                          ),
                        ),
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
                      cursorColor: const Color(0xFFC67C4E),

                      decoration: InputDecoration(
                        labelText: "CVV",
                        hintText: "123",
                        icon: Icon(hidden ? Icons.visibility: Icons.visibility_off,color: const Color(0xFFC67C4E),),


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
                            color: Color(0xFFC67C4E),
                            width: 2,
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
              physics: const NeverScrollableScrollPhysics(),

              itemBuilder: (context, index) {

                final item = items[index];

                return
                  Container(
                  margin: const EdgeInsets.only(bottom: 10),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                border: Border.all(
                color: Colors.black,
                width: 0.5,
                ),
                ),

                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),

                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        item["image"],
                        width: 55,
                        height: 55,
                        fit: BoxFit.cover,
                      ),
                    ),

                    title: Text(
                      item["name"],
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
                          "\$${(
                              (item["price"] as num).toDouble() *
                                  (item["quantity"] as num).toInt()
                          ).toStringAsFixed(2)}",
                        ),

                        IconButton(
                          onPressed: () async {
                          await removeFromCart(item["productId"]);

                          await loadCart();
                        },

                          icon: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFC67C4E),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Divider(),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

              children: [
                const Text("Subtotal"),
                Text(
                  "\$${subtotal.toStringAsFixed(2)}",
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

              children: [
                const Text("Delivery"),
                Text(
                  "\$${deliveryFee.toStringAsFixed(2)}",
                ),
              ],
            ),

            const Divider(),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  "Total",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  "\$${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(

                onPressed: placeOrder,

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFFC67C4E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),

                child: const Text(
                  "PLACE ORDER",
                  style: TextStyle(
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
    );
  }
}