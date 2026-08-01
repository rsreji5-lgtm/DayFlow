part of 'note_cubit.dart';

abstract class NoteState extends Equatable {
  const NoteState();

  @override
  List<Object?> get props => [];
}

class NoteInitial extends NoteState {
  const NoteInitial();
}

class NoteLoading extends NoteState {
  const NoteLoading();
}

class NoteLoaded extends NoteState {
  final List<Note> notes;

  const NoteLoaded(
    this.notes,
  );

  @override
  List<Object?> get props => [
        notes,
      ];
}

class NoteEmpty extends NoteState {
  const NoteEmpty();
}

class NoteError extends NoteState {
  final String message;

  const NoteError(
    this.message,
  );

  @override
  List<Object?> get props => [
        message,
      ];
}