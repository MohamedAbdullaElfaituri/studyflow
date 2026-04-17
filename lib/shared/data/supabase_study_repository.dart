import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/app_models.dart';
import 'study_repository.dart';

class SupabaseStudyRepository implements StudyRepository {
  SupabaseStudyRepository(this._client);

  final SupabaseClient _client;
  final Uuid _uuid = const Uuid();

  @override
  Future<void> ensureSeeded(AppUserModel user) async {
    await Future.wait<void>([
      _ensureGoals(user.id),
      _ensureReminderPreferences(user.id),
      _ensureUserSettings(user),
    ]);
  }

  @override
  Future<List<CourseModel>> getCourses(String userId) async {
    final data = await _client
        .from('courses')
        .select()
        .eq('user_id', userId)
        .order('created_at');

    return (data as List<dynamic>)
        .map((item) =>
            CourseModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  @override
  Future<void> saveCourse(CourseModel course) async {
    await _client.from('courses').upsert(course.toJson());
  }

  @override
  Future<void> deleteCourse(String userId, String courseId) async {
    await _client
        .from('courses')
        .delete()
        .eq('id', courseId)
        .eq('user_id', userId);
  }

  @override
  Future<List<TaskModel>> getTasks(String userId) async {
    final data = await _client
        .from('tasks')
        .select('*, subtasks(*)')
        .eq('user_id', userId)
        .order('created_at');

    return (data as List<dynamic>)
        .map(
          (item) => TaskModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  @override
  Future<void> saveTask(TaskModel task) async {
    final linkedTask = task.withLinkedSubtasks();

    await _client.from('tasks').upsert({
      'id': linkedTask.id,
      'user_id': linkedTask.userId,
      'course_id': linkedTask.courseId,
      'title': linkedTask.title,
      'description': linkedTask.description,
      'due_date_time': linkedTask.dueDateTime?.toIso8601String(),
      'priority': linkedTask.priority.name,
      'status': linkedTask.status.name,
      'estimated_minutes': linkedTask.estimatedMinutes,
      'is_archived': linkedTask.isArchived,
      'created_at': linkedTask.createdAt.toIso8601String(),
      'updated_at': linkedTask.updatedAt.toIso8601String(),
    });

    await _client.from('subtasks').delete().eq('task_id', linkedTask.id);
    if (linkedTask.subtasks.isNotEmpty) {
      await _client.from('subtasks').insert(
            linkedTask.subtasks.map((item) => item.toJson()).toList(),
          );
    }
  }

  @override
  Future<void> deleteTask(String userId, String taskId) async {
    await _client.from('tasks').delete().eq('id', taskId).eq('user_id', userId);
  }

  @override
  Future<List<NoteModel>> getNotes(String userId) async {
    final data = await _client
        .from('notes')
        .select()
        .eq('user_id', userId)
        .order('created_at');

    return (data as List<dynamic>)
        .map((item) =>
            NoteModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  @override
  Future<void> saveNote(NoteModel note) async {
    await _client.from('notes').upsert(note.toJson());
  }

  @override
  Future<void> deleteNote(String userId, String noteId) async {
    await _client.from('notes').delete().eq('id', noteId).eq('user_id', userId);
  }

  @override
  Future<List<ExamModel>> getExams(String userId) async {
    final data = await _client
        .from('exams')
        .select()
        .eq('user_id', userId)
        .order('date_time');

    return (data as List<dynamic>)
        .map((item) =>
            ExamModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  @override
  Future<void> saveExam(ExamModel exam) async {
    await _client.from('exams').upsert(exam.toJson());
  }

  @override
  Future<void> deleteExam(String userId, String examId) async {
    await _client.from('exams').delete().eq('id', examId).eq('user_id', userId);
  }

  @override
  Future<List<HabitModel>> getHabits(String userId) async {
    final data = await _client
        .from('habits')
        .select()
        .eq('user_id', userId)
        .order('created_at');

    return (data as List<dynamic>)
        .map((item) =>
            HabitModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  @override
  Future<void> saveHabit(HabitModel habit) async {
    await _client.from('habits').upsert(habit.toJson());
  }

  @override
  Future<void> deleteHabit(String userId, String habitId) async {
    await _client
        .from('habits')
        .delete()
        .eq('id', habitId)
        .eq('user_id', userId);
  }

  @override
  Future<List<StudySessionModel>> getStudySessions(String userId) async {
    final data = await _client
        .from('study_sessions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map(
          (item) => StudySessionModel.fromJson(
              Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<void> addStudySession(StudySessionModel session) async {
    await _client.from('study_sessions').insert(session.toJson());
  }

  @override
  Future<GoalSettingsModel> getGoals(String userId) async {
    final data = await _client
        .from('goals')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) {
      final created = GoalSettingsModel(
        id: _uuid.v4(),
        userId: userId,
        dailyTargetMinutes: 120,
        weeklyTargetMinutes: 600,
        monthlyTargetMinutes: 2400,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _client
          .from('goals')
          .upsert(created.toJson(), onConflict: 'user_id');
      return created;
    }

    return GoalSettingsModel.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<void> saveGoals(GoalSettingsModel goals) async {
    await _client.from('goals').upsert(goals.toJson());
  }

  @override
  Future<UserSettingsModel> getUserSettings(String userId) async {
    final data = await _client
        .from('user_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) {
      final profileData = await _client
          .from('profiles')
          .select('preferred_language, theme_mode')
          .eq('id', userId)
          .maybeSingle();
      final created = UserSettingsModel(
        id: _uuid.v4(),
        userId: userId,
        languageCode: profileData?['preferred_language'] as String? ?? 'en',
        themeMode: profileData?['theme_mode'] as String? ?? 'system',
        notificationsEnabled: true,
        accessibilityMode: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _client
          .from('user_settings')
          .upsert(created.toJson(), onConflict: 'user_id');
      return created;
    }

    return UserSettingsModel.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<void> saveUserSettings(UserSettingsModel settings) async {
    await _client.from('user_settings').upsert(settings.toJson());
  }

  @override
  Future<ReminderPreferencesModel> getReminderPreferences(String userId) async {
    final data = await _client
        .from('reminder_preferences')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) {
      final created = ReminderPreferencesModel(
        id: _uuid.v4(),
        userId: userId,
        tasksEnabled: true,
        studyEnabled: true,
        dailyEnabled: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _client
          .from('reminder_preferences')
          .upsert(created.toJson(), onConflict: 'user_id');
      return created;
    }

    return ReminderPreferencesModel.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<void> saveReminderPreferences(
    ReminderPreferencesModel preferences,
  ) async {
    await _client.from('reminder_preferences').upsert(preferences.toJson());
  }

  Future<void> _ensureGoals(String userId) async {
    final existing = await _client
        .from('goals')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    if (existing != null) {
      return;
    }

    final now = DateTime.now();
    await _client.from('goals').upsert(
          GoalSettingsModel(
            id: _uuid.v4(),
            userId: userId,
            dailyTargetMinutes: 120,
            weeklyTargetMinutes: 600,
            monthlyTargetMinutes: 2400,
            createdAt: now,
            updatedAt: now,
          ).toJson(),
          onConflict: 'user_id',
        );
  }

  Future<void> _ensureUserSettings(AppUserModel user) async {
    final data = await _client
        .from('user_settings')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    final now = DateTime.now();
    final settings = UserSettingsModel(
      id: data?['id'] as String? ?? _uuid.v4(),
      userId: user.id,
      languageCode: user.preferredLanguage,
      themeMode: user.themeMode,
      notificationsEnabled: data?['notifications_enabled'] as bool? ?? true,
      accessibilityMode: data?['accessibility_mode'] as bool? ?? false,
      createdAt:
          data == null ? now : DateTime.parse(data['created_at'] as String),
      updatedAt: now,
    );

    final shouldSync = data == null ||
        data['language'] != user.preferredLanguage ||
        data['theme_mode'] != user.themeMode;
    if (!shouldSync) {
      return;
    }

    await _client
        .from('user_settings')
        .upsert(settings.toJson(), onConflict: 'user_id');
  }

  Future<void> _ensureReminderPreferences(String userId) async {
    final existing = await _client
        .from('reminder_preferences')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    if (existing != null) {
      return;
    }

    final now = DateTime.now();
    await _client.from('reminder_preferences').upsert(
          ReminderPreferencesModel(
            id: _uuid.v4(),
            userId: userId,
            tasksEnabled: true,
            studyEnabled: true,
            dailyEnabled: false,
            createdAt: now,
            updatedAt: now,
          ).toJson(),
          onConflict: 'user_id',
        );
  }
}
