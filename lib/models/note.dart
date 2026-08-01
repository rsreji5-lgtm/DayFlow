import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;

  final String title;
  final String body;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.body,
    this.createdAt,
    this.updatedAt,
  });

  factory Note.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return Note(
      id: doc.id,

      title: data['title'] ?? '',

      body: data['body'] ?? '',

      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate(),

      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,

      'body': body,

      'createdAt':
          createdAt == null
              ? FieldValue.serverTimestamp()
              : Timestamp.fromDate(createdAt!),

      'updatedAt':
          FieldValue.serverTimestamp(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        body,
      ];
}