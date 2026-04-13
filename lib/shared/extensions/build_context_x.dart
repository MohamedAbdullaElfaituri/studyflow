import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../core/localization/app_copy.dart';
import '../../core/localization/generated/app_localizations.dart';
import '../../core/widgets/app_notification.dart';

extension BuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  AppCopy get copy => AppCopy.of(Localizations.localeOf(this));

  void showAppSnackBar(
    String message, {
    AppNotificationTone tone = AppNotificationTone.info,
    AppNotificationPosition? position,
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    AppNotificationController.show(
      context: this,
      message: message,
      title: title,
      tone: tone,
      position: position ??
          switch (tone) {
            AppNotificationTone.error => AppNotificationPosition.top,
            AppNotificationTone.warning => AppNotificationPosition.top,
            AppNotificationTone.success => AppNotificationPosition.bottom,
            AppNotificationTone.info => AppNotificationPosition.bottom,
          },
      duration: duration,
    );
  }

  void showSuccessNotification(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    showAppSnackBar(
      message,
      title: title,
      tone: AppNotificationTone.success,
      duration: duration,
    );
  }

  void showErrorNotification(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 5),
  }) {
    showAppSnackBar(
      message,
      title: title,
      tone: AppNotificationTone.error,
      duration: duration,
    );
  }

  String? validationMessage(String? code, {int minLength = 6}) {
    if (code == null) {
      return null;
    }

    return switch (code) {
      'required' => l10n.validationRequired,
      'invalid_email' => l10n.validationInvalidEmail,
      'min_length' => l10n.validationMinLength(minLength),
      _ => l10n.genericErrorMessage,
    };
  }

  String resolveError(Object error) {
    if (error is AppException) {
      return switch (error.code) {
        'user_not_found' => l10n.errorUserNotFound,
        'invalid_credentials' => l10n.errorInvalidCredentials,
        'duplicate_email' => l10n.errorDuplicateEmail,
        'missing_user' => l10n.errorMissingUser,
        _ => l10n.genericErrorMessage,
      };
    }

    if (error is AuthException) {
      final message = error.message.toLowerCase();
      if (message.contains('invalid login credentials')) {
        return l10n.errorInvalidCredentials;
      }
      if (message.contains('user already registered')) {
        return l10n.errorDuplicateEmail;
      }
      if (message.contains('invalid email') ||
          message.contains('email address')) {
        return l10n.validationInvalidEmail;
      }
      if (message.contains('password should be at least')) {
        return l10n.validationMinLength(6);
      }
      return l10n.genericErrorMessage;
    }

    return l10n.genericErrorMessage;
  }
}
