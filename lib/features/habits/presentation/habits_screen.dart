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

  Future<void> _completeHabit(
    BuildContext context,
    WidgetRef ref,
    HabitModel habit,
  ) async {
    final nextCompleted = habit.completedCount + 1 > habit.goalCount
        ? habit.goalCount
        : habit.completedCount + 1;

    try {
      await ref.read(studyDataControllerProvider.notifier).completeHabit(habit);
      if (context.mounted && nextCompleted >= habit.goalCount) {
        context.showSuccessNotification(context.copy.habitGoalCompletedMessage);
      }
    } catch (error) {
      if (context.mounted) {
        context.showErrorNotification(context.resolveError(error));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(studyDataControllerProvider);

    return AppPage(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push<bool>(HabitEditorScreen.routePath);
          if (context.mounted && (result ?? false)) {
            ref.invalidate(studyDataControllerProvider);
          }
        },
        label: Text(context.copy.addHabitAction),
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
          final habits = studyData.activeHabits;
          final isCompact = MediaQuery.sizeOf(context).width < 520;
          final totalStreak =
              habits.fold<int>(0, (sum, item) => sum + item.streakCount);

          return ListView(
            children: [
              PageHeader(
                title: _habitsTitle(context),
                subtitle: _habitsSubtitle(context),
              ),
              const SizedBox(height: AppSpacing.lg),
              AdaptiveCardGrid(
                minItemWidth: 170,
                children: [
                  DashboardStatCard(
                    label: _completedHabitsLabel(context),
                    value: '${studyData.completedHabits.length}',
                    caption: _habitsQuickCardTitle(context),
                    icon: Icons.workspace_premium_rounded,
                    accent: const Color(0xFF2BAE9A),
                  ),
                  DashboardStatCard(
                    label: context.l10n.streakLabel,
                    value: '$totalStreak',
                    caption: _focusNoteTitle(context),
                    icon: Icons.local_fire_department_rounded,
                    accent: const Color(0xFFF4A261),
                  ),
                  DashboardStatCard(
                    label: _habitsTitle(context),
                    value: '${habits.length}',
                    caption: _activeHabitsCaption(context, habits.length),
                    icon: Icons.repeat_rounded,
                    accent: Theme.of(context).colorScheme.primary,
                  ),
                  DashboardStatCard(
                    label: _consistencyLabel(context),
                    value: '${(studyData.habitConsistency * 100).round()}%',
                    caption: _habitCompletionCaption(
                      context,
                      studyData.completedHabits.length,
                      studyData.habits.length,
                    ),
                    icon: Icons.insights_rounded,
                    accent: Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              if (habits.isEmpty)
                EmptyState(
                  title: _emptyHabitsTitle(context),
                  description: _emptyHabitsDescription(context),
                  icon: Icons.repeat_rounded,
                  action: FilledButton.tonal(
                    onPressed: () async {
                      final result =
                          await context.push<bool>(HabitEditorScreen.routePath);
                      if (context.mounted && (result ?? false)) {
                        ref.invalidate(studyDataControllerProvider);
                      }
                    },
                    child: Text(_addHabitAction(context)),
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
                        onTap: () async {
                          final saved = await context.push<bool>(
                            '${HabitEditorScreen.routePath}?habitId=${habit.id}',
                          );
                          if (context.mounted && (saved ?? false)) {
                            ref.invalidate(studyDataControllerProvider);
                          }
                        },
                        child: SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isCompact)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(
                                                height: AppSpacing.xs,
                                              ),
                                              Text(
                                                habit.description,
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
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    FilledButton.tonal(
                                      onPressed: habit.isCompleted
                                          ? null
                                          : () => _completeHabit(
                                                context,
                                                ref,
                                                habit,
                                              ),
                                      child: Text(context.l10n.finishAction),
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            habit.description,
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
                                    FilledButton.tonal(
                                      onPressed: habit.isCompleted
                                          ? null
                                          : () => _completeHabit(
                                                context,
                                                ref,
                                                habit,
                                              ),
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
                                    label: _habitProgress(
                                      context,
                                      habit.completedCount,
                                      habit.goalCount,
                                    ),
                                    color: Color(habit.color),
                                  ),
                                  StatusPill(
                                    label: _habitStreak(
                                      context,
                                      habit.streakCount,
                                    ),
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                  StatusPill(
                                    label:
                                        habit.frequency == HabitFrequency.daily
                                            ? _habitDaily(context)
                                            : _habitWeekly(context),
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
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
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
          final isCompact = MediaQuery.sizeOf(context).width < 560;

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
              PageHeader(
                title: existing == null
                    ? _addHabitAction(context)
                    : _editHabitTitle(context),
                trailing: existing == null
                    ? null
                    : IconButton(
                        onPressed: () async {
                          try {
                            await ref
                                .read(studyDataControllerProvider.notifier)
                                .deleteHabit(existing.id);
                            if (!mounted) return;
                            context.showSuccessNotification(
                              context.copy.habitDeletedMessage,
                            );
                            context.pop(true);
                          } catch (error) {
                            if (!mounted) return;
                            context.showErrorNotification(
                              context.resolveError(error),
                            );
                          }
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
                      if (isCompact)
                        Column(
                          children: [
                            DropdownButtonFormField<HabitFrequency>(
                              value: _frequency,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: _habitFrequencyLabel(context),
                              ),
                              items: HabitFrequency.values
                                  .map(
                                    (value) => DropdownMenuItem<HabitFrequency>(
                                      value: value,
                                      child: Text(
                                        value == HabitFrequency.daily
                                            ? _habitDaily(context)
                                            : _habitWeekly(context),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _frequency = value!),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            DropdownButtonFormField<int>(
                              value: _goalCount,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: _habitGoalLabel(context),
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
                                value: _frequency,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: _habitFrequencyLabel(context),
                                ),
                                items: HabitFrequency.values
                                    .map(
                                      (value) =>
                                          DropdownMenuItem<HabitFrequency>(
                                        value: value,
                                        child: Text(
                                          value == HabitFrequency.daily
                                              ? _habitDaily(context)
                                              : _habitWeekly(context),
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
                                value: _goalCount,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: _habitGoalLabel(context),
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
                          _colorLabel(context),
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

                          try {
                            await ref
                                .read(studyDataControllerProvider.notifier)
                                .saveHabit(habit);
                            if (!mounted) return;
                            context.showSuccessNotification(
                              context.copy.habitSavedMessage(
                                isNew: existing == null,
                              ),
                            );
                            context.pop(true);
                          } catch (error) {
                            if (!mounted) return;
                            context.showErrorNotification(
                              context.resolveError(error),
                            );
                          }
                        },
                        child: Text(_saveHabitAction(context)),
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

String _addHabitAction(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Alışkanlık ekle',
    'ar' => 'إضافة عادة',
    _ => 'Add habit',
  };
}

String _editHabitTitle(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Alışkanlığı düzenle',
    'ar' => 'تعديل العادة',
    _ => 'Edit habit',
  };
}

String _saveHabitAction(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Alışkanlığı kaydet',
    'ar' => 'حفظ العادة',
    _ => 'Save habit',
  };
}

String _habitsTitle(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Alışkanlıklar',
    'ar' => 'العادات',
    _ => 'Habits',
  };
}

String _habitsSubtitle(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Gününü destekleyen basit rutinleri takip et.',
    'ar' => 'تابع عادات بسيطة تدعم يومك الدراسي.',
    _ => 'Track simple routines that support your day.',
  };
}

String _habitsQuickCardTitle(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Günlük rutinler',
    'ar' => 'العادات اليومية',
    _ => 'Daily routines',
  };
}

String _completedHabitsLabel(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Tamamlananlar',
    'ar' => 'المكتمل',
    _ => 'Completed',
  };
}

String _focusNoteTitle(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Odak notu',
    'ar' => 'ملاحظة تركيز',
    _ => 'Focus note',
  };
}

String _emptyHabitsTitle(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Henüz alışkanlık yok',
    'ar' => 'لا توجد عادات بعد',
    _ => 'No habits yet',
  };
}

String _emptyHabitsDescription(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Günlük ritmine destek olacak basit bir alışkanlık ekle.',
    'ar' => 'أضف عادة بسيطة تدعم روتينك اليومي.',
    _ => 'Add a simple habit to support your daily routine.',
  };
}

String _habitFrequencyLabel(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Sıklık',
    'ar' => 'التكرار',
    _ => 'Frequency',
  };
}

String _habitGoalLabel(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Günlük hedef',
    'ar' => 'الهدف اليومي',
    _ => 'Daily goal',
  };
}

String _colorLabel(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Renk',
    'ar' => 'اللون',
    _ => 'Color',
  };
}

String _habitDaily(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Günlük',
    'ar' => 'يومي',
    _ => 'Daily',
  };
}

String _habitWeekly(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Haftalık',
    'ar' => 'أسبوعي',
    _ => 'Weekly',
  };
}

String _habitProgress(BuildContext context, int value, int target) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => '$value / $target tamamlandı',
    'ar' => '$value / $target مكتمل',
    _ => '$value / $target complete',
  };
}

String _habitStreak(BuildContext context, int streak) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => '$streak gün seri',
    'ar' => 'سلسلة $streak يوم',
    _ => '$streak day streak',
  };
}

String _activeHabitsCaption(BuildContext context, int count) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => '$count aktif rutin',
    'ar' => '$count روتين نشط',
    _ => '$count active routines',
  };
}

String _consistencyLabel(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => 'Tutarlılık',
    'ar' => 'الاتساق',
    _ => 'Consistency',
  };
}

String _habitCompletionCaption(BuildContext context, int completed, int total) {
  return switch (Localizations.localeOf(context).languageCode) {
    'tr' => '$completed / $total tamamlandı',
    'ar' => '$completed / $total مكتمل',
    _ => '$completed / $total complete',
  };
}
