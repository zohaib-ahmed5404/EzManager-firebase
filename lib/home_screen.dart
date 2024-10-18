import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import '/store/theme_provider.dart';
import '/store/todo_store.dart';
import '/store/user_profile_store.dart';
import 'add_task_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    initializeNotification();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkForDeadlines();
    });
  }

  void initializeNotification() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon'); // Add your app icon here
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin!.initialize(initializationSettings);
  }

  void showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'deadline_channel',
      'Deadline Notifications',
      channelDescription: 'Notifications for task deadlines',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin!.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'Task Notification',
    );
  }

  void checkForDeadlines() {
    final todoStore = Provider.of<ToDoStore>(context, listen: false);
    for (var task in todoStore.tasks) {
      if (task.deadline.isBefore(DateTime.now()) &&
          task.deadline.isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
        showNotification("Task Deadline", "The deadline for '${task.title}' is today!");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final todoStore = Provider.of<ToDoStore>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    Provider.of<UserProfileStore>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? Colors.grey[850] : Colors.green,
        title: const Text('EZ Manager', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: 28,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: FutureBuilder(
          future: todoStore.fetchTasksFromFirebase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (todoStore.tasks.isEmpty) {
              return const Center(
                child: Text(
                  'No tasks available',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              );
            }

            return ListView.builder(
              itemCount: todoStore.tasks.length,
              itemBuilder: (context, index) {
                final task = todoStore.tasks[index];
                bool isOverdue = task.deadline.isBefore(DateTime.now());

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    gradient: LinearGradient(
                      colors: isOverdue
                          ? [Colors.redAccent.shade200, Colors.redAccent.shade400]
                          : [Colors.green.shade300, Colors.green.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isOverdue ? Colors.white : Colors.black87,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                      ),
                    ),
                    subtitle: Text(
                      task.description,
                      style: TextStyle(color: isOverdue ? Colors.white70 : Colors.black54),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          task.deadline.toLocal().toString().split(' ')[0],
                          style: TextStyle(
                            color: isOverdue ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) {
                            todoStore.markTaskCompleted(task.id, value!);
                          },
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        label: const Text('Add Task', style: TextStyle(fontSize: 16)),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green.shade600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
