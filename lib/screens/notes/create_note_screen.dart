import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubits/notes/note_cubit.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});
  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final title = TextEditingController();
  final body = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void dispose() {
    title.dispose();
    body.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final noteCubit = context.read<NoteCubit>();
    final messenger = ScaffoldMessenger.maybeOf(context);
    final saveFuture = noteCubit.addNote(title.text.trim(), body.text.trim());

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    context.pushReplacement('/notes', extra: 'Note created successfully.');

    try {
      await saveFuture;
      if (!mounted) return;
      messenger?.showSnackBar(const SnackBar(content: Text('Note created successfully.')));
    } catch (e) {
      if (!mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          content: Text('Failed to create note: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Create Note')),
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Title *', hintText: 'Enter note title'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Title is required.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: body,
                minLines: 8,
                maxLines: 14,
                decoration: const InputDecoration(labelText: 'Note', hintText: 'Write your note here...'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Note cannot be empty.' : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 8),
                          Text('Saving Note...'),
                        ],
                      )
                    : const Text('Save Note'),
              ),
            ],
          ),
        ),
      );
}
