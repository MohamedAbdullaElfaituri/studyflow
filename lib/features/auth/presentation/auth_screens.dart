// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/extensions/build_context_x.dart';
import '../../../shared/providers/app_providers.dart';
import '../../home/presentation/home_screen.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import 'auth_copy.dart';

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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
    final isCloudSyncEnabled = ref.watch(isCloudSyncEnabledProvider);
    final copy = AuthCopy.of(context);

    return _AuthFrame(
      heroTitle: context.l10n.loginTitle,
      heroSubtitle: context.l10n.loginSubtitle,
      heroBadge: isCloudSyncEnabled ? copy.loginHeroBadge : copy.demoHeroBadge,
      metrics: [
        _HeroMetric(
          copy.streakSyncLabel,
          isCloudSyncEnabled ? copy.liveValue : copy.localValue,
        ),
        _HeroMetric(copy.latencyLabel, '<120ms'),
        _HeroMetric(copy.darkModeLabel, copy.readyValue),
      ],
      footer: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
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
            copy.loginIntroTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            copy.loginIntroSubtitle,
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
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
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
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
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
                    onPressed: () =>
                        context.push(ForgotPasswordScreen.routePath),
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
                  child: _AsyncLabel(
                    isLoading: isLoading,
                    label: context.l10n.loginAction,
                  ),
                ),
              ],
            ),
          ),
          if (isCloudSyncEnabled) ...[
            const SizedBox(height: AppSpacing.xl),
            _AuthDivider(label: context.copy.authDivider),
            const SizedBox(height: AppSpacing.lg),
            _GoogleButton(
              label: context.copy.continueWithGoogle,
              isLoading: isLoading,
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).signInWithGoogle(),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.xl),
            _DemoWorkspaceCard(
              title: context.l10n.demoAccountTitle,
              description: context.l10n.demoAccountDescription,
              credentialsLabel: copy.demoCredentialsLabel,
              email: AppConstants.demoEmail,
              password: AppConstants.demoPassword,
              buttonLabel: copy.enterDemoWorkspace,
              isLoading: isLoading,
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).signInWithDemo(),
            ),
          ],
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
    final isCloudSyncEnabled = ref.watch(isCloudSyncEnabledProvider);
    final copy = AuthCopy.of(context);

    return _AuthFrame(
      canPop: true,
      heroTitle: context.l10n.signUpTitle,
      heroSubtitle: context.l10n.signUpSubtitle,
      heroBadge: isCloudSyncEnabled ? copy.signupHeroBadge : copy.demoHeroBadge,
      metrics: [
        _HeroMetric(copy.profileLabel, copy.richValue),
        _HeroMetric(copy.motionLabel, copy.smoothValue),
        _HeroMetric(copy.rtlLabel, copy.arabicValue),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            copy.signupIntroTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            copy.signupIntroSubtitle,
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
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
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
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
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
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
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
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
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
                          await ref
                              .read(authControllerProvider.notifier)
                              .signUp(
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
          if (isCloudSyncEnabled) ...[
            const SizedBox(height: AppSpacing.lg),
            _AuthDivider(label: context.copy.authDivider),
            const SizedBox(height: AppSpacing.lg),
            _GoogleButton(
              label: context.copy.continueWithGoogle,
              isLoading: isLoading,
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).signInWithGoogle(),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.xl),
            _DemoWorkspaceCard(
              title: context.l10n.demoAccountTitle,
              description: context.l10n.demoAccountDescription,
              credentialsLabel: copy.demoCredentialsLabel,
              email: AppConstants.demoEmail,
              password: AppConstants.demoPassword,
              buttonLabel: copy.enterDemoWorkspace,
              isLoading: isLoading,
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).signInWithDemo(),
            ),
          ],
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
    final copy = AuthCopy.of(context);
    return _AuthFrame(
      canPop: true,
      heroTitle: context.l10n.forgotPasswordTitle,
      heroSubtitle: context.l10n.forgotPasswordSubtitle,
      heroBadge: copy.recoveryBadge,
      metrics: [
        _HeroMetric(copy.feedbackLabel, copy.instantValue),
        _HeroMetric(copy.flowLabel, copy.simpleValue),
        _HeroMetric(copy.securityLabel, copy.safeValue),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            copy.resetTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            copy.resetSubtitle,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 920;
          final maxContentWidth = isWide ? 1120.0 : 560.0;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (canPop)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: RevealOnBuild(
                          child: IconButton(
                            onPressed: context.pop,
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                      ),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 11,
                            child: RevealOnBuild(
                              child: _AuthHeroPanel(
                                heroTitle: heroTitle,
                                heroSubtitle: heroSubtitle,
                                heroBadge: heroBadge,
                                metrics: metrics,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xl),
                          Expanded(
                            flex: 10,
                            child: RevealOnBuild(
                              delay: const Duration(milliseconds: 120),
                              child: SectionCard(
                                padding: const EdgeInsets.all(AppSpacing.xl),
                                child: child,
                              ),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      RevealOnBuild(
                        child: _AuthHeroPanel(
                          heroTitle: heroTitle,
                          heroSubtitle: heroSubtitle,
                          heroBadge: heroBadge,
                          metrics: metrics,
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
                    ],
                    if (footer != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      RevealOnBuild(
                        delay: const Duration(milliseconds: 220),
                        child: Center(child: footer!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AuthHeroPanel extends StatelessWidget {
  const _AuthHeroPanel({
    required this.heroTitle,
    required this.heroSubtitle,
    required this.heroBadge,
    required this.metrics,
  });

  final String heroTitle;
  final String heroSubtitle;
  final String heroBadge;
  final List<_HeroMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 460;

        return GradientBanner(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (compact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _StudyFlowLogo(size: 102),
                    const SizedBox(height: AppSpacing.lg),
                    _HeroBadge(label: heroBadge),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'StudyFlow',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withOpacity(0.84),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      heroTitle,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _StudyFlowLogo(size: 118),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeroBadge(label: heroBadge),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'StudyFlow',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white.withOpacity(0.84),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            heroTitle,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            heroSubtitle,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.white.withOpacity(0.84),
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: AppSpacing.xl),
              const _LanguageReadinessRow(),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: metrics
                    .map((item) => _HeroMetricTile(metric: item))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StudyFlowLogo extends StatelessWidget {
  const _StudyFlowLogo({
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.28,
            child: Container(
              width: size * 0.88,
              height: size * 0.88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.26),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF9DEBFF),
                    Color(0xFF4EE0C1),
                    Color(0xFFFFC36F),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.14),
                    blurRadius: 26,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
            ),
          ),
          Transform.rotate(
            angle: 0.22,
            child: Container(
              width: size * 0.66,
              height: size * 0.66,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.22),
                color: Colors.white.withOpacity(0.2),
                border: Border.all(color: Colors.white.withOpacity(0.28)),
              ),
            ),
          ),
          Container(
            width: size * 0.48,
            height: size * 0.48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.16),
              color: Colors.white,
            ),
            child: Padding(
              padding: EdgeInsets.all(size * 0.08),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      height: size * 0.16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF18456B),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  SizedBox(width: size * 0.04),
                  Expanded(
                    child: Container(
                      height: size * 0.24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2BAE9A),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  SizedBox(width: size * 0.04),
                  Expanded(
                    child: Container(
                      height: size * 0.32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4A261),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: size * 0.12,
            right: size * 0.12,
            child: Container(
              width: size * 0.12,
              height: size * 0.12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _LanguageReadinessRow extends StatelessWidget {
  const _LanguageReadinessRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: const [
        _LanguagePill(label: 'EN'),
        _LanguagePill(label: 'AR'),
        _LanguagePill(label: 'TR'),
      ],
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _HeroMetricTile extends StatelessWidget {
  const _HeroMetricTile({
    required this.metric,
  });

  final _HeroMetric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            metric.value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            metric.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.84),
                ),
          ),
        ],
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

class _DemoWorkspaceCard extends StatelessWidget {
  const _DemoWorkspaceCard({
    required this.title,
    required this.description,
    required this.credentialsLabel,
    required this.email,
    required this.password,
    required this.buttonLabel,
    required this.isLoading,
    required this.onPressed,
  });

  final String title;
  final String description;
  final String credentialsLabel;
  final String email;
  final String password;
  final String buttonLabel;
  final bool isLoading;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withOpacity(0.34),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primary.withOpacity(0.14),
                  child:
                      Icon(Icons.rocket_launch_rounded, color: scheme.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              credentialsLabel,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _CredentialPill(label: email),
                _CredentialPill(label: password),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.tonal(
              onPressed: isLoading
                  ? null
                  : () async {
                      await onPressed();
                    },
              child: _AsyncLabel(
                isLoading: isLoading,
                label: buttonLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CredentialPill extends StatelessWidget {
  const _CredentialPill({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.45),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium,
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

class _AuthCopy {
  const _AuthCopy(this.code);

  final String code;

  static _AuthCopy of(BuildContext context) =>
      _AuthCopy(Localizations.localeOf(context).languageCode);

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
        tr: 'Kisisel kimlik',
        ar: 'هوية شخصية',
      );
  String get recoveryBadge => _pick(
        en: 'Recovery',
        tr: 'Kurtarma',
        ar: 'استعادة الحساب',
      );
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
        tr: 'Karanlik mod',
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
        tr: 'Akis',
        ar: 'التدفق',
      );
  String get securityLabel => _pick(
        en: 'Security',
        tr: 'Guvenlik',
        ar: 'الأمان',
      );
  String get liveValue => _pick(
        en: 'Live',
        tr: 'Canli',
        ar: 'مباشر',
      );
  String get readyValue => _pick(
        en: 'Ready',
        tr: 'Hazir',
        ar: 'جاهز',
      );
  String get richValue => _pick(
        en: 'Rich',
        tr: 'Zengin',
        ar: 'غني',
      );
  String get smoothValue => _pick(
        en: 'Smooth',
        tr: 'Akici',
        ar: 'سلس',
      );
  String get arabicValue => _pick(
        en: 'Arabic',
        tr: 'Arapca',
        ar: 'العربية',
      );
  String get instantValue => _pick(
        en: 'Instant',
        tr: 'Anlik',
        ar: 'فوري',
      );
  String get simpleValue => _pick(
        en: 'Simple',
        tr: 'Sade',
        ar: 'بسيط',
      );
  String get safeValue => _pick(
        en: 'Safe',
        tr: 'Guvenli',
        ar: 'آمن',
      );
  String get loginIntroTitle => _pick(
        en: 'Welcome back',
        tr: 'Tekrar hos geldin',
        ar: 'مرحباً بعودتك',
      );
  String get loginIntroSubtitle => _pick(
        en: 'Your study identity, planner, and focus analytics are ready.',
        tr: 'Calisma kimligin, planlayicin ve odak analizlerin hazir.',
        ar: 'هوية دراستك والمخطط وتحليلات التركيز جاهزة.',
      );
  String get signupIntroTitle => _pick(
        en: 'Create your mobile workspace',
        tr: 'Mobil calisma alanini olustur',
        ar: 'أنشئ مساحة الدراسة على الهاتف',
      );
  String get signupIntroSubtitle => _pick(
        en: 'Build a premium study planner with clear hierarchy and dark mode.',
        tr: 'Net hiyerarsiye ve karanlik moda sahip premium bir planlayici kur.',
        ar: 'ابنِ مخطط دراسة مميزاً بهرمية واضحة ووضع داكن.',
      );
  String get resetTitle => _pick(
        en: 'Reset your password',
        tr: 'Sifreni yenile',
        ar: 'أعد تعيين كلمة المرور',
      );
  String get resetSubtitle => _pick(
        en: 'We will send a recovery link so you can safely re-enter your workspace.',
        tr: 'Calisma alanina guvenli sekilde donmen icin bir kurtarma baglantisi gonderecegiz.',
        ar: 'سنرسل رابط استعادة لتتمكن من العودة إلى مساحتك بأمان.',
      );
}
