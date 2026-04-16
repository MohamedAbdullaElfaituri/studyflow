// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/extensions/build_context_x.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/providers/app_providers.dart';
import '../../auth/presentation/auth_screens.dart';
import '../../settings/presentation/settings_screen.dart';
import 'profile_copy.dart';

part 'profile_edit_part.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const routePath = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final data = ref.watch(studyDataControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppPage(
      child: data.when(
        loading: () => const LoadingColumn(itemCount: 4),
        error: (error, _) => ErrorStateCard(
          message: context.resolveError(error),
          onRetry: () =>
              ref.read(studyDataControllerProvider.notifier).refresh(),
        ),
        data: (studyData) {
          final currentUser = user;
          if (currentUser == null) {
            return const SizedBox.shrink();
          }

          final copy = ProfileCopy.of(context);
          final isCompact = MediaQuery.sizeOf(context).width < 390;
          final screenWidth = MediaQuery.sizeOf(context).width;
          final completedRate = studyData.tasks.isEmpty
              ? 0.0
              : studyData.completedTasks.length / studyData.tasks.length;
          final weeklyProgress = studyData.goals.weeklyTargetMinutes == 0
              ? 0.0
              : studyData.weeklyStudyMinutes /
                  studyData.goals.weeklyTargetMinutes;
          final profileDepth = _profileDepth(currentUser);

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xl),
            children: [
              // Beautiful Simple Header Profile
              RevealOnBuild(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Decorative background ring for avatar
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                        ),
                        Hero(
                          tag: 'profile_avatar',
                          child: _ProfileAvatar(user: currentUser, radius: 56),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      currentUser.fullName.isEmpty
                          ? copy.fallbackUserName
                          : currentUser.fullName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '@${currentUser.username ?? currentUser.email.split('@').first}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    if (currentUser.bio.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          currentUser.bio,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Quick Stats (3 cards)
              Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    SizedBox(
                      width: (screenWidth - AppSpacing.lg * 2 - AppSpacing.md * 2) / 3,
                      child: RevealOnBuild(
                        delay: const Duration(milliseconds: 100),
                        child: _StatCardSimple(
                          icon: Icons.local_fire_department_rounded,
                          label: copy.consistency,
                          value: '${studyData.streakCount}',
                          unit: 'd',
                          isDark: isDark,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: (screenWidth - AppSpacing.lg * 2 - AppSpacing.md * 2) / 3,
                      child: RevealOnBuild(
                        delay: const Duration(milliseconds: 150),
                        child: _StatCardSimple(
                          icon: Icons.task_alt_rounded,
                          lottieAsset: 'assets/animations/Success.json',
                          label: copy.completedTasks,
                          value: '${studyData.completedTasks.length}',
                          isDark: isDark,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: (screenWidth - AppSpacing.lg * 2 - AppSpacing.md * 2) / 3,
                      child: RevealOnBuild(
                        delay: const Duration(milliseconds: 200),
                        child: _StatCardSimple(
                          icon: Icons.star_rounded,
                          label: copy.xpLevel,
                          value: '${studyData.level}',
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Performance Metrics (2 rows)
              isCompact
                  ? Column(
                      children: [
                        _MetricCardLarge(
                          icon: Icons.trending_up_rounded,
                          label: copy.weeklyFocus,
                          value: '${studyData.weeklyStudyMinutes}m',
                          percentage:
                              '${(weeklyProgress.clamp(0, 1) * 100).round()}%',
                          isDark: isDark,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _MetricCardLarge(
                          icon: Icons.person_search_rounded,
                          label: copy.profileDepth,
                          value: '${profileDepth.toStringAsFixed(0)}%',
                          isDark: isDark,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _MetricCardLarge(
                            icon: Icons.trending_up_rounded,
                            label: copy.weeklyFocus,
                            value: '${studyData.weeklyStudyMinutes}m',
                            percentage:
                                '${(weeklyProgress.clamp(0, 1) * 100).round()}%',
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _MetricCardLarge(
                            icon: Icons.person_search_rounded,
                            label: copy.profileDepth,
                            value: '${profileDepth.toStringAsFixed(0)}%',
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: AppSpacing.lg),

              // Additional metrics
              Row(
                children: [
                  Expanded(
                    child: _MetricCardCompact(
                      icon: Icons.done_all_rounded,
                      label: copy.taskCompletion,
                      value: '${(completedRate * 100).toStringAsFixed(0)}%',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _MetricCardCompact(
                      icon: Icons.repeat_rounded,
                      label: copy.habitsLocked,
                      value: '${studyData.completedHabits.length}',
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Identity Details Card
              RevealOnBuild(
                delay: const Duration(milliseconds: 300),
                child: _InfoCard(
                  title: copy.identityDetails,
                  isDark: isDark,
                  children: [
                    _InfoRow(
                      label: copy.email,
                      value: currentUser.email,
                    ),
                    _InfoRow(
                      label: copy.username,
                      value: '@${_username(currentUser)}',
                    ),
                    _InfoRow(
                      label: copy.university,
                      value: currentUser.university ?? copy.notAddedYet,
                    ),
                    _InfoRow(
                      label: copy.department,
                      value: currentUser.department ?? copy.notAddedYet,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Actions
              RevealOnBuild(
                delay: const Duration(milliseconds: 350),
                child: _ActionsCard(
                  isDark: isDark,
                  onEditProfile: () =>
                      context.push(ProfileEditScreen.routePath),
                  onSettings: () =>
                      context.push(SettingsScreen.routePath),
                  onLogOut: () async {
                    await ref
                        .read(authControllerProvider.notifier)
                        .signOut();
                    if (context.mounted) {
                      context.go(LoginScreen.routePath);
                    }
                  },
                  copy: copy,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }

  static double _profileDepth(AppUserModel user) {
    double depth = 0;
    if (user.fullName.isNotEmpty) depth += 25;
    if (user.bio.isNotEmpty) depth += 25;
    if (user.university != null && user.university!.isNotEmpty) depth += 25;
    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) depth += 25;
    return depth;
  }

  static List<double> _weekSeries(List<StudySessionModel> sessions) {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return sessions
          .where((s) =>
              s.startTime.year == date.year &&
              s.startTime.month == date.month &&
              s.startTime.day == date.day)
          .fold<int>(
              0,
              (prev, session) =>
                  prev +
                  session.endTime.difference(session.startTime).inMinutes);
    });
    final max = days.isEmpty ? 1.0 : days.reduce((a, b) => a > b ? a : b);
    return days.map((v) => v / max).toList();
  }

  static List<String> _weekLabels(String locale) {
    final labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    if (locale == 'ar') {
      return ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];
    }
    return labels;
  }

  static String _username(AppUserModel user) {
    if (user.username != null && user.username!.isNotEmpty) {
      return user.username!;
    }
    return user.email.split('@').first;
  }
}

// Removed unused duplicate header classes

// Simple Stat Card
class _StatCardSimple extends StatelessWidget {
  final IconData icon;
  final String? lottieAsset;
  final String label;
  final String value;
  final String? unit;
  final bool isDark;

  const _StatCardSimple({
    required this.icon,
    this.lottieAsset,
    required this.label,
    required this.value,
    this.unit,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lottieAsset != null && int.tryParse(value) != null && int.parse(value) > 0)
            SizedBox(
              height: 28,
              width: 28,
              child: Lottie.asset(lottieAsset!, repeat: false),
            )
          else
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              if (unit != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    unit!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// Large Metric Card
class _MetricCardLarge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? percentage;
  final bool isDark;

  const _MetricCardLarge({
    required this.icon,
    required this.label,
    required this.value,
    this.percentage,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
              if (percentage != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    percentage!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

// Compact Metric Card
class _MetricCardCompact extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _MetricCardCompact({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 22),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

// Info Card
class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isDark;

  const _InfoCard({
    required this.title,
    required this.children,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children.map((child) {
            final index = children.indexOf(child);
            return Column(
              children: [
                child,
                if (index < children.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Divider(
                      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.1),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// Info Row
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Actions Card
class _ActionsCard extends StatelessWidget {
  final bool isDark;
  final VoidCallback onEditProfile;
  final VoidCallback onSettings;
  final VoidCallback onLogOut;
  final ProfileCopy copy;

  const _ActionsCard({
    required this.isDark,
    required this.onEditProfile,
    required this.onSettings,
    required this.onLogOut,
    required this.copy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.edit_outlined,
            title: copy.editProfile,
            subtitle: copy.editProfileSubtitle,
            onTap: onEditProfile,
            showDivider: true,
          ),
          _ActionTile(
            icon: Icons.shield_outlined,
            title: copy.passwordAndSecurity,
            subtitle: copy.passwordAndSecuritySubtitle,
            onTap: onSettings,
            showDivider: true,
          ),
          _ActionTile(
            icon: Icons.logout_rounded,
            title: copy.logOut,
            onTap: onLogOut,
            isDanger: true,
          ),
        ],
      ),
    );
  }
}

// Action Tile
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool showDivider;
  final bool isDanger;

  const _ActionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.showDivider = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: isDanger
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDanger
                      ? Theme.of(context).colorScheme.error
                      : null,
                  fontWeight: FontWeight.w500,
                ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.1),
            height: 1,
            indent: AppSpacing.lg,
            endIndent: AppSpacing.lg,
          ),
      ],
    );
  }
}

// Profile Avatar
class _ProfileAvatar extends StatelessWidget {
  final AppUserModel user;
  final double radius;

  const _ProfileAvatar({
    required this.user,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
          ? CircleAvatar(
              radius: radius,
              backgroundImage: NetworkImage(user.avatarUrl!),
            )
          : CircleAvatar(
              radius: radius,
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              child: Text(
                user.fullName.isNotEmpty
                    ? user.fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase()
                    : '?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
    );
  }
}

