import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/task_entity.dart';
import '../domain/task_repository.dart';

class FirestoreTaskRepository implements TaskRepository {
  final String userId;
  static FirebaseFirestore? _firestore;

  FirestoreTaskRepository({required this.userId}) {
    // Use singleton pattern to prevent multiple Firestore instances
    _firestore ??= FirebaseFirestore.instance;
  }

  FirebaseFirestore get firestore => _firestore!;

  @override
  Future<List<TaskEntity>> getTasks(
      {TaskPriority? priority, bool? completed}) async {
    // Validate that userId is not empty
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    Query query = firestore.collection('users').doc(userId).collection('tasks');

    if (priority != null) {
      query = query.where('priority', isEqualTo: priority.name);
    }

    if (completed != null) {
      query = query.where('completed', isEqualTo: completed);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => _taskFromDoc(doc)).toList();
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    // Validate that task ID is not empty
    if (task.id.isEmpty) {
      throw ArgumentError('Task ID cannot be empty');
    }

    // Validate that userId is not empty
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    await firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(task.id)
        .set(_taskToMap(task));
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    // Validate that task ID is not empty
    if (task.id.isEmpty) {
      throw ArgumentError('Task ID cannot be empty');
    }

    // Validate that userId is not empty
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    await firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(task.id)
        .update(_taskToMap(task));
  }

  @override
  Future<void> deleteTask(String id) async {
    // Validate that task ID is not empty
    if (id.isEmpty) {
      throw ArgumentError('Task ID cannot be empty');
    }

    // Validate that userId is not empty
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    await firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(id)
        .delete();
  }

  TaskEntity _taskFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskEntity(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == data['priority'],
        orElse: () => TaskPriority.medium,
      ),
      completed: data['completed'] ?? false,
    );
  }

  Map<String, dynamic> _taskToMap(TaskEntity task) {
    return {
      'title': task.title,
      'description': task.description,
      'dueDate': Timestamp.fromDate(task.dueDate),
      'priority': task.priority.name,
      'completed': task.completed,
    };
  }
}
