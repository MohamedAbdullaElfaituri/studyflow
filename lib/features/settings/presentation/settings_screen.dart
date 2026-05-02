import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_copy.dart';
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
    final explicitThemePreference = ref.watch(appThemePreferenceProvider);
    final notificationPermission = ref.watch(notificationPermissionProvider);
    final reminderService = ref.watch(reminderServiceProvider);

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
          final selectedTheme =
              supportedThemes.contains(explicitThemePreference)
                  ? explicitThemePreference!
                  : supportedThemes.contains(studyData.settings.themeMode)
                      ? studyData.settings.themeMode
                      : 'system';
          final systemNotificationsEnabled =
              notificationPermission.valueOrNull ??
                  studyData.settings.notificationsEnabled;
          final appNotificationsEnabled =
              studyData.settings.notificationsEnabled;
          final effectiveNotificationsEnabled = reminderService.isSupported &&
              appNotificationsEnabled &&
              systemNotificationsEnabled;

          return ListView(
            children: [
              PageHeader(
                title: context.l10n.settingsTitle,
                subtitle: _settingsSubtitle(context),
              ),
              const SizedBox(height: AppSpacing.xl),
              _SettingsPanel(
                title: context.l10n.languageSectionTitle,
                subtitle: _languageSubtitle(context),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _SettingsChoiceChip(
                        label: 'EN',
                        semanticLabel: context.l10n.englishLabel,
                        selected: selectedLanguage == 'en',
                        onSelected: () => _updateLanguage(
                          context,
                          ref,
                          studyData,
                          'en',
                        ),
                      ),
                      _SettingsChoiceChip(
                        label: 'TR',
                        semanticLabel: context.l10n.turkishLabel,
                        selected: selectedLanguage == 'tr',
                        onSelected: () => _updateLanguage(
                          context,
                          ref,
                          studyData,
                          'tr',
                        ),
                      ),
                      _SettingsChoiceChip(
                        label: 'AR',
                        semanticLabel: context.l10n.arabicLabel,
                        selected: selectedLanguage == 'ar',
                        onSelected: () => _updateLanguage(
                          context,
                          ref,
                          studyData,
                          'ar',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SettingsPanel(
                title: context.l10n.themeSectionTitle,
                subtitle: _themeSubtitle(context),
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _SettingsChoiceChip(
                      label: context.l10n.themeSystem,
                      selected: selectedTheme == 'system',
                      onSelected: () => _updateTheme(
                        context,
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
                        context,
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
                        context,
                        ref,
                        studyData,
                        selectedLanguage,
                        'dark',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SettingsPanel(
                title: _notificationsSectionTitle(context),
                subtitle: _notificationsSectionSubtitle(
                  context,
                  isSupported: reminderService.isSupported,
                  appEnabled: appNotificationsEnabled,
                  systemEnabled: systemNotificationsEnabled,
                  isLoading: notificationPermission.isLoading,
                ),
                child: Column(
                  children: [
                    _SettingsToggleTile(
                      icon: Icons.notifications_active_outlined,
                      title: _allowNotificationsLabel(context),
                      subtitle: _notificationsTileSubtitle(
                        context,
                        isSupported: reminderService.isSupported,
                        appEnabled: appNotificationsEnabled,
                        systemEnabled: systemNotificationsEnabled,
                      ),
                      value: effectiveNotificationsEnabled,
                      onChanged: (value) => _toggleNotifications(
                        context,
                        ref,
                        studyData,
                        enabled: value,
                        systemEnabled: systemNotificationsEnabled,
                      ),
                    ),
                    if (effectiveNotificationsEnabled) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Divider(height: 1),
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: FilledButton.tonalIcon(
                          onPressed: () async {
                            await ref.read(reminderServiceProvider).showPreview(
                                  id: 7,
                                  title: context.l10n.notificationPreviewTitle,
                                  body: context.l10n.notificationPreviewBody,
                                );
                          },
                          icon: const Icon(Icons.visibility_outlined),
                          label: Text(context.l10n.previewNotificationAction),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SettingsPanel(
                title: _accessibilitySectionTitle(context),
                subtitle: _accessibilitySectionSubtitle(context),
                child: _SettingsToggleTile(
                  icon: Icons.accessibility_new_rounded,
                  title: _accessibilityModeTitle(context),
                  subtitle: _accessibilityModeSubtitle(context),
                  value: studyData.settings.accessibilityMode,
                  onChanged: (value) => _toggleAccessibility(
                    context,
                    ref,
                    studyData,
                    selectedLanguage,
                    value,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionCard(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go(LoginScreen.routePath);
                    }
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(context.l10n.logoutAction),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateLanguage(
    BuildContext context,
    WidgetRef ref,
    StudyDataState studyData,
    String code,
  ) async {
    try {
      await ref.read(studyDataControllerProvider.notifier).updateSettings(
            studyData.settings.copyWith(
              languageCode: code,
              updatedAt: DateTime.now(),
            ),
          );
      if (context.mounted) {
        context.showSuccessNotification(
          AppCopy.of(Locale(code)).languageUpdatedMessage,
        );
      }
    } catch (error) {
      if (context.mounted) {
        context.showErrorNotification(context.resolveError(error));
      }
    }
  }

  Future<void> _updateTheme(
    BuildContext context,
    WidgetRef ref,
    StudyDataState studyData,
    String languageCode,
    String themeMode,
  ) async {
    try {
      await ref.read(studyDataControllerProvider.notifier).updateSettings(
            studyData.settings.copyWith(
              languageCode: languageCode,
              themeMode: themeMode,
              updatedAt: DateTime.now(),
            ),
          );
    } catch (error) {
      if (context.mounted) {
        context.showErrorNotification(context.resolveError(error));
      }
    }
  }

  Future<void> _toggleNotifications(
    BuildContext context,
    WidgetRef ref,
    StudyDataState studyData, {
    required bool enabled,
    required bool systemEnabled,
  }) async {
    final reminderService = ref.read(reminderServiceProvider);
    final notifier = ref.read(studyDataControllerProvider.notifier);

    try {
      if (!enabled) {
        await reminderService.cancelAll();
        await notifier.updateSettings(
          studyData.settings.copyWith(
            notificationsEnabled: false,
            updatedAt: DateTime.now(),
          ),
        );
        ref.invalidate(notificationPermissionProvider);
        if (context.mounted) {
          context.showAppSnackBar(_notificationsPausedMessage(context));
        }
        return;
      }

      final granted =
          systemEnabled ? true : await reminderService.requestPermissions();
      await notifier.updateSettings(
        studyData.settings.copyWith(
          notificationsEnabled: granted,
          updatedAt: DateTime.now(),
        ),
      );
      ref.invalidate(notificationPermissionProvider);

      if (!context.mounted) {
        return;
      }

      if (granted) {
        context.showSuccessNotification(_notificationsEnabledMessage(context));
        return;
      }

      context.showErrorNotification(
        reminderService.isSupported
            ? _notificationsDeniedMessage(context)
            : _notificationsUnsupportedMessage(context),
      );
    } catch (error) {
      if (context.mounted) {
        context.showErrorNotification(context.resolveError(error));
      }
    }
  }

  Future<void> _toggleAccessibility(
    BuildContext context,
    WidgetRef ref,
    StudyDataState studyData,
    String languageCode,
    bool value,
  ) async {
    try {
      await ref.read(studyDataControllerProvider.notifier).updateSettings(
            studyData.settings.copyWith(
              languageCode: languageCode,
              accessibilityMode: value,
              updatedAt: DateTime.now(),
            ),
          );
      if (context.mounted) {
        context.showSuccessNotification(
          context.copy.accessibilityUpdatedMessage(enabled: value),
        );
      }
    } catch (error) {
      if (context.mounted) {
        context.showErrorNotification(context.resolveError(error));
      }
    }
  }

  String _settingsSubtitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Sadece gerekli ayarları tut, dili ve görünümü rahatça değiştir.',
      'ar' => 'احتفظ بالإعدادات الأساسية فقط، وبدّل اللغة والمظهر بسهولة.',
      _ =>
        'Keep only the essentials here and adjust language and appearance quickly.',
    };
  }

  String _languageSubtitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Uygulama düzenini bozmadan dili anında değiştir.',
      'ar' => 'بدّل لغة التطبيق مباشرة من دون التأثير على ترتيب الواجهة.',
      _ => 'Switch the app language instantly without affecting the layout.',
    };
  }

  String _themeSubtitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Açık, koyu veya sistem görünümünü seç.',
      'ar' => 'اختر المظهر الفاتح أو الداكن أو اجعل التطبيق يتبع النظام.',
      _ => 'Choose light, dark, or follow the system appearance.',
    };
  }

  String _notificationsSectionTitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Bildirimler',
      'ar' => 'الإشعارات',
      _ => 'Notifications',
    };
  }

  String _allowNotificationsLabel(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Bildirimlere izin ver',
      'ar' => 'السماح بالإشعارات',
      _ => 'Allow notifications',
    };
  }

  String _notificationsSectionSubtitle(
    BuildContext context, {
    required bool isSupported,
    required bool appEnabled,
    required bool systemEnabled,
    required bool isLoading,
  }) {
    if (isLoading) {
      return switch (Localizations.localeOf(context).languageCode) {
        'tr' => 'Bildirim durumu kontrol ediliyor.',
        'ar' => 'جارٍ التحقق من حالة الإشعارات.',
        _ => 'Checking notification availability.',
      };
    }

    if (!isSupported) {
      return _notificationsUnsupportedMessage(context);
    }

    if (appEnabled && systemEnabled) {
      return switch (Localizations.localeOf(context).languageCode) {
        'tr' => 'Odak, görev ve çalışma hatırlatmaları hazır.',
        'ar' => 'تم تفعيل تذكيرات التركيز والمهام والدراسة.',
        _ => 'Focus, task, and study reminders are ready to reach you.',
      };
    }

    if (appEnabled && !systemEnabled) {
      return switch (Localizations.localeOf(context).languageCode) {
        'tr' => 'Uygulama açık, ancak sistem izni hâlâ kapalı.',
        'ar' => 'الإعداد داخل التطبيق مفعّل، لكن إذن النظام ما زال مغلقاً.',
        _ => 'The app setting is on, but system permission is still blocked.',
      };
    }

    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Sadece ihtiyaç duyduğunda aç ve dikkat dağıtmadan kullan.',
      'ar' => 'فعّلها فقط عندما تحتاج التذكيرات، وأبقِ التجربة هادئة.',
      _ => 'Turn this on only when you want reminders without extra clutter.',
    };
  }

  String _notificationsTileSubtitle(
    BuildContext context, {
    required bool isSupported,
    required bool appEnabled,
    required bool systemEnabled,
  }) {
    if (!isSupported) {
      return _notificationsUnsupportedMessage(context);
    }

    if (appEnabled && systemEnabled) {
      return switch (Localizations.localeOf(context).languageCode) {
        'tr' => 'Hatırlatmalar etkin.',
        'ar' => 'التذكيرات مفعّلة.',
        _ => 'Reminders are enabled.',
      };
    }

    if (appEnabled && !systemEnabled) {
      return switch (Localizations.localeOf(context).languageCode) {
        'tr' => 'İzni tamamlamak için sistemi onayla.',
        'ar' => 'أكمل إذن النظام ليعمل هذا الخيار.',
        _ => 'Approve the system permission to finish enabling this.',
      };
    }

    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Hatırlatmalar kapalı.',
      'ar' => 'التذكيرات متوقفة.',
      _ => 'Reminders are off.',
    };
  }

  String _accessibilitySectionTitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Erişilebilirlik',
      'ar' => 'إمكانية الوصول',
      _ => 'Accessibility',
    };
  }

  String _accessibilitySectionSubtitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Okumayı kolaylaştır ve gereksiz hareketi azalt.',
      'ar' => 'اجعل القراءة أوضح وقلّل الحركة غير الضرورية في الواجهة.',
      _ => 'Make reading easier and reduce unnecessary motion across the app.',
    };
  }

  String _accessibilityModeTitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Erişilebilirlik modu',
      'ar' => 'وضع إمكانية الوصول',
      _ => 'Accessibility mode',
    };
  }

  String _accessibilityModeSubtitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Animasyonları azaltır ve metni biraz daha rahat hale getirir.',
      'ar' => 'يقلّل الحركة ويجعل النص أكثر راحة للقراءة قليلاً.',
      _ => 'Reduces motion and slightly improves reading comfort.',
    };
  }

  String _notificationsEnabledMessage(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Bildirimler açıldı.',
      'ar' => 'تم تفعيل الإشعارات.',
      _ => 'Notifications were enabled.',
    };
  }

  String _notificationsDeniedMessage(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Bildirim izni verilmedi.',
      'ar' => 'لم يتم منح إذن الإشعارات.',
      _ => 'Notification permission was not granted.',
    };
  }

  String _notificationsPausedMessage(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Bildirimler uygulama içinde duraklatıldı.',
      'ar' => 'تم إيقاف الإشعارات من داخل التطبيق.',
      _ => 'Notifications were paused inside the app.',
    };
  }

  String _notificationsUnsupportedMessage(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Bildirimler bu platformda kullanılamıyor.',
      'ar' => 'الإشعارات غير متاحة على هذه المنصة.',
      _ => 'Notifications are not available on this platform.',
    };
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _SettingsToggleTile extends StatelessWidget {
  const _SettingsToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: scheme.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SettingsChoiceChip extends StatelessWidget {
  const _SettingsChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.semanticLabel,
  });

  final String label;
  final bool selected;
  final Future<void> Function() onSelected;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel ?? label,
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: selected ? null : (_) => onSelected(),
      ),
    );
  }
}
