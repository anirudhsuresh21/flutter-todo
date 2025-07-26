import 'task_entity.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> getTasks({TaskPriority? priority, bool? completed});
  Future<void> addTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String id);
}
