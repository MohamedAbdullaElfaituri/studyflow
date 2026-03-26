import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/extensions/build_context_x.dart';
import '../../../shared/providers/app_providers.dart';
import '../../analytics/presentation/analytics_screen.dart';
import '../../courses/presentation/courses_screens.dart';
import '../../exams/presentation/exams_screens.dart';
import '../../goals/presentation/goals_screen.dart';
import '../../habits/presentation/habits_screen.dart';
import '../../notes/presentation/notes_screens.dart';
import '../../search/presentation/search_screen.dart';
import '../../tasks/presentation/tasks_screens.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const routePath = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(currentUserProvider);
    final data = ref.watch(studyDataControllerProvider);
    final locale = Localizations.localeOf(context).languageCode;

    return AppPage(
      child: data.when(
        loading: () => const SingleChildScrollView(child: LoadingColumn(itemCount: 5)),
        error: (error, _) => ErrorStateCard(
          message: context.resolveError(error),
          onRetry: () => ref.read(studyDataControllerProvider.notifier).refresh(),
        ),
        data: (studyData) {
          final completionRate = studyData.tasks.isEmpty
              ? 0.0
              : studyData.completedTasks.length / studyData.tasks.length;
          final motivation = _motivationQuote(context, studyData);
          final focusDelta = max(
            studyData.goals.weeklyTargetMinutes - studyData.weeklyStudyMinutes,
            0,
          );

          return RefreshIndicator(
            onRefresh: () => ref.read(studyDataControllerProvider.notifier).refresh(),
            child: ListView(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.welcomeBack(
                              auth?.fullName.split(' ').first ?? '',
                            ),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            DateTimeUtils.friendlyDate(DateTime.now(), locale),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => context.push(SearchScreen.routePath),
                      icon: const Icon(Icons.search_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                GradientBanner(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.copy.premiumDashboardTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(color: Colors.white),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  context.copy.premiumDashboardSubtitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.white.withOpacity(0.82),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.auto_graph_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        children: [
                          _HeroPill(
                            label: context.copy.levelLabel,
                            value: '${studyData.level}',
                          ),
                          _HeroPill(
                            label: context.copy.xpLabel,
                            value: '${studyData.totalXp}',
                          ),
                          _HeroPill(
                            label: context.l10n.streakLabel,
                            value: '${studyData.streakCount}',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: studyData.levelProgress,
                          minHeight: 10,
                          color: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: HeroMetricCard(
                        title: context.l10n.dailyStudyMinutesLabel,
                        value: '${studyData.dailyStudyMinutes}',
                        subtitle: context.l10n.goalProgressValue(
                          studyData.dailyStudyMinutes,
                          studyData.goals.dailyTargetMinutes,
                        ),
                        icon: Icons.timer_rounded,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: HeroMetricCard(
                        title: context.l10n.completedTasksLabel,
                        value: '${(completionRate * 100).round()}%',
                        subtitle:
                            '${studyData.completedTasks.length}/${studyData.tasks.length} ${context.l10n.tasksTitle.toLowerCase()}',
                        icon: Icons.task_alt_rounded,
                        accent: const Color(0xFF2BAE9A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(
                  title: context.l10n.quickActionsTitle,
                  subtitle: context.l10n.quickActionsSubtitle,
                  action: TextButton(
                    onPressed: () => _showQuickAddSheet(context),
                    child: Text(context.l10n.addTaskAction),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 180,
                  child: Row(
                    children: [
                      Expanded(
                        child: QuickActionTile(
                          icon: Icons.checklist_rtl_rounded,
                          title: context.l10n.tasksTitle,
                          subtitle: context.l10n.quickTaskSubtitle,
                          onTap: () => context.push(TaskEditorScreen.routePath),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: QuickActionTile(
                          icon: Icons.event_note_rounded,
                          title: context.copy.examsTitle,
                          subtitle: context.copy.examsQuickCardTitle,
                          onTap: () => context.push(ExamsScreen.routePath),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 180,
                  child: Row(
                    children: [
                      Expanded(
                        child: QuickActionTile(
                          icon: Icons.repeat_rounded,
                          title: context.copy.habitsTitle,
                          subtitle: context.copy.habitsQuickCardTitle,
                          onTap: () => context.push(HabitsScreen.routePath),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: QuickActionTile(
                          icon: Icons.analytics_rounded,
                          title: context.l10n.analyticsTitle,
                          subtitle: context.l10n.quickAnalyticsSubtitle,
                          onTap: () => context.push(AnalyticsScreen.routePath),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(
                  title: context.copy.plannerPulseTitle,
                  subtitle: context.copy.plannerPulseSubtitle,
                  action: TextButton(
                    onPressed: () => context.push(GoalsScreen.routePath),
                    child: Text(context.l10n.viewAllAction),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GoalProgressRow(
                        label: context.l10n.dailyGoalLabel,
                        value: studyData.dailyStudyMinutes,
                        target: studyData.goals.dailyTargetMinutes,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _GoalProgressRow(
                        label: context.l10n.weeklyGoalLabel,
                        value: studyData.weeklyStudyMinutes,
                        target: studyData.goals.weeklyTargetMinutes,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _GoalProgressRow(
                        label: context.l10n.monthlyGoalLabel,
                        value: studyData.monthlyStudyMinutes,
                        target: studyData.goals.monthlyTargetMinutes,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      StatusPill(
                        label: context.copy.weeklyChallengeDescription(focusDelta == 0
                            ? studyData.goals.weeklyTargetMinutes
                            : focusDelta),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(
                  title: context.copy.examsQuickCardTitle,
                  subtitle: context.copy.examsSubtitle,
                  action: TextButton(
                    onPressed: () => context.push(ExamsScreen.routePath),
                    child: Text(context.l10n.viewAllAction),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (studyData.criticalExams.isEmpty)
                  EmptyState(
                    title: context.copy.emptyExamsTitle,
                    description: context.copy.emptyExamsDescription,
                    icon: Icons.event_available_rounded,
                  )
                else
                  ...studyData.criticalExams.map(
                    (exam) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: SectionCard(
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: priorityColor(exam.priority)
                                  .withOpacity(0.16),
                              child: Icon(
                                Icons.event_note_rounded,
                                color: priorityColor(exam.priority),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exam.title,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    DateTimeUtils.friendlyDate(exam.dateTime, locale),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            StatusPill(
                              label: context.copy.examCountdown(
                                exam.dateTime.difference(DateTime.now()).inDays,
                              ),
                              color: priorityColor(exam.priority),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(
                  title: context.copy.habitsQuickCardTitle,
                  subtitle: context.copy.habitsSubtitle,
                  action: TextButton(
                    onPressed: () => context.push(HabitsScreen.routePath),
                    child: Text(context.l10n.viewAllAction),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (studyData.activeHabits.isEmpty)
                  EmptyState(
                    title: context.copy.emptyHabitsTitle,
                    description: context.copy.emptyHabitsDescription,
                    icon: Icons.repeat_rounded,
                  )
                else
                  ...studyData.activeHabits.take(3).map(
                    (habit) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    habit.title,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                FilledButton.tonal(
                                  onPressed: habit.isCompleted
                                      ? null
                                      : () => ref
                                          .read(studyDataControllerProvider.notifier)
                                          .completeHabit(habit),
                                  child: Text(context.l10n.finishAction),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            LinearProgressIndicator(
                              value: (habit.completedCount / habit.goalCount)
                                  .clamp(0.0, 1.0)
                                  .toDouble(),
                              color: Color(habit.color),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              context.copy.habitProgress(
                                habit.completedCount,
                                habit.goalCount,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(
                  title: context.copy.motivationMomentTitle,
                  subtitle: context.l10n.insightsSubtitle,
                ),
                const SizedBox(height: AppSpacing.md),
                SectionCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          motivation,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(
                  title: context.l10n.recentActivityTitle,
                  subtitle: context.l10n.recentActivitySubtitle,
                  action: TextButton(
                    onPressed: () => context.push(NotesScreen.routePath),
                    child: Text(context.l10n.notesTitle),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (studyData.sessions.isEmpty)
                  EmptyState(
                    title: context.l10n.emptyActivityTitle,
                    description: context.l10n.emptyActivityDescription,
                    icon: Icons.history_toggle_off_rounded,
                  )
                else
                  ...studyData.sessions.take(4).map(
                        (session) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: SectionCard(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                  child: const Icon(Icons.timer_rounded),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.l10n.focusSessionSummary(
                                          session.durationMinutes,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        DateTimeUtils.friendlyDate(
                                          session.startTime,
                                          locale,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _motivationQuote(BuildContext context, StudyDataState data) {
    final locale = Localizations.localeOf(context).languageCode;
    final quotes = switch (locale) {
      'tr' => [
          'Küçük ama tutarlı adımlar, yoğun günlerde bile güven verir.',
          'Net plan, düşük stres ve daha yüksek odak demektir.',
          'Bugünün kısa oturumu yarının rahatlığını oluşturur.',
        ],
      'ar' => [
          'الخطوات الصغيرة المنتظمة تمنحك ثقة أكبر من الاندفاع المؤقت.',
          'الخطة الواضحة تقلل الضغط وتزيد جودة التركيز.',
          'جلسة قصيرة اليوم تصنع هدوءًا أكبر غدًا.',
        ],
      _ => [
          'Small consistent wins are easier to trust than random bursts of effort.',
          'A clear plan lowers stress and raises the quality of focus.',
          'A short session today often protects tomorrow from chaos.',
        ],
    };

    return quotes[data.totalXp % quotes.length];
  }

  void _showQuickAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.checklist_rtl_rounded),
              title: Text(context.l10n.addTaskAction),
              onTap: () {
                sheetContext.pop();
                context.push(TaskEditorScreen.routePath);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_note_rounded),
              title: Text(context.copy.addExamAction),
              onTap: () {
                sheetContext.pop();
                context.push(ExamEditorScreen.routePath);
              },
            ),
            ListTile(
              leading: const Icon(Icons.repeat_rounded),
              title: Text(context.copy.addHabitAction),
              onTap: () {
                sheetContext.pop();
                context.push(HabitEditorScreen.routePath);
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_rounded),
              title: Text(context.l10n.addCourseAction),
              onTap: () {
                sheetContext.pop();
                context.push(CourseEditorScreen.routePath);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$value / $label',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
            ),
      ),
    );
  }
}

class _GoalProgressRow extends StatelessWidget {
  const _GoalProgressRow({
    required this.label,
    required this.value,
    required this.target,
  });

  final String label;
  final int value;
  final int target;

  @override
  Widget build(BuildContext context) {
    final progress = target == 0 ? 0.0 : (value / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text(context.l10n.goalProgressValue(value, target)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LinearProgressIndicator(value: progress.toDouble()),
      ],
    );
  }
}
