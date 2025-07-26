import 'dart:io';
import '../domain/task_entity.dart';
import '../domain/task_repository.dart';
import 'firestore_task_repository.dart';
import 'local_task_repository.dart';

class HybridTaskRepository implements TaskRepository {
  final FirestoreTaskRepository _remoteRepo;
  final LocalTaskRepository _localRepo;
  bool _isOnline = true;

  HybridTaskRepository({
    required String userId,
  })  : _remoteRepo = FirestoreTaskRepository(userId: userId),
        _localRepo = LocalTaskRepository(userId: userId);

  Future<void> init() async {
    await _localRepo.init();
    _isOnline = await _checkInternetConnection();
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<TaskEntity>> getTasks(
      {TaskPriority? priority, bool? completed}) async {
    _isOnline = await _checkInternetConnection();

    if (_isOnline) {
      try {
        // Try to get from remote and sync with local
        final remoteTasks = await _remoteRepo.getTasks(
            priority: priority, completed: completed);
        await _syncToLocal(remoteTasks);
        return remoteTasks;
      } catch (e) {
        print('Failed to get remote tasks, falling back to local: $e');
        return await _localRepo.getTasks(
            priority: priority, completed: completed);
      }
    } else {
      // Offline mode - get from local storage
      return await _localRepo.getTasks(
          priority: priority, completed: completed);
    }
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    // Always add to local storage first
    await _localRepo.addTask(task);

    _isOnline = await _checkInternetConnection();
    if (_isOnline) {
      try {
        await _remoteRepo.addTask(task);
      } catch (e) {
        print('Failed to add task to remote, will sync later: $e');
        // Task is already in local storage, will be synced when online
      }
    }
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    // Always update local storage first
    await _localRepo.updateTask(task);

    _isOnline = await _checkInternetConnection();
    if (_isOnline) {
      try {
        await _remoteRepo.updateTask(task);
      } catch (e) {
        print('Failed to update task in remote, will sync later: $e');
      }
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    // Always delete from local storage first
    await _localRepo.deleteTask(id);

    _isOnline = await _checkInternetConnection();
    if (_isOnline) {
      try {
        await _remoteRepo.deleteTask(id);
      } catch (e) {
        print('Failed to delete task from remote, will sync later: $e');
      }
    }
  }

  Future<void> syncWithRemote() async {
    _isOnline = await _checkInternetConnection();
    if (_isOnline) {
      try {
        await _localRepo.syncWithFirestore(_remoteRepo);
      } catch (e) {
        print('Sync failed: $e');
      }
    }
  }

  Future<void> _syncToLocal(List<TaskEntity> remoteTasks) async {
    try {
      // This is a simple sync - replace local with remote
      // In a production app, you'd want more sophisticated sync logic
      for (var task in remoteTasks) {
        await _localRepo.updateTask(task);
      }
    } catch (e) {
      print('Failed to sync to local: $e');
    }
  }

  bool get isOnline => _isOnline;

  Future<void> close() async {
    await _localRepo.close();
  }
}
