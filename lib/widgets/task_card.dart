import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/tasks.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  Color _priorityColor(
    BuildContext context,
  ) {
    switch (task.priority) {
      case 'high':
        return Colors.red;

      case 'medium':
        return Colors.orange;

      default:
        return Colors.green;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final color =
        _priorityColor(context);

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Checkbox(
              value:
                  task.isCompleted,
              onChanged: (_) =>
                  onToggle(),
            ),

            const SizedBox(
              width: 8,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(
                      context,
                    )
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w700,
                          decoration:
                              task.isCompleted
                                  ? TextDecoration
                                      .lineThrough
                                  : null,
                        ),
                  ),

                  if (task.description
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      task.description,
                    ),
                  ],

                  const SizedBox(
                    height: 10,
                  ),

                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Text(
                        'Due: ${DateFormat('MMM d, yyyy • hh:mm a').format(task.dueDate)}',
                      ),

                      Chip(
                        label: Text(
                          task.priority
                              .toUpperCase(),
                        ),
                        visualDensity:
                            VisualDensity
                                .compact,
                        side:
                            BorderSide(
                          color: color,
                        ),
                      ),

                      Chip(
                        label: Text(
                          task.isCompleted
                              ? 'Completed'
                              : 'Pending',
                        ),
                        visualDensity:
                            VisualDensity
                                .compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                }

                if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (_) =>
                  const [
                PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}