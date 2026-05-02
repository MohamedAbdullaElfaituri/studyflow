import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../app/app_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/services/reminder_service.dart';
import '../../core/services/supabase_service.dart';
import '../data/auth_repository.dart';
import '../data/study_repository.dart';
import '../data/supabase_study_repository.dart';
import '../models/app_models.dart';
import '../utils/auth_issue_codes.dart';

final localStorageServiceProvider = Provider<LocalStorageService>(
  (ref) => throw UnimplementedError(),
);

final reminderServiceProvider = Provider<ReminderService>(
  (ref) => throw UnimplementedError(),
);

final notificationPermissionProvider = FutureProvider<bool>((ref) async {
  return ref.watch(reminderServiceProvider).areNotificationsAllowed();
});

final backendModeProvider =
    Provider<BackendMode>((ref) => SupabaseService.backendMode);

final isCloudSyncEnabledProvider = Provider<bool>(
  (ref) => ref.watch(backendModeProvider) == BackendMode.supabase,
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  final isCloudSyncEnabled = ref.watch(isCloudSyncEnabledProvider);
  if (isCloudSyncEnabled) {
    return SupabaseAuthRepository(SupabaseService.client, storage);
  }
  return LocalAuthRepository(storage);
});

final studyRepositoryProvider = Provider<StudyRepository>((ref) {
  final isCloudSyncEnabled = ref.watch(isCloudSyncEnabledProvider);
  if (isCloudSyncEnabled) {
    return SupabaseStudyRepository(SupabaseService.client);
  }
  return LocalStudyRepository(ref.watch(localStorageServiceProvider));
});

class AppLocalePreferenceController extends Notifier<String?> {
  @override
  String? build() {
    return _normalizeLocaleCode(
      ref
          .watch(localStorageServiceProvider)
          .readString(AppConstants.localePreferenceKey),
    );
  }

  Future<void> setLocale(String code) async {
    final normalized = _normalizeLocaleCode(code);
    state = normalized;
    await ref
        .read(localStorageServiceProvider)
        .writeString(AppConstants.localePreferenceKey, normalized);
  }
}

final appLocalePreferenceProvider =
    NotifierProvider<AppLocalePreferenceController, String?>(
  AppLocalePreferenceController.new,
);

class AppThemePreferenceController extends Notifier<String?> {
  @override
  String? build() {
    return _normalizeThemePreference(
      ref
          .watch(localStorageServiceProvider)
          .readString(AppConstants.themePreferenceKey),
    );
  }

  Future<void> setTheme(String themeMode) async {
    final normalized = _normalizeThemePreference(themeMode) ?? 'system';
    state = normalized;
    await ref
        .read(localStorageServiceProvider)
        .writeString(AppConstants.themePreferenceKey, normalized);
  }
}

final appThemePreferenceProvider =
    NotifierProvider<AppThemePreferenceController, String?>(
  AppThemePreferenceController.new,
);

class LaunchSplashController extends Notifier<bool> {
  @override
  bool build() => false;

  void complete() {
    if (!state) {
      state = true;
    }
  }
}

final launchSplashCompletedProvider =
    NotifierProvider<LaunchSplashController, bool>(
  LaunchSplashController.new,
);

class AuthNavigationController extends Notifier<bool> {
  Timer? _timeout;

  @override
  bool build() {
    ref.onDispose(() => _timeout?.cancel());
    return false;
  }

  void begin({Duration timeout = const Duration(seconds: 35)}) {
    _timeout?.cancel();
    state = true;
    _timeout = Timer(timeout, complete);
  }

  void complete() {
    _timeout?.cancel();
    state = false;
  }
}

final authNavigationProvider = NotifierProvider<AuthNavigationController, bool>(
  AuthNavigationController.new,
);

class AuthNoticeController extends Notifier<String?> {
  @override
  String? build() => null;

  void show(String code) {
    state = code;
  }

  void clear() {
    if (state != null) {
      state = null;
    }
  }
}

final authNoticeProvider = NotifierProvider<AuthNoticeController, String?>(
  AuthNoticeController.new,
);

class AuthViewState {
  const AuthViewState({
    required this.user,
    required this.onboardingCompleted,
    required this.requiresPasswordReset,
  });

  final AppUserModel? user;
  final bool onboardingCompleted;
  final bool requiresPasswordReset;

  bool get isAuthenticated => user != null;
}

