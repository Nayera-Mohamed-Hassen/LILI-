import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../user_session.dart';
import 'create_new_categoryInventory_page.dart';
import 'inventory_page.dart';
import 'package:LILI/models/category_manager.dart';
import 'receipt_scan_dialog.dart';
import 'extracted_items_dialog.dart';
import '../services/ocr_service.dart';

class CreateNewItemPage extends StatefulWidget {
  @override
  _CreateNewItemPageState createState() => _CreateNewItemPageState();
}

class _CreateNewItemPageState extends State<CreateNewItemPage> {
  final _titleController = TextEditingController();
  final _quantityController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedCategory;
  String _selectedUnit = "pieces";
  File? _pickedImage;

  final List<String> units = [
    "pieces",
    "kg",
    "grams",
    "liters",
    "ml",
    "packets",
    "bottles",
    "cans",
    "boxes",
  ];

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
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white),
        ),
        filled: true,
        fillColor: Colors.white12,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDropdown(String label) {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white),
        ),
        filled: true,
        fillColor: Colors.white12,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: TextStyle(color: Colors.white60),
      ),
      dropdownColor: Color(0xFF1F3354),
      icon: Icon(Icons.arrow_drop_down, color: Colors.white70, size: 28),
      items:
          CategoryManager().categories
              .map(
                (cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat, style: TextStyle(color: Colors.white)),
                ),
              )
              .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
    );
  }

  Widget _buildUnitDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedUnit,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Unit',
        labelStyle: TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white),
        ),
        filled: true,
        fillColor: Colors.white12,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: TextStyle(color: Colors.white60),
      ),
      dropdownColor: Color(0xFF1F3354),
      icon: Icon(Icons.arrow_drop_down, color: Colors.white70, size: 28),
      items:
          units
              .map(
                (unit) => DropdownMenuItem(
                  value: unit,
                  child: Text(unit, style: TextStyle(color: Colors.white)),
                ),
              )
              .toList(),
      onChanged: (value) {
        setState(() {
          _selectedUnit = value!;
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

    final quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quantity must be greater than 0'),
          backgroundColor: Colors.red.withOpacity(0.8),
        ),
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
      "quantity": quantity,
      "unit": _selectedUnit,
      "amount":
          _amountController.text.isNotEmpty
              ? double.tryParse(_amountController.text) ?? 1.0
              : 1.0,
      "user_id": userId,
    };

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/user/inventory/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newItem),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        String expiryDate = result["expiry_date"];

        String message;
        if (expiryDate.isEmpty) {
          message =
              "Item saved successfully! (No expiry date for non-food items)";
        } else {
          message = "Item saved successfully!\nExpiry Date: $expiryDate";
        }

        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: Text("Item Saved"),
                content: Text(message),
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
                        expiryDate: expiryDate.isEmpty ? null : expiryDate,
                        unit: _selectedUnit,
                        amount: double.tryParse(_amountController.text) ?? 1.0,
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
    final bgColor = backgroundColor ?? Colors.white24;
    final txtColor = textColor ?? Colors.white;

    return SizedBox(
      width: fixedSize.width,
      height: fixedSize.height,
      child: ElevatedButton(
        key: const Key('add_inventory_item_button'),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white24),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: txtColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Function to handle receipt scanning
  void _scanReceipt() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReceiptScanDialog(
        onItemsExtracted: (items) async {
          // Show extracted items dialog
          final selectedItems = await showDialog<List<OCRItem>>(
            context: context,
            builder: (context) => ExtractedItemsDialog(items: items),
          );

          if (selectedItems != null && selectedItems.isNotEmpty) {
            // Process selected items
            await _processSelectedItems(selectedItems);
          }
        },
      ),
    );
  }

  // Function to show confirmation dialog for each item with category selection
  Future<Map<String, dynamic>?> _showItemConfirmationDialogWithCategory(OCRItem item) async {
    String selectedCategory = 'Food';
    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1F3354),
        title: Text(
          'Add Item',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${item.name.isNotEmpty ? item.name : 'Unknown Item'}',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              'Quantity: ${item.quantity}',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              'Price: \$${item.amount.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
            Text(
              'Category:',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8),
            StatefulBuilder(
              builder: (context, setState) {
                return DropdownButton<String>(
                  value: selectedCategory,
                  dropdownColor: Color(0xFF1F3354),
                  style: TextStyle(color: Colors.white),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
                  items: CategoryManager().categories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat, style: TextStyle(color: Colors.white)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCategory = value;
                      });
                    }
                  },
                );
              },
            ),
            SizedBox(height: 16),
            Text(
              'Would you like to add this item to your inventory?',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text('Skip', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            key: const Key('save_inventory_item_button'),
            onPressed: () => Navigator.of(context).pop({
              'add': true,
              'category': selectedCategory,
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white24,
            ),
            child: Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Function to process selected items from OCR
  Future<void> _processSelectedItems(List<OCRItem> selectedItems) async {
    for (OCRItem item in selectedItems) {
      // Pre-fill the form with the first item
      if (item == selectedItems.first) {
        setState(() {
          _titleController.text = item.name.isNotEmpty ? item.name : 'Unknown Item';
          _quantityController.text = item.quantity.toString();
          _amountController.text = item.unitPrice > 0 ? item.unitPrice.toString() : item.amount.toString();
        });
      }

      // Show confirmation dialog for each item with category selection
      final result = await _showItemConfirmationDialogWithCategory(item);
      if (result != null && result['add'] == true) {
        await _addItemFromOCR(item, result['category'] ?? 'Food');
      }
    }
  }

  // Function to add item from OCR to inventory (now takes category)
  Future<void> _addItemFromOCR(OCRItem item, String category) async {
    final String? userId = UserSession().getUserId();
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final newItem = {
      "name": item.name.isNotEmpty ? item.name : 'Unknown Item',
      "category": category,
      "quantity": item.quantity,
      "unit": _selectedUnit,
      "amount": item.unitPrice > 0 ? item.unitPrice : item.amount,
      "user_id": userId,
    };

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/user/inventory/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(newItem),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        String expiryDate = result["expiry_date"];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} added successfully!'),
            backgroundColor: Colors.green.withOpacity(0.8),
          ),
        );
      } else {
        throw Exception("Failed to save item");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding ${item.name}: ${e.toString()}'),
          backgroundColor: Colors.red.withOpacity(0.8),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF1F3354), const Color(0xFF3E5879)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                surfaceTintColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  'Add New Item',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.white),
                    tooltip: 'Add New Category',
                    onPressed: _navigateAndAddCategory,
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Scan receipt button aligned to the right
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                                size: 24,
                                color: Colors.white,
                              ),
                              onPressed: _scanReceipt,
                              tooltip: 'Scan Receipt',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      // Image at the top
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),

                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/inventory/Receipt.png',
                            height: 300,
                            width: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Image Picker in a Row with text
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white24,
                                backgroundImage:
                                    _pickedImage != null
                                        ? FileImage(_pickedImage!)
                                        : null,
                                child:
                                    _pickedImage == null
                                        ? Icon(
                                          Icons.add_a_photo,
                                          color: Colors.white,
                                          size: 30,
                                        )
                                        : null,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Add Item Image',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildTextField(_titleController, 'Item Name', isNumber: false),
                      SizedBox(height: 16),
                      _buildDropdown('Choose Category'),
                      SizedBox(height: 16),
                      _buildUnitDropdown(),
                      SizedBox(height: 16),
                      _buildTextField(
                        _quantityController,
                        'Quantity (Number of items)',
                        isNumber: true,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        _amountController,
                        'Amount per item (e.g., 5 for 5kg bag, 1 for 1L bottle)',
                        isNumber: true,
                      ),
                      SizedBox(height: 32),

                      // Buttons in a Column
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildButton(
                            'Save Item',
                            onPressed: _saveItem,
                            size: const Size(260, 50),
                            backgroundColor: Colors.white24,
                          ),
                          SizedBox(height: 12),
                          _buildButton(
                            'Discard',
                            onPressed: _discardItem,
                            size: const Size(260, 50),
                            backgroundColor: Colors.transparent,
                            textColor: Colors.white70,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
