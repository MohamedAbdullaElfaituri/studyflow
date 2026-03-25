import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';

class SupabaseService {
  static bool get isConfigured =>
      AppConstants.supabaseUrl.isNotEmpty &&
      AppConstants.supabaseAnonKey.isNotEmpty;

  static Future<void> initialize() async {
    if (!isConfigured) {
      return;
    }

    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
