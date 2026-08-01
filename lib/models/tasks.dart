import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final String id;

  final String title;
  final String description;

  final DateTime dueDate;

  final String priority;

  final List<String> reminders;

  final bool isCompleted;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.reminders,
    required this.isCompleted,
    this.createdAt,
    this.updatedAt,
  });

  factory Task.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return Task(
      id: doc.id,

      title: data['title'] ?? '',

      description: data['description'] ?? '',

      dueDate:
          (data['dueDate'] as Timestamp?)?.toDate()
          ?? DateTime.now(),

      priority: data['priority'] ?? 'medium',

      reminders: (data['reminders'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],

      isCompleted:
          data['isCompleted'] ?? false,

      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate(),

      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    List<String>? reminders,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      reminders: reminders ?? this.reminders,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,

      'description': description,

      'dueDate':
          Timestamp.fromDate(dueDate),

      'priority': priority,

      'reminders': reminders,

      'isCompleted': isCompleted,

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
        description,
        dueDate,
        priority,
        reminders,
        isCompleted,
      ];
}