import 'package:flutter/widgets.dart';

class AuthCopy {
  const AuthCopy(this.code);

  final String code;

  static AuthCopy of(BuildContext context) =>
      AuthCopy(Localizations.localeOf(context).languageCode);

  bool get _isTr => code == 'tr';
  bool get _isAr => code == 'ar';

  String _pick({
    required String en,
    required String tr,
    required String ar,
  }) {
    if (_isTr) {
      return tr;
    }
    if (_isAr) {
      return ar;
    }
    return en;
  }

  String get loginHeroBadge => _pick(
        en: 'Mobile premium',
        tr: 'Premium mobil',
        ar: 'تجربة موبايل مميزة',
      );
  String get signupHeroBadge => _pick(
        en: 'Personal identity',
        tr: 'Kişisel kimlik',
        ar: 'هوية شخصية',
      );
  String get recoveryBadge => _pick(
        en: 'Recovery',
        tr: 'Kurtarma',
        ar: 'استعادة الحساب',
      );
<<<<<<< HEAD
  String get demoHeroBadge => _pick(
        en: 'Local demo mode',
        tr: 'Yerel demo modu',
        ar: 'وضع العرض المحلي',
      );
=======
>>>>>>> 92fae2d3904b11ee5fa030777256fb5aa49368c1
  String get streakSyncLabel => _pick(
        en: 'Streak sync',
        tr: 'Seri senkronu',
        ar: 'مزامنة السلسلة',
      );
  String get latencyLabel => _pick(
        en: 'Latency',
        tr: 'Gecikme',
        ar: 'الاستجابة',
      );
  String get darkModeLabel => _pick(
        en: 'Dark mode',
        tr: 'Karanlık mod',
        ar: 'الوضع الداكن',
      );
  String get profileLabel => _pick(
        en: 'Profile',
        tr: 'Profil',
        ar: 'الملف الشخصي',
      );
  String get motionLabel => _pick(
        en: 'Motion',
        tr: 'Hareket',
        ar: 'الحركة',
      );
  String get rtlLabel => _pick(
        en: 'RTL',
        tr: 'RTL',
        ar: 'اتجاه RTL',
      );
  String get feedbackLabel => _pick(
        en: 'Feedback',
        tr: 'Geri bildirim',
        ar: 'التغذية الراجعة',
      );
  String get flowLabel => _pick(
        en: 'Flow',
        tr: 'Akış',
        ar: 'التدفّق',
      );
  String get securityLabel => _pick(
        en: 'Security',
        tr: 'Güvenlik',
        ar: 'الأمان',
      );
  String get liveValue => _pick(
        en: 'Live',
        tr: 'Canlı',
        ar: 'مباشر',
      );
  String get readyValue => _pick(
        en: 'Ready',
        tr: 'Hazır',
        ar: 'جاهز',
      );
  String get richValue => _pick(
        en: 'Rich',
        tr: 'Zengin',
        ar: 'غني',
      );
  String get smoothValue => _pick(
        en: 'Smooth',
        tr: 'Akıcı',
        ar: 'سلس',
      );
  String get arabicValue => _pick(
        en: 'Arabic',
        tr: 'Arapça',
        ar: 'العربية',
      );
  String get instantValue => _pick(
        en: 'Instant',
        tr: 'Anlık',
        ar: 'فوري',
      );
<<<<<<< HEAD
  String get localValue => _pick(
        en: 'Local',
        tr: 'Yerel',
        ar: 'محلي',
      );
=======
>>>>>>> 92fae2d3904b11ee5fa030777256fb5aa49368c1
  String get simpleValue => _pick(
        en: 'Simple',
        tr: 'Sade',
        ar: 'بسيط',
      );
  String get safeValue => _pick(
        en: 'Safe',
        tr: 'Güvenli',
        ar: 'آمن',
      );
  String get loginIntroTitle => _pick(
        en: 'Welcome back',
        tr: 'Tekrar hoş geldin',
        ar: 'مرحبًا بعودتك',
      );
  String get loginIntroSubtitle => _pick(
        en: 'Your study identity, planner, and focus analytics are ready.',
        tr: 'Çalışma kimliğin, planlayıcın ve odak analizlerin hazır.',
        ar: 'هوية دراستك والمخطط وتحليلات التركيز جاهزة.',
      );
  String get signupIntroTitle => _pick(
        en: 'Create your mobile workspace',
        tr: 'Mobil çalışma alanını oluştur',
        ar: 'أنشئ مساحة الدراسة على الهاتف',
      );
  String get signupIntroSubtitle => _pick(
        en: 'Build a premium study planner with clear hierarchy and dark mode.',
        tr: 'Net hiyerarşi ve dark mode ile premium bir çalışma planlayıcısı kur.',
        ar: 'ابنِ مخطط دراسة مميزًا بهرمية واضحة ووضع داكن.',
      );
  String get resetTitle => _pick(
        en: 'Reset your password',
        tr: 'Şifreni yenile',
        ar: 'أعد تعيين كلمة المرور',
      );
  String get resetSubtitle => _pick(
        en: 'We will send a recovery link so you can safely re-enter your workspace.',
        tr: 'Çalışma alanına güvenle dönebilmen için bir kurtarma bağlantısı göndereceğiz.',
        ar: 'سنرسل رابط استعادة لتتمكن من العودة إلى مساحتك بأمان.',
      );
<<<<<<< HEAD
  String get enterDemoWorkspace => _pick(
        en: 'Enter demo workspace',
        tr: 'Demo çalışma alanına gir',
        ar: 'ادخل مساحة العرض',
      );
  String get demoCredentialsLabel => _pick(
        en: 'Demo credentials',
        tr: 'Demo bilgileri',
        ar: 'بيانات العرض',
      );
=======
>>>>>>> 92fae2d3904b11ee5fa030777256fb5aa49368c1
}
