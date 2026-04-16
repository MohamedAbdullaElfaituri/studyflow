import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/extensions/build_context_x.dart';
import '../../../shared/providers/app_providers.dart';

String _or(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  if (code == 'tr') return 'veya';
  if (code == 'ar') return 'أو';
  return 'or';
}

String _continueWithGoogle(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  if (code == 'tr') return 'Google ile devam et';
  if (code == 'ar') return 'المتابعة عبر Google';
  return 'Continue with Google';
}

String _browserHandoffMessage(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  if (code == 'tr') {
    return 'Google girisi tarayicida acildi. Islemi tamamlayinca uygulamaya geri doneceksin.';
  }
  if (code == 'ar') {
    return 'تم فتح تسجيل الدخول عبر Google في المتصفح. ستعود إلى التطبيق بعد إكماله.';
  }
  return 'Google sign-in opened in your browser. You will come back to the app when it finishes.';
}

String _signupConfirmationMessage(BuildContext context, String email) {
  final code = Localizations.localeOf(context).languageCode;
  if (code == 'tr') {
    return '$email adresine dogrulama baglantisi gonderildi. E-postani onaylayip giris yap.';
  }
  if (code == 'ar') {
    return 'أرسلنا رابط تأكيد إلى $email. أكّد بريدك الإلكتروني ثم سجّل الدخول.';
  }
  return 'We sent a confirmation link to $email. Verify your email, then sign in.';
}

String _resetPasswordFlowTitle(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  if (code == 'tr') return 'Yeni bir sifre belirle';
  if (code == 'ar') return 'عيّن كلمة مرور جديدة';
  return 'Create a new password';
}

String _resetPasswordFlowSubtitle(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  if (code == 'tr') {
    return 'Hesabina yeniden erisim saglamak icin yeni sifreni belirle.';
  }
  if (code == 'ar') {
    return 'أدخل كلمة مرور جديدة لإكمال استعادة الوصول إلى حسابك.';
  }
  return 'Choose a new password to finish recovering access to your account.';
}

String _resetPasswordFlowAction(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  if (code == 'tr') return 'Sifreyi guncelle';
  if (code == 'ar') return 'تحديث كلمة المرور';
  return 'Update password';
}

String _resetPasswordFlowSuccess(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  if (code == 'tr') return 'Sifren guncellendi.';
  if (code == 'ar') return 'تم تحديث كلمة المرور بنجاح.';
  return 'Your password was updated.';
}

String _localizedSplashCopy(
  BuildContext context, {
  required String en,
  required String ar,
  required String tr,
}) {
  final code = Localizations.localeOf(context).languageCode;
  if (code == 'tr') return tr;
  if (code == 'ar') return ar;
  return en;
}

