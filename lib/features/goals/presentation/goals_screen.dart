import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/extensions/build_context_x.dart';
import '../../../shared/providers/app_providers.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  static const routePath = '/goals';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(studyDataControllerProvider);

    return AppPage(
      child: data.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        loading: () => const LoadingColumn(itemCount: 3),
        error: (error, _) => ErrorStateCard(
          message: context.resolveError(error),
          onRetry: () =>
              ref.read(studyDataControllerProvider.notifier).refresh(),
        ),
        data: (studyData) {
          final dailyProgress = _safeProgress(
            studyData.dailyStudyMinutes,
            studyData.goals.dailyTargetMinutes,
          );
          final weeklyProgress = _safeProgress(
            studyData.weeklyStudyMinutes,
            studyData.goals.weeklyTargetMinutes,
          );
          final monthlyProgress = _safeProgress(
            studyData.monthlyStudyMinutes,
            studyData.goals.monthlyTargetMinutes,
          );
          final weeklyRemaining = max(
            studyData.goals.weeklyTargetMinutes - studyData.weeklyStudyMinutes,
            0,
          );

          return ListView(
            children: [
              PageHeader(
                title: context.l10n.goalsTitle,
                subtitle: _goalsSubtitle(context),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _progressOverviewTitle(context),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _progressOverviewSubtitle(context),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AdaptiveCardGrid(
                      minItemWidth: 170,
                      maxColumns: 3,
                      children: [
                        _GoalSummaryItem(
                          label: context.l10n.dailyGoalLabel,
                          progress: dailyProgress,
                          valueText: '${(dailyProgress * 100).round()}%',
                          caption: context.l10n.goalProgressValue(
                            studyData.dailyStudyMinutes,
                            studyData.goals.dailyTargetMinutes,
                          ),
                          accent: Theme.of(context).colorScheme.primary,
                        ),
                        _GoalSummaryItem(
                          label: context.l10n.weeklyGoalLabel,
                          progress: weeklyProgress,
                          valueText: '${(weeklyProgress * 100).round()}%',
                          caption: context.l10n.goalProgressValue(
                            studyData.weeklyStudyMinutes,
                            studyData.goals.weeklyTargetMinutes,
                          ),
                          accent: Theme.of(context).colorScheme.secondary,
                        ),
                        _GoalSummaryItem(
                          label: context.l10n.monthlyGoalLabel,
                          progress: monthlyProgress,
                          valueText: '${(monthlyProgress * 100).round()}%',
                          caption: context.l10n.goalProgressValue(
                            studyData.monthlyStudyMinutes,
                            studyData.goals.monthlyTargetMinutes,
                          ),
                          accent: Theme.of(context).colorScheme.tertiary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.42),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.insights_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _weeklyHint(context, weeklyRemaining),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _GoalsEditor(
                daily: studyData.goals.dailyTargetMinutes.toDouble(),
                weekly: studyData.goals.weeklyTargetMinutes.toDouble(),
                monthly: studyData.goals.monthlyTargetMinutes.toDouble(),
                onSave: (daily, weekly, monthly) async {
                  await ref
                      .read(studyDataControllerProvider.notifier)
                      .saveGoals(
                        studyData.goals.copyWith(
                          dailyTargetMinutes: daily.round(),
                          weeklyTargetMinutes: weekly.round(),
                          monthlyTargetMinutes: monthly.round(),
                          updatedAt: DateTime.now(),
                        ),
                      );
                  if (context.mounted) {
                    context.showSuccessNotification(
                        context.l10n.goalsSavedMessage);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: _supportTitle(context),
                subtitle: _supportSubtitle(context),
              ),
              const SizedBox(height: AppSpacing.md),
              AdaptiveCardGrid(
                minItemWidth: 280,
                children: [
                  _GoalSupportCard(
                    icon: Icons.play_circle_outline_rounded,
                    title: context.l10n.dailyCheckInTitle,
                    description: context.l10n.dailyCheckInDescription,
                    actionLabel: context.l10n.dailyCheckInAction,
                    onActionTap: () async {
                      await ref
                          .read(studyDataControllerProvider.notifier)
                          .addStudySession(durationMinutes: 15);
                      if (context.mounted) {
                        context.showSuccessNotification(
                          context.l10n.dailyCheckInSuccessMessage,
                        );
                      }
                    },
                  ),
                  _GoalSupportCard(
                    icon: Icons.event_note_rounded,
                    title: context.l10n.weeklyReviewTitle,
                    description: context.l10n.weeklyReviewSummary(
                      studyData.weeklyStudyMinutes,
                      studyData.completedTasks.length,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  double _safeProgress(int value, int target) {
    if (target <= 0) {
      return 0;
    }
    return (value / target).clamp(0.0, 1.0).toDouble();
  }

  String _goalsSubtitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Gunluk, haftalik ve aylik hedeflerini sade sekilde ayarla.',
      'ar' => 'اضبط أهدافك اليومية والأسبوعية والشهرية بشكل واضح.',
      _ => 'Set your daily, weekly, and monthly targets clearly.',
    };
  }

  String _progressOverviewTitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Ilerleme ozeti',
      'ar' => 'ملخص التقدم',
      _ => 'Progress overview',
    };
  }

  String _progressOverviewSubtitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Hedefler sade kalsin, ama ne durumda oldugun hemen anlasilsin.',
      'ar' => 'واجهة بسيطة توضح فورًا أين وصلت في أهدافك.',
      _ => 'Keep the goals simple while making your current pace obvious.',
    };
  }

  String _weeklyHint(BuildContext context, int remainingMinutes) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => remainingMinutes == 0
          ? 'Bu haftalik hedefinin ustundesin, ayni dengeyi koru.'
          : 'Bu hafta hedefine ulasmak icin $remainingMinutes dakika kaldi.',
      'ar' => remainingMinutes == 0
          ? 'أنت فوق هدف هذا الأسبوع، حافظ على نفس التوازن.'
          : 'تبقى $remainingMinutes دقيقة للوصول إلى هدف هذا الأسبوع.',
      _ => remainingMinutes == 0
          ? 'You are above this week\'s target. Keep the same balance.'
          : '$remainingMinutes minutes left to reach this week\'s target.',
    };
  }

  String _supportTitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Hedefi destekle',
      'ar' => 'ادعم الهدف',
      _ => 'Support the goal',
    };
  }

  String _supportSubtitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Kisa kontrol ve haftalik bakis ritmi korumayi kolaylastirir.',
      'ar' => 'المراجعة السريعة والمنتظمة تجعل الحفاظ على الإيقاع أسهل.',
      _ =>
        'Short check-ins and a weekly view make it easier to stay consistent.',
    };
  }
}

