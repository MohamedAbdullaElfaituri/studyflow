import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          final selectedDayKey = DateTimeUtils.startOfDay(_selectedDay);

          return ListView(
            children: [
              PageHeader(
                leading: const AppLogo(size: 44, radius: 18),
                title: context.l10n.calendarTitle,
                trailing: IconButton.filledTonal(
                  tooltip: _todayLabel(context),
                  onPressed: _selectToday,
                  icon: const Icon(Icons.today_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TableCalendar<Object>(
                      locale: locale,
                      firstDay: DateTime.utc(2020),
                      lastDay: DateTime.utc(2035),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          DateTimeUtils.isSameDay(day, _selectedDay),
                      calendarFormat: _format,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      availableGestures: AvailableGestures.horizontalSwipe,
                      rowHeight: 58,
                      daysOfWeekHeight: 28,
                      availableCalendarFormats: {
                        CalendarFormat.month: context.l10n.monthFormatLabel,
                        CalendarFormat.week: context.l10n.weekFormatLabel,
                      },
                      eventLoader: (day) => _eventsForDay(studyData, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        setState(() => _focusedDay = focusedDay);
                      },
                      onFormatChanged: (format) {
                        HapticFeedback.selectionClick();
                        setState(() => _format = format);
                      },
                      headerStyle: HeaderStyle(
                        titleCentered: false,
                        formatButtonVisible: true,
                        titleTextStyle:
                            Theme.of(context).textTheme.titleMedium!,
                        formatButtonTextStyle:
                            Theme.of(context).textTheme.labelMedium!,
                        formatButtonPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
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
                        isTodayHighlighted: false,
                        selectedDecoration: const BoxDecoration(),
                        todayDecoration: const BoxDecoration(),
                        defaultDecoration: const BoxDecoration(),
                        weekendDecoration: const BoxDecoration(),
                        markerDecoration: const BoxDecoration(),
                        selectedTextStyle:
                            Theme.of(context).textTheme.labelLarge!,
                        todayTextStyle: Theme.of(context).textTheme.labelLarge!,
                        weekendTextStyle:
                            Theme.of(context).textTheme.bodyMedium!,
                        defaultTextStyle:
                            Theme.of(context).textTheme.bodyMedium!,
                        canMarkersOverflow: false,
                        markersMaxCount: 0,
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: Theme.of(context).textTheme.labelMedium!,
                        weekendStyle: Theme.of(context).textTheme.labelMedium!,
                      ),
                      calendarBuilders: CalendarBuilders(
                        selectedBuilder: (context, day, focusedDay) =>
                            _PlannerDayCell(
                          day: day,
                          load: _dayLoadFor(studyData, day),
                          selected: true,
                          today: DateTimeUtils.isSameDay(day, DateTime.now()),
                        ),
                        todayBuilder: (context, day, focusedDay) =>
                            _PlannerDayCell(
                          day: day,
                          load: _dayLoadFor(studyData, day),
                          today: true,
                        ),
                        defaultBuilder: (context, day, focusedDay) =>
                            _PlannerDayCell(
                          day: day,
                          load: _dayLoadFor(studyData, day),
                        ),
                        markerBuilder: (context, day, events) =>
                            const SizedBox.shrink(),
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: Column(
                  key: ValueKey(selectedDayKey),
                  children: [
                    AdaptiveCardGrid(
                      minItemWidth: 150,
                      maxColumns: 3,
                      children: [
                        DashboardStatCard(
                          label: _taskCardTitle(context),
                          value: '${tasksForDay.length}',
                          icon: Icons.check_circle_outline_rounded,
                          accent: Theme.of(context).colorScheme.primary,
                          minHeight: 118,
                        ),
                        DashboardStatCard(
                          label: _focusCardTitle(context),
                          value: '$focusMinutes',
                          icon: Icons.timer_outlined,
                          accent: Theme.of(context).colorScheme.secondary,
                          minHeight: 118,
                        ),
                        DashboardStatCard(
                          label: _examCardTitle(context),
                          value: '${examsForDay.length}',
                          icon: Icons.school_outlined,
                          accent: Theme.of(context).colorScheme.tertiary,
                          minHeight: 118,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (agendaEntries.isEmpty)
                      EmptyState(
                        title: selectedDateLabel,
                        description: context.l10n.emptyAgendaDescription,
                        icon: Icons.event_busy_rounded,
                      )
                    else ...[
                      SectionHeader(
                        title: selectedDateLabel,
                        action: StatusPill(
                          label: _agendaCountLabel(context, totalItems),
                          color: Theme.of(context).colorScheme.primary,
                        ),
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
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          );
        },
      ),
    );
  }

  void _selectToday() {
    HapticFeedback.selectionClick();
    final today = DateTime.now();
    setState(() {
      _selectedDay = today;
      _focusedDay = today;
    });
  }

  List<Object> _eventsForDay(StudyDataState studyData, DateTime day) {
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
        (session) => DateTimeUtils.isSameDay(session.startTime, day),
      ),
    );
    items.addAll(
      studyData.exams.where(
        (exam) => DateTimeUtils.isSameDay(exam.dateTime, day),
      ),
    );
    return items;
  }

  _PlannerDayLoad _dayLoadFor(StudyDataState studyData, DateTime day) {
    final events = _eventsForDay(studyData, day);
    return _PlannerDayLoad(
      tasks: events.whereType<TaskModel>().length,
      sessions: events.whereType<StudySessionModel>().length,
      exams: events.whereType<ExamModel>().length,
    );
  }

  String _todayLabel(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Bugün',
      'ar' => 'اليوم',
      _ => 'Today',
    };
  }

  String _agendaCountLabel(BuildContext context, int totalItems) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => '$totalItems öğe',
      'ar' => '$totalItems عنصر',
      _ => '$totalItems items',
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
      'tr' => 'Görev',
      'ar' => 'مهام',
      _ => 'Tasks',
    };
  }

  String _focusCardTitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Odak dk',
      'ar' => 'دقائق',
      _ => 'Focus min',
    };
  }

  String _examCardTitle(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Sınav',
      'ar' => 'اختبارات',
      _ => 'Exams',
    };
  }
}

