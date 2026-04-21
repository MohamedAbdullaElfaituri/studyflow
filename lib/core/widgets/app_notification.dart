import 'dart:async';
import 'dart:ui';

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
  var _visible = true;
  var _dismissed = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, _dismiss);
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
      const Duration(milliseconds: 140),
      widget.onDismissed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTop = widget.position == AppNotificationPosition.top;
    final verticalOffset = isTop
        ? mediaQuery.padding.top + AppSpacing.xs
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
              constraints: const BoxConstraints(maxWidth: 560),
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOutCubic,
                offset:
                    _visible ? Offset.zero : Offset(0, isTop ? -0.16 : 0.16),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 120),
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
    this.title,
  });

  final String message;
  final String? title;
  final AppNotificationTone tone;
  final VoidCallback onClose;
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
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
    final surfaceColor = colorScheme.surface.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.88 : 0.93,
    );
    final cardColor = Color.alphaBlend(
      accent.withValues(alpha: 0.08),
      surfaceColor,
    );
    final highlightColor = Color.alphaBlend(
      accent.withValues(alpha: 0.05),
      cardColor,
    );
    final iconBackground = accent.withValues(alpha: 0.13);

    return Semantics(
      container: true,
      liveRegion: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cardColor, highlightColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: accent.withValues(alpha: 0.20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 26,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: accent.withValues(alpha: 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.84),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                ),
                Padding(
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
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: iconBackground,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(icon, color: accent, size: 22),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null && title!.trim().isNotEmpty) ...[
                              Text(
                                title!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            Text(
                              message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                                height: 1.35,
                                fontWeight: FontWeight.w500,
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
                        splashRadius: 18,
                        icon: Icon(
                          Icons.close_rounded,
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
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
    );
  }
}
