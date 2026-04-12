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
    final isCloudSyncEnabled = ref.watch(isCloudSyncEnabledProvider);

    return AppPage(
      child: data.when(
        loading: () => const LoadingColumn(itemCount: 4),
        error: (error, _) => ErrorStateCard(
          message: context.resolveError(error),
          onRetry: () =>
              ref.read(studyDataControllerProvider.notifier).refresh(),
        ),
        data: (studyData) {
          const supportedLanguages = {'en', 'tr', 'ar'};
          const supportedThemes = {'system', 'light', 'dark'};
          final selectedLanguage = supportedLanguages.contains(
            studyData.settings.languageCode,
          )
              ? studyData.settings.languageCode
              : 'en';
          final selectedTheme = supportedThemes.contains(
            studyData.settings.themeMode,
          )
              ? studyData.settings.themeMode
              : 'system';
          final workspaceTitle = isCloudSyncEnabled
              ? context.copy.workspaceCloudTitle
              : context.copy.workspaceDemoTitle;
          final workspaceDescription = isCloudSyncEnabled
              ? context.copy.workspaceCloudDescription
              : context.copy.workspaceDemoDescription;
          final workspaceChip = isCloudSyncEnabled
              ? context.copy.workspaceCloudChip
              : context.copy.workspaceDemoChip;
          final workspaceColor = isCloudSyncEnabled
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.tertiary;

          return ListView(
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: workspaceColor.withOpacity(0.14),
                          child: Icon(
                            isCloudSyncEnabled
                                ? Icons.cloud_done_rounded
                                : Icons.rocket_launch_rounded,
                            color: workspaceColor,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.copy.workspaceModeTitle,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                workspaceTitle,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        StatusPill(
                          label: workspaceChip,
                          color: workspaceColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      workspaceDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        StatusPill(
                          label: isCloudSyncEnabled
                              ? 'Supabase'
                              : 'SharedPreferences',
                          color: workspaceColor,
                        ),
                        StatusPill(
                          label: isCloudSyncEnabled
                              ? context.copy.googleOAuthReadyLabel
                              : context.copy.workspaceDemoChip,
                          color: workspaceColor,
                        ),
                      ],
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
                      context.l10n.languageSectionTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _SettingsChoiceChip(
                          label: context.l10n.englishLabel,
                          selected: selectedLanguage == 'en',
                          onSelected: () async {
                            await ref
                                .read(studyDataControllerProvider.notifier)
                                .updateSettings(
                                  studyData.settings.copyWith(
                                    languageCode: 'en',
                                    updatedAt: DateTime.now(),
                                  ),
                                );
                          },
                        ),
                        _SettingsChoiceChip(
                          label: context.l10n.turkishLabel,
                          selected: selectedLanguage == 'tr',
                          onSelected: () async {
                            await ref
                                .read(studyDataControllerProvider.notifier)
                                .updateSettings(
                                  studyData.settings.copyWith(
                                    languageCode: 'tr',
                                    updatedAt: DateTime.now(),
                                  ),
                                );
                          },
                        ),
                        _SettingsChoiceChip(
                          label: context.l10n.arabicLabel,
                          selected: selectedLanguage == 'ar',
                          onSelected: () async {
                            await ref
                                .read(studyDataControllerProvider.notifier)
                                .updateSettings(
                                  studyData.settings.copyWith(
                                    languageCode: 'ar',
                                    updatedAt: DateTime.now(),
                                  ),
                                );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
<<<<<<< HEAD
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.themeSectionTitle,
                      style: Theme.of(context).textTheme.titleLarge,
=======
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
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _SettingsChoiceChip(
                        label: context.l10n.englishLabel,
                        selected: selectedLanguage == 'en',
                        onSelected: () async {
                          await ref
                              .read(studyDataControllerProvider.notifier)
                              .updateSettings(
                                studyData.settings.copyWith(
                                  languageCode: 'en',
                                  updatedAt: DateTime.now(),
                                ),
                              );
                        },
                      ),
                      _SettingsChoiceChip(
                        label: context.l10n.turkishLabel,
                        selected: selectedLanguage == 'tr',
                        onSelected: () async {
                          await ref
                              .read(studyDataControllerProvider.notifier)
                              .updateSettings(
                                studyData.settings.copyWith(
                                  languageCode: 'tr',
                                  updatedAt: DateTime.now(),
                                ),
                              );
                        },
                      ),
                      _SettingsChoiceChip(
                        label: context.l10n.arabicLabel,
                        selected: selectedLanguage == 'ar',
                        onSelected: () async {
                          await ref
                              .read(studyDataControllerProvider.notifier)
                              .updateSettings(
                                studyData.settings.copyWith(
                                  languageCode: 'ar',
                                  updatedAt: DateTime.now(),
                                ),
                              );
                        },
                      ),
                    ],
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
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _SettingsChoiceChip(
                        label: context.l10n.themeSystem,
                        selected: selectedTheme == 'system',
                        onSelected: () async {
                          await ref
                              .read(studyDataControllerProvider.notifier)
                              .updateSettings(
                                studyData.settings.copyWith(
                                  themeMode: 'system',
                                  updatedAt: DateTime.now(),
                                ),
                              );
                        },
                      ),
                      _SettingsChoiceChip(
                        label: context.l10n.themeLight,
                        selected: selectedTheme == 'light',
                        onSelected: () async {
                          await ref
                              .read(studyDataControllerProvider.notifier)
                              .updateSettings(
                                studyData.settings.copyWith(
                                  themeMode: 'light',
                                  updatedAt: DateTime.now(),
                                ),
                              );
                        },
                      ),
                      _SettingsChoiceChip(
                        label: context.l10n.themeDark,
                        selected: selectedTheme == 'dark',
                        onSelected: () async {
                          await ref
                              .read(studyDataControllerProvider.notifier)
                              .updateSettings(
                                studyData.settings.copyWith(
                                  themeMode: 'dark',
                                  updatedAt: DateTime.now(),
                                ),
                              );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.notifications_active_outlined),
                    title: Text(context.copy.notificationPermissionsAction),
                    subtitle: Text(context.copy.notificationPermissionsHint),
                    onTap: () async {
                      await ref.read(reminderServiceProvider).requestPermissions();
                    },
                  ),
                  const Divider(),
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
            SectionCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.sync_rounded),
                    title: Text(context.copy.syncStatusTitle),
                    subtitle: Text(context.copy.syncReadyLabel),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.info_outline_rounded),
                    title: Text(context.copy.aboutLabel),
                    onTap: () => _showPlaceholderSheet(
                      context,
                      context.copy.aboutLabel,
>>>>>>> 92fae2d3904b11ee5fa030777256fb5aa49368c1
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _SettingsChoiceChip(
                          label: context.l10n.themeSystem,
                          selected: selectedTheme == 'system',
                          onSelected: () async {
                            await ref
                                .read(studyDataControllerProvider.notifier)
                                .updateSettings(
                                  studyData.settings.copyWith(
                                    themeMode: 'system',
                                    updatedAt: DateTime.now(),
                                  ),
                                );
                          },
                        ),
                        _SettingsChoiceChip(
                          label: context.l10n.themeLight,
                          selected: selectedTheme == 'light',
                          onSelected: () async {
                            await ref
                                .read(studyDataControllerProvider.notifier)
                                .updateSettings(
                                  studyData.settings.copyWith(
                                    themeMode: 'light',
                                    updatedAt: DateTime.now(),
                                  ),
                                );
                          },
                        ),
                        _SettingsChoiceChip(
                          label: context.l10n.themeDark,
                          selected: selectedTheme == 'dark',
                          onSelected: () async {
                            await ref
                                .read(studyDataControllerProvider.notifier)
                                .updateSettings(
                                  studyData.settings.copyWith(
                                    themeMode: 'dark',
                                    updatedAt: DateTime.now(),
                                  ),
                                );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.notifications_active_outlined),
                      title: Text(context.copy.notificationPermissionsAction),
                      subtitle: Text(context.copy.notificationPermissionsHint),
                      onTap: () async {
                        await ref
                            .read(reminderServiceProvider)
                            .requestPermissions();
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: studyData.reminders.tasksEnabled,
                      title: Text(context.l10n.taskRemindersLabel),
                      onChanged: (value) async {
                        await ref
                            .read(studyDataControllerProvider.notifier)
                            .updateReminders(
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
                        await ref
                            .read(studyDataControllerProvider.notifier)
                            .updateReminders(
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
                        await ref
                            .read(studyDataControllerProvider.notifier)
                            .updateReminders(
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
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: studyData.settings.accessibilityMode,
                  secondary: const Icon(Icons.accessibility_new_rounded),
                  title: Text(context.copy.accessibilityModeTitle),
                  subtitle: Text(context.copy.accessibilityModeDescription),
                  onChanged: (value) async {
                    await ref
                        .read(studyDataControllerProvider.notifier)
                        .updateSettings(
                          studyData.settings.copyWith(
                            accessibilityMode: value,
                            updatedAt: DateTime.now(),
                          ),
                        );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.sync_rounded),
                      title: Text(context.copy.syncStatusTitle),
                      subtitle: Text(context.copy.syncReadyLabel),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.info_outline_rounded),
                      title: Text(context.copy.aboutLabel),
                      onTap: () => _showPlaceholderSheet(
                        context,
                        context.copy.aboutLabel,
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.shield_outlined),
                      title: Text(context.copy.privacyLabel),
                      onTap: () => _showPlaceholderSheet(
                        context,
                        context.copy.privacyLabel,
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.description_outlined),
                      title: Text(context.copy.termsLabel),
                      onTap: () => _showPlaceholderSheet(
                        context,
                        context.copy.termsLabel,
                      ),
                    ),
                  ],
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
          );
        },
      ),
    );
  }
}

void _showPlaceholderSheet(BuildContext context, String title) {
  showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.copy.placeholderLegalBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    ),
  );
}

class _SettingsChoiceChip extends StatelessWidget {
  const _SettingsChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final Future<void> Function() onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        overflow: TextOverflow.ellipsis,
      ),
      selected: selected,
      onSelected: (_) {
        onSelected();
      },
    );
  }
}
