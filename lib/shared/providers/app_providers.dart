import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../app/app_router.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/services/reminder_service.dart';
import '../../core/services/supabase_service.dart';
import '../data/auth_repository.dart';
import '../data/study_repository.dart';
import '../data/supabase_study_repository.dart';
import '../models/app_models.dart';

final localStorageServiceProvider = Provider<LocalStorageService>(
  (ref) => throw UnimplementedError(),
);

final reminderServiceProvider = Provider<ReminderService>(
  (ref) => throw UnimplementedError(),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  if (SupabaseService.isConfigured) {
    return SupabaseAuthRepository(SupabaseService.client, storage);
  }
  return LocalAuthRepository(storage);
});

final studyRepositoryProvider = Provider<StudyRepository>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  if (SupabaseService.isConfigured) {
    return SupabaseStudyRepository(SupabaseService.client);
  }
  return LocalStudyRepository(storage);
});

final routerProvider = Provider<GoRouter>((ref) => AppRouter.build());

class AuthViewState {
  const AuthViewState({
    required this.user,
    required this.onboardingCompleted,
  });

  final AppUserModel? user;
  final bool onboardingCompleted;

  bool get isAuthenticated => user != null;
}

class AuthController extends AsyncNotifier<AuthViewState> {
  @override
  Future<AuthViewState> build() async {
    final repository = ref.watch(authRepositoryProvider);
    final user = await repository.currentUser();
    final onboardingCompleted = await repository.hasCompletedOnboarding();
    return AuthViewState(
      user: user,
      onboardingCompleted: onboardingCompleted,
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    final studyRepository = ref.read(studyRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final onboardingCompleted = await repository.hasCompletedOnboarding();
      final user = await repository.signIn(email: email, password: password);
      await studyRepository.ensureSeeded(user);
      return AuthViewState(
        user: user,
        onboardingCompleted: onboardingCompleted,
      );
    });
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    final studyRepository = ref.read(studyRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final onboardingCompleted = await repository.hasCompletedOnboarding();
      final user = await repository.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );
      await studyRepository.ensureSeeded(user);
      return AuthViewState(
        user: user,
        onboardingCompleted: onboardingCompleted,
      );
    });
  }

  Future<void> signOut() async {
    final repository = ref.read(authRepositoryProvider);
    final onboardingCompleted = state.valueOrNull?.onboardingCompleted ?? false;
    await repository.signOut();
    state = AsyncData(
      AuthViewState(user: null, onboardingCompleted: onboardingCompleted),
    );
  }

  Future<void> completeOnboarding() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.completeOnboarding();
    final current = state.valueOrNull;
    state = AsyncData(
      AuthViewState(
        user: current?.user,
        onboardingCompleted: true,
      ),
    );
  }

  Future<void> sendPasswordReset(String email) async {
    await ref.read(authRepositoryProvider).sendPasswordReset(email);
  }

  Future<void> updateProfile(AppUserModel user) async {
    final repository = ref.read(authRepositoryProvider);
    final updated = await repository.updateProfile(user);
    final onboardingCompleted = state.valueOrNull?.onboardingCompleted ?? true;
    state = AsyncData(
      AuthViewState(
        user: updated,
        onboardingCompleted: onboardingCompleted,
      ),
    );
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthViewState>(AuthController.new);

class StudyDataState {
  const StudyDataState({
    required this.courses,
    required this.tasks,
    required this.notes,
    required this.sessions,
    required this.goals,
    required this.settings,
    required this.reminders,
  });

  final List<CourseModel> courses;
  final List<TaskModel> tasks;
  final List<NoteModel> notes;
  final List<StudySessionModel> sessions;
  final GoalSettingsModel goals;
  final UserSettingsModel settings;
  final ReminderPreferencesModel reminders;

  static StudyDataState empty() {
    final now = DateTime.now();
    return StudyDataState(
      courses: const [],
      tasks: const [],
      notes: const [],
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

  List<TaskModel> get activeTasks =>
      tasks.where((item) => !item.isArchived).toList()
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

  List<NoteModel> get pinnedNotes => notes.where((item) => item.isPinned).toList();

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
        .map((session) => DateTime(session.startTime.year, session.startTime.month,
            session.startTime.day))
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

  CourseModel? courseById(String? id) =>
      courses.firstWhereOrNull((course) => course.id == id);

  TaskModel? taskById(String id) => tasks.firstWhereOrNull((task) => task.id == id);

  NoteModel? noteById(String id) => notes.firstWhereOrNull((note) => note.id == id);

  List<TaskModel> tasksForCourse(String courseId) =>
      tasks.where((task) => task.courseId == courseId).toList();

  List<NoteModel> notesForCourse(String courseId) =>
      notes.where((note) => note.courseId == courseId).toList();

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
      ];
}

class StudyDataController extends AsyncNotifier<StudyDataState> {
  @override
  Future<StudyDataState> build() async {
    final user = ref.watch(authControllerProvider).valueOrNull?.user;
    if (user == null) {
      return StudyDataState.empty();
    }

    final repository = ref.watch(studyRepositoryProvider);
    await repository.ensureSeeded(user);
    return _load(user.id);
  }

  Future<StudyDataState> _load(String userId) async {
    final repository = ref.read(studyRepositoryProvider);
    final results = await Future.wait<dynamic>([
      repository.getCourses(userId),
      repository.getTasks(userId),
      repository.getNotes(userId),
      repository.getStudySessions(userId),
      repository.getGoals(userId),
      repository.getUserSettings(userId),
      repository.getReminderPreferences(userId),
    ]);

    return StudyDataState(
      courses: results[0] as List<CourseModel>,
      tasks: results[1] as List<TaskModel>,
      notes: results[2] as List<NoteModel>,
      sessions: results[3] as List<StudySessionModel>,
      goals: results[4] as GoalSettingsModel,
      settings: results[5] as UserSettingsModel,
      reminders: results[6] as ReminderPreferencesModel,
    );
  }

  Future<void> refresh() async {
    final user = ref.read(authControllerProvider).valueOrNull?.user;
    if (user == null) {
      state = AsyncData(StudyDataState.empty());
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(user.id));
  }

  Future<void> saveCourse(CourseModel course) async {
    final repository = ref.read(studyRepositoryProvider);
    await repository.saveCourse(course);
    await _softRefresh();
  }

  Future<void> deleteCourse(String courseId) async {
    final user = _currentUser;
    if (user == null) return;
    await ref.read(studyRepositoryProvider).deleteCourse(user.id, courseId);
    await _softRefresh();
  }

  Future<void> saveTask(TaskModel task) async {
    await ref.read(studyRepositoryProvider).saveTask(task);
    await _softRefresh();
  }

  Future<void> deleteTask(String taskId) async {
    final user = _currentUser;
    if (user == null) return;
    await ref.read(studyRepositoryProvider).deleteTask(user.id, taskId);
    await _softRefresh();
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
    if (current == null) return;

    for (final task in current.completedTasks.where((item) => !item.isArchived)) {
      await ref.read(studyRepositoryProvider).saveTask(
            task.copyWith(isArchived: true, updatedAt: DateTime.now()),
          );
    }
    await _softRefresh();
  }

  Future<void> saveNote(NoteModel note) async {
    await ref.read(studyRepositoryProvider).saveNote(note);
    await _softRefresh();
  }

  Future<void> deleteNote(String noteId) async {
    final user = _currentUser;
    if (user == null) return;
    await ref.read(studyRepositoryProvider).deleteNote(user.id, noteId);
    await _softRefresh();
  }

  Future<void> addStudySession({
    String? courseId,
    String? taskId,
    required int durationMinutes,
  }) async {
    final user = _currentUser;
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
    await _softRefresh();
  }

  Future<void> saveGoals(GoalSettingsModel goals) async {
    await ref.read(studyRepositoryProvider).saveGoals(goals);
    await _softRefresh();
  }

  Future<void> updateSettings(UserSettingsModel settings) async {
    final repository = ref.read(studyRepositoryProvider);
    final authState = ref.read(authControllerProvider).valueOrNull;
    await repository.saveUserSettings(settings);

    if (authState?.user != null) {
      await ref.read(authControllerProvider.notifier).updateProfile(
            authState!.user!.copyWith(
              preferredLanguage: settings.languageCode,
              themeMode: settings.themeMode,
              updatedAt: DateTime.now(),
            ),
          );
    }

    await _softRefresh();
  }

  Future<void> updateReminders(ReminderPreferencesModel preferences) async {
    await ref.read(studyRepositoryProvider).saveReminderPreferences(preferences);
    await _softRefresh();
  }

  AppUserModel? get _currentUser =>
      ref.read(authControllerProvider).valueOrNull?.user;

  Future<void> _softRefresh() async {
    final user = _currentUser;
    if (user == null) return;
    state = AsyncData(await _load(user.id));
  }
}

final studyDataControllerProvider =
    AsyncNotifierProvider<StudyDataController, StudyDataState>(
  StudyDataController.new,
);

final currentUserProvider = Provider<AppUserModel?>(
  (ref) => ref.watch(authControllerProvider).valueOrNull?.user,
);

final localeProvider = Provider<Locale?>((ref) {
  final data = ref.watch(studyDataControllerProvider).valueOrNull;
  final code =
      data?.settings.languageCode ?? ref.watch(currentUserProvider)?.preferredLanguage;
  if (code == null || code.isEmpty) {
    return null;
  }
  return Locale(code);
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  final theme =
      ref.watch(studyDataControllerProvider).valueOrNull?.settings.themeMode ??
          ref.watch(currentUserProvider)?.themeMode ??
          'system';
  return switch (theme) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
});
