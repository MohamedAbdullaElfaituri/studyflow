import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/localization/generated/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_widgets.dart';
import '../shared/providers/app_providers.dart';

class StudyFlowApp extends ConsumerWidget {
  const StudyFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final themePreference = ref.watch(effectiveThemePreferenceProvider);
    final locale = ref.watch(localeProvider);
    final accessibilityMode = ref.watch(accessibilityModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _StudyFlowScrollBehavior(),
      theme: AppTheme.light(locale, accessibilityMode: accessibilityMode),
      darkTheme: AppTheme.dark(locale, accessibilityMode: accessibilityMode),
      themeMode: themeMode,
      themeAnimationDuration:
          accessibilityMode ? Duration.zero : const Duration(milliseconds: 180),
      themeAnimationCurve: Curves.easeOutCubic,
      locale: locale,
      supportedLocales: AppConstants.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final appChild = child ?? const SizedBox.shrink();

        return MediaQuery(
          data: mediaQuery.copyWith(
            disableAnimations:
                accessibilityMode || mediaQuery.disableAnimations,
            textScaler: accessibilityMode
                ? const TextScaler.linear(1.05)
                : mediaQuery.textScaler,
          ),
          child: ThemeToggleScope(
            themeMode: themePreference,
            onToggle: () => _toggleThemeMode(context, ref),
            child: appChild,
          ),
        );
      },
    );
  }

  Future<void> _toggleThemeMode(BuildContext context, WidgetRef ref) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nextTheme = isDark ? 'light' : 'dark';
    final studyData = ref.read(studyDataControllerProvider).valueOrNull;
    final currentUser = ref.read(currentUserProvider);

    if (studyData != null && currentUser != null) {
      await ref.read(studyDataControllerProvider.notifier).updateSettings(
            studyData.settings.copyWith(
              themeMode: nextTheme,
              updatedAt: DateTime.now(),
            ),
          );
      return;
    }

    await ref.read(appThemePreferenceProvider.notifier).setTheme(nextTheme);
  }
}

class _StudyFlowScrollBehavior extends MaterialScrollBehavior {
  const _StudyFlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}
