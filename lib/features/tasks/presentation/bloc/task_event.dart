import 'package:equatable/equatable.dart';
import '../../domain/task_entity.dart';

abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTasksEvent extends TaskEvent {
  final TaskPriority? priority;
  final bool? completed;
  LoadTasksEvent({this.priority, this.completed});

  @override
  List<Object?> get props => [priority, completed];
}

class AddTaskRequestEvent extends TaskEvent {
  final TaskEntity task;
  AddTaskRequestEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTaskRequestEvent extends TaskEvent {
  final TaskEntity task;
  UpdateTaskRequestEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTaskRequestEvent extends TaskEvent {
  final String id;
  DeleteTaskRequestEvent(this.id);

  @override
  List<Object?> get props => [id];
}
