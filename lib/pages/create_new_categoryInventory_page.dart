import 'package:flutter/material.dart';
import 'package:LILI/models/category_manager.dart';

class AddNewCategoryPage extends StatefulWidget {
  @override
  _AddNewCategoryPageState createState() => _AddNewCategoryPageState();
}

class _AddNewCategoryPageState extends State<AddNewCategoryPage> {
  final TextEditingController _categoryController = TextEditingController();

  // Reusable button as in CreateNewItemPage
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
          backgroundColor: const Color(0xFF1F3354),
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

  void _discardCategory() {
    Navigator.pop(context); // Just go back without saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Category',
          style: TextStyle(color: Color(0xFFF5EFE7)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFF5EFE7)),
        backgroundColor: Color(0xFF1F3354),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 40),
            Center(
              child: Image.asset(
                'assets/inventory/category.webp',
                height: 400, // You can change this height if needed
              ),
            ),
            SizedBox(height: 40),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                  'Save',
                  onPressed: () {
                    String newCategory = _categoryController.text.trim();
                    if (newCategory.isNotEmpty) {
                      CategoryManager().addCategory(newCategory);
                      Navigator.pop(context, newCategory);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a category name'),
                        ),
                      );
                    }
                  },
                  size: const Size(150, 60),
                ),
                _buildButton(
                  'Discard',
                  onPressed: _discardCategory,
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
