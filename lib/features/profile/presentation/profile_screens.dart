import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/extensions/build_context_x.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/providers/app_providers.dart';
import '../../auth/presentation/auth_screens.dart';
import '../../settings/presentation/settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const routePath = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final data = ref.watch(studyDataControllerProvider);

    return AppPage(
      child: data.when(
        loading: () => const LoadingColumn(itemCount: 4),
        error: (error, _) => ErrorStateCard(
          message: context.resolveError(error),
          onRetry: () => ref.read(studyDataControllerProvider.notifier).refresh(),
        ),
        data: (studyData) {
          final currentUser = user;
          if (currentUser == null) {
            return const SizedBox.shrink();
          }

          final completedRate = studyData.tasks.isEmpty
              ? 0.0
              : studyData.completedTasks.length / studyData.tasks.length;
          final weeklyProgress = studyData.goals.weeklyTargetMinutes == 0
              ? 0.0
              : studyData.weeklyStudyMinutes / studyData.goals.weeklyTargetMinutes;
          final profileDepth = _profileDepth(currentUser);
          final weeklySeries = _weekSeries(studyData.sessions);
          final primaryCourse = studyData.courses.isEmpty ? null : studyData.courses.first;

          return ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              RevealOnBuild(
                child: GradientBanner(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ProfileAvatar(
                            user: currentUser,
                            radius: 38,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentUser.fullName.isEmpty
                                      ? 'StudyFlow User'
                                      : currentUser.fullName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  '@${_username(currentUser)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: Colors.white.withOpacity(0.84),
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _HeroChip(label: '${studyData.streakCount} day streak'),
                                    _HeroChip(
                                      label: primaryCourse?.title ?? 'Focus-driven planner',
                                    ),
                                    _HeroChip(
                                      label: currentUser.department ?? 'HCI student',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          FilledButton.tonal(
                            onPressed: () => context.push(ProfileEditScreen.routePath),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.14),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 48),
                            ),
                            child: const Text('Edit'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        currentUser.bio.isEmpty
                            ? 'Designing calm study weeks with focused sessions, visible progress, and low cognitive load.'
                            : currentUser.bio,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.88),
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          Expanded(
                            child: _HeroNumber(
                              label: 'Weekly focus',
                              value: studyData.weeklyStudyMinutes.toDouble(),
                              suffix: 'm',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _HeroNumber(
                              label: 'Completed tasks',
                              value: studyData.completedTasks.length.toDouble(),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _HeroNumber(
                              label: 'XP level',
                              value: studyData.level.toDouble(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: RevealOnBuild(
                      delay: const Duration(milliseconds: 120),
                      child: _ProfileStatCard(
                        label: 'Consistency',
                        color: Theme.of(context).colorScheme.primary,
                        icon: Icons.local_fire_department_rounded,
                        child: AnimatedMetricValue(
                          value: studyData.streakCount.toDouble(),
                          suffix: 'd',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: RevealOnBuild(
                      delay: const Duration(milliseconds: 180),
                      child: _ProfileStatCard(
                        label: 'Profile depth',
                        color: Theme.of(context).colorScheme.tertiary,
                        icon: Icons.person_search_rounded,
                        child: AnimatedMetricValue(
                          value: profileDepth,
                          suffix: '%',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: RevealOnBuild(
                      delay: const Duration(milliseconds: 240),
                      child: _ProfileStatCard(
                        label: 'Task completion',
                        color: Theme.of(context).colorScheme.secondary,
                        icon: Icons.task_alt_rounded,
                        child: AnimatedMetricValue(
                          value: completedRate * 100,
                          suffix: '%',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: RevealOnBuild(
                      delay: const Duration(milliseconds: 300),
                      child: _ProfileStatCard(
                        label: 'Habits locked',
                        color: Theme.of(context).colorScheme.primary,
                        icon: Icons.repeat_rounded,
                        child: AnimatedMetricValue(
                          value: studyData.completedHabits.length.toDouble(),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              RevealOnBuild(
                delay: const Duration(milliseconds: 360),
                child: SectionCard(
                  child: Row(
                    children: [
                      ProgressRing(
                        progress: weeklyProgress,
                        label: 'Weekly target',
                        valueText:
                            '${(weeklyProgress.clamp(0, 1) * 100).round()}%',
                        accent: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Performance pulse',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'A compact summary of your weekly study rhythm and recovery capacity.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            SizedBox(
                              height: 120,
                              child: WeekSparkBars(
                                values: weeklySeries,
                                accent: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              '${studyData.weeklyStudyMinutes} / ${studyData.goals.weeklyTargetMinutes} minutes focused',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              RevealOnBuild(
                delay: const Duration(milliseconds: 420),
                child: SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Identity details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Designed to keep personal context visible without overwhelming the screen.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      DetailRow(label: 'Email', value: currentUser.email),
                      DetailRow(label: 'Username', value: '@${_username(currentUser)}'),
                      DetailRow(
                        label: 'University',
                        value: currentUser.university ?? 'Not added yet',
                      ),
                      DetailRow(
                        label: 'Department',
                        value: currentUser.department ?? 'Not added yet',
                      ),
                      DetailRow(
                        label: 'Preferred language',
                        value: currentUser.preferredLanguage.toUpperCase(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              RevealOnBuild(
                delay: const Duration(milliseconds: 480),
                child: SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Achievement shelf',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Small wins stay visible so motivation becomes a system, not a memory.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ...studyData.achievements.take(3).map(
                            (achievement) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                              child: _AchievementRow(achievement: achievement),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              RevealOnBuild(
                delay: const Duration(milliseconds: 540),
                child: SectionCard(
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.edit_outlined),
                        title: const Text('Edit profile'),
                        subtitle: const Text('Update avatar, bio, and academic identity'),
                        onTap: () => context.push(ProfileEditScreen.routePath),
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.shield_outlined),
                        title: const Text('Password and security'),
                        subtitle: const Text('Theme, recovery, notifications, and account control'),
                        onTap: () => context.push(SettingsScreen.routePath),
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.logout_rounded),
                        title: const Text('Log out'),
                        onTap: () async {
                          await ref.read(authControllerProvider.notifier).signOut();
                          if (context.mounted) {
                            context.go(LoginScreen.routePath);
                          }
                        },
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

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  static const routePath = '/profile/edit';

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _universityController = TextEditingController();
  final _departmentController = TextEditingController();
  bool _initialized = false;
  bool _uploadingAvatar = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _universityController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (!_initialized && user != null) {
      _initialized = true;
      final parts = _splitName(user.fullName);
      _firstNameController.text = parts.$1;
      _lastNameController.text = parts.$2;
      _usernameController.text = user.username ?? '';
      _bioController.text = user.bio;
      _universityController.text = user.university ?? '';
      _departmentController.text = user.department ?? '';
    }

    return AppPage(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RevealOnBuild(
              child: Row(
                children: [
                  IconButton(
                    onPressed: context.pop,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Edit profile',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            RevealOnBuild(
              delay: const Duration(milliseconds: 100),
              child: SectionCard(
                child: Column(
                  children: [
                    _ProfileAvatar(user: user, radius: 42),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.tonal(
                      onPressed:
                          _uploadingAvatar || user == null ? null : () => _pickAvatar(context),
                      child: Text(
                        _uploadingAvatar ? 'Uploading...' : 'Upload photo',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Use a clean portrait for a stronger presentation identity.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            RevealOnBuild(
              delay: const Duration(milliseconds: 180),
              child: SectionCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(labelText: 'First name'),
                        validator: (value) => context.validationMessage(
                          Validators.requiredField(value),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(labelText: 'Last name'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: 'Username'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _bioController,
                        minLines: 3,
                        maxLines: 4,
                        decoration: const InputDecoration(labelText: 'Bio'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _departmentController,
                        decoration: const InputDecoration(labelText: 'Department'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _universityController,
                        decoration: const InputDecoration(labelText: 'University'),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton(
                        onPressed: user == null
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                final fullName = [
                                  _firstNameController.text.trim(),
                                  _lastNameController.text.trim(),
                                ].where((item) => item.isNotEmpty).join(' ');
                                await ref
                                    .read(authControllerProvider.notifier)
                                    .updateProfile(
                                      user.copyWith(
                                        fullName: fullName,
                                        username: _normalizedValue(
                                          _usernameController.text,
                                        ),
                                        bio: _bioController.text.trim(),
                                        department: _normalizedValue(
                                          _departmentController.text,
                                        ),
                                        university: _normalizedValue(
                                          _universityController.text,
                                        ),
                                        updatedAt: DateTime.now(),
                                      ),
                                    );
                                if (!mounted) {
                                  return;
                                }
                                context.pop();
                              },
                        child: const Text('Save profile'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            RevealOnBuild(
              delay: const Duration(milliseconds: 240),
              child: SectionCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.shield_outlined),
                  title: const Text('Password and security'),
                  subtitle: const Text('Manage recovery, notifications, and theme preferences'),
                  onTap: () => context.push(SettingsScreen.routePath),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAvatar(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 84,
      maxWidth: 1200,
    );
    if (image == null) {
      return;
    }

    setState(() => _uploadingAvatar = true);
    try {
      await ref.read(authControllerProvider.notifier).uploadAvatar(image.path);
      if (!mounted) {
        return;
      }
      context.showAppSnackBar('Profile photo updated');
    } catch (error) {
      if (!mounted) {
        return;
      }
      context.showAppSnackBar(context.resolveError(error));
    } finally {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
      }
    }
  }
}

class _ProfileStatCard extends StatelessWidget {
  const _ProfileStatCard({
    required this.label,
    required this.color,
    required this.icon,
    required this.child,
  });

  final String label;
  final Color color;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.14),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _HeroNumber extends StatelessWidget {
  const _HeroNumber({
    required this.label,
    required this.value,
    this.suffix = '',
  });

  final String label;
  final double value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedMetricValue(
            value: value,
            suffix: suffix,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.82),
                ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
            ),
      ),
    );
  }
}

class _AchievementRow extends StatelessWidget {
  const _AchievementRow({
    required this.achievement,
  });

  final AchievementModel achievement;

  @override
  Widget build(BuildContext context) {
    final progress = achievement.target == 0
        ? 0.0
        : achievement.progress / achievement.target;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.12),
          child: Icon(_achievementIcon(achievement.icon)),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                achievement.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                achievement.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress.clamp(0, 1).toDouble(),
                  minHeight: 10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          '${achievement.progress}/${achievement.target}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.user,
    required this.radius,
  });

  final AppUserModel? user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final imageProvider = _avatarProvider(user?.avatarUrl);
    final initials = _initials(user?.fullName, user?.email);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.tertiary,
          ],
        ),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.surface,
        backgroundImage: imageProvider,
        child: imageProvider == null
            ? Text(
                initials,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              )
            : null,
      ),
    );
  }
}

ImageProvider<Object>? _avatarProvider(String? avatarUrl) {
  if (avatarUrl == null || avatarUrl.isEmpty) {
    return null;
  }
  if (avatarUrl.startsWith('http')) {
    return NetworkImage(avatarUrl);
  }
  return FileImage(File(avatarUrl));
}

String _initials(String? fullName, String? email) {
  final name = (fullName ?? '').trim();
  if (name.isNotEmpty) {
    final parts = name.split(RegExp(r'\s+')).where((item) => item.isNotEmpty);
    return parts.take(2).map((item) => item[0].toUpperCase()).join();
  }

  final mail = (email ?? '').trim();
  return mail.isEmpty ? 'S' : mail.substring(0, 1).toUpperCase();
}

String _username(AppUserModel user) {
  final value = user.username?.trim();
  if (value != null && value.isNotEmpty) {
    return value;
  }
  return user.email.split('@').first;
}

double _profileDepth(AppUserModel user) {
  final values = [
    user.fullName.isNotEmpty,
    user.username?.isNotEmpty == true,
    user.bio.isNotEmpty,
    user.university?.isNotEmpty == true,
    user.department?.isNotEmpty == true,
    user.avatarUrl?.isNotEmpty == true,
  ];
  final completed = values.where((value) => value).length;
  return (completed / values.length) * 100;
}

List<double> _weekSeries(List<StudySessionModel> sessions) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));
  return List.generate(7, (index) {
    final day = start.add(Duration(days: index));
    return sessions
        .where(
          (session) =>
              session.startTime.year == day.year &&
              session.startTime.month == day.month &&
              session.startTime.day == day.day,
        )
        .fold<double>(0, (sum, item) => sum + item.durationMinutes);
  });
}

(String, String) _splitName(String fullName) {
  final trimmed = fullName.trim();
  if (trimmed.isEmpty) {
    return ('', '');
  }
  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length == 1) {
    return (parts.first, '');
  }
  return (parts.first, parts.sublist(1).join(' '));
}

String? _normalizedValue(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

IconData _achievementIcon(String icon) {
  switch (icon) {
    case 'timer':
      return Icons.timer_rounded;
    case 'check_circle':
      return Icons.check_circle_rounded;
    case 'local_fire_department':
      return Icons.local_fire_department_rounded;
    default:
      return Icons.workspace_premium_rounded;
  }
}
