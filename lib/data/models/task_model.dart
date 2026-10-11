import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  static const List<String> priorities = ['Low', 'Medium', 'High'];

  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority;
  final bool isCompleted;
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
    required this.createdAt,
  });

  factory TaskModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
    return TaskModel(
      id: doc.id,
      userId: (data['userId'] ?? '') as String,
      title: (data['title'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      priority: (data['priority'] ?? 'Medium') as String,
      isCompleted: (data['isCompleted'] ?? false) as bool,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'title': title,
        'description': description,
        'dueDate': Timestamp.fromDate(dueDate),
        'priority': priority,
        'isCompleted': isCompleted,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  TaskModel copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }

  int get priorityWeight {
    switch (priority) {
      case 'High':
        return 3;
      case 'Medium':
        return 2;
      default:
        return 1;
    }
  }

  bool get isOverdue {
    if (isCompleted) return false;
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    return dueDate.isBefore(today);
  }
}
