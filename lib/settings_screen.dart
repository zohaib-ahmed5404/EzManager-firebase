import 'package:ezmanager_task4/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'store/theme_provider.dart';
import 'store/user_profile_store.dart';

class SettingsScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfileStore = Provider.of<UserProfileStore>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    _usernameController.text = userProfileStore.userProfile?.username ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Dark Mode'),
                Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await userProfileStore.updateUserProfile(
                  _usernameController.text,
                  userProfileStore.userProfile?.email ?? '',
                  userProfileStore.userProfile?.profilePicUrl ?? '',
                );
                if (!context.mounted) return;
                Navigator.pop(context); // Go back to the previous screen
              },
              child: const Text('Change Username'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                userProfileStore.logout(); // Handle logout logic

                // Navigate to the login screen
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()), // Replace with your login screen widget
                  (route) => false, // Remove all previous routes
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
