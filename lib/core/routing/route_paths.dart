import '../../app/router/app_routes.dart';

const String subjectsRoutePath = AppRoutes.subjects;
const String todayRoutePath = AppRoutes.today;
const String activitiesRoutePath = AppRoutes.activities;
const String revisionSessionRoutePath = AppRoutes.revisionSessionPath;
const String richClosedExerciseRoutePath = AppRoutes.richClosedExercisePath;
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
  return AppRoutes.documentDetail(subjectId: subjectId, documentId: documentId);
}

String revisionSessionRoutePathFor({
  String? sessionId,
  String? subjectId,
  String? documentId,
  String? knowledgeUnitId,
  String? preferredAction,
}) {
  return AppRoutes.revisionSession(
    sessionId: sessionId,
    subjectId: subjectId,
    documentId: documentId,
    knowledgeUnitId: knowledgeUnitId,
    preferredAction: preferredAction,
  );
}

String richClosedExerciseRoutePathFor({
  String? sessionId,
  String? subjectId,
  String? documentId,
  String? knowledgeUnitId,
}) {
  return AppRoutes.richClosedExercise(
    sessionId: sessionId,
    subjectId: subjectId,
    documentId: documentId,
    knowledgeUnitId: knowledgeUnitId,
  );
}
