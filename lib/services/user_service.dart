import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class UserService {
  // For Android Emulator, use 10.0.2.2 instead of localhost
  static const String baseUrl = '${AppConfig.apiBaseUrl}/user';

  Future<Map<String, dynamic>> getUserProfile(String? userId) async {
    if (userId == null || userId.isEmpty) {
      throw Exception('Invalid user ID');
    }

    try {
      final url = Uri.parse('$baseUrl/profile/$userId');

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
              throw Exception('Connection timed out');
            },
          );

      if (response.statusCode == 200) {
        // Get allergies
        final allergies = await getUserAllergies(userId);
        final userData = json.decode(response.body);
        userData['allergies'] = allergies;
        return userData;
      } else {
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('Connection refused')) {
        throw Exception(
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
      final Map<String, dynamic> body = {
        'user_id': userId,
        'name': name,
        'email': email,
        'phone': phone,
        'height': height,
        'weight': weight,
        'birthday': birthday,
        'allergies': allergies,
      };
      if (diet != null) body['diet'] = diet;
      if (gender != null) body['gender'] = gender;
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> updateUserRole({
    required String userId,
    required String newRole,
    required String houseId,
  }) async {
    final url = Uri.parse('$baseUrl/update-user-role');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'new_role': newRole,
        'house_id': houseId,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update user role: \\n${response.body}');
    }
  }

  Future<bool> updateProfilePicture({
    required String userId,
    required String base64Image,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/update-profile-picture');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'profile_pic': base64Image,
        }),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update profile picture: \\${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update profile picture: \\${e.toString()}');
    }
  }
}
