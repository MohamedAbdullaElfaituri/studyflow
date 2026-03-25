import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/extensions/build_context_x.dart';
import '../../../shared/providers/app_providers.dart';
import '../../auth/presentation/auth_screens.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const routePath = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(studyDataControllerProvider);

    return AppPage(
      child: data.when(
        loading: () => const LoadingColumn(itemCount: 4),
        error: (error, _) => ErrorStateCard(
          message: context.resolveError(error),
          onRetry: () => ref.read(studyDataControllerProvider.notifier).refresh(),
        ),
        data: (studyData) => ListView(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: Navigator.of(context).pop,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    context.l10n.settingsTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.languageSectionTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'en', label: Text(context.l10n.englishLabel)),
                      ButtonSegment(value: 'tr', label: Text(context.l10n.turkishLabel)),
                      ButtonSegment(value: 'ar', label: Text(context.l10n.arabicLabel)),
                    ],
                    selected: {studyData.settings.languageCode},
                    onSelectionChanged: (selection) async {
                      await ref.read(studyDataControllerProvider.notifier).updateSettings(
                            studyData.settings.copyWith(
                              languageCode: selection.first,
                              updatedAt: DateTime.now(),
                            ),
                          );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.themeSectionTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'system', label: Text(context.l10n.themeSystem)),
                      ButtonSegment(value: 'light', label: Text(context.l10n.themeLight)),
                      ButtonSegment(value: 'dark', label: Text(context.l10n.themeDark)),
                    ],
                    selected: {studyData.settings.themeMode},
                    onSelectionChanged: (selection) async {
                      await ref.read(studyDataControllerProvider.notifier).updateSettings(
                            studyData.settings.copyWith(
                              themeMode: selection.first,
                              updatedAt: DateTime.now(),
                            ),
                          );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionCard(
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: studyData.reminders.tasksEnabled,
                    title: Text(context.l10n.taskRemindersLabel),
                    onChanged: (value) async {
                      await ref.read(studyDataControllerProvider.notifier).updateReminders(
                            studyData.reminders.copyWith(
                              tasksEnabled: value,
                              updatedAt: DateTime.now(),
                            ),
                          );
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: studyData.reminders.studyEnabled,
                    title: Text(context.l10n.studyRemindersLabel),
                    onChanged: (value) async {
                      await ref.read(studyDataControllerProvider.notifier).updateReminders(
                            studyData.reminders.copyWith(
                              studyEnabled: value,
                              updatedAt: DateTime.now(),
                            ),
                          );
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: studyData.reminders.dailyEnabled,
                    title: Text(context.l10n.dailyReminderLabel),
                    onChanged: (value) async {
                      await ref.read(studyDataControllerProvider.notifier).updateReminders(
                            studyData.reminders.copyWith(
                              dailyEnabled: value,
                              updatedAt: DateTime.now(),
                            ),
                          );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton.tonal(
                    onPressed: () async {
                      await ref.read(reminderServiceProvider).showPreview(
                            id: 7,
                            title: context.l10n.notificationPreviewTitle,
                            body: context.l10n.notificationPreviewBody,
                          );
                    },
                    child: Text(context.l10n.previewNotificationAction),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.accessibility_new_rounded),
                title: Text(context.l10n.accessibilityPlaceholderTitle),
                subtitle: Text(context.l10n.accessibilityPlaceholderDescription),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) {
                  context.go(LoginScreen.routePath);
                }
              },
              child: Text(context.l10n.logoutAction),
            ),
          ],
        ),
      ),
    );
  }
}
