import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/ocr_service.dart';

class ReceiptScanDialog extends StatefulWidget {
  final Function(OCRReceipt) onReceiptExtracted;

  const ReceiptScanDialog({
    Key? key,
    required this.onReceiptExtracted,
  }) : super(key: key);

  @override
  _ReceiptScanDialogState createState() => _ReceiptScanDialogState();
}

class _ReceiptScanDialogState extends State<ReceiptScanDialog> {
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF1F3354),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Scan Receipt',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            
            if (_isLoading) ...[
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                _statusMessage,
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOptionButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  _buildOptionButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
            ],
            
            SizedBox(height: 20),
            
            if (!_isLoading)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Selecting image...';
      });

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _statusMessage = 'Processing receipt...';
        });

        final imageFile = File(pickedFile.path);
        
        // Test OCR connection first
        final isConnected = await OCRService.testConnection();
        if (!isConnected) {
          throw Exception('OCR service is not available. Please check your connection.');
        }

        // Scan the receipt
        final ocrResult = await OCRService.scanReceipt(imageFile);
        final receipt = OCRReceipt.fromJson(ocrResult);

        if (receipt.items.isEmpty) {
          throw Exception('No items found in the receipt. Please try with a clearer image.');
        }

        // Close dialog and return the full receipt
        Navigator.of(context).pop();
        widget.onReceiptExtracted(receipt);

      } else {
        setState(() {
          _isLoading = false;
          _statusMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red.withOpacity(0.8),
        ),
      );
    }
  }
} 