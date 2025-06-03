import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  // For Android Emulator, use 10.0.2.2 instead of localhost
  static const String baseUrl = 'http://10.0.2.2:8000/user';

  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
      final url = Uri.parse('$baseUrl/profile/$userId');
      print('Attempting to connect to: $url'); // Debug print
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          print('Connection timed out after 10 seconds');
          throw Exception('Connection timed out');
        },
      );
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error response: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Connection error details: $e');
      if (e.toString().contains('Connection refused')) {
        print('Make sure your backend server is running with: uvicorn app.main:app --host 0.0.0.0 --port 8000');
      }
      throw Exception('Connection error: $e');
    }
  }
} 