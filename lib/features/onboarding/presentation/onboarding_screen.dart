import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/extensions/build_context_x.dart';
import '../../../shared/providers/app_providers.dart';
import '../../auth/presentation/auth_screens.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const routePath = '/onboarding';

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = [
      (
        icon: Icons.auto_graph_rounded,
        title: context.l10n.onboardingTitleOne,
        subtitle: context.l10n.onboardingSubtitleOne,
      ),
      (
        icon: Icons.insights_rounded,
        title: context.l10n.onboardingTitleTwo,
        subtitle: context.l10n.onboardingSubtitleTwo,
      ),
      (
        icon: Icons.language_rounded,
        title: context.l10n.onboardingTitleThree,
        subtitle: context.l10n.onboardingSubtitleThree,
      ),
    ];

    final lastPage = _index == slides.length - 1;
    final scheme = Theme.of(context).colorScheme;

    return AppPage(
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).completeOnboarding();
                if (!mounted) return;
                context.go(LoginScreen.routePath);
              },
              child: Text(context.l10n.skipAction),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: slides.length,
              onPageChanged: (value) => setState(() => _index = value),
              itemBuilder: (context, index) {
                final slide = slides[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            scheme.primaryContainer,
                            scheme.tertiaryContainer,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Icon(slide.icon, size: 72, color: scheme.primary),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      slide.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Text(
                        slide.subtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              slides.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _index == index ? 28 : 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _index == index
                      ? scheme.primary
                      : scheme.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: () async {
              if (lastPage) {
                await ref.read(authControllerProvider.notifier).completeOnboarding();
                if (!mounted) return;
                context.go(LoginScreen.routePath);
              } else {
                await _controller.nextPage(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                );
              }
            },
            child: Text(
              lastPage ? context.l10n.finishAction : context.l10n.nextAction,
            ),
          ),
        ],
      ),
    );
  }
}
