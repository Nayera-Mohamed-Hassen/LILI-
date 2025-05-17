import 'package:flutter/material.dart';
import 'package:LILI/models/category_manager.dart';

class AddNewCategoryPage extends StatefulWidget {
  @override
  _AddNewCategoryPageState createState() => _AddNewCategoryPageState();
}

class _AddNewCategoryPageState extends State<AddNewCategoryPage> {
  final TextEditingController _categoryController = TextEditingController();


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
        child: Text(
          text,
          style: TextStyle(color: txtColor, fontSize: 18),
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
              Column(
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
                  size: const Size(260, 40),
                ),
                SizedBox(height: 10),
                _buildButton(
                  'Discard',
                  onPressed: _discardCategory,
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
