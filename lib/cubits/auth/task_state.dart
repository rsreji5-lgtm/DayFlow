part of 'task_cubit.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TaskData extends TaskState {
  final List<Task> tasks;
  final List<Task> allTasks;

  const TaskData(
    this.tasks,
    this.allTasks,
  );

  @override
  List<Object?> get props => [
        tasks,
        allTasks,
      ];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(
    this.message,
  );

  @override
  List<Object?> get props => [
        message,
      ];
}