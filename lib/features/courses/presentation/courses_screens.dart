import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/extensions/build_context_x.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/providers/app_providers.dart';

class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  static const routePath = '/courses';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(studyDataControllerProvider);

    return AppPage(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(CourseEditorScreen.routePath),
        label: Text(context.l10n.addCourseAction),
        icon: const Icon(Icons.add_rounded),
      ),
      child: data.when(
        loading: () => const LoadingColumn(itemCount: 4),
        error: (error, _) => ErrorStateCard(
          message: context.resolveError(error),
          onRetry: () => ref.read(studyDataControllerProvider.notifier).refresh(),
        ),
        data: (studyData) => ListView(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: context.pop,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    context.l10n.coursesTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (studyData.courses.isEmpty)
              EmptyState(
                title: context.l10n.emptyCoursesTitle,
                description: context.l10n.emptyCoursesDescription,
                icon: Icons.menu_book_rounded,
                action: FilledButton.tonal(
                  onPressed: () => context.push(CourseEditorScreen.routePath),
                  child: Text(context.l10n.addCourseAction),
                ),
              )
            else
              ...studyData.courses.map(
                (course) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: InkWell(
                    onTap: () => context.push('/course/${course.id}'),
                    borderRadius: BorderRadius.circular(24),
                    child: SectionCard(
                      child: Row(
                        children: [
                          CourseAvatar(course: course),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.title,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  course.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  context.l10n.courseTaskNoteSummary(
                                    studyData.tasksForCourse(course.id).length,
                                    studyData.notesForCourse(course.id).length,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
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
              ),
          ],
        ),
      ),
    );
  }
}

class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({
    required this.courseId,
    super.key,
  });

  static const routePath = '/course/:courseId';

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(studyDataControllerProvider);

    return AppPage(
      child: data.when(
        loading: () => const LoadingColumn(itemCount: 3),
        error: (error, _) => ErrorStateCard(
          message: context.resolveError(error),
          onRetry: () => ref.read(studyDataControllerProvider.notifier).refresh(),
        ),
        data: (studyData) {
          final course = studyData.courseById(courseId);
          if (course == null) {
            return EmptyState(
              title: context.l10n.courseNotFoundTitle,
              description: context.l10n.courseNotFoundDescription,
            );
          }

          final tasks = studyData.tasksForCourse(courseId);
          final notes = studyData.notesForCourse(courseId);
          final exams = studyData.examsForCourse(courseId);

          return ListView(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: context.pop,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      context.l10n.courseDetailTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push(
                      '${CourseEditorScreen.routePath}?courseId=${course.id}',
                    ),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CourseAvatar(course: course, size: 56),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            course.title,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(course.description),
                    if (course.instructorName != null &&
                        course.instructorName!.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      DetailRow(
                        label: context.l10n.instructorLabel,
                        value: course.instructorName!,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(
                title: context.l10n.linkedTasksTitle,
                subtitle: context.l10n.linkedTasksSubtitle,
              ),
              const SizedBox(height: AppSpacing.md),
              if (tasks.isEmpty)
                EmptyState(
                  title: context.l10n.emptyLinkedTasksTitle,
                  description: context.l10n.emptyLinkedTasksDescription,
                  icon: Icons.checklist_rtl_rounded,
                )
              else
                ...tasks.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: InkWell(
                      onTap: () => context.push('/task/${task.id}'),
                      child: SectionCard(
                        child: Text(task.title),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(
                title: context.l10n.linkedNotesTitle,
                subtitle: context.l10n.linkedNotesSubtitle,
              ),
              const SizedBox(height: AppSpacing.md),
              if (notes.isEmpty)
                EmptyState(
                  title: context.l10n.emptyLinkedNotesTitle,
                  description: context.l10n.emptyLinkedNotesDescription,
                  icon: Icons.note_alt_rounded,
                )
              else
                ...notes.map(
                  (note) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: SectionCard(
                      child: Text(note.title),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(
                title: context.copy.examsTitle,
                subtitle: context.copy.examsSubtitle,
              ),
              const SizedBox(height: AppSpacing.md),
              if (exams.isEmpty)
                EmptyState(
                  title: context.copy.emptyExamsTitle,
                  description: context.copy.emptyExamsDescription,
                  icon: Icons.event_note_rounded,
                )
              else
                ...exams.map(
                  (exam) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: SectionCard(
                      child: Text(exam.title),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton(
                onPressed: () async {
                  await ref
                      .read(studyDataControllerProvider.notifier)
                      .deleteCourse(course.id);
                  if (context.mounted) {
                    context.pop();
                  }
                },
                child: Text(context.l10n.deleteCourseAction),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CourseEditorScreen extends ConsumerStatefulWidget {
  const CourseEditorScreen({
    super.key,
    this.courseId,
  });

  static const routePath = '/course/edit';

  final String? courseId;

  @override
  ConsumerState<CourseEditorScreen> createState() => _CourseEditorScreenState();
}

class _CourseEditorScreenState extends ConsumerState<CourseEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructorController = TextEditingController();
  bool _initialized = false;
  int _selectedColor = 0xFF18456B;

  static const _colorOptions = [
    0xFF18456B,
    0xFF1F6FEB,
    0xFF24A19C,
    0xFFF4A261,
    0xFFD95D39,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(studyDataControllerProvider);

    return AppPage(
      child: data.when(
        loading: () => const LoadingColumn(itemCount: 2),
        error: (error, _) => ErrorStateCard(
          message: context.resolveError(error),
          onRetry: () => ref.read(studyDataControllerProvider.notifier).refresh(),
        ),
        data: (studyData) {
          final existing = widget.courseId == null
              ? null
              : studyData.courseById(widget.courseId);

          if (!_initialized) {
            _initialized = true;
            if (existing != null) {
              _titleController.text = existing.title;
              _descriptionController.text = existing.description;
              _instructorController.text = existing.instructorName ?? '';
              _selectedColor = existing.color;
            }
          }

          return ListView(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: context.pop,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      existing == null
                          ? context.l10n.addCourseTitle
                          : context.l10n.editCourseTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
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
                      TextFormField(
                        controller: _instructorController,
                        decoration: InputDecoration(
                          labelText: context.l10n.instructorLabel,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          context.l10n.courseColorLabel,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        children: _colorOptions
                            .map(
                              (color) => GestureDetector(
                                onTap: () => setState(() => _selectedColor = color),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Color(color),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _selectedColor == color
                                          ? Theme.of(context).colorScheme.onSurface
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
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
                          final course = CourseModel(
                            id: existing?.id ?? const Uuid().v4(),
                            userId: user.id,
                            title: _titleController.text.trim(),
                            description: _descriptionController.text.trim(),
                            instructorName: _instructorController.text.trim().isEmpty
                                ? null
                                : _instructorController.text.trim(),
                            color: _selectedColor,
                            createdAt: existing?.createdAt ?? now,
                            updatedAt: now,
                          );

                          await ref
                              .read(studyDataControllerProvider.notifier)
                              .saveCourse(course);
                          if (!mounted) return;
                          context.pop();
                        },
                        child: Text(context.l10n.saveCourseAction),
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
