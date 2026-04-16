// ignore_for_file: unused_element

part of 'profile_screens.dart';

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
  bool _removingAvatar = false;
  bool _savingProfile = false;

  bool get _isBusy => _uploadingAvatar || _removingAvatar || _savingProfile;

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
          final useTwoColumns = constraints.maxWidth >= 720;
          final horizontalPadding = constraints.maxWidth >= 960
              ? AppSpacing.xxxl
              : (constraints.maxWidth >= 680 ? AppSpacing.xxl : AppSpacing.lg);
          final verticalPadding =
              constraints.maxHeight < 760 ? AppSpacing.lg : AppSpacing.xxl;

          final saveButton = FilledButton(
            onPressed: _isBusy ? null : () => _saveProfile(context, user),
            style: FilledButton.styleFrom(
              minimumSize: Size(
                useTwoColumns ? 220 : double.infinity,
                56,
              ),
            ),
            child: _BusyButtonLabel(
              isBusy: _savingProfile,
              label: copy.saveProfile,
              busyLabel: copy.savingProfile,
            ),
          );

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: useTwoColumns ? 880 : 760,
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        RevealOnBuild(
                          child: _EditProfileTopBar(copy: copy),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        RevealOnBuild(
                          delay: const Duration(milliseconds: 80),
                          child: _EditProfileSummaryCard(
                            user: user,
                            copy: copy,
                            uploadingAvatar: _uploadingAvatar,
                            removingAvatar: _removingAvatar,
                            onPickAvatar:
                                _isBusy ? null : () => _pickAvatar(context),
                            onDeleteAvatar:
                                _isBusy ? null : () => _deleteAvatar(context),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        RevealOnBuild(
                          delay: const Duration(milliseconds: 140),
                          child: _EditProfileSectionCard(
                            icon: Icons.badge_rounded,
                            accent: Theme.of(context).colorScheme.primary,
                            title: copy.coreIdentity,
                            child: Column(
                              children: [
                                LayoutBuilder(
                                  builder: (context, sectionConstraints) {
                                    final twoColumns =
                                        sectionConstraints.maxWidth >= 520;
                                    final firstNameField = TextFormField(
                                      controller: _firstNameController,
                                      textInputAction: TextInputAction.next,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      decoration: _fieldDecoration(
                                        copy.firstName,
                                        Icons.person_outline_rounded,
                                      ),
                                      validator: (value) =>
                                          context.validationMessage(
                                        Validators.requiredField(value),
                                      ),
                                    );
                                    final lastNameField = TextFormField(
                                      controller: _lastNameController,
                                      textInputAction: TextInputAction.next,
                                      textCapitalization:
                                          TextCapitalization.words,
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
                                const SizedBox(height: AppSpacing.md),
                                _ReadOnlyProfileField(
                                  label: copy.email,
                                  value: user.email,
                                  icon: Icons.mail_outline_rounded,
                                  forceLtr: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        RevealOnBuild(
                          delay: const Duration(milliseconds: 200),
                          child: _EditProfileSectionCard(
                            icon: Icons.edit_note_rounded,
                            accent: Theme.of(context).colorScheme.secondary,
                            title: copy.bio,
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
                          delay: const Duration(milliseconds: 260),
                          child: _EditProfileSectionCard(
                            icon: Icons.school_rounded,
                            accent: Theme.of(context).colorScheme.tertiary,
                            title: copy.academicContext,
                            child: LayoutBuilder(
                              builder: (context, sectionConstraints) {
                                final twoColumns =
                                    sectionConstraints.maxWidth >= 520;
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
                          delay: const Duration(milliseconds: 320),
                          child: SectionCard(
                            child: Align(
                              alignment: useTwoColumns
                                  ? Alignment.centerRight
                                  : Alignment.center,
                              child: saveButton,
                            ),
                          ),
                        ),
                      ],
                    ),
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

    final copy = ProfileCopy.of(context);
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
      showSuccessNotificationWithAnimation(
        context,
        message: copy.profileUpdatedSuccessfully,
      );
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          context.pop();
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      showErrorNotificationWithAnimation(
        context,
        message: context.resolveError(error),
      );
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
      showSuccessNotificationWithAnimation(
        context,
        message: copy.photoUpdatedMessage,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      showErrorNotificationWithAnimation(
        context,
        message: context.resolveError(error),
      );
    } finally {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
      }
    }
  }

  Future<void> _deleteAvatar(BuildContext context) async {
    if (_isBusy) {
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null || user.avatarUrl?.isEmpty != false) {
      return;
    }

    FocusScope.of(context).unfocus();
    final copy = ProfileCopy.of(context);

    setState(() => _removingAvatar = true);
    try {
      await ref.read(authControllerProvider.notifier).removeAvatar();
      if (!mounted) {
        return;
      }
      showSuccessNotificationWithAnimation(
        context,
        message: copy.photoRemovedMessage,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      showErrorNotificationWithAnimation(
        context,
        message: context.resolveError(error),
      );
    } finally {
      if (mounted) {
        setState(() => _removingAvatar = false);
      }
    }
  }
}

// Helper to split name
(String, String) _splitName(String fullName) {
  final parts = fullName.split(' ');
  if (parts.length == 1) {
    return (parts[0], '');
  }
  return (parts[0], parts.sublist(1).join(' '));
}

// Normalize value
String _normalizedValue(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? trimmed : trimmed;
}

class _EditProfileTopBar extends StatelessWidget {
  final ProfileCopy copy;

  const _EditProfileTopBar({required this.copy});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              tooltip: 'Back',
            ),
            const SizedBox(width: AppSpacing.md),
            Hero(
              tag: 'profile_logo',
              child: SvgPicture.asset(
                'assets/branding/app_logo.svg',
                height: 48,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const Spacer(),
            Text(
              copy.editProfile,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 4,
          width: 60,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}

class _EditProfileSummaryCard extends StatelessWidget {
  final AppUserModel user;
  final ProfileCopy copy;
  final bool uploadingAvatar;
  final bool removingAvatar;
  final VoidCallback? onPickAvatar;
  final VoidCallback? onDeleteAvatar;

  const _EditProfileSummaryCard({
    required this.user,
    required this.copy,
    required this.uploadingAvatar,
    required this.removingAvatar,
    required this.onPickAvatar,
    required this.onDeleteAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          _ProfileAvatar(user: user, radius: 48),
          const SizedBox(height: AppSpacing.lg),
          Text(
            copy.profilePhoto,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            copy.uploadHint,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.tonal(
                onPressed: uploadingAvatar ? null : onPickAvatar,
                child: Text(user.avatarUrl?.isEmpty != false
                    ? copy.uploadPhoto
                    : copy.changePhoto),
              ),
              if (user.avatarUrl?.isEmpty == false) ...[
                const SizedBox(width: AppSpacing.md),
                FilledButton.tonal(
                  onPressed: removingAvatar ? null : onDeleteAvatar,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.errorContainer,
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: Text(copy.deletePhoto),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _EditProfileSectionCard extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final Widget child;

  const _EditProfileSectionCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
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

class _BusyButtonLabel extends StatelessWidget {
  final bool isBusy;
  final String label;
  final String busyLabel;

  const _BusyButtonLabel({
    required this.isBusy,
    required this.label,
    required this.busyLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isBusy) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(isBusy ? busyLabel : label),
      ],
    );
  }
}

class _ReadOnlyProfileField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool forceLtr;

  const _ReadOnlyProfileField({
    required this.label,
    required this.value,
    required this.icon,
    this.forceLtr = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      initialValue: value,
      textDirection: forceLtr ? TextDirection.ltr : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
    );
  }
}

void showSuccessNotificationWithAnimation(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Lottie.asset(
              'assets/animations/Success.json',
              repeat: false,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(message),
          ),
        ],
      ),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.green.shade600,
      elevation: 2,
    ),
  );
}

void showErrorNotificationWithAnimation(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Lottie.asset(
              'assets/animations/Error animation.json',
              repeat: true,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(message),
          ),
        ],
      ),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red.shade600,
      elevation: 2,
    ),
  );
}
