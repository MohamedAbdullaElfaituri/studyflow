import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../shared/providers/app_providers.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final Set<String> _authPaths = {
    LoginScreen.routePath,
    SignupScreen.routePath,
    ForgotPasswordScreen.routePath,
    ResetPasswordScreen.routePath,
  };

  static final Set<String> _publicPaths = {
    SplashScreen.routePath,
    OnboardingScreen.routePath,
    LoginScreen.routePath,
    SignupScreen.routePath,
    ForgotPasswordScreen.routePath,
  };

  static GoRouter build(Ref ref, Listenable refreshListenable) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: SplashScreen.routePath,
      refreshListenable: refreshListenable,
      redirect: (context, state) {
        final authAsync = ref.read(authControllerProvider);
        final location = state.matchedLocation;

        if (authAsync.isLoading && !authAsync.hasValue) {
          return location == SplashScreen.routePath
              ? null
              : SplashScreen.routePath;
        }

        final authState = authAsync.valueOrNull;
        if (authState == null) {
          return location == SplashScreen.routePath
              ? null
              : SplashScreen.routePath;
        }

        if (authState.requiresPasswordReset) {
          return location == ResetPasswordScreen.routePath
              ? null
              : ResetPasswordScreen.routePath;
        }

        if (!authState.onboardingCompleted) {
          return location == OnboardingScreen.routePath
              ? null
              : OnboardingScreen.routePath;
        }

        if (!authState.isAuthenticated) {
          if (_publicPaths.contains(location)) {
            return location == SplashScreen.routePath
                ? LoginScreen.routePath
                : null;
          }
          return LoginScreen.routePath;
        }

        if (location == SplashScreen.routePath ||
            location == OnboardingScreen.routePath ||
            _authPaths.contains(location)) {
          return HomeScreen.routePath;
        }

        return null;
      },
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
        GoRoute(
          path: ResetPasswordScreen.routePath,
          builder: (context, state) => const ResetPasswordScreen(),
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
          builder: (context, state) => CourseEditorScreen(
              courseId: state.uri.queryParameters['courseId']),
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
