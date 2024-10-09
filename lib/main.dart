import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';
import 'login_screen.dart';
import 'store/task_model.dart';
import 'store/theme_provider.dart';
import 'store/todo_store.dart';
import 'store/user_profile_store.dart';

final Logger logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());

  // Initialize HiveBoxManager (Singleton)
  await HiveBoxManager().init();

  // Initialize Flutter Local Notifications Plugin
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    // Replaced the deprecated 'onSelectNotification' with 'onDidReceiveNotificationResponse'
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null) {
        logger.i("Notification Payload: ${response.payload}");
        // Handle the notification tap logic here
      }
    },
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProfileStore()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<ToDoStore>(create: (_) => ToDoStore()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EZ MANAGER',
      theme: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show a loading indicator while waiting for the auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Check if the user is logged in
          if (snapshot.hasData) {
            return const HomeScreen(); // User is logged in
          }
          return const LoginScreen(); // User is not logged in
        },
      ),
    );
  }
}

// Singleton for Hive Box Management
class HiveBoxManager {
  static final HiveBoxManager _instance = HiveBoxManager._internal();

  factory HiveBoxManager() {
    return _instance;
  }

  HiveBoxManager._internal();

  Box<Task>? _tasksBox;

  Future<void> init() async {
    if (!Hive.isBoxOpen('tasks')) {
      _tasksBox = await Hive.openBox<Task>('tasks');
    } else {
      _tasksBox = Hive.box<Task>('tasks'); // Retrieve already opened box
    }
  }

  Box<Task> get tasksBox {
    if (_tasksBox == null) {
      throw Exception('Tasks box is not initialized. Call init() first.');
    }
    return _tasksBox!;
  }
}
