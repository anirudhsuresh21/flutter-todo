import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/tasks/domain/task_entity.dart';
import '../features/tasks/presentation/bloc/task_bloc.dart';
import '../features/tasks/presentation/bloc/task_state.dart';
import '../features/tasks/presentation/bloc/task_event.dart';
import '../features/tasks/presentation/task_form_dialog.dart';
import '../screens/settings_screen.dart';
import 'task_card_widget.dart';

class TaskListWidget extends StatefulWidget {
  const TaskListWidget({Key? key}) : super(key: key);

  @override
  State<TaskListWidget> createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  // Filter state
  TaskPriority? _selectedPriority;
  bool? _showCompleted;
  String _sortBy = 'dueDate';
  bool _isFilterExpanded = false;

  void editTaskDialog(BuildContext context, TaskEntity task) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<TaskBloc>(),
        child: TaskFormDialog(
          initialTask: task,
          onSubmit: (updatedTask) {
            context.read<TaskBloc>().add(UpdateTaskRequestEvent(updatedTask));
          },
        ),
      ),
    );
  }

  void toggleComplete(BuildContext context, TaskEntity task) {
    final updated = TaskEntity(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.priority,
      completed: !task.completed,
    );
    context.read<TaskBloc>().add(UpdateTaskRequestEvent(updated));
  }

  List<TaskEntity> filterAndSortTasks(List<TaskEntity> tasks) {
    List<TaskEntity> filteredTasks = tasks;

    // Filter by priority
    if (_selectedPriority != null) {
      filteredTasks = filteredTasks
          .where((task) => task.priority == _selectedPriority)
          .toList();
    }

    // Filter by completion status
    if (_showCompleted != null) {
      filteredTasks = filteredTasks
          .where((task) => task.completed == _showCompleted)
          .toList();
    }

    // Sort tasks
    switch (_sortBy) {
      case 'dueDate':
        filteredTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case 'priority':
        filteredTasks.sort((a, b) {
          final priorityOrder = {
            TaskPriority.high: 0,
            TaskPriority.medium: 1,
            TaskPriority.low: 2,
          };
          return priorityOrder[a.priority]!
              .compareTo(priorityOrder[b.priority]!);
        });
        break;
      case 'title':
        filteredTasks.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return filteredTasks;
  }

  Widget filterBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.tune,
                    size: 20,
                    color: const Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(width: 8),
                // Active filter count indicator
                if (_selectedPriority != null || _showCompleted != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(_selectedPriority != null ? 1 : 0) + (_showCompleted != null ? 1 : 0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const Spacer(),
                // Clear filters button
                if (_selectedPriority != null || _showCompleted != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPriority = null;
                        _showCompleted = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.clear,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                // Expand/Collapse arrow
                AnimatedRotation(
                  turns: _isFilterExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 24,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isFilterExpanded ? null : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isFilterExpanded ? 1.0 : 0.0,
              child: _isFilterExpanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Priority',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                filterChip(
                                  'All',
                                  _selectedPriority == null,
                                  () =>
                                      setState(() => _selectedPriority = null),
                                ),
                                filterChip(
                                  'High',
                                  _selectedPriority == TaskPriority.high,
                                  () => setState(() =>
                                      _selectedPriority = TaskPriority.high),
                                  color: const Color(0xFFEF4444),
                                ),
                                filterChip(
                                  'Medium',
                                  _selectedPriority == TaskPriority.medium,
                                  () => setState(() =>
                                      _selectedPriority = TaskPriority.medium),
                                  color: const Color(0xFFF59E0B),
                                ),
                                filterChip(
                                  'Low',
                                  _selectedPriority == TaskPriority.low,
                                  () => setState(() =>
                                      _selectedPriority = TaskPriority.low),
                                  color: const Color(0xFF3B82F6),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                filterChip(
                                  'All',
                                  _showCompleted == null,
                                  () => setState(() => _showCompleted = null),
                                ),
                                filterChip(
                                  'Pending',
                                  _showCompleted == false,
                                  () => setState(() => _showCompleted = false),
                                  color: const Color(0xFF6366F1),
                                ),
                                filterChip(
                                  'Completed',
                                  _showCompleted == true,
                                  () => setState(() => _showCompleted = true),
                                  color: const Color(0xFF10B981),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget filterChip(String label, bool isSelected, VoidCallback onTap,
      {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? const Color(0xFF6366F1))
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? (color ?? const Color(0xFF6366F1))
                : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (color ?? const Color(0xFF6366F1)).withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return SafeArea(
      child: Column(
        children: [
          // Header Section
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF8B5FBF),
                  Color(0xFF6366F1),
                  Color(0xFF4F46E5),
                ],
                stops: [0.0, 0.6, 1.0],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Today, ${_formatDate(DateTime.now())}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'My Tasks',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Stay organized and productive',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.logout_rounded,
                              color: Colors.white, size: 24),
                          onPressed: () {
                            context.read<AuthBloc>().add(SignOutRequested());
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          filterBar(),

          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                    ),
                  );
                } else if (state is TaskLoaded) {
                  final filteredTasks = filterAndSortTasks(state.tasks);

                  if (filteredTasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedPriority != null || _showCompleted != null
                                ? Icons.filter_list_off
                                : Icons.task_alt,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedPriority != null || _showCompleted != null
                                ? 'No tasks match your filters'
                                : 'No tasks yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedPriority != null || _showCompleted != null
                                ? 'Try adjusting your filters'
                                : 'Add a task to get started!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final todayTasks = filteredTasks.where((task) {
                    final taskDate = DateTime(task.dueDate.year,
                        task.dueDate.month, task.dueDate.day);
                    return taskDate.isAtSameMomentAs(today);
                  }).toList();

                  final tomorrowTasks = filteredTasks.where((task) {
                    final taskDate = DateTime(task.dueDate.year,
                        task.dueDate.month, task.dueDate.day);
                    return taskDate.isAtSameMomentAs(tomorrow);
                  }).toList();

                  final thisWeekTasks = filteredTasks.where((task) {
                    final taskDate = DateTime(task.dueDate.year,
                        task.dueDate.month, task.dueDate.day);
                    final weekFromNow = today.add(const Duration(days: 7));
                    return taskDate.isAfter(tomorrow) &&
                        taskDate.isBefore(weekFromNow);
                  }).toList();

                  final overdueTasks = filteredTasks.where((task) {
                    final taskDate = DateTime(task.dueDate.year,
                        task.dueDate.month, task.dueDate.day);
                    return taskDate.isBefore(today) && !task.completed;
                  }).toList();

                  final futureTasks = filteredTasks.where((task) {
                    final taskDate = DateTime(task.dueDate.year,
                        task.dueDate.month, task.dueDate.day);
                    final weekFromNow = today.add(const Duration(days: 7));
                    return taskDate.isAfter(weekFromNow);
                  }).toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF6366F1).withOpacity(0.1),
                                const Color(0xFF8B5FBF).withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6366F1)
                                          .withOpacity(0.3),
                                      spreadRadius: 0,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.analytics_rounded,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${filteredTasks.length} task${filteredTasks.length != 1 ? 's' : ''} shown',
                                      style: const TextStyle(
                                        color: Color(0xFF1E293B),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getStatsText(state.tasks, filteredTasks),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (overdueTasks.isNotEmpty) ...[
                          _buildSectionHeader(
                              'Overdue', Colors.red, Icons.warning_rounded),
                          const SizedBox(height: 8),
                          ...overdueTasks.map((task) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: TaskCardWidget(
                                  task: task,
                                  onToggleComplete: () =>
                                      toggleComplete(context, task),
                                  onEdit: () => editTaskDialog(context, task),
                                  onDelete: () => context
                                      .read<TaskBloc>()
                                      .add(DeleteTaskRequestEvent(task.id)),
                                ),
                              )),
                          const SizedBox(height: 24),
                        ],
                        if (todayTasks.isNotEmpty) ...[
                          _buildSectionHeader('Today', const Color(0xFF6366F1),
                              Icons.today_rounded),
                          const SizedBox(height: 8),
                          ...todayTasks.map((task) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: TaskCardWidget(
                                  task: task,
                                  onToggleComplete: () =>
                                      toggleComplete(context, task),
                                  onEdit: () => editTaskDialog(context, task),
                                  onDelete: () => context
                                      .read<TaskBloc>()
                                      .add(DeleteTaskRequestEvent(task.id)),
                                ),
                              )),
                          const SizedBox(height: 24),
                        ],
                        if (tomorrowTasks.isNotEmpty) ...[
                          _buildSectionHeader('Tomorrow',
                              const Color(0xFF10B981), Icons.schedule_rounded),
                          const SizedBox(height: 8),
                          ...tomorrowTasks.map((task) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: TaskCardWidget(
                                  task: task,
                                  onToggleComplete: () =>
                                      toggleComplete(context, task),
                                  onEdit: () => editTaskDialog(context, task),
                                  onDelete: () => context
                                      .read<TaskBloc>()
                                      .add(DeleteTaskRequestEvent(task.id)),
                                ),
                              )),
                          const SizedBox(height: 24),
                        ],
                        if (thisWeekTasks.isNotEmpty) ...[
                          _buildSectionHeader(
                              'This week',
                              const Color(0xFFF59E0B),
                              Icons.date_range_rounded),
                          const SizedBox(height: 8),
                          ...thisWeekTasks.map((task) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: TaskCardWidget(
                                  task: task,
                                  onToggleComplete: () =>
                                      toggleComplete(context, task),
                                  onEdit: () => editTaskDialog(context, task),
                                  onDelete: () => context
                                      .read<TaskBloc>()
                                      .add(DeleteTaskRequestEvent(task.id)),
                                ),
                              )),
                          const SizedBox(height: 24),
                        ],
                        if (futureTasks.isNotEmpty) ...[
                          _buildSectionHeader('Later', Colors.grey,
                              Icons.schedule_send_rounded),
                          const SizedBox(height: 8),
                          ...futureTasks.map((task) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: TaskCardWidget(
                                  task: task,
                                  onToggleComplete: () =>
                                      toggleComplete(context, task),
                                  onEdit: () => editTaskDialog(context, task),
                                  onDelete: () => context
                                      .read<TaskBloc>()
                                      .add(DeleteTaskRequestEvent(task.id)),
                                ),
                              )),
                        ],
                      ],
                    ),
                  );
                } else if (state is TaskError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Error: ${state.message}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, [Color? color, IconData? icon]) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: (color ?? const Color(0xFF374151)).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (color ?? const Color(0xFF374151)).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color ?? const Color(0xFF374151),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color ?? const Color(0xFF374151),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (color ?? const Color(0xFF374151)).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: color ?? const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _getStatsText(
      List<TaskEntity> allTasks, List<TaskEntity> filteredTasks) {
    final totalCompleted = allTasks.where((task) => task.completed).length;
    final totalPending = allTasks.length - totalCompleted;
    final filteredCompleted =
        filteredTasks.where((task) => task.completed).length;
    final filteredPending = filteredTasks.length - filteredCompleted;

    if (_selectedPriority != null || _showCompleted != null) {
      return 'Completed: $filteredCompleted • Pending: $filteredPending';
    } else {
      final completionRate = allTasks.isNotEmpty
          ? ((totalCompleted / allTasks.length) * 100).round()
          : 0;
      return '$totalCompleted completed • $totalPending pending • $completionRate% done';
    }
  }
}
