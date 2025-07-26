import 'package:cloud_firestore/cloud_firestore.dart';

// import '../../domain/task_entity.dart';
import '../domain/task_entity.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final bool completed;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.completed,
  });

  factory TaskModel.fromEntity(TaskEntity entity) => TaskModel(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        dueDate: entity.dueDate,
        priority: entity.priority,
        completed: entity.completed,
      );

  TaskEntity toEntity() => TaskEntity(
        id: id,
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
        completed: completed,
      );

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) => TaskModel(
        id: id,
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        dueDate: (map['dueDate'] as Timestamp).toDate(),
        priority: TaskPriority.values.firstWhere(
          (p) => p.name == (map['priority'] ?? 'medium'),
          orElse: () => TaskPriority.medium,
        ),
        completed: map['completed'] ?? false,
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'dueDate': Timestamp.fromDate(dueDate),
        'priority': priority.name,
        'completed': completed,
      };
}
