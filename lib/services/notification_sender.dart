import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationSender {

  static const String proxyUrl =
      'https://gorgeous-starship-84f940.netlify.app/.netlify/functions/send-notification';

  static Future<void> sendNotification({
    required String receiverId,
    required String senderName,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(proxyUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'receiverId': receiverId,
          'senderName': senderName,
          'message': message,
        }),
      );

      print('Notification proxy status: ${response.statusCode}');
      print('Notification proxy response: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Notification sent successfully');
      } else {
        print('Notification failed');
      }
    } catch (e) {
      print('Notification error: $e');
    }
  }
}