import 'package:LILI/models/category_task.dart';

class TaskModel {
  final int id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final String assignedTo;
  final String category; // Category name

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    required this.assignedTo,
    required this.category,
  });

  TaskModel copyWith({bool? isCompleted, double? progress}) {
    return TaskModel(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      assignedTo: assignedTo,
      category: category,
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
  };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    dueDate: DateTime.parse(json['dueDate']),
    isCompleted: json['isCompleted'],
    assignedTo: json['assignedTo'],
    category: json['category'],
  );
}
