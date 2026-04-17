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

    final isCompact = MediaQuery.sizeOf(context).width < 420;

    return AppPage(
      child: ListView(
        children: [
          PageHeader(
            title: context.l10n.editProfileTitle,
            subtitle: copy.managePreferences,
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            child: Column(
              children: [
                _ProfileAvatar(user: user, radius: 46),
                const SizedBox(height: AppSpacing.md),
                Text(
                  copy.profilePhoto,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  copy.uploadHint,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (isCompact)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.tonal(
                        onPressed: _uploadingAvatar ? null : _pickAvatar,
                        child: Text(
                          user.avatarUrl?.isEmpty != false
                              ? copy.uploadPhoto
                              : copy.changePhoto,
                        ),
                      ),
                      if (user.avatarUrl?.isEmpty == false) ...[
                        const SizedBox(height: AppSpacing.sm),
                        OutlinedButton(
                          onPressed: _removingAvatar ? null : _deleteAvatar,
                          child: Text(copy.deletePhoto),
                        ),
                      ],
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: _uploadingAvatar ? null : _pickAvatar,
                          child: Text(
                            user.avatarUrl?.isEmpty != false
                                ? copy.uploadPhoto
                                : copy.changePhoto,
                          ),
                        ),
                      ),
                      if (user.avatarUrl?.isEmpty == false) ...[
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _removingAvatar ? null : _deleteAvatar,
                            child: Text(copy.deletePhoto),
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionCard(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (isCompact)
                    Column(
                      children: [
                        _buildTextField(
                          controller: _firstNameController,
                          label: copy.firstName,
                          icon: Icons.person_outline_rounded,
                          validator: (value) => context.validationMessage(
                            Validators.requiredField(value),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildTextField(
                          controller: _lastNameController,
                          label: copy.lastName,
                          icon: Icons.badge_outlined,
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _firstNameController,
                            label: copy.firstName,
                            icon: Icons.person_outline_rounded,
                            validator: (value) => context.validationMessage(
                              Validators.requiredField(value),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildTextField(
                            controller: _lastNameController,
                            label: copy.lastName,
                            icon: Icons.badge_outlined,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(
                    controller: _usernameController,
                    label: copy.username,
                    icon: Icons.alternate_email_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    initialValue: user.email,
                    readOnly: true,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      labelText: copy.email,
                      prefixIcon: const Icon(Icons.mail_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(
                    controller: _bioController,
                    label: copy.bio,
                    icon: Icons.notes_rounded,
                    minLines: 3,
                    maxLines: 5,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (isCompact)
                    Column(
                      children: [
                        _buildTextField(
                          controller: _departmentController,
                          label: copy.department,
                          icon: Icons.menu_book_outlined,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildTextField(
                          controller: _universityController,
                          label: copy.university,
                          icon: Icons.school_outlined,
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _departmentController,
                            label: copy.department,
                            icon: Icons.menu_book_outlined,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildTextField(
                            controller: _universityController,
                            label: copy.university,
                            icon: Icons.school_outlined,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: _isBusy ? null : () => _saveProfile(user),
            child: _savingProfile
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : Text(context.l10n.saveProfileAction),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  Future<void> _saveProfile(AppUserModel user) async {
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
      context.showSuccessNotification(
          ProfileCopy.of(context).profileUpdatedSuccessfully);
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

  Future<void> _pickAvatar() async {
    if (_isBusy) {
      return;
    }

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
      context
          .showSuccessNotification(ProfileCopy.of(context).photoUpdatedMessage);
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

  Future<void> _deleteAvatar() async {
    if (_isBusy) {
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null || user.avatarUrl?.isEmpty != false) {
      return;
    }

    setState(() => _removingAvatar = true);
    try {
      await ref.read(authControllerProvider.notifier).removeAvatar();
      if (!mounted) {
        return;
      }
      context
          .showSuccessNotification(ProfileCopy.of(context).photoRemovedMessage);
    } catch (error) {
      if (!mounted) {
        return;
      }
      context.showErrorNotification(context.resolveError(error));
    } finally {
      if (mounted) {
        setState(() => _removingAvatar = false);
      }
    }
  }
}

(String, String) _splitName(String fullName) {
  final normalized = fullName.trim();
  if (normalized.isEmpty) {
    return ('', '');
  }

  final parts = normalized.split(RegExp(r'\s+'));
  if (parts.length == 1) {
    return (parts.first, '');
  }
  return (parts.first, parts.sublist(1).join(' '));
}

String? _normalizedValue(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
