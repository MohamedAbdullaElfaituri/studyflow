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

  Future<void> _completeOnboarding() async {
    await ref.read(authControllerProvider.notifier).completeOnboarding();
    if (!mounted) return;
    context.go(LoginScreen.routePath);
  }

  Future<void> _setLanguage(String code) async {
    HapticFeedback.selectionClick();
    await ref.read(appLocalePreferenceProvider.notifier).setLocale(code);
  }

  Future<void> _nextOrFinish(bool lastPage) async {
    if (lastPage) {
      await _completeOnboarding();
      return;
    }

    await _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    const supportedLanguageCodes = {'en', 'tr', 'ar'};
    final rawLanguage = ref.watch(appLocalePreferenceProvider) ?? 'en';
    final selectedLanguage =
    supportedLanguageCodes.contains(rawLanguage) ? rawLanguage : 'en';

    final slides = <_OnboardingSlideData>[
      _OnboardingSlideData(
        icon: Icons.auto_graph_rounded,
        title: context.l10n.onboardingTitleOne,
        subtitle: context.l10n.onboardingSubtitleOne,
      ),
      _OnboardingSlideData(
        icon: Icons.insights_rounded,
        title: context.l10n.onboardingTitleTwo,
        subtitle: context.l10n.onboardingSubtitleTwo,
      ),
      _OnboardingSlideData(
        icon: Icons.language_rounded,
        title: context.l10n.onboardingTitleThree,
        subtitle: context.l10n.onboardingSubtitleThree,
      ),
    ];

    final lastPage = _index == slides.length - 1;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppPage(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _LanguageChip(
                        label: context.l10n.englishLabel,
                        selected: selectedLanguage == 'en',
                        onSelected: () => _setLanguage('en'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _LanguageChip(
                        label: context.l10n.turkishLabel,
                        selected: selectedLanguage == 'tr',
                        onSelected: () => _setLanguage('tr'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _LanguageChip(
                        label: context.l10n.arabicLabel,
                        selected: selectedLanguage == 'ar',
                        onSelected: () => _setLanguage('ar'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              TextButton(
                onPressed: _completeOnboarding,
                child: Text(context.l10n.skipAction),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: slides.length,
              onPageChanged: (value) => setState(() => _index = value),
              itemBuilder: (context, index) {
                final slide = slides[index];
                return AnimatedPadding(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.only(
                    top: index == _index ? 4 : 16,
                    bottom: index == _index ? 4 : 16,
                  ),
                  child: _OnboardingSlide(
                    slide: slide,
                    isActive: index == _index,
                    scheme: scheme,
                    textTheme: theme.textTheme,
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
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _index == index ? 26 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _index == index
                      ? scheme.primary
                      : scheme.outlineVariant.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _nextOrFinish(lastPage),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                lastPage ? context.l10n.finishAction : context.l10n.nextAction,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.slide,
    required this.isActive,
    required this.scheme,
    required this.textTheme,
  });

  final _OnboardingSlideData slide;
  final bool isActive;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primaryContainer,
                Color.lerp(scheme.primaryContainer, scheme.surface, 0.55)!,
                scheme.surface,
              ],
            ),
            border: Border.all(
              color: scheme.outlineVariant.withOpacity(0.28),
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withOpacity(isActive ? 0.10 : 0.05),
                blurRadius: isActive ? 28 : 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withOpacity(0.22),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: SizedBox.shrink(),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -92),
                child: Icon(
                  slide.icon,
                  size: 42,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Text(
                  slide.subtitle,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    height: 1.55,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
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
    final scheme = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: scheme.primary.withOpacity(0.12),
      backgroundColor: scheme.surface,
      side: BorderSide(
        color: selected
            ? scheme.primary.withOpacity(0.35)
            : scheme.outlineVariant.withOpacity(0.45),
      ),
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: selected ? scheme.primary : scheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onSelected: (_) {
        onSelected();
      },
    );
  }
}

class _OnboardingSlideData {
  const _OnboardingSlideData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}