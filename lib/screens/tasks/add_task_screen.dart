import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubits/auth/task_cubit.dart';
import '../../services/notification_service.dart';
import '../../utils/reminder_utils.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final title = TextEditingController();
  final description = TextEditingController();
  final formKey = GlobalKey<FormState>();

  DateTime dueDate = DateTime.now();
  TimeOfDay dueTime = TimeOfDay.now();
  String priority = 'medium';
  final List<String> reminders = ['1 hour before'];

  bool _isSaving = false;

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Prevent multiple clicks
    if (_isSaving) return;

    // Validate form
    if (!formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final taskCubit = context.read<TaskCubit>();
    final messenger = ScaffoldMessenger.maybeOf(context);
    final dueDateTime = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      dueTime.hour,
      dueTime.minute,
    );

    final saveFuture = taskCubit.addTask(
      title: title.text.trim(),
      description: description.text.trim(),
      dueDate: dueDateTime,
      priority: priority,
      reminders: reminders,
    );

    for (int index = 0; index < reminders.length; index++) {
      final reminderValue = reminders[index];
      final reminderTime = calculateReminderTime(reminderValue, dueDateTime);

      if (reminderTime != null && reminderTime.isAfter(DateTime.now())) {
        await NotificationService.instance.scheduleTaskReminder(
          notificationId: DateTime.now().millisecondsSinceEpoch ~/ 1000 + index,
          taskTitle: title.text.trim(),
          reminderTime: reminderTime,
        );
      }
    }

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    context.pushReplacement(
      '/home',
      extra: 'Task created successfully',
    );

    try { 
      await saveFuture;
    } catch (e) {
      if (!mounted) return;

      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            'Failed to create task: ${e.toString()}',
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
      ),

      body: Form(
        key: formKey,

        child: ListView(
          padding: const EdgeInsets.all(20),

          children: [
            const Text(
              'Add something you need to accomplish.',
            ),

            const SizedBox(height: 24),

            // TITLE
            TextFormField(
              controller: title,

              decoration: const InputDecoration(
                labelText: 'Task Title *',
                hintText: 'Enter task title',
              ),

              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Task title is required.';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // DESCRIPTION
            TextFormField(
              controller: description,

              maxLines: 4,

              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe your task...',
              ),
            ),

            const SizedBox(height: 16),

            // DUE DATE
            ListTile(
              contentPadding: EdgeInsets.zero,

              title: const Text(
                'Due Date *',
              ),

              subtitle: Text(
                '${dueDate.day}/${dueDate.month}/${dueDate.year}',
              ),

              trailing: const Icon(
                Icons.calendar_month,
              ),

              onTap: _isSaving
                  ? null
                  : () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        initialDate: dueDate,
                      );

                      if (picked != null) {
                        setState(() {
                          dueDate = picked;
                        });
                      }
                    },
            ),

            const SizedBox(height: 10),

            // DUE TIME
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Due Time'),
              subtitle: Text(dueTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: _isSaving
                  ? null
                  : () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: dueTime,
                      );

                      if (picked != null) {
                        setState(() {
                          dueTime = picked;
                        });
                      }
                    },
            ),

            const SizedBox(height: 10),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reminders',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
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
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.notifications_outlined),
                              border: OutlineInputBorder(),
                            ),
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
                            onChanged: _isSaving
                                ? null
                                : (value) {
                                    setState(() {
                                      reminders[index] = value ?? '1 hour before';
                                    });
                                  },
                          ),
                        ),
                        if (reminders.length > 1)
                          IconButton(
                            onPressed: _isSaving
                                ? null
                                : () {
                                    setState(() {
                                      reminders.removeAt(index);
                                    });
                                  },
                            icon: const Icon(Icons.remove_circle_outline),
                            tooltip: 'Remove reminder',
                          ),
                      ],
                    ),
                  );
                }),
                if (!(_isSaving))
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        reminders.add('1 hour before');
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add reminder'),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // PRIORITY
            DropdownButtonFormField<String>(
              value: priority,

              decoration: const InputDecoration(
                labelText: 'Priority',
              ),

              items: const [
                DropdownMenuItem(
                  value: 'low',
                  child: Text('Low'),
                ),
                DropdownMenuItem(
                  value: 'medium',
                  child: Text('Medium'),
                ),
                DropdownMenuItem(
                  value: 'high',
                  child: Text('High'),
                ),
              ],

              onChanged: _isSaving
                  ? null
                  : (v) {
                      setState(() {
                        priority = v ?? 'medium';
                      });
                    },
            ),

            const SizedBox(height: 28),

            // CREATE TASK BUTTON
            SizedBox(
              height: 52,

              child: FilledButton(
                onPressed: _isSaving ? null : _save,

                child: _isSaving
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),

                          SizedBox(width: 12),

                          Text(
                            'Creating Task...',
                          ),
                        ],
                      )
                    : const Text(
                        'Create Task',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}