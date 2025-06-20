import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../user_session.dart';
import 'create_new_categoryInventory_page.dart';
import 'inventory_page.dart';
import 'package:LILI/models/category_manager.dart';

class CreateNewItemPage extends StatefulWidget {
  @override
  _CreateNewItemPageState createState() => _CreateNewItemPageState();
}

class _CreateNewItemPageState extends State<CreateNewItemPage> {
  final _titleController = TextEditingController();
  final _quantityController = TextEditingController();
  String? _selectedCategory;
  File? _pickedImage;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDropdown(String label) {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      items:
          CategoryManager().categories
              .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
              .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
    );
  }

  void _saveItem() async {
    if (_titleController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final String? userId = UserSession().getUserId();
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('User not logged in')));
      return;
    }

    final newItem = {
      "name": _titleController.text,
      "category": _selectedCategory!,
      "quantity":
          _quantityController.text.isNotEmpty
              ? int.tryParse(_quantityController.text) ?? 0
              : 0,
      "user_id": userId,
    };

    print("Sending item: ${jsonEncode(newItem)}");

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/user/inventory/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newItem),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        String expiryDate = result["expiry_date"];

        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: Text("Item Saved"),
                content: Text("Expiry Date: $expiryDate"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      // Create an InventoryItem instance to pass back
                      final newItem = InventoryItem(
                        name: _titleController.text,
                        category: _selectedCategory!,
                        quantity: int.tryParse(_quantityController.text) ?? 0,
                        image: _pickedImage?.path,
                      );
                      Navigator.of(context).pop(newItem);
                    },
                    child: Text("OK"),
                  ),
                ],
              ),
        );
      } else {
        throw Exception("Failed to save item");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  // void _saveItem() {
  //   if (_titleController.text.isEmpty ||
  //       _quantityController.text.isEmpty ||
  //       _selectedCategory == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Please fill in all required fields')),
  //     );
  //     return;
  //   }
  //
  //   final newItem = InventoryItem(
  //     name: _titleController.text,
  //     category: _selectedCategory!,
  //     quantity: int.tryParse(_quantityController.text) ?? 0,
  //     image: _pickedImage?.path,
  //   );
  //
  //   Navigator.pop(context, newItem);
  // }

  void _discardItem() {
    Navigator.pop(context);
  }

  Future<void> _navigateAndAddCategory() async {
    final newCategory = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => AddNewCategoryPage()),
    );

    if (newCategory != null) {
      setState(() {
        _selectedCategory = newCategory;
      });
    }
  }

  Widget _buildButton(
    String text, {
    required VoidCallback onPressed,
    Size? size,
    Color? backgroundColor, // background color parameter
    Color? textColor, // text color parameter
  }) {
    final fixedSize = size ?? const Size(200, 60);
    final bgColor = backgroundColor ?? const Color(0xFF3E5879);
    final txtColor = textColor ?? Colors.white;

    return SizedBox(
      width: fixedSize.width,
      height: fixedSize.height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Text(text, style: TextStyle(color: txtColor, fontSize: 18)),
      ),
    );
  }

  // Function to simulate scanning receipt
  void _scanReceipt() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Scanning receipt...')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F3354),
        title: const Text(
          'Add New Item To Inventory',
          style: TextStyle(color: Color(0xFFF5EFE7)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFF5EFE7)),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Add New Category',
            onPressed: _navigateAndAddCategory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Scan receipt button aligned to the right, below AppBar
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.camera_alt,
                    size: 30,
                    color: const Color(0xFF3E5879),
                  ),
                  onPressed: _scanReceipt,
                  tooltip: 'Scan Receipt',
                ),
              ],
            ),
            SizedBox(height: 10),

            // Image at the top
            Image.asset('assets/inventory/Receipt.png', height: 200),
            SizedBox(height: 20),

            // Image Picker in a Row with text
            Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        _pickedImage != null ? FileImage(_pickedImage!) : null,
                    child:
                        _pickedImage == null
                            ? Icon(Icons.add_a_photo, color: Colors.white)
                            : null,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Add Item Image',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildTextField(_titleController, 'Item Name'),
            SizedBox(height: 16),
            _buildDropdown('Choose Category'),
            SizedBox(height: 16),
            _buildTextField(_quantityController, 'Quantity', isNumber: true),
            SizedBox(height: 32),

            // Buttons in a Column
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                  'Save Item',
                  onPressed: _saveItem,
                  size: const Size(260, 40),
                ),
                SizedBox(height: 10),
                _buildButton(
                  'Discard',
                  onPressed: _discardItem,
                  size: const Size(260, 40),
                  backgroundColor: Color(0xFFF2F2F2),
                  textColor: Color(0xFF3E5879),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
