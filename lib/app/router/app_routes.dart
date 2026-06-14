class AppRoutes {
  const AppRoutes._();

  static const root = '/';
  static const subjects = '/subjects';
  static const today = '/today';
  static const activities = '/activities';
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
}
