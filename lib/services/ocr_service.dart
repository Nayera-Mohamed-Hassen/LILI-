import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OCRService {
  static const String baseUrl = 'http://10.0.2.2:8000'; // Update with your backend URL

  /// Scan receipt image and extract text using OCR
  static Future<Map<String, dynamic>> scanReceipt(File imageFile) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/ocr/receipt'),
      );

      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

      // Send the request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('OCR failed: ${response.statusCode} - $responseData');
      }
    } catch (e) {
      throw Exception('Error scanning receipt: $e');
    }
  }

  /// Test OCR service connection
  static Future<bool> testConnection() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ocr/test'),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// Model for OCR extracted item data
class OCRItem {
  final String name;
  final int quantity;
  final double amount;
  final double unitPrice;

  OCRItem({
    required this.name,
    required this.quantity,
    required this.amount,
    required this.unitPrice,
  });

  factory OCRItem.fromJson(Map<String, dynamic> json) {
    return OCRItem(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      amount: (json['amount'] ?? 0.0).toDouble(),
      unitPrice: (json['unit_price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'amount': amount,
      'unit_price': unitPrice,
    };
  }
}

/// Model for OCR receipt data
class OCRReceipt {
  final List<OCRItem> items;
  final double totalAmount;
  final String storeName;
  final String date;
  final String rawText;

  OCRReceipt({
    required this.items,
    required this.totalAmount,
    required this.storeName,
    required this.date,
    required this.rawText,
  });

  factory OCRReceipt.fromJson(Map<String, dynamic> json) {
    List<OCRItem> items = [];
    if (json['items'] != null) {
      items = (json['items'] as List)
          .map((item) => OCRItem.fromJson(item))
          .toList();
    }

    return OCRReceipt(
      items: items,
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      storeName: json['store_name'] ?? '',
      date: json['date'] ?? '',
      rawText: json['raw_text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'store_name': storeName,
      'date': date,
      'raw_text': rawText,
    };
  }
} 