import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/extensions/build_context_x.dart';
import '../../shared/models/app_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    required this.child,
    super.key,
    this.padding,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.appBar,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [
                        Color(0xFF06101F),
                        Color(0xFF0C162A),
                        Color(0xFF132546),
                      ]
                    : const [
                        Color(0xFFF9FBFF),
                        Color(0xFFF0F4FF),
                        Color(0xFFE7F1FF),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        PositionedDirectional(
          top: -40,
          start: -20,
          child: _AmbientOrb(
            color: (isDark ? AppColors.secondary : AppColors.seed)
                .withValues(alpha: 0.16),
            size: 160,
          ),
        ),
        PositionedDirectional(
          top: 180,
          end: -30,
          child: _AmbientOrb(
            color: AppColors.tertiary.withValues(alpha: 0.12),
            size: 180,
          ),
        ),
        PositionedDirectional(
          bottom: 90,
          start: 24,
          child: _AmbientOrb(
            color: AppColors.success.withValues(alpha: 0.1),
            size: 120,
          ),
        ),
        PositionedDirectional(
          top: 260,
          start: 110,
          child: _AmbientOrb(
            color: AppColors.seed.withValues(alpha: isDark ? 0.08 : 0.06),
            size: 110,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appBar,
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: bottomNavigationBar,
          body: SafeArea(
            child: Padding(
              padding: padding ??
                  const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

enum _MainNavTab {
  home,
  tasks,
  calendar,
  focus,
  profile,
}

class _MainNavItemData {
  const _MainNavItemData({
    required this.tab,
    required this.label,
    required this.shortLabel,
    required this.icon,
    required this.selectedIcon,
    required this.accent,
  });

  final _MainNavTab tab;
  final String label;
  final String shortLabel;
  final IconData icon;
  final IconData selectedIcon;
  final Color accent;
}

String _shortNavLabel(BuildContext context, _MainNavTab tab) {
  final code = Localizations.localeOf(context).languageCode;

  if (code == 'tr') {
    return switch (tab) {
      _MainNavTab.home => 'Ana',
      _MainNavTab.tasks => 'Gorev',
      _MainNavTab.calendar => 'Takvim',
      _MainNavTab.focus => 'Odak',
      _MainNavTab.profile => 'Profil',
    };
  }

  if (code == 'ar') {
    return switch (tab) {
      _MainNavTab.home => 'الرئيسية',
      _MainNavTab.tasks => 'المهام',
      _MainNavTab.calendar => 'التقويم',
      _MainNavTab.focus => 'التركيز',
      _MainNavTab.profile => 'الملف',
    };
  }

  return switch (tab) {
    _MainNavTab.home => 'Home',
    _MainNavTab.tasks => 'Tasks',
    _MainNavTab.calendar => 'Plan',
    _MainNavTab.focus => 'Focus',
    _MainNavTab.profile => 'Profile',
  };
}

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final navItems = [
      _MainNavItemData(
        tab: _MainNavTab.home,
        label: l10n.homeTab,
        shortLabel: _shortNavLabel(context, _MainNavTab.home),
        icon: Icons.dashboard_customize_outlined,
        selectedIcon: Icons.dashboard_customize_rounded,
        accent: AppColors.seed,
      ),
      _MainNavItemData(
        tab: _MainNavTab.tasks,
        label: l10n.tasksTab,
        shortLabel: _shortNavLabel(context, _MainNavTab.tasks),
        icon: Icons.task_alt_outlined,
        selectedIcon: Icons.task_alt_rounded,
        accent: AppColors.secondary,
      ),
      _MainNavItemData(
        tab: _MainNavTab.calendar,
        label: l10n.calendarTab,
        shortLabel: _shortNavLabel(context, _MainNavTab.calendar),
        icon: Icons.event_note_outlined,
        selectedIcon: Icons.event_note_rounded,
        accent: AppColors.tertiary,
      ),
      _MainNavItemData(
        tab: _MainNavTab.focus,
        label: l10n.focusTab,
        shortLabel: _shortNavLabel(context, _MainNavTab.focus),
        icon: Icons.timer_outlined,
        selectedIcon: Icons.timer_rounded,
        accent: AppColors.warning,
      ),
      _MainNavItemData(
        tab: _MainNavTab.profile,
        label: l10n.profileTab,
        shortLabel: _shortNavLabel(context, _MainNavTab.profile),
        icon: Icons.account_circle_outlined,
        selectedIcon: Icons.account_circle_rounded,
        accent: AppColors.success,
      ),
    ];

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: Theme.of(context).brightness == Brightness.dark
                    ? const [
                        Color(0xFF06101F),
                        Color(0xFF0C162A),
                        Color(0xFF132546),
                      ]
                    : const [
                        Color(0xFFF9FBFF),
                        Color(0xFFF0F4FF),
                        Color(0xFFE7F1FF),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        PositionedDirectional(
          top: -40,
          start: -20,
          child: _AmbientOrb(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
            size: 160,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: navigationShell,
          bottomNavigationBar: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              bottomInset > AppSpacing.sm ? bottomInset : AppSpacing.md,
            ),
            child: _StudyFlowBottomBar(
              currentIndex: navigationShell.currentIndex,
              items: navItems,
              onSelected: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _StudyFlowBottomBar extends StatelessWidget {
  const _StudyFlowBottomBar({
    required this.currentIndex,
    required this.items,
    required this.onSelected,
  });

  final int currentIndex;
  final List<_MainNavItemData> items;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 380;
        final useShortLabel = constraints.maxWidth < 430;
        final horizontalPadding = compact ? AppSpacing.xs : AppSpacing.sm;
        final verticalPadding = compact ? AppSpacing.xs : AppSpacing.sm;

        return ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.surface.withValues(alpha: 0.92),
                    scheme.surfaceContainerHigh.withValues(alpha: 0.88),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.34),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 32,
                    offset: const Offset(0, 18),
                  ),
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Row(
                  textDirection: TextDirection.ltr,
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 2 : 4,
                        ),
                        child: _StudyFlowBottomBarItem(
                          data: item,
                          selected: index == currentIndex,
                          useShortLabel: useShortLabel,
                          compact: compact,
                          onTap: () => onSelected(index),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StudyFlowBottomBarItem extends StatelessWidget {
  const _StudyFlowBottomBarItem({
    required this.data,
    required this.selected,
    required this.useShortLabel,
    required this.compact,
    required this.onTap,
  });

  final _MainNavItemData data;
  final bool selected;
  final bool useShortLabel;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = useShortLabel ? data.shortLabel : data.label;
    final iconSize = compact ? 18.0 : 20.0;
    final bubbleSize = compact ? 38.0 : 42.0;
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          color: selected ? data.accent : scheme.onSurfaceVariant,
          letterSpacing: 0.1,
        );

    return Semantics(
      button: true,
      selected: selected,
      label: data.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 4 : 6,
              vertical: compact ? 8 : 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: selected
                  ? LinearGradient(
                      colors: [
                        data.accent.withValues(alpha: 0.24),
                        data.accent.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : null,
              border: Border.all(
                color: selected
                    ? data.accent.withValues(alpha: 0.3)
                    : Colors.transparent,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: data.accent.withValues(alpha: 0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : const [],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  width: bubbleSize,
                  height: bubbleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: selected
                        ? LinearGradient(
                            colors: [
                              data.accent,
                              data.accent.withValues(alpha: 0.72),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: selected
                        ? null
                        : scheme.surface.withValues(alpha: 0.42),
                    border: Border.all(
                      color: selected
                          ? data.accent.withValues(alpha: 0.18)
                          : scheme.outlineVariant.withValues(alpha: 0.26),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (selected ? data.accent : scheme.shadow)
                            .withValues(alpha: selected ? 0.24 : 0.08),
                        blurRadius: selected ? 18 : 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    selected ? data.selectedIcon : data.icon,
                    size: iconSize,
                    color:
                        selected ? scheme.onPrimary : scheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: compact ? 5 : 6),
                SizedBox(
                  height: compact ? 14 : 16,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: labelStyle,
                    ),
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

class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.98),
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.38),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha:
                  Theme.of(context).brightness == Brightness.dark ? 0.22 : 0.07,
            ),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class HeroMetricCard extends StatelessWidget {
  const HeroMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    super.key,
    this.accent,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = accent ?? scheme.primary;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withValues(alpha: 0.16),
                child: Icon(icon, color: color),
              ),
              const Spacer(),
              Icon(Icons.north_east_rounded, color: color),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class GradientBanner extends StatelessWidget {
  const GradientBanner({
    required this.child,
    super.key,
    this.colors,
  });

  final Widget child;
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: colors ??
              [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).colorScheme.tertiary,
              ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.28),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: child,
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    super.key,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        if (compact && action != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              action!,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            if (action != null) action!,
          ],
        );
      },
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
    this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SectionCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: (color ?? scheme.primary).withValues(alpha: 0.14),
            child: Icon(icon, color: color ?? scheme.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    required this.description,
    super.key,
    this.icon = Icons.inbox_rounded,
    this.action,
  });

  final String title;
  final String description;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SectionCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: scheme.primaryContainer,
            child: Icon(icon, size: 28, color: scheme.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.md),
            action!,
          ],
        ],
      ),
    );
  }
}

class ErrorStateCard extends StatelessWidget {
  const ErrorStateCard({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: context.l10n.errorStateTitle,
      description: message,
      icon: Icons.error_outline_rounded,
      action: FilledButton(
        onPressed: onRetry,
        child: Text(context.l10n.tryAgain),
      ),
    );
  }
}

class LoadingColumn extends StatelessWidget {
  const LoadingColumn({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: EdgeInsets.only(
              bottom: index == itemCount - 1 ? 0 : AppSpacing.md),
          child: const SectionCard(
            child: SizedBox(height: 120),
          ),
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  const DetailRow({
    required this.label,
    required this.value,
    super.key,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 18, color: scheme.primary),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Expanded(
                          child: Text(
                            label,
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: scheme.primary),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Expanded(
                      child: Text(
                        label,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        value,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    required this.label,
    required this.color,
    super.key,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}

class SearchTextField extends StatelessWidget {
  const SearchTextField({
    required this.controller,
    required this.hintText,
    super.key,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
      ),
    );
  }
}

class CourseAvatar extends StatelessWidget {
  const CourseAvatar({
    required this.course,
    super.key,
    this.size = 44,
  });

  final CourseModel course;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Color(course.color).withValues(alpha: 0.15),
      child: Text(
        (course.title.isEmpty ? '?' : course.title.substring(0, 1))
            .toUpperCase(),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Color(course.color),
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: title,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(icon, color: scheme.primary),
                ),
                const Spacer(),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RevealOnBuild extends StatefulWidget {
  const RevealOnBuild({
    required this.child,
    super.key,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.04),
  });

  final Widget child;
  final Duration delay;
  final Offset offset;

  @override
  State<RevealOnBuild> createState() => _RevealOnBuildState();
}

class _RevealOnBuildState extends State<RevealOnBuild> {
  var _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) {
      return widget.child;
    }

    return AnimatedSlide(
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      offset: _visible ? Offset.zero : widget.offset,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        opacity: _visible ? 1 : 0,
        child: widget.child,
      ),
    );
  }
}

class AnimatedMetricValue extends StatelessWidget {
  const AnimatedMetricValue({
    required this.value,
    super.key,
    this.decimals = 0,
    this.suffix = '',
    this.style,
  });

  final double value;
  final int decimals;
  final String suffix;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 950),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        final display = decimals == 0
            ? animatedValue.round().toString()
            : animatedValue.toStringAsFixed(decimals);
        return Text('$display$suffix', style: style);
      },
    );
  }
}

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    required this.progress,
    required this.label,
    required this.valueText,
    super.key,
    this.accent,
    this.size = 132,
  });

  final double progress;
  final String label;
  final String valueText;
  final Color? accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = accent ?? scheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween:
                Tween<double>(begin: 0, end: progress.clamp(0, 1).toDouble()),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, _) {
              return CustomPaint(
                size: Size.square(size),
                painter: _ProgressRingPainter(
                  progress: animatedProgress,
                  accent: color,
                  track: scheme.outlineVariant.withValues(alpha: 0.2),
                ),
              );
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                valueText,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WeekSparkBars extends StatelessWidget {
  const WeekSparkBars({
    required this.values,
    super.key,
    this.accent,
    this.labels,
  });

  final List<double> values;
  final Color? accent;
  final List<String>? labels;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = accent ?? scheme.primary;
    final maxValue =
        values.isEmpty ? 1.0 : math.max(values.reduce(math.max), 1.0);
    final resolvedLabels = labels ?? const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(values.length, (index) {
        final value = values[index];
        final ratio = (value / maxValue).clamp(0.14, 1.0).toDouble();
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == values.length - 1 ? 0 : 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 360 + (index * 70)),
                  curve: Curves.easeOutCubic,
                  height: 18 + (82 * ratio),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        color.withValues(alpha: 0.92),
                        color.withValues(alpha: 0.26),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  index < resolvedLabels.length ? resolvedLabels[index] : '',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

Color priorityColor(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.low:
      return AppColors.success;
    case TaskPriority.medium:
      return AppColors.secondary;
    case TaskPriority.high:
      return AppColors.tertiary;
    case TaskPriority.urgent:
      return AppColors.danger;
  }
}

Color statusColor(TaskStatus status) {
  switch (status) {
    case TaskStatus.pending:
      return AppColors.warning;
    case TaskStatus.inProgress:
      return AppColors.secondary;
    case TaskStatus.completed:
      return AppColors.success;
  }
}

class _AmbientOrb extends StatelessWidget {
  const _AmbientOrb({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter({
    required this.progress,
    required this.accent,
    required this.track,
  });

  final double progress;
  final Color accent;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.11;
    final center = size.center(Offset.zero);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

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
          accent.withValues(alpha: 0.22),
          accent.withValues(alpha: 0.78),
          accent,
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

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
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accent != accent ||
        oldDelegate.track != track;
  }
}
