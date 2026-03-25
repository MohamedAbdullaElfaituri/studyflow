import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../shared/extensions/build_context_x.dart';
import '../../../shared/providers/app_providers.dart';
import '../../auth/presentation/auth_screens.dart';
import '../../settings/presentation/settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const routePath = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(currentUserProvider);
    final data = ref.watch(studyDataControllerProvider);

    return AppPage(
      child: data.when(
        loading: () => const LoadingColumn(itemCount: 3),
        error: (error, _) => ErrorStateCard(
          message: context.resolveError(error),
          onRetry: () => ref.read(studyDataControllerProvider.notifier).refresh(),
        ),
        data: (studyData) => ListView(
          children: [
            SectionCard(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      ((auth?.fullName.isNotEmpty ?? false)
                              ? auth!.fullName.trim()[0]
                              : 'S')
                          .toUpperCase(),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    auth?.fullName ?? context.l10n.profileFallbackName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(auth?.email ?? ''),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.tonal(
                    onPressed: () => context.push(ProfileEditScreen.routePath),
                    child: Text(context.l10n.editProfileAction),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(
              title: context.l10n.profileOverviewTitle,
              subtitle: context.l10n.profileOverviewSubtitle,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: MetricTile(
                    label: context.l10n.coursesTitle,
                    value: '${studyData.courses.length}',
                    icon: Icons.menu_book_rounded,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: MetricTile(
                    label: context.l10n.notesTitle,
                    value: '${studyData.notes.length}',
                    icon: Icons.note_alt_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: MetricTile(
                    label: context.l10n.streakLabel,
                    value: '${studyData.streakCount}',
                    icon: Icons.local_fire_department_rounded,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: MetricTile(
                    label: context.l10n.focusHistoryTitle,
                    value: '${studyData.sessions.length}',
                    icon: Icons.timer_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.settings_outlined),
                    title: Text(context.l10n.settingsTitle),
                    onTap: () => context.push(SettingsScreen.routePath),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout_rounded),
                    title: Text(context.l10n.logoutAction),
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
          ],
        ),
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
  final _nameController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (!_initialized && user != null) {
      _initialized = true;
      _nameController.text = user.fullName;
    }

    return AppPage(
      child: ListView(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: Navigator.of(context).pop,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.l10n.editProfileTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration:
                        InputDecoration(labelText: context.l10n.fullNameLabel),
                    validator: (value) => context.validationMessage(
                      Validators.requiredField(value),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate() || user == null) {
                        return;
                      }
                      await ref.read(authControllerProvider.notifier).updateProfile(
                            user.copyWith(
                              fullName: _nameController.text.trim(),
                              updatedAt: DateTime.now(),
                            ),
                          );
                      if (!mounted) return;
                      Navigator.of(context).pop();
                    },
                    child: Text(context.l10n.saveProfileAction),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
