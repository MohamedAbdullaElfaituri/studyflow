import 'dart:async';
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
  Future<AppUserModel> signUp({
    required String fullName,
    required String email,
    required String password,
  });
  Future<AppUserModel> signInWithDemo();
  Future<AppUserModel> signInWithGoogle();
  Future<void> signOut();
  Future<void> sendPasswordReset(String email);
  Future<AppUserModel> updateProfile(AppUserModel user);
  Future<AppUserModel> uploadAvatar({
    required AppUserModel user,
    required String filePath,
  });
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
    final credential = _credentials.cast<AuthCredentialModel?>().firstWhere(
          (item) => item?.email.toLowerCase() == email.trim().toLowerCase(),
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
  Future<AppUserModel> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final hasDuplicate =
        _credentials.any((item) => item.email.toLowerCase() == normalizedEmail);

    if (hasDuplicate) {
      throw const AppException('duplicate_email');
    }

    final now = DateTime.now();
    final preferredLanguage =
        _storage.readString(AppConstants.localePreferenceKey) ?? 'en';
    final user = AppUserModel(
      id: _uuid.v4(),
      fullName: fullName.trim(),
      email: normalizedEmail,
      avatarUrl: null,
      username: _suggestUsername(fullName, normalizedEmail),
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

    return user;
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

    return signUp(
      fullName: 'StudyFlow Student',
      email: AppConstants.demoEmail,
      password: AppConstants.demoPassword,
    );
  }

  @override
  Future<void> signOut() async {
    await _storage.remove(AppConstants.authSessionKey);
  }

  @override
  Future<AppUserModel> signInWithGoogle() async {
    return signInWithDemo();
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    final exists = _credentials.any(
      (item) => item.email.toLowerCase() == email.trim().toLowerCase(),
    );

    if (!exists) {
      throw const AppException('user_not_found');
    }
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
    final stored =
        decodeCollection(_storage.readString(AppConstants.authCredentialsKey))
            .map(AuthCredentialModel.fromJson)
            .toList();
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

    return _fetchProfile(user);
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
      email: email.trim(),
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const AppException('invalid_credentials');
    }

    return _fetchProfile(user);
  }

  @override
  Future<AppUserModel> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final preferredLanguage =
        _storage.readString(AppConstants.localePreferenceKey) ?? 'en';
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': fullName.trim(),
        'preferred_language': preferredLanguage,
        'theme_mode': 'system',
      },
    );

    final user = response.user;
    if (user == null) {
      throw const AppException('missing_user');
    }

    final now = DateTime.now();
    final profile = AppUserModel(
      id: user.id,
      fullName: fullName.trim(),
      email: email.trim(),
      avatarUrl: null,
      username: _suggestUsername(fullName, email),
      bio: '',
      university: null,
      department: null,
      preferredLanguage: preferredLanguage,
      themeMode: 'system',
      createdAt: now,
      updatedAt: now,
    );

    await _client.from('profiles').upsert(profile.toJson());
    return profile;
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
  Future<AppUserModel> signInWithGoogle() async {
    final launched = await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: AppConstants.supabaseAuthRedirectUrl,
    );

    if (!launched) {
      throw const AppException('missing_user');
    }

    final authState = await _client.auth.onAuthStateChange
        .firstWhere(
          (event) =>
              event.event == AuthChangeEvent.signedIn ||
              event.session?.user != null,
        )
        .timeout(const Duration(minutes: 2));

    final user = authState.session?.user ?? _client.auth.currentUser;
    if (user == null) {
      throw const AppException('missing_user');
    }

    return _fetchProfile(user);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(email.trim());
  }

  @override
  Future<AppUserModel> updateProfile(AppUserModel user) async {
    await _client.from('profiles').upsert(user.toJson());
    return user;
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
    final updated = user.copyWith(
      avatarUrl: publicUrl,
      updatedAt: DateTime.now(),
    );
    await _client.from('profiles').upsert(updated.toJson());
    return updated;
  }

  Future<AppUserModel> _fetchProfile(User user) async {
    final data =
        await _client.from('profiles').select().eq('id', user.id).maybeSingle();

    if (data == null) {
      final now = DateTime.now();
      final created = AppUserModel(
        id: user.id,
        fullName: (user.userMetadata?['full_name'] as String?) ?? '',
        email: user.email ?? '',
        avatarUrl: null,
        username: _suggestUsername(
          (user.userMetadata?['full_name'] as String?) ?? '',
          user.email ?? '',
        ),
        bio: '',
        university: null,
        department: null,
        preferredLanguage:
            _storage.readString(AppConstants.localePreferenceKey) ?? 'en',
        themeMode: 'system',
        createdAt: now,
        updatedAt: now,
      );
      await _client.from('profiles').upsert(created.toJson());
      return created;
    }

    return AppUserModel.fromJson(Map<String, dynamic>.from(data));
  }
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
