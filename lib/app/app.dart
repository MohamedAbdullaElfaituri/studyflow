import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/localization/generated/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../shared/providers/app_providers.dart';

class StudyFlowApp extends ConsumerWidget {
  const StudyFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final accessibilityMode = ref.watch(accessibilityModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(locale, accessibilityMode: accessibilityMode),
      darkTheme: AppTheme.dark(locale, accessibilityMode: accessibilityMode),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppConstants.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            disableAnimations:
                accessibilityMode || mediaQuery.disableAnimations,
            textScaler: accessibilityMode
                ? const TextScaler.linear(1.05)
                : mediaQuery.textScaler,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