/*
String _splashEyebrow(BuildContext context) => _localizedSplashCopy(
      context,
      en: 'Your study space is getting ready',
      ar: 'مساحتك الدراسية تستعد الآن',
      tr: 'Calisma alani hazirlaniyor',
    );

String _splashLoadingTitle(BuildContext context) => _localizedSplashCopy(
      context,
      en: 'Preparing everything for a smooth start',
      ar: 'نجهّز كل شيء لبداية سلسة',
      tr: 'Rahat bir baslangic icin her sey hazirlaniyor',
    );

String _splashLoadingBody(BuildContext context) => _localizedSplashCopy(
      context,
      en: 'We are loading your tasks, focus tools, and study progress so the app opens ready to use.',
      ar: 'نحمّل مهامك وأدوات التركيز وتقدّمك الدراسي حتى تفتح الواجهة وهي جاهزة للاستخدام.',
      tr: 'Gorevlerin, odak araclarin ve calisma ilerlemen yukleniyor; uygulama hazir acilsin.',
    );

String _splashProgressLabel(BuildContext context) => _localizedSplashCopy(
      context,
      en: 'Opening your dashboard...',
      ar: 'جاري فتح لوحتك...',
      tr: 'Panelin aciliyor...',
    );

String _splashChipPhone(BuildContext context) => _localizedSplashCopy(
      context,
      en: 'Phone friendly',
      ar: 'جاهز للهاتف',
      tr: 'Telefon uyumlu',
    );

String _splashChipLanguages(BuildContext context) => _localizedSplashCopy(
      context,
      en: 'EN • AR • TR',
      ar: 'EN • AR • TR',
      tr: 'EN • AR • TR',
    );

String _splashChipSync(BuildContext context) => _localizedSplashCopy(
      context,
      en: 'Secure sync',
      ar: 'مزامنة آمنة',
      tr: 'Guvenli senkron',
    );

String _splashTasksTitle(BuildContext context) => _localizedSplashCopy(
      context,
      en: 'Tasks',
      ar: 'المهام',
      tr: 'Gorevler',
    );

String _splashTasksBody(BuildContext context) => _localizedSplashCopy(
      context,
      en: 'Your plans and priorities are being organized.',
      ar: 'يتم ترتيب خططك وأولوياتك الآن.',
      tr: 'Planlarin ve onceliklerin duzenleniyor.',
    );

String _splashFocusTitle(BuildContext context) => _localizedSplashCopy(
      context,
      en: 'Focus',
      ar: 'التركيز',
      tr: 'Odak',
    );

String _splashFocusBody(BuildContext context) => _localizedSplashCopy(
      context,
      en: 'Sessions and routines are getting ready.',
      ar: 'جلساتك وروتينك قيد التحضير.',
      tr: 'Seanslarin ve rutinlerin hazirlaniyor.',
    );

String _splashProfileTitle(BuildContext context) => _localizedSplashCopy(
      context,
      en: 'Profile',
      ar: 'الملف الشخصي',
      tr: 'Profil',
    );

String _splashProfileBody(BuildContext context) => _localizedSplashCopy(
      context,
      en: 'Preferences and language choices follow you.',
      ar: 'تفضيلاتك واختيارات اللغة تبقى معك.',
      tr: 'Tercihlerin ve dil secimin seninle gelir.',
    );

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const routePath = '/splash';

  @override
  Widget build(BuildContext context) {
    return AppPage(
      padding: EdgeInsets.zero,
      child: RevealOnBuild(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 920;
            final isMedium = constraints.maxWidth >= 640;
            final horizontalPadding = isWide
                ? AppSpacing.xxxl
                : (isMedium ? AppSpacing.xxl : AppSpacing.lg);
            final verticalPadding =
                constraints.maxHeight < 720 ? AppSpacing.lg : AppSpacing.xxl;

            final content = isWide
                ? const Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 11,
                        child: _SplashIntroPanel(isCompact: false),
                      ),
                      SizedBox(width: AppSpacing.xl),
                      Expanded(
                        flex: 10,
                        child: _SplashVisualPanel(isCompact: false),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SplashIntroPanel(isCompact: !isMedium),
                      const SizedBox(height: AppSpacing.lg),
                      _SplashVisualPanel(isCompact: !isMedium),
                    ],
                  );

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isWide ? 1120 : 760),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: verticalPadding,
                      ),
                      child: content,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SplashIntroPanel extends StatelessWidget {
  const _SplashIntroPanel({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _splashEyebrow(context),
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _AppLogo(size: isCompact ? 64 : 72),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isCompact ? 220 : 280),
                child: Text(
                  context.l10n.appName,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                    height: 1.05,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _splashLoadingTitle(context),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: isCompact ? 28 : 36,
              fontWeight: FontWeight.w900,
              height: 1.08,
              letterSpacing: -1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _splashLoadingBody(context),
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: scheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: isCompact ? AppSpacing.lg : AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _SplashFeatureChip(
                icon: Icons.phone_iphone_rounded,
                label: _splashChipPhone(context),
                accent: scheme.primary,
              ),
              _SplashFeatureChip(
                icon: Icons.translate_rounded,
                label: _splashChipLanguages(context),
                accent: scheme.tertiary,
              ),
              _SplashFeatureChip(
                icon: Icons.cloud_done_rounded,
                label: _splashChipSync(context),
                accent: scheme.secondary,
              ),
            ],
          ),
          SizedBox(height: isCompact ? AppSpacing.lg : AppSpacing.xl),
          Text(
            _splashProgressLabel(context),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              backgroundColor: scheme.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashVisualPanel extends StatelessWidget {
  const _SplashVisualPanel({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return _FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  scheme.primaryContainer.withValues(alpha: 0.96),
                  scheme.surfaceContainerHighest.withValues(alpha: 0.94),
                  scheme.tertiaryContainer.withValues(alpha: 0.86),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            child: AspectRatio(
              aspectRatio: isCompact ? 1.08 : 1.18,
              child: Stack(
                children: [
                  PositionedDirectional(
                    top: -26,
                    end: -18,
                    child: _SplashOrb(
                      size: isCompact ? 118 : 144,
                      color: scheme.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  PositionedDirectional(
                    bottom: -36,
                    start: -10,
                    child: _SplashOrb(
                      size: isCompact ? 132 : 164,
                      color: scheme.tertiary.withValues(alpha: 0.14),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.all(
                        isCompact ? AppSpacing.lg : AppSpacing.xl,
                      ),
                      child: SvgPicture.asset(
                        'assets/illustrations/undraw_onboarding_dcq2.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = constraints.maxWidth >= 600
                  ? (constraints.maxWidth - (AppSpacing.md * 2)) / 3
                  : constraints.maxWidth >= 380
                      ? (constraints.maxWidth - AppSpacing.md) / 2
                      : constraints.maxWidth;

              return Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  SizedBox(
                    width: tileWidth,
                    child: _SplashStatusTile(
                      icon: Icons.task_alt_rounded,
                      title: _splashTasksTitle(context),
                      body: _splashTasksBody(context),
                      accent: scheme.primary,
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: _SplashStatusTile(
                      icon: Icons.timer_rounded,
                      title: _splashFocusTitle(context),
                      body: _splashFocusBody(context),
                      accent: scheme.secondary,
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: _SplashStatusTile(
                      icon: Icons.account_circle_rounded,
                      title: _splashProfileTitle(context),
                      body: _splashProfileBody(context),
                      accent: scheme.tertiary,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SplashFeatureChip extends StatelessWidget {
  const _SplashFeatureChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accent.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: accent,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _SplashStatusTile extends StatelessWidget {
  const _SplashStatusTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.45,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashOrb extends StatelessWidget {
  const _SplashOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
*/

