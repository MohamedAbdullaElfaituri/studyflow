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

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  static const routePath = '/habits';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(studyDataControllerProvider);

    return AppPage(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(HabitEditorScreen.routePath),
        label: Text(context.copy.addHabitAction),
        icon: const Icon(Icons.add_rounded),
      ),
      child: data.when(
        loading: () => const LoadingColumn(itemCount: 4),
        error: (error, _) => ErrorStateCard(
          message: context.resolveError(error),
          onRetry: () =>
              ref.read(studyDataControllerProvider.notifier).refresh(),
        ),
        data: (studyData) {
          final habits = studyData.activeHabits;
          final isCompact = MediaQuery.sizeOf(context).width < 390;
          return ListView(
            children: [
              SectionHeader(
                title: context.copy.habitsTitle,
                subtitle: context.copy.habitsSubtitle,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (isCompact)
                Column(
                  children: [
                    HeroMetricCard(
                      title: context.copy.levelLabel,
                      value: '${studyData.completedHabits.length}',
                      subtitle: context.copy.habitsQuickCardTitle,
                      icon: Icons.workspace_premium_rounded,
                      accent: const Color(0xFF2BAE9A),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    HeroMetricCard(
                      title: context.l10n.streakLabel,
                      value:
                          '${habits.fold<int>(0, (sum, item) => sum + item.streakCount)}',
                      subtitle: context.copy.motivationMomentTitle,
                      icon: Icons.local_fire_department_rounded,
                      accent: const Color(0xFFF4A261),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: HeroMetricCard(
                        title: context.copy.levelLabel,
                        value: '${studyData.completedHabits.length}',
                        subtitle: context.copy.habitsQuickCardTitle,
                        icon: Icons.workspace_premium_rounded,
                        accent: const Color(0xFF2BAE9A),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: HeroMetricCard(
                        title: context.l10n.streakLabel,
                        value:
                            '${habits.fold<int>(0, (sum, item) => sum + item.streakCount)}',
                        subtitle: context.copy.motivationMomentTitle,
                        icon: Icons.local_fire_department_rounded,
                        accent: const Color(0xFFF4A261),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: AppSpacing.xl),
              if (habits.isEmpty)
                EmptyState(
                  title: context.copy.emptyHabitsTitle,
                  description: context.copy.emptyHabitsDescription,
                  icon: Icons.repeat_rounded,
                  action: FilledButton.tonal(
                    onPressed: () => context.push(HabitEditorScreen.routePath),
                    child: Text(context.copy.addHabitAction),
                  ),
                )
              else
                ...habits.map(
                  (habit) {
                    final progress = (habit.completedCount / habit.goalCount)
                        .clamp(0.0, 1.0);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28),
                        onTap: () => context.push(
                          '${HabitEditorScreen.routePath}?habitId=${habit.id}',
                        ),
                        child: SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isCompact)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor:
                                              Color(habit.color).withValues(
                                            alpha: 0.14,
                                          ),
                                          child: Icon(
                                            Icons.repeat_rounded,
                                            color: Color(habit.color),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                habit.title,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              const SizedBox(
                                                  height: AppSpacing.xs),
                                              Text(
                                                habit.description,
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
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    FilledButton.tonal(
                                      onPressed: habit.isCompleted
                                          ? null
                                          : () => ref
                                              .read(
                                                studyDataControllerProvider
                                                    .notifier,
                                              )
                                              .completeHabit(habit),
                                      child: Text(context.l10n.finishAction),
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          Color(habit.color).withValues(
                                        alpha: 0.14,
                                      ),
                                      child: Icon(
                                        Icons.repeat_rounded,
                                        color: Color(habit.color),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            habit.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            habit.description,
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
                                    FilledButton.tonal(
                                      onPressed: habit.isCompleted
                                          ? null
                                          : () => ref
                                              .read(
                                                studyDataControllerProvider
                                                    .notifier,
                                              )
                                              .completeHabit(habit),
                                      child: Text(context.l10n.finishAction),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: AppSpacing.md),
                              LinearProgressIndicator(
                                value: progress.toDouble(),
                                color: Color(habit.color),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.sm,
                                children: [
                                  StatusPill(
                                    label: context.copy.habitProgress(
                                      habit.completedCount,
                                      habit.goalCount,
                                    ),
                                    color: Color(habit.color),
                                  ),
                                  StatusPill(
                                    label: context.copy
                                        .habitStreak(habit.streakCount),
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                  StatusPill(
                                    label:
                                        habit.frequency == HabitFrequency.daily
                                            ? context.copy.habitDaily
                                            : context.copy.habitWeekly,
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

class HabitEditorScreen extends ConsumerStatefulWidget {
  const HabitEditorScreen({
    super.key,
    this.habitId,
  });

  static const routePath = '/habit/edit';

  final String? habitId;

  @override
  ConsumerState<HabitEditorScreen> createState() => _HabitEditorScreenState();
}

class _HabitEditorScreenState extends ConsumerState<HabitEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  HabitFrequency _frequency = HabitFrequency.daily;
  int _goalCount = 1;
  int _color = 0xFF2BAE9A;
  bool _initialized = false;

  static const _colorOptions = [
    0xFF2BAE9A,
    0xFF1F6FEB,
    0xFFF4A261,
    0xFFD95D39,
    0xFF7B61FF,
  ];

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
        loading: () => const LoadingColumn(itemCount: 2),
        error: (error, _) => ErrorStateCard(
          message: context.resolveError(error),
          onRetry: () =>
              ref.read(studyDataControllerProvider.notifier).refresh(),
        ),
        data: (studyData) {
          final existing = widget.habitId == null
              ? null
              : studyData.habitById(widget.habitId!);
          final isCompact = MediaQuery.sizeOf(context).width < 390;

          if (!_initialized) {
            _initialized = true;
            if (existing != null) {
              _titleController.text = existing.title;
              _descriptionController.text = existing.description;
              _frequency = existing.frequency;
              _goalCount = existing.goalCount;
              _color = existing.color;
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
                          ? context.copy.addHabitTitle
                          : context.copy.editHabitTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (existing != null)
                    IconButton(
                      onPressed: () async {
                        await ref
                            .read(studyDataControllerProvider.notifier)
                            .deleteHabit(existing.id);
                        if (!mounted) return;
                        context.pop();
                      },
                      icon: const Icon(Icons.delete_outline_rounded),
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
                      if (isCompact)
                        Column(
                          children: [
                            DropdownButtonFormField<HabitFrequency>(
                              initialValue: _frequency,
                              decoration: InputDecoration(
                                labelText: context.copy.habitFrequencyLabel,
                              ),
                              items: HabitFrequency.values
                                  .map(
                                    (value) => DropdownMenuItem<HabitFrequency>(
                                      value: value,
                                      child: Text(
                                        value == HabitFrequency.daily
                                            ? context.copy.habitDaily
                                            : context.copy.habitWeekly,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _frequency = value!),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            DropdownButtonFormField<int>(
                              initialValue: _goalCount,
                              decoration: InputDecoration(
                                labelText: context.copy.habitGoalLabel,
                              ),
                              items: List.generate(
                                5,
                                (index) => DropdownMenuItem<int>(
                                  value: index + 1,
                                  child: Text('${index + 1}'),
                                ),
                              ),
                              onChanged: (value) =>
                                  setState(() => _goalCount = value ?? 1),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<HabitFrequency>(
                                initialValue: _frequency,
                                decoration: InputDecoration(
                                  labelText: context.copy.habitFrequencyLabel,
                                ),
                                items: HabitFrequency.values
                                    .map(
                                      (value) =>
                                          DropdownMenuItem<HabitFrequency>(
                                        value: value,
                                        child: Text(
                                          value == HabitFrequency.daily
                                              ? context.copy.habitDaily
                                              : context.copy.habitWeekly,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => _frequency = value!),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                initialValue: _goalCount,
                                decoration: InputDecoration(
                                  labelText: context.copy.habitGoalLabel,
                                ),
                                items: List.generate(
                                  5,
                                  (index) => DropdownMenuItem<int>(
                                    value: index + 1,
                                    child: Text('${index + 1}'),
                                  ),
                                ),
                                onChanged: (value) =>
                                    setState(() => _goalCount = value ?? 1),
                              ),
                            ),
                          ],
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
                              (value) => GestureDetector(
                                onTap: () => setState(() => _color = value),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Color(value),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _color == value
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onSurface
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
                          final habit = HabitModel(
                            id: existing?.id ?? const Uuid().v4(),
                            userId: user.id,
                            title: _titleController.text.trim(),
                            description: _descriptionController.text.trim(),
                            color: _color,
                            frequency: _frequency,
                            goalCount: _goalCount,
                            completedCount: existing?.completedCount ?? 0,
                            streakCount: existing?.streakCount ?? 0,
                            lastCompletedAt: existing?.lastCompletedAt,
                            createdAt: existing?.createdAt ?? now,
                            updatedAt: now,
                          );

                          await ref
                              .read(studyDataControllerProvider.notifier)
                              .saveHabit(habit);
                          if (!mounted) return;
                          context.pop();
                        },
                        child: Text(context.copy.saveHabitAction),
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
