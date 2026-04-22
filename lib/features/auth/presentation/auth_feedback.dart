import 'package:flutter/widgets.dart';

import '../../../shared/utils/auth_issue_codes.dart';

enum AuthFeedbackTone { error, info, success }

enum AuthFieldTarget {
  none,
  email,
  password,
  fullName,
  confirmPassword,
}

class AuthFeedbackMessage {
  const AuthFeedbackMessage({
    required this.title,
    required this.message,
    this.tone = AuthFeedbackTone.error,
    this.field = AuthFieldTarget.none,
    this.fieldMessage,
    this.code,
  });

  final String title;
  final String message;
  final AuthFeedbackTone tone;
  final AuthFieldTarget field;
  final String? fieldMessage;
  final String? code;

  bool get isRecoveryIssue =>
      code == 'recovery_link_invalid' ||
      code == 'recovery_link_expired' ||
      code == 'recovery_session_missing';
}

AuthFeedbackMessage resolveAuthFeedback(
  BuildContext context,
  Object error, {
  required AuthErrorContext intent,
}) {
  final code = authErrorCodeFrom(error, context: intent);
  return feedbackForAuthCode(
    context,
    code,
    intent: intent,
  );
}

AuthFeedbackMessage feedbackForAuthNotice(
  BuildContext context,
  String code,
) {
  return feedbackForAuthCode(
    context,
    code,
    intent: AuthErrorContext.authFlow,
  );
}

AuthFeedbackMessage feedbackForAuthCode(
  BuildContext context,
  String code, {
  required AuthErrorContext intent,
}) {
  return switch (code) {
    'user_not_found' => _userNotFoundFeedback(context, intent),
    'invalid_credentials' => _invalidCredentialsFeedback(context),
    'duplicate_email' => _duplicateEmailFeedback(context),
    'invalid_email' => _invalidEmailFeedback(context),
    'weak_password' => _weakPasswordFeedback(context),
    'email_confirmation_required' =>
      _emailConfirmationRequiredFeedback(context),
    'google_oauth_incomplete' => _googleFeedback(context),
    'network_error' => _networkFeedback(context),
    'rate_limited' => _rateLimitedFeedback(context),
    'recovery_link_invalid' => _recoveryInvalidFeedback(context),
    'recovery_link_expired' => _recoveryExpiredFeedback(context),
    'recovery_session_missing' => _recoverySessionMissingFeedback(context),
    'demo_mode_unavailable' => _demoModeUnavailableFeedback(context),
    'auth_flow_failed' => _authFlowFailedFeedback(context),
    _ => _genericAuthFeedback(context, intent),
  };
}

AuthFeedbackMessage signUpConfirmationFeedback(
  BuildContext context,
  String email,
) {
  return AuthFeedbackMessage(
    title: _pick(
      context,
      en: 'Check your email',
      tr: 'E-postani kontrol et',
      ar: 'تحقق من بريدك الإلكتروني',
    ),
    message: _pick(
      context,
      en: 'We sent a confirmation link to $email. Open it first, then return here and sign in.',
      tr: '$email adresine onay baglantisi gonderdik. Once e-postayi onayla, sonra buraya donup giris yap.',
      ar: 'أرسلنا رابط تأكيد إلى $email. افتحه أولاً، ثم ارجع إلى هنا وسجّل الدخول.',
    ),
    tone: AuthFeedbackTone.success,
    code: 'signup_confirmation_sent',
  );
}

