import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CheckoutStorageService {

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String nameKey = 'checkout_name';
  static const String phoneKey = 'checkout_phone';
  static const String addressKey = 'checkout_address';
  static const String paymentMethodKey = 'checkout_payment_method';


  static Future<void> saveCheckoutDetails({
    required String name,
    required String phone,
    required String address,
    required String paymentMethod,
  }) async {
    await _storage.write(
      key: nameKey,
      value: name,
    );

    await _storage.write(
      key: phoneKey,
      value: phone,
    );

    await _storage.write(
      key: addressKey,
      value: address,
    );

    await _storage.write(
      key: paymentMethodKey,
      value: paymentMethod,
    );

  }

  static Future<Map<String, String?>> loadCheckoutDetails() async {
    return {
      'name': await _storage.read(key: nameKey),
      'phone': await _storage.read(key: phoneKey),
      'address': await _storage.read(key: addressKey),
      'paymentMethod':
      await _storage.read(key: paymentMethodKey),
    };
  }
}
