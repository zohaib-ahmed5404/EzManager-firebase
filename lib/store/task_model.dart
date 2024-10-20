import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:hive/hive.dart';

part 'task_model.g.dart'; // This will be generated by Hive

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final bool isImportant;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final DateTime deadline;

  @HiveField(5)
  bool isCompleted = false; // Explicitly initialized

  @HiveField(6)
  String id = ''; // Explicitly initialized

  Task({
    required this.title,
    required this.description,
    required this.isImportant,
    required this.category,
    required this.deadline,
    this.isCompleted=false,
  });

  // Factory constructor to create a Task from Firestore data
  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Task(
      title: data['title'],
      description: data['description'],
      isImportant: data['isImportant'],
      category: data['category'],
      deadline: (data['deadline'] as Timestamp).toDate(), // Convert Firestore Timestamp to DateTime
    );
  }

  // Method to convert a Task object to Firestore format (Map)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isImportant': isImportant,
      'category': category,
      'deadline': Timestamp.fromDate(deadline), // Convert DateTime to Firestore Timestamp
    };
  }

  // Factory constructor to create a Task from a JSON map (if you still need this)
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      description: json['description'],
      isImportant: json['isImportant'],
      category: json['category'],
      deadline: DateTime.parse(json['deadline']),
    );
  }

  // Method to convert a Task to a JSON map (if you still need this)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isImportant': isImportant,
      'category': category,
      'deadline': deadline.toIso8601String(),
    };
  }
}
