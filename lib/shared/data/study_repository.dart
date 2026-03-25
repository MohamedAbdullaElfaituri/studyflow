import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/demo_seed_service.dart';
import '../../core/services/local_storage_service.dart';
import '../models/app_models.dart';

abstract class StudyRepository {
  Future<void> ensureSeeded(AppUserModel user);
  Future<List<CourseModel>> getCourses(String userId);
  Future<void> saveCourse(CourseModel course);
  Future<void> deleteCourse(String userId, String courseId);
  Future<List<TaskModel>> getTasks(String userId);
  Future<void> saveTask(TaskModel task);
  Future<void> deleteTask(String userId, String taskId);
  Future<List<NoteModel>> getNotes(String userId);
  Future<void> saveNote(NoteModel note);
  Future<void> deleteNote(String userId, String noteId);
  Future<List<StudySessionModel>> getStudySessions(String userId);
  Future<void> addStudySession(StudySessionModel session);
  Future<GoalSettingsModel> getGoals(String userId);
  Future<void> saveGoals(GoalSettingsModel goals);
  Future<UserSettingsModel> getUserSettings(String userId);
  Future<void> saveUserSettings(UserSettingsModel settings);
  Future<ReminderPreferencesModel> getReminderPreferences(String userId);
  Future<void> saveReminderPreferences(ReminderPreferencesModel preferences);
}

class LocalStudyRepository implements StudyRepository {
  LocalStudyRepository(this._storage);

  final LocalStorageService _storage;
  final Uuid _uuid = const Uuid();

  @override
  Future<void> ensureSeeded(AppUserModel user) async {
    if (_storage.containsKey(AppConstants.coursesKey(user.id))) {
      return;
    }

    final courses = DemoSeedService.coursesFor(user.id);
    final tasks = DemoSeedService.tasksFor(user.id, courses);
    final notes = DemoSeedService.notesFor(user.id, courses);
    final sessions = DemoSeedService.sessionsFor(user.id, courses, tasks);
    final goals = DemoSeedService.goalsFor(user.id);
    final settings = DemoSeedService.settingsFor(user.id).copyWith(
      languageCode: user.preferredLanguage,
      themeMode: user.themeMode,
    );
    final reminders = DemoSeedService.remindersFor(user.id);

    await _writeCollection(
      AppConstants.coursesKey(user.id),
      courses.map((item) => item.toJson()).toList(),
    );
    await _writeCollection(
      AppConstants.tasksKey(user.id),
      tasks.map((item) => item.toJson()).toList(),
    );
    await _writeCollection(
      AppConstants.notesKey(user.id),
      notes.map((item) => item.toJson()).toList(),
    );
    await _writeCollection(
      AppConstants.sessionsKey(user.id),
      sessions.map((item) => item.toJson()).toList(),
    );
    await _storage.writeString(
      AppConstants.goalsKey(user.id),
      encodeCollection([goals.toJson()]),
    );
    await _storage.writeString(
      AppConstants.settingsKey(user.id),
      encodeCollection([settings.toJson()]),
    );
    await _storage.writeString(
      AppConstants.remindersKey(user.id),
      encodeCollection([reminders.toJson()]),
    );
  }

  @override
  Future<List<CourseModel>> getCourses(String userId) async {
    return _readCollection(AppConstants.coursesKey(userId), CourseModel.fromJson);
  }

  @override
  Future<void> saveCourse(CourseModel course) async {
    final courses = await getCourses(course.userId);
    final updated = _upsert(courses, course, (item) => item.id);
    await _writeCollection(
      AppConstants.coursesKey(course.userId),
      updated.map((item) => item.toJson()).toList(),
    );
  }

  @override
  Future<void> deleteCourse(String userId, String courseId) async {
    final courses =
        (await getCourses(userId)).where((item) => item.id != courseId).toList();
    final tasks = (await getTasks(userId))
        .map(
          (task) => task.courseId == courseId
              ? task.copyWith(courseId: null, updatedAt: DateTime.now())
              : task,
        )
        .toList();
    final notes = (await getNotes(userId))
        .map(
          (note) => note.courseId == courseId
              ? note.copyWith(courseId: null, updatedAt: DateTime.now())
              : note,
        )
        .toList();

    await _writeCollection(
      AppConstants.coursesKey(userId),
      courses.map((item) => item.toJson()).toList(),
    );
    await _writeCollection(
      AppConstants.tasksKey(userId),
      tasks.map((item) => item.toJson()).toList(),
    );
    await _writeCollection(
      AppConstants.notesKey(userId),
      notes.map((item) => item.toJson()).toList(),
    );
  }

