import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/extensions/build_context_x.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/providers/app_providers.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  static const routePath = '/calendar';

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(studyDataControllerProvider);
    final locale = Localizations.localeOf(context).languageCode;

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
          final tasksForDay = studyData.tasks
              .where(
                (task) =>
                    task.dueDateTime != null &&
                    DateTimeUtils.isSameDay(task.dueDateTime!, _selectedDay),
              )
              .toList()
            ..sort(
              (a, b) => (a.dueDateTime ?? _selectedDay).compareTo(
                b.dueDateTime ?? _selectedDay,
              ),
            );
          final examsForDay = studyData.exams
              .where(
                (exam) => DateTimeUtils.isSameDay(exam.dateTime, _selectedDay),
              )
              .toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
          final sessionsForDay = studyData.sessions
              .where(
                (session) =>
                    DateTimeUtils.isSameDay(session.startTime, _selectedDay),
              )
              .toList()
            ..sort((a, b) => a.startTime.compareTo(b.startTime));

          final focusMinutes = sessionsForDay.fold<int>(
            0,
            (sum, session) => sum + session.durationMinutes,
          );
          final agendaEntries = [
            ...examsForDay.map(
              (exam) => _PlannerAgendaEntry(
                title: exam.title,
                label: _examLabel(context),
                time: exam.dateTime,
                icon: Icons.school_outlined,
                accent: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            ...tasksForDay.map(
              (task) => _PlannerAgendaEntry(
                title: task.title,
                label: _taskLabel(context),
                time: task.dueDateTime ?? _selectedDay,
                icon: Icons.checklist_rtl_rounded,
                accent: Theme.of(context).colorScheme.primary,
              ),
            ),
            ...sessionsForDay.map(
              (session) => _PlannerAgendaEntry(
                title: context.l10n.focusSessionSummary(
                  session.durationMinutes,
                ),
                label: _focusLabel(context),
                time: session.startTime,
                icon: Icons.timer_outlined,
                accent: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ]..sort((a, b) => a.time.compareTo(b.time));

          final selectedDateLabel = DateTimeUtils.friendlyDate(
            _selectedDay,
            locale,
          );
          final totalItems = agendaEntries.length;

          return ListView(
            children: [
              PageHeader(
                leading: const AppLogo(size: 44, radius: 18),
                title: context.l10n.calendarTitle,
                subtitle: context.l10n.calendarSubtitle,
              ),
              const SizedBox(height: AppSpacing.md),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.dailyAgendaTitle(selectedDateLabel),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _plannerSummarySubtitle(context, totalItems),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _PlannerLegendChip(
                          color: Theme.of(context).colorScheme.primary,
                          label: _taskLabel(context),
                        ),
                        _PlannerLegendChip(
                          color: Theme.of(context).colorScheme.secondary,
                          label: _focusLabel(context),
                        ),
                        _PlannerLegendChip(
                          color: Theme.of(context).colorScheme.tertiary,
                          label: _examLabel(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AdaptiveCardGrid(
                minItemWidth: 150,
                maxColumns: 3,
                children: [
                  DashboardStatCard(
                    label: _taskCardTitle(context),
                    value: '${tasksForDay.length}',
                    caption: _taskCardCaption(context),
                    icon: Icons.check_circle_outline_rounded,
                    accent: Theme.of(context).colorScheme.primary,
                    minHeight: 132,
                  ),
                  DashboardStatCard(
                    label: _focusCardTitle(context),
                    value: '$focusMinutes',
                    caption: _minutesCaption(context),
                    icon: Icons.timer_outlined,
                    accent: Theme.of(context).colorScheme.secondary,
                    minHeight: 132,
                  ),
                  DashboardStatCard(
                    label: _examCardTitle(context),
                    value: '${examsForDay.length}',
                    caption: _examCardCaption(context),
                    icon: Icons.school_outlined,
                    accent: Theme.of(context).colorScheme.tertiary,
                    minHeight: 132,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                child: TableCalendar<Object>(
                  locale: locale,
                  firstDay: DateTime.utc(2020),
                  lastDay: DateTime.utc(2035),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) =>
                      DateTimeUtils.isSameDay(day, _selectedDay),
                  calendarFormat: _format,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  availableCalendarFormats: {
                    CalendarFormat.month: context.l10n.monthFormatLabel,
                    CalendarFormat.week: context.l10n.weekFormatLabel,
                  },
                  eventLoader: (day) {
                    final items = <Object>[];
                    items.addAll(
                      studyData.tasks.where(
                        (task) =>
                            task.dueDateTime != null &&
                            DateTimeUtils.isSameDay(task.dueDateTime!, day),
                      ),
                    );
                    items.addAll(
                      studyData.sessions.where(
                        (session) =>
                            DateTimeUtils.isSameDay(session.startTime, day),
                      ),
                    );
                    items.addAll(
                      studyData.exams.where(
                        (exam) => DateTimeUtils.isSameDay(exam.dateTime, day),
                      ),
                    );
                    return items;
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) => setState(() => _format = format),
                  headerStyle: HeaderStyle(
                    titleCentered: false,
                    formatButtonVisible: true,
                    titleTextStyle: Theme.of(context).textTheme.titleMedium!,
                    formatButtonTextStyle:
                        Theme.of(context).textTheme.labelMedium!,
                    formatButtonDecoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    isTodayHighlighted: true,
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.6,
                      ),
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.10),
                    ),
                    selectedTextStyle: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(
                            color: Theme.of(context).colorScheme.onPrimary),
                    todayTextStyle: Theme.of(context).textTheme.labelLarge!,
                    weekendTextStyle: Theme.of(context).textTheme.bodyMedium!,
                    defaultTextStyle: Theme.of(context).textTheme.bodyMedium!,
                    canMarkersOverflow: false,
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: Theme.of(context).textTheme.labelMedium!,
                    weekendStyle: Theme.of(context).textTheme.labelMedium!,
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      final markers = <Widget>[
                        if (events.any((event) => event is TaskModel))
                          _PlannerMarkerDot(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        if (events.any((event) => event is StudySessionModel))
                          _PlannerMarkerDot(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        if (events.any((event) => event is ExamModel))
                          _PlannerMarkerDot(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                      ];

                      if (markers.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Wrap(
                            spacing: 4,
                            children: markers,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (agendaEntries.isEmpty)
                EmptyState(
                  title: context.l10n.dailyAgendaTitle(selectedDateLabel),
                  description: context.l10n.emptyAgendaDescription,
                  icon: Icons.event_busy_rounded,
                )
              else ...[
                SectionHeader(
                  title: context.l10n.dailyAgendaTitle(selectedDateLabel),
                  subtitle: _agendaSubtitle(context, totalItems),
                ),
                const SizedBox(height: AppSpacing.md),
                ...agendaEntries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _PlannerAgendaCard(
                      entry: entry,
                      locale: locale,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _plannerSummarySubtitle(BuildContext context, int totalItems) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => totalItems == 0
          ? 'Seçili günde planlanmış bir şey yok.'
          : 'Seçili gün için planlanan öğe sayısı: $totalItems.',
      'ar' => totalItems == 0
          ? 'لا توجد عناصر مخططة في اليوم المحدد.'
          : 'عدد العناصر المخططة لليوم المحدد: $totalItems.',
      _ => totalItems == 0
          ? 'Nothing is planned for the selected day yet.'
          : 'Planned items for the selected day: $totalItems.',
    };
  }

  String _taskLabel(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Görev',
      'ar' => 'مهمة',
      _ => 'Task',
    };
  }

  String _focusLabel(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Odak',
      'ar' => 'تركيز',
      _ => 'Focus',
    };
  }

  String _examLabel(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Sınav',
      'ar' => 'اختبار',
      _ => 'Exam',
    };
  }

  String _taskCardTitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Günlük görevler',
      'ar' => 'مهام اليوم',
      _ => 'Daily tasks',
    };
  }

  String _focusCardTitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Odak dakikası',
      'ar' => 'دقائق التركيز',
      _ => 'Focus minutes',
    };
  }

  String _examCardTitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Sınavlar',
      'ar' => 'الاختبارات',
      _ => 'Exams',
    };
  }

  String _taskCardCaption(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Seçili gün',
      'ar' => 'لليوم المحدد',
      _ => 'Selected day',
    };
  }

  String _minutesCaption(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Toplam dakika',
      'ar' => 'إجمالي الدقائق',
      _ => 'Total minutes',
    };
  }

  String _examCardCaption(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Yaklaşan akademik noktalar',
      'ar' => 'المواعيد الأكاديمية في هذا اليوم',
      _ => 'Academic milestones for this day',
    };
  }

  String _agendaSubtitle(BuildContext context, int totalItems) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => '$totalItems öğe zaman sırasına göre listelendi.',
      'ar' => 'تم ترتيب $totalItems عنصر حسب الوقت.',
      _ => '$totalItems items sorted by time.',
    };
  }
}

class _PlannerAgendaEntry {
  const _PlannerAgendaEntry({
    required this.title,
    required this.label,
    required this.time,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String label;
  final DateTime time;
  final IconData icon;
  final Color accent;
}

class _PlannerAgendaCard extends StatelessWidget {
  const _PlannerAgendaCard({
    required this.entry,
    required this.locale,
  });

  final _PlannerAgendaEntry entry;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 330;
          final timeLabel = DateTimeUtils.time(entry.time, locale);

          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusPill(
                label: entry.label,
                color: entry.accent,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                entry.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (compact) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  timeLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: entry.accent,
                      ),
                ),
              ],
            ],
          );

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: entry.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(entry.icon, color: entry.accent),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: details),
              if (!compact) ...[
                const SizedBox(width: AppSpacing.md),
                Text(
                  timeLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: entry.accent,
                      ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _PlannerLegendChip extends StatelessWidget {
  const _PlannerLegendChip({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PlannerMarkerDot(color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

class _PlannerMarkerDot extends StatelessWidget {
  const _PlannerMarkerDot({
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
