import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class EmergencyService {
  // For Android Emulator, use 10.0.2.2 instead of localhost
  static const String baseUrl = '${AppConfig.apiBaseUrl}/emergency';

  Future<Map<String, dynamic>> sendEmergencyAlert(Map<String, dynamic> alert) async {
    final url = Uri.parse('$baseUrl/send');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(alert),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to send emergency alert');
    }
  }

  Future<List<dynamic>> getAllAlerts() async {
    final url = Uri.parse('$baseUrl/all');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch alerts');
    }
  }

  Future<List<dynamic>> getHouseAlerts(String houseId) async {
    final url = Uri.parse('$baseUrl/house/$houseId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch house alerts');
    }
  }

  Future<List<dynamic>> getUserAlerts(String userId) async {
    final url = Uri.parse('$baseUrl/$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch user alerts');
    }
  }

  Future<void> acknowledgeAlert(String alertId, String userId) async {
    final url = Uri.parse('$baseUrl/acknowledge/$alertId');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(userId),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to acknowledge alert');
    }
  }

  Future<void> resolveAlert(String alertId) async {
    final url = Uri.parse('$baseUrl/resolve/$alertId');
    final response = await http.post(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to resolve alert');
    }
  }
} 