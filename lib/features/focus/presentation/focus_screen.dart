import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/extensions/build_context_x.dart';
import '../../../shared/providers/app_providers.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  static const routePath = '/focus';

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _pulseController;
  final _intentionController = TextEditingController();
  int _focusMinutes = 25;
  int _breakMinutes = 5;
  Duration _remaining = const Duration(minutes: 25);
  bool _isRunning = false;
  bool _isBreak = false;
  String? _courseId;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _intentionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(studyDataControllerProvider);

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
          final selectedCourseId = studyData.courses.any(
            (course) => course.id == _courseId,
          )
              ? _courseId
              : null;
          final totalSeconds = _activeDuration.inSeconds;
          final progress = totalSeconds <= 0
              ? 0.0
              : 1 - (_remaining.inSeconds / totalSeconds);
          final isPaused = !_isRunning &&
              _remaining.inSeconds > 0 &&
              _remaining.inSeconds < totalSeconds;
          final modeLabel = _isBreak
              ? context.l10n.breakModeLabel
              : context.l10n.focusModeLabel;
          final statusLabel = _statusLabel(context, isPaused: isPaused);
          final prompt = _computerPrompt(context, isPaused: isPaused);
          final minutes =
              _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
          final seconds =
              _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

          return ListView(
            children: [
              PageHeader(
                leading: const AppLogo(size: 44, radius: 18),
                title: context.l10n.focusTitle,
                subtitle: context.l10n.focusSubtitle,
                trailing: _FocusStatusBadge(
                  label: statusLabel,
                  active: _isRunning,
                  isBreak: _isBreak,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                padding: EdgeInsets.zero,
                child: _FocusCommandCenter(
                  minutes: minutes,
                  seconds: seconds,
                  modeLabel: modeLabel,
                  statusLabel: statusLabel,
                  prompt: prompt,
                  progress: progress,
                  isRunning: _isRunning,
                  isBreak: _isBreak,
                  pulse: _pulseController,
                  intentionController: _intentionController,
                  onIntentionChanged: (_) => setState(() {}),
                  onStart: !_isRunning && !isPaused ? _startTimer : null,
                  onPause: _isRunning ? _pauseTimer : null,
                  onResume: isPaused ? _resumeTimer : null,
                  onReset: _resetTimer,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.customizeSessionTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _DurationSlider(
                      icon: Icons.center_focus_strong_rounded,
                      label: context.l10n.focusDurationLabel(_focusMinutes),
                      value: _focusMinutes.toDouble(),
                      min: 15,
                      max: 90,
                      divisions: 15,
                      enabled: !_isRunning,
                      onChanged: (value) {
                        setState(() {
                          _focusMinutes = value.round();
                          if (!_isBreak) {
                            _remaining = Duration(minutes: _focusMinutes);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _DurationSlider(
                      icon: Icons.self_improvement_rounded,
                      label: context.l10n.breakDurationLabel(_breakMinutes),
                      value: _breakMinutes.toDouble(),
                      min: 5,
                      max: 30,
                      divisions: 5,
                      enabled: !_isRunning,
                      onChanged: (value) =>
                          setState(() => _breakMinutes = value.round()),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    DropdownButtonFormField<String?>(
                      initialValue: selectedCourseId,
                      decoration: InputDecoration(
                        labelText: context.l10n.linkCourseOptionalLabel,
                        prefixIcon: const Icon(Icons.school_outlined),
                      ),
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
                      onChanged: _isRunning
                          ? null
                          : (value) => setState(() => _courseId = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(
                title: context.l10n.focusHistoryTitle,
                subtitle: context.l10n.focusHistorySubtitle,
              ),
              const SizedBox(height: AppSpacing.md),
              if (studyData.sessions.isEmpty)
                EmptyState(
                  title: context.l10n.emptyFocusHistoryTitle,
                  description: context.l10n.emptyFocusHistoryDescription,
                  icon: Icons.timer_off_rounded,
                )
              else
                ...studyData.sessions.take(5).map(
                      (session) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: SectionCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.success.withValues(alpha: 0.14),
                              child: const Icon(
                                Icons.check_rounded,
                                color: AppColors.success,
                              ),
                            ),
                            title: Text(
                              context.l10n.focusSessionSummary(
                                session.durationMinutes,
                              ),
                            ),
                            subtitle: Text(
                              MaterialLocalizations.of(context).formatShortDate(
                                session.createdAt,
                              ),
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

  Duration get _activeDuration =>
      Duration(minutes: _isBreak ? _breakMinutes : _focusMinutes);

  String _statusLabel(BuildContext context, {required bool isPaused}) {
    if (_isBreak) {
      return context.l10n.focusStatusBreak;
    }
    if (_isRunning) {
      return context.l10n.focusStatusRunning;
    }
    if (isPaused) {
      return context.l10n.focusStatusPaused;
    }
    return context.l10n.focusStatusReady;
  }

  String _computerPrompt(BuildContext context, {required bool isPaused}) {
    final intention = _intentionController.text.trim();
    if (_isBreak) {
      return context.l10n.focusComputerPromptBreak;
    }
    if (_isRunning && intention.isNotEmpty) {
      return context.l10n.focusIntentionResponse(intention);
    }
    if (_isRunning) {
      return context.l10n.focusComputerPromptRunning;
    }
    if (isPaused) {
      return context.l10n.focusComputerPromptPaused;
    }
    return context.l10n.focusComputerPromptReady;
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _remaining = Duration(minutes: _isBreak ? _breakMinutes : _focusMinutes);
    });
    _runTimer();
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resumeTimer() {
    if (_remaining.inSeconds <= 0) {
      return;
    }
    setState(() => _isRunning = true);
    _runTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isBreak = false;
      _remaining = Duration(minutes: _focusMinutes);
    });
  }

  void _runTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remaining.inSeconds <= 1) {
        timer.cancel();

        if (!_isBreak) {
          final studyData = ref.read(studyDataControllerProvider).valueOrNull;
          final selectedCourseId = studyData?.courses.any(
                    (course) => course.id == _courseId,
                  ) ==
                  true
              ? _courseId
              : null;
          await ref.read(studyDataControllerProvider.notifier).addStudySession(
                courseId: selectedCourseId,
                durationMinutes: _focusMinutes,
              );
          final isForeground = WidgetsBinding.instance.lifecycleState ==
              AppLifecycleState.resumed;
          if (mounted && isForeground) {
            context.showSuccessNotification(
              context.l10n.focusSessionCompleteMessage,
            );
          } else {
            await ref.read(reminderServiceProvider).showPomodoroComplete(
                  id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                  title: context.l10n.notificationPreviewTitle,
                  body: context.l10n.focusSessionCompleteMessage,
                );
          }
        }

        if (!mounted) {
          return;
        }

        setState(() {
          _isRunning = false;
          _isBreak = !_isBreak;
          _remaining =
              Duration(minutes: _isBreak ? _breakMinutes : _focusMinutes);
        });
        return;
      }

      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }
}

class _FocusCommandCenter extends StatelessWidget {
  const _FocusCommandCenter({
    required this.minutes,
    required this.seconds,
    required this.modeLabel,
    required this.statusLabel,
    required this.prompt,
    required this.progress,
    required this.isRunning,
    required this.isBreak,
    required this.pulse,
    required this.intentionController,
    required this.onIntentionChanged,
    required this.onReset,
    this.onStart,
    this.onPause,
    this.onResume,
  });

  final String minutes;
  final String seconds;
  final String modeLabel;
  final String statusLabel;
  final String prompt;
  final double progress;
  final bool isRunning;
  final bool isBreak;
  final Animation<double> pulse;
  final TextEditingController intentionController;
  final ValueChanged<String> onIntentionChanged;
  final VoidCallback? onStart;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = isBreak ? AppColors.secondary : scheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.10),
            scheme.surface.withValues(alpha: 0.96),
            AppColors.tertiary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 620;
            final timer = _TimerDial(
              minutes: minutes,
              seconds: seconds,
              modeLabel: modeLabel,
              progress: progress,
              isRunning: isRunning,
              isBreak: isBreak,
              pulse: pulse,
            );
            final panel = _HumanComputerPanel(
              statusLabel: statusLabel,
              prompt: prompt,
              isRunning: isRunning,
              isBreak: isBreak,
              intentionController: intentionController,
              onIntentionChanged: onIntentionChanged,
            );

            return Column(
              children: [
                if (compact)
                  Column(
                    children: [
                      timer,
                      const SizedBox(height: AppSpacing.lg),
                      panel,
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: panel),
                      const SizedBox(width: AppSpacing.xl),
                      timer,
                    ],
                  ),
                const SizedBox(height: AppSpacing.xl),
                _FocusControls(
                  onStart: onStart,
                  onPause: onPause,
                  onResume: onResume,
                  onReset: onReset,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HumanComputerPanel extends StatelessWidget {
  const _HumanComputerPanel({
    required this.statusLabel,
    required this.prompt,
    required this.isRunning,
    required this.isBreak,
    required this.intentionController,
    required this.onIntentionChanged,
  });

  final String statusLabel;
  final String prompt;
  final bool isRunning;
  final bool isBreak;
  final TextEditingController intentionController;
  final ValueChanged<String> onIntentionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = isBreak ? AppColors.secondary : scheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _ConnectionChip(
              icon: Icons.person_rounded,
              label: context.l10n.focusHumanName,
              color: AppColors.tertiary,
            ),
            _ConnectionChip(
              icon: Icons.sync_alt_rounded,
              label: context.l10n.focusConnectionLabel,
              color: accent,
            ),
            _ConnectionChip(
              icon: Icons.computer_rounded,
              label: context.l10n.focusComputerName,
              color: AppColors.secondary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          statusLabel,
          style: theme.textTheme.headlineSmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          prompt,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: intentionController,
          onChanged: onIntentionChanged,
          enabled: !isRunning,
          minLines: 1,
          maxLines: 2,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: context.l10n.focusIntentionLabel,
            hintText: context.l10n.focusIntentionHint,
            prefixIcon: const Icon(Icons.edit_note_rounded),
          ),
        ),
      ],
    );
  }
}

class _TimerDial extends StatelessWidget {
  const _TimerDial({
    required this.minutes,
    required this.seconds,
    required this.modeLabel,
    required this.progress,
    required this.isRunning,
    required this.isBreak,
    required this.pulse,
  });

  final String minutes;
  final String seconds;
  final String modeLabel;
  final double progress;
  final bool isRunning;
  final bool isBreak;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = isBreak ? AppColors.secondary : scheme.primary;

    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) {
        final pulseValue = isRunning ? pulse.value : 0.0;
        return SizedBox(
          width: 238,
          height: 238,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size.square(238),
                painter: _FocusDialPainter(
                  progress: progress,
                  accent: accent,
                  track: scheme.outlineVariant.withValues(alpha: 0.24),
                  pulse: pulseValue,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isBreak
                        ? Icons.self_improvement_rounded
                        : Icons.center_focus_strong_rounded,
                    color: accent,
                    size: 28,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$minutes:$seconds',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    modeLabel,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FocusControls extends StatelessWidget {
  const _FocusControls({
    required this.onReset,
    this.onStart,
    this.onPause,
    this.onResume,
  });

  final VoidCallback? onStart;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.center,
      children: [
        FilledButton.icon(
          onPressed: onStart,
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(context.l10n.startAction),
        ),
        FilledButton.tonalIcon(
          onPressed: onPause,
          icon: const Icon(Icons.pause_rounded),
          label: Text(context.l10n.pauseAction),
        ),
        OutlinedButton.icon(
          onPressed: onResume,
          icon: const Icon(Icons.replay_rounded),
          label: Text(context.l10n.resumeAction),
        ),
        OutlinedButton.icon(
          onPressed: onReset,
          icon: const Icon(Icons.restart_alt_rounded),
          label: Text(context.l10n.resetAction),
        ),
      ],
    );
  }
}

class _DurationSlider extends StatelessWidget {
  const _DurationSlider({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.enabled,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: scheme.primary, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: value.round().toString(),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}

class _FocusStatusBadge extends StatelessWidget {
  const _FocusStatusBadge({
    required this.label,
    required this.active,
    required this.isBreak,
  });

  final String label;
  final bool active;
  final bool isBreak;

  @override
  Widget build(BuildContext context) {
    final color = isBreak
        ? AppColors.secondary
        : active
            ? AppColors.success
            : Theme.of(context).colorScheme.primary;

    return StatusPill(label: label, color: color);
  }
}

class _ConnectionChip extends StatelessWidget {
  const _ConnectionChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 12, 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
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

class _FocusDialPainter extends CustomPainter {
  const _FocusDialPainter({
    required this.progress,
    required this.accent,
    required this.track,
    required this.pulse,
  });

  final double progress;
  final Color accent;
  final Color track;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final strokeWidth = size.width * 0.075;
    final radius = (size.width - strokeWidth - 20) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final glowPaint = Paint()
      ..color = accent.withValues(alpha: 0.08 + (pulse * 0.10))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18 + (pulse * 12);

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: (math.pi * 2) - (math.pi / 2),
        colors: [
          accent.withValues(alpha: 0.34),
          accent.withValues(alpha: 0.82),
          accent,
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius + 6, glowPaint);
    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0, 1).toDouble(),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FocusDialPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accent != accent ||
        oldDelegate.track != track ||
        oldDelegate.pulse != pulse;
  }
}
