// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'StudyFlow';

  @override
  String get splashSubtitle =>
      'Premium study planning for focused university life.';

  @override
  String get genericNavigationError =>
      'Something went wrong while opening this screen.';

  @override
  String get genericErrorMessage => 'Something went wrong. Please try again.';

  @override
  String get errorStateTitle => 'We hit a small issue';

  @override
  String get tryAgain => 'Try again';

  @override
  String get validationRequired => 'This field is required.';

  @override
  String get validationInvalidEmail => 'Enter a valid email address.';

  @override
  String validationMinLength(int min) {
    return 'Use at least $min characters.';
  }

  @override
  String get errorUserNotFound =>
      'We could not find an account with that email.';

  @override
  String get errorInvalidCredentials => 'Your email or password is incorrect.';

  @override
  String get errorDuplicateEmail => 'This email is already in use.';

  @override
  String get errorMissingUser =>
      'We could not complete your request right now.';

  @override
  String get homeTab => 'Home';

  @override
  String get tasksTab => 'Tasks';

  @override
  String get calendarTab => 'Calendar';

  @override
  String get focusTab => 'Focus';

  @override
  String get profileTab => 'Profile';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle =>
      'Sign in to keep your courses, tasks, notes, and focus history together.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get forgotPasswordAction => 'Forgot password?';

  @override
  String get loginAction => 'Log in';

  @override
  String get demoAccountTitle => 'Demo-ready project flow';

  @override
  String get demoAccountDescription =>
      'Use the prefilled credentials or create a new account to explore the app quickly during your presentation.';

  @override
  String get noAccountPrompt => 'Don’t have an account?';

  @override
  String get signUpAction => 'Sign up';

  @override
  String get signUpTitle => 'Create your account';

  @override
  String get signUpSubtitle =>
      'Build your personal study system in one elegant workspace.';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get createAccountAction => 'Create account';

  @override
  String get forgotPasswordTitle => 'Reset your password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and we will send you a reset link structure.';

  @override
  String get sendResetLinkAction => 'Send reset link';

  @override
  String get resetPasswordSentMessage =>
      'If the account exists, a reset flow has been prepared.';

  @override
  String get onboardingTitleOne => 'Plan every course in one flow';

  @override
  String get onboardingSubtitleOne =>
      'Track classes, assignments, deadlines, and notes with a calm mobile-first experience.';

  @override
  String get onboardingTitleTwo => 'Stay focused with smart insights';

  @override
  String get onboardingSubtitleTwo =>
      'Turn study sessions into measurable progress with streaks, goals, and weekly summaries.';

  @override
  String get onboardingTitleThree => 'Inclusive, multilingual, and polished';

  @override
  String get onboardingSubtitleThree =>
      'Switch between English, Turkish, and Arabic with full RTL support for Arabic.';

  @override
  String get skipAction => 'Skip';

  @override
  String get nextAction => 'Next';

  @override
  String get finishAction => 'Finish';

  @override
  String welcomeBack(String name) {
    return 'Welcome back, $name';
  }

  @override
  String dashboardHeroSubtitle(String date) {
    return 'Here is your study flow for $date.';
  }

  @override
  String get dailyStudyMinutesLabel => 'Today’s minutes';

  @override
  String get weeklyStudyMinutesLabel => 'Weekly minutes';

  @override
  String get completedTasksLabel => 'Completed tasks';

  @override
  String get streakLabel => 'Streak';

  @override
  String get quickActionsTitle => 'Quick actions';

  @override
  String get quickActionsSubtitle => 'Jump into the next thing that matters.';

  @override
  String get quickTaskSubtitle => 'Add or manage assignments';

  @override
  String get quickCourseSubtitle => 'Organize your subjects';

  @override
  String get quickNoteSubtitle => 'Capture class insights';

  @override
  String get quickAnalyticsSubtitle => 'Review your momentum';

  @override
  String get todayPlanTitle => 'Today’s plan';

  @override
  String get todayPlanSubtitle => 'What needs attention before the day ends.';

  @override
  String get emptyTodayTitle => 'Your day is clear';

  @override
  String get emptyTodayDescription =>
      'Add a task or plan a focus block to build momentum.';

  @override
  String get goalProgressTitle => 'Goal progress';

  @override
  String get goalProgressSubtitle =>
      'Daily, weekly, and monthly targets at a glance.';

  @override
  String get viewAllAction => 'View all';

  @override
  String get dailyGoalLabel => 'Daily goal';

  @override
  String get weeklyGoalLabel => 'Weekly goal';

  @override
  String get monthlyGoalLabel => 'Monthly goal';

  @override
  String goalProgressValue(int value, int target) {
    return '$value/$target min';
  }

  @override
  String get insightsTitle => 'Productivity insights';

  @override
  String get insightsSubtitle =>
      'Helpful observations based on your recent patterns.';

  @override
  String insightStreak(int days) {
    return 'You are on a $days-day streak. Keep the routine steady and protect your best study hours.';
  }

  @override
  String get insightPlanDay =>
      'You have room in today’s plan. A short focus session could keep your rhythm strong.';

  @override
  String get insightBoostFocus =>
      'Your weekly target is still within reach. Two focused sessions can close the gap.';

  @override
  String get insightStrongMomentum =>
      'Your progress looks steady. Keep pairing focused work with realistic task planning.';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get achievementsSubtitle => 'Small wins that reinforce consistency.';

  @override
  String get recentActivityTitle => 'Recent activity';

  @override
  String get recentActivitySubtitle =>
      'Your latest study sessions and momentum signals.';

  @override
  String get emptyActivityTitle => 'No recent activity yet';

  @override
  String get emptyActivityDescription =>
      'Complete a focus session to begin building your activity history.';

  @override
  String focusSessionSummary(int minutes) {
    return '$minutes minute focus session';
  }

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get tasksSubtitle =>
      'Search, filter, and complete your study workload with clarity.';

  @override
  String get addTaskAction => 'Add task';

  @override
  String get addTaskTitle => 'Create task';

  @override
  String get editTaskTitle => 'Edit task';

  @override
  String get taskDetailTitle => 'Task details';

  @override
  String get searchTasksHint => 'Search tasks';

  @override
  String get sortByDueDate => 'Sort by due date';

  @override
  String get sortByPriority => 'Sort by priority';

  @override
  String get sortByCourse => 'Sort by course';

  @override
  String get filterAll => 'All';

  @override
  String get filterPending => 'Pending';

  @override
  String get filterInProgress => 'In progress';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get archiveCompletedAction => 'Archive completed tasks';

  @override
  String get emptyTasksTitle => 'No tasks yet';

  @override
  String get emptyTasksDescription =>
      'Create your first task to build today’s plan.';

  @override
  String get taskNotFoundTitle => 'Task not found';

  @override
  String get taskNotFoundDescription =>
      'This task may have been deleted or is no longer available.';

  @override
  String get statusLabel => 'Status';

  @override
  String get priorityLabel => 'Priority';

  @override
  String get dueDateLabel => 'Due date';

  @override
  String get estimatedMinutesLabel => 'Estimated minutes';

  @override
  String get courseLabel => 'Course';

  @override
  String get linkedTasksTitle => 'Linked tasks';

  @override
  String get linkedTasksSubtitle =>
      'Assignments and study actions connected to this course.';

  @override
  String get emptyLinkedTasksTitle => 'No linked tasks yet';

  @override
  String get emptyLinkedTasksDescription =>
      'Add a task and connect it to this course.';

  @override
  String get subtasksTitle => 'Subtasks';

  @override
  String get emptySubtasksDescription =>
      'Break this work into smaller steps for easier progress.';

  @override
  String get deleteTaskAction => 'Delete task';

  @override
  String get titleLabel => 'Title';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get optionalCourseLabel => 'No course linked';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityUrgent => 'Urgent';

  @override
  String get pickDateAction => 'Pick date';

  @override
  String get pickTimeAction => 'Pick time';

  @override
  String subtaskLabel(int index) {
    return 'Subtask $index';
  }

  @override
  String get addSubtaskAction => 'Add subtask';

  @override
  String get saveTaskAction => 'Save task';

  @override
  String get coursesTitle => 'Courses';

  @override
  String get addCourseAction => 'Add course';

  @override
  String get addCourseTitle => 'Create course';

  @override
  String get editCourseTitle => 'Edit course';

  @override
  String get courseDetailTitle => 'Course overview';

  @override
  String get emptyCoursesTitle => 'No courses yet';

  @override
  String get emptyCoursesDescription =>
      'Create a course to organize related tasks and notes.';

  @override
  String courseTaskNoteSummary(int taskCount, int noteCount) {
    return '$taskCount tasks • $noteCount notes';
  }

  @override
  String get courseNotFoundTitle => 'Course not found';

  @override
  String get courseNotFoundDescription => 'This course could not be loaded.';

  @override
  String get instructorLabel => 'Instructor';

  @override
  String get linkedNotesTitle => 'Linked notes';

  @override
  String get linkedNotesSubtitle =>
      'Quick references and class notes connected to this course.';

  @override
  String get emptyLinkedNotesTitle => 'No linked notes yet';

  @override
  String get emptyLinkedNotesDescription =>
      'Create a note and attach it to this course.';

  @override
  String get deleteCourseAction => 'Delete course';

  @override
  String get courseColorLabel => 'Course color';

  @override
  String get saveCourseAction => 'Save course';

  @override
  String get notesTitle => 'Notes';

  @override
  String get addNoteAction => 'Add note';

  @override
  String get addNoteTitle => 'Create note';

  @override
  String get editNoteTitle => 'Edit note';

  @override
  String get searchNotesHint => 'Search notes';

  @override
  String get emptyNotesTitle => 'No notes yet';

  @override
  String get emptyNotesDescription =>
      'Capture your first insight, lecture summary, or revision checklist.';

  @override
  String get contentLabel => 'Content';

  @override
  String get pinNoteLabel => 'Pin this note';

  @override
  String get saveNoteAction => 'Save note';

  @override
  String get calendarTitle => 'Planner';

  @override
  String get calendarSubtitle =>
      'Monthly and weekly planning with a daily agenda.';

  @override
  String get monthFormatLabel => 'Month';

  @override
  String get weekFormatLabel => 'Week';

  @override
  String dailyAgendaTitle(String date) {
    return 'Agenda for $date';
  }

  @override
  String get emptyAgendaDescription =>
      'No tasks or focus sessions are planned for this day.';

  @override
  String get focusTitle => 'Focus mode';

  @override
  String get focusSubtitle =>
      'Use Pomodoro-style sessions to stay intentional and energized.';

  @override
  String get focusModeLabel => 'Focus session';

  @override
  String get breakModeLabel => 'Break session';

  @override
  String get startAction => 'Start';

  @override
  String get pauseAction => 'Pause';

  @override
  String get resumeAction => 'Resume';

  @override
  String get resetAction => 'Reset';

  @override
  String get customizeSessionTitle => 'Customize session';

  @override
  String focusDurationLabel(int minutes) {
    return 'Focus duration: $minutes minutes';
  }

  @override
  String breakDurationLabel(int minutes) {
    return 'Break duration: $minutes minutes';
  }

  @override
  String get linkCourseOptionalLabel => 'Link session to a course';

  @override
  String get focusHistoryTitle => 'Focus history';

  @override
  String get focusHistorySubtitle =>
      'Recent completed sessions saved to your progress timeline.';

  @override
  String get emptyFocusHistoryTitle => 'No focus history yet';

  @override
  String get emptyFocusHistoryDescription =>
      'Start a session to begin tracking your study rhythm.';

  @override
  String get focusSessionCompleteMessage =>
      'Focus session completed. Great work.';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get weeklyFocusChartTitle => 'Last 7 days';

  @override
  String get courseDistributionTitle => 'Course distribution';

  @override
  String get miscLabel => 'Misc';

  @override
  String courseAnalyticsRow(String course, int minutes) {
    return '$course: $minutes minutes';
  }

  @override
  String get goalsTitle => 'Goals';

  @override
  String get studyGoalsTitle => 'Study targets';

  @override
  String get saveGoalsAction => 'Save goals';

  @override
  String get goalsSavedMessage => 'Your goals have been updated.';

  @override
  String get dailyCheckInTitle => 'Daily check-in';

  @override
  String get dailyCheckInDescription =>
      'Log a short session to stay connected to your goals, even on busy days.';

  @override
  String get dailyCheckInAction => 'Check in now';

  @override
  String get dailyCheckInSuccessMessage =>
      'A quick check-in session was added to today.';

  @override
  String get weeklyReviewTitle => 'Weekly review';

  @override
  String get weeklyReviewDescription =>
      'A simple reflection helps you notice progress and adjust next week’s plan.';

  @override
  String weeklyReviewSummary(int minutes, int tasks) {
    return 'This week you studied for $minutes minutes and completed $tasks tasks.';
  }

  @override
  String get profileFallbackName => 'StudyFlow Student';

  @override
  String get editProfileAction => 'Edit profile';

  @override
  String get profileOverviewTitle => 'Profile overview';

  @override
  String get profileOverviewSubtitle =>
      'A snapshot of your current study identity and momentum.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get logoutAction => 'Log out';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get saveProfileAction => 'Save profile';

  @override
  String get languageSectionTitle => 'Language';

  @override
  String get englishLabel => 'English';

  @override
  String get turkishLabel => 'Turkish';

  @override
  String get arabicLabel => 'Arabic';

  @override
  String get themeSectionTitle => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get taskRemindersLabel => 'Task reminders';

  @override
  String get studyRemindersLabel => 'Study reminders';

  @override
  String get dailyReminderLabel => 'Daily reminder';

  @override
  String get notificationPreviewTitle => 'StudyFlow reminder';

  @override
  String get notificationPreviewBody =>
      'A short focused session can move today forward.';

  @override
  String get previewNotificationAction => 'Preview notification';

  @override
  String get accessibilityPlaceholderTitle => 'Accessibility support';

  @override
  String get accessibilityPlaceholderDescription =>
      'Accessibility-specific preferences can be expanded here for larger text, reduced motion, and assistive support.';
}
