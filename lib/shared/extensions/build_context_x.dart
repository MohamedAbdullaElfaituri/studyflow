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
        'email_confirmation_required' => _emailConfirmationRequiredMessage(),
        'google_oauth_incomplete' => _googleOAuthIncompleteMessage(),
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
      if (message.contains('email not confirmed')) {
        return _emailConfirmationRequiredMessage();
      }
      if (message.contains('provider is not enabled') ||
          message.contains('unsupported provider') ||
          message.contains('oauth')) {
        return _googleOAuthIncompleteMessage();
      }
      return l10n.genericErrorMessage;
    }

    return l10n.genericErrorMessage;
  }

  String _emailConfirmationRequiredMessage() {
    return switch (Localizations.localeOf(this).languageCode) {
      'ar' => 'تحقق من بريدك الإلكتروني لتأكيد الحساب ثم سجّل الدخول.',
      'tr' => 'Hesabini onaylamak icin e-postani kontrol et, sonra giris yap.',
      _ => 'Check your email to confirm your account, then sign in.',
    };
  }

  String _googleOAuthIncompleteMessage() {
    return switch (Localizations.localeOf(this).languageCode) {
      'ar' =>
        'لم يكتمل تسجيل الدخول عبر Google. تحقق من Client ID وClient Secret داخل Supabase، ومن رابط callback، ومن test users في Google Console.',
      'tr' =>
        'Google girisi tamamlanmadi. Supabase icindeki Client ID ve Client Secret ayarlarini, callback URL adresini ve Google test users listesini kontrol et.',
      _ =>
        'Google sign-in did not finish. Verify the Client ID and Client Secret in Supabase, the callback URL, and your Google test users.',
    };
  }
}
