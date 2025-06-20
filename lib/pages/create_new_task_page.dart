import 'package:flutter/material.dart';
import 'package:LILI/models/task.dart';
import 'package:LILI/models/category_task.dart';
import 'package:LILI/user_session.dart';
import 'package:provider/provider.dart';
import 'package:LILI/services/task_service.dart';
import 'package:LILI/services/user_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  late DateTime _selectedDate;
  late String _selectedCategory;
  String? _selectedAssignee;
  List<Map<String, dynamic>> _householdUsers = [];
  bool _isLoadingMembers = false;
  final UserService _userService = UserService();
  late TextEditingController _otherAssigneeController;
  bool _showOtherAssignee = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.taskToEdit?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.taskToEdit?.description ?? '',
    );
    _selectedDate = widget.taskToEdit?.dueDate ?? DateTime.now();
    _selectedCategory =
        widget.taskToEdit?.category ?? widget.categories[0].name;
    _otherAssigneeController = TextEditingController();
    _selectedAssignee = widget.taskToEdit?.assignedTo;
    _loadHouseholdUsers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _otherAssigneeController.dispose();
    super.dispose();
  }

  Future<void> _loadHouseholdUsers() async {
    setState(() => _isLoadingMembers = true);
    final userId = UserSession().getUserId();
    if (userId == null || userId.isEmpty) {
      setState(() => _isLoadingMembers = false);
      return;
    }
    try {
      final url = Uri.parse('http://10.0.2.2:8000/user/household-users/$userId');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _householdUsers = List<Map<String, dynamic>>.from(data);
          _isLoadingMembers = false;
        });
      } else {
        setState(() => _isLoadingMembers = false);
      }
    } catch (e) {
      setState(() => _isLoadingMembers = false);
    }
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
              _buildAssigneeDropdown(),
              if (_showOtherAssignee)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: _buildTextField(
                    controller: _otherAssigneeController,
                    label: 'Enter Name',
                    validator: (value) {
                      if (_showOtherAssignee && (value == null || value.isEmpty)) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
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
                    final assignerId = UserSession().getUserId() ?? '';
                    String assigneeId = assignerId;
                    String assignedToDisplay = '';
                    if (_showOtherAssignee) {
                      assignedToDisplay = _otherAssigneeController.text;
                      assigneeId = assignerId; // fallback: assign to self if not in household
                    } else {
                      // Find the selected household user by name
                      final selectedMember = _householdUsers.firstWhere(
                        (member) =>
                          (member['name'] ?? member['username'] ?? member['email'] ?? '') == _selectedAssignee,
                        orElse: () => {},
                      );
                      assignedToDisplay = _selectedAssignee ?? '';
                      if (selectedMember.isNotEmpty && selectedMember['user_id'] != null) {
                        assigneeId = selectedMember['user_id'];
                      }
                    }
                    final taskData = {
                      'title': _titleController.text,
                      'description': _descriptionController.text,
                      'due_date': _selectedDate.toIso8601String(),
                      'assigned_to': assignedToDisplay,
                      'category': _selectedCategory,
                      'user_id': assignerId,
                      'is_completed': widget.taskToEdit?.isCompleted ?? false,
                      'assignerId': assignerId,
                      'assigneeId': assigneeId,
                    };

                    if (widget.taskToEdit != null) {
                      // Update existing task
                      taskData['task_id'] = widget.taskToEdit!.id;
                      final success = await taskService.updateTask(taskData);
                      if (success) {
                        Navigator.pop(context, true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update task'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      // Create new task
                      final result = await taskService.createTask(taskData);
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

  Widget _buildAssigneeDropdown() {
    if (_isLoadingMembers) {
      return Center(child: CircularProgressIndicator());
    }
    final List<DropdownMenuItem<String>> items = [
      ..._householdUsers.map((member) {
        final name = member['name'] ?? member['username'] ?? member['email'] ?? '';
        return DropdownMenuItem<String>(
          value: name,
          child: Text(name),
        );
      }),
      DropdownMenuItem<String>(
        value: '__other__',
        child: Text('Other'),
      ),
    ];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAssignee != null &&
                  items.any((item) => item.value == _selectedAssignee)
              ? _selectedAssignee
              : null,
          hint: Text('Assigned To', style: TextStyle(color: Colors.white70)),
          isExpanded: true,
          dropdownColor: Color(0xFF1F3354),
          style: TextStyle(color: Colors.white),
          icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
          items: items,
          onChanged: (value) {
            setState(() {
              if (value == '__other__') {
                _showOtherAssignee = true;
                _selectedAssignee = null;
              } else {
                _showOtherAssignee = false;
                _selectedAssignee = value;
              }
            });
          },
        ),
      ),
    );
  }
}
