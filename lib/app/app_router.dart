import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/app_widgets.dart';
import '../features/analytics/presentation/analytics_screen.dart';
import '../features/auth/presentation/auth_screens.dart';
import '../features/calendar/presentation/calendar_screen.dart';
import '../features/courses/presentation/courses_screens.dart';
import '../features/exams/presentation/exams_screens.dart';
import '../features/focus/presentation/focus_screen.dart';
import '../features/goals/presentation/goals_screen.dart';
import '../features/habits/presentation/habits_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/notes/presentation/notes_screens.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/profile/presentation/profile_screens.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/tasks/presentation/tasks_screens.dart';
import '../shared/extensions/build_context_x.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter build() {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: SplashScreen.routePath,
      routes: [
        GoRoute(
          path: SplashScreen.routePath,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: OnboardingScreen.routePath,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: LoginScreen.routePath,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: SignupScreen.routePath,
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: ForgotPasswordScreen.routePath,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              MainNavigationShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: HomeScreen.routePath,
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: TasksScreen.routePath,
                  builder: (context, state) => const TasksScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: CalendarScreen.routePath,
                  builder: (context, state) => const CalendarScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: FocusScreen.routePath,
                  builder: (context, state) => const FocusScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: ProfileScreen.routePath,
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: CoursesScreen.routePath,
          builder: (context, state) => const CoursesScreen(),
        ),
        GoRoute(
          path: CourseDetailScreen.routePath,
          builder: (context, state) =>
              CourseDetailScreen(courseId: state.pathParameters['courseId']!),
        ),
        GoRoute(
          path: CourseEditorScreen.routePath,
          builder: (context, state) =>
              CourseEditorScreen(courseId: state.uri.queryParameters['courseId']),
        ),
        GoRoute(
          path: TaskDetailScreen.routePath,
          builder: (context, state) =>
              TaskDetailScreen(taskId: state.pathParameters['taskId']!),
        ),
        GoRoute(
          path: TaskEditorScreen.routePath,
          builder: (context, state) =>
              TaskEditorScreen(taskId: state.uri.queryParameters['taskId']),
        ),
        GoRoute(
          path: NotesScreen.routePath,
          builder: (context, state) => const NotesScreen(),
        ),
        GoRoute(
          path: ExamsScreen.routePath,
          builder: (context, state) => const ExamsScreen(),
        ),
        GoRoute(
          path: ExamEditorScreen.routePath,
          builder: (context, state) =>
              ExamEditorScreen(examId: state.uri.queryParameters['examId']),
        ),
        GoRoute(
          path: HabitsScreen.routePath,
          builder: (context, state) => const HabitsScreen(),
        ),
        GoRoute(
          path: HabitEditorScreen.routePath,
          builder: (context, state) =>
              HabitEditorScreen(habitId: state.uri.queryParameters['habitId']),
        ),
        GoRoute(
          path: SearchScreen.routePath,
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: NoteEditorScreen.routePath,
          builder: (context, state) =>
              NoteEditorScreen(noteId: state.uri.queryParameters['noteId']),
        ),
        GoRoute(
          path: AnalyticsScreen.routePath,
          builder: (context, state) => const AnalyticsScreen(),
        ),
        GoRoute(
          path: GoalsScreen.routePath,
          builder: (context, state) => const GoalsScreen(),
        ),
        GoRoute(
          path: SettingsScreen.routePath,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: ProfileEditScreen.routePath,
          builder: (context, state) => const ProfileEditScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text(context.l10n.genericNavigationError),
        ),
      ),
    );
  }
}