String _splashBadge(BuildContext context) => _localizedSplashCopy(
      context,
      en: 'Getting ready',
      ar: 'يتم التحضير الآن',
      tr: 'Hazirlaniyor',
    );

/*
String _splashLoadingTitle(BuildContext context) => _localizedSplashCopy(
      context,
      en: 'Opening your calm study space',
      ar: 'جارٍ فتح مساحة الدراسة الهادئة',
      tr: 'Sakin calisma alanin aciliyor',
    );

String _splashLoadingBody(BuildContext context) => _localizedSplashCopy(
      context,
      en: 'Tasks, focus tools, and preferences are loading so you can continue without extra steps.',
      ar: 'يتم تحميل المهام وأدوات التركيز والتفضيلات حتى تتابع مباشرة من دون خطوات إضافية.',
      tr: 'Gorevler, odak araclari ve tercihlerin ek adim olmadan devam edebilmen icin yukleniyor.',
    );

String _splashProgressLabel(BuildContext context) => _localizedSplashCopy(
      context,
      en: 'Opening home...',
      ar: 'جارٍ فتح الصفحة الرئيسية...',
      tr: 'Ana sayfa aciliyor...',
    );

*/
String _splashLoadingTitle(BuildContext context) => _localizedSplashCopy(
      context,
      en: 'Opening StudyFlow',
      ar: 'جارٍ فتح StudyFlow',
      tr: 'StudyFlow aciliyor',
    );

String _splashLoadingBody(BuildContext context) => _localizedSplashCopy(
      context,
      en: 'Please wait a moment.',
      ar: 'يرجى الانتظار لحظة.',
      tr: 'Lutfen kisa bir an bekleyin.',
    );

String _splashProgressLabel(BuildContext context) => _localizedSplashCopy(
      context,
      en: 'Loading...',
      ar: 'جارٍ التحميل...',
      tr: 'Yukleniyor...',
    );

