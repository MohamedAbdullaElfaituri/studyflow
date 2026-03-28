import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    const supportedLanguageCodes = {'en', 'tr', 'ar'};
    final rawLanguage = ref.watch(appLocalePreferenceProvider) ?? 'en';
    final selectedLanguage =
        supportedLanguageCodes.contains(rawLanguage) ? rawLanguage : 'en';
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
          Row(
            children: [
              Expanded(
                child: Text(
                  context.copy.chooseLanguageTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).completeOnboarding();
                  if (!mounted) return;
                  context.go(LoginScreen.routePath);
                },
                child: Text(context.l10n.skipAction),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.copy.chooseLanguageSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _LanguageChip(
                label: context.l10n.englishLabel,
                selected: selectedLanguage == 'en',
                onSelected: () async {
                  HapticFeedback.selectionClick();
                  await ref
                      .read(appLocalePreferenceProvider.notifier)
                      .setLocale('en');
                },
              ),
              _LanguageChip(
                label: context.l10n.turkishLabel,
                selected: selectedLanguage == 'tr',
                onSelected: () async {
                  HapticFeedback.selectionClick();
                  await ref
                      .read(appLocalePreferenceProvider.notifier)
                      .setLocale('tr');
                },
              ),
              _LanguageChip(
                label: context.l10n.arabicLabel,
                selected: selectedLanguage == 'ar',
                onSelected: () async {
                  HapticFeedback.selectionClick();
                  await ref
                      .read(appLocalePreferenceProvider.notifier)
                      .setLocale('ar');
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
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
                    GradientBanner(
                      colors: [
                        scheme.primary,
                        scheme.secondary,
                        scheme.tertiary,
                      ],
                      child: SizedBox(
                        width: 240,
                        height: 220,
                        child: Center(
                          child: Icon(slide.icon, size: 92, color: Colors.white),
                        ),
                      ),
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
                      : scheme.outlineVariant.withOpacity(0.5),
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
                  duration: const Duration(milliseconds: 320),
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

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final Future<void> Function() onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        overflow: TextOverflow.ellipsis,
      ),
      selected: selected,
      onSelected: (_) {
        onSelected();
      },
    );
  }
}
