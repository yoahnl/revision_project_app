import 'package:go_router/go_router.dart';

import '../../app/presentation/revision_home_shell.dart';
import '../../features/activities/application/activity_controller.dart';
import '../../features/activities/presentation/activities_page.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/sign_in_page.dart';
import '../../features/documents/application/documents_controller.dart';
import '../../features/onboarding/application/revision_goals_controller.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/subjects/application/subjects_controller.dart';
import '../../features/subjects/presentation/subject_detail_page.dart';
import '../../features/subjects/presentation/subjects_home_page.dart';
import '../../features/today/application/today_controller.dart';
import '../../features/today/presentation/today_page.dart';
import 'route_paths.dart';

GoRouter createAppRouter({
  required AuthController authController,
  required SubjectsController subjectsController,
  required RevisionGoalsController revisionGoalsController,
  required DocumentsController documentsController,
  required ActivityController activityController,
  required TodayController todayController,
}) {
  return GoRouter(
    initialLocation: subjectsRoutePath,
    refreshListenable: authController,
    redirect: (context, state) {
      final isSigningIn = state.uri.path == signInRoutePath;

      if (authController.isLoading) {
        return null;
      }

      if (!authController.isSignedIn) {
        return isSigningIn ? null : signInRoutePath;
      }

      if (isSigningIn) {
        return subjectsRoutePath;
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => subjectsRoutePath),
      GoRoute(
        path: signInRoutePath,
        builder: (context, state) => SignInPage(authController: authController),
      ),
      GoRoute(
        path: onboardingRoutePath,
        builder: (context, state) => OnboardingPage(
          subjectsController: subjectsController,
          revisionGoalsController: revisionGoalsController,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return RevisionHomeShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: subjectsRoutePath,
                builder: (context, state) =>
                    SubjectsHomePage(controller: subjectsController),
                routes: [
                  GoRoute(
                    path: ':subjectId',
                    builder: (context, state) => SubjectDetailPage(
                      subjectId: state.pathParameters['subjectId'] ?? '',
                      controller: subjectsController,
                      documentsController: documentsController,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: todayRoutePath,
                builder: (context, state) =>
                    TodayPage(controller: todayController),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: activitiesRoutePath,
                builder: (context, state) => ActivitiesPage(
                  controller: activityController,
                  subjectId: state.uri.queryParameters['subjectId'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: profileRoutePath,
                builder: (context, state) =>
                    ProfilePage(authController: authController),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
