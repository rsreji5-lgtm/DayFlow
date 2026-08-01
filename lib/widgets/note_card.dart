import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final date =
        note.updatedAt ??
        note.createdAt;

    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.all(16),

        title: Text(
          note.title,
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        subtitle: Padding(
          padding:
              const EdgeInsets.only(
            top: 8,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                note.body,
                maxLines: 4,
                overflow:
                    TextOverflow.ellipsis,
              ),

              if (date != null) ...[
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Updated ${DateFormat('MMM d, yyyy').format(date)}',
                ),
              ],
            ],
          ),
        ),

        trailing:
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
      ),
    );
  }
}