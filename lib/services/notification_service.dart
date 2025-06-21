import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';

class NotificationService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<List<NotificationModel>> fetchNotifications(String userId, {bool unreadOnly = false}) async {
    final response = await http.get(Uri.parse('$baseUrl/notifications/$userId?unread_only=$unreadOnly'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/mark_read'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'notification_id': notificationId}),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteNotification(String notificationId) async {
    final response = await http.delete(Uri.parse('$baseUrl/notifications/$notificationId'));
    return response.statusCode == 200;
  }
} 