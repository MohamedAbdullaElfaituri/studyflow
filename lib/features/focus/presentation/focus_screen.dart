import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class _FocusScreenState extends ConsumerState<FocusScreen> {
  Timer? _timer;
  int _focusMinutes = 25;
  int _breakMinutes = 5;
  Duration _remaining = const Duration(minutes: 25);
  bool _isRunning = false;
  bool _isBreak = false;
  String? _courseId;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(studyDataControllerProvider);
    final minutes = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return AppPage(
      child: data.when(
        loading: () => const LoadingColumn(itemCount: 3),
        error: (error, _) => ErrorStateCard(
          message: context.resolveError(error),
          onRetry: () => ref.read(studyDataControllerProvider.notifier).refresh(),
        ),
        data: (studyData) => ListView(
          children: [
            SectionHeader(
              title: context.l10n.focusTitle,
              subtitle: context.l10n.focusSubtitle,
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionCard(
              child: Column(
                children: [
                  Text(
                    _isBreak
                        ? context.l10n.breakModeLabel
                        : context.l10n.focusModeLabel,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Center(
                      child: Text(
                        '$minutes:$seconds',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    alignment: WrapAlignment.center,
                    children: [
                      FilledButton(
                        onPressed: _isRunning ? null : _startTimer,
                        child: Text(context.l10n.startAction),
                      ),
                      FilledButton.tonal(
                        onPressed: _isRunning ? _pauseTimer : null,
                        child: Text(context.l10n.pauseAction),
                      ),
                      OutlinedButton(
                        onPressed: !_isRunning && _remaining.inSeconds > 0
                            ? _resumeTimer
                            : null,
                        child: Text(context.l10n.resumeAction),
                      ),
                      OutlinedButton(
                        onPressed: _resetTimer,
                        child: Text(context.l10n.resetAction),
                      ),
                    ],
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
                    context.l10n.customizeSessionTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(context.l10n.focusDurationLabel(_focusMinutes)),
                  Slider(
                    value: _focusMinutes.toDouble(),
                    min: 15,
                    max: 90,
                    divisions: 15,
                    onChanged: _isRunning
                        ? null
                        : (value) {
                            setState(() {
                              _focusMinutes = value.round();
                              if (!_isBreak) {
                                _remaining = Duration(minutes: _focusMinutes);
                              }
                            });
                          },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(context.l10n.breakDurationLabel(_breakMinutes)),
                  Slider(
                    value: _breakMinutes.toDouble(),
                    min: 5,
                    max: 30,
                    divisions: 5,
                    onChanged: _isRunning
                        ? null
                        : (value) => setState(() => _breakMinutes = value.round()),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String?>(
                    initialValue: _courseId,
                    decoration: InputDecoration(
                      labelText: context.l10n.linkCourseOptionalLabel,
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
                    onChanged: (value) => setState(() => _courseId = value),
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
                    child: Text(
                      context.l10n.focusSessionSummary(session.durationMinutes),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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
          await ref.read(studyDataControllerProvider.notifier).addStudySession(
                courseId: _courseId,
                durationMinutes: _focusMinutes,
              );
          if (mounted) {
            context.showAppSnackBar(context.l10n.focusSessionCompleteMessage);
          }
        }

        if (!mounted) {
          return;
        }

        setState(() {
          _isRunning = false;
          _isBreak = !_isBreak;
          _remaining = Duration(minutes: _isBreak ? _breakMinutes : _focusMinutes);
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
