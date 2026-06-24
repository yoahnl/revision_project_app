# PLUS-03A - Evidence pack App

Ce pack capture le diff complet des fichiers produit/test App pour PLUS-03A. Les documents V3 du lot sont exclus pour eviter un artefact auto-recursif ; ils sont listes dans le rapport.

## Diff stat produit/test

```text
 lib/app/router/app_router.dart                     |   7 +
 lib/app/router/app_routes.dart                     |   6 +
 .../courses/application/courses_providers.dart     |  10 +
 .../courses/data/http_courses_repository.dart      | 242 +++++++++++++++++++++
 lib/features/courses/domain/course_models.dart     | 106 +++++++++
 .../courses/domain/courses_repository.dart         |   4 +
 .../courses/presentation/course_detail_page.dart   |   9 +-
 test/fakes/in_memory_courses_repository.dart       |  45 ++++
 test/features/courses/course_detail_page_test.dart |  88 ++++++++
 .../courses/http_courses_repository_test.dart      |  90 ++++++++
 10 files changed, 604 insertions(+), 3 deletions(-)

Fichiers nouveaux non suivis hors docs :
lib/features/courses/presentation/course_exam_preparation_page.dart
test/features/courses/course_exam_preparation_page_test.dart
```

## Diff complet des fichiers suivis produit/test