class _GoalsEditor extends StatefulWidget {
  const _GoalsEditor({
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.onSave,
  });

  final double daily;
  final double weekly;
  final double monthly;
  final Future<void> Function(double daily, double weekly, double monthly)
      onSave;

  @override
  State<_GoalsEditor> createState() => _GoalsEditorState();
}

class _GoalsEditorState extends State<_GoalsEditor> {
  late double _daily = widget.daily;
  late double _weekly = widget.weekly;
  late double _monthly = widget.monthly;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.studyGoalsTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _editorSubtitle(context),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _GoalSliderRow(
            label: context.l10n.dailyGoalLabel,
            helper: _dailyHelper(context),
            value: _daily,
            min: 30,
            max: 240,
            divisions: 14,
            accent: Theme.of(context).colorScheme.primary,
            onChanged: (value) => setState(() => _daily = value),
          ),
          const SizedBox(height: AppSpacing.lg),
          _GoalSliderRow(
            label: context.l10n.weeklyGoalLabel,
            helper: _weeklyHelper(context),
            value: _weekly,
            min: 120,
            max: 1200,
            divisions: 18,
            accent: Theme.of(context).colorScheme.secondary,
            onChanged: (value) => setState(() => _weekly = value),
          ),
          const SizedBox(height: AppSpacing.lg),
          _GoalSliderRow(
            label: context.l10n.monthlyGoalLabel,
            helper: _monthlyHelper(context),
            value: _monthly,
            min: 600,
            max: 4800,
            divisions: 21,
            accent: Theme.of(context).colorScheme.tertiary,
            onChanged: (value) => setState(() => _monthly = value),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: () => widget.onSave(_daily, _weekly, _monthly),
            child: Text(context.l10n.saveGoalsAction),
          ),
        ],
      ),
    );
  }

  String _editorSubtitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Gercekci hedefler belirle ki ekran rehber olsun, baski degil.',
      'ar' => 'اختر أهدافًا واقعية لتبقى الصفحة مرشدًا هادئًا لا مصدر ضغط.',
      _ =>
        'Choose realistic targets so the screen stays supportive, not noisy.',
    };
  }

  String _dailyHelper(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Her gun korunabilir bir minimum ritim belirle.',
      'ar' => 'حدد حدًا يوميًا يمكن الحفاظ عليه باستمرار.',
      _ => 'Set a daily minimum that feels easy to keep.',
    };
  }

  String _weeklyHelper(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Haftalik hedef, gunluk dagilimi daha net hale getirir.',
      'ar' => 'الهدف الأسبوعي يعطيك صورة أوضح لتوزيع الجهد.',
      _ => 'A weekly target makes your effort distribution easier to read.',
    };
  }

  String _monthlyHelper(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Aylik hedef uzun vadeli dengeyi korumana yardim eder.',
      'ar' => 'الهدف الشهري يساعدك على الحفاظ على توازن أبعد مدى.',
      _ => 'A monthly target helps keep the bigger picture balanced.',
    };
  }
}

class _GoalSummaryItem extends StatelessWidget {
  const _GoalSummaryItem({
    required this.label,
    required this.progress,
    required this.valueText,
    required this.caption,
    required this.accent,
  });

  final String label;
  final double progress;
  final String valueText;
  final String caption;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProgressRing(
          progress: progress,
          valueText: valueText,
          label: label,
          accent: accent,
          size: 118,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          caption,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _GoalSliderRow extends StatelessWidget {
  const _GoalSliderRow({
    required this.label,
    required this.helper,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.accent,
    required this.onChanged,
  });

  final String label;
  final String helper;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color accent;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(22),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 320;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (stacked) ...[
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                StatusPill(
                  label: '${value.round()}m',
                  color: accent,
                ),
              ] else
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    StatusPill(
                      label: '${value.round()}m',
                      color: accent,
                    ),
                  ],
                ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                helper,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: accent,
                  thumbColor: accent,
                  overlayColor: accent.withValues(alpha: 0.12),
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  label: value.round().toString(),
                  onChanged: onChanged,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GoalSupportCard extends StatelessWidget {
  const _GoalSupportCard({
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onActionTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          if (actionLabel != null && onActionTap != null) ...[
            const SizedBox(height: AppSpacing.md),
            FilledButton.tonal(
              onPressed: onActionTap,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
