import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  // For Android Emulator, use 10.0.2.2 instead of localhost
  static const String baseUrl = 'http://10.0.2.2:8000/user';

  Future<Map<String, dynamic>> getUserProfile(String? userId) async {
    if (userId == null || userId.isEmpty) {
      throw Exception('Invalid user ID');
    }

    try {
      final url = Uri.parse('$baseUrl/profile/$userId');
      print('Attempting to connect to: $url'); // Debug print

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(
            Duration(seconds: 10),
            onTimeout: () {
              print('Connection timed out after 10 seconds');
              throw Exception('Connection timed out');
            },
          );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Get allergies
        final allergies = await getUserAllergies(userId);
        final userData = json.decode(response.body);
        userData['allergies'] = allergies;
        return userData;
      } else {
        print('Error response: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Connection error details: $e');
      if (e.toString().contains('Connection refused')) {
        print(
          'Make sure your backend server is running with: uvicorn app.main:app --host 0.0.0.0 --port 8000',
        );
      }
      throw Exception('Connection error: $e');
    }
  }

  Future<List<String>> getUserAllergies(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/allergies/$userId');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['allergies']);
      } else {
        throw Exception('Failed to load user allergies');
      }
    } catch (e) {
      print('Error getting allergies: $e');
      return [];
    }
  }

  Future<void> updateProfile({
    required String userId,
    required String name,
    required String email,
    required String phone,
    double? height,
    double? weight,
    String? diet,
    String? gender,
    String? birthday,
    required List<String> allergies,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/update-profile');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'name': name,
          'email': email,
          'phone': phone,
          'height': height,
          'weight': weight,
          'diet': diet,
          'gender': gender,
          'birthday': birthday,
          'allergies': allergies,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }
}
