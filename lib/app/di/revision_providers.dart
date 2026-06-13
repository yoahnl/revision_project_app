import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/activities/application/activity_controller.dart';
import '../../features/activities/data/http_activities_api.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/data/firebase_auth_repository.dart';
import '../../features/auth/data/http_student_profile_bootstrapper.dart';
import '../../features/documents/application/documents_controller.dart';
import '../../features/documents/data/documents_api.dart';
import '../../features/onboarding/application/revision_goals_controller.dart';
import '../../features/onboarding/data/http_revision_goals_api.dart';
import '../../features/subjects/application/subjects_controller.dart';
import '../../features/subjects/data/http_subjects_repository.dart';
import '../../features/today/application/today_controller.dart';
import '../../features/today/data/http_today_repository.dart';
import 'infrastructure_providers.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final authProfileBootstrapperProvider = Provider<AuthProfileBootstrapper>((
  ref,
) {
  final repository = ref.read(authRepositoryProvider);
  return HttpStudentProfileBootstrapper(
    apiBaseUrl: ref.read(dioProvider).options.baseUrl,
    dio: ref.read(dioProvider),
    getIdToken: repository.requireIdToken,
  );
});

final authControllerProvider = Provider<AuthController>((ref) {
  final controller = AuthController(
    ref.read(authRepositoryProvider),
    profileBootstrapper: ref.read(authProfileBootstrapperProvider),
  );
  controller.start();
  ref.onDispose(controller.dispose);
  return controller;
});

final subjectsRepositoryProvider = Provider<SubjectsRepository>((ref) {
  final dio = ref.read(dioProvider);
  final auth = ref.read(authControllerProvider);
  return HttpSubjectsRepository(dio: dio, getIdToken: auth.requireIdToken);
});

final subjectsControllerProvider = Provider<SubjectsController>((ref) {
  return SubjectsController(ref.read(subjectsRepositoryProvider));
});

final revisionGoalsRepositoryProvider = Provider<RevisionGoalsRepository>((
  ref,
) {
  final dio = ref.read(dioProvider);
  final auth = ref.read(authControllerProvider);
  return HttpRevisionGoalsApi(dio: dio, getIdToken: auth.requireIdToken);
});

final revisionGoalsControllerProvider = Provider<RevisionGoalsController>((
  ref,
) {
  return RevisionGoalsController(ref.read(revisionGoalsRepositoryProvider));
});

final documentsApiProvider = Provider<DocumentsApi>((ref) {
  final dio = ref.read(dioProvider);
  final auth = ref.read(authControllerProvider);
  return HttpDocumentsApi(dio: dio, getIdToken: auth.requireIdToken);
});

final documentsControllerProvider = Provider<DocumentsController>((ref) {
  return DocumentsController(ref.read(documentsApiProvider));
});

final activityApiProvider = Provider<ActivityApi>((ref) {
  final dio = ref.read(dioProvider);
  final auth = ref.read(authControllerProvider);
  return HttpActivitiesApi(dio: dio, getIdToken: auth.requireIdToken);
});

final activityControllerProvider = Provider<ActivityController>((ref) {
  return ActivityController(ref.read(activityApiProvider));
});

final todayRepositoryProvider = Provider<TodayRepository>((ref) {
  final dio = ref.read(dioProvider);
  final auth = ref.read(authControllerProvider);
  return HttpTodayRepository(dio: dio, getIdToken: auth.requireIdToken);
});

final todayControllerProvider = Provider<TodayController>((ref) {
  return TodayController(ref.read(todayRepositoryProvider));
});
