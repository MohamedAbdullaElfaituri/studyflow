import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    final explicitLanguagePreference = ref.watch(appLocalePreferenceProvider);

    return AppPage(
      child: data.when(
        loading: () => const LoadingColumn(itemCount: 4),
        error: (error, _) => ErrorStateCard(
          message: context.resolveError(error),
          onRetry: () => ref.read(studyDataControllerProvider.notifier).refresh(),
        ),
        data: (studyData) {
          const supportedLanguages = {'en', 'tr', 'ar'};
          const supportedThemes = {'system', 'light', 'dark'};
          final selectedLanguage = supportedLanguages.contains(
            explicitLanguagePreference,
          )
              ? explicitLanguagePreference!
              : supportedLanguages.contains(studyData.settings.languageCode)
                  ? studyData.settings.languageCode
                  : 'en';
          final selectedTheme = supportedThemes.contains(
            studyData.settings.themeMode,
          )
              ? studyData.settings.themeMode
              : 'system';

          return ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: Navigator.of(context).pop,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Hero(
                      tag: 'settings_logo',
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SvgPicture.asset(
                          'assets/branding/app_logo.svg',
                          height: 48,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Text(
                        context.l10n.settingsTitle,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: context.l10n.languageSectionTitle,
                subtitle: context.copy.chooseLanguageSubtitle,
              ),
              const SizedBox(height: AppSpacing.md),
              SectionCard(
                child: Wrap(
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
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: context.l10n.themeSectionTitle,
              ),
              const SizedBox(height: AppSpacing.md),
              SectionCard(
                child: Wrap(
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
                                languageCode: selectedLanguage,
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
                                languageCode: selectedLanguage,
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
                                languageCode: selectedLanguage,
                                themeMode: 'dark',
                                updatedAt: DateTime.now(),
                              ),
                            );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: context.copy.notificationPermissionsAction,
                subtitle: context.copy.notificationPermissionsHint,
              ),
              const SizedBox(height: AppSpacing.md),
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
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: context.copy.accessibilityModeTitle,
                subtitle: context.copy.accessibilityModeDescription,
              ),
              const SizedBox(height: AppSpacing.md),
              SectionCard(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.accessibility_new_rounded),
                  value: studyData.settings.accessibilityMode,
                  title: Text(context.copy.accessibilityModeTitle),
                  subtitle: Text(context.copy.accessibilityModeDescription),
                  onChanged: (value) async {
                    await ref
                        .read(studyDataControllerProvider.notifier)
                        .updateSettings(
                          studyData.settings.copyWith(
                            languageCode: selectedLanguage,
                            accessibilityMode: value,
                            updatedAt: DateTime.now(),
                          ),
                        );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const AppLogo(size: 42),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            context.l10n.appName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    OutlinedButton(
                      onPressed: () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .signOut();
                        if (context.mounted) {
                          context.go(LoginScreen.routePath);
                        }
                      },
                      child: Text(context.l10n.logoutAction),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
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
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}