AuthFeedbackMessage passwordResetEmailSentFeedback(
  BuildContext context,
  String email,
) {
  return AuthFeedbackMessage(
    title: _pick(
      context,
      en: 'Reset email sent',
      tr: 'Sifirlama e-postasi gonderildi',
      ar: 'تم إرسال رسالة إعادة التعيين',
    ),
    message: _pick(
      context,
      en: 'If $email belongs to an account, check your inbox and spam folder, then open the newest reset link.',
      tr: 'Eger $email bir hesaba bagliysa, gelen kutunu ve spam klasorunu kontrol et, sonra en yeni sifirlama baglantisini ac.',
      ar: 'إذا كان $email مرتبطاً بحساب، فتفقد الوارد والرسائل غير المرغوبة ثم افتح أحدث رابط لإعادة التعيين.',
    ),
    tone: AuthFeedbackTone.success,
    code: 'password_reset_email_sent',
  );
}

String requestNewResetLinkLabel(BuildContext context) {
  return _pick(
    context,
    en: 'Request a new reset link',
    tr: 'Yeni sifirlama baglantisi iste',
    ar: 'اطلب رابط إعادة تعيين جديد',
  );
}

AuthFeedbackMessage _userNotFoundFeedback(
  BuildContext context,
  AuthErrorContext intent,
) {
  return switch (intent) {
    AuthErrorContext.forgotPassword => AuthFeedbackMessage(
        title: _pick(
          context,
          en: 'Account not found',
          tr: 'Hesap bulunamadi',
          ar: 'الحساب غير موجود',
        ),
        message: _pick(
          context,
          en: 'We could not find an account with this email. Check the address or create a new account first.',
          tr: 'Bu e-posta ile bir hesap bulamadik. Adresi kontrol et ya da once yeni bir hesap olustur.',
          ar: 'لم نعثر على حساب بهذا البريد. راجع العنوان أو أنشئ حساباً جديداً أولاً.',
        ),
        field: AuthFieldTarget.email,
        fieldMessage: _pick(
          context,
          en: 'No account was found for this email.',
          tr: 'Bu e-posta icin hesap bulunamadi.',
          ar: 'لا يوجد حساب لهذا البريد.',
        ),
        code: 'user_not_found',
      ),
    _ => AuthFeedbackMessage(
        title: _pick(
          context,
          en: 'Account not found',
          tr: 'Hesap bulunamadi',
          ar: 'الحساب غير موجود',
        ),
        message: _pick(
          context,
          en: 'There is no account with this email yet. Double-check the address or create a new account.',
          tr: 'Bu e-posta ile henuz bir hesap yok. Adresi tekrar kontrol et ya da yeni hesap olustur.',
          ar: 'لا يوجد حساب بهذا البريد حتى الآن. راجع العنوان أو أنشئ حساباً جديداً.',
        ),
        field: AuthFieldTarget.email,
        fieldMessage: _pick(
          context,
          en: 'We could not find this email.',
          tr: 'Bu e-postayi bulamadik.',
          ar: 'لم نعثر على هذا البريد.',
        ),
        code: 'user_not_found',
      ),
  };
}

AuthFeedbackMessage _invalidCredentialsFeedback(BuildContext context) {
  return AuthFeedbackMessage(
    title: _pick(
      context,
      en: 'Incorrect password or email',
      tr: 'E-posta veya sifre yanlis',
      ar: 'البريد أو كلمة المرور غير صحيحة',
    ),
    message: _pick(
      context,
      en: 'Check your email and password, then try again. If you forgot your password, use the reset option below.',
      tr: 'E-posta ve sifreni kontrol edip tekrar dene. Sifreni unuttuysan asagidaki sifirlama secenegini kullan.',
      ar: 'راجع البريد وكلمة المرور ثم حاول مرة أخرى. إذا نسيت كلمة المرور فاستخدم خيار إعادة التعيين الموجود بالأسفل.',
    ),
    field: AuthFieldTarget.password,
    fieldMessage: _pick(
      context,
      en: 'This password does not match the account.',
      tr: 'Bu sifre hesapla eslesmiyor.',
      ar: 'كلمة المرور هذه لا تطابق الحساب.',
    ),
    code: 'invalid_credentials',
  );
}

