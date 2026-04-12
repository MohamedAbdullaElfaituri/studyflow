import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';

enum BackendMode { local, supabase }

class SupabaseService {
  static bool _initialized = false;

  static String _normalized(String value) => value.trim();

  static bool get isConfigured =>
      _normalized(AppConstants.supabaseUrl).isNotEmpty &&
      _normalized(AppConstants.supabaseAnonKey).isNotEmpty;

  static bool get isInitialized => _initialized;

  static BackendMode get backendMode =>
      isConfigured ? BackendMode.supabase : BackendMode.local;

<<<<<<< HEAD
  static Future<void> initialize() async {
    if (!isConfigured || _initialized) {
      return;
=======
  static void ensureConfigured() {
    if (!isConfigured) {
      throw StateError(
        'Supabase configuration is missing. Provide SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
>>>>>>> 92fae2d3904b11ee5fa030777256fb5aa49368c1
    }
  }

  static Future<void> initialize() async {
    ensureConfigured();

    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    _initialized = true;
  }

  static SupabaseClient get client {
    if (!_initialized) {
      throw StateError(
        'Supabase is not initialized. Provide SUPABASE_URL and SUPABASE_ANON_KEY, '
        'or use the local demo mode.',
      );
    }
    return Supabase.instance.client;
  }
}
