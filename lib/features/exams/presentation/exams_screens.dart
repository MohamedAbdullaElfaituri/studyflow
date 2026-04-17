import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/extensions/build_context_x.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/providers/app_providers.dart';

class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({super.key});

  static const routePath = '/exams';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(studyDataControllerProvider);
    final locale = Localizations.localeOf(context).languageCode;

    return AppPage(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(ExamEditorScreen.routePath),
        label: Text(context.copy.addExamAction),
        icon: const Icon(Icons.add_rounded),
      ),
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
          final exams = studyData.upcomingExams;
          final isCompact = MediaQuery.sizeOf(context).width < 390;
          return ListView(
            children: [
              PageHeader(
                title: _examsTitle(context),
                subtitle: _examsSubtitle(context),
              ),
              const SizedBox(height: AppSpacing.lg),
              GradientBanner(
                colors: const [
                  Color(0xFF18456B),
                  Color(0xFF1F6FEB),
                  Color(0xFF24A19C)
                ],
                child: isCompact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.event_available_rounded,
                            size: 54,
                            color: Colors.white,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _examsQuickCardTitle(context),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.88),
                                ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '${studyData.criticalExams.length}',
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _examsQuickCardSubtitle(context),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.82),
                                ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _examsQuickCardTitle(context),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.white
                                            .withValues(alpha: 0.88),
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  '${studyData.criticalExams.length}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(color: Colors.white),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  _examsQuickCardSubtitle(context),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.white
                                            .withValues(alpha: 0.82),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          const Icon(
                            Icons.event_available_rounded,
                            size: 54,
                            color: Colors.white,
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (exams.isEmpty)
                EmptyState(
                  title: _emptyExamsTitle(context),
                  description: _emptyExamsDescription(context),
                  icon: Icons.event_busy_rounded,
                  action: FilledButton.tonal(
                    onPressed: () => context.push(ExamEditorScreen.routePath),
                    child: Text(_addExamAction(context)),
                  ),
                )
              else
                ...exams.map(
                  (exam) {
                    final course = studyData.courseById(exam.courseId);
                    final countdown =
                        exam.dateTime.difference(DateTime.now()).inDays;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28),
                        onTap: () => context.push(
                          '${ExamEditorScreen.routePath}?examId=${exam.id}',
                        ),
                        child: SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isCompact)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exam.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    StatusPill(
                                      label: _examCountdown(context, countdown),
                                      color: priorityColor(exam.priority),
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        exam.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ),
                                    StatusPill(
                                      label: _examCountdown(context, countdown),
                                      color: priorityColor(exam.priority),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                exam.description,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.sm,
                                children: [
                                  StatusPill(
                                    label: _examTypeLabel(context, exam.type),
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  if (course != null)
                                    StatusPill(
                                      label: course.title,
                                      color: Color(course.color),
                                    ),
                                  StatusPill(
                                    label: DateTimeUtils.friendlyDate(
                                        exam.dateTime, locale),
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class ExamEditorScreen extends ConsumerStatefulWidget {
  const ExamEditorScreen({
    super.key,
    this.examId,
  });

  static const routePath = '/exam/edit';

  final String? examId;

  @override
  ConsumerState<ExamEditorScreen> createState() => _ExamEditorScreenState();
}

class _ExamEditorScreenState extends ConsumerState<ExamEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  ExamType _type = ExamType.exam;
  TaskPriority _priority = TaskPriority.high;
  String? _courseId;
  DateTime _dateTime = DateTime.now().add(const Duration(days: 3));
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(studyDataControllerProvider);

    return AppPage(
      child: data.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        loading: () => const LoadingColumn(itemCount: 2),
        error: (error, _) => ErrorStateCard(
          message: context.resolveError(error),
          onRetry: () =>
              ref.read(studyDataControllerProvider.notifier).refresh(),
        ),
        data: (studyData) {
          final existing =
              widget.examId == null ? null : studyData.examById(widget.examId!);
          final isCompact = MediaQuery.sizeOf(context).width < 390;
          final selectedCourseId = studyData.courses.any(
            (course) => course.id == _courseId,
          )
              ? _courseId
              : null;

          if (!_initialized) {
            _initialized = true;
            if (existing != null) {
              _titleController.text = existing.title;
              _descriptionController.text = existing.description;
              _type = existing.type;
              _priority = existing.priority;
              _courseId = existing.courseId;
              _dateTime = existing.dateTime;
            }
          }

          return ListView(
            children: [
              PageHeader(
                title: existing == null
                    ? _addExamAction(context)
                    : _editExamTitle(context),
                trailing: existing == null
                    ? null
                    : IconButton(
                        onPressed: () async {
                          await ref
                              .read(studyDataControllerProvider.notifier)
                              .deleteExam(existing.id);
                          if (!mounted) return;
                          context.pop();
                        },
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration:
                            InputDecoration(labelText: context.l10n.titleLabel),
                        validator: (value) => context.validationMessage(
                          Validators.requiredField(value),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _descriptionController,
                        minLines: 3,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: context.l10n.descriptionLabel,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<String?>(
                        initialValue: selectedCourseId,
                        decoration: InputDecoration(
                            labelText: context.l10n.courseLabel),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(context.l10n.optionalCourseLabel),
                          ),
                          ...studyData.courses.map(
                            (course) => DropdownMenuItem<String?>(
                              value: course.id,
                              child: Text(course.title),
                            ),
                          ),
                        ],
                        onChanged: (value) => setState(() => _courseId = value),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (isCompact)
                        Column(
                          children: [
                            DropdownButtonFormField<ExamType>(
                              initialValue: _type,
                              decoration: InputDecoration(
                                labelText: context.copy.examTypeLabel,
                              ),
                              items: ExamType.values
                                  .map(
                                    (value) => DropdownMenuItem<ExamType>(
                                      value: value,
                                      child:
                                          Text(_examTypeLabel(context, value)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _type = value!),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            DropdownButtonFormField<TaskPriority>(
                              initialValue: _priority,
                              decoration: InputDecoration(
                                labelText: context.l10n.priorityLabel,
                              ),
                              items: TaskPriority.values
                                  .map(
                                    (value) => DropdownMenuItem<TaskPriority>(
                                      value: value,
                                      child:
                                          Text(_priorityLabel(context, value)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _priority = value!),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<ExamType>(
                                initialValue: _type,
                                decoration: InputDecoration(
                                  labelText: context.copy.examTypeLabel,
                                ),
                                items: ExamType.values
                                    .map(
                                      (value) => DropdownMenuItem<ExamType>(
                                        value: value,
                                        child: Text(
                                            _examTypeLabel(context, value)),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => _type = value!),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: DropdownButtonFormField<TaskPriority>(
                                initialValue: _priority,
                                decoration: InputDecoration(
                                  labelText: context.l10n.priorityLabel,
                                ),
                                items: TaskPriority.values
                                    .map(
                                      (value) => DropdownMenuItem<TaskPriority>(
                                        value: value,
                                        child: Text(
                                            _priorityLabel(context, value)),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => _priority = value!),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 30)),
                            lastDate:
                                DateTime.now().add(const Duration(days: 730)),
                            initialDate: _dateTime,
                          );
                          if (pickedDate == null || !mounted) return;
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_dateTime),
                          );
                          if (pickedTime == null) return;
                          setState(() {
                            _dateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        },
                        icon: const Icon(Icons.event_outlined),
                        label: Text(
                          '${DateTimeUtils.friendlyDate(
                            _dateTime,
                            Localizations.localeOf(context).languageCode,
                          )} / ${TimeOfDay.fromDateTime(_dateTime).format(context)}',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          final user = ref.read(currentUserProvider);
                          if (user == null) return;

                          final now = DateTime.now();
                          final exam = ExamModel(
                            id: existing?.id ?? const Uuid().v4(),
                            userId: user.id,
                            courseId: selectedCourseId,
                            title: _titleController.text.trim(),
                            description: _descriptionController.text.trim(),
                            dateTime: _dateTime,
                            type: _type,
                            priority: _priority,
                            createdAt: existing?.createdAt ?? now,
                            updatedAt: now,
                          );

                          await ref
                              .read(studyDataControllerProvider.notifier)
                              .saveExam(exam);
                          if (!mounted) return;
                          context.pop();
                        },
                        child: Text(context.copy.saveExamAction),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _examTypeLabel(BuildContext context, ExamType type) {
  return switch (type) {
    ExamType.exam => _examTypeExam(context),
    ExamType.assignment => _examTypeAssignment(context),
    ExamType.quiz => _examTypeQuiz(context),
  };
}

String _priorityLabel(BuildContext context, TaskPriority priority) {
  return switch (priority) {
    TaskPriority.low => context.l10n.priorityLow,
    TaskPriority.medium => context.l10n.priorityMedium,
    TaskPriority.high => context.l10n.priorityHigh,
    TaskPriority.urgent => context.l10n.priorityUrgent,
  };
}

String _addExamAction(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Sinav ekle',
    'ar' => 'إضافة اختبار',
    _ => 'Add exam',
  };
}

String _editExamTitle(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Sinavi duzenle',
    'ar' => 'تعديل الاختبار',
    _ => 'Edit exam',
  };
}

String _examsTitle(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Sinavlar',
    'ar' => 'الاختبارات',
    _ => 'Exams',
  };
}

String _examsSubtitle(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Onemli tarihlerini ve yaklasan sinavlarini tek ekranda gor.',
    'ar' => 'راجع اختباراتك القادمة ومواعيدك المهمة من شاشة واحدة.',
    _ => 'See upcoming exams and important dates in one place.',
  };
}

String _examsQuickCardTitle(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Yaklasan sinavlar',
    'ar' => 'الاختبارات القادمة',
    _ => 'Upcoming exams',
  };
}

String _examsQuickCardSubtitle(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Bir sonraki onemli tarihi yaklasmadan once kontrol et.',
    'ar' => 'راجع الموعد المهم القادم قبل أن يقترب كثيرًا.',
    _ => 'Review the next important date before it gets too close.',
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
    'ar' => 'أضف اختبارًا لإبقاء الموعد القادم واضحًا أمامك.',
    _ => 'Add an exam to keep the next important date visible.',
  };
}

String _examCountdown(BuildContext context, int days) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => '$days gun kaldi',
    'ar' => 'متبقي $days يوم',
    _ => '$days days left',
  };
}

String _examTypeExam(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Sinav',
    'ar' => 'اختبار',
    _ => 'Exam',
  };
}

String _examTypeAssignment(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Odev',
    'ar' => 'واجب',
    _ => 'Assignment',
  };
}

String _examTypeQuiz(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Kisa sinav',
    'ar' => 'اختبار قصير',
    _ => 'Quiz',
  };
}
