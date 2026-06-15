class AppRoutes {
  const AppRoutes._();

  static const root = '/';
  static const subjects = '/subjects';
  static const today = '/today';
  static const activities = '/activities';
  static const revisionSessionSegment = 'session';
  static const revisionSessionPath = '/activities/session';
  static const profile = '/profile';
  static const onboarding = '/onboarding';
  static const signIn = '/sign-in';

  static String subjectDetail(String subjectId) => '/subjects/$subjectId';

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
}
