import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

export 'branding/app_logo.dart';

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
    final overlayStyle = isDark
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.light,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
          );

    return _AppBackdrop(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.translucent,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
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
        ),
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    super.key,
    this.subtitle,
    this.trailing,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final stackTrailing = trailing != null && constraints.maxWidth < 430;

        final headerRow = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            leading ??
                IconButton.filledTonal(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: titleBlock),
            if (!stackTrailing && trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ],
          ],
        );

        if (!stackTrailing) {
          return headerRow;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            headerRow,
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: trailing!,
            ),
          ],
        );
      },
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

    return _AppBackdrop(
      child: Scaffold(
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
        final compact = constraints.maxWidth < 390;
        final useShortLabel = constraints.maxWidth < 430;

        return ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: compact ? 76 : 82,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? AppSpacing.xs : AppSpacing.sm,
                    vertical: compact ? AppSpacing.xs : AppSpacing.sm,
                  ),
                  child: Row(
                    textDirection: TextDirection.ltr,
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
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
    final bubbleSize = compact ? 36.0 : 40.0;
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
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 4 : 6,
              vertical: compact ? 6 : 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: selected ? data.accent.withValues(alpha: 0.10) : null,
              border: Border.all(
                color: selected
                    ? data.accent.withValues(alpha: 0.24)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  width: bubbleSize,
                  height: bubbleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? data.accent.withValues(alpha: 0.16)
                        : scheme.surface.withValues(alpha: 0.52),
                    border: Border.all(
                      color: selected
                          ? data.accent.withValues(alpha: 0.24)
                          : scheme.outlineVariant.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Icon(
                    selected ? data.selectedIcon : data.icon,
                    size: iconSize,
                    color: selected ? data.accent : scheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: compact ? 5 : 6),
                SizedBox(
                  height: compact ? 16 : 18,
                  child: Center(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha:
                  Theme.of(context).brightness == Brightness.dark ? 0.16 : 0.05,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
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

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
    this.caption,
    this.accent,
    this.onTap,
    this.minHeight = 150,
  });

  final String label;
  final String value;
  final String? caption;
  final IconData icon;
  final Color? accent;
  final VoidCallback? onTap;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = accent ?? scheme.primary;

    Widget child = SectionCard(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: color.withValues(alpha: 0.14),
                  child: Icon(icon, color: color),
                ),
                const Spacer(),
                if (onTap != null)
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 18,
                    color: color.withValues(alpha: 0.82),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (caption != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                caption!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );

    if (onTap != null) {
      child = InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: child,
      );
    }

    return child;
  }
}

class AdaptiveCardGrid extends StatelessWidget {
  const AdaptiveCardGrid({
    required this.children,
    super.key,
    this.minItemWidth = 240,
    this.maxColumns = 2,
    this.spacing = AppSpacing.md,
  });

  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final rawColumns =
            ((availableWidth + spacing) / (minItemWidth + spacing)).floor();
        final columns = math.max(1, math.min(maxColumns, rawColumns));
        final itemWidth =
            (availableWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(
                width: itemWidth,
                child: child,
              ),
          ],
        );
      },
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
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: colors ??
              [
                scheme.primary,
                Color.alphaBlend(
                  scheme.secondary.withValues(alpha: 0.28),
                  scheme.primaryContainer,
                ),
              ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
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
        final compact = constraints.maxWidth < 480;
        if (compact && action != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
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
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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
    this.animationAsset,
    this.animationRepeat = false,
    this.animationSize = 96,
    this.action,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? animationAsset;
  final bool animationRepeat;
  final double animationSize;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final header = animationAsset == null
        ? CircleAvatar(
            radius: 30,
            backgroundColor: scheme.primaryContainer,
            child: Icon(icon, size: 28, color: scheme.primary),
          )
        : SizedBox(
            width: animationSize,
            height: animationSize,
            child: Lottie.asset(
              animationAsset!,
              repeat: animationRepeat,
              fit: BoxFit.contain,
            ),
          );

    return SectionCard(
      child: Column(
        children: [
          header,
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
      animationAsset: 'assets/animations/Error animation.json',
      animationRepeat: true,
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
    return SingleChildScrollView(
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: EdgeInsets.only(
              bottom: index == itemCount - 1 ? 0 : AppSpacing.md,
            ),
            child: const SectionCard(
              child: SizedBox(height: 120),
            ),
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
      textInputAction: TextInputAction.search,
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
            color: scheme.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.34),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 148),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: scheme.primaryContainer,
                    child: Icon(icon, color: scheme.primary),
                  ),
                  const SizedBox(height: AppSpacing.lg),
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
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      offset: _visible ? Offset.zero : widget.offset,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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

class _AppBackdrop extends StatelessWidget {
  const _AppBackdrop({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRect(
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? const [
                          Color(0xFF0B1322),
                          Color(0xFF10192B),
                          Color(0xFF141F32),
                        ]
                      : const [
                          Color(0xFFF7F9FC),
                          Color(0xFFF2F5FA),
                          Color(0xFFECEFF5),
                        ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: -56,
            start: -32,
            child: _AmbientOrb(
              color: (isDark ? AppColors.secondary : AppColors.seed)
                  .withValues(alpha: 0.10),
              size: 172,
            ),
          ),
          PositionedDirectional(
            top: 140,
            end: -48,
            child: _AmbientOrb(
              color: AppColors.tertiary.withValues(alpha: isDark ? 0.06 : 0.08),
              size: 176,
            ),
          ),
          PositionedDirectional(
            bottom: 80,
            start: 18,
            child: _AmbientOrb(
              color: AppColors.success.withValues(alpha: isDark ? 0.05 : 0.07),
              size: 120,
            ),
          ),
          child,
        ],
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
