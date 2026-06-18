class AppRoutes {
  const AppRoutes._();

  static const root = '/';
  static const home = '/home';
  static const progress = '/progress';
  static const revisions = '/revisions';
  static const sources = '/sources';
  static const coursePath = '/courses/:courseId';
  static const courseSheetPath = '/courses/:courseId/sheet';
  static const revisionSessionV2Path = '/revision-sessions/:sessionId';
  static const revisionSessionResultV2Path =
      '/revision-sessions/:sessionId/result';
  static const subjects = '/subjects';
  static const today = '/today';
  static const activities = '/activities';
  static const revisionSessionSegment = 'session';
  static const revisionSessionPath = '/activities/session';
  static const richClosedExercisePath = '/activities/rich-closed';
  static const profile = '/profile';
  static const onboarding = '/onboarding';
  static const signIn = '/sign-in';

  static String subjectDetail(String subjectId) => '/subjects/$subjectId';

  static String course(String courseId) => '/courses/$courseId';

  static String courseSheet(String courseId) => '/courses/$courseId/sheet';

  static String revisionSessionV2({
    required String sessionId,
    String? courseId,
    String? mode,
  }) {
    final queryParameters = <String, String>{};
    if (courseId != null && courseId.trim().isNotEmpty) {
      queryParameters['courseId'] = courseId.trim();
    }
    if (mode != null && mode.trim().isNotEmpty) {
      queryParameters['mode'] = mode.trim();
    }

    return Uri(
      path: '/revision-sessions/${sessionId.trim()}',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static String revisionSessionResultV2({
    required String sessionId,
    String? courseId,
    String? mode,
  }) {
    final queryParameters = <String, String>{};
    if (courseId != null && courseId.trim().isNotEmpty) {
      queryParameters['courseId'] = courseId.trim();
    }
    if (mode != null && mode.trim().isNotEmpty) {
      queryParameters['mode'] = mode.trim();
    }

    return Uri(
      path: '/revision-sessions/${sessionId.trim()}/result',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static String documentDetail({
    required String subjectId,
    required String documentId,
  }) {
    return '/subjects/$subjectId/documents/$documentId';
  }

  static String activitiesForSubject(String subjectId) {
    return Uri(
      path: activities,
      queryParameters: {'subjectId': subjectId},
    ).toString();
  }

  static String revisionSession({
    String? sessionId,
    String? subjectId,
    String? documentId,
    String? knowledgeUnitId,
    String? preferredAction,
  }) {
    final queryParameters = <String, String>{};
    if (sessionId != null && sessionId.trim().isNotEmpty) {
      queryParameters['sessionId'] = sessionId.trim();
    }
    if (subjectId != null && subjectId.trim().isNotEmpty) {
      queryParameters['subjectId'] = subjectId.trim();
    }
    if (documentId != null && documentId.trim().isNotEmpty) {
      queryParameters['documentId'] = documentId.trim();
    }
    if (knowledgeUnitId != null && knowledgeUnitId.trim().isNotEmpty) {
      queryParameters['knowledgeUnitId'] = knowledgeUnitId.trim();
    }
    if (preferredAction != null && preferredAction.trim().isNotEmpty) {
      queryParameters['preferredAction'] = preferredAction.trim();
    }

    return Uri(
      path: revisionSessionPath,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static String richClosedExercise({
    String? sessionId,
    String? subjectId,
    String? documentId,
    String? knowledgeUnitId,
  }) {
    final queryParameters = <String, String>{};
    if (sessionId != null && sessionId.trim().isNotEmpty) {
      queryParameters['sessionId'] = sessionId.trim();
    }
    if (subjectId != null && subjectId.trim().isNotEmpty) {
      queryParameters['subjectId'] = subjectId.trim();
    }
    if (documentId != null && documentId.trim().isNotEmpty) {
      queryParameters['documentId'] = documentId.trim();
    }
    if (knowledgeUnitId != null && knowledgeUnitId.trim().isNotEmpty) {
      queryParameters['knowledgeUnitId'] = knowledgeUnitId.trim();
    }

    return Uri(
      path: richClosedExercisePath,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }
}
