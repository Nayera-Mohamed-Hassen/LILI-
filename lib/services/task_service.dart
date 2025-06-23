import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:LILI/models/task.dart';
import 'package:LILI/user_session.dart';

class TaskService extends ChangeNotifier {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTasks() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userId = UserSession().getUserId();
      if (userId == null || userId.isEmpty) {
        _error = 'User ID is missing. Please log in again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/user/tasks/' + userId),
      );

      if (response.statusCode == 200) {
        final List<dynamic> tasksJson = jsonDecode(response.body);
        _tasks = tasksJson.map((json) => TaskModel(
          id: json['_id'],
          title: json['title'],
          description: json['description'],
          dueDate: DateTime.parse(json['due_date']),
          assignedTo: json['assigned_to'],
          category: json['category'],
          isCompleted: json['is_completed'],
          assignerId: json['assignerId'] ?? json['user_id'] ?? '',
          assigneeId: json['assigneeId'] ?? json['assigned_to_id'] ?? '',
        )).toList();
        _error = null;
      } else {
        _error = 'Failed to load tasks: ${response.body}';
      }
    } catch (e) {
      _error = 'Error loading tasks: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTaskStatus(TaskModel task, bool isCompleted) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/user/tasks/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'task_id': task.id,
          'is_completed': isCompleted,
        }),
      );

      if (response.statusCode == 200) {
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = _tasks[index].copyWith(isCompleted: isCompleted);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTask(TaskModel task) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8000/user/tasks/${task.id}'),
      );

      if (response.statusCode == 200) {
        _tasks.removeWhere((t) => t.id == task.id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<TaskModel?> createTask(Map<String, dynamic> taskData) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/user/tasks/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(taskData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final newTask = TaskModel(
          id: responseData['task_id'],
          title: taskData['title'],
          description: taskData['description'],
          dueDate: DateTime.parse(taskData['due_date']),
          assignedTo: taskData['assigned_to'],
          category: taskData['category'],
          isCompleted: taskData['is_completed'] ?? false,
          assignerId: taskData['assignerId'] ?? '',
          assigneeId: taskData['assigneeId'] ?? '',
        );
        _tasks.add(newTask);
        notifyListeners();
        return newTask;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  List<TaskModel> getFilteredTasks({String filter = 'All', String searchQuery = ''}) {
    List<TaskModel> filtered = _tasks;

    switch (filter) {
      case 'Done':
        filtered = filtered.where((t) => t.isCompleted).toList();
        break;
      case 'In progress':
        filtered = filtered.where((t) => !t.isCompleted).toList();
        break;
      case 'Scheduled':
        filtered = filtered.where((t) => t.dueDate.isAfter(DateTime.now())).toList();
        break;
      case 'All':
      default:
        break;
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((t) =>
        t.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
        t.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
        t.assignedTo.toLowerCase().contains(searchQuery.toLowerCase()) ||
        t.category.toLowerCase().contains(searchQuery.toLowerCase()),
      ).toList();
    }

    return filtered;
  }

  double getCompletionRate() {
    if (_tasks.isEmpty) return 0.0;
    return _tasks.where((t) => t.isCompleted).length / _tasks.length;
  }

  int getPendingTasksCount() {
    return _tasks.where((t) => !t.isCompleted).length;
  }

  Future<bool> updateTask(Map<String, dynamic> taskData) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/user/tasks/update-full'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(taskData),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
} 