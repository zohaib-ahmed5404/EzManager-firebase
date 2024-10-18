import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:googleapis_auth/auth_io.dart'; // For OAuth
import 'package:http/http.dart' as http;
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
        titleTextStyle: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
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
            ),
            const SizedBox(height: 16),
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
                  activeColor: theme.colorScheme.secondary,
                ),
              ],
            ),
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
                backgroundColor: theme.colorScheme.secondaryContainer,
              ),
              child: Text(
                _deadline == null
                    ? 'Select Deadline'
                    : 'Deadline: ${_deadline!.toLocal()}'.split(' ')[0],
                style: TextStyle(color: theme.colorScheme.onSecondary),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addTask(todoStore);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                backgroundColor: theme.colorScheme.primary,
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

        await _syncWithGoogleCalendar(
          _titleController.text,
          _descriptionController.text,
          _deadline!,
        );

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

  Future<void> _syncWithGoogleCalendar(String title, String description, DateTime deadline) async {
    final client = await authenticateWithGoogle();
    final calendarApi = gcal.CalendarApi(client);

    final event = gcal.Event(
      summary: title,
      description: description,
      start: gcal.EventDateTime(
        dateTime: deadline,
        timeZone: "Asia/Karachi",
      ),
      end: gcal.EventDateTime(
        dateTime: deadline.add(const Duration(hours: 1)),
        timeZone: "Asia/Karachi",
      ),
    );

    await calendarApi.events.insert(event, 'primary');
  }

  Future<http.Client> authenticateWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      scopes: [gcal.CalendarApi.calendarScope],
    );

    final account = await googleSignIn.signIn();
    if (account == null) {
      throw Exception('Google sign-in failed');
    }

    final authHeaders = await account.authHeaders;
    final client = http.Client();

    return authenticatedClient(
      client,
      AccessCredentials(
        AccessToken(
          'Bearer',
          authHeaders['Authorization']!.split(' ')[1],
          DateTime.now().add(const Duration(hours: 1)),
        ),
        null,
        [gcal.CalendarApi.calendarScope],
      ),
    );
  }
}
