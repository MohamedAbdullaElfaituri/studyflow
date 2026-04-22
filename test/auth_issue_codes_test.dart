import 'package:flutter_test/flutter_test.dart';
import 'package:studyflow/core/errors/app_exception.dart';
import 'package:studyflow/shared/utils/auth_issue_codes.dart';

void main() {
  test('maps invalid credentials errors for sign-in', () {
    final code = authErrorCodeFrom(
      Exception('Invalid login credentials'),
      context: AuthErrorContext.signIn,
    );

    expect(code, 'invalid_credentials');
  });

  test('maps missing reset user to recovery session missing', () {
    final code = authErrorCodeFrom(
      const AppException('missing_user'),
      context: AuthErrorContext.resetPassword,
    );

    expect(code, 'recovery_session_missing');
  });

  test('maps expired recovery links for auth flow notices', () {
    final code = authFlowNoticeCodeFrom(
      Exception('Token has expired or is invalid'),
    );

    expect(code, 'recovery_link_expired');
  });

  test('maps network failures consistently', () {
    final code = authErrorCodeFrom(
      Exception('Failed host lookup'),
      context: AuthErrorContext.forgotPassword,
    );

    expect(code, 'network_error');
  });
}
