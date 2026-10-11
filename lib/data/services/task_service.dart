import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('tasks');

  /// Only a single equality filter is used, so no composite index is needed.
  /// Sorting and filtering are done on the client.
  Stream<List<TaskModel>> watchTasks(String uid) {
    return _col
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.map(TaskModel.fromDoc).toList());
  }

  Future<void> addTask(TaskModel task) => _col.add(task.toMap());

  Future<void> updateTask(TaskModel task) => _col.doc(task.id).update(task.toMap());

  Future<void> setCompleted(String id, bool value) =>
      _col.doc(id).update({'isCompleted': value});

  Future<void> deleteTask(String id) => _col.doc(id).delete();
}
