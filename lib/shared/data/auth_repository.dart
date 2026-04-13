import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/services/local_storage_service.dart';
import '../models/app_models.dart';

abstract class AuthRepository {
  Future<AppUserModel?> currentUser();
  Future<bool> hasCompletedOnboarding();
  Future<void> completeOnboarding();
  Future<AppUserModel> signIn({
    required String email,
    required String password,
  });
  Future<AuthSignUpResult> signUp({
    required String fullName,
    required String email,
    required String password,
  });
  Future<AppUserModel> signInWithDemo();
  Future<void> signInWithGoogle();
  Future<void> signOut();
  Future<void> sendPasswordReset(String email);
  Future<void> updatePassword({required String password});
  Future<AppUserModel> updateProfile(AppUserModel user);
  Future<AppUserModel> uploadAvatar({
    required AppUserModel user,
    required String filePath,
  });
}

class AuthSignUpResult {
  const AuthSignUpResult._({
    required this.email,
    required this.requiresEmailConfirmation,
    this.user,
  });

  AuthSignUpResult.authenticated(AppUserModel user)
      : this._(
          email: user.email,
          requiresEmailConfirmation: false,
          user: user,
        );

  const AuthSignUpResult.emailConfirmationRequired({
    required String email,
  }) : this._(
          email: email,
          requiresEmailConfirmation: true,
        );

