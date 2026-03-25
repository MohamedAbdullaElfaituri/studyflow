import 'package:uuid/uuid.dart';

import '../../shared/models/app_models.dart';

class DemoSeedService {
  DemoSeedService._();

  static final _uuid = const Uuid();

  static List<CourseModel> coursesFor(String userId) {
    final now = DateTime.now();

    return [
      CourseModel(
        id: _uuid.v4(),
        userId: userId,
        title: 'Human-Computer Interaction',
        description: 'Design critiques, usability testing, and inclusive UX.',
        instructorName: 'Dr. Elif Demir',
        color: 0xFF1F6FEB,
        createdAt: now.subtract(const Duration(days: 18)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      CourseModel(
        id: _uuid.v4(),
        userId: userId,
        title: 'Database Systems',
        description: 'Schema design, SQL, and Supabase architecture.',
        instructorName: 'Prof. Samir Kaya',
        color: 0xFF24A19C,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      CourseModel(
        id: _uuid.v4(),
        userId: userId,
        title: 'Software Engineering',
        description: 'Team sprint planning, architecture, and reviews.',
        instructorName: 'Dr. Selin Arslan',
        color: 0xFFF4A261,
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  static List<TaskModel> tasksFor(String userId, List<CourseModel> courses) {
    final now = DateTime.now();
    final hci = courses.first.id;
    final db = courses[1].id;
    final se = courses[2].id;

    return [
      TaskModel(
        id: _uuid.v4(),
        userId: userId,
        courseId: hci,
        title: 'Prepare heuristic evaluation slides',
        description:
            'Summarize Nielsen heuristics and attach interface screenshots.',
        dueDateTime: DateTime(now.year, now.month, now.day, 17, 30),
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
        estimatedMinutes: 90,
        isArchived: false,
        subtasks: [
          SubtaskModel(
            id: _uuid.v4(),
            taskId: 'seed',
            title: 'Collect screenshots',
            isCompleted: true,
            createdAt: now.subtract(const Duration(days: 1)),
          ),
          SubtaskModel(
            id: _uuid.v4(),
            taskId: 'seed',
            title: 'Add accessibility notes',
            isCompleted: false,
            createdAt: now.subtract(const Duration(hours: 8)),
          ),
        ],
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      TaskModel(
        id: _uuid.v4(),
        userId: userId,
        courseId: db,
        title: 'Model StudyFlow relational schema',
        description:
            'Finalize RLS-ready tables for profiles, tasks, and study sessions.',
        dueDateTime: DateTime(now.year, now.month, now.day + 1, 14),
        priority: TaskPriority.urgent,
        status: TaskStatus.pending,
        estimatedMinutes: 120,
        isArchived: false,
        subtasks: [
          SubtaskModel(
            id: _uuid.v4(),
            taskId: 'seed',
            title: 'Validate foreign keys',
            isCompleted: false,
            createdAt: now.subtract(const Duration(hours: 12)),
          ),
        ],
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      TaskModel(
        id: _uuid.v4(),
        userId: userId,
        courseId: se,
        title: 'Weekly sprint reflection',
        description: 'Capture wins, blockers, and next sprint priorities.',
        dueDateTime: DateTime(now.year, now.month, now.day + 2, 18, 15),
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        estimatedMinutes: 45,
        isArchived: false,
        subtasks: const [],
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      TaskModel(
        id: _uuid.v4(),
        userId: userId,
        courseId: hci,
        title: 'Submit low-fidelity wireframes',
        description: 'Send three revised mobile flows to the studio board.',
        dueDateTime: DateTime(now.year, now.month, now.day - 1, 10),
        priority: TaskPriority.high,
        status: TaskStatus.completed,
        estimatedMinutes: 70,
        isArchived: false,
        subtasks: const [],
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ].map((task) => task.withLinkedSubtasks()).toList();
  }

  static List<NoteModel> notesFor(String userId, List<CourseModel> courses) {
    final now = DateTime.now();

    return [
      NoteModel(
        id: _uuid.v4(),
        userId: userId,
        courseId: courses.first.id,
        title: 'Inclusive design reminders',
        content:
            'Use large touch targets, clear labels, and multiple feedback cues.',
        isPinned: true,
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(hours: 3)),
      ),
      NoteModel(
        id: _uuid.v4(),
        userId: userId,
        courseId: courses[1].id,
        title: 'Supabase setup checklist',
        content:
            'Create project, enable email auth, add tables, configure RLS, seed demo data.',
        isPinned: false,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      NoteModel(
        id: _uuid.v4(),
        userId: userId,
        courseId: courses[2].id,
        title: 'Presentation narrative',
        content:
            'Lead with student pain points, then show premium design and analytics.',
        isPinned: false,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 9)),
      ),
    ];
  }

  static List<StudySessionModel> sessionsFor(
    String userId,
    List<CourseModel> courses,
    List<TaskModel> tasks,
  ) {
    final now = DateTime.now();

    return [
      StudySessionModel(
        id: _uuid.v4(),
        userId: userId,
        taskId: tasks.first.id,
        courseId: courses.first.id,
        startTime: now.subtract(const Duration(days: 1, hours: 3)),
        endTime: now.subtract(const Duration(days: 1, hours: 2, minutes: 10)),
        durationMinutes: 50,
        createdAt: now.subtract(const Duration(days: 1, hours: 2, minutes: 10)),
      ),
      StudySessionModel(
        id: _uuid.v4(),
        userId: userId,
        taskId: tasks[1].id,
        courseId: courses[1].id,
        startTime: now.subtract(const Duration(days: 2, hours: 4)),
        endTime: now.subtract(const Duration(days: 2, hours: 3, minutes: 15)),
        durationMinutes: 45,
        createdAt: now.subtract(const Duration(days: 2, hours: 3, minutes: 15)),
      ),
      StudySessionModel(
        id: _uuid.v4(),
        userId: userId,
        taskId: tasks[2].id,
        courseId: courses[2].id,
        startTime: now.subtract(const Duration(days: 4, hours: 5)),
        endTime: now.subtract(const Duration(days: 4, hours: 4, minutes: 5)),
        durationMinutes: 55,
        createdAt: now.subtract(const Duration(days: 4, hours: 4, minutes: 5)),
      ),
      StudySessionModel(
        id: _uuid.v4(),
        userId: userId,
        taskId: null,
        courseId: courses.first.id,
        startTime: now.subtract(const Duration(hours: 7)),
        endTime: now.subtract(const Duration(hours: 6, minutes: 30)),
        durationMinutes: 30,
        createdAt: now.subtract(const Duration(hours: 6, minutes: 30)),
      ),
    ];
  }

  static GoalSettingsModel goalsFor(String userId) {
    final now = DateTime.now();

    return GoalSettingsModel(
      id: _uuid.v4(),
      userId: userId,
      dailyTargetMinutes: 120,
      weeklyTargetMinutes: 600,
      monthlyTargetMinutes: 2400,
      createdAt: now.subtract(const Duration(days: 12)),
      updatedAt: now.subtract(const Duration(days: 1)),
    );
  }

  static UserSettingsModel settingsFor(String userId) {
    final now = DateTime.now();

    return UserSettingsModel(
      id: _uuid.v4(),
      userId: userId,
      languageCode: 'en',
      themeMode: 'system',
      notificationsEnabled: true,
      accessibilityMode: false,
      createdAt: now.subtract(const Duration(days: 12)),
      updatedAt: now.subtract(const Duration(days: 1)),
    );
  }

  static ReminderPreferencesModel remindersFor(String userId) {
    final now = DateTime.now();

    return ReminderPreferencesModel(
      id: _uuid.v4(),
      userId: userId,
      tasksEnabled: true,
      studyEnabled: true,
      dailyEnabled: false,
      createdAt: now.subtract(const Duration(days: 12)),
      updatedAt: now.subtract(const Duration(days: 2)),
    );
  }
}
