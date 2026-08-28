import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  static const String _backendUrl =
      'https://rad-pasca-ab4233.netlify.app/.netlify/functions/create-payment-intent';

  static Future<Map<String, dynamic>?> createPaymentIntent({
    required int amount,
    required String userId,
    required String orderId,
    required String email,
    required String name,
    required String accountNumber,
    required String exp,
    required String cvv,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'userId': userId,
          'orderId': orderId,
          'email': email,
          'name': name,
          'accountNumber': accountNumber,
          'exp': '${exp.substring(0, 2)}/${exp.substring(2, 4)}',
          'cvv': cvv,
        }),
      );

      print("Stripe Status Code: ${response.statusCode}");
      print("Stripe Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print("Payment Response: $data");

        return Map<String, dynamic>.from(data);
      }
      else {
        print("Payment Error Status: ${response.statusCode}");
        print("Payment Error Body: ${response.body}");
        return null;
      }

    } catch (e) {
      print("Payment Service Error: $e");
      return null;
    }
  }
}