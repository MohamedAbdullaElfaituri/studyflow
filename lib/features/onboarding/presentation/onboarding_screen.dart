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

  Future<void> _finish() async {
    await ref.read(authControllerProvider.notifier).completeOnboarding();
    if (!mounted) {
      return;
    }
    context.go(LoginScreen.routePath);
  }

  @override
  Widget build(BuildContext context) {
    const supportedLanguageCodes = {'en', 'tr', 'ar'};
    final rawLanguage = ref.watch(appLocalePreferenceProvider) ?? 'en';
    final selectedLanguage =
        supportedLanguageCodes.contains(rawLanguage) ? rawLanguage : 'en';
    final scheme = Theme.of(context).colorScheme;

    final slides = [
      (
        icon: Icons.checklist_rounded,
        title: context.l10n.onboardingTitleOne,
        subtitle: context.l10n.onboardingSubtitleOne,
      ),
      (
        icon: Icons.insights_rounded,
        title: context.l10n.onboardingTitleTwo,
        subtitle: context.l10n.onboardingSubtitleTwo,
      ),
      (
        icon: Icons.translate_rounded,
        title: context.l10n.onboardingTitleThree,
        subtitle: context.l10n.onboardingSubtitleThree,
      ),
    ];

    final isLastPage = _index == slides.length - 1;

    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const AppLogo(size: 44),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  context.l10n.appName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton(
                onPressed: _finish,
                child: Text(context.l10n.skipAction),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            context.copy.chooseLanguageTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.copy.chooseLanguageSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _LanguageChip(
                  label: 'EN',
                  semanticLabel: context.l10n.englishLabel,
                  selected: selectedLanguage == 'en',
                  onSelected: () async {
                    HapticFeedback.selectionClick();
                    await ref
                        .read(appLocalePreferenceProvider.notifier)
                        .setLocale('en');
                  },
                ),
                _LanguageChip(
                  label: 'TR',
                  semanticLabel: context.l10n.turkishLabel,
                  selected: selectedLanguage == 'tr',
                  onSelected: () async {
                    HapticFeedback.selectionClick();
                    await ref
                        .read(appLocalePreferenceProvider.notifier)
                        .setLocale('tr');
                  },
                ),
                _LanguageChip(
                  label: 'AR',
                  semanticLabel: context.l10n.arabicLabel,
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
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (value) => setState(() => _index = value),
              itemCount: slides.length,
              itemBuilder: (context, index) {
                final slide = slides[index];
                return RevealOnBuild(
                  key: ValueKey(index),
                  child: SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Icon(
                            slide.icon,
                            size: 42,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          slide.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          slide.subtitle,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              slides.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _index == index ? 26 : 10,
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
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () async {
              if (isLastPage) {
                await _finish();
              } else {
                await _controller.nextPage(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                );
              }
            },
            child: Text(
              isLastPage ? context.l10n.finishAction : context.l10n.nextAction,
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
    this.semanticLabel,
  });

  final String label;
  final bool selected;
  final Future<void> Function() onSelected;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel ?? label,
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}
