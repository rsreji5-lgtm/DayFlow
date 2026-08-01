import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/note.dart';

class NoteRepository {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>
      get _notes {
    final uid = _auth.currentUser!.uid;

    return _db
        .collection('users')
        .doc(uid)
        .collection('notes');
  }

  Stream<List<Note>> watchNotes() {
    return _notes
        .orderBy(
          'updatedAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(Note.fromFirestore)
                  .toList(),
        );
  }

  Future<void> addNote(Note note) {
    return _notes.add(
      note.toMap(),
    );
  }

  Future<void> updateNote(Note note) {
    return _notes
        .doc(note.id)
        .update(note.toMap());
  }

  Future<void> deleteNote(String id) {
    return _notes
        .doc(id)
        .delete();
  }
}