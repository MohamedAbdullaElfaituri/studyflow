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

    final scheme = Theme.of(context).colorScheme;

    return AppPage(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(Icons.auto_graph_rounded, size: 42, color: scheme.primary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              context.l10n.appName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.splashSubtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
          ],
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

    return AppPage(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            GradientBanner(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.loginTitle,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.l10n.loginSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.84),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionCard(
              child: Form(
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
                              await ref
                                  .read(authControllerProvider.notifier)
                                  .signIn(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  );
                            },
                      child: Text(context.l10n.loginAction),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text(context.copy.authDivider),
                ),
                Expanded(child: Divider(color: Theme.of(context).dividerColor)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _SocialAuthButtons(
              googleLabel: context.copy.continueWithGoogle,
              appleLabel: context.copy.continueWithApple,
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.demoAccountTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    context.l10n.demoAccountDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(context.l10n.noAccountPrompt),
                TextButton(
                  onPressed: () => context.push(SignupScreen.routePath),
                  child: Text(context.l10n.signUpAction),
                ),
              ],
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
  final _confirmPasswordController = TextEditingController();

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

    return AppPage(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: context.pop,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.signUpTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.signUpSubtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            SectionCard(
              child: Form(
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
                        prefixIcon: const Icon(Icons.mail_outline_rounded),
                      ),
                      validator: (value) => context.validationMessage(
                        Validators.email(value),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: context.l10n.passwordLabel,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                      ),
                      validator: (value) => context.validationMessage(
                        Validators.minLength(value, 6),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: context.l10n.confirmPasswordLabel,
                        prefixIcon: const Icon(Icons.lock_person_outlined),
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
                              await ref
                                  .read(authControllerProvider.notifier)
                                  .signUp(
                                    fullName: _nameController.text,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  );
                            },
                      child: Text(context.l10n.createAccountAction),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text(context.copy.authDivider),
                ),
                Expanded(child: Divider(color: Theme.of(context).dividerColor)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _SocialAuthButtons(
              googleLabel: context.copy.continueWithGoogle,
              appleLabel: context.copy.continueWithApple,
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

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: context.pop,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.forgotPasswordTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.forgotPasswordSubtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            SectionCard(
              child: Form(
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
                                if (!mounted) return;
                                context.showAppSnackBar(
                                  context.l10n.resetPasswordSentMessage,
                                );
                                context.pop();
                              } catch (error) {
                                if (!mounted) return;
                                context.showAppSnackBar(
                                  context.resolveError(error),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() => _isSubmitting = false);
                                }
                              }
                            },
                      child: Text(context.l10n.sendResetLinkAction),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialAuthButtons extends StatelessWidget {
  const _SocialAuthButtons({
    required this.googleLabel,
    required this.appleLabel,
  });

  final String googleLabel;
  final String appleLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.g_mobiledata_rounded),
            label: Text(googleLabel),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.apple_rounded),
            label: Text(appleLabel),
          ),
        ),
      ],
    );
  }
}
