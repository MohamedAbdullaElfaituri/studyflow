import 'dart:math';

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
import '../../exams/presentation/exams_screens.dart';
import '../../goals/presentation/goals_screen.dart';
import '../../habits/presentation/habits_screen.dart';
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
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        loading: () =>
            const SingleChildScrollView(child: LoadingColumn(itemCount: 5)),
        error: (error, _) => ErrorStateCard(
          message: context.resolveError(error),
          onRetry: () =>
              ref.read(studyDataControllerProvider.notifier).refresh(),
        ),
        data: (studyData) {
          final firstName = _firstName(
            context,
            auth?.fullName,
            auth?.email,
          );
          final completionRate = studyData.tasks.isEmpty
              ? 0.0
              : studyData.completedTasks.length / studyData.tasks.length;
          final weeklyProgress = _safeProgress(
            studyData.weeklyStudyMinutes,
            studyData.goals.weeklyTargetMinutes,
          );
          final weeklyRemaining = max(
            studyData.goals.weeklyTargetMinutes - studyData.weeklyStudyMinutes,
            0,
          );
          final criticalExams = studyData.criticalExams.take(2).toList();
          final activeHabits = studyData.activeHabits.take(2).toList();
          final recentSessions = [...studyData.sessions]
            ..sort((a, b) => b.startTime.compareTo(a.startTime));
          return ListView(
            children: [
              PageHeader(
                leading: const AppLogo(size: 44, radius: 18),
                title: context.l10n.welcomeBack(firstName),
                subtitle: DateTimeUtils.friendlyDate(DateTime.now(), locale),
                trailing: IconButton.filledTonal(
                  onPressed: () => context.push(SearchScreen.routePath),
                  icon: const Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              GradientBanner(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 420;
                    final ring = ProgressRing(
                      progress: weeklyProgress,
                      valueText: '${(weeklyProgress * 100).round()}%',
                      label: _weeklyGoalShort(context),
                      size: compact ? 120 : 132,
                    );

                    final content = [
                      Text(
                        _overviewTitle(context),
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        context.l10n.dashboardHeroSubtitle(
                          DateTimeUtils.friendlyDate(DateTime.now(), locale),
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.86),
                            ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      StatusPill(
                        label: _weeklyFocusHint(context, weeklyRemaining),
                        color: Colors.white,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: weeklyProgress,
                          minHeight: 10,
                          color: Colors.white,
                          backgroundColor: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                    ];

                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...content,
                          const SizedBox(height: AppSpacing.xl),
                          Align(
                            alignment: AlignmentDirectional.center,
                            child: ring,
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: content,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        ring,
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: _overviewSectionTitle(context),
                subtitle: _overviewSectionSubtitle(context),
              ),
              const SizedBox(height: AppSpacing.md),
              AdaptiveCardGrid(
                minItemWidth: 170,
                children: [
                  DashboardStatCard(
                    label: context.l10n.dailyStudyMinutesLabel,
                    value: '${studyData.dailyStudyMinutes}',
                    caption: context.l10n.goalProgressValue(
                      studyData.dailyStudyMinutes,
                      studyData.goals.dailyTargetMinutes,
                    ),
                    icon: Icons.timer_rounded,
                    accent: Theme.of(context).colorScheme.primary,
                  ),
                  DashboardStatCard(
                    label: context.l10n.completedTasksLabel,
                    value: '${(completionRate * 100).round()}%',
                    caption: _taskCompletionCaption(
                      context,
                      studyData.completedTasks.length,
                      studyData.tasks.length,
                    ),
                    icon: Icons.task_alt_rounded,
                    accent: const Color(0xFF2BAE9A),
                  ),
                  DashboardStatCard(
                    label: _upcomingExamsTitle(context),
                    value: '${studyData.criticalExams.length}',
                    caption: _examOverviewCaption(context, studyData),
                    icon: Icons.event_note_rounded,
                    accent: const Color(0xFFF4A261),
                  ),
                  DashboardStatCard(
                    label: _dailyRoutinesTitle(context),
                    value: '${studyData.activeHabits.length}',
                    caption: _habitOverviewCaption(context, studyData),
                    icon: Icons.repeat_rounded,
                    accent: const Color(0xFF4F8FC0),
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
              AdaptiveCardGrid(
                minItemWidth: 170,
                children: [
                  QuickActionTile(
                    icon: Icons.checklist_rtl_rounded,
                    title: context.l10n.tasksTitle,
                    subtitle: _openTasksCaption(
                      context,
                      studyData.activeTasks.length,
                    ),
                    onTap: () => context.push(TasksScreen.routePath),
                  ),
                  QuickActionTile(
                    icon: Icons.event_note_rounded,
                    title: _examsTitle(context),
                    subtitle: _dueSoonCaption(
                      context,
                      studyData.criticalExams.length,
                    ),
                    onTap: () => context.push(ExamsScreen.routePath),
                  ),
                  QuickActionTile(
                    icon: Icons.flag_rounded,
                    title: context.l10n.goalsTitle,
                    subtitle: context.l10n.goalProgressValue(
                      studyData.weeklyStudyMinutes,
                      studyData.goals.weeklyTargetMinutes,
                    ),
                    onTap: () => context.push(GoalsScreen.routePath),
                  ),
                  QuickActionTile(
                    icon: Icons.analytics_rounded,
                    title: context.l10n.analyticsTitle,
                    subtitle: _streakCaption(context, studyData.streakCount),
                    onTap: () => context.push(AnalyticsScreen.routePath),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: context.l10n.goalProgressTitle,
                subtitle: context.l10n.goalProgressSubtitle,
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
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.48),
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
                              _weeklyFocusHint(context, weeklyRemaining),
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
              SectionHeader(
                title: _focusAreasTitle(context),
                subtitle: _focusAreasSubtitle(context),
              ),
              const SizedBox(height: AppSpacing.md),
              AdaptiveCardGrid(
                minItemWidth: 280,
                children: [
                  _HomePreviewCard(
                    title: _upcomingExamsTitle(context),
                    icon: Icons.event_note_rounded,
                    actionLabel: context.l10n.viewAllAction,
                    onActionTap: () => context.push(ExamsScreen.routePath),
                    child: criticalExams.isEmpty
                        ? _PreviewEmptyText(
                            message: _emptyExamsDescription(context),
                          )
                        : Column(
                            children: criticalExams
                                .map(
                                  (exam) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSpacing.md,
                                    ),
                                    child: _ExamPreviewTile(
                                      exam: exam,
                                      locale: locale,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                  _HomePreviewCard(
                    title: _dailyRoutinesTitle(context),
                    icon: Icons.repeat_rounded,
                    actionLabel: context.l10n.viewAllAction,
                    onActionTap: () => context.push(HabitsScreen.routePath),
                    child: activeHabits.isEmpty
                        ? _PreviewEmptyText(
                            message: _emptyHabitsDescription(context),
                          )
                        : Column(
                            children: activeHabits
                                .map(
                                  (habit) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSpacing.md,
                                    ),
                                    child: _HabitPreviewTile(habit: habit),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: context.l10n.recentActivityTitle,
                subtitle: context.l10n.recentActivitySubtitle,
              ),
              const SizedBox(height: AppSpacing.md),
              if (recentSessions.isEmpty)
                EmptyState(
                  title: context.l10n.emptyActivityTitle,
                  description: context.l10n.emptyActivityDescription,
                  icon: Icons.history_toggle_off_rounded,
                )
              else
                ...recentSessions.take(2).map(
                      (session) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: SectionCard(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final stacked = constraints.maxWidth < 360;

                              final details = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.l10n.focusSessionSummary(
                                      session.durationMinutes,
                                    ),
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    DateTimeUtils.friendlyDate(
                                      session.startTime,
                                      locale,
                                    ),
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
                              );

                              if (stacked) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondaryContainer,
                                          child:
                                              const Icon(Icons.timer_rounded),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(child: details),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    StatusPill(
                                      label: '${session.durationMinutes}m',
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    child: const Icon(Icons.timer_rounded),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(child: details),
                                  const SizedBox(width: AppSpacing.sm),
                                  StatusPill(
                                    label: '${session.durationMinutes}m',
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
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

  String _overviewTitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Bugunun ozeti',
      'ar' => 'ملخص اليوم',
      _ => 'Today overview',
    };
  }

  String _overviewSectionTitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Hizli bakis',
      'ar' => 'نظرة سريعة',
      _ => 'Quick glance',
    };
  }

  String _overviewSectionSubtitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Bugunun ve haftanin en onemli gostergelerini ayni ritimde gor.',
      'ar' => 'راجع أهم مؤشرات اليوم والأسبوع بإيقاع بصري موحد.',
      _ =>
        'See the most important signals for today and this week in one calm view.',
    };
  }

  String _weeklyGoalShort(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Haftalik',
      'ar' => 'أسبوعي',
      _ => 'Weekly',
    };
  }

  String _weeklyFocusHint(BuildContext context, int remainingMinutes) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => remainingMinutes == 0
          ? 'Bu haftalik hedefin yolunda gorunuyor.'
          : 'Haftalik hedefe ulasmak icin $remainingMinutes dakika kaldi.',
      'ar' => remainingMinutes == 0
          ? 'أنت على المسار الصحيح لهدف هذا الأسبوع.'
          : 'تبقى $remainingMinutes دقيقة للوصول إلى هدف هذا الأسبوع.',
      _ => remainingMinutes == 0
          ? 'You are on track for this week.'
          : '$remainingMinutes minutes left to reach this week\'s target.',
    };
  }

  String _taskCompletionCaption(
      BuildContext context, int completed, int total) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => '$completed / $total gorev tamamlandi',
      'ar' => '$completed / $total مهمة مكتملة',
      _ => '$completed / $total tasks complete',
    };
  }

  String _examOverviewCaption(BuildContext context, StudyDataState data) {
    if (data.criticalExams.isEmpty) {
      return _emptyExamsTitle(context);
    }

    final days =
        data.criticalExams.first.dateTime.difference(DateTime.now()).inDays;
    return _examCountdown(context, days);
  }

  String _habitOverviewCaption(BuildContext context, StudyDataState data) {
    final consistency = (data.habitConsistency * 100).round();
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => '%$consistency tutarlilik',
      'ar' => '$consistency% اتساق',
      _ => '$consistency% consistency',
    };
  }

  String _openTasksCaption(BuildContext context, int count) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => '$count acik gorev',
      'ar' => '$count مهمة مفتوحة',
      _ => '$count open tasks',
    };
  }

  String _dueSoonCaption(BuildContext context, int count) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => '$count yakin tarih',
      'ar' => '$count موعد قريب',
      _ => '$count due soon',
    };
  }

  String _streakCaption(BuildContext context, int count) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => '$count gunluk seri',
      'ar' => 'سلسلة $count يوم',
      _ => '$count day streak',
    };
  }

  String _focusAreasTitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Odak alanlari',
      'ar' => 'نقاط التركيز',
      _ => 'Focus areas',
    };
  }

  String _focusAreasSubtitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Yaklasan baskilar ve gunluk ritimler tek yerde gorunsun.',
      'ar' => 'اجمع المواعيد القريبة والعادات اليومية في مساحة أوضح.',
      _ =>
        'Keep upcoming pressure points and daily routines visible in one place.',
    };
  }

  String _examsTitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Sinavlar',
      'ar' => 'الاختبارات',
      _ => 'Exams',
    };
  }

  String _upcomingExamsTitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Yaklasan sinavlar',
      'ar' => 'الاختبارات القادمة',
      _ => 'Upcoming exams',
    };
  }

  String _emptyExamsTitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Yaklasan sinav yok',
      'ar' => 'لا توجد اختبارات قادمة',
      _ => 'No upcoming exams',
    };
  }

  String _emptyExamsDescription(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Bir sonraki onemli tarihi gorunur tutmak icin sinav ekle.',
      'ar' => 'أضف اختبارًا ليبقى الموعد القادم واضحًا أمامك.',
      _ => 'Add an exam to keep the next important date visible.',
    };
  }

  String _examCountdown(BuildContext context, int days) {
    final safeDays = max(days, 0);
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => '$safeDays gun kaldi',
      'ar' => 'متبقي $safeDays يوم',
      _ => '$safeDays days left',
    };
  }

  String _dailyRoutinesTitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Gunluk rutinler',
      'ar' => 'العادات اليومية',
      _ => 'Daily routines',
    };
  }

  String _emptyHabitsDescription(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Gunluk ritmine destek olacak basit bir aliskanlik ekle.',
      'ar' => 'أضف عادة بسيطة تدعم روتينك اليومي.',
      _ => 'Add a simple habit to support your daily routine.',
    };
  }

  String _firstName(BuildContext context, String? fullName, String? email) {
    final trimmedName = fullName?.trim() ?? '';
    if (trimmedName.isNotEmpty) {
      return trimmedName.split(RegExp(r'\s+')).first;
    }

    final mail = email?.trim() ?? '';
    if (mail.isNotEmpty && mail.contains('@')) {
      return mail.split('@').first;
    }

    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Ogrenci',
      'ar' => 'طالب',
      _ => 'Student',
    };
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

