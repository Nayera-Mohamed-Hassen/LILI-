import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateNewTaskPage extends StatefulWidget {
  @override
  _CreateNewTaskPageState createState() => _CreateNewTaskPageState();
}

class _CreateNewTaskPageState extends State<CreateNewTaskPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedAssignee;
  String? _selectedCategory;

  final List<String> _assignees = ['Nayera', 'Ali', 'Sara'];
  final List<String> _categories = ['Design', 'Chores', 'Shopping'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1F3354),
              const Color(0xFF3E5879),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(
                        _titleController,
                        'Task Title',
                        'Enter task title',
                        Icons.title,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        _descriptionController,
                        'Description',
                        'Enter task description',
                        Icons.description_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      _buildDropdown(
                        'Assignee',
                        _selectedAssignee,
                        _assignees,
                        Icons.person_outline,
                        (value) => setState(() => _selectedAssignee = value),
                      ),
                      const SizedBox(height: 20),
                      _buildDropdown(
                        'Category',
                        _selectedCategory,
                        _categories,
                        Icons.category_outlined,
                        (value) => setState(() => _selectedCategory = value),
                      ),
                      const SizedBox(height: 20),
                      _buildDatePicker(),
                      const SizedBox(height: 20),
                      _buildTimePicker(),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(child: _buildCancelButton()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildSaveButton()),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Create New Task',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(icon, color: Colors.white70),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    IconData icon,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        dropdownColor: const Color(0xFF1F3354),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(icon, color: Colors.white70),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark(
                  primary: Colors.white,
                  onPrimary: Color(0xFF1F3354),
                  surface: Color(0xFF1F3354),
                  onSurface: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: const Icon(
                Icons.calendar_today_outlined,
                color: Colors.white70,
              ),
            ),
            Expanded(
              child: Text(
                _selectedDate == null
                    ? 'Select Due Date'
                    : DateFormat('MMMM d, y').format(_selectedDate!),
                style: TextStyle(
                  color: _selectedDate == null ? Colors.white38 : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _selectedTime ?? TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark(
                  primary: Colors.white,
                  onPrimary: Color(0xFF1F3354),
                  surface: Color(0xFF1F3354),
                  onSurface: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => _selectedTime = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: const Icon(
                Icons.access_time_outlined,
                color: Colors.white70,
              ),
            ),
            Expanded(
              child: Text(
                _selectedTime == null
                    ? 'Select Time'
                    : _selectedTime!.format(context),
                style: TextStyle(
                  color: _selectedTime == null ? Colors.white38 : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _validateAndSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1F3354),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: const Text(
        'Save Task',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white24),
        ),
      ),
      child: const Text(
        'Cancel',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _validateAndSave() {
    if (_titleController.text.isEmpty) {
      _showError('Please enter a task title');
      return;
    }

    if (_descriptionController.text.isEmpty) {
      _showError('Please enter a task description');
      return;
    }

    if (_selectedAssignee == null) {
      _showError('Please select an assignee');
      return;
    }

    if (_selectedCategory == null) {
      _showError('Please select a category');
      return;
    }

    if (_selectedDate == null) {
      _showError('Please select a due date');
      return;
    }

    if (_selectedTime == null) {
      _showError('Please select a time');
      return;
    }

    // Here you would typically save the task
    Navigator.pushNamed(context, '/task home');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
