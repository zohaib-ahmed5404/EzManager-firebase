import 'package:flutter/material.dart';

class UserProfile {
  String username;
  String email;
  String profilePicUrl;

  UserProfile({
    required this.username,
    required this.email,
    required this.profilePicUrl,
  });
}

class UserProfileStore with ChangeNotifier {
  UserProfile? userProfile;

  Future<void> fetchUserProfileFromFirebase() async {
    // Simulate fetching user profile from Firebase (you need to implement this logic)
    userProfile = UserProfile(
      username: 'JohnDoe',
      email: 'johndoe@example.com',
      profilePicUrl: 'https://example.com/profile-pic.png',
    );
    notifyListeners();
  }

  Future<void> updateUserProfile(String username, String email, String profilePicUrl) async {
    // Simulate updating user profile in Firebase (you need to implement this logic)
    userProfile = UserProfile(username: username, email: email, profilePicUrl: profilePicUrl);
    notifyListeners();
  }

  void logout() {
    userProfile = null;
    notifyListeners();
  }
}