```diff
diff --git a/lib/app/router/app_router.dart b/lib/app/router/app_router.dart
index 31459ca..7240f5e 100644
--- a/lib/app/router/app_router.dart
+++ b/lib/app/router/app_router.dart
@@ -5,6 +5,7 @@ import 'package:go_router/go_router.dart';
 import '../../features/activities/application/activity_controller.dart';
 import '../../features/auth/application/auth_controller.dart';
 import '../../features/courses/presentation/course_detail_page.dart';
+import '../../features/courses/presentation/course_exam_preparation_page.dart';
 import '../../features/courses/presentation/course_revision_sheet_page.dart';
 import '../../features/courses/presentation/courses_home_page.dart';
 import '../../features/courses/presentation/revisions_pending_page.dart';
@@ -99,6 +100,12 @@ GoRouter createAppRouter({
                   courseId: state.pathParameters['courseId'] ?? '',
                 ),
               ),
+              GoRoute(
+                path: AppRoutes.courseExamPreparationPath,
+                builder: (context, state) => CourseExamPreparationPage(
+                  courseId: state.pathParameters['courseId'] ?? '',
+                ),
+              ),
               GoRoute(
                 path: AppRoutes.courseSheetPath,
                 builder: (context, state) => CourseRevisionSheetPage(
diff --git a/lib/app/router/app_routes.dart b/lib/app/router/app_routes.dart
index 8f0d8d8..c8ebefa 100644
--- a/lib/app/router/app_routes.dart
+++ b/lib/app/router/app_routes.dart
@@ -7,6 +7,8 @@ class AppRoutes {
   static const revisions = '/revisions';
   static const sources = '/sources';
   static const coursePath = '/courses/:courseId';
+  static const courseExamPreparationPath =
+      '/courses/:courseId/exam-preparation';
   static const courseSheetPath = '/courses/:courseId/sheet';
   static const courseSheetSourcesPath = '/courses/:courseId/sheet/sources';
   static const revisionSessionV2Path = '/revision-sessions/:sessionId';
@@ -28,6 +30,10 @@ class AppRoutes {

   static String course(String courseId) => '/courses/$courseId';

+  static String courseExamPreparation(String courseId) {
+    return '/courses/$courseId/exam-preparation';
+  }
+
   static String courseSheet(String courseId) => '/courses/$courseId/sheet';

   static String courseSheetSources(String courseId) {
diff --git a/lib/features/courses/application/courses_providers.dart b/lib/features/courses/application/courses_providers.dart
index c888e5b..8775c27 100644
--- a/lib/features/courses/application/courses_providers.dart
+++ b/lib/features/courses/application/courses_providers.dart
@@ -74,6 +74,16 @@ final courseRichClosedHistoryProvider =
           .getCourseRichClosedHistory(courseId: courseId);
     });

+final courseExamPreparationOptionsProvider =
+    FutureProvider.family<CourseExamPreparationOptions, String>((
+      ref,
+      courseId,
+    ) {
+      return ref
+          .read(coursesRepositoryProvider)
+          .getExamPreparationOptions(courseId: courseId);
+    });
+
 typedef CourseQuestionBankReadinessKey = ({String courseId, int questionCount});

 final courseQuestionBankReadinessProvider =
diff --git a/lib/features/courses/data/http_courses_repository.dart b/lib/features/courses/data/http_courses_repository.dart
index f2661dd..4d4740c 100644
--- a/lib/features/courses/data/http_courses_repository.dart
+++ b/lib/features/courses/data/http_courses_repository.dart
@@ -477,6 +477,25 @@ class HttpCoursesRepository implements CoursesRepository {
     }
   }

+  @override
+  Future<CourseExamPreparationOptions> getExamPreparationOptions({
+    required String courseId,
+  }) async {
+    try {
+      final response = await _dio.get<Object?>(
+        '/courses/${Uri.encodeComponent(courseId)}/exam-preparation/options',
+        options: await _authorizedOptions(),
+      );
+
+      return _CourseExamPreparationOptionsJson(response.data).toOptions();
+    } on DioException catch (error) {
+      if (error.response?.statusCode == 404) {
+        throw const CourseNotFoundException('Course not found');
+      }
+      rethrow;
+    }
+  }
+
   @override
   Future<CourseProgress> getCourseProgress({required String courseId}) async {
     try {
@@ -1012,6 +1031,193 @@ class _CourseRichClosedHistoryItemJson {
   }
 }

+class _CourseExamPreparationOptionsJson {
+  const _CourseExamPreparationOptionsJson(this.value);
+
+  final Object? value;
+
+  CourseExamPreparationOptions toOptions() {
+    final json = value;
+
+    if (json is! Map<String, Object?>) {
+      throw const FormatException('Invalid exam preparation response');
+    }
+
+    final course = json['course'];
+    final readiness = json['readiness'];
+    final scopeOptions = json['scopeOptions'];
+    final questionCountOptions = json['questionCountOptions'];
+    final supportedQuestionKinds = json['supportedQuestionKinds'];
+    final nextStep = json['nextStep'];
+
+    if (course is! Map<String, Object?> ||
+        readiness is! Map<String, Object?> ||
+        scopeOptions is! List ||
+        questionCountOptions is! List ||
+        supportedQuestionKinds is! List ||
+        nextStep is! Map<String, Object?>) {
+      throw const FormatException('Invalid exam preparation response');
+    }
+
+    return CourseExamPreparationOptions(
+      course: CourseExamPreparationCourse(
+        id: _requiredString(course['id'], 'Invalid exam preparation response'),
+        title: _requiredString(
+          course['title'],
+          'Invalid exam preparation response',
+        ),
+        subjectId: _requiredString(
+          course['subjectId'],
+          'Invalid exam preparation response',
+        ),
+      ),
+      readiness: _CourseExamPreparationReadinessJson(readiness).toReadiness(),
+      scopeOptions: scopeOptions
+          .map((item) => _CourseExamPreparationScopeOptionJson(item).toOption())
+          .toList(growable: false),
+      questionCountOptions: questionCountOptions
+          .map(
+            (item) => _requiredInt(item, 'Invalid exam preparation response'),
+          )
+          .toList(growable: false),
+      defaultQuestionCount: _optionalInt(json['defaultQuestionCount']),
+      supportedQuestionKinds: supportedQuestionKinds
+          .map(
+            (item) =>
+                _requiredString(item, 'Invalid exam preparation response'),
+          )
+          .toList(growable: false),
+      defaultConfig: json['defaultConfig'] == null
+          ? null
+          : _CourseExamPreparationConfigJson(json['defaultConfig']).toConfig(),
+      nextStep: CourseExamPreparationNextStep(
+        kind: _requiredString(
+          nextStep['kind'],
+          'Invalid exam preparation response',
+        ),
+        userMessage: _requiredString(
+          nextStep['userMessage'],
+          'Invalid exam preparation response',
+        ),
+      ),
+    );
+  }
+}
+
+class _CourseExamPreparationReadinessJson {
+  const _CourseExamPreparationReadinessJson(this.value);
+
+  final Map<String, Object?> value;
+
+  CourseExamPreparationReadiness toReadiness() {
+    final blockers = value['blockers'];
+    if (blockers is! List) {
+      throw const FormatException('Invalid exam preparation response');
+    }
+
+    return CourseExamPreparationReadiness(
+      canPrepare: _requiredBool(
+        value['canPrepare'],
+        'Invalid exam preparation response',
+      ),
+      state: _parseExamPreparationReadinessState(
+        _requiredString(value['state'], 'Invalid exam preparation response'),
+      ),
+      userMessage: _requiredString(
+        value['userMessage'],
+        'Invalid exam preparation response',
+      ),
+      blockers: blockers
+          .map(
+            (item) =>
+                _requiredString(item, 'Invalid exam preparation response'),
+          )
+          .toList(growable: false),
+      readySourceCount: _requiredInt(
+        value['readySourceCount'],
+        'Invalid exam preparation response',
+      ),
+      readyKnowledgeUnitCount: _requiredInt(
+        value['readyKnowledgeUnitCount'],
+        'Invalid exam preparation response',
+      ),
+      availableQuestionCount: _requiredInt(
+        value['availableQuestionCount'],
+        'Invalid exam preparation response',
+      ),
+    );
+  }
+}
+
+class _CourseExamPreparationScopeOptionJson {
+  const _CourseExamPreparationScopeOptionJson(this.value);
+
+  final Object? value;
+
+  CourseExamPreparationScopeOption toOption() {
+    final json = value;
+
+    if (json is! Map<String, Object?>) {
+      throw const FormatException('Invalid exam preparation response');
+    }
+
+    return CourseExamPreparationScopeOption(
+      kind: _parseExamPreparationScopeKind(
+        _requiredString(json['kind'], 'Invalid exam preparation response'),
+      ),
+      id: _requiredString(json['id'], 'Invalid exam preparation response'),
+      label: _requiredString(
+        json['label'],
+        'Invalid exam preparation response',
+      ),
+      readyQuestionCount: _requiredInt(
+        json['readyQuestionCount'],
+        'Invalid exam preparation response',
+      ),
+      readyKnowledgeUnitCount: _requiredInt(
+        json['readyKnowledgeUnitCount'],
+        'Invalid exam preparation response',
+      ),
+      canSelect: _requiredBool(
+        json['canSelect'],
+        'Invalid exam preparation response',
+      ),
+    );
+  }
+}
+
+class _CourseExamPreparationConfigJson {
+  const _CourseExamPreparationConfigJson(this.value);
+
+  final Object? value;
+
+  CourseExamPreparationConfig toConfig() {
+    final json = value;
+
+    if (json is! Map<String, Object?>) {
+      throw const FormatException('Invalid exam preparation response');
+    }
+
+    return CourseExamPreparationConfig(
+      scopeKind: _parseExamPreparationScopeKind(
+        _requiredString(json['scopeKind'], 'Invalid exam preparation response'),
+      ),
+      scopeId: _requiredString(
+        json['scopeId'],
+        'Invalid exam preparation response',
+      ),
+      questionCount: _requiredInt(
+        json['questionCount'],
+        'Invalid exam preparation response',
+      ),
+      complexityProfile: _requiredString(
+        json['complexityProfile'],
+        'Invalid exam preparation response',
+      ),
+    );
+  }
+}
+
 class _CourseProgressJson {
   const _CourseProgressJson(this.value);

@@ -1267,6 +1473,22 @@ int _requiredInt(Object? value, String message) {
   throw FormatException(message);
 }

+int? _optionalInt(Object? value) {
+  if (value == null) {
+    return null;
+  }
+
+  return _requiredInt(value, 'Invalid optional int response');
+}
+
+bool _requiredBool(Object? value, String message) {
+  if (value is bool) {
+    return value;
+  }
+
+  throw FormatException(message);
+}
+
 DateTime _requiredDate(Object? value, String message) {
   final parsed = _parseOptionalDate(value);
   if (parsed == null) {
@@ -1275,3 +1497,23 @@ DateTime _requiredDate(Object? value, String message) {

   return parsed;
 }
+
+CourseExamPreparationReadinessState _parseExamPreparationReadinessState(
+  String value,
+) {
+  return switch (value) {
+    'READY' => CourseExamPreparationReadinessState.ready,
+    'PARTIALLY_READY' => CourseExamPreparationReadinessState.partiallyReady,
+    'NOT_READY' => CourseExamPreparationReadinessState.notReady,
+    'BLOCKED' => CourseExamPreparationReadinessState.blocked,
+    _ => CourseExamPreparationReadinessState.unknown,
+  };
+}
+
+CourseExamPreparationScopeKind _parseExamPreparationScopeKind(String value) {
+  return switch (value) {
+    'course' => CourseExamPreparationScopeKind.course,
+    'source' => CourseExamPreparationScopeKind.source,
+    _ => CourseExamPreparationScopeKind.unknown,
+  };
+}
diff --git a/lib/features/courses/domain/course_models.dart b/lib/features/courses/domain/course_models.dart
index 6c9cedf..2cfbd5c 100644
--- a/lib/features/courses/domain/course_models.dart
+++ b/lib/features/courses/domain/course_models.dart
@@ -229,6 +229,112 @@ class CourseQuestionBankReadiness {
   final String userMessage;
 }

+enum CourseExamPreparationReadinessState {
+  ready,
+  partiallyReady,
+  notReady,
+  blocked,
+  unknown,
+}
+
+enum CourseExamPreparationScopeKind { course, source, unknown }
+
+class CourseExamPreparationOptions {
+  const CourseExamPreparationOptions({
+    required this.course,
+    required this.readiness,
+    required this.scopeOptions,
+    required this.questionCountOptions,
+    required this.defaultQuestionCount,
+    required this.supportedQuestionKinds,
+    required this.defaultConfig,
+    required this.nextStep,
+  });
+
+  final CourseExamPreparationCourse course;
+  final CourseExamPreparationReadiness readiness;
+  final List<CourseExamPreparationScopeOption> scopeOptions;
+  final List<int> questionCountOptions;
+  final int? defaultQuestionCount;
+  final List<String> supportedQuestionKinds;
+  final CourseExamPreparationConfig? defaultConfig;
+  final CourseExamPreparationNextStep nextStep;
+}
+
+class CourseExamPreparationCourse {
+  const CourseExamPreparationCourse({
+    required this.id,
+    required this.title,
+    required this.subjectId,
+  });
+
+  final String id;
+  final String title;
+  final String subjectId;
+}
+
+class CourseExamPreparationReadiness {
+  const CourseExamPreparationReadiness({
+    required this.canPrepare,
+    required this.state,
+    required this.userMessage,
+    required this.blockers,
+    required this.readySourceCount,
+    required this.readyKnowledgeUnitCount,
+    required this.availableQuestionCount,
+  });
+
+  final bool canPrepare;
+  final CourseExamPreparationReadinessState state;
+  final String userMessage;
+  final List<String> blockers;
+  final int readySourceCount;
+  final int readyKnowledgeUnitCount;
+  final int availableQuestionCount;
+}
+
+class CourseExamPreparationScopeOption {
+  const CourseExamPreparationScopeOption({
+    required this.kind,
+    required this.id,
+    required this.label,
+    required this.readyQuestionCount,
+    required this.readyKnowledgeUnitCount,
+    required this.canSelect,
+  });
+
+  final CourseExamPreparationScopeKind kind;
+  final String id;
+  final String label;
+  final int readyQuestionCount;
+  final int readyKnowledgeUnitCount;
+  final bool canSelect;
+}
+
+class CourseExamPreparationConfig {
+  const CourseExamPreparationConfig({
+    required this.scopeKind,
+    required this.scopeId,
+    required this.questionCount,
+    required this.complexityProfile,
+  });
+
+  final CourseExamPreparationScopeKind scopeKind;
+  final String scopeId;
+  final int questionCount;
+  final String complexityProfile;
+}
+
+class CourseExamPreparationNextStep {
+  const CourseExamPreparationNextStep({
+    required this.kind,
+    required this.userMessage,
+  });
+
+  final String kind;
+  final String userMessage;
+}
+
 class CourseRichClosedHistoryResponse {
   const CourseRichClosedHistoryResponse({required this.items});

diff --git a/lib/features/courses/domain/courses_repository.dart b/lib/features/courses/domain/courses_repository.dart
index fe6ce53..67e76c5 100644
--- a/lib/features/courses/domain/courses_repository.dart
+++ b/lib/features/courses/domain/courses_repository.dart
@@ -82,6 +82,10 @@ abstract interface class CoursesRepository {
     int limit = 5,
   });

+  Future<CourseExamPreparationOptions> getExamPreparationOptions({
+    required String courseId,
+  });
+
   Future<CourseProgress> getCourseProgress({required String courseId});

   Future<SubjectProgress> getSubjectProgress({required String subjectId});
diff --git a/lib/features/courses/presentation/course_detail_page.dart b/lib/features/courses/presentation/course_detail_page.dart
index 65dcb93..7c3e2ba 100644
--- a/lib/features/courses/presentation/course_detail_page.dart
+++ b/lib/features/courses/presentation/course_detail_page.dart
@@ -1043,11 +1043,14 @@ class _CourseModes extends ConsumerWidget {
         const SizedBox(height: RevisionSpacing.m),
         RevisionModeCard(
           title: 'Préparation examen',
-          description: 'Entraînements et sujets corrigés.',
+          description:
+              'Construis un entraînement plus proche d’un sujet d’examen.',
           icon: Icons.gps_fixed_rounded,
           accent: RevisionColors.pink,
-          trailingLabel: 'Bientôt disponible',
-          enabled: false,
+          trailingLabel: 'Configurer',
+          enabled: true,
+          onTap: () =>
+              context.push(AppRoutes.courseExamPreparation(detail.course.id)),
         ),
         if (quickRevisionState.hasError || preparationState.hasError) ...[
           const SizedBox(height: RevisionSpacing.s),
diff --git a/test/fakes/in_memory_courses_repository.dart b/test/fakes/in_memory_courses_repository.dart
index 4876731..7fd4c59 100644
--- a/test/fakes/in_memory_courses_repository.dart
+++ b/test/fakes/in_memory_courses_repository.dart
@@ -28,6 +28,8 @@ class InMemoryCoursesRepository implements CoursesRepository {
   revisionSessionHistoryByCourse = {};
   final Map<String, List<CourseRichClosedHistoryItem>>
   richClosedHistoryByCourse = {};
+  final Map<String, CourseExamPreparationOptions>
+  examPreparationOptionsByCourse = {};
   final Map<String, SourceLifecycleDecision> lifecycleByDocumentId = {};
   int createCount = 0;
   int updateCount = 0;
@@ -41,6 +43,7 @@ class InMemoryCoursesRepository implements CoursesRepository {
   int getResumableRevisionSessionCount = 0;
   int getCourseRevisionSessionHistoryCount = 0;
   int getCourseRichClosedHistoryCount = 0;
+  int getExamPreparationOptionsCount = 0;
   int prepareQuestionBankCount = 0;
   int uploadCount = 0;
   int deleteDocumentCount = 0;
@@ -61,6 +64,7 @@ class InMemoryCoursesRepository implements CoursesRepository {
   String? lastResumableRevisionSessionCourseId;
   String? lastCourseRevisionSessionHistoryCourseId;
   String? lastCourseRichClosedHistoryCourseId;
+  String? lastExamPreparationOptionsCourseId;
   int? lastQuickRevisionQuestionCount;
   String? lastArchivedCourseLifecycleId;
   String? lastDeletedCourseLifecycleId;
@@ -539,6 +543,47 @@ class InMemoryCoursesRepository implements CoursesRepository {
     );
   }

+  @override
+  Future<CourseExamPreparationOptions> getExamPreparationOptions({
+    required String courseId,
+  }) async {
+    getExamPreparationOptionsCount += 1;
+    lastExamPreparationOptionsCourseId = courseId;
+
+    if (!detailsByCourse.containsKey(courseId)) {
+      throw const CourseNotFoundException('Course not found');
+    }
+
+    return examPreparationOptionsByCourse[courseId] ??
+        CourseExamPreparationOptions(
+          course: CourseExamPreparationCourse(
+            id: courseId,
+            title: detailsByCourse[courseId]!.course.title,
+            subjectId: detailsByCourse[courseId]!.course.subjectId,
+          ),
+          readiness: const CourseExamPreparationReadiness(
+            canPrepare: false,
+            state: CourseExamPreparationReadinessState.blocked,
+            userMessage:
+                'Ajoute une source prête avant de configurer une préparation examen.',
+            blockers: ['NO_READY_SOURCE'],
+            readySourceCount: 0,
+            readyKnowledgeUnitCount: 0,
+            availableQuestionCount: 0,
+          ),
+          scopeOptions: const [],
+          questionCountOptions: const [],
+          defaultQuestionCount: null,
+          supportedQuestionKinds: const ['single_choice', 'multiple_choice'],
+          defaultConfig: null,
+          nextStep: const CourseExamPreparationNextStep(
+            kind: 'blocked',
+            userMessage:
+                'Ajoute une source prête avant de configurer une préparation examen.',
+          ),
+        );
+  }
+
   @override
   Future<CourseProgress> getCourseProgress({required String courseId}) {
     getCourseProgressCount += 1;
diff --git a/test/features/courses/course_detail_page_test.dart b/test/features/courses/course_detail_page_test.dart
index 8795606..eedfe96 100644
--- a/test/features/courses/course_detail_page_test.dart
+++ b/test/features/courses/course_detail_page_test.dart
@@ -763,6 +763,44 @@ void main() {
     expect(find.text('Résultat questions riches'), findsOneWidget);
   });

+  testWidgets(
+    'course detail opens the exam preparation page from a real card',
+    (tester) async {
+      final repository = InMemoryCoursesRepository()
+        ..detailsByCourse['course-1'] = courseDetail(
+          sources: const [
+            CourseDocument(
+              id: 'document-1',
+              courseId: 'course-1',
+              documentId: 'document-1',
+              fileName: 'CM.pdf',
+              status: CourseDocumentStatus.ready,
+            ),
+          ],
+        )
+        ..examPreparationOptionsByCourse['course-1'] =
+            examPreparationOptionsFixture();
+
+      await tester.pumpWidget(
+        routerTestApp(
+          repository: repository,
+          picker: FakeCoursePdfPicker(null),
+        ),
+      );
+      await tester.pumpAndSettle();
+
+      await tester.scrollUntilVisible(find.text('Préparation examen'), 400);
+      await tester.pumpAndSettle();
+
+      await tester.tap(
+        find.widgetWithText(RevisionModeCard, 'Préparation examen'),
+      );
+      await tester.pumpAndSettle();
+
+      expect(find.text('Préparation examen dédiée'), findsOneWidget);
+    },
+  );
+
   testWidgets('course detail prioritizes a resumable quick session', (
     tester,
   ) async {
@@ -878,6 +916,11 @@ Widget routerTestApp({
           ),
         ),
       ),
+      GoRoute(
+        path: AppRoutes.courseExamPreparationPath,
+        builder: (context, state) =>
+            const Scaffold(body: Text('Préparation examen dédiée')),
+      ),
     ],
   );

@@ -1006,6 +1049,51 @@ CourseRichClosedHistoryItem richClosedHistoryItem({
   );
 }

+CourseExamPreparationOptions examPreparationOptionsFixture({
+  CourseExamPreparationReadinessState state =
+      CourseExamPreparationReadinessState.ready,
+}) {
+  return CourseExamPreparationOptions(
+    course: const CourseExamPreparationCourse(
+      id: 'course-1',
+      title: 'Droit constitutionnel',
+      subjectId: 'subject-1',
+    ),
+    readiness: CourseExamPreparationReadiness(
+      canPrepare: state == CourseExamPreparationReadinessState.ready,
+      state: state,
+      userMessage: 'Ton cours est prêt pour une préparation examen.',
+      blockers: const [],
+      readySourceCount: 1,
+      readyKnowledgeUnitCount: 2,
+      availableQuestionCount: 20,
+    ),
+    scopeOptions: const [
+      CourseExamPreparationScopeOption(
+        kind: CourseExamPreparationScopeKind.course,
+        id: 'course-1',
+        label: 'Tout le cours',
+        readyQuestionCount: 20,
+        readyKnowledgeUnitCount: 2,
+        canSelect: true,
+      ),
+    ],
+    questionCountOptions: const [10, 20],
+    defaultQuestionCount: 20,
+    supportedQuestionKinds: const ['single_choice', 'multiple_choice'],
+    defaultConfig: const CourseExamPreparationConfig(
+      scopeKind: CourseExamPreparationScopeKind.course,
+      scopeId: 'course-1',
+      questionCount: 20,
+      complexityProfile: 'exam',
+    ),
+    nextStep: const CourseExamPreparationNextStep(
+      kind: 'configuration_ready',
+      userMessage: 'Configuration prête. La session complète arrive ensuite.',
+    ),
+  );
+}
+
 class FakeCoursePdfPicker implements CoursePdfPicker {
   FakeCoursePdfPicker(this.result);

diff --git a/test/features/courses/http_courses_repository_test.dart b/test/features/courses/http_courses_repository_test.dart
index 363e8fe..cdea67b 100644
--- a/test/features/courses/http_courses_repository_test.dart
+++ b/test/features/courses/http_courses_repository_test.dart
@@ -644,6 +644,42 @@ void main() {
     expect(adapter.lastOptions?.queryParameters, {'limit': 5});
   });

+  test('loads course exam preparation options without answer data', () async {
+    final response = examPreparationOptionsJson();
+    final adapter = CapturingHttpClientAdapter(jsonResponse(response));
+    final repository = HttpCoursesRepository(
+      dio: Dio()..httpClientAdapter = adapter,
+      getIdToken: () async => 'firebase-id-token',
+    );
+
+    final options = await repository.getExamPreparationOptions(
+      courseId: 'course-1',
+    );
+
+    expect(options.course.title, 'Droit constitutionnel');
+    expect(options.readiness.state, CourseExamPreparationReadinessState.ready);
+    expect(options.readiness.canPrepare, isTrue);
+    expect(options.scopeOptions, hasLength(2));
+    expect(
+      options.scopeOptions.first.kind,
+      CourseExamPreparationScopeKind.course,
+    );
+    expect(options.scopeOptions.first.canSelect, isTrue);
+    expect(options.questionCountOptions, [10, 20]);
+    expect(options.defaultQuestionCount, 20);
+    expect(options.defaultConfig?.complexityProfile, 'exam');
+    expect(options.supportedQuestionKinds, [
+      'single_choice',
+      'multiple_choice',
+    ]);
+    expect(jsonEncode(response), isNot(contains('correctAnswer')));
+    expect(adapter.lastOptions?.method, 'GET');
+    expect(
+      adapter.lastOptions?.path,
+      '/courses/course-1/exam-preparation/options',
+    );
+  });
+
   test('maps course history 404 to CourseNotFoundException', () async {
     final adapter = CapturingHttpClientAdapter(
       jsonResponse({'message': 'Course not found'}, statusCode: 404),
@@ -888,6 +924,60 @@ Map<String, Object?> richClosedHistoryItemJson({
   };
 }

+Map<String, Object?> examPreparationOptionsJson({
+  String state = 'READY',
+  bool canPrepare = true,
+  int availableQuestionCount = 24,
+}) {
+  return {
+    'course': {
+      'id': 'course-1',
+      'title': 'Droit constitutionnel',
+      'subjectId': 'subject-1',
+    },
+    'readiness': {
+      'canPrepare': canPrepare,
+      'state': state,
+      'userMessage': 'Ton cours est prêt pour une préparation examen.',
+      'blockers': <String>[],
+      'readySourceCount': 1,
+      'readyKnowledgeUnitCount': 2,
+      'availableQuestionCount': availableQuestionCount,
+    },
+    'scopeOptions': [
+      {
+        'kind': 'course',
+        'id': 'course-1',
+        'label': 'Tout le cours',
+        'readyQuestionCount': availableQuestionCount,
+        'readyKnowledgeUnitCount': 2,
+        'canSelect': true,
+      },
+      {
+        'kind': 'source',
+        'id': 'document-1',
+        'label': 'CM.pdf',
+        'readyQuestionCount': 16,
+        'readyKnowledgeUnitCount': 1,
+        'canSelect': true,
+      },
+    ],
+    'questionCountOptions': [10, 20],
+    'defaultQuestionCount': 20,
+    'supportedQuestionKinds': ['single_choice', 'multiple_choice'],
+    'defaultConfig': {
+      'scopeKind': 'course',
+      'scopeId': 'course-1',
+      'questionCount': 20,
+      'complexityProfile': 'exam',
+    },
+    'nextStep': {
+      'kind': 'configuration_ready',
+      'userMessage': 'Configuration prête. La session complète arrive ensuite.',
+    },
+  };
+}
+
 Map<String, Object?> revisionSessionJson({required String courseId}) {
   return {
     'session': {
```

