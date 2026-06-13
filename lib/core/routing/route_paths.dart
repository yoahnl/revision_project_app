const String subjectsRoutePath = '/subjects';
const String todayRoutePath = '/today';
const String activitiesRoutePath = '/activities';
const String profileRoutePath = '/profile';
const String onboardingRoutePath = '/onboarding';
const String signInRoutePath = '/sign-in';

const String subjectDetailRoutePattern = '/subjects/:subjectId';

String subjectDetailRoutePath(String subjectId) => '/subjects/$subjectId';
