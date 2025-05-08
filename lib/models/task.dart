import 'package:untitled4/models/category_task.dart';

class TaskModel {
  final int id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority; // 'Low', 'Medium', 'High'
  final double progress; // 0.0 to 1.0
  final bool isCompleted;
  final bool isRecurring;
  final String assignedTo;
  final String category; // Category name

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.progress = 0.0,
    this.isCompleted = false,
    this.isRecurring = false,
    required this.assignedTo,
    required this.category,
  });

  TaskModel copyWith({bool? isCompleted, double? progress}) {
    return TaskModel(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      isRecurring: isRecurring,
      assignedTo: assignedTo,
      category: category,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
    'priority': priority,
    'progress': progress,
    'isCompleted': isCompleted,
    'isRecurring': isRecurring,
    'assignedTo': assignedTo,
    'category': category,
  };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    dueDate: DateTime.parse(json['dueDate']),
    priority: json['priority'],
    progress: (json['progress'] as num).toDouble(),
    isCompleted: json['isCompleted'],
    isRecurring: json['isRecurring'],
    assignedTo: json['assignedTo'],
    category: json['category'],
  );
}
