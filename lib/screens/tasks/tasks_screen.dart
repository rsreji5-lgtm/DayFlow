import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubits/auth/task_cubit.dart';
import '../../models/tasks.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/task_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final search = TextEditingController();

  @override
  void initState() {
    super.initState();

    context.read<TaskCubit>().applyDefaultFilters();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: 1,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Tasks', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Manage everything you need to get done.'),
                    ],
                  ),
                ),
                FloatingActionButton.small(onPressed: () => context.go('/tasks/add'), child: const Icon(Icons.add)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: search,
              onChanged: context.read<TaskCubit>().searchTasks,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search tasks...'),
            ),
          ),
          _filters(context),
          Expanded(
            child: BlocBuilder<TaskCubit, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading || state is TaskInitial) return const Center(child: CircularProgressIndicator());
                if (state is TaskError) return _error(context, state.message);
                if (state is TaskData) {
                  final tasks = state.tasks;
                  if (tasks.isEmpty) return _empty(context);
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: tasks.length,
                    itemBuilder: (_, i) => TaskCard(
                      task: tasks[i],
                      onToggle: () => context.read<TaskCubit>().toggleComplete(tasks[i]),
                      onEdit: () => context.go('/tasks/edit/${tasks[i].id}'),
                      onDelete: () => _delete(context, tasks[i]),
                    ),
                  );
                }
                return _empty(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filters(BuildContext context) {
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, _) {
        final cubit = context.read<TaskCubit>();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _dropdown(
                  'Priority',
                  ['All', 'Low', 'Medium', 'High'],
                  cubit.filterPriority,
                  cubit.priority,
                ),
                const SizedBox(width: 8),
                _dropdown(
                  'Status',
                  ['All', 'Pending', 'Completed'],
                  cubit.filterCompletion,
                  cubit.completion,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dropdown(
    String label,
    List<String> values,
    ValueChanged<String> onChanged,
    String selectedValue,
  ) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      itemBuilder: (_) => values
          .map(
            (v) => PopupMenuItem(
              value: v,
              child: Text(v),
            ),
          )
          .toList(),
      child: Chip(label: Text('$label: $selectedValue')),
    );
  }

  Widget _empty(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.task_alt, size: 60),
            const SizedBox(height: 14),
            Text('No Tasks Yet', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Start by creating your first task\nand keep your day organized.', textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton.icon(onPressed: () => context.go('/tasks/add'), icon: const Icon(Icons.add), label: const Text('Add Task')),
          ],
        ),
      );

  Widget _error(BuildContext context, String message) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Something went wrong while loading your tasks.'),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => context.read<TaskCubit>().loadTasks(), child: const Text('Retry')),
          ],
        ),
      );

  Future<void> _delete(BuildContext context, Task task) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final taskCubit = context.read<TaskCubit>();

    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task?'),
        content: const Text('Are you sure you want to delete this task?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (yes == true) {
      await taskCubit.deleteTask(task.id);
      if (!mounted) return;
      messenger?.showSnackBar(const SnackBar(content: Text('Task deleted successfully.')));
    }
  }
}
