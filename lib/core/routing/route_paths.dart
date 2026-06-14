import '../../app/router/app_routes.dart';

const String subjectsRoutePath = AppRoutes.subjects;
const String todayRoutePath = AppRoutes.today;
const String activitiesRoutePath = AppRoutes.activities;
const String profileRoutePath = AppRoutes.profile;
const String onboardingRoutePath = AppRoutes.onboarding;
const String signInRoutePath = AppRoutes.signIn;
const String subjectDetailRoutePattern = '/subjects/:subjectId';
const String documentDetailRoutePattern =
    '/subjects/:subjectId/documents/:documentId';

String subjectDetailRoutePath(String subjectId) {
  return AppRoutes.subjectDetail(subjectId);
}

String documentDetailRoutePath({
  required String subjectId,
  required String documentId,
}) {
  return AppRoutes.documentDetail(
    subjectId: subjectId,
    documentId: documentId,
  );
}
