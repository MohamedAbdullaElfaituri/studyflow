import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';

enum AuthErrorContext {
  signIn,
  signUp,
  forgotPassword,
  resetPassword,
  google,
  authFlow,
}

String authErrorCodeFrom(
  Object error, {
  AuthErrorContext? context,
}) {
  if (error is AppException) {
    if (error.code == 'missing_user' &&
        (context == AuthErrorContext.resetPassword ||
            context == AuthErrorContext.authFlow)) {
      return 'recovery_session_missing';
    }
    return error.code;
  }

  if (error is SocketException || error is TimeoutException) {
    return 'network_error';
  }

  final message = _normalizedErrorMessage(error);

  if (_containsAny(message, [
    'invalid login credentials',
    'invalid credentials',
    'invalid password',
  ])) {
    return 'invalid_credentials';
  }

  if (_containsAny(message, [
    'user already registered',
    'already registered',
    'already exists',
    'already in use',
  ])) {
    return 'duplicate_email';
  }

  if (_containsAny(message, [
    'invalid email',
    'email address',
    'email format',
  ])) {
    return 'invalid_email';
  }

  if (_containsAny(message, [
    'password should be at least',
    'password is too short',
    'weak password',
  ])) {
    return 'weak_password';
  }

  if (_containsAny(message, ['email not confirmed', 'email not verified'])) {
    return 'email_confirmation_required';
  }

  if (_containsAny(message, [
    'provider is not enabled',
    'unsupported provider',
  ])) {
    return 'google_oauth_incomplete';
  }

  if (_containsAny(message, [
    'rate limit',
    'too many requests',
    'security purposes',
    'wait a few seconds',
  ])) {
    return 'rate_limited';
  }

  if (_containsAny(message, [
    'network request failed',
    'failed host lookup',
    'connection refused',
    'connection closed',
    'timed out',
    'timeout',
    'socketexception',
  ])) {
    return 'network_error';
  }

  if (_looksLikeRecoveryFailure(message, context)) {
    if (_containsAny(message, ['expired', 'has expired'])) {
      return 'recovery_link_expired';
    }
    if (_containsAny(message, [
      'session missing',
      'auth session missing',
      'session not found',
      'no current session',
      'no session',
    ])) {
      return 'recovery_session_missing';
    }
    return 'recovery_link_invalid';
  }

  if (context == AuthErrorContext.google && message.contains('oauth')) {
    return 'google_oauth_incomplete';
  }

  return 'unknown_auth_error';
}

String? authFlowNoticeCodeFrom(Object error) {
  final code = authErrorCodeFrom(
    error,
    context: AuthErrorContext.authFlow,
  );

  return switch (code) {
    'recovery_link_invalid' => code,
    'recovery_link_expired' => code,
    'recovery_session_missing' => code,
    'google_oauth_incomplete' => code,
    'network_error' => code,
    'rate_limited' => code,
    'unknown_auth_error' => 'auth_flow_failed',
    _ => code,
  };
}

String _normalizedErrorMessage(Object error) {
  if (error is AuthException) {
    return error.message.toLowerCase().trim();
  }

  return error.toString().toLowerCase().trim();
}

bool _containsAny(String text, List<String> values) {
  return values.any(text.contains);
}

bool _looksLikeRecoveryFailure(
  String message,
  AuthErrorContext? context,
) {
  if (context != AuthErrorContext.resetPassword &&
      context != AuthErrorContext.authFlow) {
    return false;
  }

  return _containsAny(message, [
    'token',
    'otp',
    'recovery',
    'pkce',
    'code verifier',
    'code challenge',
    'flow state',
    'session missing',
    'session not found',
    'auth session missing',
    'email link',
  ]);
}
