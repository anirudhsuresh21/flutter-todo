import 'package:hive/hive.dart';
import '../domain/task_entity.dart';
import '../domain/task_repository.dart';

class LocalTaskRepository implements TaskRepository {
  static const String _boxName = 'tasks';
  late Box<Map> _taskBox;
  final String userId;

  LocalTaskRepository({required this.userId});

  Future<void> init() async {
    _taskBox = await Hive.openBox<Map>('${_boxName}_$userId');
  }

  @override
  Future<List<TaskEntity>> getTasks(
      {TaskPriority? priority, bool? completed}) async {
    try {
      var tasks = _taskBox.values
          .map((taskMap) =>
              TaskEntity.fromJson(Map<String, dynamic>.from(taskMap)))
          .toList();

      // Apply filters
      if (priority != null) {
        tasks = tasks.where((task) => task.priority == priority).toList();
      }
      if (completed != null) {
        tasks = tasks.where((task) => task.completed == completed).toList();
      }

      // Sort by due date
      tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return tasks;
    } catch (e) {
      print('Error getting local tasks: $e');
      return [];
    }
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    try {
      await _taskBox.put(task.id, task.toJson());
    } catch (e) {
      print('Error adding local task: $e');
      throw Exception('Failed to add task locally');
    }
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    try {
      await _taskBox.put(task.id, task.toJson());
    } catch (e) {
      print('Error updating local task: $e');
      throw Exception('Failed to update task locally');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _taskBox.delete(taskId);
    } catch (e) {
      print('Error deleting local task: $e');
      throw Exception('Failed to delete task locally');
    }
  }

  Future<void> syncWithFirestore(TaskRepository firestoreRepo) async {
    try {
      // Get remote tasks and update local storage
      final remoteTasks = await firestoreRepo.getTasks();

      // Clear local storage and replace with remote data
      await _taskBox.clear();
      for (var task in remoteTasks) {
        await _taskBox.put(task.id, task.toJson());
      }

      print('Sync completed: ${remoteTasks.length} tasks synced');
    } catch (e) {
      print('Error syncing with Firestore: $e');
    }
  }

  Future<void> close() async {
    await _taskBox.close();
  }
}
