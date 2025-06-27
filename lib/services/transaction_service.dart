import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class TransactionService {
  static const String baseUrl = AppConfig.apiBaseUrl;

  // Add a new transaction (expense or income)
  static Future<void> addTransaction({
    required String userId,
    required double amount,
    required String category,
    required String transactionType,
    String? description,
    String? source,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transaction/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'amount': amount,
          'category': category,
          'transaction_type': transactionType,
          'description': description,
          'source': source,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add transaction: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding transaction: $e');
    }
  }

  // Get all transactions for a user
  static Future<List<Map<String, dynamic>>> getTransactions(
    String userId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get transactions: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting transactions: $e');
    }
  }

  // Add a new card
  static Future<void> addCard({
    required String userId,
    required String cardType,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardholderName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/card/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'card_type': cardType,
          'card_number': cardNumber,
          'expiry_date': expiryDate,
          'cvv': cvv,
          'cardholder_name': cardholderName,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add card: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding card: $e');
    }
  }

  // Get all cards for a user
  static Future<List<Map<String, dynamic>>> getCards(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cards/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get cards: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting cards: $e');
    }
  }
}
