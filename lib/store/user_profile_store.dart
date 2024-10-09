import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
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

class UserProfileStore extends ChangeNotifier {
  UserProfile? _userProfile;

  UserProfile? get userProfile => _userProfile;

  UserProfileStore() {
    // Initialize with random profile
    _userProfile = UserProfile(
      username: 'User${Random().nextInt(100)}', // Random username
      email: 'user@example.com',
      profilePicUrl: getRandomProfilePic(),
    );
  }

  // Update user profile with new values and Firestore
  Future<void> updateUserProfile(String username, String email, String profilePicUrl) async {
    _userProfile = UserProfile(
      username: username,
      email: email,
      profilePicUrl: profilePicUrl,
    );
    
    // Update in Firestore
    try {
      // Assuming userProfile has a field 'uid' that uniquely identifies the user
      await FirebaseFirestore.instance.collection('users').doc(_userProfile!.email).update({
        'username': username,
        'email': email,
        'profilePicUrl': profilePicUrl,
      });
    } catch (error) {
      // Optionally notify users about the error
    }

    notifyListeners();
  }

  // Set user profile directly from Firebase user
  void setUserProfile({
    required String username,
    required String email,
    required String profilePicUrl,
  }) {
    _userProfile = UserProfile(
      username: username,
      email: email,
      profilePicUrl: profilePicUrl,
    );
    notifyListeners();
  }

  // Generate a random profile picture URL
  String getRandomProfilePic() {
    final images = [
      'https://randomuser.me/api/portraits/men/1.jpg',
      'https://randomuser.me/api/portraits/women/1.jpg',
      'https://randomuser.me/api/portraits/men/2.jpg',
      'https://randomuser.me/api/portraits/women/2.jpg',
      'https://randomuser.me/api/portraits/men/3.jpg',
      'https://randomuser.me/api/portraits/women/3.jpg',
    ];
    return images[Random().nextInt(images.length)];
  }

  // Handle logout logic
  void logout() {
    _userProfile = null; // Clear user profile
    notifyListeners();
  }
}
