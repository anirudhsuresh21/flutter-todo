import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/tasks/data/hybrid_task_repository.dart';
import '../features/tasks/domain/task_usecases.dart';
import '../features/tasks/presentation/bloc/task_bloc.dart';
import '../features/tasks/presentation/bloc/task_event.dart';
import '../features/tasks/presentation/task_form_dialog.dart';
import '../widgets/task_list_widget.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onSignOut;
  const HomeScreen({Key? key, required this.onSignOut}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TaskBloc? _taskBloc;
  HybridTaskRepository? _taskRepository;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeRepository();
  }

  Future<void> _initializeRepository() async {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) {
        throw StateError('User must be authenticated to access HomeScreen');
      }

      final user = authState.user;
      if (user.id.isEmpty) {
        throw ArgumentError('User ID cannot be empty');
      }

      print('Initializing hybrid task repository for user: ${user.id}');
      _taskRepository = HybridTaskRepository(userId: user.id);
      await _taskRepository!.init();

      _taskBloc = TaskBloc(
        getTasks: GetTasks(_taskRepository!),
        addTask: AddTask(_taskRepository!),
        updateTask: UpdateTask(_taskRepository!),
        deleteTask: DeleteTask(_taskRepository!),
      )..add(LoadTasksEvent());

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing repository: $e');
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _taskBloc?.close();
    _taskRepository?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _taskBloc == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
        ),
      );
    }

    return BlocProvider.value(
      value: _taskBloc!,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: const TaskListWidget(),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () => _showAddTaskDialog(context),
            backgroundColor: const Color(0xFF6366F1),
            child: const Icon(Icons.add, color: Colors.white),
            elevation: 4,
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<TaskBloc>(),
        child: TaskFormDialog(
          onSubmit: (task) {
            context.read<TaskBloc>().add(AddTaskRequestEvent(task));
          },
        ),
      ),
    );
  }
}
