import 'package:fl_chart/fl_chart.dart';
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
        loading: () => const LoadingColumn(itemCount: 4),
        error: (error, _) => ErrorStateCard(
          message: context.resolveError(error),
          onRetry: () => ref.read(studyDataControllerProvider.notifier).refresh(),
        ),
        data: (studyData) {
          final courseMinutes = <String, double>{};
          final locale = Localizations.localeOf(context).languageCode;
          final isCompact = MediaQuery.sizeOf(context).width < 390;
          for (final session in studyData.sessions) {
            final title =
                studyData.courseById(session.courseId)?.title ?? context.l10n.miscLabel;
            courseMinutes.update(
              title,
              (value) => value + session.durationMinutes,
              ifAbsent: () => session.durationMinutes.toDouble(),
            );
          }

          final now = DateTime.now();
          final weekdays = List.generate(
            7,
            (index) => now.subtract(Duration(days: 6 - index)),
          );
          final weekdayBars = List.generate(7, (index) {
            final targetDay = weekdays[index];
            final minutes = studyData.sessions
                .where(
                  (session) =>
                      session.startTime.year == targetDay.year &&
                      session.startTime.month == targetDay.month &&
                      session.startTime.day == targetDay.day,
                )
                .fold<int>(0, (sum, item) => sum + item.durationMinutes);
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: minutes.toDouble(),
                  width: 18,
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            );
          });

          return ListView(
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
                      context.l10n.analyticsTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (isCompact)
                Column(
                  children: [
                    MetricTile(
                      label: context.l10n.dailyStudyMinutesLabel,
                      value: '${studyData.dailyStudyMinutes}',
                      icon: Icons.today_rounded,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    MetricTile(
                      label: context.l10n.weeklyStudyMinutesLabel,
                      value: '${studyData.weeklyStudyMinutes}',
                      icon: Icons.date_range_rounded,
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: MetricTile(
                        label: context.l10n.dailyStudyMinutesLabel,
                        value: '${studyData.dailyStudyMinutes}',
                        icon: Icons.today_rounded,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: MetricTile(
                        label: context.l10n.weeklyStudyMinutesLabel,
                        value: '${studyData.weeklyStudyMinutes}',
                        icon: Icons.date_range_rounded,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
              if (isCompact)
                Column(
                  children: [
                    MetricTile(
                      label: context.copy.habitsTitle,
                      value: '${(studyData.habitConsistency * 100).round()}%',
                      icon: Icons.repeat_rounded,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    MetricTile(
                      label: context.copy.examsTitle,
                      value: '${studyData.criticalExams.length}',
                      icon: Icons.event_note_rounded,
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: MetricTile(
                        label: context.copy.habitsTitle,
                        value: '${(studyData.habitConsistency * 100).round()}%',
                        icon: Icons.repeat_rounded,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: MetricTile(
                        label: context.copy.examsTitle,
                        value: '${studyData.criticalExams.length}',
                        icon: Icons.event_note_rounded,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
              if (isCompact)
                Column(
                  children: [
                    MetricTile(
                      label: context.l10n.completedTasksLabel,
                      value: '${studyData.completedTasks.length}',
                      icon: Icons.check_circle_rounded,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    MetricTile(
                      label: context.l10n.streakLabel,
                      value: '${studyData.streakCount}',
                      icon: Icons.local_fire_department_rounded,
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: MetricTile(
                        label: context.l10n.completedTasksLabel,
                        value: '${studyData.completedTasks.length}',
                        icon: Icons.check_circle_rounded,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: MetricTile(
                        label: context.l10n.streakLabel,
                        value: '${studyData.streakCount}',
                        icon: Icons.local_fire_department_rounded,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.weeklyFocusChartTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      DateTimeUtils.weekdayShort(
                                        weekdays[value.toInt()],
                                        locale,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: weekdayBars,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (courseMinutes.isEmpty)
                EmptyState(
                  title: context.l10n.emptyActivityTitle,
                  description: context.l10n.emptyActivityDescription,
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
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        height: 220,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 42,
                            sections:
                                courseMinutes.entries.toList().asMap().entries.map(
                              (entry) {
                                final colors = [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary,
                                  Theme.of(context).colorScheme.tertiary,
                                  Theme.of(context).colorScheme.error,
                                ];
                                return PieChartSectionData(
                                  title: entry.value.key.substring(
                                    0,
                                    entry.value.key.length > 3
                                        ? 3
                                        : entry.value.key.length,
                                  ),
                                  value: entry.value.value,
                                  color: colors[entry.key % colors.length],
                                  radius: 74,
                                );
                              },
                            ).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ...courseMinutes.entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Text(
                            context.l10n.courseAnalyticsRow(
                              entry.key,
                              entry.value.round(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
