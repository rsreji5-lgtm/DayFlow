import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubits/auth/task_cubit.dart';
import '../../models/tasks.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/task_card.dart';

class HomeScreen extends StatefulWidget {
  final String? successMessage;

  const HomeScreen({
    super.key,
    this.successMessage,
  });
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<TaskCubit>().loadTasks();

      if (widget.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.successMessage!,
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: 0,
      child: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          final all = state is TaskData ? state.allTasks : <Task>[];
          final completed = all.where((t) => t.isCompleted).length;
          final pending = all.length - completed;
          final high = all.where((t) => t.priority == 'high' && !t.isCompleted).length;

          final now = DateTime.now();
          final todaysTasks = all.where((t) {
            return t.dueDate.year == now.year &&
                t.dueDate.month == now.month &&
                t.dueDate.day == now.day;
          }).toList();

          return RefreshIndicator(
            onRefresh: () async => context.read<TaskCubit>().loadTasks(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('HELLO CHIEF 👋', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text("Here's your day at a glance."),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.7,
                  children: [
                    _StatCard('Total Tasks', '${all.length}', Icons.list_alt),
                    _StatCard('Completed', '$completed', Icons.check_circle_outline),
                    _StatCard('Pending', '$pending', Icons.pending_actions),
                    _StatCard('High Priority', '$high', Icons.priority_high),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Today's Tasks", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () => context.go('/tasks'), child: const Text('See All')),
                  ],
                ),
                if (state is TaskLoading || state is TaskInitial)
                  const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
                else if (all.isEmpty)
                  const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No saved tasks yet. Add your first task!')))
                else if (todaysTasks.isEmpty)
                  const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No tasks scheduled for today!')))
                else
                  ...todaysTasks.map((task) => TaskCard(
                        task: task,
                        onToggle: () => context.read<TaskCubit>().toggleComplete(task),
                        onEdit: () => context.go('/tasks/edit/${task.id}'),
                        onDelete: () => _delete(context, task),
                      )),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: OutlinedButton.icon(onPressed: () => context.go('/tasks/add'), icon: const Icon(Icons.add), label: const Text('Add Task'))),
                    const SizedBox(width: 12),
                    Expanded(child: OutlinedButton.icon(onPressed: () => context.go('/notes/add'), icon: const Icon(Icons.note_add_outlined), label: const Text('Add Note'))),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  const _StatCard(this.title, this.value, this.icon);

  @override
  Widget build(BuildContext context) => Card(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
