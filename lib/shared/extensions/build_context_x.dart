import 'package:flutter/material.dart';

import '../../core/errors/app_exception.dart';
import '../../core/localization/app_copy.dart';
import '../../core/localization/generated/app_localizations.dart';

extension BuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  AppCopy get copy => AppCopy.of(Localizations.localeOf(this));

  void showAppSnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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

    return l10n.genericErrorMessage;
  }
}
