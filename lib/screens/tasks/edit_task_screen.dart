import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubits/auth/task_cubit.dart';
import '../../models/tasks.dart';
import '../../services/notification_service.dart';
import '../../utils/reminder_utils.dart';

class EditTaskScreen extends StatefulWidget {
  final String taskId;
  const EditTaskScreen({super.key, required this.taskId});
  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  Task? task;
  late final TextEditingController title;
  late final TextEditingController description;
  DateTime? dueDate;
  TimeOfDay dueTime = TimeOfDay.now();
  String priority = 'medium';
  final List<String> reminders = [];
  bool ready = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<TaskCubit>().state;
    if (state is TaskData) {
      for (final t in state.tasks) {
        if (t.id == widget.taskId) task = t;
      }
    }
    if (task != null) {
      title = TextEditingController(text: task!.title);
      description = TextEditingController(text: task!.description);
      dueDate = task!.dueDate;
      dueTime = TimeOfDay.fromDateTime(task!.dueDate);
      priority = task!.priority;
      reminders.addAll(task!.reminders);
      ready = true;
    } else {
      title = TextEditingController();
      description = TextEditingController();
    }
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (task == null || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final finalDueDate = DateTime(
      dueDate?.year ?? task!.dueDate.year,
      dueDate?.month ?? task!.dueDate.month,
      dueDate?.day ?? task!.dueDate.day,
      dueTime.hour,
      dueTime.minute,
    );

    final updated = Task(
      id: task!.id,
      title: title.text.trim(),
      description: description.text.trim(),
      dueDate: finalDueDate,
      priority: priority,
      reminders: reminders,
      isCompleted: task!.isCompleted,
      createdAt: task!.createdAt,
      updatedAt: DateTime.now(),
    );

    final updateFuture = context.read<TaskCubit>().updateTask(updated);

    for (int index = 0; index < reminders.length; index++) {
      final reminderValue = reminders[index];
      final reminderTime = calculateReminderTime(reminderValue, finalDueDate);

      if (reminderTime != null && reminderTime.isAfter(DateTime.now())) {
        await NotificationService.instance.scheduleTaskReminder(
          notificationId: getNotificationId(task!.id, index),
          taskTitle: title.text.trim(),
          reminderTime: reminderTime,
        );
      }
    }

    if (!mounted) return;

    context.pushReplacement(
      '/home',
      extra: 'Task edited successfully',
    );

    try {
      await updateFuture;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update task: ${e.toString()}'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) return const Scaffold(body: Center(child: Text('Task not found.')));
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: title, decoration: const InputDecoration(labelText: 'Task Title')),
          const SizedBox(height: 16),
          TextField(controller: description, maxLines: 4, decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Due Date'),
            subtitle: Text('${dueDate!.day}/${dueDate!.month}/${dueDate!.year}'),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
                initialDate: dueDate!,
              );
              if (picked != null) setState(() => dueDate = picked);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Due Time'),
            subtitle: Text(dueTime.format(context)),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: dueTime,
              );
              if (picked != null) setState(() => dueTime = picked);
            },
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Reminders', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...reminders.asMap().entries.map((entry) {
                final index = entry.key;
                final reminderValue = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: reminderValue,
                          decoration: const InputDecoration(prefixIcon: Icon(Icons.notifications_outlined), border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'none', child: Text('No reminder')),
                            DropdownMenuItem(value: 'at due time', child: Text('At due time')),
                            DropdownMenuItem(value: '5 minutes before', child: Text('5 minutes before')),
                            DropdownMenuItem(value: '10 minutes before', child: Text('10 minutes before')),
                            DropdownMenuItem(value: '15 minutes before', child: Text('15 minutes before')),
                            DropdownMenuItem(value: '30 minutes before', child: Text('30 minutes before')),
                            DropdownMenuItem(value: '1 hour before', child: Text('1 hour before')),
                            DropdownMenuItem(value: '2 hours before', child: Text('2 hours before')),
                            DropdownMenuItem(value: '4 hours before', child: Text('4 hours before')),
                            DropdownMenuItem(value: '12 hours before', child: Text('12 hours before')),
                            DropdownMenuItem(value: '1 day before', child: Text('1 day before')),
                          ],
                          onChanged: (value) => setState(() => reminders[index] = value ?? '1 hour before'),
                        ),
                      ),
                      if (reminders.length > 1)
                        IconButton(
                          onPressed: () => setState(() => reminders.removeAt(index)),
                          icon: const Icon(Icons.remove_circle_outline),
                          tooltip: 'Remove reminder',
                        ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: () => setState(() => reminders.add('1 hour before')),
                icon: const Icon(Icons.add),
                label: const Text('Add reminder'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: priority,
            decoration: const InputDecoration(labelText: 'Priority'),
            items: const [
              DropdownMenuItem(value: 'low', child: Text('Low')),
              DropdownMenuItem(value: 'medium', child: Text('Medium')),
              DropdownMenuItem(value: 'high', child: Text('High')),
            ],
            onChanged: (v) => setState(() => priority = v ?? priority),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Saving Changes...'),
                    ],
                  )
                : const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