## Diff complet des fichiers nouveaux produit/test

### `lib/features/courses/presentation/course_exam_preparation_page.dart`

```diff
diff --git a/lib/features/courses/presentation/course_exam_preparation_page.dart b/lib/features/courses/presentation/course_exam_preparation_page.dart
new file mode 100644
index 0000000..7ca5d29
--- /dev/null
+++ b/lib/features/courses/presentation/course_exam_preparation_page.dart
@@ -0,0 +1,364 @@
+import 'package:flutter/material.dart';
+import 'package:flutter_riverpod/flutter_riverpod.dart';
+import 'package:go_router/go_router.dart';
+
+import '../../../app/router/app_routes.dart';
+import '../../../presentation/design_system/components/revision_mvp_components.dart';
+import '../../../presentation/design_system/components/revision_states.dart';
+import '../../../presentation/design_system/tokens/revision_colors.dart';
+import '../../../presentation/design_system/tokens/revision_spacing.dart';
+import '../../../presentation/design_system/tokens/revision_typography.dart';
+import '../application/courses_providers.dart';
+import '../domain/course_models.dart';
+import '../domain/courses_repository.dart';
+import 'course_not_found_page.dart';
+
+class CourseExamPreparationPage extends ConsumerWidget {
+  const CourseExamPreparationPage({required this.courseId, super.key});
+
+  final String courseId;
+
+  @override
+  Widget build(BuildContext context, WidgetRef ref) {
+    final options = ref.watch(courseExamPreparationOptionsProvider(courseId));
+
+    return RevisionPageScaffold(
+      headerChildren: [
+        Row(
+          children: [
+            IconButton(
+              tooltip: 'Retour au cours',
+              onPressed: () => _popOrGo(context, AppRoutes.course(courseId)),
+              icon: const Icon(Icons.arrow_back_rounded),
+            ),
+          ],
+        ),
+        Text('Préparation examen', style: RevisionTypography.hero),
+        Text(
+          'Construis un entraînement plus proche d’un sujet d’examen, à partir de ce cours.',
+          style: RevisionTypography.body,
+        ),
+      ],
+      children: [
+        options.when(
+          loading: () => const RevisionLoadingState(
+            label: 'Chargement de la préparation examen',
+          ),
+          error: (error, stackTrace) {
+            if (error is CourseNotFoundException) {
+              return CourseNotFoundPage(courseId: courseId);
+            }
+
+            return RevisionErrorState(
+              title: 'Préparation indisponible',
+              message:
+                  'Impossible de charger cette préparation pour le moment.',
+              actionLabel: 'Réessayer',
+              onAction: () => ref.invalidate(
+                courseExamPreparationOptionsProvider(courseId),
+              ),
+            );
+          },
+          data: (options) => _ExamPreparationContent(options: options),
+        ),
+      ],
+    );
+  }
+}
+
+class _ExamPreparationContent extends StatefulWidget {
+  const _ExamPreparationContent({required this.options});
+
+  final CourseExamPreparationOptions options;
+
+  @override
+  State<_ExamPreparationContent> createState() =>
+      _ExamPreparationContentState();
+}
+
+class _ExamPreparationContentState extends State<_ExamPreparationContent> {
+  String? _selectedScopeId;
+  int? _selectedQuestionCount;
+
+  @override
+  void initState() {
+    super.initState();
+    _selectedScopeId = widget.options.defaultConfig?.scopeId;
+    _selectedQuestionCount = widget.options.defaultQuestionCount;
+  }
+
+  @override
+  void didUpdateWidget(covariant _ExamPreparationContent oldWidget) {
+    super.didUpdateWidget(oldWidget);
+    if (oldWidget.options.course.id != widget.options.course.id) {
+      _selectedScopeId = widget.options.defaultConfig?.scopeId;
+      _selectedQuestionCount = widget.options.defaultQuestionCount;
+    }
+  }
+
+  @override
+  Widget build(BuildContext context) {
+    final options = widget.options;
+
+    return Column(
+      crossAxisAlignment: CrossAxisAlignment.start,
+      children: [
+        _ReadinessCard(readiness: options.readiness),
+        const SizedBox(height: RevisionSpacing.m),
+        if (options.scopeOptions.isNotEmpty) ...[
+          _SectionTitle(
+            title: 'Périmètre',
+            subtitle: 'Choisis la partie du cours à travailler.',
+          ),
+          const SizedBox(height: RevisionSpacing.s),
+          _ScopeSelector(
+            options: options.scopeOptions,
+            selectedScopeId: _selectedScopeId,
+            onSelected: (scopeId) {
+              setState(() {
+                _selectedScopeId = scopeId;
+              });
+            },
+          ),
+          const SizedBox(height: RevisionSpacing.m),
+        ],
+        if (options.questionCountOptions.isNotEmpty) ...[
+          _SectionTitle(
+            title: 'Nombre de questions',
+            subtitle: 'Garde une configuration réaliste pour ce cours.',
+          ),
+          const SizedBox(height: RevisionSpacing.s),
+          Material(
+            type: MaterialType.transparency,
+            child: Wrap(
+              spacing: RevisionSpacing.s,
+              runSpacing: RevisionSpacing.s,
+              children: [
+                for (final count in options.questionCountOptions)
+                  ChoiceChip(
+                    label: Text('$count questions'),
+                    selected: _selectedQuestionCount == count,
+                    onSelected: (_) {
+                      setState(() {
+                        _selectedQuestionCount = count;
+                      });
+                    },
+                  ),
+              ],
+            ),
+          ),
+          const SizedBox(height: RevisionSpacing.m),
+        ],
+        if (options.supportedQuestionKinds.isNotEmpty) ...[
+          _SectionTitle(
+            title: 'Types de questions',
+            subtitle: _questionKindsLabel(options.supportedQuestionKinds),
+          ),
+          const SizedBox(height: RevisionSpacing.m),
+        ],
+        RevisionGlassCard(
+          child: Row(
+            crossAxisAlignment: CrossAxisAlignment.start,
+            children: [
+              const RevisionIconTile(
+                icon: Icons.flag_rounded,
+                accent: RevisionColors.pink,
+                size: 44,
+              ),
+              const SizedBox(width: RevisionSpacing.m),
+              Expanded(
+                child: Column(
+                  crossAxisAlignment: CrossAxisAlignment.start,
+                  children: [
+                    Text(
+                      options.readiness.canPrepare
+                          ? 'Configuration prête'
+                          : 'Configuration indisponible',
+                      style: RevisionTypography.sectionTitle,
+                    ),
+                    const SizedBox(height: RevisionSpacing.xs),
+                    Text(
+                      options.nextStep.userMessage,
+                      style: RevisionTypography.body,
+                    ),
+                  ],
+                ),
+              ),
+            ],
+          ),
+        ),
+      ],
+    );
+  }
+}
+
+class _ReadinessCard extends StatelessWidget {
+  const _ReadinessCard({required this.readiness});
+
+  final CourseExamPreparationReadiness readiness;
+
+  @override
+  Widget build(BuildContext context) {
+    return RevisionGlassCard(
+      child: Row(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: [
+          RevisionIconTile(
+            icon: _readinessIcon(readiness.state),
+            accent: _readinessColor(readiness.state),
+            size: 44,
+          ),
+          const SizedBox(width: RevisionSpacing.m),
+          Expanded(
+            child: Column(
+              crossAxisAlignment: CrossAxisAlignment.start,
+              children: [
+                Text(
+                  _readinessLabel(readiness.state),
+                  style: RevisionTypography.sectionTitle,
+                ),
+                const SizedBox(height: RevisionSpacing.xs),
+                Text(readiness.userMessage, style: RevisionTypography.body),
+                const SizedBox(height: RevisionSpacing.s),
+                Text(
+                  '${readiness.readySourceCount} source(s) prête(s) · '
+                  '${readiness.readyKnowledgeUnitCount} notion(s) · '
+                  '${readiness.availableQuestionCount} question(s)',
+                  style: RevisionTypography.caption,
+                ),
+              ],
+            ),
+          ),
+        ],
+      ),
+    );
+  }
+}
+
+class _ScopeSelector extends StatelessWidget {
+  const _ScopeSelector({
+    required this.options,
+    required this.selectedScopeId,
+    required this.onSelected,
+  });
+
+  final List<CourseExamPreparationScopeOption> options;
+  final String? selectedScopeId;
+  final ValueChanged<String> onSelected;
+
+  @override
+  Widget build(BuildContext context) {
+    return Column(
+      children: [
+        for (final option in options) ...[
+          RevisionGlassCard(
+            onTap: option.canSelect ? () => onSelected(option.id) : null,
+            child: Row(
+              children: [
+                Icon(
+                  selectedScopeId == option.id
+                      ? Icons.radio_button_checked_rounded
+                      : Icons.radio_button_unchecked_rounded,
+                  color: option.canSelect
+                      ? RevisionColors.pink
+                      : RevisionColors.textMuted,
+                ),
+                const SizedBox(width: RevisionSpacing.m),
+                Expanded(
+                  child: Column(
+                    crossAxisAlignment: CrossAxisAlignment.start,
+                    children: [
+                      Text(
+                        option.label,
+                        style: RevisionTypography.sectionTitle,
+                      ),
+                      const SizedBox(height: RevisionSpacing.xs),
+                      Text(
+                        '${option.readyQuestionCount} question(s) · ${option.readyKnowledgeUnitCount} notion(s)',
+                        style: RevisionTypography.caption,
+                      ),
+                    ],
+                  ),
+                ),
+              ],
+            ),
+          ),
+          const SizedBox(height: RevisionSpacing.s),
+        ],
+      ],
+    );
+  }
+}
+
+class _SectionTitle extends StatelessWidget {
+  const _SectionTitle({required this.title, required this.subtitle});
+
+  final String title;
+  final String subtitle;
+
+  @override
+  Widget build(BuildContext context) {
+    return Column(
+      crossAxisAlignment: CrossAxisAlignment.start,
+      children: [
+        Text(title, style: RevisionTypography.sectionTitle),
+        const SizedBox(height: RevisionSpacing.xs),
+        Text(subtitle, style: RevisionTypography.caption),
+      ],
+    );
+  }
+}
+
+String _readinessLabel(CourseExamPreparationReadinessState state) {
+  return switch (state) {
+    CourseExamPreparationReadinessState.ready => 'Prêt',
+    CourseExamPreparationReadinessState.partiallyReady => 'Partiellement prêt',
+    CourseExamPreparationReadinessState.notReady => 'Pas encore prêt',
+    CourseExamPreparationReadinessState.blocked => 'Action nécessaire',
+    CourseExamPreparationReadinessState.unknown => 'État indisponible',
+  };
+}
+
+IconData _readinessIcon(CourseExamPreparationReadinessState state) {
+  return switch (state) {
+    CourseExamPreparationReadinessState.ready => Icons.check_circle_rounded,
+    CourseExamPreparationReadinessState.partiallyReady => Icons.tune_rounded,
+    CourseExamPreparationReadinessState.notReady => Icons.hourglass_empty,
+    CourseExamPreparationReadinessState.blocked => Icons.error_outline_rounded,
+    CourseExamPreparationReadinessState.unknown => Icons.help_outline_rounded,
+  };
+}
+
+Color _readinessColor(CourseExamPreparationReadinessState state) {
+  return switch (state) {
+    CourseExamPreparationReadinessState.ready => RevisionColors.mint,
+    CourseExamPreparationReadinessState.partiallyReady => RevisionColors.blue,
+    CourseExamPreparationReadinessState.notReady => RevisionColors.amber,
+    CourseExamPreparationReadinessState.blocked => RevisionColors.red,
+    CourseExamPreparationReadinessState.unknown => RevisionColors.textMuted,
+  };
+}
+
+String _questionKindsLabel(List<String> kinds) {
+  final labels = kinds.map((kind) {
+    return switch (kind) {
+      'single_choice' => 'choix simple',
+      'multiple_choice' => 'choix multiple',
+      'matching' => 'association',
+      'ordering' => 'ordre',
+      'date_slider' => 'dates',
+      _ => null,
+    };
+  }).whereType<String>();
+
+  return labels.isEmpty ? 'Formats disponibles' : labels.join(', ');
+}
+
+void _popOrGo(BuildContext context, String fallbackRoute) {
+  if (context.canPop()) {
+    context.pop();
+    return;
+  }
+
+  context.go(fallbackRoute);
+}
```

