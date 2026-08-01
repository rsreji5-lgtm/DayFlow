import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/tasks.dart';

class TaskRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tasks =>
      _firestore.collection('tasks');

  Future<void> addTask({
    required String userId,
    required String title,
    required String description,
    required DateTime dueDate,
    required String priority,
    required List<String> reminders,
  }) async {
    await _tasks.add({
      'userId': userId,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority,
      'reminders': reminders,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Task>> watchTasks(String userId) {
    return _tasks
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) {
            final tasks = snapshot.docs
                .map((doc) => Task.fromFirestore(doc))
                .toList();
            tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
            return tasks;
          },
        );
  }

  Future<void> deleteTask(String taskId) async {
    await _tasks.doc(taskId).delete();
  }

  Future<void> updateTask(Task task) async {
    await _tasks.doc(task.id).update({
      'title': task.title,
      'description': task.description,
      'dueDate': Timestamp.fromDate(task.dueDate),
      'priority': task.priority,
      'reminders': task.reminders,
      'isCompleted': task.isCompleted,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleComplete(Task task) async {
    await _tasks.doc(task.id).update({
      'isCompleted': !task.isCompleted,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}