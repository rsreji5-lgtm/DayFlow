import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/tasks.dart';
import '../../repositories/task_repository.dart';
import '../../services/notification_service.dart';
import '../../utils/reminder_utils.dart';

part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository repository;

  StreamSubscription<List<Task>>?
      _subscription;
  StreamSubscription<User?>?
      _authSubscription;

  List<Task> _all = [];

  String _query = '';

  String _priority = 'All';

  String _completion = 'All';

  String get priority => _priority;

  String get completion => _completion;

  TaskCubit(
    this.repository,
  ) : super(const TaskInitial());

  void listenToAuthChanges() {
    _authSubscription?.cancel();

    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen(
      (user) {
        if (user == null) {
          _subscription?.cancel();
          _all = [];
          emit(const TaskInitial());
          return;
        }

        loadTasks(user.uid);
      },
    );

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      loadTasks(currentUser.uid);
    }
  }

  void loadTasks([String? userId]) {
    final effectiveUserId = userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (effectiveUserId == null) {
      return;
    }

    if (_subscription != null && _all.isNotEmpty && userId == null) {
      _emitFiltered();
      return;
    }

    if (_all.isEmpty) {
      emit(const TaskLoading());
    }

    _subscription?.cancel();

    _subscription =
        repository.watchTasks(effectiveUserId).listen(
      (tasks) {
        _all = List<Task>.from(tasks);
        _syncNotifications(_all);
        _emitFiltered();
      },
      onError: (_) {
        emit(
          const TaskError(
            'Unable to Load Tasks',
          ),
        );
      },
    );
  }

  void _syncNotifications(List<Task> tasks) {
    for (final task in tasks) {
      for (int i = 0; i < task.reminders.length; i++) {
        final notificationId = getNotificationId(task.id, i);
        if (task.isCompleted) {
          NotificationService.instance.cancelTaskReminder(notificationId);
        } else {
          final reminderTime = calculateReminderTime(task.reminders[i], task.dueDate);
          if (reminderTime != null && reminderTime.isAfter(DateTime.now())) {
            NotificationService.instance.scheduleTaskReminder(
              notificationId: notificationId,
              taskTitle: task.title,
              reminderTime: reminderTime,
            );
          }
        }
      }
    }
  }

  void _emitFiltered() {
    final q = _query.toLowerCase().trim();

    final filtered = _all.where(
      (task) {
        final searchOk =
            q.isEmpty ||
            task.title.toLowerCase().contains(q) ||
            task.description.toLowerCase().contains(q);

        final priorityOk =
            _priority == 'All' || task.priority == _priority.toLowerCase();

        final completionOk =
            _completion == 'All' ||
            (_completion == 'Completed' && task.isCompleted) ||
            (_completion == 'Pending' && !task.isCompleted);

        return searchOk && priorityOk && completionOk;
      },
    ).toList();

    emit(
      TaskData(
        List<Task>.from(filtered),
        List<Task>.from(_all),
      ),
    );
  }

  void searchTasks(String value) {
    _query = value;

    _emitFiltered();
  }

  void resetFilters() {
    _query = '';
    _priority = 'All';
    _completion = 'All';

    _emitFiltered();
  }

  void applyDefaultFilters() {
    _query = '';
    _priority = 'All';
    _completion = 'All';

    _emitFiltered();
  }

  void filterPriority(String value) {
    _priority = value;

    _emitFiltered();
  }

  void filterCompletion(String value) {
    _completion = value;

    _emitFiltered();
  }

  Future<void> addTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required String priority,
    required List<String> reminders,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User is not logged in.');
      }

      await repository.addTask(
        userId: user.uid,
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
        reminders: reminders,
      );
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> updateTask(
    Task task,
  ) {
    for (int i = 0; i < task.reminders.length; i++) {
      final notificationId = getNotificationId(task.id, i);
      final reminderTime = calculateReminderTime(task.reminders[i], task.dueDate);
      if (reminderTime != null && reminderTime.isAfter(DateTime.now())) {
        NotificationService.instance.scheduleTaskReminder(
          notificationId: notificationId,
          taskTitle: task.title,
          reminderTime: reminderTime,
        );
      }
    }
    return repository.updateTask(
      task,
    );
  }

  Future<void> deleteTask(
    String id,
  ) async {
    for (int i = 0; i < 10; i++) {
      NotificationService.instance.cancelTaskReminder(getNotificationId(id, i));
    }

    final index = _all.indexWhere((t) => t.id == id);
    Task? removedTask;
    if (index != -1) {
      removedTask = _all.removeAt(index);
      _emitFiltered();
    }

    try {
      await repository.deleteTask(id);
    } catch (e) {
      if (removedTask != null && index != -1) {
        _all.insert(index, removedTask);
        _emitFiltered();
      }
      rethrow;
    }
  }

  Future<void> toggleComplete(
    Task task,
  ) async {
    final index = _all.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      final updatedTask = _all[index].copyWith(
        isCompleted: !_all[index].isCompleted,
        updatedAt: DateTime.now(),
      );
      _all[index] = updatedTask;

      for (int i = 0; i < updatedTask.reminders.length; i++) {
        final nid = getNotificationId(updatedTask.id, i);
        if (updatedTask.isCompleted) {
          NotificationService.instance.cancelTaskReminder(nid);
        } else {
          final reminderTime = calculateReminderTime(updatedTask.reminders[i], updatedTask.dueDate);
          if (reminderTime != null && reminderTime.isAfter(DateTime.now())) {
            NotificationService.instance.scheduleTaskReminder(
              notificationId: nid,
              taskTitle: updatedTask.title,
              reminderTime: reminderTime,
            );
          }
        }
      }

      _emitFiltered();
    }

    try {
      await repository.toggleComplete(task);
    } catch (e) {
      if (index != -1) {
        _all[index] = task;
        _emitFiltered();
      }
      rethrow;
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _authSubscription?.cancel();

    return super.close();
  } 
}