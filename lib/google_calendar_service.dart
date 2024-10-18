// ignore_for_file: file_names

import 'dart:async';

import 'package:flutter/material.dart'; // For SnackBar notifications in Flutter
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/googleapis_auth.dart'; // Import correct package
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http; // Add this for HTTP client

class GoogleCalendarService {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [calendar.CalendarApi.calendarScope], // Correct scope
  );

  AuthClient? _client;

  /// Sign-in the user via Google Sign-In and authenticate with Google Calendar
  Future<void> signIn(BuildContext context) async {
    try {
      // Initiate Google Sign-In
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // Notify user about the cancelation
        
  if(!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-In was canceled.')),
        );
        return;
      }

      // Obtain the Google authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create access credentials manually from the Google auth tokens
      var accessCredentials = AccessCredentials(
        AccessToken(
          'Bearer',
          googleAuth.accessToken!,
          DateTime.now().add(const Duration(hours: 1)), // Token expiration (adjust as needed)
        ),
        null, // Refresh token (not required in this case)
        [calendar.CalendarApi.calendarScope],
      );

      // Create an authenticated HTTP client using the credentials
      _client = autoRefreshingClient(
        ClientId('YOUR_CLIENT_ID', 'YOUR_CLIENT_SECRET'), // Replace with actual client ID and secret
        accessCredentials,
        http.Client(),
      );

  if(!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed in successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during Google Sign-In: $e')),
      );
    }
  }

  /// Add an event to Google Calendar
  Future<void> addEventToCalendar(
    BuildContext context,
    String title,
    String description,
    DateTime startTime,
    DateTime endTime,
  ) async {
    if (_client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User is not authenticated.')),
      );
      return;
    }

    final calendar.CalendarApi calendarApi = calendar.CalendarApi(_client!);

    final event = calendar.Event(
      summary: title,
      description: description,
      start: calendar.EventDateTime(dateTime: startTime, timeZone: 'UTC'),
      end: calendar.EventDateTime(dateTime: endTime, timeZone: 'UTC'),
    );

    try {
      
      await calendarApi.events.insert(event, 'primary');
  if(!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event added successfully to Google Calendar')),
      );
    } catch (e) {
        
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add event: $e')),
      );
    }
  }
}