  final String email;
  final bool requiresEmailConfirmation;
  final AppUserModel? user;
}

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._storage);

  final LocalStorageService _storage;
  final Uuid _uuid = const Uuid();
  static const _demoUserId = 'demo-studyflow-user';

  @override
  Future<AppUserModel?> currentUser() async {
    final userId = _storage.readString(AppConstants.authSessionKey);
    if (userId == null) {
      return null;
    }

    return _profiles.cast<AppUserModel?>().firstWhere(
          (profile) => profile?.id == userId,
          orElse: () => null,
        );
  }

  @override
  Future<bool> hasCompletedOnboarding() async {
    return _storage.readBool(AppConstants.onboardingKey) ?? false;
  }

  @override
  Future<void> completeOnboarding() async {
    await _storage.writeBool(AppConstants.onboardingKey, true);
  }

  @override
  Future<AppUserModel> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final credential = _credentials.cast<AuthCredentialModel?>().firstWhere(
          (item) => item?.email.toLowerCase() == normalizedEmail,
          orElse: () => null,
        );

    if (credential == null) {
      throw const AppException('user_not_found');
    }

    if (credential.password != password) {
      throw const AppException('invalid_credentials');
    }

    await _storage.writeString(AppConstants.authSessionKey, credential.userId);

    return _profiles.firstWhere((profile) => profile.id == credential.userId);
  }

  @override
  Future<AuthSignUpResult> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final hasDuplicate =
        _credentials.any((item) => item.email.toLowerCase() == normalizedEmail);

    if (hasDuplicate) {
      throw const AppException('duplicate_email');
    }

    final now = DateTime.now();
    final preferredLanguage =
        _storage.readString(AppConstants.localePreferenceKey) ?? 'en';
    final trimmedFullName = fullName.trim();
    final user = AppUserModel(
      id: _uuid.v4(),
      fullName: trimmedFullName,
      email: normalizedEmail,
      avatarUrl: null,
      username: _suggestUsername(trimmedFullName, normalizedEmail),
      bio: '',
      university: null,
      department: null,
      preferredLanguage: preferredLanguage,
      themeMode: 'system',
      createdAt: now,
      updatedAt: now,
    );

    final credentials = [
      ..._credentials,
      AuthCredentialModel(
        userId: user.id,
        email: normalizedEmail,
        password: password,
      ),
    ];
    final profiles = [..._profiles, user];

    await _writeProfiles(profiles);
    await _writeCredentials(credentials);
    await _storage.writeString(AppConstants.authSessionKey, user.id);

    return AuthSignUpResult.authenticated(user);
  }

  @override
  Future<AppUserModel> signInWithDemo() async {
    final demoUser = _profiles.cast<AppUserModel?>().firstWhere(
          (profile) =>
              profile?.email.toLowerCase() ==
              AppConstants.demoEmail.toLowerCase(),
          orElse: () => null,
        );

    if (demoUser != null) {
      await _storage.writeString(AppConstants.authSessionKey, demoUser.id);
      return demoUser;
    }

    final result = await signUp(
      fullName: 'StudyFlow Student',
      email: AppConstants.demoEmail,
      password: AppConstants.demoPassword,
    );
    return result.user!;
  }

  @override
  Future<void> signOut() async {
    await _storage.remove(AppConstants.authSessionKey);
  }

  @override
  Future<void> signInWithGoogle() async {
    await signInWithDemo();
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    final normalizedEmail = _normalizeEmail(email);
    final exists =
        _credentials.any((item) => item.email.toLowerCase() == normalizedEmail);

    if (!exists) {
      throw const AppException('user_not_found');
    }
  }

  @override
  Future<void> updatePassword({required String password}) async {
    final userId = _storage.readString(AppConstants.authSessionKey);
    if (userId == null) {
      throw const AppException('missing_user');
    }

    final credentials = _credentials
        .map(
          (item) => item.userId == userId
              ? AuthCredentialModel(
                  userId: item.userId,
                  email: item.email,
                  password: password,
                )
              : item,
        )
        .toList();

    await _writeCredentials(credentials);
  }

  @override
  Future<AppUserModel> updateProfile(AppUserModel user) async {
    final profiles = _profiles
        .map((profile) => profile.id == user.id ? user : profile)
        .toList();
    await _writeProfiles(profiles);
    return user;
  }

  @override
  Future<AppUserModel> uploadAvatar({
    required AppUserModel user,
    required String filePath,
  }) async {
    final updated = user.copyWith(
      avatarUrl: filePath,
      updatedAt: DateTime.now(),
    );
    return updateProfile(updated);
  }

  List<AppUserModel> get _profiles {
    final stored =
        decodeCollection(_storage.readString(AppConstants.profilesKey))
            .map(AppUserModel.fromJson)
            .toList();
    return stored.isEmpty ? [_demoUser] : stored;
  }

  List<AuthCredentialModel> get _credentials {
    final stored = decodeCollection(
      _storage.readString(AppConstants.authCredentialsKey),
    ).map(AuthCredentialModel.fromJson).toList();
    return stored.isEmpty ? [_demoCredential] : stored;
  }

  AppUserModel get _demoUser {
    final now = DateTime.now();
    return AppUserModel(
      id: _demoUserId,
      fullName: 'StudyFlow Student',
      email: AppConstants.demoEmail,
      avatarUrl: null,
      username: 'studyflow_student',
      bio: 'Designing calm, high-focus study weeks with clean routines.',
      university: 'Istanbul Technical University',
      department: 'Human-Computer Interaction',
      preferredLanguage:
          _storage.readString(AppConstants.localePreferenceKey) ?? 'en',
      themeMode: 'system',
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(days: 1)),
    );
  }

  AuthCredentialModel get _demoCredential => const AuthCredentialModel(
        userId: _demoUserId,
        email: AppConstants.demoEmail,
        password: AppConstants.demoPassword,
      );

  Future<void> _writeProfiles(List<AppUserModel> profiles) async {
    await _storage.writeString(
      AppConstants.profilesKey,
      encodeCollection(profiles.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> _writeCredentials(List<AuthCredentialModel> credentials) async {
    await _storage.writeString(
      AppConstants.authCredentialsKey,
      encodeCollection(credentials.map((item) => item.toJson()).toList()),
    );
  }
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client, this._storage);

  final SupabaseClient _client;
  final LocalStorageService _storage;

  @override
  Future<AppUserModel?> currentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    return _ensureProfile(user);
  }

  @override
  Future<bool> hasCompletedOnboarding() async {
    return _storage.readBool(AppConstants.onboardingKey) ?? false;
  }

  @override
  Future<void> completeOnboarding() async {
    await _storage.writeBool(AppConstants.onboardingKey, true);
  }

  @override
  Future<AppUserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: _normalizeEmail(email),
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const AppException('invalid_credentials');
    }

    return _ensureProfile(user);
  }

  @override
  Future<AuthSignUpResult> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final trimmedFullName = fullName.trim();
    final normalizedEmail = _normalizeEmail(email);
    final preferredLanguage = _normalizeLanguage(
      _storage.readString(AppConstants.localePreferenceKey),
    );

    final response = await _client.auth.signUp(
      email: normalizedEmail,
      password: password,
      data: {
        'full_name': trimmedFullName,
        'username': _suggestUsername(trimmedFullName, normalizedEmail),
        'preferred_language': preferredLanguage,
        'theme_mode': 'system',
      },
    );

    final user = response.user;
    if (user == null) {
      throw const AppException('missing_user');
    }

    if (response.session == null) {
      return AuthSignUpResult.emailConfirmationRequired(
        email: normalizedEmail,
      );
    }

    return AuthSignUpResult.authenticated(await _ensureProfile(user));
  }

  @override
  Future<AppUserModel> signInWithDemo() async {
    throw const AppException('demo_mode_unavailable');
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<void> signInWithGoogle() async {
    final launched = await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: AppConstants.supabaseAuthRedirectUri.toString(),
      queryParams: const {
        'access_type': 'offline',
        'prompt': 'select_account',
      },
    );

    if (!launched) {
      throw const AppException('google_oauth_incomplete');
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(
      _normalizeEmail(email),
      redirectTo: AppConstants.supabaseAuthRedirectUri.toString(),
    );
  }

  @override
  Future<void> updatePassword({required String password}) async {
    if (_client.auth.currentUser == null) {
      throw const AppException('missing_user');
    }

    await _client.auth.updateUser(
      UserAttributes(password: password),
    );
  }

  @override
  Future<AppUserModel> updateProfile(AppUserModel user) async {
    final existingProfile = await _fetchExistingProfile(user.id);
    final normalized = _normalizeProfile(
      user,
      existingProfile: existingProfile,
    );

    await _client.from('profiles').upsert(
          normalized.toJson(),
          onConflict: 'id',
        );
    await _syncAuthMetadata(normalized);

    return normalized;
  }

  @override
  Future<AppUserModel> uploadAvatar({
    required AppUserModel user,
    required String filePath,
  }) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final extension = _fileExtension(filePath);
    final objectPath =
        '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$extension';

    final previousObjectPath = _extractAvatarObjectPath(user.avatarUrl);
    if (previousObjectPath != null) {
      try {
        await _client.storage.from('avatars').remove([previousObjectPath]);
      } catch (_) {}
    }

    await _client.storage.from('avatars').uploadBinary(
          objectPath,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    final publicUrl = _client.storage.from('avatars').getPublicUrl(objectPath);
    final updated = await updateProfile(
      user.copyWith(
        avatarUrl: publicUrl,
        updatedAt: _now(),
      ),
    );

    return updated;
  }

  Future<AppUserModel> _ensureProfile(User user) async {
    final existingProfile = await _fetchExistingProfile(user.id);
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final email = _normalizeEmail(
      user.email ?? _readMetadataString(metadata['email']),
    );
    final fullName = _readMetadataString(metadata['full_name']);
    final preferredLanguageFromMetadata =
        _readMetadataString(metadata['preferred_language']);
    final preferredLanguage = _normalizeLanguage(
      preferredLanguageFromMetadata.isNotEmpty
          ? preferredLanguageFromMetadata
          : _storage.readString(AppConstants.localePreferenceKey),
    );

    final profile = _normalizeProfile(
      AppUserModel(
        id: user.id,
        fullName: fullName,
        email: email,
        avatarUrl: _cleanNullable(_readMetadataString(metadata['avatar_url'])),
        username: _cleanNullable(_readMetadataString(metadata['username'])),
        bio: _readMetadataString(metadata['bio']),
        university: _cleanNullable(_readMetadataString(metadata['university'])),
        department: _cleanNullable(_readMetadataString(metadata['department'])),
        preferredLanguage: preferredLanguage,
        themeMode: _normalizeThemeMode(
          _readMetadataString(metadata['theme_mode']),
        ),
        createdAt: existingProfile?.createdAt ?? _now(),
        updatedAt: _now(),
      ),
      existingProfile: existingProfile,
    );

    await _client.from('profiles').upsert(
          profile.toJson(),
          onConflict: 'id',
        );
    return profile;
  }

  Future<AppUserModel?> _fetchExistingProfile(String userId) async {
    final data =
        await _client.from('profiles').select().eq('id', userId).maybeSingle();
    if (data == null) {
      return null;
    }

    return AppUserModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> _syncAuthMetadata(AppUserModel profile) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null || authUser.id != profile.id) {
      return;
    }

    final data = <String, dynamic>{
      'full_name': profile.fullName,
      'preferred_language': profile.preferredLanguage,
      'theme_mode': profile.themeMode,
      'bio': profile.bio,
      if (profile.username != null) 'username': profile.username,
      if (profile.avatarUrl != null) 'avatar_url': profile.avatarUrl,
      if (profile.university != null) 'university': profile.university,
      if (profile.department != null) 'department': profile.department,
    };

    await _client.auth.updateUser(UserAttributes(data: data));
  }
}

