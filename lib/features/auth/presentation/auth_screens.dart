import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/extensions/build_context_x.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/utils/auth_issue_codes.dart';
import 'auth_feedback.dart';
import 'widgets/auth_shell.dart';

String _orLabel(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'veya',
    'ar' => 'أو',
    _ => 'or',
  };
}

String _continueWithGoogleLabel(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Google ile devam et',
    'ar' => 'المتابعة عبر Google',
    _ => 'Continue with Google',
  };
}

String _exploreAppLabel(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Uygulamayı keşfet',
    'ar' => 'استكشف التطبيق',
    _ => 'Explore the app',
  };
}

String _alreadyHaveAccountPrompt(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Zaten bir hesabın var mı?',
    'ar' => 'هل لديك حساب بالفعل؟',
    _ => 'Already have an account?',
  };
}

String _authLoadingTitle(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Hesabın hazırlanıyor',
    'ar' => 'جار تجهيز حسابك',
    _ => 'Preparing your account',
  };
}

String _authLoadingSubtitle(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Lütfen bekle, seni doğrudan ana ekrana götürüyoruz.',
    'ar' => 'يرجى الانتظار، سيتم نقلك مباشرة إلى الصفحة الرئيسية.',
    _ => 'Please wait while we take you straight to the home screen.',
  };
}

String _resetPasswordTitle(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Yeni bir şifre belirle',
    'ar' => 'عيّن كلمة مرور جديدة',
    _ => 'Create a new password',
  };
}

String _resetPasswordSubtitle(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Hesabına tekrar erişebilmek için yeni şifreni gir.',
    'ar' => 'أدخل كلمة مرور جديدة لإكمال استعادة الوصول إلى حسابك.',
    _ => 'Enter a new password to finish restoring access to your account.',
  };
}

String _resetPasswordAction(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Şifreyi güncelle',
    'ar' => 'تحديث كلمة المرور',
    _ => 'Update password',
  };
}

String _resetPasswordSuccess(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Şifren güncellendi.',
    'ar' => 'تم تحديث كلمة المرور بنجاح.',
    _ => 'Your password was updated.',
  };
}