class _HomePreviewCard extends StatelessWidget {
  const _HomePreviewCard({
    required this.title,
    required this.icon,
    required this.child,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackAction = actionLabel != null &&
              onActionTap != null &&
              constraints.maxWidth < 360;

          final header = Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!stackAction && actionLabel != null && onActionTap != null)
                TextButton(
                  onPressed: onActionTap,
                  child: Text(actionLabel!),
                ),
            ],
          );

          if (!stackAction) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header,
                const SizedBox(height: AppSpacing.lg),
                child,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: onActionTap,
                  child: Text(actionLabel!),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              child,
            ],
          );
        },
      ),
    );
  }
}

class _ExamPreviewTile extends StatelessWidget {
  const _ExamPreviewTile({
    required this.exam,
    required this.locale,
  });

  final ExamModel exam;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final color = priorityColor(exam.priority);
    final days = exam.dateTime.difference(DateTime.now()).inDays;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(20),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 340;

          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exam.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                DateTimeUtils.friendlyDate(exam.dateTime, locale),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.14),
                      child: Icon(Icons.event_note_rounded, color: color),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: details),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                StatusPill(
                  label: _localizedExamCountdown(context, days),
                  color: color,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.14),
                child: Icon(Icons.event_note_rounded, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: details),
              const SizedBox(width: AppSpacing.sm),
              StatusPill(
                label: _localizedExamCountdown(context, days),
                color: color,
              ),
            ],
          );
        },
      ),
    );
  }

  String _localizedExamCountdown(BuildContext context, int days) {
    final safeDays = max(days, 0);
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => '$safeDays gun',
      'ar' => '$safeDays يوم',
      _ => '$safeDays d',
    };
  }
}