class AuthController extends AsyncNotifier<AuthViewState> {
  @override
  Future<AuthViewState> build() async {
    final repository = ref.watch(authRepositoryProvider);
    final studyRepository = ref.watch(studyRepositoryProvider);
    final isCloudSyncEnabled = ref.watch(isCloudSyncEnabledProvider);
    AuthState? initialAuthState;

    if (isCloudSyncEnabled) {
      try {
        initialAuthState =
            await SupabaseService.client.auth.onAuthStateChange.first;
      } catch (error) {
        final noticeCode = authFlowNoticeCodeFrom(error);
        if (noticeCode != null) {
          ref.read(authNoticeProvider.notifier).show(noticeCode);
        }
      }
    }

    if (isCloudSyncEnabled) {
      final subscription = SupabaseService.client.auth.onAuthStateChange.listen(
        (authState) {
          unawaited(_handleAuthStateChange(authState));
        },
        onError: (Object error, StackTrace __) {
          final noticeCode = authFlowNoticeCodeFrom(error);
          if (noticeCode != null) {
            ref.read(authNoticeProvider.notifier).show(noticeCode);
          }
          ref.read(authNavigationProvider.notifier).complete();
        },
      );
      ref.onDispose(subscription.cancel);
    }

    final onboardingCompleted = await repository.hasCompletedOnboarding();
    final user = await repository.currentUser();

    if (user != null) {
      await studyRepository.ensureSeeded(user);
    }

    return AuthViewState(
      user: user,
      onboardingCompleted: onboardingCompleted,
      requiresPasswordReset:
          initialAuthState?.event == AuthChangeEvent.passwordRecovery,
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    ref.read(authNoticeProvider.notifier).clear();
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.signIn(email: email, password: password);
      await _setAuthenticatedUser(user);
    } catch (_) {
      rethrow;
    }
  }

  Future<AuthSignUpResult> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    ref.read(authNoticeProvider.notifier).clear();
    try {
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );

      final user = result.user;
      if (user != null) {
        await _setAuthenticatedUser(user);
      }

