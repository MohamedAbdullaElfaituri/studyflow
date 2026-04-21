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

enum _TaskFilter { all, pending, inProgress, completed }

enum _TaskSort { dueDate, priority, course }

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  static const routePath = '/tasks';

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final _searchController = TextEditingController();
  _TaskFilter _filter = _TaskFilter.all;
  _TaskSort _sort = _TaskSort.dueDate;

  Future<void> _archiveCompletedTasks(StudyDataState studyData) async {
    final archiveCount =
        studyData.completedTasks.where((task) => !task.isArchived).length;

    if (archiveCount == 0) {
      context
          .showInfoNotification(context.copy.noCompletedTasksToArchiveMessage);
      return;
    }

    try {
      await ref
          .read(studyDataControllerProvider.notifier)
          .archiveCompletedTasks();
      if (!mounted) {
        return;
      }
      context.showSuccessNotification(
        context.copy.archivedTasksMessage(archiveCount),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      context.showErrorNotification(context.resolveError(error));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(studyDataControllerProvider);
    final locale = Localizations.localeOf(context).languageCode;

    return AppPage(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(TaskEditorScreen.routePath),
        label: Text(context.l10n.addTaskAction),
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
          final query = _searchController.text.trim().toLowerCase();
          final dueToday = studyData.todayTasks
              .where((task) => task.status != TaskStatus.completed)
              .length;
          final overdue = studyData.activeTasks
              .where(
                (task) =>
                    task.status != TaskStatus.completed &&
                    task.dueDateTime != null &&
                    task.dueDateTime!.isBefore(DateTime.now()),
              )
              .length;
          final filtered = studyData.activeTasks.where((task) {
            final matchesSearch = query.isEmpty ||
                task.title.toLowerCase().contains(query) ||
                task.description.toLowerCase().contains(query);
            final matchesFilter = switch (_filter) {
              _TaskFilter.all => true,
              _TaskFilter.pending => task.status == TaskStatus.pending,
              _TaskFilter.inProgress => task.status == TaskStatus.inProgress,
              _TaskFilter.completed => task.status == TaskStatus.completed,
            };
            return matchesSearch && matchesFilter;
          }).toList()
            ..sort((a, b) {
              switch (_sort) {
                case _TaskSort.dueDate:
                  return (a.dueDateTime ?? DateTime(3000))
                      .compareTo(b.dueDateTime ?? DateTime(3000));
                case _TaskSort.priority:
                  return b.priority.index.compareTo(a.priority.index);
                case _TaskSort.course:
                  final courseA =
                      studyData.courseById(a.courseId)?.title.toLowerCase() ??
                          '';
                  final courseB =
                      studyData.courseById(b.courseId)?.title.toLowerCase() ??
                          '';
                  return courseA.compareTo(courseB);
              }
            });

          return ListView(
            children: [
              PageHeader(
                leading: const AppLogo(size: 44, radius: 18),
                title: context.l10n.tasksTitle,
                subtitle: context.l10n.tasksSubtitle,
                trailing: PopupMenuButton<_TaskSort>(
                  initialValue: _sort,
                  onSelected: (value) => setState(() => _sort = value),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _TaskSort.dueDate,
                      child: Text(context.l10n.sortByDueDate),
                    ),
                    PopupMenuItem(
                      value: _TaskSort.priority,
                      child: Text(context.l10n.sortByPriority),
                    ),
                    PopupMenuItem(
                      value: _TaskSort.course,
                      child: Text(context.l10n.sortByCourse),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AdaptiveCardGrid(
                minItemWidth: 170,
                children: [
                  DashboardStatCard(
                    label: _openTasksLabel(context),
                    value: '${studyData.activeTasks.length}',
                    caption: context.l10n.tasksSubtitle,
                    icon: Icons.task_alt_rounded,
                    accent: Theme.of(context).colorScheme.primary,
                  ),
                  DashboardStatCard(
                    label: _dueTodayLabel(context),
                    value: '$dueToday',
                    caption: DateTimeUtils.friendlyDate(DateTime.now(), locale),
                    icon: Icons.calendar_today_rounded,
                    accent: Theme.of(context).colorScheme.secondary,
                  ),
                  DashboardStatCard(
                    label: context.l10n.completedTasksLabel,
                    value: '${studyData.completedTasks.length}',
                    caption: _taskSummaryCaption(
                      context,
                      studyData.completedTasks.length,
                      studyData.tasks.length,
                    ),
                    icon: Icons.check_circle_rounded,
                    accent: const Color(0xFF2BAE9A),
                  ),
                  DashboardStatCard(
                    label: _overdueLabel(context),
                    value: '$overdue',
                    caption: _overdueCaption(context, overdue),
                    icon: Icons.warning_amber_rounded,
                    accent: const Color(0xFFD95D39),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                child: Column(
                  children: [
                    SearchTextField(
                      controller: _searchController,
                      hintText: context.l10n.searchTasksHint,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        FilterChip(
                          label: Text(context.l10n.filterAll),
                          selected: _filter == _TaskFilter.all,
                          onSelected: (_) =>
                              setState(() => _filter = _TaskFilter.all),
                        ),
                        FilterChip(
                          label: Text(context.l10n.filterPending),
                          selected: _filter == _TaskFilter.pending,
                          onSelected: (_) =>
                              setState(() => _filter = _TaskFilter.pending),
                        ),
                        FilterChip(
                          label: Text(context.l10n.filterInProgress),
                          selected: _filter == _TaskFilter.inProgress,
                          onSelected: (_) =>
                              setState(() => _filter = _TaskFilter.inProgress),
                        ),
                        FilterChip(
                          label: Text(context.l10n.filterCompleted),
                          selected: _filter == _TaskFilter.completed,
                          onSelected: (_) =>
                              setState(() => _filter = _TaskFilter.completed),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.tonal(
                      onPressed: () => _archiveCompletedTasks(studyData),
                      child: Text(context.l10n.archiveCompletedAction),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (filtered.isEmpty)
                EmptyState(
                  title: context.l10n.emptyTasksTitle,
                  description: context.l10n.emptyTasksDescription,
                  icon: Icons.checklist_rtl_rounded,
                  action: FilledButton.tonal(
                    onPressed: () => context.push(TaskEditorScreen.routePath),
                    child: Text(context.l10n.addTaskAction),
                  ),
                )
              else
                ...filtered.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: InkWell(
                      onTap: () => context.push('/task/${task.id}'),
                      borderRadius: BorderRadius.circular(24),
                      child: SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: priorityColor(task.priority)
                                      .withValues(alpha: 0.14),
                                  child: Icon(
                                    Icons.checklist_rtl_rounded,
                                    color: priorityColor(task.priority),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        task.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
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
                                const SizedBox(width: AppSpacing.sm),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: AppSpacing.xs),
                                  child: Checkbox(
                                    value: task.status == TaskStatus.completed,
                                    onChanged: (_) => ref
                                        .read(
                                          studyDataControllerProvider.notifier,
                                        )
                                        .toggleTaskStatus(task),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                StatusPill(
                                  label: _taskStatusLabel(context, task.status),
                                  color: statusColor(task.status),
                                ),
                                StatusPill(
                                  label: _taskPriorityLabel(
                                    context,
                                    task.priority,
                                  ),
                                  color: priorityColor(task.priority),
                                ),
                                if (task.dueDateTime != null)
                                  StatusPill(
                                    label: DateTimeUtils.friendlyDate(
                                      task.dueDateTime!,
                                      locale,
                                    ),
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                              ],
                            ),
                          ],
                        ),
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
}

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({
    required this.taskId,
    super.key,
  });

  static const routePath = '/task/:taskId';

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          final task = studyData.taskById(taskId);
          if (task == null) {
            return EmptyState(
              title: context.l10n.taskNotFoundTitle,
              description: context.l10n.taskNotFoundDescription,
            );
          }

          final course = studyData.courseById(task.courseId);

          return ListView(
            children: [
              PageHeader(
                title: context.l10n.taskDetailTitle,
                trailing: IconButton(
                  onPressed: () => context.push(
                    '${TaskEditorScreen.routePath}?taskId=${task.id}',
                  ),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title,
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: AppSpacing.md),
                    Text(task.description),
                    const SizedBox(height: AppSpacing.lg),
                    DetailRow(
                      label: context.l10n.statusLabel,
                      value: _taskStatusLabel(context, task.status),
                    ),
                    DetailRow(
                      label: context.l10n.priorityLabel,
                      value: _taskPriorityLabel(context, task.priority),
                    ),
                    if (task.dueDateTime != null)
                      DetailRow(
                        label: context.l10n.dueDateLabel,
                        value: DateTimeUtils.friendlyDate(
                            task.dueDateTime!, locale),
                      ),
                    DetailRow(
                      label: context.l10n.estimatedMinutesLabel,
                      value: '${task.estimatedMinutes}',
                    ),
                    if (course != null)
                      DetailRow(
                        label: context.l10n.courseLabel,
                        value: course.title,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.subtasksTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (task.subtasks.isEmpty)
                      Text(context.l10n.emptySubtasksDescription)
                    else
                      ...task.subtasks.map(
                        (subtask) => CheckboxListTile(
                          value: subtask.isCompleted,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (_) => ref
                              .read(studyDataControllerProvider.notifier)
                              .toggleSubtask(task, subtask),
                          title: Text(subtask.title),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton(
                onPressed: () async {
                  try {
                    await ref
                        .read(studyDataControllerProvider.notifier)
                        .deleteTask(task.id);
                    if (context.mounted) {
                      context.showSuccessNotification(
                        context.copy.taskDeletedMessage,
                      );
                      context.pop();
                    }
                  } catch (error) {
                    if (context.mounted) {
                      context.showErrorNotification(
                        context.resolveError(error),
                      );
                    }
                  }
                },
                child: Text(context.l10n.deleteTaskAction),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TaskEditorScreen extends ConsumerStatefulWidget {
  const TaskEditorScreen({
    super.key,
    this.taskId,
  });

  static const routePath = '/task/edit';

  final String? taskId;

  @override
  ConsumerState<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends ConsumerState<TaskEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimatedMinutesController = TextEditingController(text: '60');
  final List<TextEditingController> _subtaskControllers = [];

  TaskPriority _priority = TaskPriority.medium;
  TaskStatus _status = TaskStatus.pending;
  String? _courseId;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedMinutesController.dispose();
    for (final controller in _subtaskControllers) {
      controller.dispose();
    }
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
              widget.taskId == null ? null : studyData.taskById(widget.taskId!);
          final isCompact = MediaQuery.sizeOf(context).width < 560;
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
              _estimatedMinutesController.text =
                  existing.estimatedMinutes.toString();
              _priority = existing.priority;
              _status = existing.status;
              _courseId = existing.courseId;
              _dueDate = existing.dueDateTime;
              _dueTime = existing.dueDateTime == null
                  ? null
                  : TimeOfDay.fromDateTime(existing.dueDateTime!);
              for (final subtask in existing.subtasks) {
                _subtaskControllers
                    .add(TextEditingController(text: subtask.title));
              }
            } else if (_subtaskControllers.isEmpty) {
              _subtaskControllers.add(TextEditingController());
            }
          }

          return ListView(
            children: [
              PageHeader(
                title: existing == null
                    ? context.l10n.addTaskTitle
                    : context.l10n.editTaskTitle,
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
                        isExpanded: true,
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
                            DropdownButtonFormField<TaskPriority>(
                              initialValue: _priority,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: context.l10n.priorityLabel,
                              ),
                              items: TaskPriority.values
                                  .map(
                                    (value) => DropdownMenuItem(
                                      value: value,
                                      child: Text(
                                        _taskPriorityLabel(context, value),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _priority = value!),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            DropdownButtonFormField<TaskStatus>(
                              initialValue: _status,
                              isExpanded: true,
                              decoration: InputDecoration(
                                  labelText: context.l10n.statusLabel),
                              items: TaskStatus.values
                                  .map(
                                    (value) => DropdownMenuItem(
                                      value: value,
                                      child: Text(
                                        _taskStatusLabel(context, value),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _status = value!),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<TaskPriority>(
                                initialValue: _priority,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: context.l10n.priorityLabel,
                                ),
                                items: TaskPriority.values
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(
                                          _taskPriorityLabel(context, value),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => _priority = value!),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: DropdownButtonFormField<TaskStatus>(
                                initialValue: _status,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: context.l10n.statusLabel,
                                ),
                                items: TaskStatus.values
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(
                                          _taskStatusLabel(context, value),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => _status = value!),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _estimatedMinutesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: context.l10n.estimatedMinutesLabel,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (isCompact)
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime.now()
                                        .subtract(const Duration(days: 365)),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 730)),
                                    initialDate: _dueDate ?? DateTime.now(),
                                  );
                                  if (picked != null) {
                                    setState(() => _dueDate = picked);
                                  }
                                },
                                child: Text(
                                  _dueDate == null
                                      ? context.l10n.pickDateAction
                                      : DateTimeUtils.friendlyDate(
                                          _dueDate!,
                                          Localizations.localeOf(context)
                                              .languageCode,
                                        ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: _dueTime ?? TimeOfDay.now(),
                                  );
                                  if (picked != null) {
                                    setState(() => _dueTime = picked);
                                  }
                                },
                                child: Text(
                                  _dueTime == null
                                      ? context.l10n.pickTimeAction
                                      : _dueTime!.format(context),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime.now()
                                          .subtract(const Duration(days: 365)),
                                      lastDate: DateTime.now()
                                          .add(const Duration(days: 730)),
                                      initialDate: _dueDate ?? DateTime.now(),
                                    );
                                    if (picked != null) {
                                      setState(() => _dueDate = picked);
                                    }
                                  },
                                  child: Text(
                                    _dueDate == null
                                        ? context.l10n.pickDateAction
                                        : DateTimeUtils.friendlyDate(
                                            _dueDate!,
                                            Localizations.localeOf(context)
                                                .languageCode,
                                          ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () async {
                                    final picked = await showTimePicker(
                                      context: context,
                                      initialTime: _dueTime ?? TimeOfDay.now(),
                                    );
                                    if (picked != null) {
                                      setState(() => _dueTime = picked);
                                    }
                                  },
                                  child: Text(
                                    _dueTime == null
                                        ? context.l10n.pickTimeAction
                                        : _dueTime!.format(context),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          context.l10n.subtasksTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ..._subtaskControllers.asMap().entries.map(
                            (entry) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: entry.value,
                                      decoration: InputDecoration(
                                        labelText: context.l10n.subtaskLabel(
                                          entry.key + 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _subtaskControllers.length == 1
                                        ? null
                                        : () {
                                            setState(() {
                                              _subtaskControllers[entry.key]
                                                  .dispose();
                                              _subtaskControllers
                                                  .removeAt(entry.key);
                                            });
                                          },
                                    icon: const Icon(
                                        Icons.remove_circle_outline_rounded),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _subtaskControllers.add(TextEditingController());
                            });
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: Text(context.l10n.addSubtaskAction),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          final user = ref.read(currentUserProvider);
                          if (user == null) {
                            return;
                          }

                          final now = DateTime.now();
                          final dueDateTime = _dueDate == null
                              ? null
                              : DateTime(
                                  _dueDate!.year,
                                  _dueDate!.month,
                                  _dueDate!.day,
                                  _dueTime?.hour ?? 9,
                                  _dueTime?.minute ?? 0,
                                );

                          final task = TaskModel(
                            id: existing?.id ?? const Uuid().v4(),
                            userId: user.id,
                            courseId: selectedCourseId,
                            title: _titleController.text.trim(),
                            description: _descriptionController.text.trim(),
                            dueDateTime: dueDateTime,
                            priority: _priority,
                            status: _status,
                            estimatedMinutes: int.tryParse(
                                    _estimatedMinutesController.text) ??
                                0,
                            isArchived: existing?.isArchived ?? false,
                            subtasks: _subtaskControllers
                                .where((controller) =>
                                    controller.text.trim().isNotEmpty)
                                .map(
                                  (controller) => SubtaskModel(
                                    id: const Uuid().v4(),
                                    taskId: existing?.id ?? 'draft',
                                    title: controller.text.trim(),
                                    isCompleted: false,
                                    createdAt: now,
                                  ),
                                )
                                .toList(),
                            createdAt: existing?.createdAt ?? now,
                            updatedAt: now,
                          );

                          try {
                            await ref
                                .read(studyDataControllerProvider.notifier)
                                .saveTask(task);
                            if (!mounted) return;
                            context.showSuccessNotification(
                              context.copy.taskSavedMessage(
                                isNew: existing == null,
                              ),
                            );
                            context.pop();
                          } catch (error) {
                            if (!mounted) return;
                            context.showErrorNotification(
                              context.resolveError(error),
                            );
                          }
                        },
                        child: Text(context.l10n.saveTaskAction),
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

String _taskStatusLabel(BuildContext context, TaskStatus status) {
  return switch (status) {
    TaskStatus.pending => context.l10n.filterPending,
    TaskStatus.inProgress => context.l10n.filterInProgress,
    TaskStatus.completed => context.l10n.filterCompleted,
  };
}

String _openTasksLabel(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Acik gorevler',
    'ar' => 'المهام المفتوحة',
    _ => 'Open tasks',
  };
}

String _dueTodayLabel(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Bugun',
    'ar' => 'اليوم',
    _ => 'Due today',
  };
}

String _overdueLabel(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Gecikenler',
    'ar' => 'المتأخرة',
    _ => 'Overdue',
  };
}

String _taskSummaryCaption(BuildContext context, int completed, int total) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => '$completed / $total tamamlandi',
    'ar' => '$completed / $total مكتمل',
    _ => '$completed / $total complete',
  };
}

String _overdueCaption(BuildContext context, int count) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' =>
      count == 0 ? 'Takvim temiz gorunuyor.' : 'Oncelik sirasina gore duzenle.',
    'ar' => count == 0 ? 'الجدول يبدو مرتبًا.' : 'رتبها حسب الأولوية أولًا.',
    _ => count == 0
        ? 'Your schedule looks clear.'
        : 'Sort these by priority first.',
  };
}

String _taskPriorityLabel(BuildContext context, TaskPriority priority) {
  return switch (priority) {
    TaskPriority.low => context.l10n.priorityLow,
    TaskPriority.medium => context.l10n.priorityMedium,
    TaskPriority.high => context.l10n.priorityHigh,
    TaskPriority.urgent => context.l10n.priorityUrgent,
  };
}
