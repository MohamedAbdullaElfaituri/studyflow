import 'dart:convert';

enum TaskPriority { low, medium, high, urgent }

enum TaskStatus { pending, inProgress, completed }

enum AppThemePreference { system, light, dark }

class AppUserModel {
  const AppUserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.avatarUrl,
    required this.preferredLanguage,
    required this.themeMode,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String preferredLanguage;
  final String themeMode;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppUserModel copyWith({
    String? fullName,
    String? email,
    String? avatarUrl,
    String? preferredLanguage,
    String? themeMode,
    DateTime? updatedAt,
  }) {
    return AppUserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      themeMode: themeMode ?? this.themeMode,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'avatar_url': avatarUrl,
      'preferred_language': preferredLanguage,
      'theme_mode': themeMode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
      themeMode: json['theme_mode'] as String? ?? 'system',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class AuthCredentialModel {
  const AuthCredentialModel({
    required this.userId,
    required this.email,
    required this.password,
  });

  final String userId;
  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'password': password,
    };
  }

  factory AuthCredentialModel.fromJson(Map<String, dynamic> json) {
    return AuthCredentialModel(
      userId: json['user_id'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }
}

class CourseModel {
  const CourseModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.instructorName,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String description;
  final String? instructorName;
  final int color;
  final DateTime createdAt;
  final DateTime updatedAt;

  CourseModel copyWith({
    String? title,
    String? description,
    String? instructorName,
    int? color,
    DateTime? updatedAt,
  }) {
    return CourseModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      instructorName: instructorName ?? this.instructorName,
      color: color ?? this.color,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'instructor_name': instructorName,
      'color': color,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      instructorName: json['instructor_name'] as String?,
      color: (json['color'] as num?)?.toInt() ?? 0xFF18456B,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class SubtaskModel {
  const SubtaskModel({
    required this.id,
    required this.taskId,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
  });

  final String id;
  final String taskId;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  SubtaskModel copyWith({
    String? taskId,
    String? title,
    bool? isCompleted,
  }) {
    return SubtaskModel(
      id: id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'title': title,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SubtaskModel.fromJson(Map<String, dynamic> json) {
    return SubtaskModel(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      title: json['title'] as String? ?? '',
      isCompleted: json['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class TaskModel {
  const TaskModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.title,
    required this.description,
    required this.dueDateTime,
    required this.priority,
    required this.status,
    required this.estimatedMinutes,
    required this.isArchived,
    required this.subtasks,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String? courseId;
  final String title;
  final String description;
  final DateTime? dueDateTime;
  final TaskPriority priority;
  final TaskStatus status;
  final int estimatedMinutes;
  final bool isArchived;
  final List<SubtaskModel> subtasks;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel copyWith({
    String? courseId,
    String? title,
    String? description,
    DateTime? dueDateTime,
    TaskPriority? priority,
    TaskStatus? status,
    int? estimatedMinutes,
    bool? isArchived,
    List<SubtaskModel>? subtasks,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id,
      userId: userId,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDateTime: dueDateTime ?? this.dueDateTime,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isArchived: isArchived ?? this.isArchived,
      subtasks: subtasks ?? this.subtasks,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  TaskModel withLinkedSubtasks() {
    return copyWith(
      subtasks: subtasks.map((subtask) => subtask.copyWith(taskId: id)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'title': title,
      'description': description,
      'due_date_time': dueDateTime?.toIso8601String(),
      'priority': priority.name,
      'status': status.name,
      'estimated_minutes': estimatedMinutes,
      'is_archived': isArchived,
      'subtasks': subtasks.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      courseId: json['course_id'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dueDateTime: json['due_date_time'] == null
          ? null
          : DateTime.parse(json['due_date_time'] as String),
      priority: TaskPriority.values.firstWhere(
        (value) => value.name == (json['priority'] as String? ?? 'medium'),
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (value) => value.name == (json['status'] as String? ?? 'pending'),
        orElse: () => TaskStatus.pending,
      ),
      estimatedMinutes: (json['estimated_minutes'] as num?)?.toInt() ?? 0,
      isArchived: json['is_archived'] as bool? ?? false,
      subtasks: ((json['subtasks'] as List?) ?? const [])
          .map((item) => SubtaskModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class NoteModel {
  const NoteModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.title,
    required this.content,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String? courseId;
  final String title;
  final String content;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteModel copyWith({
    String? courseId,
    String? title,
    String? content,
    bool? isPinned,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id,
      userId: userId,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      content: content ?? this.content,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'title': title,
      'content': content,
      'is_pinned': isPinned,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      courseId: json['course_id'] as String?,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      isPinned: json['is_pinned'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class StudySessionModel {
  const StudySessionModel({
    required this.id,
    required this.userId,
    required this.taskId,
    required this.courseId,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String? taskId;
  final String? courseId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'task_id': taskId,
      'course_id': courseId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'duration_minutes': durationMinutes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory StudySessionModel.fromJson(Map<String, dynamic> json) {
    return StudySessionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      taskId: json['task_id'] as String?,
      courseId: json['course_id'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class GoalSettingsModel {
  const GoalSettingsModel({
    required this.id,
    required this.userId,
    required this.dailyTargetMinutes,
    required this.weeklyTargetMinutes,
    required this.monthlyTargetMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final int dailyTargetMinutes;
  final int weeklyTargetMinutes;
  final int monthlyTargetMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  GoalSettingsModel copyWith({
    int? dailyTargetMinutes,
    int? weeklyTargetMinutes,
    int? monthlyTargetMinutes,
    DateTime? updatedAt,
  }) {
    return GoalSettingsModel(
      id: id,
      userId: userId,
      dailyTargetMinutes: dailyTargetMinutes ?? this.dailyTargetMinutes,
      weeklyTargetMinutes: weeklyTargetMinutes ?? this.weeklyTargetMinutes,
      monthlyTargetMinutes: monthlyTargetMinutes ?? this.monthlyTargetMinutes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'daily_target_minutes': dailyTargetMinutes,
      'weekly_target_minutes': weeklyTargetMinutes,
      'monthly_target_minutes': monthlyTargetMinutes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory GoalSettingsModel.fromJson(Map<String, dynamic> json) {
    return GoalSettingsModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      dailyTargetMinutes: (json['daily_target_minutes'] as num?)?.toInt() ?? 120,
      weeklyTargetMinutes:
          (json['weekly_target_minutes'] as num?)?.toInt() ?? 600,
      monthlyTargetMinutes:
          (json['monthly_target_minutes'] as num?)?.toInt() ?? 2400,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class UserSettingsModel {
  const UserSettingsModel({
    required this.id,
    required this.userId,
    required this.languageCode,
    required this.themeMode,
    required this.notificationsEnabled,
    required this.accessibilityMode,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String languageCode;
  final String themeMode;
  final bool notificationsEnabled;
  final bool accessibilityMode;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSettingsModel copyWith({
    String? languageCode,
    String? themeMode,
    bool? notificationsEnabled,
    bool? accessibilityMode,
    DateTime? updatedAt,
  }) {
    return UserSettingsModel(
      id: id,
      userId: userId,
      languageCode: languageCode ?? this.languageCode,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      accessibilityMode: accessibilityMode ?? this.accessibilityMode,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'language': languageCode,
      'theme_mode': themeMode,
      'notifications_enabled': notificationsEnabled,
      'accessibility_mode': accessibilityMode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      languageCode: json['language'] as String? ?? 'en',
      themeMode: json['theme_mode'] as String? ?? 'system',
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      accessibilityMode: json['accessibility_mode'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class ReminderPreferencesModel {
  const ReminderPreferencesModel({
    required this.id,
    required this.userId,
    required this.tasksEnabled,
    required this.studyEnabled,
    required this.dailyEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final bool tasksEnabled;
  final bool studyEnabled;
  final bool dailyEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReminderPreferencesModel copyWith({
    bool? tasksEnabled,
    bool? studyEnabled,
    bool? dailyEnabled,
    DateTime? updatedAt,
  }) {
    return ReminderPreferencesModel(
      id: id,
      userId: userId,
      tasksEnabled: tasksEnabled ?? this.tasksEnabled,
      studyEnabled: studyEnabled ?? this.studyEnabled,
      dailyEnabled: dailyEnabled ?? this.dailyEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tasks_enabled': tasksEnabled,
      'study_enabled': studyEnabled,
      'daily_enabled': dailyEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ReminderPreferencesModel.fromJson(Map<String, dynamic> json) {
    return ReminderPreferencesModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      tasksEnabled: json['tasks_enabled'] as bool? ?? true,
      studyEnabled: json['study_enabled'] as bool? ?? true,
      dailyEnabled: json['daily_enabled'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class AchievementModel {
  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.target,
    required this.icon,
  });

  final String id;
  final String title;
  final String description;
  final int progress;
  final int target;
  final String icon;

  double get completion => target == 0 ? 0 : progress / target;
}

String encodeCollection(List<Map<String, dynamic>> items) => jsonEncode(items);

List<Map<String, dynamic>> decodeCollection(String? raw) {
  if (raw == null || raw.isEmpty) {
    return [];
  }

  final decoded = jsonDecode(raw) as List<dynamic>;
  return decoded
      .map((item) => Map<String, dynamic>.from(item as Map))
      .toList();
}
