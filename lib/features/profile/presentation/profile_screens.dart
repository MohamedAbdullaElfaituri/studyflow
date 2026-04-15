// ignore_for_file: unused_element

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
import 'profile_copy.dart';

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
          onRetry: () =>
              ref.read(studyDataControllerProvider.notifier).refresh(),
        ),
        data: (studyData) {
          final currentUser = user;
          if (currentUser == null) {
            return const SizedBox.shrink();
          }

          final copy = ProfileCopy.of(context);
          final locale = Localizations.localeOf(context).languageCode;
          final isCompact = MediaQuery.sizeOf(context).width < 390;
          final screenWidth = MediaQuery.sizeOf(context).width;
          final heroMetricWidth =
              isCompact ? screenWidth - 72 : (screenWidth - 96) / 3;
          final completedRate = studyData.tasks.isEmpty
              ? 0.0
              : studyData.completedTasks.length / studyData.tasks.length;
          final weeklyProgress = studyData.goals.weeklyTargetMinutes == 0
              ? 0.0
              : studyData.weeklyStudyMinutes /
                  studyData.goals.weeklyTargetMinutes;
          final profileDepth = _profileDepth(currentUser);
          final weeklySeries = _weekSeries(studyData.sessions);
          final primaryCourse =
              studyData.courses.isEmpty ? null : studyData.courses.first;

          return ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              RevealOnBuild(
                child: GradientBanner(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isCompact)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ProfileAvatar(
                              user: currentUser,
                              radius: 38,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              currentUser.fullName.isEmpty
                                  ? copy.fallbackUserName
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
                                    color: Colors.white.withValues(alpha: 0.84),
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _HeroChip(
                                    label:
                                        copy.dayStreak(studyData.streakCount)),
                                _HeroChip(
                                  label:
                                      primaryCourse?.title ?? copy.focusPlanner,
                                ),
                                _HeroChip(
                                  label:
                                      currentUser.department ?? copy.hciStudent,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            FilledButton.tonal(
                              onPressed: () =>
                                  context.push(ProfileEditScreen.routePath),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.14),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 48),
                              ),
                              child: Text(copy.edit),
                            ),
                          ],
                        )
                      else
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
                                        ? copy.fallbackUserName
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
                                          color: Colors.white
                                              .withValues(alpha: 0.84),
                                        ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _HeroChip(
                                          label: copy.dayStreak(
                                              studyData.streakCount)),
                                      _HeroChip(
                                        label: primaryCourse?.title ??
                                            copy.focusPlanner,
                                      ),
                                      _HeroChip(
                                        label: currentUser.department ??
                                            copy.hciStudent,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            FilledButton.tonal(
                              onPressed: () =>
                                  context.push(ProfileEditScreen.routePath),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.14),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 48),
                              ),
                              child: Text(copy.edit),
                            ),
                          ],
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        currentUser.bio.isEmpty
                            ? copy.defaultBio
                            : currentUser.bio,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        children: [
                          SizedBox(
                            width: heroMetricWidth,
                            child: _HeroNumber(
                              label: copy.weeklyFocus,
                              value: studyData.weeklyStudyMinutes.toDouble(),
                              suffix: 'm',
                            ),
                          ),
                          SizedBox(
                            width: heroMetricWidth,
                            child: _HeroNumber(
                              label: copy.completedTasks,
                              value: studyData.completedTasks.length.toDouble(),
                            ),
                          ),
                          SizedBox(
                            width: heroMetricWidth,
                            child: _HeroNumber(
                              label: copy.xpLevel,
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
              if (isCompact)
                Column(
                  children: [
                    RevealOnBuild(
                      delay: const Duration(milliseconds: 120),
                      child: _ProfileStatCard(
                        label: copy.consistency,
                        color: Theme.of(context).colorScheme.primary,
                        icon: Icons.local_fire_department_rounded,
                        child: AnimatedMetricValue(
                          value: studyData.streakCount.toDouble(),
                          suffix: 'd',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    RevealOnBuild(
                      delay: const Duration(milliseconds: 180),
                      child: _ProfileStatCard(
                        label: copy.profileDepth,
                        color: Theme.of(context).colorScheme.tertiary,
                        icon: Icons.person_search_rounded,
                        child: AnimatedMetricValue(
                          value: profileDepth,
                          suffix: '%',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: RevealOnBuild(
                        delay: const Duration(milliseconds: 120),
                        child: _ProfileStatCard(
                          label: copy.consistency,
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
                          label: copy.profileDepth,
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
              if (isCompact)
                Column(
                  children: [
                    RevealOnBuild(
                      delay: const Duration(milliseconds: 240),
                      child: _ProfileStatCard(
                        label: copy.taskCompletion,
                        color: Theme.of(context).colorScheme.secondary,
                        icon: Icons.task_alt_rounded,
                        child: AnimatedMetricValue(
                          value: completedRate * 100,
                          suffix: '%',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    RevealOnBuild(
                      delay: const Duration(milliseconds: 300),
                      child: _ProfileStatCard(
                        label: copy.habitsLocked,
                        color: Theme.of(context).colorScheme.primary,
                        icon: Icons.repeat_rounded,
                        child: AnimatedMetricValue(
                          value: studyData.completedHabits.length.toDouble(),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: RevealOnBuild(
                        delay: const Duration(milliseconds: 240),
                        child: _ProfileStatCard(
                          label: copy.taskCompletion,
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
                          label: copy.habitsLocked,
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
                  child: isCompact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              child: ProgressRing(
                                progress: weeklyProgress,
                                label: copy.weeklyTarget,
                                valueText:
                                    '${(weeklyProgress.clamp(0, 1) * 100).round()}%',
                                accent: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              copy.performancePulse,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              copy.performancePulseSubtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
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
                                labels: _weekLabels(locale),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              copy.focusMinutes(
                                studyData.weeklyStudyMinutes,
                                studyData.goals.weeklyTargetMinutes,
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            ProgressRing(
                              progress: weeklyProgress,
                              label: copy.weeklyTarget,
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
                                    copy.performancePulse,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    copy.performancePulseSubtitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
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
                                      accent:
                                          Theme.of(context).colorScheme.primary,
                                      labels: _weekLabels(locale),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    copy.focusMinutes(
                                      studyData.weeklyStudyMinutes,
                                      studyData.goals.weeklyTargetMinutes,
                                    ),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
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
                        copy.identityDetails,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        copy.identityDetailsSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      DetailRow(label: copy.email, value: currentUser.email),
                      DetailRow(
                          label: copy.username,
                          value: '@${_username(currentUser)}'),
                      DetailRow(
                        label: copy.university,
                        value: currentUser.university ?? copy.notAddedYet,
                      ),
                      DetailRow(
                        label: copy.department,
                        value: currentUser.department ?? copy.notAddedYet,
                      ),
                      DetailRow(
                        label: copy.preferredLanguage,
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
                        copy.achievementShelf,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        copy.achievementSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ...studyData.achievements.take(3).map(
                            (achievement) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.lg),
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
                        title: Text(copy.editProfile),
                        subtitle: Text(copy.editProfileSubtitle),
                        onTap: () => context.push(ProfileEditScreen.routePath),
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.shield_outlined),
                        title: Text(copy.passwordAndSecurity),
                        subtitle: Text(copy.passwordAndSecuritySubtitle),
                        onTap: () => context.push(SettingsScreen.routePath),
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.logout_rounded),
                        title: Text(copy.logOut),
                        onTap: () async {
                          await ref
                              .read(authControllerProvider.notifier)
                              .signOut();
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
  bool _savingProfile = false;

  bool get _isBusy => _uploadingAvatar || _savingProfile;

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
    final copy = ProfileCopy.of(context);
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

    if (user == null) {
      return AppPage(
        child: const LoadingColumn(itemCount: 3),
      );
    }

    return AppPage(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 980;
          final isMedium = constraints.maxWidth >= 680;
          final horizontalPadding = isWide
              ? AppSpacing.xxxl
              : (isMedium ? AppSpacing.xxl : AppSpacing.lg);
          final verticalPadding =
              constraints.maxHeight < 760 ? AppSpacing.lg : AppSpacing.xxl;

          final sidebar = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RevealOnBuild(
                child: _EditProfileHero(
                  user: user,
                  copy: copy,
                  compact: !isMedium,
                  uploadingAvatar: _uploadingAvatar,
                  onPickAvatar: _isBusy ? null : () => _pickAvatar(context),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              RevealOnBuild(
                delay: const Duration(milliseconds: 120),
                child: _EditProfileSecurityCard(
                  copy: copy,
                  onTap: () => context.push(SettingsScreen.routePath),
                ),
              ),
            ],
          );

          final formColumn = Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RevealOnBuild(
                  delay: const Duration(milliseconds: 160),
                  child: _EditProfileSectionCard(
                    icon: Icons.badge_rounded,
                    accent: Theme.of(context).colorScheme.primary,
                    title: copy.coreIdentity,
                    subtitle: copy.coreIdentitySubtitle,
                    child: Column(
                      children: [
                        LayoutBuilder(
                          builder: (context, sectionConstraints) {
                            final twoColumns =
                                sectionConstraints.maxWidth >= 520;
                            final firstNameField = TextFormField(
                              controller: _firstNameController,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                              decoration: _fieldDecoration(
                                copy.firstName,
                                Icons.person_outline_rounded,
                              ),
                              validator: (value) => context.validationMessage(
                                Validators.requiredField(value),
                              ),
                            );
                            final lastNameField = TextFormField(
                              controller: _lastNameController,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                              decoration: _fieldDecoration(
                                copy.lastName,
                                Icons.badge_outlined,
                              ),
                            );

                            if (!twoColumns) {
                              return Column(
                                children: [
                                  firstNameField,
                                  const SizedBox(height: AppSpacing.md),
                                  lastNameField,
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(child: firstNameField),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(child: lastNameField),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _usernameController,
                          textInputAction: TextInputAction.next,
                          decoration: _fieldDecoration(
                            copy.username,
                            Icons.alternate_email_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                RevealOnBuild(
                  delay: const Duration(milliseconds: 220),
                  child: _EditProfileSectionCard(
                    icon: Icons.edit_note_rounded,
                    accent: Theme.of(context).colorScheme.secondary,
                    title: copy.bio,
                    subtitle: copy.bioSubtitle,
                    child: TextFormField(
                      controller: _bioController,
                      minLines: 4,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _fieldDecoration(
                        copy.bio,
                        Icons.notes_rounded,
                        hint: copy.defaultBio,
                        alignLabelWithHint: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                RevealOnBuild(
                  delay: const Duration(milliseconds: 280),
                  child: _EditProfileSectionCard(
                    icon: Icons.school_rounded,
                    accent: Theme.of(context).colorScheme.tertiary,
                    title: copy.academicContext,
                    subtitle: copy.academicContextSubtitle,
                    child: LayoutBuilder(
                      builder: (context, sectionConstraints) {
                        final twoColumns = sectionConstraints.maxWidth >= 520;
                        final departmentField = TextFormField(
                          controller: _departmentController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: _fieldDecoration(
                            copy.department,
                            Icons.auto_stories_outlined,
                          ),
                        );
                        final universityField = TextFormField(
                          controller: _universityController,
                          textInputAction: TextInputAction.done,
                          textCapitalization: TextCapitalization.words,
                          decoration: _fieldDecoration(
                            copy.university,
                            Icons.account_balance_outlined,
                          ),
                        );

                        if (!twoColumns) {
                          return Column(
                            children: [
                              departmentField,
                              const SizedBox(height: AppSpacing.md),
                              universityField,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: departmentField),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: universityField),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                RevealOnBuild(
                  delay: const Duration(milliseconds: 340),
                  child: SectionCard(
                    child: LayoutBuilder(
                      builder: (context, sectionConstraints) {
                        final stacked = sectionConstraints.maxWidth < 430;
                        final saveButton = FilledButton(
                          onPressed: _isBusy
                              ? null
                              : () => _saveProfile(context, user),
                          style: FilledButton.styleFrom(
                            minimumSize: Size(
                              stacked ? double.infinity : 220,
                              56,
                            ),
                          ),
                          child: _BusyButtonLabel(
                            isBusy: _savingProfile,
                            label: copy.saveProfile,
                            busyLabel: copy.savingProfile,
                          ),
                        );

                        if (stacked) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                copy.saveProfile,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                copy.saveProfileHint,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              saveButton,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    copy.saveProfile,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    copy.saveProfileHint,
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
                            const SizedBox(width: AppSpacing.lg),
                            saveButton,
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );

          final content = isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 10, child: sidebar),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(flex: 12, child: formColumn),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    sidebar,
                    const SizedBox(height: AppSpacing.lg),
                    formColumn,
                  ],
                );

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 1160 : 760,
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RevealOnBuild(
                        child: _EditProfileTopBar(copy: copy),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      content,
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _fieldDecoration(
    String label,
    IconData icon, {
    String? hint,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      alignLabelWithHint: alignLabelWithHint,
    );
  }

  Future<void> _saveProfile(BuildContext context, AppUserModel user) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _savingProfile = true);

    try {
      final fullName = [
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
      ].where((item) => item.isNotEmpty).join(' ');

      await ref.read(authControllerProvider.notifier).updateProfile(
            user.copyWith(
              fullName: fullName,
              username: _normalizedValue(_usernameController.text),
              bio: _bioController.text.trim(),
              department: _normalizedValue(_departmentController.text),
              university: _normalizedValue(_universityController.text),
              updatedAt: DateTime.now(),
            ),
          );

      if (!mounted) {
        return;
      }
      context.pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      context.showErrorNotification(context.resolveError(error));
    } finally {
      if (mounted) {
        setState(() => _savingProfile = false);
      }
    }
  }

  Future<void> _pickAvatar(BuildContext context) async {
    if (_isBusy) {
      return;
    }

    FocusScope.of(context).unfocus();
    final copy = ProfileCopy.of(context);
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
      context.showSuccessNotification(copy.photoUpdatedMessage);
    } catch (error) {
      if (!mounted) {
        return;
      }
      context.showErrorNotification(context.resolveError(error));
    } finally {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
      }
    }
  }
}

class _EditProfileTopBar extends StatelessWidget {
  const _EditProfileTopBar({required this.copy});

  final ProfileCopy copy;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton.filledTonal(
          onPressed: context.pop,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                copy.editProfile,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                copy.editProfileSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditProfileHero extends StatelessWidget {
  const _EditProfileHero({
    required this.user,
    required this.copy,
    required this.compact,
    required this.uploadingAvatar,
    required this.onPickAvatar,
  });

  final AppUserModel user;
  final ProfileCopy copy;
  final bool compact;
  final bool uploadingAvatar;
  final VoidCallback? onPickAvatar;

  @override
  Widget build(BuildContext context) {
    final completion = _profileDepth(user).round();
    final name = user.fullName.isEmpty ? copy.fallbackUserName : user.fullName;
    final scheme = Theme.of(context).colorScheme;
    final hasAvatar = user.avatarUrl?.isNotEmpty == true;
    final chips = <Widget>[
      _EditProfileGlassChip(
        icon: Icons.alternate_email_rounded,
        label: '@${_username(user)}',
      ),
      _EditProfileGlassChip(
        icon: Icons.translate_rounded,
        label: user.preferredLanguage.toUpperCase(),
      ),
    ];

    final shortDepartment = user.department?.trim();
    if (shortDepartment != null &&
        shortDepartment.isNotEmpty &&
        shortDepartment.length <= 18) {
      chips.add(
        _EditProfileGlassChip(
          icon: Icons.school_rounded,
          label: shortDepartment,
        ),
      );
    }

    final photoColumn = Column(
      crossAxisAlignment:
          compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          copy.profilePhoto,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.86),
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        _EditProfilePhotoFrame(
          user: user,
          compact: compact,
          uploadingAvatar: uploadingAvatar,
          accent: scheme.primary,
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: onPickAvatar,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.16),
            foregroundColor: Colors.white,
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.2),
            ),
            minimumSize: const Size(0, 48),
          ),
          icon: Icon(
            uploadingAvatar ? Icons.sync_rounded : Icons.camera_alt_rounded,
            size: 18,
          ),
          label: Text(
            uploadingAvatar
                ? copy.uploading
                : (hasAvatar ? copy.changePhoto : copy.uploadPhoto),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: compact ? 280 : 320),
          child: Text(
            copy.uploadHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.4,
                ),
            textAlign: compact ? TextAlign.center : TextAlign.start,
          ),
        ),
      ],
    );

    final detailsColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          copy.livePreview,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.88),
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          user.email,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.84),
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: chips,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          copy.livePreviewSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.82),
                height: 1.5,
              ),
        ),
      ],
    );

    final completionCard = _EditProfileCompletionCard(
      copy: copy,
      completion: completion,
      compact: compact,
    );

    return GradientBanner(
      colors: [
        scheme.primary,
        Color.lerp(scheme.primary, scheme.secondary, 0.72) ?? scheme.secondary,
        scheme.tertiary,
      ],
      child: Stack(
        children: [
          PositionedDirectional(
            top: -18,
            end: -8,
            child: Container(
              width: compact ? 92 : 116,
              height: compact ? 92 : 116,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: -40,
            start: compact ? -18 : 84,
            child: Container(
              width: compact ? 110 : 148,
              height: compact ? 110 : 148,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          if (compact)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                photoColumn,
                const SizedBox(height: AppSpacing.xl),
                detailsColumn,
                const SizedBox(height: AppSpacing.lg),
                completionCard,
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                photoColumn,
                const SizedBox(width: AppSpacing.xl),
                Expanded(child: detailsColumn),
                const SizedBox(width: AppSpacing.lg),
                completionCard,
              ],
            ),
        ],
      ),
    );
  }
}

class _EditProfilePhotoFrame extends StatelessWidget {
  const _EditProfilePhotoFrame({
    required this.user,
    required this.compact,
    required this.uploadingAvatar,
    required this.accent,
  });

  final AppUserModel user;
  final bool compact;
  final bool uploadingAvatar;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final avatarRadius = compact ? 54.0 : 60.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          _ProfileAvatar(user: user, radius: avatarRadius),
          PositionedDirectional(
            bottom: -6,
            end: -6,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                uploadingAvatar
                    ? Icons.hourglass_top_rounded
                    : Icons.camera_alt_rounded,
                color: accent,
                size: 20,
              ),
            ),
          ),
          if (uploadingAvatar)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.26),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EditProfileCompletionCard extends StatelessWidget {
  const _EditProfileCompletionCard({
    required this.copy,
    required this.completion,
    required this.compact,
  });

  final ProfileCopy copy;
  final int completion;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? double.infinity : 220,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            copy.profileDepth,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.86),
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '$completion%',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            copy.editProfileSubtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.76),
                  height: 1.45,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: completion / 100,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.92),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileGlassChip extends StatelessWidget {
  const _EditProfileGlassChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileSectionCard extends StatelessWidget {
  const _EditProfileSectionCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _EditProfileSecurityCard extends StatelessWidget {
  const _EditProfileSecurityCard({
    required this.copy,
    required this.onTap,
  });

  final ProfileCopy copy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.shield_rounded,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        title: Text(copy.passwordAndSecurity),
        subtitle: Text(copy.managePreferences),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _BusyButtonLabel extends StatelessWidget {
  const _BusyButtonLabel({
    required this.isBusy,
    required this.label,
    required this.busyLabel,
  });

  final bool isBusy;
  final String label;
  final String busyLabel;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isBusy
          ? Row(
              key: const ValueKey('busy'),
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(busyLabel),
              ],
            )
          : Text(
              label,
              key: const ValueKey('idle'),
            ),
    );
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
            backgroundColor: color.withValues(alpha: 0.14),
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
        color: Colors.white.withValues(alpha: 0.12),
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
                  color: Colors.white.withValues(alpha: 0.82),
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
        color: Colors.white.withValues(alpha: 0.12),
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
    final copy = ProfileCopy.of(context);
    final progress = achievement.target == 0
        ? 0.0
        : achievement.progress / achievement.target;
    final compact = MediaQuery.sizeOf(context).width < 360;

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.12),
                child: Icon(_achievementIcon(achievement.icon)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      copy.achievementTitle(achievement.id),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      copy.achievementDescription(achievement.id),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${achievement.progress}/${achievement.target}',
            style: Theme.of(context).textTheme.labelLarge,
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
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
          child: Icon(_achievementIcon(achievement.icon)),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                copy.achievementTitle(achievement.id),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                copy.achievementDescription(achievement.id),
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

List<String> _weekLabels(String locale) {
  return switch (locale) {
    'tr' => const ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pa'],
    'ar' => const ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'],
    _ => const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
  };
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
    case 'repeat':
      return Icons.repeat_rounded;
    default:
      return Icons.workspace_premium_rounded;
  }
}

class _ProfileCopy {
  const _ProfileCopy(this.code);

  final String code;

  static _ProfileCopy of(BuildContext context) =>
      _ProfileCopy(Localizations.localeOf(context).languageCode);

  bool get _isTr => code == 'tr';
  bool get _isAr => code == 'ar';

  String _pick({
    required String en,
    required String tr,
    required String ar,
  }) {
    if (_isTr) {
      return tr;
    }
    if (_isAr) {
      return ar;
    }
    return en;
  }

  String get fallbackUserName => _pick(
        en: 'StudyFlow User',
        tr: 'StudyFlow Kullanicisi',
        ar: 'مستخدم StudyFlow',
      );
  String get focusPlanner => _pick(
        en: 'Focus-driven planner',
        tr: 'Odak planlayicisi',
        ar: 'مخطط قائم على التركيز',
      );
  String get hciStudent => _pick(
        en: 'HCI student',
        tr: 'HCI ogrencisi',
        ar: 'طالب تفاعل إنسان وحاسوب',
      );
  String dayStreak(int days) => _pick(
        en: '$days day streak',
        tr: '$days gun seri',
        ar: 'سلسلة $days يوم',
      );
  String get edit => _pick(
        en: 'Edit',
        tr: 'Duzenle',
        ar: 'تعديل',
      );
  String get defaultBio => _pick(
        en: 'Designing calm study weeks with focused sessions, visible progress, and low cognitive load.',
        tr: 'Odak seanslari, gorunur ilerleme ve dusuk bilissel yuk ile sakin calisma haftalari kuruyorum.',
        ar: 'أبني أسابيع دراسة هادئة بجلسات تركيز وتقدم واضح وحمل معرفي منخفض.',
      );
  String get weeklyFocus => _pick(
        en: 'Weekly focus',
        tr: 'Haftalik odak',
        ar: 'تركيز الأسبوع',
      );
  String get completedTasks => _pick(
        en: 'Completed tasks',
        tr: 'Tamamlanan gorevler',
        ar: 'المهام المكتملة',
      );
  String get xpLevel => _pick(
        en: 'XP level',
        tr: 'XP seviyesi',
        ar: 'مستوى XP',
      );
  String get weeklyTarget => _pick(
        en: 'Weekly target',
        tr: 'Haftalik hedef',
        ar: 'هدف الأسبوع',
      );
  String get consistency => _pick(
        en: 'Consistency',
        tr: 'Tutarlilik',
        ar: 'الاستمرارية',
      );
  String get profileDepth => _pick(
        en: 'Profile depth',
        tr: 'Profil derinligi',
        ar: 'عمق الملف الشخصي',
      );
  String get taskCompletion => _pick(
        en: 'Task completion',
        tr: 'Gorev tamamlama',
        ar: 'إكمال المهام',
      );
  String get habitsLocked => _pick(
        en: 'Habits locked',
        tr: 'Tamamlanan aliskanliklar',
        ar: 'العادات المنجزة',
      );
  String get performancePulse => _pick(
        en: 'Performance pulse',
        tr: 'Performans ozeti',
        ar: 'نبض الأداء',
      );
  String get performancePulseSubtitle => _pick(
        en: 'A compact summary of your weekly study rhythm and recovery capacity.',
        tr: 'Haftalik ritmini ve toparlanma kapasiteni gosteren kisa bir ozet.',
        ar: 'ملخص مدمج لإيقاع دراستك الأسبوعي وقدرتك على الاستمرار.',
      );
  String focusMinutes(int value, int target) => _pick(
        en: '$value / $target minutes focused',
        tr: '$value / $target dakika odak',
        ar: '$value / $target دقيقة تركيز',
      );
  String get identityDetails => _pick(
        en: 'Identity details',
        tr: 'Kimlik detaylari',
        ar: 'تفاصيل الهوية',
      );
  String get identityDetailsSubtitle => _pick(
        en: 'Designed to keep personal context visible without overwhelming the screen.',
        tr: 'Kisisel bilgileri ekrani yormadan gorunur tutmak icin tasarlandi.',
        ar: 'مصمم لإبقاء السياق الشخصي ظاهراً دون إرباك الشاشة.',
      );
  String get email => _pick(
        en: 'Email',
        tr: 'E-posta',
        ar: 'البريد الإلكتروني',
      );
  String get username => _pick(
        en: 'Username',
        tr: 'Kullanici adi',
        ar: 'اسم المستخدم',
      );
  String get university => _pick(
        en: 'University',
        tr: 'Universite',
        ar: 'الجامعة',
      );
  String get department => _pick(
        en: 'Department',
        tr: 'Bolum',
        ar: 'القسم',
      );
  String get preferredLanguage => _pick(
        en: 'Preferred language',
        tr: 'Tercih edilen dil',
        ar: 'اللغة المفضلة',
      );
  String get notAddedYet => _pick(
        en: 'Not added yet',
        tr: 'Henuz eklenmedi',
        ar: 'لم تتم إضافته بعد',
      );
  String get achievementShelf => _pick(
        en: 'Achievement shelf',
        tr: 'Basari rafı',
        ar: 'رف الإنجازات',
      );
  String get achievementSubtitle => _pick(
        en: 'Small wins stay visible so motivation becomes a system, not a memory.',
        tr: 'Kucuk kazanclar gorunur kaldiginda motivasyon bir sistem haline gelir.',
        ar: 'تبقى الانتصارات الصغيرة ظاهرة حتى تصبح الدافعية نظاماً لا مجرد ذكرى.',
      );
  String get editProfile => _pick(
        en: 'Edit profile',
        tr: 'Profili duzenle',
        ar: 'تعديل الملف الشخصي',
      );
  String get editProfileSubtitle => _pick(
        en: 'Update avatar, bio, and academic identity',
        tr: 'Avatar, biyografi ve akademik kimligi guncelle',
        ar: 'حدّث الصورة والنبذة والهوية الأكاديمية',
      );
  String get passwordAndSecurity => _pick(
        en: 'Password and security',
        tr: 'Sifre ve guvenlik',
        ar: 'كلمة المرور والأمان',
      );
  String get passwordAndSecuritySubtitle => _pick(
        en: 'Theme, recovery, notifications, and account control',
        tr: 'Tema, kurtarma, bildirimler ve hesap yonetimi',
        ar: 'الثيم والاستعادة والإشعارات والتحكم بالحساب',
      );
  String get logOut => _pick(
        en: 'Log out',
        tr: 'Cikis yap',
        ar: 'تسجيل الخروج',
      );
  String get uploading => _pick(
        en: 'Uploading...',
        tr: 'Yukleniyor...',
        ar: 'جارٍ الرفع...',
      );
  String get uploadPhoto => _pick(
        en: 'Upload photo',
        tr: 'Fotograf yukle',
        ar: 'رفع صورة',
      );
  String get uploadHint => _pick(
        en: 'Use a clean portrait for a stronger presentation identity.',
        tr: 'Sunumda daha guclu bir kimlik icin temiz bir portre kullan.',
        ar: 'استخدم صورة واضحة لتقديم هوية شخصية أقوى.',
      );
  String get firstName => _pick(
        en: 'First name',
        tr: 'Ad',
        ar: 'الاسم الأول',
      );
  String get lastName => _pick(
        en: 'Last name',
        tr: 'Soyad',
        ar: 'اسم العائلة',
      );
  String get bio => _pick(
        en: 'Bio',
        tr: 'Biyografi',
        ar: 'نبذة',
      );
  String get saveProfile => _pick(
        en: 'Save profile',
        tr: 'Profili kaydet',
        ar: 'حفظ الملف الشخصي',
      );
  String get managePreferences => _pick(
        en: 'Manage recovery, notifications, and theme preferences',
        tr: 'Kurtarma, bildirim ve tema tercihlerini yonet',
        ar: 'أدِر الاستعادة والإشعارات وتفضيلات الثيم',
      );
  String get photoUpdatedMessage => _pick(
        en: 'Profile photo updated',
        tr: 'Profil fotografi guncellendi',
        ar: 'تم تحديث صورة الملف الشخصي',
      );
  String achievementTitle(String id) {
    return switch (id) {
      'first-focus' => _pick(
          en: 'Focus Starter',
          tr: 'Odak baslangici',
          ar: 'بداية التركيز',
        ),
      'task-run' => _pick(
          en: 'Task Finisher',
          tr: 'Gorev bitirici',
          ar: 'منهي المهام',
        ),
      'streak' => _pick(
          en: 'Consistency',
          tr: 'Tutarlilik',
          ar: 'الاستمرارية',
        ),
      'habit' => _pick(
          en: 'Ritual Builder',
          tr: 'Rutin kurucu',
          ar: 'باني العادات',
        ),
      _ => _pick(
          en: 'Achievement',
          tr: 'Basari',
          ar: 'إنجاز',
        ),
    };
  }

  String achievementDescription(String id) {
    return switch (id) {
      'first-focus' => _pick(
          en: 'Complete 3 focus sessions',
          tr: '3 odak seansi tamamla',
          ar: 'أكمل 3 جلسات تركيز',
        ),
      'task-run' => _pick(
          en: 'Complete 5 tasks',
          tr: '5 gorev tamamla',
          ar: 'أكمل 5 مهام',
        ),
      'streak' => _pick(
          en: 'Maintain a 4 day streak',
          tr: '4 gunluk seri koru',
          ar: 'حافظ على سلسلة 4 أيام',
        ),
      'habit' => _pick(
          en: 'Complete 3 habits in one day',
          tr: 'Bir gunde 3 aliskanlik tamamla',
          ar: 'أكمل 3 عادات في يوم واحد',
        ),
      _ => _pick(
          en: 'Keep progressing',
          tr: 'Ilerlemeye devam et',
          ar: 'استمر في التقدم',
        ),
    };
  }
}