class _HabitPreviewTile extends StatelessWidget {
  const _HabitPreviewTile({
    required this.habit,
  });

  final HabitModel habit;

  @override
  Widget build(BuildContext context) {
    final progress = (habit.completedCount / habit.goalCount).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(habit.color).withValues(alpha: 0.14),
                child: Icon(
                  Icons.repeat_rounded,
                  color: Color(habit.color),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  habit.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: progress.toDouble(),
            color: Color(habit.color),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _localizedHabitProgress(
              context,
              habit.completedCount,
              habit.goalCount,
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  String _localizedHabitProgress(BuildContext context, int value, int target) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => '$value / $target tamamlandi',
      'ar' => '$value / $target مكتمل',
      _ => '$value / $target complete',
    };
  }
}

class _PreviewEmptyText extends StatelessWidget {
  const _PreviewEmptyText({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 300;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (stacked) ...[
              Text(label),
              const SizedBox(height: AppSpacing.xs),
              Text(context.l10n.goalProgressValue(value, target)),
            ] else
              Row(
                children: [
                  Expanded(child: Text(label)),
                  const SizedBox(width: AppSpacing.sm),
                  Text(context.l10n.goalProgressValue(value, target)),
                ],
              ),
            const SizedBox(height: AppSpacing.xs),
            LinearProgressIndicator(value: progress.toDouble()),
          ],
        );
      },
    );
  }
}
