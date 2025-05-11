import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'create_new_categoryInventory_page.dart';
import 'inventory_page.dart';
import 'package:untitled4/models/category_manager.dart';

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

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
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
      items: CategoryManager()
          .categories
          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
    );
  }

  void _saveItem() {
    if (_titleController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final newItem = InventoryItem(
      name: _titleController.text,
      category: _selectedCategory!,
      quantity: int.tryParse(_quantityController.text) ?? 0,
      image: _pickedImage?.path,
    );

    Navigator.pop(context, newItem);
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

  // Custom button widget
  Widget _buildButton(
      String text, {
        required VoidCallback onPressed,
        Size? size,
      }) {
    final fixedSize = size ?? const Size(200, 60);

    return SizedBox(
      width: fixedSize.width,
      height: fixedSize.height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const  Color(0xFF1F3354),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  // Function to simulate scanning receipt
  void _scanReceipt() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Scanning receipt...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F3354),
        title: const Text('Add New Item To Inventory',
            style: TextStyle(color: Color(0xFFF5EFE7))),
        iconTheme: const IconThemeData(color: Color(0xFFF5EFE7)),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Add New Category',
            onPressed: _navigateAndAddCategory,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height:40),
            // Image at the top
            Image.asset('assets/inventory/Receipt.png', height: 200, ),
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
                    child: _pickedImage == null
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

            // Camera button to scan receipt
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.camera_alt, size: 40, color: Color(0xFF3E5879)),
                  onPressed: _scanReceipt,
                ),
                SizedBox(width: 10),
                Text(
                  'Scan Receipt',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 32),

            // Buttons in a Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                  'Save Item',
                  onPressed: _saveItem,
                  size: const Size(150, 60),
                ),
                _buildButton(
                  'Discard',
                  onPressed: _discardItem,
                  size: const Size(150, 60),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