AuthFeedbackMessage _duplicateEmailFeedback(BuildContext context) {
  return AuthFeedbackMessage(
    title: _pick(
      context,
      en: 'Email already in use',
      tr: 'E-posta zaten kullaniliyor',
      ar: 'البريد مستخدم بالفعل',
    ),
    message: _pick(
      context,
      en: 'This email is already registered. Sign in instead, or reset the password if you no longer remember it.',
      tr: 'Bu e-posta zaten kayitli. Bunun yerine giris yap ya da sifreni hatirlamiyorsan sifirla.',
      ar: 'هذا البريد مسجل بالفعل. سجّل الدخول بدلاً من ذلك، أو أعد تعيين كلمة المرور إذا لم تعد تتذكرها.',
    ),
    field: AuthFieldTarget.email,
    fieldMessage: _pick(
      context,
      en: 'This email is already registered.',
      tr: 'Bu e-posta zaten kayitli.',
      ar: 'هذا البريد مسجل بالفعل.',
    ),
    code: 'duplicate_email',
  );
}

AuthFeedbackMessage _invalidEmailFeedback(BuildContext context) {
  return AuthFeedbackMessage(
    title: _pick(
      context,
      en: 'Email format is not valid',
      tr: 'E-posta formati gecersiz',
      ar: 'صيغة البريد غير صحيحة',
    ),
    message: _pick(
      context,
      en: 'Enter a complete email address like name@example.com, then try again.',
      tr: 'name@example.com gibi tam bir e-posta adresi gir ve tekrar dene.',
      ar: 'أدخل بريداً إلكترونياً كاملاً مثل name@example.com ثم حاول مرة أخرى.',
    ),
    field: AuthFieldTarget.email,
    fieldMessage: _pick(
      context,
      en: 'Enter a valid email address.',
      tr: 'Gecerli bir e-posta adresi gir.',
      ar: 'أدخل بريداً إلكترونياً صالحاً.',
    ),
    code: 'invalid_email',
  );
}

AuthFeedbackMessage _weakPasswordFeedback(BuildContext context) {
  return AuthFeedbackMessage(
    title: _pick(
      context,
      en: 'Password is too weak',
      tr: 'Sifre cok zayif',
      ar: 'كلمة المرور ضعيفة',
    ),
    message: _pick(
      context,
      en: 'Use at least 6 characters. A longer password with letters and numbers will be more secure.',
      tr: 'En az 6 karakter kullan. Harf ve rakam iceren daha uzun bir sifre daha guvenlidir.',
      ar: 'استخدم 6 أحرف على الأقل. ستكون كلمة المرور الأطول التي تحتوي على حروف وأرقام أكثر أماناً.',
    ),
    field: AuthFieldTarget.password,
    fieldMessage: _pick(
      context,
      en: 'Use a stronger password.',
      tr: 'Daha guclu bir sifre kullan.',
      ar: 'استخدم كلمة مرور أقوى.',
    ),
    code: 'weak_password',
  );
}

AuthFeedbackMessage _emailConfirmationRequiredFeedback(BuildContext context) {
  return AuthFeedbackMessage(
    title: _pick(
      context,
      en: 'Confirm your email first',
      tr: 'Once e-postani onayla',
      ar: 'أكّد بريدك أولاً',
    ),
    message: _pick(
      context,
      en: 'Open the confirmation email we sent you, complete the verification, then return here and sign in.',
      tr: 'Gonderdigimiz onay e-postasini ac, dogrulamayi tamamla, sonra buraya donup giris yap.',
      ar: 'افتح رسالة التأكيد التي أرسلناها لك، وأكمل التحقق، ثم ارجع إلى هنا وسجّل الدخول.',
    ),
    field: AuthFieldTarget.email,
    code: 'email_confirmation_required',
  );
}

