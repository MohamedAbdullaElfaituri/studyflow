import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/reminder_service.dart';
import 'core/services/supabase_service.dart';
import 'shared/providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await SupabaseService.initialize();
  final storage = await LocalStorageService.create();
  final reminders = await ReminderService.create();

  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(storage),
        reminderServiceProvider.overrideWithValue(reminders),
      ],
      child: const StudyFlowApp(),
    ),
  );
}
