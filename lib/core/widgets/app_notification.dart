import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum AppNotificationTone { success, error, info, warning }

enum AppNotificationPosition { top, bottom }

class AppNotificationController {
  static OverlayEntry? _activeEntry;

  static void show({
    required BuildContext context,
    required String message,
    required AppNotificationTone tone,
    required AppNotificationPosition position,
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }

    hide();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) => _AppNotificationOverlay(
        message: message,
        title: title,
        tone: tone,
        position: position,
        duration: duration,
        onDismissed: () {
          if (identical(_activeEntry, entry)) {
            _activeEntry = null;
          }
          if (entry.mounted) {
            entry.remove();
          }
        },
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }

  static void hide() {
    if (_activeEntry?.mounted ?? false) {
      _activeEntry?.remove();
    }
    _activeEntry = null;
  }
}

class _AppNotificationOverlay extends StatefulWidget {
  const _AppNotificationOverlay({
    required this.message,
    required this.tone,
    required this.position,
    required this.duration,
    required this.onDismissed,
    this.title,
  });

  final String message;
  final String? title;
  final AppNotificationTone tone;
  final AppNotificationPosition position;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_AppNotificationOverlay> createState() =>
      _AppNotificationOverlayState();
}

class _AppNotificationOverlayState extends State<_AppNotificationOverlay> {
  Timer? _timer;
  var _visible = false;
  var _dismissed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() => _visible = true);
      _timer = Timer(widget.duration, _dismiss);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _dismiss() {
    if (!mounted || _dismissed) {
      return;
    }
    _dismissed = true;
    _timer?.cancel();
    setState(() => _visible = false);
    Timer(
      const Duration(milliseconds: 240),
      widget.onDismissed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);
    final isTop = widget.position == AppNotificationPosition.top;
    final verticalOffset = isTop
        ? mediaQuery.padding.top + AppSpacing.md
        : mediaQuery.padding.bottom + mediaQuery.viewInsets.bottom + 88;

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Container(color: Colors.transparent),
          ),
        ),
        PositionedDirectional(
          top: isTop ? verticalOffset : null,
          bottom: isTop ? null : verticalOffset,
          start: AppSpacing.md,
          end: AppSpacing.md,
          child: Align(
            alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                offset:
                    _visible ? Offset.zero : Offset(0, isTop ? -0.18 : 0.18),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  opacity: _visible ? 1 : 0,
                  child: Material(
                    color: Colors.transparent,
                    child: _AppNotificationCard(
                      message: widget.message,
                      title: widget.title,
                      tone: widget.tone,
                      onClose: _dismiss,
                      closeLabel:
                          MaterialLocalizations.of(context).closeButtonTooltip,
                      textTheme: theme.textTheme,
                      colorScheme: theme.colorScheme,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AppNotificationCard extends StatelessWidget {
  const _AppNotificationCard({
    required this.message,
    required this.tone,
    required this.onClose,
    required this.closeLabel,
    required this.textTheme,
    required this.colorScheme,
    this.title,
  });

  final String message;
  final String? title;
  final AppNotificationTone tone;
  final VoidCallback onClose;
  final String closeLabel;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final accent = switch (tone) {
      AppNotificationTone.success => AppColors.success,
      AppNotificationTone.error => colorScheme.error,
      AppNotificationTone.info => colorScheme.primary,
      AppNotificationTone.warning => AppColors.warning,
    };
    final icon = switch (tone) {
      AppNotificationTone.success => Icons.check_circle_rounded,
      AppNotificationTone.error => Icons.error_rounded,
      AppNotificationTone.info => Icons.info_rounded,
      AppNotificationTone.warning => Icons.warning_amber_rounded,
    };
    final cardColor = Color.alphaBlend(
      accent.withValues(alpha: 0.10),
      colorScheme.surface.withValues(alpha: 0.98),
    );
    final iconBackground = accent.withValues(alpha: 0.14);

    return Semantics(
      container: true,
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: accent.withValues(alpha: 0.22),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: accent.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accent, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null && title!.trim().isNotEmpty) ...[
                      Text(
                        title!,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      message,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                onPressed: onClose,
                tooltip: closeLabel,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.close_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