AuthFeedbackMessage _googleFeedback(BuildContext context) {
  return AuthFeedbackMessage(
    title: _pick(
      context,
      en: 'Google sign-in was not completed',
      tr: 'Google ile giris tamamlanamadi',
      ar: 'لم يكتمل تسجيل الدخول عبر Google',
    ),
    message: _pick(
      context,
      en: 'Try the Google flow again. If it still fails, use email and password for now.',
      tr: 'Google akisini tekrar dene. Sorun devam ederse simdilik e-posta ve sifre kullan.',
      ar: 'جرّب مسار Google مرة أخرى. وإذا استمرت المشكلة فاستخدم البريد وكلمة المرور حالياً.',
    ),
    code: 'google_oauth_incomplete',
  );
}

AuthFeedbackMessage _networkFeedback(BuildContext context) {
  return AuthFeedbackMessage(
    title: _pick(
      context,
      en: 'Connection problem',
      tr: 'Baglanti sorunu',
      ar: 'مشكلة في الاتصال',
    ),
    message: _pick(
      context,
      en: 'Check your internet connection, then try again.',
      tr: 'Internet baglantini kontrol edip tekrar dene.',
      ar: 'تحقق من اتصال الإنترنت ثم حاول مرة أخرى.',
    ),
    code: 'network_error',
  );
}

AuthFeedbackMessage _rateLimitedFeedback(BuildContext context) {
  return AuthFeedbackMessage(
    title: _pick(
      context,
      en: 'Too many attempts',
      tr: 'Cok fazla deneme',
      ar: 'محاولات كثيرة جداً',
    ),
    message: _pick(
      context,
      en: 'Please wait a little before trying again or requesting another email.',
      tr: 'Tekrar denemeden veya yeni e-posta istemeden once biraz bekle.',
      ar: 'يرجى الانتظار قليلاً قبل المحاولة مرة أخرى أو طلب رسالة جديدة.',
    ),
    code: 'rate_limited',
  );
}

AuthFeedbackMessage _recoveryInvalidFeedback(BuildContext context) {
  return AuthFeedbackMessage(
    title: _pick(
      context,
      en: 'Reset link is not valid',
      tr: 'Sifirlama baglantisi gecersiz',
      ar: 'رابط إعادة التعيين غير صالح',
    ),
    message: _pick(
      context,
      en: 'This reset link could not be verified. Request a new password reset email, then open the newest link.',
      tr: 'Bu sifirlama baglantisi dogrulanamadi. Yeni bir sifirlama e-postasi iste ve en yeni baglantiyi ac.',
      ar: 'تعذر التحقق من رابط إعادة التعيين هذا. اطلب رسالة إعادة تعيين جديدة ثم افتح أحدث رابط.',
    ),
    code: 'recovery_link_invalid',
  );
}

AuthFeedbackMessage _recoveryExpiredFeedback(BuildContext context) {
  return AuthFeedbackMessage(
    title: _pick(
      context,
      en: 'Reset link has expired',
      tr: 'Sifirlama baglantisinin suresi doldu',
      ar: 'انتهت صلاحية رابط إعادة التعيين',
    ),
    message: _pick(
      context,
      en: 'Request a new password reset email and use the latest link as soon as it arrives.',
      tr: 'Yeni bir sifirlama e-postasi iste ve geldikten sonra en yeni baglantiyi hemen kullan.',
      ar: 'اطلب رسالة إعادة تعيين جديدة واستخدم أحدث رابط فور وصوله.',
    ),
    code: 'recovery_link_expired',
  );
}

AuthFeedbackMessage _recoverySessionMissingFeedback(BuildContext context) {
  return AuthFeedbackMessage(
    title: _pick(
      context,
      en: 'Reset session has ended',
      tr: 'Sifirlama oturumu sona erdi',
      ar: 'انتهت جلسة إعادة التعيين',
    ),
    message: _pick(
      context,
      en: 'The recovery session is no longer active. Request a new reset link, then return from the newest email.',
      tr: 'Kurtarma oturumu artik aktif degil. Yeni bir sifirlama baglantisi iste ve en yeni e-postadan geri don.',
      ar: 'جلسة الاستعادة لم تعد نشطة. اطلب رابط إعادة تعيين جديداً ثم ارجع من أحدث رسالة بريد.',
    ),
    code: 'recovery_session_missing',
  );
}