class _PlannerDayLoad {
  const _PlannerDayLoad({
    required this.tasks,
    required this.sessions,
    required this.exams,
  });

  final int tasks;
  final int sessions;
  final int exams;

  int get total => tasks + sessions + exams;
  bool get hasItems => total > 0;
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: HapticFeedback.lightImpact,
        child: SectionCard(
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
        ),
      ),
    );
  }
}

class _PlannerDayCell extends StatelessWidget {
  const _PlannerDayCell({
    required this.day,
    required this.load,
    this.selected = false,
    this.today = false,
  });

  final DateTime day;
  final _PlannerDayLoad load;
  final bool selected;
  final bool today;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = selected ? scheme.onPrimary : scheme.onSurface;
    final borderColor = selected
        ? scheme.primary
        : today
            ? scheme.primary.withValues(alpha: 0.58)
            : scheme.outlineVariant.withValues(alpha: 0.22);
    final fillColor = selected
        ? scheme.primary
        : load.hasItems
            ? scheme.primaryContainer.withValues(alpha: 0.24)
            : Colors.transparent;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: 44,
        height: 50,
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ]
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Text(
                '${day.day}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: foreground,
                      fontWeight:
                          selected || today ? FontWeight.w800 : FontWeight.w600,
                    ),
              ),
            ),
            if (load.hasItems)
              PositionedDirectional(
                top: 4,
                end: 5,
                child: _PlannerCountBadge(
                  count: load.total,
                  selected: selected,
                ),
              ),
            if (load.hasItems)
              PositionedDirectional(
                bottom: 6,
                start: 0,
                end: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (load.tasks > 0)
                      _PlannerMarkerDot(
                        color: selected ? scheme.onPrimary : scheme.primary,
                      ),
                    if (load.sessions > 0) ...[
                      const SizedBox(width: 3),
                      _PlannerMarkerDot(
                        color: selected ? scheme.onPrimary : scheme.secondary,
                      ),
                    ],
                    if (load.exams > 0) ...[
                      const SizedBox(width: 3),
                      _PlannerMarkerDot(
                        color: selected ? scheme.onPrimary : scheme.tertiary,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlannerCountBadge extends StatelessWidget {
  const _PlannerCountBadge({
    required this.count,
    required this.selected,
  });

  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = count > 9 ? '9+' : '$count';

    return Container(
      constraints: const BoxConstraints(minWidth: 16),
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: selected ? scheme.onPrimary : scheme.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: selected ? scheme.primary : scheme.onPrimary,
              fontSize: 9,
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
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
