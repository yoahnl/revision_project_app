import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/config/app_config.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';
import '../features/activities/application/activity_controller.dart';
import '../features/activities/data/http_activities_api.dart';
import '../features/auth/application/auth_controller.dart';
import '../features/auth/data/firebase_auth_repository.dart';
import '../features/auth/data/http_student_profile_bootstrapper.dart';
import '../features/documents/application/documents_controller.dart';
import '../features/documents/data/documents_api.dart';
import '../features/onboarding/application/revision_goals_controller.dart';
import '../features/onboarding/data/http_revision_goals_api.dart';
import '../features/subjects/application/subjects_controller.dart';
import '../features/subjects/data/http_subjects_repository.dart';
import '../features/today/application/today_controller.dart';
import '../features/today/data/http_today_repository.dart';

class RevisionApp extends StatefulWidget {
  const RevisionApp({
    this.authController,
    this.subjectsController,
    this.revisionGoalsController,
    this.documentsController,
    this.activityController,
    this.todayController,
    super.key,
  });

  final AuthController? authController;
  final SubjectsController? subjectsController;
  final RevisionGoalsController? revisionGoalsController;
  final DocumentsController? documentsController;
  final ActivityController? activityController;
  final TodayController? todayController;

  @override
  State<RevisionApp> createState() => _RevisionAppState();
}

class _RevisionAppState extends State<RevisionApp> {
  late final bool _ownsAuthController = widget.authController == null;
  late final Dio _dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
  late final AuthRepository _authRepository = FirebaseAuthRepository();
  late final AuthController _authController =
      widget.authController ??
      AuthController(
        _authRepository,
        profileBootstrapper: HttpStudentProfileBootstrapper(
          apiBaseUrl: AppConfig.apiBaseUrl,
          getIdToken: _authRepository.requireIdToken,
        ),
      );
  late final SubjectsController _subjectsController =
      widget.subjectsController ??
      SubjectsController(
        HttpSubjectsRepository(
          dio: _dio,
          getIdToken: _authController.requireIdToken,
        ),
      );
  late final RevisionGoalsController _revisionGoalsController =
      widget.revisionGoalsController ??
      RevisionGoalsController(
        HttpRevisionGoalsApi(
          dio: _dio,
          getIdToken: _authController.requireIdToken,
        ),
      );
  late final DocumentsController _documentsController =
      widget.documentsController ??
      DocumentsController(
        HttpDocumentsApi(dio: _dio, getIdToken: _authController.requireIdToken),
      );
  late final ActivityController _activityController =
      widget.activityController ??
      ActivityController(
        HttpActivitiesApi(
          dio: _dio,
          getIdToken: _authController.requireIdToken,
        ),
      );
  late final TodayController _todayController =
      widget.todayController ??
      TodayController(
        HttpTodayRepository(
          dio: _dio,
          getIdToken: _authController.requireIdToken,
        ),
      );
  late final GoRouter _router = createAppRouter(
    authController: _authController,
    subjectsController: _subjectsController,
    revisionGoalsController: _revisionGoalsController,
    documentsController: _documentsController,
    activityController: _activityController,
    todayController: _todayController,
  );

  @override
  void initState() {
    super.initState();
    _authController.start();
  }

  @override
  void dispose() {
    _router.dispose();
    if (_ownsAuthController) {
      _authController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Revision',
      theme: AppTheme.light(),
      routerConfig: _router,
    );
  }
}
