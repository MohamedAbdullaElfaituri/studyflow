// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/extensions/build_context_x.dart';
import '../../../shared/providers/app_providers.dart';
import '../../home/presentation/home_screen.dart';
import '../../onboarding/presentation/onboarding_screen.dart';

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

// ─────────────────────────────────────────────
//  SPLASH
// ─────────────────────────────────────────────

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  static const routePath = '/splash';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authControllerProvider, (_, next) {
      next.whenData((value) {
        final target = value.requiresPasswordReset
            ? ResetPasswordScreen.routePath
            : !value.onboardingCompleted
                ? OnboardingScreen.routePath
                : value.isAuthenticated
                    ? HomeScreen.routePath
                    : LoginScreen.routePath;

        if (GoRouterState.of(context).uri.toString() != target) {
          context.go(target);
        }
      });
    });

    return AppPage(
      child: Center(
        child: RevealOnBuild(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _AppLogo(size: 88),
              const SizedBox(height: AppSpacing.xl),
              Text(
                context.l10n.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  LOGIN
// ─────────────────────────────────────────────

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

  @override
  void initState() {
    super.initState();
    ref.listenManual(authControllerProvider, (_, next) {
      next.whenOrNull(
        data: (value) {
          if (!mounted) return;
          if (value.requiresPasswordReset) {
            context.go(ResetPasswordScreen.routePath);
            return;
          }
          if (value.isAuthenticated) {
            context.go(HomeScreen.routePath);
          }
        },
        error: (error, _) {
          if (mounted) {
            context.showErrorNotification(context.resolveError(error));
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

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
            onPressed: () => context.push(SignupScreen.routePath),
            child: Text(context.l10n.signUpAction),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──
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

            // ── Email ──
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.l10n.emailLabel,
                prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
              ),
              validator: (v) => context.validationMessage(Validators.email(v)),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Password ──
            TextFormField(
              controller: _passwordController,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: context.l10n.passwordLabel,
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: _VisibilityToggle(
                  obscure: _obscure,
                  onToggle: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) =>
                  context.validationMessage(Validators.minLength(v, 6)),
            ),

            // ── Forgot password ──
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => context.push(ForgotPasswordScreen.routePath),
                child: Text(context.l10n.forgotPasswordAction),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Submit ──
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      await ref.read(authControllerProvider.notifier).signIn(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                    },
              child: _AsyncLabel(
                  isLoading: isLoading, label: context.l10n.loginAction),
            ),

            // ── Google ──
            const SizedBox(height: AppSpacing.xl),
            _AuthDivider(label: _or(context)),
            const SizedBox(height: AppSpacing.xl),
            _GoogleButton(
              isLoading: isLoading,
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).signInWithGoogle(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SIGNUP
// ─────────────────────────────────────────────

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

  @override
  void initState() {
    super.initState();
    ref.listenManual(authControllerProvider, (_, next) {
      next.whenOrNull(
        data: (value) {
          if (!mounted) return;
          if (value.requiresPasswordReset) {
            context.go(ResetPasswordScreen.routePath);
            return;
          }
          if (value.isAuthenticated) {
            context.go(HomeScreen.routePath);
          }
        },
        error: (error, _) {
          if (mounted) {
            context.showErrorNotification(context.resolveError(error));
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return _AuthShell(
      canPop: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──
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

            // ── Full name ──
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.l10n.fullNameLabel,
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
              ),
              validator: (v) =>
                  context.validationMessage(Validators.requiredField(v)),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Email ──
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.l10n.emailLabel,
                prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
              ),
              validator: (v) => context.validationMessage(Validators.email(v)),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Password ──
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.l10n.passwordLabel,
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: _VisibilityToggle(
                  obscure: _obscurePassword,
                  onToggle: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) =>
                  context.validationMessage(Validators.minLength(v, 6)),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Confirm password ──
            TextFormField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: context.l10n.confirmPasswordLabel,
                prefixIcon: const Icon(Icons.lock_person_outlined, size: 20),
                suffixIcon: _VisibilityToggle(
                  obscure: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (v) {
                if (v != _passwordController.text) {
                  return context.l10n.passwordsDoNotMatch;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Submit ──
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      await ref.read(authControllerProvider.notifier).signUp(
                            fullName: _nameController.text,
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                    },
              child: _AsyncLabel(
                isLoading: isLoading,
                label: context.l10n.createAccountAction,
              ),
            ),

            // ── Google ──
            const SizedBox(height: AppSpacing.xl),
            _AuthDivider(label: _or(context)),
            const SizedBox(height: AppSpacing.xl),
            _GoogleButton(
              isLoading: isLoading,
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).signInWithGoogle(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FORGOT PASSWORD
// ─────────────────────────────────────────────

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
  void initState() {
    super.initState();
    ref.listenManual(authControllerProvider, (_, next) {
      next.whenOrNull(
        data: (value) {
          if (!mounted) return;
          if (value.requiresPasswordReset) {
            context.go(ResetPasswordScreen.routePath);
          }
        },
        error: (error, _) {
          if (mounted) {
            context.showErrorNotification(context.resolveError(error));
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AuthShell(
      canPop: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──
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

          // ── Form ──
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: context.l10n.emailLabel,
                    prefixIcon:
                        const Icon(Icons.mail_outline_rounded, size: 20),
                  ),
                  validator: (v) =>
                      context.validationMessage(Validators.email(v)),
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          setState(() => _isSubmitting = true);
                          try {
                            await ref
                                .read(authControllerProvider.notifier)
                                .sendPasswordReset(_emailController.text);
                            if (!mounted) return;
                            context.showSuccessNotification(
                              context.l10n.resetPasswordSentMessage,
                            );
                            context.pop();
                          } catch (error) {
                            if (!mounted) return;
                            context.showErrorNotification(
                              context.resolveError(error),
                            );
                          } finally {
                            if (mounted) {
                              setState(() => _isSubmitting = false);
                            }
                          }
                        },
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

  @override
  void initState() {
    super.initState();
    ref.listenManual(authControllerProvider, (_, next) {
      next.whenOrNull(
        data: (value) {
          if (!mounted) return;
          if (value.requiresPasswordReset) {
            return;
          }
          if (value.isAuthenticated) {
            context.showSuccessNotification(_resetPasswordFlowSuccess(context));
            context.go(HomeScreen.routePath);
            return;
          }
          context.go(LoginScreen.routePath);
        },
        error: (error, _) {
          if (mounted) {
            context.showErrorNotification(context.resolveError(error));
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

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
              decoration: InputDecoration(
                labelText: context.l10n.passwordLabel,
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: _VisibilityToggle(
                  obscure: _obscurePassword,
                  onToggle: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
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
              decoration: InputDecoration(
                labelText: context.l10n.confirmPasswordLabel,
                prefixIcon: const Icon(Icons.lock_person_outlined, size: 20),
                suffixIcon: _VisibilityToggle(
                  obscure: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
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
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      await ref
                          .read(authControllerProvider.notifier)
                          .updatePassword(_passwordController.text);
                    },
              child: _AsyncLabel(
                isLoading: isLoading,
                label: _resetPasswordFlowAction(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED SHELL
// ─────────────────────────────────────────────

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
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 18),
                          style: IconButton.styleFrom(
                            backgroundColor: scheme.surfaceContainerHighest
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      SizedBox(height: canPop ? AppSpacing.lg : AppSpacing.xxl),
                      if (isWide)
                        // ── Wide: side by side ──
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _LogoPanel()),
                            const SizedBox(width: AppSpacing.xxl),
                            Expanded(
                              child: _FormCard(child: child),
                            ),
                          ],
                        )
                      else ...[
                        // ── Narrow: stacked ──
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

// ─────────────────────────────────────────────
//  LOGO PANEL  (left / top)
// ─────────────────────────────────────────────

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

// ─────────────────────────────────────────────
//  FORM CARD
// ─────────────────────────────────────────────

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

// ─────────────────────────────────────────────
//  APP LOGO
// ─────────────────────────────────────────────

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

// ─────────────────────────────────────────────
//  FALLBACK LOGO  (shown when asset is missing)
// ─────────────────────────────────────────────

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

// ─────────────────────────────────────────────
//  AUTH DIVIDER
// ─────────────────────────────────────────────

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

// ─────────────────────────────────────────────
//  GOOGLE BUTTON
// ─────────────────────────────────────────────

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
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
      onPressed: isLoading ? null : () async => onPressed(),
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

// ─────────────────────────────────────────────
//  VISIBILITY TOGGLE
// ─────────────────────────────────────────────

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

// ─────────────────────────────────────────────
//  ASYNC LABEL
// ─────────────────────────────────────────────

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
