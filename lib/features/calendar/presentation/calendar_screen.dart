import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/extensions/build_context_x.dart';
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
        loading: () => const LoadingColumn(itemCount: 3),
        error: (error, _) => ErrorStateCard(
          message: context.resolveError(error),
          onRetry: () => ref.read(studyDataControllerProvider.notifier).refresh(),
        ),
        data: (studyData) {
          final tasksForDay = studyData.tasks
              .where(
                (task) =>
                    task.dueDateTime != null &&
                    DateTimeUtils.isSameDay(task.dueDateTime!, _selectedDay),
              )
              .toList();
          final examsForDay = studyData.exams
              .where((exam) => DateTimeUtils.isSameDay(exam.dateTime, _selectedDay))
              .toList();
          final sessionsForDay = studyData.sessions
              .where(
                (session) => DateTimeUtils.isSameDay(session.startTime, _selectedDay),
              )
              .toList();

          return ListView(
            children: [
              SectionHeader(
                title: context.l10n.calendarTitle,
                subtitle: context.l10n.calendarSubtitle,
              ),
              const SizedBox(height: AppSpacing.md),
              SectionCard(
                child: TableCalendar<Object>(
                  firstDay: DateTime.utc(2020),
                  lastDay: DateTime.utc(2035),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) =>
                      DateTimeUtils.isSameDay(day, _selectedDay),
                  calendarFormat: _format,
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
                        (session) => DateTimeUtils.isSameDay(session.startTime, day),
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
                  headerStyle: const HeaderStyle(formatButtonVisible: true),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.dailyAgendaTitle(
                        DateTimeUtils.friendlyDate(_selectedDay, locale),
                      ),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (tasksForDay.isEmpty &&
                        sessionsForDay.isEmpty &&
                        examsForDay.isEmpty)
                      Text(context.l10n.emptyAgendaDescription)
                    else ...[
                      ...examsForDay.map(
                        (exam) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Row(
                            children: [
                              const Icon(Icons.event_note_rounded),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(child: Text(exam.title)),
                              Text(DateTimeUtils.time(exam.dateTime, locale)),
                            ],
                          ),
                        ),
                      ),
                      ...tasksForDay.map(
                        (task) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Row(
                            children: [
                              const Icon(Icons.checklist_rtl_rounded),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(task.title),
                              ),
                              if (task.dueDateTime != null)
                                Text(DateTimeUtils.time(task.dueDateTime!, locale)),
                            ],
                          ),
                        ),
                      ),
                      ...sessionsForDay.map(
                        (session) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_rounded),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  context.l10n.focusSessionSummary(
                                    session.durationMinutes,
                                  ),
                                ),
                              ),
                              Text(DateTimeUtils.time(session.endTime, locale)),
                            ],
                          ),
                        ),
                      ),
                    ],
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
