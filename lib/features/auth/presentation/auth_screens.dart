import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/extensions/build_context_x.dart';
import '../../../shared/providers/app_providers.dart';
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
    'tr' => 'Uygulamayi kesfet',
    'ar' => 'استكشف التطبيق',
    _ => 'Explore the app',
  };
}

String _alreadyHaveAccountPrompt(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Zaten bir hesabin var mi?',
    'ar' => 'هل لديك حساب بالفعل؟',
    _ => 'Already have an account?',
  };
}

String _authLoadingTitle(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Hesabin hazirlaniyor',
    'ar' => 'جار تجهيز حسابك',
    _ => 'Preparing your account',
  };
}

String _authLoadingSubtitle(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Lutfen bekle, seni dogrudan ana ekrana goturuyoruz.',
    'ar' => 'يرجى الانتظار، سيتم نقلك مباشرة إلى الصفحة الرئيسية.',
    _ => 'Please wait while we take you straight to the home screen.',
  };
}

String _signupConfirmationMessage(BuildContext context, String email) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' =>
      '$email adresine onay baglantisi gonderildi. E-postani onayladiktan sonra giris yap.',
    'ar' =>
      'أرسلنا رابط تأكيد إلى $email. أكّد بريدك الإلكتروني ثم سجّل الدخول.',
    _ =>
      'A confirmation link was sent to $email. Verify your email, then sign in.',
  };
}

String _resetPasswordTitle(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Yeni bir sifre belirle',
    'ar' => 'عيّن كلمة مرور جديدة',
    _ => 'Create a new password',
  };
}

String _resetPasswordSubtitle(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Hesabina tekrar erisebilmek icin yeni sifreni gir.',
    'ar' => 'أدخل كلمة مرور جديدة لإكمال استعادة الوصول إلى حسابك.',
    _ => 'Enter a new password to finish restoring access to your account.',
  };
}

String _resetPasswordAction(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Sifreyi guncelle',
    'ar' => 'تحديث كلمة المرور',
    _ => 'Update password',
  };
}

String _resetPasswordSuccess(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Sifren guncellendi.',
    'ar' => 'تم تحديث كلمة المرور بنجاح.',
    _ => 'Your password was updated.',
  };
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const routePath = '/splash';

  @override
  Widget build(BuildContext context) {
    return AppPage(
      padding: EdgeInsets.zero,
      child: Center(
        child: Semantics(
          label: 'StudyFlow',
          child: Image.asset(
            'assets/branding/app_logo.png',
            width: 104,
            height: 104,
            fit: BoxFit.contain,
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
      if (!mounted) {
        return;
      }
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
    } catch (error) {
      if (!mounted) {
        return;
      }
      context.showErrorNotification(context.resolveError(error));
    } finally {
      if (mounted) {
        setState(() => _isGoogleSubmitting = false);
      }
    }
  }

  Future<void> _signInWithDemo() async {
    FocusScope.of(context).unfocus();
    setState(() => _isDemoSubmitting = true);
    try {
      await ref.read(authControllerProvider.notifier).signInWithDemo();
    } catch (error) {
      if (!mounted) {
        return;
      }
      context.showErrorNotification(context.resolveError(error));
    } finally {
      if (mounted) {
        setState(() => _isDemoSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCloudSyncEnabled = ref.watch(isCloudSyncEnabledProvider);

    return AuthScaffold(
      title: context.l10n.loginTitle,
      subtitle: context.l10n.loginSubtitle,
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
              onFieldSubmitted: (_) => _submit(),
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

      if (!mounted) {
        return;
      }

      if (result.requiresEmailConfirmation) {
        context.showSuccessNotification(
          _signupConfirmationMessage(context, result.email),
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
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
    } catch (error) {
      if (!mounted) {
        return;
      }
      context.showErrorNotification(context.resolveError(error));
    } finally {
      if (mounted) {
        setState(() => _isGoogleSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCloudSyncEnabled = ref.watch(isCloudSyncEnabledProvider);

    return AuthScaffold(
      title: context.l10n.signUpTitle,
      subtitle: context.l10n.signUpSubtitle,
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
              onFieldSubmitted: (_) => _submit(),
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

      if (!mounted) {
        return;
      }
      context.showSuccessNotification(context.l10n.resetPasswordSentMessage);
      context.go(LoginScreen.routePath);
    } catch (error) {
      if (!mounted) {
        return;
      }
      context.showErrorNotification(context.resolveError(error));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: context.l10n.forgotPasswordTitle,
      subtitle: context.l10n.forgotPasswordSubtitle,
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
              onFieldSubmitted: (_) => _submit(),
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
      if (!mounted) {
        return;
      }
      context.showSuccessNotification(_resetPasswordSuccess(context));
    } catch (error) {
      if (!mounted) {
        return;
      }
      context.showErrorNotification(context.resolveError(error));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: _resetPasswordTitle(context),
      subtitle: _resetPasswordSubtitle(context),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
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
              onFieldSubmitted: (_) => _submit(),
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
