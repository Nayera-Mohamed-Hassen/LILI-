import 'package:LILI/models/category_task.dart';

class TaskModel {
  final String id; // Using String for MongoDB ObjectId
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final String assignedTo;
  final String category; // Category name
  final String assignerId;
  final String assigneeId;
  final String priority;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.assignedTo,
    required this.category,
    required this.assignerId,
    required this.assigneeId,
    required this.priority,
  });

  TaskModel copyWith({bool? isCompleted, String? priority}) {
    return TaskModel(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      assignedTo: assignedTo,
      category: category,
      assignerId: assignerId,
      assigneeId: assigneeId,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
    'isCompleted': isCompleted,
    'assignedTo': assignedTo,
    'category': category,
    'assignerId': assignerId,
    'assigneeId': assigneeId,
    'priority': priority,
  };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    dueDate: DateTime.parse(json['dueDate']),
    isCompleted: json['isCompleted'],
    assignedTo: json['assignedTo'],
    category: json['category'],
    assignerId: json['assignerId'],
    assigneeId: json['assigneeId'],
    priority: json['priority'] ?? 'Medium',
  );
}