  @override
  Future<List<TaskModel>> getTasks(String userId) async {
    return _readCollection(AppConstants.tasksKey(userId), TaskModel.fromJson);
  }

  @override
  Future<void> saveTask(TaskModel task) async {
    final tasks = await getTasks(task.userId);
    final updated = _upsert(tasks, task.withLinkedSubtasks(), (item) => item.id);
    await _writeCollection(
      AppConstants.tasksKey(task.userId),
      updated.map((item) => item.toJson()).toList(),
    );
  }

  @override
  Future<void> deleteTask(String userId, String taskId) async {
    final tasks =
        (await getTasks(userId)).where((item) => item.id != taskId).toList();
    await _writeCollection(
      AppConstants.tasksKey(userId),
      tasks.map((item) => item.toJson()).toList(),
    );
  }

  @override
  Future<List<NoteModel>> getNotes(String userId) async {
    return _readCollection(AppConstants.notesKey(userId), NoteModel.fromJson);
  }

  @override
  Future<void> saveNote(NoteModel note) async {
    final notes = await getNotes(note.userId);
    final updated = _upsert(notes, note, (item) => item.id);
    await _writeCollection(
      AppConstants.notesKey(note.userId),
      updated.map((item) => item.toJson()).toList(),
    );
  }

  @override
  Future<void> deleteNote(String userId, String noteId) async {
    final notes =
        (await getNotes(userId)).where((item) => item.id != noteId).toList();
    await _writeCollection(
      AppConstants.notesKey(userId),
      notes.map((item) => item.toJson()).toList(),
    );
  }

  @override
  Future<List<StudySessionModel>> getStudySessions(String userId) async {
    return _readCollection(
      AppConstants.sessionsKey(userId),
      StudySessionModel.fromJson,
    );
  }

  @override
  Future<void> addStudySession(StudySessionModel session) async {
    final sessions = await getStudySessions(session.userId);
    final updated = [...sessions, session];
    await _writeCollection(
      AppConstants.sessionsKey(session.userId),
      updated.map((item) => item.toJson()).toList(),
    );
  }

  @override
  Future<GoalSettingsModel> getGoals(String userId) async {
    final items =
        _readCollection(AppConstants.goalsKey(userId), GoalSettingsModel.fromJson);
    if (items.isNotEmpty) {
      return items.first;
    }

    return GoalSettingsModel(
      id: _uuid.v4(),
      userId: userId,
      dailyTargetMinutes: 120,
      weeklyTargetMinutes: 600,
      monthlyTargetMinutes: 2400,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> saveGoals(GoalSettingsModel goals) async {
    await _storage.writeString(
      AppConstants.goalsKey(goals.userId),
      encodeCollection([goals.toJson()]),
    );
  }

  @override
  Future<UserSettingsModel> getUserSettings(String userId) async {
    final items = _readCollection(
      AppConstants.settingsKey(userId),
      UserSettingsModel.fromJson,
    );
    if (items.isNotEmpty) {
      return items.first;
    }

    return UserSettingsModel(
      id: _uuid.v4(),
      userId: userId,
      languageCode: 'en',
      themeMode: 'system',
      notificationsEnabled: true,
      accessibilityMode: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> saveUserSettings(UserSettingsModel settings) async {
    await _storage.writeString(
      AppConstants.settingsKey(settings.userId),
      encodeCollection([settings.toJson()]),
    );
  }

  @override
  Future<ReminderPreferencesModel> getReminderPreferences(String userId) async {
    final items = _readCollection(
      AppConstants.remindersKey(userId),
      ReminderPreferencesModel.fromJson,
    );
    if (items.isNotEmpty) {
      return items.first;
    }

    return ReminderPreferencesModel(
      id: _uuid.v4(),
      userId: userId,
      tasksEnabled: true,
      studyEnabled: true,
      dailyEnabled: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> saveReminderPreferences(
    ReminderPreferencesModel preferences,
  ) async {
    await _storage.writeString(
      AppConstants.remindersKey(preferences.userId),
      encodeCollection([preferences.toJson()]),
    );
  }

  List<T> _readCollection<T>(
    String key,
    T Function(Map<String, dynamic>) parser,
  ) {
    return decodeCollection(_storage.readString(key)).map(parser).toList();
  }

  Future<void> _writeCollection(
    String key,
    List<Map<String, dynamic>> collection,
  ) async {
    await _storage.writeString(key, encodeCollection(collection));
  }

  List<T> _upsert<T>(
    List<T> items,
    T value,
    String Function(T item) idOf,
  ) {
    final existingIndex = items.indexWhere((item) => idOf(item) == idOf(value));
    if (existingIndex == -1) {
      return [...items, value];
    }

    final updated = [...items];
    updated[existingIndex] = value;
    return updated;
  }
}
