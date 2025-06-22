import 'dart:convert';
import 'package:http/http.dart' as http;
import '../new Lib/models/event.dart';

class CalendarService {
  static const String baseUrl =
      'http://10.0.2.2:8000/calendar/events'; // Change to your backend URL

  // Fetch events for a user (and optionally a household)
  static Future<List<Event>> fetchEvents({
    required String userId,
    String? houseId,
  }) async {
    final uri = Uri.parse(
      '$baseUrl?user_id=$userId${houseId != null ? '&house_id=$houseId' : ''}',
    );
    final response = await http.get(uri);
    print('[DEBUG] Raw response: [36m${response.body}[0m');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) {
        print('[DEBUG] Parsing event: $e');
        return Event.fromApiJson(e);
      }).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  // Add a new event
  static Future<bool> addEvent(Map<String, dynamic> eventData) async {
    final uri = Uri.parse(baseUrl);
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(eventData),
    );
    return response.statusCode == 200;
  }

  // Update an event
  static Future<bool> updateEvent(
    String eventId,
    Map<String, dynamic> eventData,
  ) async {
    final uri = Uri.parse('$baseUrl/$eventId');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(eventData),
    );
    return response.statusCode == 200;
  }

  // Delete an event
  static Future<bool> deleteEvent(String eventId) async {
    final uri = Uri.parse('$baseUrl/$eventId');
    final response = await http.delete(uri);
    return response.statusCode == 200;
  }
}
