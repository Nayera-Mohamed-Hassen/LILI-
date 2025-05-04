import 'package:flutter/material.dart';

class CreateNewTaskPage extends StatefulWidget {
  @override
  _CreateNewTaskPageState createState() => _CreateNewTaskPageState();
}

class _CreateNewTaskPageState extends State<CreateNewTaskPage> {
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
        backgroundColor: const Color(0xFF3E5879),
        title: const Text(
          'Add New Task',
          style: TextStyle(color: Color(0xFFF5EFE7)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFF5EFE7)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(_titleController, 'Title'),
            const SizedBox(height: 16),
            _buildTextField(_descriptionController, 'Description', maxLines: 3),
            const SizedBox(height: 16),
            _buildDropdown('Choose assignee'),
            const SizedBox(height: 16),
            _buildDropdown('Choose category'),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 16),
            _buildTimePicker(),
            const SizedBox(height: 16),
            Row(
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 9),
                Text(
                  'Private Task',
                  style: TextStyle(
                    color: Color(0xFF3E5879),
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 157),
                Switch(
                  value: isPrivate,
                  activeColor: Color(0xFF3E5879),
                  onChanged: (value) {
                    setState(() {
                      isPrivate = value;
                    });
                  },
                ),
              ],
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
                      builder:
                          (ctx) => AlertDialog(
                            title: Text('Success'),
                            content: Text('Task saved successfully!'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // Navigator.of(ctx).pop(); // Close dialog
                                  Navigator.pushNamed(context, '/task home');
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

  Widget _buildDatePicker() {
    return TextField(
      readOnly: true,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      },
      decoration: InputDecoration(
        labelText:
            _selectedDate == null
                ? 'Select deadline'
                : 'Deadline: ${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: Icon(Icons.calendar_today),
      ),
    );
  }

  Widget _buildTimePicker() {
    return TextField(
      readOnly: true,
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null) {
          setState(() => _selectedTime = picked);
        }
      },
      decoration: InputDecoration(
        labelText:
            _selectedTime == null
                ? 'Select time'
                : 'Time: ${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: Icon(Icons.access_time),
      ),
    );
  }

  Widget _buildButton(String text, {required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3E5879),
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
