import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';

class SupabaseService {
  static bool get isConfigured =>
      AppConstants.supabaseUrl.isNotEmpty &&
      AppConstants.supabaseAnonKey.isNotEmpty;

  static void ensureConfigured() {
    if (!isConfigured) {
      throw StateError(
        'Supabase configuration is missing. Provide SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
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
  }

  static SupabaseClient get client => Supabase.instance.client;
}