### `test/features/courses/course_exam_preparation_page_test.dart`

```diff
diff --git a/test/features/courses/course_exam_preparation_page_test.dart b/test/features/courses/course_exam_preparation_page_test.dart
new file mode 100644
index 0000000..847582c
--- /dev/null
+++ b/test/features/courses/course_exam_preparation_page_test.dart
@@ -0,0 +1,167 @@
+import 'package:Neralune/features/courses/application/courses_providers.dart';
+import 'package:Neralune/features/courses/domain/course_models.dart';
+import 'package:Neralune/features/courses/presentation/course_exam_preparation_page.dart';
+import 'package:flutter/material.dart';
+import 'package:flutter_riverpod/flutter_riverpod.dart';
+import 'package:flutter_test/flutter_test.dart';
+
+import '../../fakes/in_memory_courses_repository.dart';
+
+void main() {
+  testWidgets(
+    'exam preparation page displays ready options without fake start',
+    (tester) async {
+      final repository = InMemoryCoursesRepository()
+        ..detailsByCourse['course-1'] = courseDetail()
+        ..examPreparationOptionsByCourse['course-1'] =
+            examPreparationOptionsFixture();
+
+      await tester.pumpWidget(testApp(repository));
+      await tester.pumpAndSettle();
+
+      expect(repository.getExamPreparationOptionsCount, 1);
+      expect(repository.lastExamPreparationOptionsCourseId, 'course-1');
+      expect(find.text('Préparation examen'), findsOneWidget);
+      expect(find.text('Prêt'), findsOneWidget);
+      expect(find.text('Tout le cours'), findsOneWidget);
+      expect(find.text('CM.pdf'), findsOneWidget);
+      expect(find.text('20 questions'), findsOneWidget);
+      expect(find.text('Types de questions'), findsOneWidget);
+      expect(find.text('choix simple, choix multiple'), findsOneWidget);
+      expect(find.text('Configuration prête'), findsOneWidget);
+      expect(find.textContaining('session complète arrive'), findsOneWidget);
+      expect(find.textContaining('Démarrer'), findsNothing);
+
+      final tenQuestionsChip = find.widgetWithText(ChoiceChip, '10 questions');
+      await tester.ensureVisible(tenQuestionsChip);
+      await tester.tap(tenQuestionsChip);
+      await tester.pumpAndSettle();
+
+      final selectedChip = tester.widget<ChoiceChip>(tenQuestionsChip);
+      expect(selectedChip.selected, isTrue);
+    },
+  );
+
+  testWidgets('exam preparation page explains blocked state without options', (
+    tester,
+  ) async {
+    final repository = InMemoryCoursesRepository()
+      ..detailsByCourse['course-1'] = courseDetail()
+      ..examPreparationOptionsByCourse['course-1'] =
+          examPreparationOptionsFixture(
+            state: CourseExamPreparationReadinessState.blocked,
+          );
+
+    await tester.pumpWidget(testApp(repository));
+    await tester.pumpAndSettle();
+
+    expect(find.text('Action nécessaire'), findsOneWidget);
+    expect(find.text('Configuration indisponible'), findsOneWidget);
+    expect(
+      find.text(
+        'Ajoute une source prête avant de configurer une préparation examen.',
+      ),
+      findsWidgets,
+    );
+    expect(find.text('Périmètre'), findsNothing);
+    expect(find.text('Nombre de questions'), findsNothing);
+    expect(find.textContaining('Démarrer'), findsNothing);
+  });
+}
+
+Widget testApp(InMemoryCoursesRepository repository) {
+  return ProviderScope(
+    overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
+    child: const MaterialApp(
+      home: CourseExamPreparationPage(courseId: 'course-1'),
+    ),
+  );
+}
+
+CourseDetail courseDetail() {
+  const course = CourseListItem(
+    id: 'course-1',
+    subjectId: 'subject-1',
+    title: 'Droit constitutionnel',
+    sourceCount: 1,
+    readySourceCount: 1,
+    processingSourceCount: 0,
+    failedSourceCount: 0,
+  );
+  return CourseDetail(
+    course: course,
+    subject: const CourseSubjectSummary(id: 'subject-1', name: 'Droit'),
+    sources: const [
+      CourseDocument(
+        id: 'document-1',
+        courseId: 'course-1',
+        documentId: 'document-1',
+        fileName: 'CM.pdf',
+        status: CourseDocumentStatus.ready,
+      ),
+    ],
+  );
+}
+
+CourseExamPreparationOptions examPreparationOptionsFixture({
+  CourseExamPreparationReadinessState state =
+      CourseExamPreparationReadinessState.ready,
+}) {
+  final canPrepare = state == CourseExamPreparationReadinessState.ready;
+
+  return CourseExamPreparationOptions(
+    course: const CourseExamPreparationCourse(
+      id: 'course-1',
+      title: 'Droit constitutionnel',
+      subjectId: 'subject-1',
+    ),
+    readiness: CourseExamPreparationReadiness(
+      canPrepare: canPrepare,
+      state: state,
+      userMessage: canPrepare
+          ? 'Ton cours est prêt pour une préparation examen.'
+          : 'Ajoute une source prête avant de configurer une préparation examen.',
+      blockers: canPrepare ? const [] : const ['NO_READY_SOURCE'],
+      readySourceCount: canPrepare ? 1 : 0,
+      readyKnowledgeUnitCount: canPrepare ? 2 : 0,
+      availableQuestionCount: canPrepare ? 20 : 0,
+    ),
+    scopeOptions: canPrepare
+        ? const [
+            CourseExamPreparationScopeOption(
+              kind: CourseExamPreparationScopeKind.course,
+              id: 'course-1',
+              label: 'Tout le cours',
+              readyQuestionCount: 20,
+              readyKnowledgeUnitCount: 2,
+              canSelect: true,
+            ),
+            CourseExamPreparationScopeOption(
+              kind: CourseExamPreparationScopeKind.source,
+              id: 'document-1',
+              label: 'CM.pdf',
+              readyQuestionCount: 12,
+              readyKnowledgeUnitCount: 1,
+              canSelect: true,
+            ),
+          ]
+        : const [],
+    questionCountOptions: canPrepare ? const [10, 20] : const [],
+    defaultQuestionCount: canPrepare ? 20 : null,
+    supportedQuestionKinds: const ['single_choice', 'multiple_choice'],
+    defaultConfig: canPrepare
+        ? const CourseExamPreparationConfig(
+            scopeKind: CourseExamPreparationScopeKind.course,
+            scopeId: 'course-1',
+            questionCount: 20,
+            complexityProfile: 'exam',
+          )
+        : null,
+    nextStep: CourseExamPreparationNextStep(
+      kind: canPrepare ? 'configuration_ready' : 'blocked',
+      userMessage: canPrepare
+          ? 'Configuration prête. La session complète arrive ensuite.'
+          : 'Ajoute une source prête avant de configurer une préparation examen.',
+    ),
+  );
+}
```
