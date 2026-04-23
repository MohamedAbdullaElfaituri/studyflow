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
    AuthLoadingScreen.routePath,
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
        final authNavigationPending = ref.read(authNavigationProvider);
        final authNotice = ref.read(authNoticeProvider);
        final launchSplashCompleted = ref.read(launchSplashCompletedProvider);
        final location = state.matchedLocation;
        final hasRecoveryNotice = authNotice == 'recovery_link_invalid' ||
            authNotice == 'recovery_link_expired' ||
            authNotice == 'recovery_session_missing';

        if (!launchSplashCompleted) {
          return location == SplashScreen.routePath
              ? null
              : SplashScreen.routePath;
        }

        if (authAsync.isLoading && !authAsync.hasValue) {
          return location == SplashScreen.routePath ||
                  location == AuthLoadingScreen.routePath
              ? null
              : SplashScreen.routePath;
        }

        final authState = authAsync.valueOrNull;
        if (authState == null) {
          return location == SplashScreen.routePath ||
                  location == AuthLoadingScreen.routePath
              ? null
              : SplashScreen.routePath;
        }

        if (authNavigationPending && !authState.isAuthenticated) {
          return location == AuthLoadingScreen.routePath
              ? null
              : AuthLoadingScreen.routePath;
        }

        if (authState.requiresPasswordReset) {
          return location == ResetPasswordScreen.routePath
              ? null
              : ResetPasswordScreen.routePath;
        }

        if (authState.isAuthenticated) {
          final studyDataAsync = ref.read(studyDataControllerProvider);
          final isStudyDataBootstrapping =
              studyDataAsync.isLoading && !studyDataAsync.hasValue;

          if (isStudyDataBootstrapping) {
            return location == AuthLoadingScreen.routePath
                ? null
                : AuthLoadingScreen.routePath;
          }

          if (location == SplashScreen.routePath ||
              location == AuthLoadingScreen.routePath ||
              location == OnboardingScreen.routePath ||
              _authPaths.contains(location)) {
            return HomeScreen.routePath;
          }
          return null;
        }

        if (!authState.onboardingCompleted) {
          return location == OnboardingScreen.routePath
              ? null
              : OnboardingScreen.routePath;
        }

        if (!authState.isAuthenticated) {
          if (location == ResetPasswordScreen.routePath ||
              (location == AuthLoadingScreen.routePath && hasRecoveryNotice)) {
            return location == ForgotPasswordScreen.routePath
                ? null
                : ForgotPasswordScreen.routePath;
          }
          if (location == AuthLoadingScreen.routePath) {
            return LoginScreen.routePath;
          }
          if (_publicPaths.contains(location)) {
            return location == SplashScreen.routePath
                ? LoginScreen.routePath
                : null;
          }
          return LoginScreen.routePath;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: SplashScreen.routePath,
          pageBuilder: (context, state) => _fadePage(
            state,
            const SplashScreen(),
          ),
        ),
        GoRoute(
          path: AuthLoadingScreen.routePath,
          pageBuilder: (context, state) => _fadePage(
            state,
            const AuthLoadingScreen(),
          ),
        ),
        GoRoute(
          path: OnboardingScreen.routePath,
          pageBuilder: (context, state) => _fadePage(
            state,
            const OnboardingScreen(),
          ),
        ),
        GoRoute(
          path: LoginScreen.routePath,
          pageBuilder: (context, state) => _authSwapPage(
            state,
            const LoginScreen(),
          ),
        ),
        GoRoute(
          path: SignupScreen.routePath,
          pageBuilder: (context, state) => _authSwapPage(
            state,
            const SignupScreen(),
          ),
        ),
        GoRoute(
          path: ForgotPasswordScreen.routePath,
          pageBuilder: (context, state) => _fadePage(
            state,
            const ForgotPasswordScreen(),
          ),
        ),
        GoRoute(
          path: ResetPasswordScreen.routePath,
          pageBuilder: (context, state) => _fadePage(
            state,
            const ResetPasswordScreen(),
          ),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => MainNavigationShell(
            navigationShell: navigationShell,
            currentUser: ref.read(currentUserProvider),
          ),
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
          pageBuilder: (context, state) => _slidePage(
            state,
            const CoursesScreen(),
          ),
        ),
        GoRoute(
          path: CourseDetailScreen.routePath,
          pageBuilder: (context, state) => _slidePage(
            state,
            CourseDetailScreen(courseId: state.pathParameters['courseId']!),
          ),
        ),
        GoRoute(
          path: CourseEditorScreen.routePath,
          pageBuilder: (context, state) => _slidePage(
            state,
            CourseEditorScreen(
              courseId: state.uri.queryParameters['courseId'],
            ),
          ),
        ),
        GoRoute(
          path: TaskEditorScreen.routePath,
          pageBuilder: (context, state) => _slidePage(
            state,
            TaskEditorScreen(taskId: state.uri.queryParameters['taskId']),
          ),
        ),
        GoRoute(
          path: TaskDetailScreen.routePath,
          pageBuilder: (context, state) => _slidePage(
            state,
            TaskDetailScreen(taskId: state.pathParameters['taskId']!),
          ),
        ),
        GoRoute(
          path: NotesScreen.routePath,
          pageBuilder: (context, state) => _slidePage(
            state,
            const NotesScreen(),
          ),
        ),
        GoRoute(
          path: ExamsScreen.routePath,
          pageBuilder: (context, state) => _slidePage(
            state,
            const ExamsScreen(),
          ),
        ),
        GoRoute(
          path: ExamEditorScreen.routePath,
          pageBuilder: (context, state) => _slidePage(
            state,
            ExamEditorScreen(examId: state.uri.queryParameters['examId']),
          ),
        ),
        GoRoute(
          path: HabitsScreen.routePath,
          pageBuilder: (context, state) => _slidePage(
            state,
            const HabitsScreen(),
          ),
        ),
        GoRoute(
          path: HabitEditorScreen.routePath,
          pageBuilder: (context, state) => _slidePage(
            state,
            HabitEditorScreen(habitId: state.uri.queryParameters['habitId']),
          ),
        ),
        GoRoute(
          path: SearchScreen.routePath,
          pageBuilder: (context, state) => _slidePage(
            state,
            const SearchScreen(),
          ),
        ),
        GoRoute(
          path: NoteEditorScreen.routePath,
          pageBuilder: (context, state) => _slidePage(
            state,
            NoteEditorScreen(noteId: state.uri.queryParameters['noteId']),
          ),
        ),
        GoRoute(
          path: AnalyticsScreen.routePath,
          pageBuilder: (context, state) => _slidePage(
            state,
            const AnalyticsScreen(),
          ),
        ),
        GoRoute(
          path: GoalsScreen.routePath,
          pageBuilder: (context, state) => _slidePage(
            state,
            const GoalsScreen(),
          ),
        ),
        GoRoute(
          path: SettingsScreen.routePath,
          pageBuilder: (context, state) => _slidePage(
            state,
            const SettingsScreen(),
          ),
        ),
        GoRoute(
          path: ProfileEditScreen.routePath,
          pageBuilder: (context, state) => _slidePage(
            state,
            const ProfileEditScreen(),
          ),
        ),
      ],
      errorBuilder: (context, state) => AppPage(
        child: Center(
          child: ErrorStateCard(
            message: context.l10n.genericNavigationError,
            onRetry: () => context.go(HomeScreen.routePath),
          ),
        ),
      ),
    );
  }
}

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 180),
    reverseTransitionDuration: const Duration(milliseconds: 140),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      );
      return FadeTransition(
        opacity: fade,
        child: child,
      );
    },
  );
}

