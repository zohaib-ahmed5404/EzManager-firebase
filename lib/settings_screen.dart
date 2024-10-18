import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';
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
        backgroundColor: themeProvider.isDarkMode ? Colors.grey[850] : Colors.green,
        title: const Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Change Username'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                userProfileStore.logout(); // Handle logout logic
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()), // Replace with your login screen widget
                  (route) => false, // Remove all previous routes
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
