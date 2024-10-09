import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'task_model.dart'; // Import your Task model

class ToDoStore extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Box<Task> _taskBox = Hive.box<Task>('tasks');
  List<Task> tasks = [];

  ToDoStore() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    tasks.clear();
    final List<Task> storedTasks = _taskBox.values.toList();
    tasks.addAll(storedTasks);
    notifyListeners();
  }

  Future<void> fetchTasksFromFirebase() async {
    final QuerySnapshot snapshot = await _db.collection('tasks').get();
    for (var doc in snapshot.docs) {
      final task = Task.fromFirestore(doc.data() as DocumentSnapshot<Object?>);
      await _taskBox.add(task); // Save to Hive
      tasks.add(task); // Add to local list
    }
    notifyListeners();
  }

  Future<void> addTask(String title, String description, bool isImportant, String category, DateTime deadline) async {
    final task = Task(
      title: title,
      description: description,
      isImportant: isImportant,
      category: category,
      deadline: deadline,
      isCompleted: false,
    );

    // Save task to Hive
    await _taskBox.add(task);
    tasks.add(task);
    notifyListeners();

    // Also add to Firebase
    await _db.collection('tasks').add(task.toMap());
  }

   Future<void> markTaskCompleted(String id, bool isCompleted) async {
    final taskIndex = tasks.indexWhere((t) => t.id == id);
    if (taskIndex != -1) {
      tasks[taskIndex].isCompleted = isCompleted;
      _taskBox.putAt(taskIndex, tasks[taskIndex]); // Save updated task to Hive
      notifyListeners();
    }
  }
}
