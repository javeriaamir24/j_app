import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CheckoutStorageService {

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String nameKey = 'checkout_name';
  static const String phoneKey = 'checkout_phone';
  static const String addressKey = 'checkout_address';
  static const String paymentMethodKey = 'checkout_payment_method';
  static const String cardNumberKey = 'checkout_card_number';
  static const String cardHolderKey = 'checkout_card_holder';
  static const String expiryKey = 'checkout_expiry';

  static Future<void> saveCheckoutDetails({
    required String name,
    required String phone,
    required String address,
    required String paymentMethod,
    String? cardNumber,
    String? cardHolder,
    String? expiry,
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

    if (cardNumber != null) {
      await _storage.write(
        key: cardNumberKey,
        value: cardNumber,
      );
    }

    if (cardHolder != null) {
      await _storage.write(
        key: cardHolderKey,
        value: cardHolder,
      );
    }

    if (expiry != null) {
      await _storage.write(
        key: expiryKey,
        value: expiry,
      );
    }
  }

  static Future<Map<String, String?>> loadCheckoutDetails() async {
    return {
      'name': await _storage.read(key: nameKey),
      'phone': await _storage.read(key: phoneKey),
      'address': await _storage.read(key: addressKey),
      'paymentMethod':
      await _storage.read(key: paymentMethodKey),
      'cardNumber':
      await _storage.read(key: cardNumberKey),
      'cardHolder':
      await _storage.read(key: cardHolderKey),
      'expiry':
      await _storage.read(key: expiryKey),
    };
  }
}
