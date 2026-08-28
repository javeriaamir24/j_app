import 'dart:convert';
import 'dart:io';

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
    final client = HttpClient();

    try {
      final uri = Uri.parse(_backendUrl);
      final request = await client.postUrl(uri);

      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');

      final payload = jsonEncode({
        'amount': amount,
        'userId': userId,
        'orderId': orderId,
        'email': email,
        'name': name,
        'accountNumber': accountNumber,
        'exp': exp,
        'cvv': cvv,
      });

      final payloadBytes = utf8.encode(payload);

      request.headers.set(HttpHeaders.contentLengthHeader, payloadBytes.length);
      request.add(payloadBytes);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print("Stripe Status Code: ${response.statusCode}");
      print("Stripe Response: $responseBody");

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);

        print("Payment Response: $data");

        return Map<String, dynamic>.from(data);
      } else {
        print("Payment Error Status: ${response.statusCode}");
        print("Payment Error Body: $responseBody");
        return null;
      }
    } catch (e) {
      print("Payment Service Error: $e");
      return null;
    } finally {
      client.close();
    }
  }

}