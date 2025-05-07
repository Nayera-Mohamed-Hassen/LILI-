import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateNewItemPage extends StatefulWidget {
  @override
  _CreateNewItemPageState createState() => _CreateNewItemPageState();
}

class _CreateNewItemPageState extends State<CreateNewItemPage> {
  final _titleController = TextEditingController();
  final _quantityController = TextEditingController();
  String? _selectedCategory;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D2345),
        title: const Text(
          'Add New Item To Inventory',
          style: TextStyle(color: Color(0xFFF5EFE7)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFF5EFE7)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(_titleController, 'Item Name'),
            const SizedBox(height: 16),
            _buildDropdown('Choose category'),
            const SizedBox(height: 16),
            _buildTextField(_quantityController, 'Quantity', isNumber: true),
            const SizedBox(height: 16),
            _buildDatePickerField(context),
            const SizedBox(height: 200),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: Icon(Icons.camera_alt, size: 30, color: Color(0xFF1D2345)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Scanning'),
                      content: Text('Scanning the receipt...'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                  'Save',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Success'),
                        content: Text('Item Added successfully!'),
                        actions: [
                          TextButton(
                            onPressed: () {
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
        bool isNumber = false,
      }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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
      items: [
        'All',
        'Food',
        'Cleaning Supplies',
        'Toiletries & Personal Care',
        'Medications & First Aid',
      ].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
    );
  }

  Widget _buildDatePickerField(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
          });
        }
      },
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            labelText: 'Expiry Date',
            hintText: _selectedDate != null
                ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                : 'Select date',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, {required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1D2345),
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
