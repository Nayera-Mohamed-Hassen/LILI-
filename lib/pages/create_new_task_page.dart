import 'package:flutter/material.dart';
import 'package:LILI/models/task.dart';
import 'package:LILI/models/category_task.dart';
import 'package:LILI/user_session.dart';
import 'package:provider/provider.dart';
import 'package:LILI/services/task_service.dart';

class CreateNewTaskPage extends StatefulWidget {
  final List<CategoryModel> categories;
  final TaskModel? taskToEdit;

  const CreateNewTaskPage({Key? key, required this.categories, this.taskToEdit})
    : super(key: key);

  @override
  _CreateNewTaskPageState createState() => _CreateNewTaskPageState();
}

class _CreateNewTaskPageState extends State<CreateNewTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _assignedToController;
  late DateTime _selectedDate;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.taskToEdit?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.taskToEdit?.description ?? '',
    );
    _assignedToController = TextEditingController(
      text: widget.taskToEdit?.assignedTo ?? '',
    );
    _selectedDate = widget.taskToEdit?.dueDate ?? DateTime.now();
    _selectedCategory =
        widget.taskToEdit?.category ?? widget.categories[0].name;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.taskToEdit == null ? 'Create New Task' : 'Edit Task',
          style: TextStyle(color: Colors.white70),
        ),
        backgroundColor: Color(0xFF1F3354),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF1F3354), const Color(0xFF3E5879)],
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Title',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _assignedToController,
                label: 'Assigned To',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an assignee';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildDatePicker(),
              SizedBox(height: 16),
              _buildCategoryDropdown(),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final taskService = Provider.of<TaskService>(
                      context,
                      listen: false,
                    );
                    final taskData = {
                      'title': _titleController.text,
                      'description': _descriptionController.text,
                      'due_date': _selectedDate.toIso8601String(),
                      'assigned_to': _assignedToController.text,
                      'category': _selectedCategory,
                      'user_id': UserSession().getUserId(),
                      'is_completed': widget.taskToEdit?.isCompleted ?? false,
                    };

                    TaskModel? result;
                    if (widget.taskToEdit != null) {
                      // Update existing task
                      taskData['task_id'] = widget.taskToEdit!.id;
                      result = await taskService.createTask(taskData);
                    } else {
                      // Create new task
                      result = await taskService.createTask(taskData);
                    }

                    if (result != null) {
                      Navigator.pop(context, result);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to save task'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF1F3354),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.taskToEdit == null ? 'Create Task' : 'Update Task',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.white70),
            SizedBox(width: 8),
            Text(
              'Due Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          dropdownColor: Color(0xFF1F3354),
          style: TextStyle(color: Colors.white),
          icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
          items:
              widget.categories.map((category) {
                return DropdownMenuItem(
                  value: category.name,
                  child: Text(category.name),
                );
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCategory = value;
              });
            }
          },
        ),
      ),
    );
  }
}
