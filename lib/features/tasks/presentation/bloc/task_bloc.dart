import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/task_usecases.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasks getTasks;
  final AddTask addTask;
  final UpdateTask updateTask;
  final DeleteTask deleteTask;

  TaskBloc({
    required this.getTasks,
    required this.addTask,
    required this.updateTask,
    required this.deleteTask,
  }) : super(TaskInitial()) {
    on<LoadTasksEvent>((event, emit) async {
      emit(TaskLoading());
      try {
        final tasks = await getTasks(
            priority: event.priority, completed: event.completed);
        emit(TaskLoaded(tasks));
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    on<AddTaskRequestEvent>((event, emit) async {
      try {
        await addTask(event.task);
        add(LoadTasksEvent());
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    on<UpdateTaskRequestEvent>((event, emit) async {
      try {
        await updateTask(event.task);
        add(LoadTasksEvent());
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    on<DeleteTaskRequestEvent>((event, emit) async {
      try {
        await deleteTask(event.id);
        add(LoadTasksEvent());
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });
  }
}
