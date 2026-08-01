import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/note.dart';
import '../../repositories/note_repository.dart';

part 'note_state.dart';

class NoteCubit extends Cubit<NoteState> {
  final NoteRepository repository;

  StreamSubscription<List<Note>>?
      _subscription;

  NoteCubit(
    this.repository,
  ) : super(const NoteInitial());

  void loadNotes() {
    emit(const NoteLoading());

    _subscription?.cancel();

    _subscription =
        repository.watchNotes().listen(
      (notes) {
        if (notes.isEmpty) {
          emit(const NoteEmpty());
        } else {
          emit(
            NoteLoaded(notes),
          );
        }
      },
      onError: (_) {
        emit(
          const NoteError(
            'Unable to Load Notes',
          ),
        );
      },
    );
  }

  Future<void> addNote(
    String title,
    String body,
  ) {
    return repository.addNote(
      Note(
        id: '',
        title: title,
        body: body,
      ),
    );
  }

  Future<void> updateNote(
    Note note,
  ) {
    return repository.updateNote(
      note,
    );
  }

  Future<void> deleteNote(
    String id,
  ) {
    return repository.deleteNote(
      id,
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();

    return super.close();
  }
}