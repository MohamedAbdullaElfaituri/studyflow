import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'StudyFlow'**
  String get appName;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Premium study planning for focused university life.'**
  String get splashSubtitle;

  /// No description provided for @genericNavigationError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while opening this screen.'**
  String get genericNavigationError;

  /// No description provided for @genericErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericErrorMessage;

  /// No description provided for @errorStateTitle.
  ///
  /// In en, this message translates to:
  /// **'We hit a small issue'**
  String get errorStateTitle;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get validationRequired;

  /// No description provided for @validationInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get validationInvalidEmail;

  /// No description provided for @validationMinLength.
  ///
  /// In en, this message translates to:
  /// **'Use at least {min} characters.'**
  String validationMinLength(int min);

  /// No description provided for @errorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'We could not find an account with that email.'**
  String get errorUserNotFound;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Your email or password is incorrect.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorDuplicateEmail.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use.'**
  String get errorDuplicateEmail;

  /// No description provided for @errorMissingUser.
  ///
  /// In en, this message translates to:
  /// **'We could not complete your request right now.'**
  String get errorMissingUser;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @tasksTab.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTab;

  /// No description provided for @calendarTab.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTab;

  /// No description provided for @focusTab.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focusTab;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to keep your courses, tasks, notes, and focus history together.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @forgotPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordAction;

  /// No description provided for @loginAction.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginAction;

  /// No description provided for @demoAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo-ready project flow'**
  String get demoAccountTitle;

  /// No description provided for @demoAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Use the prefilled credentials or create a new account to explore the app quickly during your presentation.'**
  String get demoAccountDescription;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account?'**
  String get noAccountPrompt;

  /// No description provided for @signUpAction.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUpAction;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get signUpTitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Build your personal study system in one elegant workspace.'**
  String get signUpSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @createAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountAction;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send you a reset link structure.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetLinkAction.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLinkAction;

  /// No description provided for @resetPasswordSentMessage.
  ///
  /// In en, this message translates to:
  /// **'If the account exists, a reset flow has been prepared.'**
  String get resetPasswordSentMessage;

  /// No description provided for @onboardingTitleOne.
  ///
  /// In en, this message translates to:
  /// **'Plan every course in one flow'**
  String get onboardingTitleOne;

  /// No description provided for @onboardingSubtitleOne.
  ///
  /// In en, this message translates to:
  /// **'Track classes, assignments, deadlines, and notes with a calm mobile-first experience.'**
  String get onboardingSubtitleOne;

  /// No description provided for @onboardingTitleTwo.
  ///
  /// In en, this message translates to:
  /// **'Stay focused with smart insights'**
  String get onboardingTitleTwo;

  /// No description provided for @onboardingSubtitleTwo.
  ///
  /// In en, this message translates to:
  /// **'Turn study sessions into measurable progress with streaks, goals, and weekly summaries.'**
  String get onboardingSubtitleTwo;

  /// No description provided for @onboardingTitleThree.
  ///
  /// In en, this message translates to:
  /// **'Inclusive, multilingual, and polished'**
  String get onboardingTitleThree;

  /// No description provided for @onboardingSubtitleThree.
  ///
  /// In en, this message translates to:
  /// **'Switch between English, Turkish, and Arabic with full RTL support for Arabic.'**
  String get onboardingSubtitleThree;

  /// No description provided for @skipAction.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipAction;

  /// No description provided for @nextAction.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextAction;

  /// No description provided for @finishAction.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishAction;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}'**
  String welcomeBack(String name);

  /// No description provided for @dashboardHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here is your study flow for {date}.'**
  String dashboardHeroSubtitle(String date);

  /// No description provided for @dailyStudyMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Today’s minutes'**
  String get dailyStudyMinutesLabel;

  /// No description provided for @weeklyStudyMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Weekly minutes'**
  String get weeklyStudyMinutesLabel;

  /// No description provided for @completedTasksLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed tasks'**
  String get completedTasksLabel;

  /// No description provided for @streakLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakLabel;

  /// No description provided for @quickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActionsTitle;

  /// No description provided for @quickActionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Jump into the next thing that matters.'**
  String get quickActionsSubtitle;

  /// No description provided for @quickTaskSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add or manage assignments'**
  String get quickTaskSubtitle;

  /// No description provided for @quickCourseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize your subjects'**
  String get quickCourseSubtitle;

  /// No description provided for @quickNoteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture class insights'**
  String get quickNoteSubtitle;

  /// No description provided for @quickAnalyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review your momentum'**
  String get quickAnalyticsSubtitle;

  /// No description provided for @todayPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Today’s plan'**
  String get todayPlanTitle;

  /// No description provided for @todayPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What needs attention before the day ends.'**
  String get todayPlanSubtitle;

  /// No description provided for @emptyTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Your day is clear'**
  String get emptyTodayTitle;

  /// No description provided for @emptyTodayDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a task or plan a focus block to build momentum.'**
  String get emptyTodayDescription;

  /// No description provided for @goalProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal progress'**
  String get goalProgressTitle;

  /// No description provided for @goalProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily, weekly, and monthly targets at a glance.'**
  String get goalProgressSubtitle;

  /// No description provided for @viewAllAction.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAllAction;

  /// No description provided for @dailyGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get dailyGoalLabel;

  /// No description provided for @weeklyGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Weekly goal'**
  String get weeklyGoalLabel;

  /// No description provided for @monthlyGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly goal'**
  String get monthlyGoalLabel;

  /// No description provided for @goalProgressValue.
  ///
  /// In en, this message translates to:
  /// **'{value}/{target} min'**
  String goalProgressValue(int value, int target);

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Productivity insights'**
  String get insightsTitle;

  /// No description provided for @insightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Helpful observations based on your recent patterns.'**
  String get insightsSubtitle;

  /// No description provided for @insightStreak.
  ///
  /// In en, this message translates to:
  /// **'You are on a {days}-day streak. Keep the routine steady and protect your best study hours.'**
  String insightStreak(int days);

  /// No description provided for @insightPlanDay.
  ///
  /// In en, this message translates to:
  /// **'You have room in today’s plan. A short focus session could keep your rhythm strong.'**
  String get insightPlanDay;

  /// No description provided for @insightBoostFocus.
  ///
  /// In en, this message translates to:
  /// **'Your weekly target is still within reach. Two focused sessions can close the gap.'**
  String get insightBoostFocus;

  /// No description provided for @insightStrongMomentum.
  ///
  /// In en, this message translates to:
  /// **'Your progress looks steady. Keep pairing focused work with realistic task planning.'**
  String get insightStrongMomentum;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @achievementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Small wins that reinforce consistency.'**
  String get achievementsSubtitle;

  /// No description provided for @recentActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivityTitle;

  /// No description provided for @recentActivitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your latest study sessions and momentum signals.'**
  String get recentActivitySubtitle;

  /// No description provided for @emptyActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'No recent activity yet'**
  String get emptyActivityTitle;

  /// No description provided for @emptyActivityDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete a focus session to begin building your activity history.'**
  String get emptyActivityDescription;

  /// No description provided for @focusSessionSummary.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minute focus session'**
  String focusSessionSummary(int minutes);

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// No description provided for @tasksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search, filter, and complete your study workload with clarity.'**
  String get tasksSubtitle;

  /// No description provided for @addTaskAction.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get addTaskAction;

  /// No description provided for @addTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get addTaskTitle;

  /// No description provided for @editTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editTaskTitle;

  /// No description provided for @taskDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Task details'**
  String get taskDetailTitle;

  /// No description provided for @searchTasksHint.
  ///
  /// In en, this message translates to:
  /// **'Search tasks'**
  String get searchTasksHint;

  /// No description provided for @sortByDueDate.
  ///
  /// In en, this message translates to:
  /// **'Sort by due date'**
  String get sortByDueDate;

  /// No description provided for @sortByPriority.
  ///
  /// In en, this message translates to:
  /// **'Sort by priority'**
  String get sortByPriority;

  /// No description provided for @sortByCourse.
  ///
  /// In en, this message translates to:
  /// **'Sort by course'**
  String get sortByCourse;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterPending;

  /// No description provided for @filterInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get filterInProgress;

  /// No description provided for @filterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get filterCompleted;

  /// No description provided for @archiveCompletedAction.
  ///
  /// In en, this message translates to:
  /// **'Archive completed tasks'**
  String get archiveCompletedAction;

  /// No description provided for @emptyTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get emptyTasksTitle;

  /// No description provided for @emptyTasksDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your first task to build today’s plan.'**
  String get emptyTasksDescription;

  /// No description provided for @taskNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Task not found'**
  String get taskNotFoundTitle;

  /// No description provided for @taskNotFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'This task may have been deleted or is no longer available.'**
  String get taskNotFoundDescription;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @priorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priorityLabel;

  /// No description provided for @dueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get dueDateLabel;

  /// No description provided for @estimatedMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated minutes'**
  String get estimatedMinutesLabel;

  /// No description provided for @courseLabel.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get courseLabel;

  /// No description provided for @linkedTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Linked tasks'**
  String get linkedTasksTitle;

  /// No description provided for @linkedTasksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Assignments and study actions connected to this course.'**
  String get linkedTasksSubtitle;

  /// No description provided for @emptyLinkedTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'No linked tasks yet'**
  String get emptyLinkedTasksTitle;

  /// No description provided for @emptyLinkedTasksDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a task and connect it to this course.'**
  String get emptyLinkedTasksDescription;

  /// No description provided for @subtasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Subtasks'**
  String get subtasksTitle;

  /// No description provided for @emptySubtasksDescription.
  ///
  /// In en, this message translates to:
  /// **'Break this work into smaller steps for easier progress.'**
  String get emptySubtasksDescription;

  /// No description provided for @deleteTaskAction.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get deleteTaskAction;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @optionalCourseLabel.
  ///
  /// In en, this message translates to:
  /// **'No course linked'**
  String get optionalCourseLabel;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get priorityUrgent;

  /// No description provided for @pickDateAction.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get pickDateAction;

  /// No description provided for @pickTimeAction.
  ///
  /// In en, this message translates to:
  /// **'Pick time'**
  String get pickTimeAction;

  /// No description provided for @subtaskLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtask {index}'**
  String subtaskLabel(int index);

  /// No description provided for @addSubtaskAction.
  ///
  /// In en, this message translates to:
  /// **'Add subtask'**
  String get addSubtaskAction;

  /// No description provided for @saveTaskAction.
  ///
  /// In en, this message translates to:
  /// **'Save task'**
  String get saveTaskAction;

  /// No description provided for @coursesTitle.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get coursesTitle;

  /// No description provided for @addCourseAction.
  ///
  /// In en, this message translates to:
  /// **'Add course'**
  String get addCourseAction;

  /// No description provided for @addCourseTitle.
  ///
  /// In en, this message translates to:
  /// **'Create course'**
  String get addCourseTitle;

  /// No description provided for @editCourseTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit course'**
  String get editCourseTitle;

  /// No description provided for @courseDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Course overview'**
  String get courseDetailTitle;

  /// No description provided for @emptyCoursesTitle.
  ///
  /// In en, this message translates to:
  /// **'No courses yet'**
  String get emptyCoursesTitle;

  /// No description provided for @emptyCoursesDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a course to organize related tasks and notes.'**
  String get emptyCoursesDescription;

  /// No description provided for @courseTaskNoteSummary.
  ///
  /// In en, this message translates to:
  /// **'{taskCount} tasks • {noteCount} notes'**
  String courseTaskNoteSummary(int taskCount, int noteCount);

  /// No description provided for @courseNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Course not found'**
  String get courseNotFoundTitle;

  /// No description provided for @courseNotFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'This course could not be loaded.'**
  String get courseNotFoundDescription;

  /// No description provided for @instructorLabel.
  ///
  /// In en, this message translates to:
  /// **'Instructor'**
  String get instructorLabel;

  /// No description provided for @linkedNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Linked notes'**
  String get linkedNotesTitle;

  /// No description provided for @linkedNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick references and class notes connected to this course.'**
  String get linkedNotesSubtitle;

  /// No description provided for @emptyLinkedNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'No linked notes yet'**
  String get emptyLinkedNotesTitle;

  /// No description provided for @emptyLinkedNotesDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a note and attach it to this course.'**
  String get emptyLinkedNotesDescription;

  /// No description provided for @deleteCourseAction.
  ///
  /// In en, this message translates to:
  /// **'Delete course'**
  String get deleteCourseAction;

  /// No description provided for @courseColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Course color'**
  String get courseColorLabel;

  /// No description provided for @saveCourseAction.
  ///
  /// In en, this message translates to:
  /// **'Save course'**
  String get saveCourseAction;

  /// No description provided for @notesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesTitle;

  /// No description provided for @addNoteAction.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNoteAction;

  /// No description provided for @addNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Create note'**
  String get addNoteTitle;

  /// No description provided for @editNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editNoteTitle;

  /// No description provided for @searchNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get searchNotesHint;

  /// No description provided for @emptyNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get emptyNotesTitle;

  /// No description provided for @emptyNotesDescription.
  ///
  /// In en, this message translates to:
  /// **'Capture your first insight, lecture summary, or revision checklist.'**
  String get emptyNotesDescription;

  /// No description provided for @contentLabel.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get contentLabel;

  /// No description provided for @pinNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Pin this note'**
  String get pinNoteLabel;

  /// No description provided for @saveNoteAction.
  ///
  /// In en, this message translates to:
  /// **'Save note'**
  String get saveNoteAction;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get calendarTitle;

  /// No description provided for @calendarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly and weekly planning with a daily agenda.'**
  String get calendarSubtitle;

  /// No description provided for @monthFormatLabel.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get monthFormatLabel;

  /// No description provided for @weekFormatLabel.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get weekFormatLabel;

  /// No description provided for @dailyAgendaTitle.
  ///
  /// In en, this message translates to:
  /// **'Agenda for {date}'**
  String dailyAgendaTitle(String date);

  /// No description provided for @emptyAgendaDescription.
  ///
  /// In en, this message translates to:
  /// **'No tasks or focus sessions are planned for this day.'**
  String get emptyAgendaDescription;

  /// No description provided for @focusTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus mode'**
  String get focusTitle;

  /// No description provided for @focusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use Pomodoro-style sessions to stay intentional and energized.'**
  String get focusSubtitle;

  /// No description provided for @focusModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Focus session'**
  String get focusModeLabel;

  /// No description provided for @breakModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Break session'**
  String get breakModeLabel;

  /// No description provided for @startAction.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startAction;

  /// No description provided for @pauseAction.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseAction;

  /// No description provided for @resumeAction.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeAction;

  /// No description provided for @resetAction.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetAction;

  /// No description provided for @customizeSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Customize session'**
  String get customizeSessionTitle;

  /// No description provided for @focusDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Focus duration: {minutes} minutes'**
  String focusDurationLabel(int minutes);

  /// No description provided for @breakDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Break duration: {minutes} minutes'**
  String breakDurationLabel(int minutes);

  /// No description provided for @linkCourseOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Link session to a course'**
  String get linkCourseOptionalLabel;

  /// No description provided for @focusHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus history'**
  String get focusHistoryTitle;

  /// No description provided for @focusHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recent completed sessions saved to your progress timeline.'**
  String get focusHistorySubtitle;

  /// No description provided for @emptyFocusHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'No focus history yet'**
  String get emptyFocusHistoryTitle;

  /// No description provided for @emptyFocusHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Start a session to begin tracking your study rhythm.'**
  String get emptyFocusHistoryDescription;

  /// No description provided for @focusSessionCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Focus session completed. Great work.'**
  String get focusSessionCompleteMessage;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @weeklyFocusChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get weeklyFocusChartTitle;

  /// No description provided for @courseDistributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Course distribution'**
  String get courseDistributionTitle;

  /// No description provided for @miscLabel.
  ///
  /// In en, this message translates to:
  /// **'Misc'**
  String get miscLabel;

  /// No description provided for @courseAnalyticsRow.
  ///
  /// In en, this message translates to:
  /// **'{course}: {minutes} minutes'**
  String courseAnalyticsRow(String course, int minutes);

  /// No description provided for @goalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goalsTitle;

  /// No description provided for @studyGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Study targets'**
  String get studyGoalsTitle;

  /// No description provided for @saveGoalsAction.
  ///
  /// In en, this message translates to:
  /// **'Save goals'**
  String get saveGoalsAction;

  /// No description provided for @goalsSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your goals have been updated.'**
  String get goalsSavedMessage;

  /// No description provided for @dailyCheckInTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily check-in'**
  String get dailyCheckInTitle;

  /// No description provided for @dailyCheckInDescription.
  ///
  /// In en, this message translates to:
  /// **'Log a short session to stay connected to your goals, even on busy days.'**
  String get dailyCheckInDescription;

  /// No description provided for @dailyCheckInAction.
  ///
  /// In en, this message translates to:
  /// **'Check in now'**
  String get dailyCheckInAction;

  /// No description provided for @dailyCheckInSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'A quick check-in session was added to today.'**
  String get dailyCheckInSuccessMessage;

  /// No description provided for @weeklyReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly review'**
  String get weeklyReviewTitle;

  /// No description provided for @weeklyReviewDescription.
  ///
  /// In en, this message translates to:
  /// **'A simple reflection helps you notice progress and adjust next week’s plan.'**
  String get weeklyReviewDescription;

  /// No description provided for @weeklyReviewSummary.
  ///
  /// In en, this message translates to:
  /// **'This week you studied for {minutes} minutes and completed {tasks} tasks.'**
  String weeklyReviewSummary(int minutes, int tasks);

  /// No description provided for @profileFallbackName.
  ///
  /// In en, this message translates to:
  /// **'StudyFlow Student'**
  String get profileFallbackName;

  /// No description provided for @editProfileAction.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileAction;

  /// No description provided for @profileOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile overview'**
  String get profileOverviewTitle;

  /// No description provided for @profileOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A snapshot of your current study identity and momentum.'**
  String get profileOverviewSubtitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @logoutAction.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutAction;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @saveProfileAction.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get saveProfileAction;

  /// No description provided for @languageSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSectionTitle;

  /// No description provided for @englishLabel.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLabel;

  /// No description provided for @turkishLabel.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkishLabel;

  /// No description provided for @arabicLabel.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabicLabel;

  /// No description provided for @themeSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeSectionTitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @taskRemindersLabel.
  ///
  /// In en, this message translates to:
  /// **'Task reminders'**
  String get taskRemindersLabel;

  /// No description provided for @studyRemindersLabel.
  ///
  /// In en, this message translates to:
  /// **'Study reminders'**
  String get studyRemindersLabel;

  /// No description provided for @dailyReminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get dailyReminderLabel;

  /// No description provided for @notificationPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'StudyFlow reminder'**
  String get notificationPreviewTitle;

  /// No description provided for @notificationPreviewBody.
  ///
  /// In en, this message translates to:
  /// **'A short focused session can move today forward.'**
  String get notificationPreviewBody;

  /// No description provided for @previewNotificationAction.
  ///
  /// In en, this message translates to:
  /// **'Preview notification'**
  String get previewNotificationAction;

  /// No description provided for @accessibilityPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Accessibility support'**
  String get accessibilityPlaceholderTitle;

  /// No description provided for @accessibilityPlaceholderDescription.
  ///
  /// In en, this message translates to:
  /// **'Accessibility-specific preferences can be expanded here for larger text, reduced motion, and assistive support.'**
  String get accessibilityPlaceholderDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
