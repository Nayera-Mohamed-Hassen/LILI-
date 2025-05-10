import 'package:flutter/material.dart';

class CreateNewCategoryInventoryPage extends StatefulWidget {
  @override
  _CreateNewCategoryInventoryPageState createState() =>
      _CreateNewCategoryInventoryPageState();
}

// const Color(0xFF213555)
class _CreateNewCategoryInventoryPageState
    extends State<CreateNewCategoryInventoryPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool isPrivate = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE7),
      appBar: AppBar(
        backgroundColor: Color(0xFF1F3354),
        title: const Text(
          'Add New Inventory Category ',
          style: TextStyle(color: Color(0xFFF5EFE7)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFF5EFE7)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/inventory/category.png',
              height: 150, // Adjust size as needed
              width: 150, // Adjust size as needed
            ),
            SizedBox(height: 20,),
            _buildTextField(_titleController, 'Category Name '),
            const SizedBox(height: 16),
            _buildTextField(_descriptionController, 'Description', maxLines: 3),
            const SizedBox(height: 350),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                  'Save',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                        title: Text('Success'),
                        content: Text('Category saved successfully!'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // Navigator.of(ctx).pop(); // Close dialog
                              Navigator.pushNamed(context, '/inventory');
                            },
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                _buildButton(
                  'Discard',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        int maxLines = 1,
      }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDropdown(String label) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
      items:
      ['Option 1', 'Option 2', 'Option 3']
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) {},
    );
  }

  Widget _buildButton(String text, {required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1F3354),
        minimumSize: const Size(140, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}