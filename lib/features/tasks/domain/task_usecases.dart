import 'task_entity.dart';
import 'task_repository.dart';

class GetTasks {
  final TaskRepository repository;

  GetTasks(this.repository);

  Future<List<TaskEntity>> call({TaskPriority? priority, bool? completed}) {
    return repository.getTasks(priority: priority, completed: completed);
  }
}

class AddTask {
  final TaskRepository repository;

  AddTask(this.repository);

  Future<void> call(TaskEntity task) {
    return repository.addTask(task);
  }
}

class UpdateTask {
  final TaskRepository repository;

  UpdateTask(this.repository);

  Future<void> call(TaskEntity task) {
    return repository.updateTask(task);
  }
}

class DeleteTask {
  final TaskRepository repository;

  DeleteTask(this.repository);

  Future<void> call(String id) {
    return repository.deleteTask(id);
  }
}
