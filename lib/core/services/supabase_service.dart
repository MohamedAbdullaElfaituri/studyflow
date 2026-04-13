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

  static Future<void> initialize() async {
    if (_initialized || !isConfigured) {
      return;
    }

    await Supabase.initialize(
      url: _normalized(AppConstants.supabaseUrl),
      anonKey: _normalized(AppConstants.supabaseAnonKey),
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        detectSessionInUri: true,
      ),
    );

    _initialized = true;
  }

  static SupabaseClient get client {
    if (!_initialized) {
      throw StateError('Supabase has not been initialized.');
    }
    return Supabase.instance.client;
  }
}
