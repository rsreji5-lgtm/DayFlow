import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubits/notes/note_cubit.dart';
import '../../models/note.dart';

class EditNoteScreen extends StatefulWidget {
  final String noteId;
  const EditNoteScreen({super.key, required this.noteId});
  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  Note? note;
  late final TextEditingController title;
  late final TextEditingController body;

  @override
  void initState() {
    super.initState();
    final state = context.read<NoteCubit>().state;
    if (state is NoteLoaded) {
      for (final n in state.notes) {
        if (n.id == widget.noteId) note = n;
      }
    }
    title = TextEditingController(text: note?.title ?? '');
    body = TextEditingController(text: note?.body ?? '');
  }

  @override
  void dispose() {
    title.dispose();
    body.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (note == null) return;
    await context.read<NoteCubit>().updateNote(
      Note(
        id: note!.id,
        title: title.text.trim(),
        body: body.text.trim(),
        createdAt: note!.createdAt,
        updatedAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note updated successfully.')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (note == null) return const Scaffold(body: Center(child: Text('Note not found.')));
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Note')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 16),
          TextField(controller: body, minLines: 10, maxLines: 16, decoration: const InputDecoration(labelText: 'Note')),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: const Text('Save Changes')),
        ],
      ),
    );
  }
}
