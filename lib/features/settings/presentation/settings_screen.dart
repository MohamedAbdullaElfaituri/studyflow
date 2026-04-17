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
    final explicitLanguagePreference = ref.watch(appLocalePreferenceProvider);

    return AppPage(
      child: data.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
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
              PageHeader(
                title: context.l10n.settingsTitle,
                subtitle: _settingsSubtitle(context),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Image.asset(
                            'assets/branding/app_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.appName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                _appSummary(context),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                      onSelected: () => _updateLanguage(
                        ref,
                        studyData,
                        'en',
                      ),
                    ),
                    _SettingsChoiceChip(
                      label: context.l10n.turkishLabel,
                      selected: selectedLanguage == 'tr',
                      onSelected: () => _updateLanguage(
                        ref,
                        studyData,
                        'tr',
                      ),
                    ),
                    _SettingsChoiceChip(
                      label: context.l10n.arabicLabel,
                      selected: selectedLanguage == 'ar',
                      onSelected: () => _updateLanguage(
                        ref,
                        studyData,
                        'ar',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: context.l10n.themeSectionTitle,
                subtitle: _themeSubtitle(context),
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
                      onSelected: () => _updateTheme(
                        ref,
                        studyData,
                        selectedLanguage,
                        'system',
                      ),
                    ),
                    _SettingsChoiceChip(
                      label: context.l10n.themeLight,
                      selected: selectedTheme == 'light',
                      onSelected: () => _updateTheme(
                        ref,
                        studyData,
                        selectedLanguage,
                        'light',
                      ),
                    ),
                    _SettingsChoiceChip(
                      label: context.l10n.themeDark,
                      selected: selectedTheme == 'dark',
                      onSelected: () => _updateTheme(
                        ref,
                        studyData,
                        selectedLanguage,
                        'dark',
                      ),
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
                child: OutlinedButton(
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go(LoginScreen.routePath);
                    }
                  },
                  child: Text(context.l10n.logoutAction),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateLanguage(
    WidgetRef ref,
    StudyDataState studyData,
    String code,
  ) async {
    await ref.read(studyDataControllerProvider.notifier).updateSettings(
          studyData.settings.copyWith(
            languageCode: code,
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<void> _updateTheme(
    WidgetRef ref,
    StudyDataState studyData,
    String languageCode,
    String themeMode,
  ) async {
    await ref.read(studyDataControllerProvider.notifier).updateSettings(
          studyData.settings.copyWith(
            languageCode: languageCode,
            themeMode: themeMode,
            updatedAt: DateTime.now(),
          ),
        );
  }

  String _settingsSubtitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' =>
        'Dil, gorunum, bildirimler ve erisilebilirlik ayarlarini duzenle.',
      'ar' => 'عدّل اللغة والمظهر والإشعارات وإعدادات سهولة الوصول.',
      _ => 'Adjust language, appearance, notifications, and accessibility.',
    };
  }

  String _themeSubtitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Acik, koyu veya sistem gorunumunu sec.',
      'ar' => 'اختر المظهر الفاتح أو الداكن أو مظهر النظام.',
      _ => 'Choose light, dark, or system appearance.',
    };
  }

  String _appSummary(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Sade bir calisma duzeni icin temel ayarlari burada tut.',
      'ar' => 'احتفظ هنا بالإعدادات الأساسية لتجربة دراسة بسيطة ومريحة.',
      _ => 'Keep the essentials here for a calm and simple study experience.',
    };
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
