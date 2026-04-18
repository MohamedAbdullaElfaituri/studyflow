import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/extensions/build_context_x.dart';
import '../../../shared/providers/app_providers.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  static const routePath = '/analytics';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(studyDataControllerProvider);

    return AppPage(
      child: data.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        loading: () => const LoadingColumn(itemCount: 4),
        error: (error, _) => ErrorStateCard(
          message: context.resolveError(error),
          onRetry: () =>
              ref.read(studyDataControllerProvider.notifier).refresh(),
        ),
        data: (studyData) {
          final locale = Localizations.localeOf(context).languageCode;
          final now = DateTime.now();

          final weekdays = List.generate(
            7,
            (index) => now.subtract(Duration(days: 6 - index)),
          );

          final weekdayMinutes = List.generate(7, (index) {
            final targetDay = weekdays[index];
            return studyData.sessions
                .where(
                  (session) =>
                      session.startTime.year == targetDay.year &&
                      session.startTime.month == targetDay.month &&
                      session.startTime.day == targetDay.day,
                )
                .fold<int>(0, (sum, item) => sum + item.durationMinutes);
          });

          final weekTotal =
              weekdayMinutes.fold<int>(0, (sum, item) => sum + item);
          final averageDay = weekTotal == 0 ? 0 : (weekTotal / 7).round();
          final bestDayIndex = weekdayMinutes.isEmpty
              ? 0
              : weekdayMinutes.indexOf(weekdayMinutes.reduce(max));
          final bestDayLabel = weekTotal == 0
              ? '-'
              : DateTimeUtils.weekdayShort(weekdays[bestDayIndex], locale);

          final taskCompletionRate = studyData.tasks.isEmpty
              ? 0.0
              : studyData.completedTasks.length / studyData.tasks.length;
          final habitConsistency = studyData.habitConsistency;
          final weeklyGoalProgress = _safeProgress(
            studyData.weeklyStudyMinutes,
            studyData.goals.weeklyTargetMinutes,
          );

          final courseMinutes = <String, double>{};
          for (final session in studyData.sessions) {
            final title = studyData.courseById(session.courseId)?.title ??
                context.l10n.miscLabel;
            courseMinutes.update(
              title,
              (value) => value + session.durationMinutes,
              ifAbsent: () => session.durationMinutes.toDouble(),
            );
          }

          final sortedCourses = courseMinutes.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final courseTotal =
              sortedCourses.fold<double>(0, (sum, item) => sum + item.value);

          return ListView(
            children: [
              PageHeader(
                title: context.l10n.analyticsTitle,
                subtitle: _analyticsSubtitle(context),
              ),
              const SizedBox(height: AppSpacing.lg),
              AdaptiveCardGrid(
                minItemWidth: 170,
                children: [
                  DashboardStatCard(
                    label: context.l10n.weeklyStudyMinutesLabel,
                    value: '${studyData.weeklyStudyMinutes}',
                    caption: context.l10n.goalProgressValue(
                      studyData.weeklyStudyMinutes,
                      studyData.goals.weeklyTargetMinutes,
                    ),
                    icon: Icons.date_range_rounded,
                    accent: Theme.of(context).colorScheme.primary,
                  ),
                  DashboardStatCard(
                    label: context.l10n.dailyStudyMinutesLabel,
                    value: '${studyData.dailyStudyMinutes}',
                    caption:
                        _todayCaption(context, studyData.dailyStudyMinutes),
                    icon: Icons.today_rounded,
                    accent: Theme.of(context).colorScheme.secondary,
                  ),
                  DashboardStatCard(
                    label: context.l10n.completedTasksLabel,
                    value: '${(taskCompletionRate * 100).round()}%',
                    caption: _taskCompletionCaption(
                      context,
                      studyData.completedTasks.length,
                      studyData.tasks.length,
                    ),
                    icon: Icons.check_circle_rounded,
                    accent: const Color(0xFF2BAE9A),
                  ),
                  DashboardStatCard(
                    label: context.l10n.streakLabel,
                    value: '${studyData.streakCount}',
                    caption: _streakCaption(context, studyData.streakCount),
                    icon: Icons.local_fire_department_rounded,
                    accent: const Color(0xFFF4A261),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.weeklyFocusChartTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _weeklyRhythmSubtitle(context),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    WeekSparkBars(
                      values: weekdayMinutes
                          .map((value) => value.toDouble())
                          .toList(),
                      labels: weekdays
                          .map((day) => DateTimeUtils.weekdayShort(day, locale))
                          .toList(),
                      accent: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _AnalyticsChip(
                          label: _weekTotalLabel(context),
                          value: '${weekTotal}m',
                        ),
                        _AnalyticsChip(
                          label: _averageLabel(context),
                          value: '${averageDay}m',
                        ),
                        _AnalyticsChip(
                          label: _bestDayLabel(context),
                          value: bestDayLabel,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _studyBalanceTitle(context),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _studyBalanceSubtitle(context),
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
                        _AnalyticsRingCard(
                          label: _weeklyGoalLabel(context),
                          progress: weeklyGoalProgress,
                          valueText: '${(weeklyGoalProgress * 100).round()}%',
                          accent: Theme.of(context).colorScheme.primary,
                          caption: context.l10n.goalProgressValue(
                            studyData.weeklyStudyMinutes,
                            studyData.goals.weeklyTargetMinutes,
                          ),
                        ),
                        _AnalyticsRingCard(
                          label: _taskCompletionLabel(context),
                          progress: taskCompletionRate,
                          valueText: '${(taskCompletionRate * 100).round()}%',
                          accent: Theme.of(context).colorScheme.secondary,
                          caption: _taskCompletionCaption(
                            context,
                            studyData.completedTasks.length,
                            studyData.tasks.length,
                          ),
                        ),
                        _AnalyticsRingCard(
                          label: _habitConsistencyLabel(context),
                          progress: habitConsistency,
                          valueText: '${(habitConsistency * 100).round()}%',
                          accent: Theme.of(context).colorScheme.tertiary,
                          caption: _habitConsistencyCaption(
                            context,
                            studyData.completedHabits.length,
                            studyData.habits.length,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (sortedCourses.isEmpty)
                EmptyState(
                  title: context.l10n.emptyActivityTitle,
                  description: _emptyCourseDistribution(context),
                  icon: Icons.pie_chart_outline_rounded,
                )
              else
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.courseDistributionTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _courseDistributionSubtitle(context),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ...sortedCourses.take(4).toList().asMap().entries.map(
                            (entry) => Padding(
                              padding: EdgeInsets.only(
                                bottom: entry.key ==
                                        min(sortedCourses.length, 4) - 1
                                    ? 0
                                    : AppSpacing.lg,
                              ),
                              child: _CourseShareRow(
                                title: entry.value.key,
                                minutes: entry.value.value.round(),
                                progress: courseTotal == 0
                                    ? 0
                                    : entry.value.value / courseTotal,
                                color: _courseColor(context, entry.key),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
              SectionCard(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final stacked = constraints.maxWidth < 360;

                    final insightText = Text(
                      _analyticsInsight(
                        context,
                        weeklyGoalProgress: weeklyGoalProgress,
                        taskCompletionRate: taskCompletionRate,
                        habitConsistency: habitConsistency,
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                    );

                    if (stacked) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          insightText,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: insightText),
                      ],
                    );
                  },
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

  Color _courseColor(BuildContext context, int index) {
    final colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
      const Color(0xFFD95D39),
    ];
    return colors[index % colors.length];
  }

  String _analyticsSubtitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Haftalik odak, gorevler ve aliskanliklarini tek bakista izle.',
      'ar' => 'راجع التركيز الأسبوعي والمهام والعادات في لوحة أوضح.',
      _ =>
        'Review your weekly focus, tasks, and habits in one calmer dashboard.',
    };
  }

  String _todayCaption(BuildContext context, int minutes) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Bugun $minutes dakika',
      'ar' => '$minutes دقيقة اليوم',
      _ => '$minutes minutes today',
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

  String _streakCaption(BuildContext context, int days) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => '$days gunluk seri',
      'ar' => 'سلسلة $days يوم',
      _ => '$days day streak',
    };
  }

  String _weeklyRhythmSubtitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Her gunun yogunlugunu gorerek ritmini dengele.',
      'ar' => 'شاهد كثافة كل يوم لتفهم إيقاع الأسبوع بشكل أسرع.',
      _ =>
        'See the intensity of each day so your weekly rhythm is easier to read.',
    };
  }

  String _weekTotalLabel(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Hafta toplami',
      'ar' => 'إجمالي الأسبوع',
      _ => 'Week total',
    };
  }

  String _averageLabel(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Gunluk ortalama',
      'ar' => 'متوسط يومي',
      _ => 'Daily average',
    };
  }

  String _bestDayLabel(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'En guclu gun',
      'ar' => 'أفضل يوم',
      _ => 'Best day',
    };
  }

  String _studyBalanceTitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Calisma dengesi',
      'ar' => 'توازن الدراسة',
      _ => 'Study balance',
    };
  }

  String _studyBalanceSubtitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' =>
        'Hedef, gorev ve aliskanlik taraflarinin ayni anda nasil gittigini gor.',
      'ar' => 'افهم معًا كيف تتحرك الأهداف والمهام والعادات.',
      _ =>
        'Compare goals, tasks, and habits together instead of reading them separately.',
    };
  }

  String _weeklyGoalLabel(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Haftalik hedef',
      'ar' => 'هدف أسبوعي',
      _ => 'Weekly goal',
    };
  }

  String _taskCompletionLabel(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Gorev tamamlama',
      'ar' => 'إكمال المهام',
      _ => 'Task completion',
    };
  }

  String _habitConsistencyLabel(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Aliskanlik tutarliligi',
      'ar' => 'اتساق العادات',
      _ => 'Habit consistency',
    };
  }

  String _habitConsistencyCaption(
      BuildContext context, int completed, int total) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => '$completed / $total aliskanlik tamamlandi',
      'ar' => '$completed / $total عادة مكتملة',
      _ => '$completed / $total habits complete',
    };
  }

  String _emptyCourseDistribution(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Ders dagilimi gormek icin oturumlarini derslerle bagla.',
      'ar' => 'اربط جلساتك بالمواد لتظهر خريطة التوزيع بشكل أوضح.',
      _ =>
        'Link sessions to courses to make the study distribution more meaningful.',
    };
  }

  String _courseDistributionSubtitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' =>
        'Hangi derslerin daha fazla zaman aldigini oranlarla karsilastir.',
      'ar' => 'قارن أين يذهب وقتك فعلًا بدل الاكتفاء بعدد الجلسات.',
      _ =>
        'Compare where your time really goes instead of relying on session counts alone.',
    };
  }

  String _analyticsInsight(
    BuildContext context, {
    required double weeklyGoalProgress,
    required double taskCompletionRate,
    required double habitConsistency,
  }) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => weeklyGoalProgress >= 1
          ? 'Haftalik hedefin tamamlanmis gorunuyor. Simdi ayni sakin dengeyi korumak yeterli.'
          : taskCompletionRate < 0.35
              ? 'Calisma suresi var ama gorev bitirme hizi daha dusuk. Kucuk ve net gorevler daha iyi denge kurabilir.'
              : habitConsistency < 0.4
                  ? 'Odak dakikalari iyi gidiyor. Simdi bunlari destekleyecek iki basit rutine ihtiyacin var.'
                  : 'Ilerlemen dengeli gorunuyor. Ayni ritmi korursan hafta sonu daha rahat olur.',
      'ar' => weeklyGoalProgress >= 1
          ? 'يبدو أنك أنهيت هدف الأسبوع، والآن يكفي الحفاظ على نفس الهدوء والتوازن.'
          : taskCompletionRate < 0.35
              ? 'وقت الدراسة موجود، لكن إنجاز المهام أبطأ. تقسيم المهام إلى أجزاء أوضح قد يعطي توازنًا أفضل.'
              : habitConsistency < 0.4
                  ? 'دقائق التركيز جيدة، لكنك تحتاج عادات بسيطة تدعم هذا الإيقاع.'
                  : 'تقدمك يبدو متوازنًا. الاستمرار بنفس النسق سيجعل نهاية الأسبوع أخف.',
      _ => weeklyGoalProgress >= 1
          ? 'Your weekly target looks complete. Now the job is simply to keep the same calm balance.'
          : taskCompletionRate < 0.35
              ? 'Study time exists, but task completion is lagging. Smaller, clearer tasks could rebalance the week.'
              : habitConsistency < 0.4
                  ? 'Your focus minutes are moving well. Now you need a couple of simple routines to support them.'
                  : 'Your progress looks balanced. Keeping this same rhythm should make the week feel lighter.',
    };
  }
}

class _AnalyticsChip extends StatelessWidget {
  const _AnalyticsChip({
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
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _AnalyticsRingCard extends StatelessWidget {
  const _AnalyticsRingCard({
    required this.label,
    required this.progress,
    required this.valueText,
    required this.accent,
    required this.caption,
  });

  final String label;
  final double progress;
  final String valueText;
  final Color accent;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          ProgressRing(
            progress: progress,
            label: label,
            valueText: valueText,
            accent: accent,
            size: 120,
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
      ),
    );
  }
}

class _CourseShareRow extends StatelessWidget {
  const _CourseShareRow({
    required this.title,
    required this.minutes,
    required this.progress,
    required this.color,
  });

  final String title;
  final int minutes;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 320;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (stacked) ...[
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  Text(
                    '${(progress * 100).round()}%',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: color,
                        ),
                  ),
                  Text(
                    '${minutes}m',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ] else
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${(progress * 100).round()}%',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: color,
                        ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${minutes}m',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 10,
                color: color,
                backgroundColor: color.withValues(alpha: 0.14),
              ),
            ),
          ],
        );
      },
    );
  }
}
