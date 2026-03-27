import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/extensions/build_context_x.dart';
import '../../../shared/providers/app_providers.dart';
import '../../home/presentation/home_screen.dart';
import '../../onboarding/presentation/onboarding_screen.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  static const routePath = '/splash';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authControllerProvider, (previous, next) {
      next.whenData((value) {
        final target = !value.onboardingCompleted
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
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(context).colorScheme.tertiary,
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: Colors.white,
                  size: 46,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                context.l10n.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.l10n.splashSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(strokeWidth: 2.8),
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
  final _emailController = TextEditingController(text: 'student@studyflow.app');
  final _passwordController = TextEditingController(text: 'studyflow123');
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    ref.listenManual(authControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (value) {
          if (value.isAuthenticated && mounted) {
            context.go(HomeScreen.routePath);
          }
        },
        error: (error, _) {
          if (mounted) {
            context.showAppSnackBar(context.resolveError(error));
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
    final auth = ref.watch(authControllerProvider);
    final isLoading = auth.isLoading;

    return _AuthFrame(
      heroTitle: context.l10n.loginTitle,
      heroSubtitle: context.l10n.loginSubtitle,
      heroBadge: 'Mobile premium',
      metrics: const [
        _HeroMetric('Streak sync', 'Live'),
        _HeroMetric('Latency', '<120ms'),
        _HeroMetric('Dark mode', 'Ready'),
      ],
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(context.l10n.noAccountPrompt),
          TextButton(
            onPressed: () => context.push(SignupScreen.routePath),
            child: Text(context.l10n.signUpAction),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Your study identity, planner, and focus analytics are ready.',
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
                  decoration: InputDecoration(
                    labelText: context.l10n.emailLabel,
                    prefixIcon: const Icon(Icons.alternate_email_rounded),
                  ),
                  validator: (value) => context.validationMessage(
                    Validators.email(value),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: context.l10n.passwordLabel,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
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
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          await ref.read(authControllerProvider.notifier).signIn(
                                email: _emailController.text,
                                password: _passwordController.text,
                              );
                        },
                  child: _AsyncLabel(
                    isLoading: isLoading,
                    label: context.l10n.loginAction,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _AuthDivider(label: context.copy.authDivider),
          const SizedBox(height: AppSpacing.lg),
          _GoogleButton(
            label: context.copy.continueWithGoogle,
            isLoading: isLoading,
            onPressed: () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
          ),
        ],
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
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    ref.listenManual(authControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (value) {
          if (value.isAuthenticated && mounted) {
            context.go(HomeScreen.routePath);
          }
        },
        error: (error, _) {
          if (mounted) {
            context.showAppSnackBar(context.resolveError(error));
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
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return _AuthFrame(
      canPop: true,
      heroTitle: context.l10n.signUpTitle,
      heroSubtitle: context.l10n.signUpSubtitle,
      heroBadge: 'Personal identity',
      metrics: const [
        _HeroMetric('Profile', 'Rich'),
        _HeroMetric('Motion', 'Smooth'),
        _HeroMetric('RTL', 'Arabic'),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create your mobile workspace',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Build a premium study planner with clear hierarchy and dark mode.',
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
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: context.l10n.fullNameLabel,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                  validator: (value) => context.validationMessage(
                    Validators.requiredField(value),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: context.l10n.emailLabel,
                    prefixIcon: const Icon(Icons.alternate_email_rounded),
                  ),
                  validator: (value) => context.validationMessage(
                    Validators.email(value),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: context.l10n.passwordLabel,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) => context.validationMessage(
                    Validators.minLength(value, 6),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: context.l10n.confirmPasswordLabel,
                    prefixIcon: const Icon(Icons.lock_person_outlined),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
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
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
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
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _AuthDivider(label: context.copy.authDivider),
          const SizedBox(height: AppSpacing.lg),
          _GoogleButton(
            label: context.copy.continueWithGoogle,
            isLoading: isLoading,
            onPressed: () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    return _AuthFrame(
      canPop: true,
      heroTitle: context.l10n.forgotPasswordTitle,
      heroSubtitle: context.l10n.forgotPasswordSubtitle,
      heroBadge: 'Recovery',
      metrics: const [
        _HeroMetric('Feedback', 'Instant'),
        _HeroMetric('Flow', 'Simple'),
        _HeroMetric('Security', 'Safe'),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reset your password',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'We will send a recovery link so you can safely re-enter your workspace.',
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
                  decoration: InputDecoration(
                    labelText: context.l10n.emailLabel,
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (value) => context.validationMessage(
                    Validators.email(value),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          setState(() => _isSubmitting = true);
                          try {
                            await ref
                                .read(authControllerProvider.notifier)
                                .sendPasswordReset(_emailController.text);
                            if (!mounted) {
                              return;
                            }
                            context.showAppSnackBar(
                              context.l10n.resetPasswordSentMessage,
                            );
                            context.pop();
                          } catch (error) {
                            if (!mounted) {
                              return;
                            }
                            context.showAppSnackBar(
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

class _AuthFrame extends StatelessWidget {
  const _AuthFrame({
    required this.heroTitle,
    required this.heroSubtitle,
    required this.heroBadge,
    required this.metrics,
    required this.child,
    this.footer,
    this.canPop = false,
  });

  final String heroTitle;
  final String heroSubtitle;
  final String heroBadge;
  final List<_HeroMetric> metrics;
  final Widget child;
  final Widget? footer;
  final bool canPop;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (canPop)
              RevealOnBuild(
                child: IconButton(
                  onPressed: context.pop,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
            RevealOnBuild(
              child: GradientBanner(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        heroBadge,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      heroTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      heroSubtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.84),
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: metrics
                          .map(
                            (item) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.value,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.white.withOpacity(0.84),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            RevealOnBuild(
              delay: const Duration(milliseconds: 120),
              child: SectionCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: child,
              ),
            ),
            if (footer != null) ...[
              const SizedBox(height: AppSpacing.lg),
              RevealOnBuild(
                delay: const Duration(milliseconds: 220),
                child: footer!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AuthDivider extends StatelessWidget {
  const _AuthDivider({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Theme.of(context).dividerColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(label),
        ),
        Expanded(child: Divider(color: Theme.of(context).dividerColor)),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading
          ? null
          : () async {
              await onPressed();
            },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'G',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
      duration: const Duration(milliseconds: 220),
      child: isLoading
          ? const SizedBox(
              key: ValueKey('loading'),
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            )
          : Text(
              label,
              key: const ValueKey('label'),
            ),
    );
  }
}

class _HeroMetric {
  const _HeroMetric(this.label, this.value);

  final String label;
  final String value;
}