/*
String _splashChipLanguages(BuildContext context) => _localizedSplashCopy(
      context,
      en: 'EN • TR • AR',
      ar: 'EN • TR • AR',
      tr: 'EN • TR • AR',
    );

String _splashChipTheme(BuildContext context) => _localizedSplashCopy(
      context,
      en: 'Light + dark',
      ar: 'فاتح + داكن',
      tr: 'Acik + koyu',
    );

String _splashChipSync(BuildContext context) => _localizedSplashCopy(
      context,
      en: 'Secure sync',
      ar: 'مزامنة آمنة',
      tr: 'Guvenli senkron',
    );

*/
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const routePath = '/splash';

  @override
  Widget build(BuildContext context) {
    return AppPage(
      padding: EdgeInsets.zero,
      child: RevealOnBuild(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 380;
            final verticalPadding =
                constraints.maxHeight < 700 ? AppSpacing.xl : AppSpacing.xxxl;

            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? AppSpacing.lg : AppSpacing.xl,
                  vertical: verticalPadding,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Semantics(
                        label:
                            '${_splashBadge(context)} ${_splashLoadingTitle(context)} ${_splashLoadingBody(context)} ${_splashProgressLabel(context)}',
                        child: _SplashLogoHalo(compact: isCompact),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SplashLogoHalo extends StatelessWidget {
  const _SplashLogoHalo({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _AppLogo(size: compact ? 68 : 76);
  }
}

/*
class _SplashStatusPill extends StatelessWidget {
  const _SplashStatusPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: scheme.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

*/
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const routePath = '/login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscure = true;
  bool _isSubmitting = false;
  bool _isGoogleSubmitting = false;
  /*
        context.go('/home'); // BURAYI kendi ana ekran rotana göre değiştir
      }
    });
  }

  void _checkExistingSession() {
    final session = Supabase.instance.client.auth.currentSession;
    debugPrint('CURRENT SESSION ON LOGIN SCREEN: $session');

    if (!mounted || _hasNavigatedAfterAuth) return;

    if (session != null) {
      _hasNavigatedAfterAuth = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go('/home'); // BURAYI kendi ana ekran rotana göre değiştir
      });
    }
  }

  */
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      await ref.read(authControllerProvider.notifier).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    } catch (error) {
      if (!mounted) return;
      context.showErrorNotification(context.resolveError(error));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() => _isGoogleSubmitting = true);

    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();

      if (!mounted) return;
      context.showAppSnackBar(_browserHandoffMessage(context));
    } catch (error) {
      if (!mounted) return;
      context.showErrorNotification(context.resolveError(error));
    } finally {
      if (mounted) {
        setState(() => _isGoogleSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isSubmitting || _isGoogleSubmitting;

    return _AuthShell(
      canPop: false,
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.l10n.noAccountPrompt,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          TextButton(
            onPressed:
                isBusy ? null : () => context.push(SignupScreen.routePath),
            child: Text(context.l10n.signUpAction),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.loginTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.l10n.loginSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              decoration: InputDecoration(
                labelText: context.l10n.emailLabel,
                prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
              ),
              validator: (value) =>
                  context.validationMessage(Validators.email(value)),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              autocorrect: false,
              enableSuggestions: false,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: context.l10n.passwordLabel,
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: _VisibilityToggle(
                  obscure: _obscure,
                  onToggle: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (value) =>
                  context.validationMessage(Validators.minLength(value, 6)),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: isBusy
                    ? null
                    : () => context.push(ForgotPasswordScreen.routePath),
                child: Text(context.l10n.forgotPasswordAction),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: isBusy ? null : _submit,
              child: _AsyncLabel(
                isLoading: _isSubmitting,
                label: context.l10n.loginAction,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _AuthDivider(label: _or(context)),
            const SizedBox(height: AppSpacing.xl),
            _GoogleButton(
              isLoading: _isGoogleSubmitting,
              enabled: !isBusy,
              onPressed: _signInWithGoogle,
            ),
          ],
        ),
      ),
    );
  }
}

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  static const routePath = '/signup';

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  bool _isGoogleSubmitting = false;
  /*
  @override
  void initState() {
    super.initState();
    _listenForAuthChanges();
    _checkExistingSession();
  }

  void _listenForAuthChanges() {
    final supabase = Supabase.instance.client;

    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      debugPrint('SIGNUP AUTH EVENT: $event');
      debugPrint('SIGNUP AUTH SESSION: $session');
      debugPrint('SIGNUP AUTH USER: ${session?.user.email}');

      if (!mounted || _hasNavigatedAfterAuth) return;

      if (session != null) {
        _hasNavigatedAfterAuth = true;
        context.go('/home'); // BURAYI kendi ana ekran rotana göre değiştir
      }
    });
  }

  void _checkExistingSession() {
    final session = Supabase.instance.client.auth.currentSession;
    debugPrint('CURRENT SESSION ON SIGNUP SCREEN: $session');

    if (!mounted || _hasNavigatedAfterAuth) return;

    if (session != null) {
      _hasNavigatedAfterAuth = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go('/home'); // BURAYI kendi ana ekran rotana göre değiştir
      });
    }
  }

  */
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      final result = await ref.read(authControllerProvider.notifier).signUp(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) return;

      if (result.requiresEmailConfirmation) {
        context.showSuccessNotification(
          _signupConfirmationMessage(context, result.email),
        );
        context.go(LoginScreen.routePath);
      }
    } catch (error) {
      if (!mounted) return;
      context.showErrorNotification(context.resolveError(error));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() => _isGoogleSubmitting = true);

    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();

      if (!mounted) return;
      context.showAppSnackBar(_browserHandoffMessage(context));
    } catch (error) {
      if (!mounted) return;
      context.showErrorNotification(context.resolveError(error));
    } finally {
      if (mounted) {
        setState(() => _isGoogleSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isSubmitting || _isGoogleSubmitting;

    return _AuthShell(
      canPop: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.signUpTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.l10n.signUpSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: context.l10n.fullNameLabel,
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
              ),
              validator: (value) =>
                  context.validationMessage(Validators.requiredField(value)),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              decoration: InputDecoration(
                labelText: context.l10n.emailLabel,
                prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
              ),
              validator: (value) =>
                  context.validationMessage(Validators.email(value)),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: context.l10n.passwordLabel,
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: _VisibilityToggle(
                  obscure: _obscurePassword,
                  onToggle: () => setState(
                    () => _obscurePassword = !_obscurePassword,
                  ),
                ),
              ),
              validator: (value) =>
                  context.validationMessage(Validators.minLength(value, 6)),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              autocorrect: false,
              enableSuggestions: false,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: context.l10n.confirmPasswordLabel,
                prefixIcon: const Icon(Icons.lock_person_outlined, size: 20),
                suffixIcon: _VisibilityToggle(
                  obscure: _obscureConfirm,
                  onToggle: () => setState(
                    () => _obscureConfirm = !_obscureConfirm,
                  ),
                ),
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return context.l10n.passwordsDoNotMatch;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: isBusy ? null : _submit,
              child: _AsyncLabel(
                isLoading: _isSubmitting,
                label: context.l10n.createAccountAction,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _AuthDivider(label: _or(context)),
            const SizedBox(height: AppSpacing.xl),
            _GoogleButton(
              isLoading: _isGoogleSubmitting,
              enabled: !isBusy,
              onPressed: _signInWithGoogle,
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const routePath = '/forgot-password';

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      await ref.read(authControllerProvider.notifier).sendPasswordReset(
            _emailController.text.trim(),
          );

      if (!mounted) return;

      context.showSuccessNotification(
        context.l10n.resetPasswordSentMessage,
      );
      context.go(LoginScreen.routePath);
    } catch (error) {
      if (!mounted) return;
      context.showErrorNotification(context.resolveError(error));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthShell(
      canPop: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.forgotPasswordTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.forgotPasswordSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.email],
                  autocorrect: false,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: context.l10n.emailLabel,
                    prefixIcon:
                        const Icon(Icons.mail_outline_rounded, size: 20),
                  ),
                  validator: (value) =>
                      context.validationMessage(Validators.email(value)),
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _AsyncLabel(
                    isLoading: _isSubmitting,
                    label: context.l10n.sendResetLinkAction,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  static const routePath = '/reset-password';

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(authControllerProvider.notifier)
          .updatePassword(_passwordController.text);

      if (!mounted) return;

      context.showSuccessNotification(_resetPasswordFlowSuccess(context));
    } catch (error) {
      if (!mounted) return;
      context.showErrorNotification(context.resolveError(error));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthShell(
      canPop: false,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _resetPasswordFlowTitle(context),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _resetPasswordFlowSubtitle(context),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: context.l10n.passwordLabel,
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: _VisibilityToggle(
                  obscure: _obscurePassword,
                  onToggle: () => setState(
                    () => _obscurePassword = !_obscurePassword,
                  ),
                ),
              ),
              validator: (value) =>
                  context.validationMessage(Validators.minLength(value, 6)),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              autocorrect: false,
              enableSuggestions: false,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: context.l10n.confirmPasswordLabel,
                prefixIcon: const Icon(Icons.lock_person_outlined, size: 20),
                suffixIcon: _VisibilityToggle(
                  obscure: _obscureConfirm,
                  onToggle: () => setState(
                    () => _obscureConfirm = !_obscureConfirm,
                  ),
                ),
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return context.l10n.passwordsDoNotMatch;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _AsyncLabel(
                isLoading: _isSubmitting,
                label: _resetPasswordFlowAction(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthShell extends StatelessWidget {
  const _AuthShell({
    required this.child,
    this.canPop = false,
    this.footer,
  });

  final Widget child;
  final bool canPop;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppPage(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 860;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 960 : 480),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: isWide ? AppSpacing.xxl : AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (canPop)
                        IconButton.filledTonal(
                          onPressed: context.pop,
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: scheme.surfaceContainerHighest
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      SizedBox(height: canPop ? AppSpacing.lg : AppSpacing.xxl),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _LogoPanel()),
                            const SizedBox(width: AppSpacing.xxl),
                            Expanded(child: _FormCard(child: child)),
                          ],
                        )
                      else ...[
                        _LogoPanel(),
                        const SizedBox(height: AppSpacing.xl),
                        _FormCard(child: child),
                      ],
                      if (footer != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Center(child: footer!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LogoPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AppLogo(size: 72),
        const SizedBox(height: AppSpacing.lg),
        Text(
          context.l10n.appName,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1.2,
                height: 1.05,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(
              alpha:
                  Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.06,
            ),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: child,
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = size * 0.26;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          'assets/branding/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _FallbackLogo(
            size: size,
            radius: radius,
            scheme: scheme,
          ),
        ),
      ),
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo({
    required this.size,
    required this.radius,
    required this.scheme,
  });

  final double size;
  final double radius;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        color: scheme.onPrimary,
        size: size * 0.46,
      ),
    );
  }
}

class _AuthDivider extends StatelessWidget {
  const _AuthDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({
    required this.isLoading,
    required this.enabled,
    required this.onPressed,
  });

  final bool isLoading;
  final bool enabled;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      onPressed: !enabled || isLoading ? null : () async => onPressed(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.string(
            '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="20" height="20"><path fill="#FFC107" d="M43.611 20.083H42V20H24v8h11.303c-1.649 4.657-6.08 8-11.303 8-6.627 0-12-5.373-12-12s5.373-12 12-12c3.059 0 5.842 1.154 7.961 3.039l5.657-5.657C34.046 6.053 29.268 4 24 4 12.955 4 4 12.955 4 24s8.955 20 20 20 20-8.955 20-20c0-1.341-.138-2.65-.389-3.917z"/><path fill="#FF3D00" d="m6.306 14.691 6.571 4.819C14.655 15.108 18.961 12 24 12c3.059 0 5.842 1.154 7.961 3.039l5.657-5.657C34.046 6.053 29.268 4 24 4 16.318 4 9.656 8.337 6.306 14.691z"/><path fill="#4CAF50" d="M24 44c5.166 0 9.86-1.977 13.409-5.192l-6.19-5.238A11.91 11.91 0 0 1 24 36c-5.202 0-9.619-3.317-11.283-7.946l-6.522 5.025C9.505 39.556 16.227 44 24 44z"/><path fill="#1976D2" d="M43.611 20.083H42V20H24v8h11.303a12.04 12.04 0 0 1-4.087 5.571l6.19 5.238C36.971 39.205 44 34 44 24c0-1.341-.138-2.65-.389-3.917z"/></svg>''',
            width: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            _continueWithGoogle(context),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({
    required this.obscure,
    required this.onToggle,
  });

  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      icon: Icon(
        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 20,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _AsyncLabel extends StatelessWidget {
  const _AsyncLabel({
    required this.isLoading,
    required this.label,
  });

  final bool isLoading;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isLoading
          ? SizedBox(
              key: const ValueKey('loading'),
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            )
          : Text(
              key: const ValueKey('label'),
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
    );
  }
}