String _normalizeEmail(String email) => email.trim().toLowerCase();

String _readMetadataString(Object? value) {
  if (value is String) {
    return value.trim();
  }
  return '';
}

String? _cleanNullable(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

String _pickValue(String current, String? fallback, {String empty = ''}) {
  final normalizedCurrent = current.trim();
  if (normalizedCurrent.isNotEmpty) {
    return normalizedCurrent;
  }

  final normalizedFallback = fallback?.trim();
  if (normalizedFallback != null && normalizedFallback.isNotEmpty) {
    return normalizedFallback;
  }

  return empty;
}

String _normalizeLanguage(String? value) {
  return switch (value?.trim().toLowerCase()) {
    'tr' => 'tr',
    'ar' => 'ar',
    _ => 'en',
  };
}

String _normalizeThemeMode(String? value) {
  return switch (value?.trim().toLowerCase()) {
    'light' => 'light',
    'dark' => 'dark',
    _ => 'system',
  };
}

DateTime _now() => DateTime.now().toUtc();

AppUserModel _normalizeProfile(
  AppUserModel user, {
  AppUserModel? existingProfile,
}) {
  final normalizedEmail = _normalizeEmail(
    _pickValue(user.email, existingProfile?.email),
  );
  final normalizedFullName =
      _pickValue(user.fullName, existingProfile?.fullName);
  final normalizedBio = _pickValue(user.bio, existingProfile?.bio);
  final normalizedUsername = _cleanNullable(user.username) ??
      _cleanNullable(existingProfile?.username) ??
      _suggestUsername(normalizedFullName, normalizedEmail);

  return AppUserModel(
    id: user.id,
    fullName: normalizedFullName,
    email: normalizedEmail,
    avatarUrl: _cleanNullable(user.avatarUrl) ?? existingProfile?.avatarUrl,
    username: normalizedUsername,
    bio: normalizedBio,
    university: _cleanNullable(user.university) ?? existingProfile?.university,
    department: _cleanNullable(user.department) ?? existingProfile?.department,
    preferredLanguage: _normalizeLanguage(
      _pickValue(
        user.preferredLanguage,
        existingProfile?.preferredLanguage,
        empty: 'en',
      ),
    ),
    themeMode: _normalizeThemeMode(
      _pickValue(
        user.themeMode,
        existingProfile?.themeMode,
        empty: 'system',
      ),
    ),
    createdAt: existingProfile?.createdAt ?? user.createdAt.toUtc(),
    updatedAt: _now(),
  );
}

String _suggestUsername(String fullName, String email) {
  final normalized = fullName
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '.')
      .replaceAll(RegExp(r'\.{2,}'), '.')
      .replaceAll(RegExp(r'^\.|\.$'), '');
  if (normalized.isNotEmpty) {
    return normalized;
  }

  final emailPrefix = email.split('@').first.toLowerCase();
  return emailPrefix.isEmpty ? 'studyflow.user' : emailPrefix;
}

String _fileExtension(String filePath) {
  final segments = filePath.split('.');
  if (segments.length < 2) {
    return 'jpg';
  }
  return segments.last.toLowerCase();
}

String? _extractAvatarObjectPath(String? avatarUrl) {
  if (avatarUrl == null || avatarUrl.isEmpty) {
    return null;
  }

  const marker = '/storage/v1/object/public/avatars/';
  final index = avatarUrl.indexOf(marker);
  if (index == -1) {
    return null;
  }

  return avatarUrl.substring(index + marker.length);
}
