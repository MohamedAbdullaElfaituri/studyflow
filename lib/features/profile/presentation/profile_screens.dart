import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final copy = ProfileCopy.of(context);

    return AppPage(
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
          final currentUser = user;
          if (currentUser == null) {
            return const SizedBox.shrink();
          }

          final isCompact = MediaQuery.sizeOf(context).width < 390;
          final completionRate = studyData.tasks.isEmpty
              ? 0.0
              : studyData.completedTasks.length / studyData.tasks.length;

          return ListView(
            children: [
              PageHeader(
                title: context.l10n.profileTab,
                subtitle: context.l10n.profileOverviewSubtitle,
                leading: _ProfileAvatar(user: currentUser, radius: 24),
                trailing: IconButton.filledTonal(
                  onPressed: () => context.push(SettingsScreen.routePath),
                  icon: const Icon(Icons.settings_outlined),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionCard(
                child: Column(
                  children: [
                    _ProfileAvatar(user: currentUser, radius: 46),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      currentUser.fullName.isEmpty
                          ? copy.fallbackUserName
                          : currentUser.fullName,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '@${_username(currentUser)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    if (currentUser.bio.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        currentUser.bio,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Lottie.asset(
                        'assets/animations/Success.json',
                        repeat: false,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (isCompact)
                Column(
                  children: [
                    MetricTile(
                      label: copy.weeklyFocus,
                      value: '${studyData.weeklyStudyMinutes}',
                      icon: Icons.timer_outlined,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    MetricTile(
                      label: context.l10n.completedTasksLabel,
                      value: '${studyData.completedTasks.length}',
                      icon: Icons.task_alt_rounded,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    MetricTile(
                      label: context.l10n.streakLabel,
                      value: '${studyData.streakCount}',
                      icon: Icons.local_fire_department_rounded,
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: MetricTile(
                        label: copy.weeklyFocus,
                        value: '${studyData.weeklyStudyMinutes}',
                        icon: Icons.timer_outlined,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: MetricTile(
                        label: context.l10n.completedTasksLabel,
                        value: '${studyData.completedTasks.length}',
                        icon: Icons.task_alt_rounded,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: MetricTile(
                        label: context.l10n.streakLabel,
                        value: '${studyData.streakCount}',
                        icon: Icons.local_fire_department_rounded,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: context.l10n.profileOverviewTitle,
                subtitle: _progressSubtitle(context, completionRate),
              ),
              const SizedBox(height: AppSpacing.md),
              SectionCard(
                child: Column(
                  children: [
                    DetailRow(
                      label: copy.email,
                      value: currentUser.email,
                      icon: Icons.mail_outline_rounded,
                    ),
                    DetailRow(
                      label: copy.username,
                      value: '@${_username(currentUser)}',
                      icon: Icons.alternate_email_rounded,
                    ),
                    DetailRow(
                      label: copy.university,
                      value: currentUser.university ?? copy.notAddedYet,
                      icon: Icons.school_outlined,
                    ),
                    DetailRow(
                      label: copy.department,
                      value: currentUser.department ?? copy.notAddedYet,
                      icon: Icons.menu_book_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton(
                      onPressed: () =>
                          context.push(ProfileEditScreen.routePath),
                      child: Text(context.l10n.editProfileAction),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: () => context.push(SettingsScreen.routePath),
                      child: Text(context.l10n.settingsTitle),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .signOut();
                        if (context.mounted) {
                          context.go(LoginScreen.routePath);
                        }
                      },
                      child: Text(context.l10n.logoutAction),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _username(AppUserModel user) {
    if (user.username != null && user.username!.trim().isNotEmpty) {
      return user.username!.trim();
    }
    return user.email.split('@').first;
  }

  String _progressSubtitle(BuildContext context, double completionRate) {
    final percent = (completionRate * 100).round();
    return switch (Localizations.localeOf(context).languageCode) {
      'tr' => 'Mevcut gorev tamamlama oranin $percent% seviyesinde.',
      'ar' => 'معدل إكمال المهام الحالي لديك هو $percent٪.',
      _ => 'Your current task completion rate is $percent%.',
    };
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.user,
    required this.radius,
  });

  final AppUserModel user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;
    final initials = user.fullName.trim().isEmpty
        ? '?'
        : user.fullName
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((part) => part.isEmpty ? '' : part[0])
            .join()
            .toUpperCase();

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
          ? ClipOval(
              child: Image.network(
                user.avatarUrl!,
                fit: BoxFit.cover,
              ),
            )
          : CircleAvatar(
              radius: radius,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                initials,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
    );
  }
}