AuthFeedbackMessage _demoModeUnavailableFeedback(BuildContext context) {
  return AuthFeedbackMessage(
    title: _pick(
      context,
      en: 'Demo mode is unavailable',
      tr: 'Demo modu kullanilamiyor',
      ar: 'وضع العرض غير متاح',
    ),
    message: _pick(
      context,
      en: 'This build is connected to live cloud auth, so demo sign-in is disabled.',
      tr: 'Bu surum canli bulut kimlik dogrulamaya bagli oldugu icin demo girisi kapali.',
      ar: 'هذا الإصدار متصل بمصادقة سحابية حية، لذلك تم تعطيل دخول وضع العرض.',
    ),
    code: 'demo_mode_unavailable',
  );
}

AuthFeedbackMessage _authFlowFailedFeedback(BuildContext context) {
  return AuthFeedbackMessage(
    title: _pick(
      context,
      en: 'We could not complete the auth flow',
      tr: 'Kimlik dogrulama akisi tamamlanamadi',
      ar: 'تعذر إكمال مسار المصادقة',
    ),
    message: _pick(
      context,
      en: 'Return to sign-in and try again. If you were resetting your password, request a new reset link.',
      tr: 'Giris ekranina donup tekrar dene. Eger sifreni yeniliyorsan yeni bir sifirlama baglantisi iste.',
      ar: 'ارجع إلى تسجيل الدخول وحاول مجدداً. وإذا كنت تعيد تعيين كلمة المرور فاطلب رابطاً جديداً.',
    ),
    code: 'auth_flow_failed',
  );
}

AuthFeedbackMessage _genericAuthFeedback(
  BuildContext context,
  AuthErrorContext intent,
) {
  final message = switch (intent) {
    AuthErrorContext.signUp => _pick(
        context,
        en: 'We could not create the account right now. Review your details and try again.',
        tr: 'Hesap su anda olusturulamadi. Bilgilerini kontrol edip tekrar dene.',
        ar: 'تعذر إنشاء الحساب حالياً. راجع بياناتك ثم حاول مرة أخرى.',
      ),
    AuthErrorContext.forgotPassword => _pick(
        context,
        en: 'We could not start the reset flow right now. Try again in a moment.',
        tr: 'Sifirlama akisi su anda baslatilamadi. Biraz sonra tekrar dene.',
        ar: 'تعذر بدء مسار إعادة التعيين حالياً. حاول مجدداً بعد قليل.',
      ),
    AuthErrorContext.resetPassword => _pick(
        context,
        en: 'We could not update the password right now. Try again or request a new reset link.',
        tr: 'Sifre su anda guncellenemedi. Tekrar dene ya da yeni bir sifirlama baglantisi iste.',
        ar: 'تعذر تحديث كلمة المرور حالياً. حاول مرة أخرى أو اطلب رابط إعادة تعيين جديد.',
      ),
    _ => _pick(
        context,
        en: 'We could not complete this step right now. Please try again.',
        tr: 'Bu adim su anda tamamlanamadi. Lutfen tekrar dene.',
        ar: 'تعذر إكمال هذه الخطوة حالياً. يرجى المحاولة مرة أخرى.',
      ),
  };

  return AuthFeedbackMessage(
    title: _pick(
      context,
      en: 'Something went wrong',
      tr: 'Bir sorun olustu',
      ar: 'حدثت مشكلة',
    ),
    message: message,
    code: 'unknown_auth_error',
  );
}

String _pick(
  BuildContext context, {
  required String en,
  required String tr,
  required String ar,
}) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => tr,
    'ar' => ar,
    _ => en,
  };
}