CustomTransitionPage<void> _authSwapPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 360),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final disableAnimations =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (disableAnimations) {
        return child;
      }

      final isRtl = Directionality.of(context) == TextDirection.rtl;
      final enteringDx = isRtl ? -0.12 : 0.12;
      final leavingDx = -enteringDx * 0.42;

      final entrance = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final exit = CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final entranceFade = CurvedAnimation(
        parent: animation,
        curve: const Interval(0, 0.82, curve: Curves.easeOut),
        reverseCurve: Curves.easeIn,
      );

      return SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: Offset(leavingDx, 0),
        ).animate(exit),
        child: FadeTransition(
          opacity: Tween<double>(
            begin: 1,
            end: 0.74,
          ).animate(exit),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(enteringDx, 0),
              end: Offset.zero,
            ).animate(entrance),
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.985,
                end: 1,
              ).animate(entrance),
              alignment: Alignment.topCenter,
              child: FadeTransition(
                opacity: entranceFade,
                child: child,
              ),
            ),
          ),
        ),
      );
    },
  );
}

CustomTransitionPage<void> _slidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 160),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      final offset = Tween<Offset>(
        begin: const Offset(0.04, 0.02),
        end: Offset.zero,
      ).animate(curved);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(position: offset, child: child),
      );
    },
  );
}