      return result;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    ref.read(authNoticeProvider.notifier).clear();
    ref.read(authNavigationProvider.notifier).complete();
    final repository = ref.read(authRepositoryProvider);
    await repository.signOut();
    await _setSignedOutState();
  }

  Future<void> completeOnboarding() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.completeOnboarding();
    final current = state.valueOrNull;
    state = AsyncData(
      AuthViewState(
        user: current?.user,
        onboardingCompleted: true,
        requiresPasswordReset: current?.requiresPasswordReset ?? false,
      ),
    );
  }

  Future<void> sendPasswordReset(String email) async {
    ref.read(authNoticeProvider.notifier).clear();
    await ref.read(authRepositoryProvider).sendPasswordReset(email);
  }

  Future<void> signInWithGoogle() async {
    ref.read(authNoticeProvider.notifier).clear();
    ref.read(authNavigationProvider.notifier).begin();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signInWithGoogle();

      if (!ref.read(isCloudSyncEnabledProvider)) {
        final user = await repository.currentUser();
        if (user != null) {
          await _setAuthenticatedUser(user);
          return;
        }
        ref.read(authNavigationProvider.notifier).complete();
      }
    } catch (_) {
      ref.read(authNavigationProvider.notifier).complete();
      rethrow;
    }
  }

  Future<void> signInWithDemo() async {
    ref.read(authNoticeProvider.notifier).clear();
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.signInWithDemo();
      await _setAuthenticatedUser(user);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updatePassword(String password) async {
    ref.read(authNoticeProvider.notifier).clear();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.updatePassword(password: password);
      final user = await repository.currentUser();
      if (user == null) {
        throw const AppException('missing_user');
      }
      await _setAuthenticatedUser(user);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateProfile(AppUserModel user) async {
    final repository = ref.read(authRepositoryProvider);
    final updated = await repository.updateProfile(user);
    final onboardingCompleted = state.valueOrNull?.onboardingCompleted ?? true;
    state = AsyncData(
      AuthViewState(
        user: updated,
        onboardingCompleted: onboardingCompleted,
        requiresPasswordReset:
            state.valueOrNull?.requiresPasswordReset ?? false,
      ),
    );
  }

  Future<void> uploadAvatar(String filePath) async {
    final repository = ref.read(authRepositoryProvider);
    final current = state.valueOrNull;
    final user = current?.user;
    if (user == null) {
      return;
    }

    final updated = await repository.uploadAvatar(
      user: user,
      filePath: filePath,
    );
    state = AsyncData(
      AuthViewState(
        user: updated,
        onboardingCompleted: current?.onboardingCompleted ?? true,
        requiresPasswordReset: current?.requiresPasswordReset ?? false,
      ),
    );
  }

  Future<void> deleteAvatar() async {
    final repository = ref.read(authRepositoryProvider);
    final current = state.valueOrNull;
    final user = current?.user;
    if (user == null) {
      return;
    }

    final updated = await repository.deleteAvatar(user);
    state = AsyncData(
      AuthViewState(
        user: updated,
        onboardingCompleted: current?.onboardingCompleted ?? true,
        requiresPasswordReset: current?.requiresPasswordReset ?? false,
      ),
    );
  }

  Future<void> _handleAuthStateChange(AuthState authState) async {
    try {
      if (authState.event == AuthChangeEvent.signedOut ||
          authState.session?.user == null) {
        ref.read(authNavigationProvider.notifier).complete();
        await _setSignedOutState();
        return;
      }

      final repository = ref.read(authRepositoryProvider);
      final user = await repository.currentUser();
      if (user == null) {
        ref.read(authNavigationProvider.notifier).complete();
        await _setSignedOutState();
        return;
      }

      await _setAuthenticatedUser(
        user,
        requiresPasswordReset:
            authState.event == AuthChangeEvent.passwordRecovery,
      );
    } catch (error, stackTrace) {
      if (!state.hasValue) {
        state = AsyncError(error, stackTrace);
      }
    }
  }

  Future<void> _setAuthenticatedUser(
    AppUserModel user, {
    bool requiresPasswordReset = false,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    final studyRepository = ref.read(studyRepositoryProvider);
    var onboardingCompleted = await repository.hasCompletedOnboarding();

    if (!onboardingCompleted) {
      await repository.completeOnboarding();
      onboardingCompleted = true;
    }

    await studyRepository.ensureSeeded(user);

    state = AsyncData(
      AuthViewState(
        user: user,
        onboardingCompleted: onboardingCompleted,
        requiresPasswordReset: requiresPasswordReset,
      ),
    );
    ref.read(authNavigationProvider.notifier).complete();
  }

  Future<void> _setSignedOutState() async {
    final onboardingCompleted =
        await ref.read(authRepositoryProvider).hasCompletedOnboarding();
    state = AsyncData(
      AuthViewState(
        user: null,
        onboardingCompleted: onboardingCompleted,
        requiresPasswordReset: false,
      ),
    );
    ref.read(authNavigationProvider.notifier).complete();
  }

  Future<void> removeAvatar() async {
    await deleteAvatar();
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthViewState>(AuthController.new);

class GoRouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final goRouterRefreshNotifierProvider =
    Provider<GoRouterRefreshNotifier>((ref) {
  final notifier = GoRouterRefreshNotifier();
  ref.listen<AsyncValue<AuthViewState>>(authControllerProvider, (_, __) {
    notifier.refresh();
  });
  ref.listen<bool>(authNavigationProvider, (_, __) {
    notifier.refresh();
  });
  ref.listen<String?>(authNoticeProvider, (_, __) {
    notifier.refresh();
  });
  ref.listen<bool>(launchSplashCompletedProvider, (_, __) {
    notifier.refresh();
  });
  ref.listen<AsyncValue<StudyDataState>>(studyDataControllerProvider, (_, __) {
    notifier.refresh();
  });
  ref.onDispose(notifier.dispose);
  return notifier;
});

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(goRouterRefreshNotifierProvider);
  return AppRouter.build(ref, refreshNotifier);
});

class StudyDataState {
  const StudyDataState({
    required this.courses,
    required this.tasks,
    required this.notes,
    required this.exams,
    required this.habits,
    required this.sessions,
    required this.goals,
    required this.settings,
    required this.reminders,
  });

  final List<CourseModel> courses;
  final List<TaskModel> tasks;
  final List<NoteModel> notes;
  final List<ExamModel> exams;
  final List<HabitModel> habits;
  final List<StudySessionModel> sessions;
  final GoalSettingsModel goals;
  final UserSettingsModel settings;
  final ReminderPreferencesModel reminders;

  StudyDataState copyWith({
    List<CourseModel>? courses,
    List<TaskModel>? tasks,
    List<NoteModel>? notes,
    List<ExamModel>? exams,
    List<HabitModel>? habits,
    List<StudySessionModel>? sessions,
    GoalSettingsModel? goals,
    UserSettingsModel? settings,
    ReminderPreferencesModel? reminders,
  }) {
    return StudyDataState(
      courses: courses ?? this.courses,
      tasks: tasks ?? this.tasks,
      notes: notes ?? this.notes,
      exams: exams ?? this.exams,
      habits: habits ?? this.habits,
      sessions: sessions ?? this.sessions,
      goals: goals ?? this.goals,
      settings: settings ?? this.settings,
      reminders: reminders ?? this.reminders,
    );
  }

  static StudyDataState empty() {
    final now = DateTime.now();
    return StudyDataState(
      courses: const [],
      tasks: const [],
      notes: const [],
      exams: const [],
      habits: const [],
      sessions: const [],
      goals: GoalSettingsModel(
        id: 'empty',
        userId: '',
        dailyTargetMinutes: 120,
        weeklyTargetMinutes: 600,
        monthlyTargetMinutes: 2400,
        createdAt: now,
        updatedAt: now,
      ),
      settings: UserSettingsModel(
        id: 'empty',
        userId: '',
        languageCode: 'en',
        themeMode: 'system',
        notificationsEnabled: true,
        accessibilityMode: false,
        createdAt: now,
        updatedAt: now,
      ),
      reminders: ReminderPreferencesModel(
        id: 'empty',
        userId: '',
        tasksEnabled: true,
        studyEnabled: true,
        dailyEnabled: false,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  List<TaskModel> get activeTasks => tasks
      .where(
        (item) => !item.isArchived && item.status != TaskStatus.completed,
      )
      .toList()
    ..sort((a, b) => (a.dueDateTime ?? DateTime(3000))
        .compareTo(b.dueDateTime ?? DateTime(3000)));

  List<TaskModel> get completedTasks =>
      tasks.where((item) => item.status == TaskStatus.completed).toList();

  List<TaskModel> get todayTasks {
    final now = DateTime.now();
    return activeTasks
        .where(
          (task) =>
              task.dueDateTime != null &&
              task.dueDateTime!.year == now.year &&
              task.dueDateTime!.month == now.month &&
              task.dueDateTime!.day == now.day,
        )
        .toList();
  }

  List<TaskModel> get upcomingTasks {
    final now = DateTime.now();
    return activeTasks
        .where(
          (task) =>
              task.status != TaskStatus.completed &&
              task.dueDateTime != null &&
              task.dueDateTime!.isAfter(now.subtract(const Duration(hours: 1))),
        )
        .take(5)
        .toList();
  }

  List<NoteModel> get pinnedNotes =>
      notes.where((item) => item.isPinned).toList();

  List<ExamModel> get upcomingExams {
    final now = DateTime.now();
    return exams.where((item) => item.dateTime.isAfter(now)).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<ExamModel> get criticalExams {
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 7));
    return upcomingExams
        .where((item) => item.dateTime.isBefore(threshold))
        .take(4)
        .toList();
  }

  List<HabitModel> get activeHabits =>
      habits.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<HabitModel> get completedHabits =>
      habits.where((item) => item.isCompleted).toList();

  int get dailyStudyMinutes {
    final now = DateTime.now();
    return sessions
        .where(
          (item) =>
              item.startTime.year == now.year &&
              item.startTime.month == now.month &&
              item.startTime.day == now.day,
        )
        .fold(0, (sum, item) => sum + item.durationMinutes);
  }

  int get weeklyStudyMinutes {
    final threshold = DateTime.now().subtract(const Duration(days: 7));
    return sessions
        .where((item) => item.startTime.isAfter(threshold))
        .fold(0, (sum, item) => sum + item.durationMinutes);
  }

  int get monthlyStudyMinutes {
    final now = DateTime.now();
    return sessions
        .where(
          (item) =>
              item.startTime.year == now.year &&
              item.startTime.month == now.month,
        )
        .fold(0, (sum, item) => sum + item.durationMinutes);
  }

  int get streakCount {
    if (sessions.isEmpty) {
      return 0;
    }

    final studyDays = sessions
        .map((session) => DateTime(session.startTime.year,
            session.startTime.month, session.startTime.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    var cursor = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    for (final day in studyDays) {
      if (day == cursor) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else if (day.isBefore(cursor)) {
        break;
      }
    }

    return streak;
  }

  int get totalXp =>
      completedTasks.length * 25 +
      sessions.length * 40 +
      completedHabits.length * 18 +
      upcomingExams
              .where((item) => item.priority == TaskPriority.urgent)
              .length *
          12;

  int get level => (totalXp ~/ 180) + 1;

  double get levelProgress {
    final progress = (totalXp % 180) / 180;
    return progress.clamp(0, 1).toDouble();
  }

  double get habitConsistency {
    if (habits.isEmpty) {
      return 0;
    }
    return completedHabits.length / habits.length;
  }

  CourseModel? courseById(String? id) =>
      courses.firstWhereOrNull((course) => course.id == id);

  TaskModel? taskById(String id) =>
      tasks.firstWhereOrNull((task) => task.id == id);

  NoteModel? noteById(String id) =>
      notes.firstWhereOrNull((note) => note.id == id);

  ExamModel? examById(String id) =>
      exams.firstWhereOrNull((exam) => exam.id == id);

  HabitModel? habitById(String id) =>
      habits.firstWhereOrNull((habit) => habit.id == id);

  List<TaskModel> tasksForCourse(String courseId) =>
      tasks.where((task) => task.courseId == courseId).toList();

  List<NoteModel> notesForCourse(String courseId) =>
      notes.where((note) => note.courseId == courseId).toList();

  List<ExamModel> examsForCourse(String courseId) =>
      exams.where((exam) => exam.courseId == courseId).toList();

  List<StudySessionModel> sessionsForCourse(String courseId) =>
      sessions.where((session) => session.courseId == courseId).toList();

  List<AchievementModel> get achievements => [
        AchievementModel(
          id: 'first-focus',
          title: 'Focus Starter',
          description: 'Complete 3 focus sessions',
          progress: sessions.length,
          target: 3,
          icon: 'timer',
        ),
        AchievementModel(
          id: 'task-run',
          title: 'Task Finisher',
          description: 'Complete 5 tasks',
          progress: completedTasks.length,
          target: 5,
          icon: 'check_circle',
        ),
        AchievementModel(
          id: 'streak',
          title: 'Consistency',
          description: 'Maintain a 4 day streak',
          progress: streakCount,
          target: 4,
          icon: 'local_fire_department',
        ),
        AchievementModel(
          id: 'habit',
          title: 'Ritual Builder',
          description: 'Complete 3 habits in one day',
          progress: completedHabits.length,
          target: 3,
          icon: 'repeat',
        ),
      ];
}

class StudyDataController extends AsyncNotifier<StudyDataState> {
  @override
  Future<StudyDataState> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) {
      return StudyDataState.empty();
    }

    final user = ref.read(currentUserProvider);
    final repository = ref.watch(studyRepositoryProvider);
    if (user != null) {
      await repository.ensureSeeded(user);
    }
    return _load(userId);
  }

  Future<StudyDataState> _load(String userId) async {
    final repository = ref.read(studyRepositoryProvider);
    final results = await Future.wait<dynamic>([
      repository.getCourses(userId),
      repository.getTasks(userId),
      repository.getNotes(userId),
      repository.getExams(userId),
      repository.getHabits(userId),
      repository.getStudySessions(userId),
      repository.getGoals(userId),
      repository.getUserSettings(userId),
      repository.getReminderPreferences(userId),
    ]);

    return StudyDataState(
      courses: results[0] as List<CourseModel>,
      tasks: results[1] as List<TaskModel>,
      notes: results[2] as List<NoteModel>,
      exams: results[3] as List<ExamModel>,
      habits: results[4] as List<HabitModel>,
      sessions: results[5] as List<StudySessionModel>,
      goals: results[6] as GoalSettingsModel,
      settings: results[7] as UserSettingsModel,
      reminders: results[8] as ReminderPreferencesModel,
    );
  }

  Future<void> refresh() async {
    final user = ref.read(authControllerProvider).valueOrNull?.user;
    if (user == null) {
      state = AsyncData(StudyDataState.empty());
      return;
    }

    final previousState = state.valueOrNull;

    try {
      final nextState = await _load(user.id);
      state = AsyncData(nextState);
    } catch (error, stackTrace) {
      if (previousState != null) {
        state = AsyncData(previousState);
      } else {
        state = AsyncError(error, stackTrace);
      }
    }
  }

  Future<void> saveCourse(CourseModel course) async {
    final repository = ref.read(studyRepositoryProvider);
    final user = ref.read(authControllerProvider).valueOrNull?.user;
    await repository.saveCourse(course);
    await _softRefresh(user);
  }

  Future<void> deleteCourse(String courseId) async {
    final user = ref.read(authControllerProvider).valueOrNull?.user;
    if (user == null) return;
    await ref.read(studyRepositoryProvider).deleteCourse(user.id, courseId);
    await _softRefresh(user);
  }

  Future<void> saveTask(TaskModel task) async {
    final user = ref.read(authControllerProvider).valueOrNull?.user;
    await ref.read(studyRepositoryProvider).saveTask(task);
    await _softRefresh(user);
  }

  Future<void> deleteTask(String taskId) async {
    final user = ref.read(authControllerProvider).valueOrNull?.user;
    if (user == null) return;
    await ref.read(studyRepositoryProvider).deleteTask(user.id, taskId);
    await _softRefresh(user);
  }

  Future<void> toggleTaskStatus(TaskModel task) async {
    final next = task.status == TaskStatus.completed
        ? TaskStatus.inProgress
        : TaskStatus.completed;
    await saveTask(
      task.copyWith(
        status: next,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> toggleSubtask(TaskModel task, SubtaskModel subtask) async {
    final updated = task.copyWith(
      subtasks: task.subtasks
          .map(
            (item) => item.id == subtask.id
                ? item.copyWith(isCompleted: !item.isCompleted)
                : item,
          )
          .toList(),
      updatedAt: DateTime.now(),
    );
    await saveTask(updated);
  }

  Future<void> archiveCompletedTasks() async {
    final current = state.valueOrNull;
    final user = ref.read(authControllerProvider).valueOrNull?.user;
    if (current == null) return;

    for (final task
        in current.completedTasks.where((item) => !item.isArchived)) {
      await ref.read(studyRepositoryProvider).saveTask(
            task.copyWith(isArchived: true, updatedAt: DateTime.now()),
          );
    }
    await _softRefresh(user);
  }

  Future<void> saveNote(NoteModel note) async {
    final user = ref.read(authControllerProvider).valueOrNull?.user;
    await ref.read(studyRepositoryProvider).saveNote(note);
    await _softRefresh(user);
  }

  Future<void> deleteNote(String noteId) async {
    final user = ref.read(authControllerProvider).valueOrNull?.user;
    if (user == null) return;
    await ref.read(studyRepositoryProvider).deleteNote(user.id, noteId);
    await _softRefresh(user);
  }

  Future<void> saveExam(ExamModel exam) async {
    final user = ref.read(authControllerProvider).valueOrNull?.user;
    await ref.read(studyRepositoryProvider).saveExam(exam);
    await _softRefresh(user);
  }

  Future<void> deleteExam(String examId) async {
    final user = ref.read(authControllerProvider).valueOrNull?.user;
    if (user == null) return;
    await ref.read(studyRepositoryProvider).deleteExam(user.id, examId);
    await _softRefresh(user);
  }

  Future<void> saveHabit(HabitModel habit) async {
    final user = ref.read(authControllerProvider).valueOrNull?.user;
    await ref.read(studyRepositoryProvider).saveHabit(habit);
    await _softRefresh(user);
  }

  Future<void> deleteHabit(String habitId) async {
    final user = ref.read(authControllerProvider).valueOrNull?.user;
    if (user == null) return;
    await ref.read(studyRepositoryProvider).deleteHabit(user.id, habitId);
    await _softRefresh(user);
  }

  Future<void> completeHabit(HabitModel habit) async {
    final user = ref.read(authControllerProvider).valueOrNull?.user;
    final nextCompleted = habit.completedCount + 1 > habit.goalCount
        ? habit.goalCount
        : habit.completedCount + 1;
    await ref.read(studyRepositoryProvider).saveHabit(
          habit.copyWith(
            completedCount: nextCompleted,
            streakCount: nextCompleted >= habit.goalCount
                ? habit.streakCount + 1
                : habit.streakCount,
            lastCompletedAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
    HapticFeedback.lightImpact();
    await _softRefresh(user);
  }

  Future<void> addStudySession({
    String? courseId,
    String? taskId,
    required int durationMinutes,
  }) async {
    final user = ref.read(authControllerProvider).valueOrNull?.user;
    if (user == null) return;

    final now = DateTime.now();
    final session = StudySessionModel(
      id: const Uuid().v4(),
      userId: user.id,
      taskId: taskId,
      courseId: courseId,
      startTime: now.subtract(Duration(minutes: durationMinutes)),
      endTime: now,
      durationMinutes: durationMinutes,
      createdAt: now,
    );
    await ref.read(studyRepositoryProvider).addStudySession(session);
    HapticFeedback.mediumImpact();
    await _softRefresh(user);
  }

  Future<void> saveGoals(GoalSettingsModel goals) async {
    final user = ref.read(authControllerProvider).valueOrNull?.user;
    await ref.read(studyRepositoryProvider).saveGoals(goals);
    await _softRefresh(user);
  }

  Future<void> updateSettings(UserSettingsModel settings) async {
    final repository = ref.read(studyRepositoryProvider);
    final authRepository = ref.read(authRepositoryProvider);
    final currentUser = ref.read(authControllerProvider).valueOrNull?.user;
    final previousState = state.valueOrNull;
    final previousLocaleCode = ref.read(appLocalePreferenceProvider) ??
        previousState?.settings.languageCode ??
        currentUser?.preferredLanguage ??
        'en';
    final previousThemeMode = ref.read(appThemePreferenceProvider) ??
        previousState?.settings.themeMode ??
        currentUser?.themeMode ??
        'system';

    if (previousState != null) {
      state = AsyncData(previousState.copyWith(settings: settings));
    }

    await ref
        .read(appLocalePreferenceProvider.notifier)
        .setLocale(settings.languageCode);
    await ref
        .read(appThemePreferenceProvider.notifier)
        .setTheme(settings.themeMode);

    try {
      await repository.saveUserSettings(settings);
    } catch (error, stackTrace) {
      if (previousState != null) {
        state = AsyncData(previousState);
      } else {
        state = AsyncError(error, stackTrace);
      }

      await ref
          .read(appLocalePreferenceProvider.notifier)
          .setLocale(previousLocaleCode);
      await ref
          .read(appThemePreferenceProvider.notifier)
          .setTheme(previousThemeMode);
      rethrow;
    }

    if (currentUser != null) {
      await authRepository.updateProfile(
        currentUser.copyWith(
          preferredLanguage: settings.languageCode,
          themeMode: settings.themeMode,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> updateReminders(ReminderPreferencesModel preferences) async {
    final user = ref.read(authControllerProvider).valueOrNull?.user;
    await ref
        .read(studyRepositoryProvider)
        .saveReminderPreferences(preferences);
    await _softRefresh(user);
  }

  Future<void> _softRefresh(AppUserModel? user) async {
    if (user == null) return;
    state = AsyncData(await _load(user.id));
  }
}

final studyDataControllerProvider =
    AsyncNotifierProvider<StudyDataController, StudyDataState>(
  StudyDataController.new,
);

final currentUserProvider = Provider<AppUserModel?>(
  (ref) => ref.watch(
    authControllerProvider.select((value) => value.valueOrNull?.user),
  ),
);

final currentUserIdProvider = Provider<String?>(
  (ref) => ref.watch(
    authControllerProvider.select((value) => value.valueOrNull?.user?.id),
  ),
);

final localeProvider = Provider<Locale?>((ref) {
  final code = _normalizeLocaleCode(ref.watch(appLocalePreferenceProvider));
  return Locale(code);
});

String _normalizeLocaleCode(String? code) {
  return switch (code?.trim().toLowerCase()) {
    'tr' => 'tr',
    'ar' => 'ar',
    _ => 'en',
  };
}

String? _normalizeThemePreference(String? value) {
  return switch (value?.trim().toLowerCase()) {
    'light' => 'light',
    'dark' => 'dark',
    'system' => 'system',
    _ => null,
  };
}

final effectiveThemePreferenceProvider = Provider<String>((ref) {
  return ref.watch(appThemePreferenceProvider) ??
      ref.watch(
        studyDataControllerProvider.select(
          (value) => value.valueOrNull?.settings.themeMode,
        ),
      ) ??
      ref.watch(currentUserProvider)?.themeMode ??
      'system';
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  final theme = ref.watch(effectiveThemePreferenceProvider);
  return switch (theme) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
});

final accessibilityModeProvider = Provider<bool>((ref) {
  return ref.watch(
    studyDataControllerProvider.select(
      (value) => value.valueOrNull?.settings.accessibilityMode ?? false,
    ),
  );
});
