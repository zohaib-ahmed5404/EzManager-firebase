import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'store/todo_store.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  AddTaskScreenState createState() => AddTaskScreenState();
}

class AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isImportant = false;
  String _category = '';
  DateTime? _deadline;

  @override
  Widget build(BuildContext context) {
    final todoStore = Provider.of<ToDoStore>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
        titleTextStyle: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor, // Use theme colors
        elevation: 0, // Flat app bar for a modern look
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title TextField
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: theme.colorScheme.secondary), // Updated for dark mode
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.secondary),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description TextField
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: theme.colorScheme.secondary),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.secondary),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Important Checkbox
            Row(
              children: [
                const Text('Important:'),
                Checkbox(
                  value: _isImportant,
                  onChanged: (value) {
                    setState(() {
                      _isImportant = value ?? false;
                    });
                  },
                  activeColor: theme.colorScheme.secondary, // Update checkbox color for dark mode
                ),
              ],
            ),

            // Category TextField
            TextField(
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: theme.colorScheme.secondary),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.secondary),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                _category = value;
              },
            ),
            const SizedBox(height: 16),

            // Date Picker Button
            TextButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _deadline = pickedDate;
                  });
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: theme.colorScheme.secondaryContainer, // Update background for dark mode
              ),
              child: Text(
                _deadline == null
                    ? 'Select Deadline'
                    : 'Deadline: ${_deadline!.toLocal()}'.split(' ')[0],
                style: TextStyle(color: theme.colorScheme.onSecondary), // Update text color
              ),
            ),
            const SizedBox(height: 20),

            // Add Task Button
            ElevatedButton(
              onPressed: () {
                _addTask(todoStore);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                backgroundColor: theme.colorScheme.primary, // Use theme colors
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add Task',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addTask(ToDoStore todoStore) async {
    if (_titleController.text.isNotEmpty && _deadline != null) {
      try {
        await todoStore.addTask(
          _titleController.text,
          _descriptionController.text,
          _isImportant,
          _category,
          _deadline!,
        );

        // Clear the fields after the task is added
        _titleController.clear();
        _descriptionController.clear();
        _isImportant = false;
        _category = '';
        _deadline = null;

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added successfully!')),
        );

        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding task: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }
}
