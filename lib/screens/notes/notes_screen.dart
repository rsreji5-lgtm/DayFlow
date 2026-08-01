import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubits/notes/note_cubit.dart';
import '../../models/note.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/note_card.dart';

class NotesScreen extends StatefulWidget {
  final String? successMessage;

  const NotesScreen({
    super.key,
    this.successMessage,
  });

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NoteCubit>().loadNotes();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.successMessage!),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: 2,
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
                      Text('My Notes', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Capture your thoughts and ideas.'),
                    ],
                  ),
                ),
                FloatingActionButton.small(onPressed: () => context.go('/notes/add'), child: const Icon(Icons.add)),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<NoteCubit, NoteState>(
              builder: (context, state) {
                if (state is NoteLoading || state is NoteInitial) return const Center(child: CircularProgressIndicator());
                if (state is NoteError) return _error(context, state.message);
                if (state is NoteEmpty) return _empty(context);
                final notes = (state as NoteLoaded).notes;
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  itemCount: notes.length,
                  itemBuilder: (_, i) => NoteCard(
                    note: notes[i],
                    onEdit: () => context.go('/notes/edit/${notes[i].id}'),
                    onDelete: () => _delete(context, notes[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.note_alt_outlined, size: 60),
            const SizedBox(height: 14),
            Text('No Notes Yet', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Save ideas, reminders, and important\ninformation here.', textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton.icon(onPressed: () => context.go('/notes/add'), icon: const Icon(Icons.add), label: const Text('Add Note')),
          ],
        ),
      );

  Widget _error(BuildContext context, String message) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => context.read<NoteCubit>().loadNotes(), child: const Text('Retry')),
          ],
        ),
      );

  Future<void> _delete(BuildContext context, Note note) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Note?'),
        content: const Text('Are you sure you want to delete this note?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (yes == true) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      final noteCubit = context.read<NoteCubit>();
      await noteCubit.deleteNote(note.id);
      if (!mounted) return;
      messenger?.showSnackBar(const SnackBar(content: Text('Note deleted successfully.')));
    }
  }
}
