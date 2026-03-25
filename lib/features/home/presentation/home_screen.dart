import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/extensions/build_context_x.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/providers/app_providers.dart';
import '../../analytics/presentation/analytics_screen.dart';
import '../../courses/presentation/courses_screens.dart';
import '../../goals/presentation/goals_screen.dart';
import '../../notes/presentation/notes_screens.dart';
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
        data: (studyData) => RefreshIndicator(
          onRefresh: () => ref.read(studyDataControllerProvider.notifier).refresh(),
          child: ListView(
            children: [
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.welcomeBack(auth?.fullName.split(' ').first ?? ''),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      context.l10n.dashboardHeroSubtitle(
                        DateTimeUtils.friendlyDate(DateTime.now(), locale),
                      ),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: [
                        _MiniSummaryChip(
                          icon: Icons.timer_rounded,
                          label: context.l10n.dailyStudyMinutesLabel,
                          value: '${studyData.dailyStudyMinutes}',
                        ),
                        _MiniSummaryChip(
                          icon: Icons.local_fire_department_rounded,
                          label: context.l10n.streakLabel,
                          value: '${studyData.streakCount}',
                        ),
                        _MiniSummaryChip(
                          icon: Icons.check_circle_rounded,
                          label: context.l10n.completedTasksLabel,
                          value: '${studyData.completedTasks.length}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(
                title: context.l10n.quickActionsTitle,
                subtitle: context.l10n.quickActionsSubtitle,
                action: IconButton(
                  onPressed: () => _showQuickAddSheet(context),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 178,
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
                        icon: Icons.menu_book_rounded,
                        title: context.l10n.coursesTitle,
                        subtitle: context.l10n.quickCourseSubtitle,
                        onTap: () => context.push(CoursesScreen.routePath),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 178,
                child: Row(
                  children: [
                    Expanded(
                      child: QuickActionTile(
                        icon: Icons.note_alt_rounded,
                        title: context.l10n.notesTitle,
                        subtitle: context.l10n.quickNoteSubtitle,
                        onTap: () => context.push(NotesScreen.routePath),
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
                title: context.l10n.todayPlanTitle,
                subtitle: context.l10n.todayPlanSubtitle,
              ),
              const SizedBox(height: AppSpacing.md),
              if (studyData.todayTasks.isEmpty)
                EmptyState(
                  title: context.l10n.emptyTodayTitle,
                  description: context.l10n.emptyTodayDescription,
                  icon: Icons.event_available_rounded,
                  action: FilledButton.tonal(
                    onPressed: () => context.push(TaskEditorScreen.routePath),
                    child: Text(context.l10n.addTaskAction),
                  ),
                )
              else
                ...studyData.todayTasks.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: SectionCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  task.description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                StatusPill(
                                  label: _homeTaskStatusLabel(context, task.status),
                                  color: statusColor(task.status),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => ref
                                .read(studyDataControllerProvider.notifier)
                                .toggleTaskStatus(task),
                            icon: Icon(
                              task.status == TaskStatus.completed
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: context.l10n.goalProgressTitle,
                      subtitle: context.l10n.goalProgressSubtitle,
                      action: TextButton(
                        onPressed: () => context.push(GoalsScreen.routePath),
                        child: Text(context.l10n.viewAllAction),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
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
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: context.l10n.insightsTitle,
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
                        _insightText(context, studyData),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: context.l10n.achievementsTitle,
                subtitle: context.l10n.achievementsSubtitle,
              ),
              const SizedBox(height: AppSpacing.md),
              ...studyData.achievements.map(
                (achievement) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(achievement.description),
                        const SizedBox(height: AppSpacing.sm),
                        LinearProgressIndicator(
                          value: achievement.completion.clamp(0.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: context.l10n.recentActivityTitle,
                subtitle: context.l10n.recentActivitySubtitle,
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
                                      style: Theme.of(context).textTheme.titleMedium,
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
        ),
      ),
    );
  }

  String _insightText(BuildContext context, StudyDataState data) {
    if (data.streakCount >= 3) {
      return context.l10n.insightStreak(data.streakCount);
    }
    if (data.todayTasks.isEmpty) {
      return context.l10n.insightPlanDay;
    }
    if (data.weeklyStudyMinutes < data.goals.weeklyTargetMinutes / 2) {
      return context.l10n.insightBoostFocus;
    }
    return context.l10n.insightStrongMomentum;
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
              leading: const Icon(Icons.menu_book_rounded),
              title: Text(context.l10n.addCourseAction),
              onTap: () {
                sheetContext.pop();
                context.push(CourseEditorScreen.routePath);
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_alt_rounded),
              title: Text(context.l10n.addNoteAction),
              onTap: () {
                sheetContext.pop();
                context.push(NoteEditorScreen.routePath);
              },
            ),
          ],
        ),
      ),
    );
  }
}

String _homeTaskStatusLabel(BuildContext context, TaskStatus status) {
  return switch (status) {
    TaskStatus.pending => context.l10n.filterPending,
    TaskStatus.inProgress => context.l10n.filterInProgress,
    TaskStatus.completed => context.l10n.filterCompleted,
  };
}

class _MiniSummaryChip extends StatelessWidget {
  const _MiniSummaryChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Text('$value · $label'),
        ],
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