Widget? _buildAuthNotice(AuthFeedbackMessage? feedback) {
  if (feedback == null) {
    return null;
  }

  return AuthMessageBanner(
    title: feedback.title,
    message: feedback.message,
    tone: feedback.tone,
  );
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const routePath = '/splash';

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _animationDuration = Duration(milliseconds: 1200);
  static const _reducedMotionDuration = Duration(milliseconds: 650);

  @override
  void initState() {
    super.initState();
    final accessibilityMode = ref.read(accessibilityModeProvider);
    final delay =
        accessibilityMode ? _reducedMotionDuration : _animationDuration;
    Future<void>.delayed(delay, () {
      if (!mounted) {
        return;
      }
      ref.read(launchSplashCompletedProvider.notifier).complete();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final progressDuration =
        disableAnimations ? _reducedMotionDuration : _animationDuration;

    return AppPage(
      padding: EdgeInsets.zero,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xxl,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.84, end: 1),
                  duration: progressDuration,
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: disableAnimations ? 1 : value,
                      child: Transform.scale(
                        scale: disableAnimations ? 1 : value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 152,
                    height: 152,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(44),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          scheme.surface.withValues(alpha: 0.96),
                          scheme.surfaceContainerHighest.withValues(
                            alpha: 0.88,
                          ),
                        ],
                      ),
                      border: Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.34),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.seed.withValues(alpha: 0.10),
                          blurRadius: 30,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(44),
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.secondary.withValues(alpha: 0.14),
                                  Colors.transparent,
                                ],
                                radius: 0.88,
                              ),
                            ),
                          ),
                        ),
                        const AppLogo(
                          size: 88,
                          radius: 28,
                          backgroundColor: Colors.white,
                          borderColor: Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  context.l10n.appName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.l10n.splashSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: SizedBox(
                    width: 156,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: progressDuration,
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: disableAnimations ? 1 : value,
                          minHeight: 5,
                          backgroundColor:
                              scheme.outlineVariant.withValues(alpha: 0.24),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.secondary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthLoadingScreen extends StatelessWidget {
  const AuthLoadingScreen({super.key});

  static const routePath = '/auth-loading';

  @override
  Widget build(BuildContext context) {
    return AppPage(
      padding: EdgeInsets.zero,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/branding/app_logo.png',
                width: 88,
                height: 88,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                _authLoadingTitle(context),
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _authLoadingSubtitle(context),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

  String? _emailError;
  String? _passwordError;
  AuthFeedbackMessage? _feedback;
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  bool _isGoogleSubmitting = false;
  bool _isDemoSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearFeedback({
    bool clearBanner = true,
    bool clearEmail = true,
    bool clearPassword = true,
    bool clearNotice = true,
  }) {
    final shouldUpdate = (clearBanner && _feedback != null) ||
        (clearEmail && _emailError != null) ||
        (clearPassword && _passwordError != null);

    if (shouldUpdate) {
      setState(() {
        if (clearBanner) {
          _feedback = null;
        }
        if (clearEmail) {
          _emailError = null;
        }
        if (clearPassword) {
          _passwordError = null;
        }
      });
    }

    if (clearNotice) {
      ref.read(authNoticeProvider.notifier).clear();
    }
  }

  void _applyFeedback(AuthFeedbackMessage feedback) {
    setState(() {
      _feedback = feedback;
      _emailError = feedback.field == AuthFieldTarget.email
          ? (feedback.fieldMessage ?? feedback.message)
          : null;
      _passwordError = feedback.field == AuthFieldTarget.password
          ? (feedback.fieldMessage ?? feedback.message)
          : null;
    });
  }

  Future<void> _submit() async {
    _clearFeedback();
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
      if (!mounted) {
        return;
      }
      _applyFeedback(
        resolveAuthFeedback(
          context,
          error,
          intent: AuthErrorContext.signIn,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    _clearFeedback();
    FocusScope.of(context).unfocus();
    setState(() => _isGoogleSubmitting = true);
    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();
    } catch (error) {
      if (!mounted) {
        return;
      }
      _applyFeedback(
        resolveAuthFeedback(
          context,
          error,
          intent: AuthErrorContext.google,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGoogleSubmitting = false);
      }
    }
  }

  Future<void> _signInWithDemo() async {
    _clearFeedback();
    FocusScope.of(context).unfocus();
    setState(() => _isDemoSubmitting = true);
    try {
      await ref.read(authControllerProvider.notifier).signInWithDemo();
    } catch (error) {
      if (!mounted) {
        return;
      }
      _applyFeedback(
        resolveAuthFeedback(
          context,
          error,
          intent: AuthErrorContext.signIn,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDemoSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCloudSyncEnabled = ref.watch(isCloudSyncEnabledProvider);
    final authNoticeCode = ref.watch(authNoticeProvider);
    final activeFeedback = _feedback ??
        (authNoticeCode == null
            ? null
            : feedbackForAuthNotice(context, authNoticeCode));

    return AuthScaffold(
      title: context.l10n.loginTitle,
      subtitle: context.l10n.loginSubtitle,
      notice: _buildAuthNotice(activeFeedback),
      footer: AuthFooterPrompt(
        prompt: context.l10n.noAccountPrompt,
        actionLabel: context.l10n.signUpAction,
        onTap: () => context.push(SignupScreen.routePath),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _clearFeedback(
                clearEmail: true,
                clearPassword: true,
              ),
              forceErrorText: _emailError,
              decoration: InputDecoration(
                labelText: context.l10n.emailLabel,
                prefixIcon: const Icon(Icons.mail_outline_rounded),
              ),
              validator: (value) =>
                  context.validationMessage(Validators.email(value)),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onChanged: (_) => _clearFeedback(
                clearEmail: false,
                clearPassword: true,
              ),
              onFieldSubmitted: (_) => _submit(),
              forceErrorText: _passwordError,
              decoration: InputDecoration(
                labelText: context.l10n.passwordLabel,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () => setState(
                    () => _obscurePassword = !_obscurePassword,
                  ),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                ),
              ),
              validator: (value) => context.validationMessage(
                Validators.minLength(value, 6),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => context.push(ForgotPasswordScreen.routePath),
                child: Text(context.l10n.forgotPasswordAction),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _BusyLabel(
                isBusy: _isSubmitting,
                idleLabel: context.l10n.loginAction,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AuthDivider(label: _orLabel(context)),
            const SizedBox(height: AppSpacing.lg),
            if (isCloudSyncEnabled)
              AuthSecondaryButton(
                label: _continueWithGoogleLabel(context),
                onPressed: _isGoogleSubmitting ? null : _signInWithGoogle,
                isBusy: _isGoogleSubmitting,
                icon: const _GoogleMark(),
              )
            else
              AuthSecondaryButton(
                label: _exploreAppLabel(context),
                onPressed: _isDemoSubmitting ? null : _signInWithDemo,
                isBusy: _isDemoSubmitting,
                icon: const Icon(Icons.play_circle_outline_rounded),
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

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  AuthFeedbackMessage? _feedback;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  bool _isGoogleSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _clearFeedback({
    bool clearBanner = true,
    bool clearName = true,
    bool clearEmail = true,
    bool clearPassword = true,
    bool clearConfirm = true,
    bool clearNotice = true,
  }) {
    final shouldUpdate = (clearBanner && _feedback != null) ||
        (clearName && _nameError != null) ||
        (clearEmail && _emailError != null) ||
        (clearPassword && _passwordError != null) ||
        (clearConfirm && _confirmError != null);

    if (shouldUpdate) {
      setState(() {
        if (clearBanner) {
          _feedback = null;
        }
        if (clearName) {
          _nameError = null;
        }
        if (clearEmail) {
          _emailError = null;
        }
        if (clearPassword) {
          _passwordError = null;
        }
        if (clearConfirm) {
          _confirmError = null;
        }
      });
    }

    if (clearNotice) {
      ref.read(authNoticeProvider.notifier).clear();
    }
  }

  void _applyFeedback(AuthFeedbackMessage feedback) {
    setState(() {
      _feedback = feedback;
      _nameError = feedback.field == AuthFieldTarget.fullName
          ? (feedback.fieldMessage ?? feedback.message)
          : null;
      _emailError = feedback.field == AuthFieldTarget.email
          ? (feedback.fieldMessage ?? feedback.message)
          : null;
      _passwordError = feedback.field == AuthFieldTarget.password
          ? (feedback.fieldMessage ?? feedback.message)
          : null;
      _confirmError = feedback.field == AuthFieldTarget.confirmPassword
          ? (feedback.fieldMessage ?? feedback.message)
          : null;
    });
  }

  Future<void> _submit() async {
    _clearFeedback();
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

      if (!mounted) {
        return;
      }

      if (result.requiresEmailConfirmation) {
        _applyFeedback(signUpConfirmationFeedback(context, result.email));
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      _applyFeedback(
        resolveAuthFeedback(
          context,
          error,
          intent: AuthErrorContext.signUp,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    _clearFeedback();
    FocusScope.of(context).unfocus();
    setState(() => _isGoogleSubmitting = true);
    try {
      await ref.read(authControllerProvider.notifier).signInWithGoogle();
    } catch (error) {
      if (!mounted) {
        return;
      }
      _applyFeedback(
        resolveAuthFeedback(
          context,
          error,
          intent: AuthErrorContext.google,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGoogleSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCloudSyncEnabled = ref.watch(isCloudSyncEnabledProvider);
    final authNoticeCode = ref.watch(authNoticeProvider);
    final activeFeedback = _feedback ??
        (authNoticeCode == null
            ? null
            : feedbackForAuthNotice(context, authNoticeCode));

    return AuthScaffold(
      title: context.l10n.signUpTitle,
      subtitle: context.l10n.signUpSubtitle,
      notice: _buildAuthNotice(activeFeedback),
      canPop: true,
      footer: AuthFooterPrompt(
        prompt: _alreadyHaveAccountPrompt(context),
        actionLabel: context.l10n.loginAction,
        onTap: () => context.pop(),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => _clearFeedback(
                clearName: true,
                clearEmail: false,
                clearPassword: false,
                clearConfirm: false,
              ),
              forceErrorText: _nameError,
              decoration: InputDecoration(
                labelText: context.l10n.fullNameLabel,
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
              validator: (value) =>
                  context.validationMessage(Validators.requiredField(value)),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _clearFeedback(
                clearName: false,
                clearEmail: true,
                clearPassword: false,
                clearConfirm: false,
              ),
              forceErrorText: _emailError,
              decoration: InputDecoration(
                labelText: context.l10n.emailLabel,
                prefixIcon: const Icon(Icons.mail_outline_rounded),
              ),
              validator: (value) =>
                  context.validationMessage(Validators.email(value)),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _clearFeedback(
                clearName: false,
                clearEmail: false,
                clearPassword: true,
                clearConfirm: true,
              ),
              forceErrorText: _passwordError,
              decoration: InputDecoration(
                labelText: context.l10n.passwordLabel,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () => setState(
                    () => _obscurePassword = !_obscurePassword,
                  ),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                ),
              ),
              validator: (value) => context.validationMessage(
                Validators.minLength(value, 6),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              onChanged: (_) => _clearFeedback(
                clearName: false,
                clearEmail: false,
                clearPassword: false,
                clearConfirm: true,
              ),
              onFieldSubmitted: (_) => _submit(),
              forceErrorText: _confirmError,
              decoration: InputDecoration(
                labelText: context.l10n.confirmPasswordLabel,
                prefixIcon: const Icon(Icons.verified_user_outlined),
                suffixIcon: IconButton(
                  onPressed: () => setState(
                    () => _obscureConfirm = !_obscureConfirm,
                  ),
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                ),
              ),
              validator: (value) {
                final message =
                    context.validationMessage(Validators.minLength(value, 6));
                if (message != null) {
                  return message;
                }
                if (value != _passwordController.text) {
                  return context.l10n.passwordsDoNotMatch;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _BusyLabel(
                isBusy: _isSubmitting,
                idleLabel: context.l10n.createAccountAction,
              ),
            ),
            if (isCloudSyncEnabled) ...[
              const SizedBox(height: AppSpacing.lg),
              AuthDivider(label: _orLabel(context)),
              const SizedBox(height: AppSpacing.lg),
              AuthSecondaryButton(
                label: _continueWithGoogleLabel(context),
                onPressed: _isGoogleSubmitting ? null : _signInWithGoogle,
                isBusy: _isGoogleSubmitting,
                icon: const _GoogleMark(),
              ),
            ],
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
  String? _emailError;
  AuthFeedbackMessage? _feedback;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _clearFeedback({
    bool clearBanner = true,
    bool clearEmail = true,
    bool clearNotice = true,
  }) {
    final shouldUpdate = (clearBanner && _feedback != null) ||
        (clearEmail && _emailError != null);

    if (shouldUpdate) {
      setState(() {
        if (clearBanner) {
          _feedback = null;
        }
        if (clearEmail) {
          _emailError = null;
        }
      });
    }

    if (clearNotice) {
      ref.read(authNoticeProvider.notifier).clear();
    }
  }

  void _applyFeedback(AuthFeedbackMessage feedback) {
    setState(() {
      _feedback = feedback;
      _emailError = feedback.field == AuthFieldTarget.email
          ? (feedback.fieldMessage ?? feedback.message)
          : null;
    });
  }

  Future<void> _submit() async {
    _clearFeedback();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      await ref.read(authControllerProvider.notifier).sendPasswordReset(
            _emailController.text.trim(),
          );

      if (!mounted) {
        return;
      }
      _applyFeedback(
        passwordResetEmailSentFeedback(
          context,
          _emailController.text.trim(),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _applyFeedback(
        resolveAuthFeedback(
          context,
          error,
          intent: AuthErrorContext.forgotPassword,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authNoticeCode = ref.watch(authNoticeProvider);
    final activeFeedback = _feedback ??
        (authNoticeCode == null
            ? null
            : feedbackForAuthNotice(context, authNoticeCode));

    return AuthScaffold(
      title: context.l10n.forgotPasswordTitle,
      subtitle: context.l10n.forgotPasswordSubtitle,
      notice: _buildAuthNotice(activeFeedback),
      canPop: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onChanged: (_) => _clearFeedback(),
              onFieldSubmitted: (_) => _submit(),
              forceErrorText: _emailError,
              decoration: InputDecoration(
                labelText: context.l10n.emailLabel,
                prefixIcon: const Icon(Icons.mail_outline_rounded),
              ),
              validator: (value) =>
                  context.validationMessage(Validators.email(value)),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _BusyLabel(
                isBusy: _isSubmitting,
                idleLabel: context.l10n.sendResetLinkAction,
              ),
            ),
          ],
        ),
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

  String? _passwordError;
  String? _confirmError;
  AuthFeedbackMessage? _feedback;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _clearFeedback({
    bool clearBanner = true,
    bool clearPassword = true,
    bool clearConfirm = true,
    bool clearNotice = true,
  }) {
    final shouldUpdate = (clearBanner && _feedback != null) ||
        (clearPassword && _passwordError != null) ||
        (clearConfirm && _confirmError != null);

    if (shouldUpdate) {
      setState(() {
        if (clearBanner) {
          _feedback = null;
        }
        if (clearPassword) {
          _passwordError = null;
        }
        if (clearConfirm) {
          _confirmError = null;
        }
      });
    }

    if (clearNotice) {
      ref.read(authNoticeProvider.notifier).clear();
    }
  }

  void _applyFeedback(AuthFeedbackMessage feedback) {
    setState(() {
      _feedback = feedback;
      _passwordError = feedback.field == AuthFieldTarget.password
          ? (feedback.fieldMessage ?? feedback.message)
          : null;
      _confirmError = feedback.field == AuthFieldTarget.confirmPassword
          ? (feedback.fieldMessage ?? feedback.message)
          : null;
    });
  }

  Future<void> _submit() async {
    _clearFeedback();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .updatePassword(_passwordController.text);
      if (!mounted) {
        return;
      }
      context.showSuccessNotification(_resetPasswordSuccess(context));
    } catch (error) {
      if (!mounted) {
        return;
      }
      _applyFeedback(
        resolveAuthFeedback(
          context,
          error,
          intent: AuthErrorContext.resetPassword,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeFeedback = _feedback;

    return AuthScaffold(
      title: _resetPasswordTitle(context),
      subtitle: _resetPasswordSubtitle(context),
      notice: _buildAuthNotice(activeFeedback),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (activeFeedback?.isRecoveryIssue ?? false) ...[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () => context.go(ForgotPasswordScreen.routePath),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(requestNewResetLinkLabel(context)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _clearFeedback(
                clearPassword: true,
                clearConfirm: false,
              ),
              forceErrorText: _passwordError,
              decoration: InputDecoration(
                labelText: context.l10n.passwordLabel,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () => setState(
                    () => _obscurePassword = !_obscurePassword,
                  ),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                ),
              ),
              validator: (value) => context.validationMessage(
                Validators.minLength(value, 6),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              onChanged: (_) => _clearFeedback(
                clearPassword: false,
                clearConfirm: true,
              ),
              onFieldSubmitted: (_) => _submit(),
              forceErrorText: _confirmError,
              decoration: InputDecoration(
                labelText: context.l10n.confirmPasswordLabel,
                prefixIcon: const Icon(Icons.verified_user_outlined),
                suffixIcon: IconButton(
                  onPressed: () => setState(
                    () => _obscureConfirm = !_obscureConfirm,
                  ),
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                ),
              ),
              validator: (value) {
                final message =
                    context.validationMessage(Validators.minLength(value, 6));
                if (message != null) {
                  return message;
                }
                if (value != _passwordController.text) {
                  return context.l10n.passwordsDoNotMatch;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _BusyLabel(
                isBusy: _isSubmitting,
                idleLabel: _resetPasswordAction(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BusyLabel extends StatelessWidget {
  const _BusyLabel({
    required this.isBusy,
    required this.idleLabel,
  });

  final bool isBusy;
  final String idleLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isBusy)
          SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        if (isBusy) const SizedBox(width: AppSpacing.sm),
        Flexible(child: Text(idleLabel)),
      ],
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        'G',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
