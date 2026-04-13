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
        loading: () => const LoadingColumn(itemCount: 3),
        error: (error, _) => ErrorStateCard(
          message: context.resolveError(error),
          onRetry: () =>
              ref.read(studyDataControllerProvider.notifier).refresh(),
        ),
        data: (studyData) => ListView(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: Navigator.of(context).pop,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    context.l10n.goalsTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _GoalsEditor(
              daily: studyData.goals.dailyTargetMinutes.toDouble(),
              weekly: studyData.goals.weeklyTargetMinutes.toDouble(),
              monthly: studyData.goals.monthlyTargetMinutes.toDouble(),
              onSave: (daily, weekly, monthly) async {
                await ref.read(studyDataControllerProvider.notifier).saveGoals(
                      studyData.goals.copyWith(
                        dailyTargetMinutes: daily.round(),
                        weeklyTargetMinutes: weekly.round(),
                        monthlyTargetMinutes: monthly.round(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                if (context.mounted) {
                  context
                      .showSuccessNotification(context.l10n.goalsSavedMessage);
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.dailyCheckInTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(context.l10n.dailyCheckInDescription),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.tonal(
                    onPressed: () async {
                      await ref
                          .read(studyDataControllerProvider.notifier)
                          .addStudySession(durationMinutes: 15);
                      if (context.mounted) {
                        context.showSuccessNotification(
                          context.l10n.dailyCheckInSuccessMessage,
                        );
                      }
                    },
                    child: Text(context.l10n.dailyCheckInAction),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.weeklyReviewTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(context.l10n.weeklyReviewDescription),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    context.l10n.weeklyReviewSummary(
                      studyData.weeklyStudyMinutes,
                      studyData.completedTasks.length,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
          const SizedBox(height: AppSpacing.lg),
          Text(context.l10n.dailyGoalLabel),
          Slider(
            value: _daily,
            min: 30,
            max: 240,
            divisions: 14,
            label: _daily.round().toString(),
            onChanged: (value) => setState(() => _daily = value),
          ),
          Text(context.l10n.weeklyGoalLabel),
          Slider(
            value: _weekly,
            min: 120,
            max: 1200,
            divisions: 18,
            label: _weekly.round().toString(),
            onChanged: (value) => setState(() => _weekly = value),
          ),
          Text(context.l10n.monthlyGoalLabel),
          Slider(
            value: _monthly,
            min: 600,
            max: 4800,
            divisions: 21,
            label: _monthly.round().toString(),
            onChanged: (value) => setState(() => _monthly = value),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: () => widget.onSave(_daily, _weekly, _monthly),
            child: Text(context.l10n.saveGoalsAction),
          ),
        ],
      ),
    );
  }
}
