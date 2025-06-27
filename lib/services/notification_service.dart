import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';
import '../config.dart';

class NotificationService {
  static const String baseUrl = AppConfig.apiBaseUrl;

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

  Future<bool> markAllAsRead(String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/mark_all_read'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'user_id': userId}),
    );
    return response.statusCode == 200;
  }

  Future<bool> sendNotification({
    required List<String> userIds,
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/send'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_ids': userIds,
        'title': title,
        'body': body,
        'type': type ?? 'event',
        'data': data ?? {},
      }),
    );
    return response.statusCode == 200;
  }
} 