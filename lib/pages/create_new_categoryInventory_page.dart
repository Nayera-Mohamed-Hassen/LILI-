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
    final bgColor = backgroundColor ?? Colors.white24;
    final txtColor = textColor ?? Colors.white;

    return SizedBox(
      width: fixedSize.width,
      height: fixedSize.height,
      child: ElevatedButton(
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
          style: TextStyle(color: txtColor, fontSize: 18, fontWeight: FontWeight.w600),
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
                  'Add New Category',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      // Image with styling
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/inventory/category.webp',
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      // TextField with styling
                      TextField(
                        controller: _categoryController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Category Name',
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
                      ),
                      SizedBox(height: 30),
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
                                  SnackBar(
                                    content: Text('Please enter a category name'),
                                    backgroundColor: Colors.red.withOpacity(0.8),
                                  ),
                                );
                              }
                            },
                            size: const Size(260, 50),
                            backgroundColor: Colors.white24,
                          ),
                          SizedBox(height: 12),
                          _buildButton(
                            'Discard',
                            onPressed: _discardCategory,
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
