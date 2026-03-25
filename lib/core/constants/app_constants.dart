import 'package:flutter/material.dart';

class AppConstants {
  static const appName = 'StudyFlow';

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static const supportedLocales = [
    Locale('en'),
    Locale('tr'),
    Locale('ar'),
  ];

  static const authSessionKey = 'auth_session_user_id';
  static const onboardingKey = 'has_completed_onboarding';
  static const profilesKey = 'profiles_collection';
  static const authCredentialsKey = 'auth_credentials_collection';

  static String coursesKey(String userId) => '${userId}_courses_collection';
  static String tasksKey(String userId) => '${userId}_tasks_collection';
  static String notesKey(String userId) => '${userId}_notes_collection';
  static String sessionsKey(String userId) => '${userId}_sessions_collection';
  static String goalsKey(String userId) => '${userId}_goals_collection';
  static String settingsKey(String userId) => '${userId}_settings_document';
  static String remindersKey(String userId) => '${userId}_reminders_document';
}
