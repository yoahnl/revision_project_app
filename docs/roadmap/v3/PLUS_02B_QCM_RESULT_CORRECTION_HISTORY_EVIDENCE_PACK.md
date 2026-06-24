# PLUS-02B - Evidence pack App

Ce pack capture le diff complet des fichiers produit/test App pour PLUS-02B. Les documents V3 du lot sont exclus pour eviter un artefact auto-recursif ; ils sont listes dans le rapport.

## Diff stat produit/test

```text
 lib/app/router/app_router.dart                     |  11 ++
 lib/app/router/app_routes.dart                     |  17 +++
 .../activities/data/demo_activity_api.dart         |   6 +
 .../activities/domain/rich_closed_exercise.dart    |  44 ++++++
 .../courses/application/courses_providers.dart     |  10 ++
 .../courses/data/http_courses_repository.dart      | 165 ++++++++++++++++++++
 lib/features/courses/domain/course_models.dart     |  57 +++++++
 .../courses/domain/courses_repository.dart         |   5 +
 .../courses/presentation/course_detail_page.dart   | 168 ++++++++++++++++-----
 .../presentation/quick_revision_quiz_flow.dart     |   1 +
 test/fakes/in_memory_courses_repository.dart       |  22 +++
 .../fixtures/rich_closed_exercise_fixtures.dart    |   6 +
 .../rich_closed_correction_presenter_test.dart     |   6 +
 .../activities/rich_closed_exercise_page_test.dart |  39 +++++
 .../activities/rich_closed_exercise_test.dart      |   6 +
 test/features/courses/course_detail_page_test.dart |  67 ++++++++
 .../courses/http_courses_repository_test.dart      |  64 ++++++++
 17 files changed, 655 insertions(+), 39 deletions(-)
```

## Diff complet des fichiers suivis produit/test

```diff
diff --git a/lib/app/router/app_router.dart b/lib/app/router/app_router.dart
index 59bf55d..31459ca 100644
--- a/lib/app/router/app_router.dart
+++ b/lib/app/router/app_router.dart
@@ -20,6 +20,7 @@ import '../../features/today/application/today_controller.dart';
 import '../../presentation/pages/activities/activities_page.dart';
 import '../../presentation/pages/auth/sign_in_page.dart';
 import '../../presentation/pages/activities/rich_closed_exercise_page.dart';
+import '../../presentation/pages/activities/rich_closed_exercise_result_page.dart';
 import '../../presentation/pages/onboarding/onboarding_page.dart';
 import '../../presentation/pages/profile/profile_page.dart';
 import '../../presentation/pages/documents/document_detail_page.dart';
@@ -226,6 +227,16 @@ GoRouter createAppRouter({
           ),
         ),
       ),
+      GoRoute(
+        path: AppRoutes.richClosedExerciseResultPath,
+        builder: (context, state) => _ImmersiveRouteScaffold(
+          child: RichClosedExerciseResultPage(
+            controller: activityController,
+            sessionId: state.pathParameters['sessionId'] ?? '',
+            courseId: state.uri.queryParameters['courseId'],
+          ),
+        ),
+      ),
     ],
   );
 }
diff --git a/lib/app/router/app_routes.dart b/lib/app/router/app_routes.dart
index fb36543..8f0d8d8 100644
--- a/lib/app/router/app_routes.dart
+++ b/lib/app/router/app_routes.dart
@@ -18,6 +18,8 @@ class AppRoutes {
   static const revisionSessionSegment = 'session';
   static const revisionSessionPath = '/activities/session';
   static const richClosedExercisePath = '/activities/rich-closed';
+  static const richClosedExerciseResultPath =
+      '/activities/rich-closed/:sessionId/result';
   static const profile = '/profile';
   static const onboarding = '/onboarding';
   static const signIn = '/sign-in';
@@ -139,4 +141,19 @@ class AppRoutes {
       queryParameters: queryParameters.isEmpty ? null : queryParameters,
     ).toString();
   }
+
+  static String richClosedExerciseResult({
+    required String sessionId,
+    String? courseId,
+  }) {
+    final queryParameters = <String, String>{};
+    if (courseId != null && courseId.trim().isNotEmpty) {
+      queryParameters['courseId'] = courseId.trim();
+    }
+
+    return Uri(
+      path: '/activities/rich-closed/${sessionId.trim()}/result',
+      queryParameters: queryParameters.isEmpty ? null : queryParameters,
+    ).toString();
+  }
 }
diff --git a/lib/features/activities/data/demo_activity_api.dart b/lib/features/activities/data/demo_activity_api.dart
index a7ad3f8..e88baa8 100644
--- a/lib/features/activities/data/demo_activity_api.dart
+++ b/lib/features/activities/data/demo_activity_api.dart
@@ -146,6 +146,12 @@ class DemoActivityApi implements ActivityApi {
     sessionId: 'demo-rich-session-1',
     type: richClosedExerciseType,
     status: 'completed',
+    subjectId: 'demo-subject-1',
+    documentId: 'demo-document-1',
+    knowledgeUnitId: 'demo-unit-1',
+    createdAt: DateTime.utc(2026, 6, 18, 10),
+    completedAt: DateTime.utc(2026, 6, 18, 10, 7),
+    durationSeconds: 420,
     correctAnswers: 6,
     totalQuestions: 6,
     score: 1,
diff --git a/lib/features/activities/domain/rich_closed_exercise.dart b/lib/features/activities/domain/rich_closed_exercise.dart
index f296e87..1c43797 100644
--- a/lib/features/activities/domain/rich_closed_exercise.dart
+++ b/lib/features/activities/domain/rich_closed_exercise.dart
@@ -1814,6 +1814,12 @@ class RichClosedExerciseResult {
     required this.sessionId,
     required this.type,
     required this.status,
+    required this.subjectId,
+    required this.documentId,
+    required this.knowledgeUnitId,
+    required this.createdAt,
+    required this.completedAt,
+    required this.durationSeconds,
     required this.correctAnswers,
     required this.totalQuestions,
     required this.score,
@@ -1845,6 +1851,18 @@ class RichClosedExerciseResult {
       sessionId: _readString(json['sessionId'], 'Invalid result session id'),
       type: type,
       status: status,
+      subjectId: _readString(json['subjectId'], 'Invalid result subject id'),
+      documentId: _readOptionalString(json['documentId']),
+      knowledgeUnitId: _readString(
+        json['knowledgeUnitId'],
+        'Invalid result knowledge unit id',
+      ),
+      createdAt: _readDate(json['createdAt'], 'Invalid result createdAt'),
+      completedAt: _readDate(json['completedAt'], 'Invalid result completedAt'),
+      durationSeconds: _readNullableInt(
+        json['durationSeconds'],
+        'Invalid result duration',
+      ),
       correctAnswers: _readInt(
         json['correctAnswers'],
         'Invalid result correct answers',
@@ -1864,6 +1882,12 @@ class RichClosedExerciseResult {
   final String sessionId;
   final String type;
   final String status;
+  final String subjectId;
+  final String? documentId;
+  final String knowledgeUnitId;
+  final DateTime createdAt;
+  final DateTime completedAt;
+  final int? durationSeconds;
   final int correctAnswers;
   final int totalQuestions;
   final double score;
@@ -2440,6 +2464,26 @@ int _readInt(Object? value, String message) {
   throw RichClosedExerciseParseException(message);
 }

+int? _readNullableInt(Object? value, String message) {
+  if (value == null) {
+    return null;
+  }
+
+  return _readInt(value, message);
+}
+
+DateTime _readDate(Object? value, String message) {
+  if (value is String) {
+    try {
+      return DateTime.parse(value);
+    } on FormatException {
+      throw RichClosedExerciseParseException(message);
+    }
+  }
+
+  throw RichClosedExerciseParseException(message);
+}
+
 bool _readBool(Object? value, String message) {
   if (value is bool) {
     return value;
diff --git a/lib/features/courses/application/courses_providers.dart b/lib/features/courses/application/courses_providers.dart
index 268f51f..c888e5b 100644
--- a/lib/features/courses/application/courses_providers.dart
+++ b/lib/features/courses/application/courses_providers.dart
@@ -64,6 +64,16 @@ final courseRevisionSessionHistoryProvider =
           .getCourseRevisionSessionHistory(courseId: courseId);
     });

+final courseRichClosedHistoryProvider =
+    FutureProvider.family<CourseRichClosedHistoryResponse, String>((
+      ref,
+      courseId,
+    ) {
+      return ref
+          .read(coursesRepositoryProvider)
+          .getCourseRichClosedHistory(courseId: courseId);
+    });
+
 typedef CourseQuestionBankReadinessKey = ({String courseId, int questionCount});

 final courseQuestionBankReadinessProvider =
diff --git a/lib/features/courses/data/http_courses_repository.dart b/lib/features/courses/data/http_courses_repository.dart
index 66d3335..f2661dd 100644
--- a/lib/features/courses/data/http_courses_repository.dart
+++ b/lib/features/courses/data/http_courses_repository.dart
@@ -456,6 +456,27 @@ class HttpCoursesRepository implements CoursesRepository {
     }
   }

+  @override
+  Future<CourseRichClosedHistoryResponse> getCourseRichClosedHistory({
+    required String courseId,
+    int limit = 5,
+  }) async {
+    try {
+      final response = await _dio.get<Object?>(
+        '/courses/${Uri.encodeComponent(courseId)}/rich-closed/history',
+        queryParameters: {'limit': limit},
+        options: await _authorizedOptions(),
+      );
+
+      return _CourseRichClosedHistoryResponseJson(response.data).toHistory();
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
@@ -880,6 +901,117 @@ class _RevisionSessionHistoryCourseJson {
   }
 }

+class _CourseRichClosedHistoryResponseJson {
+  const _CourseRichClosedHistoryResponseJson(this.value);
+
+  final Object? value;
+
+  CourseRichClosedHistoryResponse toHistory() {
+    final json = value;
+
+    if (json is! Map<String, Object?>) {
+      throw const FormatException('Invalid rich closed history response');
+    }
+
+    final items = json['items'];
+    if (items is! List) {
+      throw const FormatException('Invalid rich closed history response');
+    }
+
+    return CourseRichClosedHistoryResponse(
+      items: items
+          .map((item) => _CourseRichClosedHistoryItemJson(item).toItem())
+          .toList(growable: false),
+    );
+  }
+}
+
+class _CourseRichClosedHistoryItemJson {
+  const _CourseRichClosedHistoryItemJson(this.value);
+
+  final Object? value;
+
+  CourseRichClosedHistoryItem toItem() {
+    final json = value;
+
+    if (json is! Map<String, Object?>) {
+      throw const FormatException('Invalid rich closed history response');
+    }
+
+    final score = json['score'];
+    final knowledgeUnit = json['knowledgeUnit'];
+    final course = json['course'];
+
+    if (score is! num ||
+        knowledgeUnit is! Map<String, Object?> ||
+        course is! Map<String, Object?>) {
+      throw const FormatException('Invalid rich closed history response');
+    }
+
+    return CourseRichClosedHistoryItem(
+      id: _requiredString(json['id'], 'Invalid rich closed history response'),
+      sessionId: _requiredString(
+        json['sessionId'],
+        'Invalid rich closed history response',
+      ),
+      type: _requiredString(
+        json['type'],
+        'Invalid rich closed history response',
+      ),
+      status: _requiredString(
+        json['status'],
+        'Invalid rich closed history response',
+      ),
+      title: _requiredString(
+        json['title'],
+        'Invalid rich closed history response',
+      ),
+      subjectId: _requiredString(
+        json['subjectId'],
+        'Invalid rich closed history response',
+      ),
+      documentId: _optionalString(json['documentId']),
+      knowledgeUnit: CourseRichClosedHistoryKnowledgeUnit(
+        id: _requiredString(
+          knowledgeUnit['id'],
+          'Invalid rich closed history response',
+        ),
+        title: _requiredString(
+          knowledgeUnit['title'],
+          'Invalid rich closed history response',
+        ),
+      ),
+      course: CourseRichClosedHistoryCourse(
+        id: _requiredString(
+          course['id'],
+          'Invalid rich closed history response',
+        ),
+        title: _requiredString(
+          course['title'],
+          'Invalid rich closed history response',
+        ),
+      ),
+      correctAnswers: _requiredInt(
+        json['correctAnswers'],
+        'Invalid rich closed history response',
+      ),
+      totalQuestions: _requiredInt(
+        json['totalQuestions'],
+        'Invalid rich closed history response',
+      ),
+      score: score.toDouble(),
+      completedAt: _requiredDate(
+        json['completedAt'],
+        'Invalid rich closed history response',
+      ),
+      resultPath: _requiredString(
+        json['resultPath'],
+        'Invalid rich closed history response',
+      ),
+    );
+  }
+}
+
 class _CourseProgressJson {
   const _CourseProgressJson(this.value);

@@ -1110,3 +1242,36 @@ DateTime? _parseOptionalDate(Object? value) {

   return DateTime.parse(value);
 }
+
+String _requiredString(Object? value, String message) {
+  if (value is String && value.trim().isNotEmpty) {
+    return value.trim();
+  }
+
+  throw FormatException(message);
+}
+
+String? _optionalString(Object? value) {
+  if (value == null) {
+    return null;
+  }
+
+  return _requiredString(value, 'Invalid optional string response');
+}
+
+int _requiredInt(Object? value, String message) {
+  if (value is int) {
+    return value;
+  }
+
+  throw FormatException(message);
+}
+
+DateTime _requiredDate(Object? value, String message) {
+  final parsed = _parseOptionalDate(value);
+  if (parsed == null) {
+    throw FormatException(message);
+  }
+
+  return parsed;
+}
diff --git a/lib/features/courses/domain/course_models.dart b/lib/features/courses/domain/course_models.dart
index e33cb4a..6c9cedf 100644
--- a/lib/features/courses/domain/course_models.dart
+++ b/lib/features/courses/domain/course_models.dart
@@ -228,3 +228,60 @@ class CourseQuestionBankReadiness {
   final bool canPrepare;
   final String userMessage;
 }
+
+class CourseRichClosedHistoryResponse {
+  const CourseRichClosedHistoryResponse({required this.items});
+
+  final List<CourseRichClosedHistoryItem> items;
+}
+
+class CourseRichClosedHistoryItem {
+  const CourseRichClosedHistoryItem({
+    required this.id,
+    required this.sessionId,
+    required this.type,
+    required this.status,
+    required this.title,
+    required this.subjectId,
+    required this.documentId,
+    required this.knowledgeUnit,
+    required this.course,
+    required this.correctAnswers,
+    required this.totalQuestions,
+    required this.score,
+    required this.completedAt,
+    required this.resultPath,
+  });
+
+  final String id;
+  final String sessionId;
+  final String type;
+  final String status;
+  final String title;
+  final String subjectId;
+  final String? documentId;
+  final CourseRichClosedHistoryKnowledgeUnit knowledgeUnit;
+  final CourseRichClosedHistoryCourse course;
+  final int correctAnswers;
+  final int totalQuestions;
+  final double score;
+  final DateTime completedAt;
+  final String resultPath;
+}
+
+class CourseRichClosedHistoryKnowledgeUnit {
+  const CourseRichClosedHistoryKnowledgeUnit({
+    required this.id,
+    required this.title,
+  });
+
+  final String id;
+  final String title;
+}
+
+class CourseRichClosedHistoryCourse {
+  const CourseRichClosedHistoryCourse({required this.id, required this.title});
+
+  final String id;
+  final String title;
+}
diff --git a/lib/features/courses/domain/courses_repository.dart b/lib/features/courses/domain/courses_repository.dart
index 6c46c6e..fe6ce53 100644
--- a/lib/features/courses/domain/courses_repository.dart
+++ b/lib/features/courses/domain/courses_repository.dart
@@ -77,6 +77,11 @@ abstract interface class CoursesRepository {
     int limit = 5,
   });

+  Future<CourseRichClosedHistoryResponse> getCourseRichClosedHistory({
+    required String courseId,
+    int limit = 5,
+  });
+
   Future<CourseProgress> getCourseProgress({required String courseId});

   Future<SubjectProgress> getSubjectProgress({required String subjectId});
diff --git a/lib/features/courses/presentation/course_detail_page.dart b/lib/features/courses/presentation/course_detail_page.dart
index 84fbf53..65dcb93 100644
--- a/lib/features/courses/presentation/course_detail_page.dart
+++ b/lib/features/courses/presentation/course_detail_page.dart
@@ -765,9 +765,12 @@ class _CourseRevisionHistorySection extends ConsumerWidget {

   @override
   Widget build(BuildContext context, WidgetRef ref) {
-    final history = ref.watch(
+    final quickHistory = ref.watch(
       courseRevisionSessionHistoryProvider(detail.course.id),
     );
+    final richClosedHistory = ref.watch(
+      courseRichClosedHistoryProvider(detail.course.id),
+    );

     return RevisionGlassCard(
       child: Column(
@@ -784,45 +787,14 @@ class _CourseRevisionHistorySection extends ConsumerWidget {
             ],
           ),
           const SizedBox(height: RevisionSpacing.m),
-          history.when(
-            loading: () => Text(
-              'Chargement des sessions terminées.',
-              style: RevisionTypography.body,
-            ),
-            error: (error, stackTrace) => Column(
-              crossAxisAlignment: CrossAxisAlignment.start,
-              children: [
-                Text(
-                  'Historique indisponible pour le moment.',
-                  style: RevisionTypography.body,
-                ),
-                const SizedBox(height: RevisionSpacing.s),
-                TextButton.icon(
-                  onPressed: () => ref.invalidate(
-                    courseRevisionSessionHistoryProvider(detail.course.id),
-                  ),
-                  icon: const Icon(Icons.refresh_rounded),
-                  label: const Text('Réessayer'),
-                ),
-              ],
-            ),
-            data: (history) {
-              if (history.items.isEmpty) {
-                return Text(
-                  'Aucune session terminée pour ce cours.',
-                  style: RevisionTypography.body,
-                );
-              }
-
-              return Column(
-                children: [
-                  for (final item in history.items) ...[
-                    _CourseRevisionHistoryTile(item: item),
-                    if (item != history.items.last)
-                      const Divider(color: RevisionColors.border),
-                  ],
-                ],
+          _CourseHistoryContent(
+            quickHistory: quickHistory,
+            richClosedHistory: richClosedHistory,
+            onRetry: () {
+              ref.invalidate(
+                courseRevisionSessionHistoryProvider(detail.course.id),
               );
+              ref.invalidate(courseRichClosedHistoryProvider(detail.course.id));
             },
           ),
         ],
@@ -831,6 +803,75 @@ class _CourseRevisionHistorySection extends ConsumerWidget {
   }
 }

+class _CourseHistoryContent extends StatelessWidget {
+  const _CourseHistoryContent({
+    required this.quickHistory,
+    required this.richClosedHistory,
+    required this.onRetry,
+  });
+
+  final AsyncValue<RevisionSessionHistoryResponse> quickHistory;
+  final AsyncValue<CourseRichClosedHistoryResponse> richClosedHistory;
+  final VoidCallback onRetry;
+
+  @override
+  Widget build(BuildContext context) {
+    final quickItems = quickHistory.asData?.value.items ?? const [];
+    final richClosedItems = richClosedHistory.asData?.value.items ?? const [];
+    final hasAnyData = quickHistory.hasValue || richClosedHistory.hasValue;
+    final isLoading = quickHistory.isLoading || richClosedHistory.isLoading;
+    final hasError = quickHistory.hasError || richClosedHistory.hasError;
+
+    if (isLoading && !hasAnyData) {
+      return Text(
+        'Chargement des sessions terminées.',
+        style: RevisionTypography.body,
+      );
+    }
+
+    if (hasError && !hasAnyData) {
+      return Column(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: [
+          Text(
+            'Historique indisponible pour le moment.',
+            style: RevisionTypography.body,
+          ),
+          const SizedBox(height: RevisionSpacing.s),
+          TextButton.icon(
+            onPressed: onRetry,
+            icon: const Icon(Icons.refresh_rounded),
+            label: const Text('Réessayer'),
+          ),
+        ],
+      );
+    }
+
+    if (quickItems.isEmpty && richClosedItems.isEmpty) {
+      return Text(
+        'Aucune session terminée pour ce cours.',
+        style: RevisionTypography.body,
+      );
+    }
+
+    final rows = <Widget>[
+      for (final item in quickItems) _CourseRevisionHistoryTile(item: item),
+      for (final item in richClosedItems)
+        _CourseRichClosedHistoryTile(item: item),
+    ];
+
+    return Column(
+      children: [
+        for (final indexed in rows.indexed) ...[
+          indexed.$2,
+          if (indexed.$1 != rows.length - 1)
+            const Divider(color: RevisionColors.border),
+        ],
+      ],
+    );
+  }
+}
+
 class _CourseRevisionHistoryTile extends StatelessWidget {
   const _CourseRevisionHistoryTile({required this.item});

@@ -882,6 +923,54 @@ class _CourseRevisionHistoryTile extends StatelessWidget {
   }
 }

+class _CourseRichClosedHistoryTile extends StatelessWidget {
+  const _CourseRichClosedHistoryTile({required this.item});
+
+  final CourseRichClosedHistoryItem item;
+
+  @override
+  Widget build(BuildContext context) {
+    return Padding(
+      padding: const EdgeInsets.symmetric(vertical: RevisionSpacing.xs),
+      child: Row(
+        children: [
+          const RevisionIconTile(
+            icon: Icons.extension_rounded,
+            accent: RevisionColors.blue,
+            size: 44,
+          ),
+          const SizedBox(width: RevisionSpacing.m),
+          Expanded(
+            child: Column(
+              crossAxisAlignment: CrossAxisAlignment.start,
+              children: [
+                Text(
+                  '${item.correctAnswers}/${item.totalQuestions}',
+                  style: RevisionTypography.sectionTitle,
+                ),
+                const SizedBox(height: RevisionSpacing.xs),
+                Text(
+                  '${_scorePercent(item.score)} · Questions riches · ${_historyDate(item.completedAt)}',
+                  style: RevisionTypography.caption,
+                ),
+              ],
+            ),
+          ),
+          TextButton(
+            onPressed: () => context.push(
+              AppRoutes.richClosedExerciseResult(
+                sessionId: item.sessionId,
+                courseId: item.course.id,
+              ),
+            ),
+            child: const Text('Voir le résultat'),
+          ),
+        ],
+      ),
+    );
+  }
+}
+
 class _CourseModes extends ConsumerWidget {
   const _CourseModes({required this.detail, required this.visual});

@@ -1112,6 +1201,7 @@ Future<void> _showCourseManagement(
   ref.invalidate(courseDetailProvider(detail.course.id));
   ref.invalidate(courseProgressProvider(detail.course.id));
   ref.invalidate(courseRevisionSessionHistoryProvider(detail.course.id));
+  ref.invalidate(courseRichClosedHistoryProvider(detail.course.id));
   ref.invalidate(subjectProgressProvider(detail.course.subjectId));
 }

diff --git a/lib/features/revision_sessions/presentation/quick_revision_quiz_flow.dart b/lib/features/revision_sessions/presentation/quick_revision_quiz_flow.dart
index 2bab24a..759c7ba 100644
--- a/lib/features/revision_sessions/presentation/quick_revision_quiz_flow.dart
+++ b/lib/features/revision_sessions/presentation/quick_revision_quiz_flow.dart
@@ -405,6 +405,7 @@ class _QuickRevisionQuizFlowState extends ConsumerState<QuickRevisionQuizFlow> {
     ref.invalidate(courseDetailProvider(courseId));
     ref.invalidate(courseProgressProvider(courseId));
     ref.invalidate(courseRevisionSessionHistoryProvider(courseId));
+    ref.invalidate(courseRichClosedHistoryProvider(courseId));
     ref.invalidate(resumableCourseRevisionSessionProvider(courseId));
     ref.invalidate(subjectProgressProvider(widget.response.session.subjectId));
   }
diff --git a/test/fakes/in_memory_courses_repository.dart b/test/fakes/in_memory_courses_repository.dart
index bf1facc..4876731 100644
--- a/test/fakes/in_memory_courses_repository.dart
+++ b/test/fakes/in_memory_courses_repository.dart
@@ -26,6 +26,8 @@ class InMemoryCoursesRepository implements CoursesRepository {
   resumableRevisionSessionByCourse = {};
   final Map<String, List<RevisionSessionHistoryItem>>
   revisionSessionHistoryByCourse = {};
+  final Map<String, List<CourseRichClosedHistoryItem>>
+  richClosedHistoryByCourse = {};
   final Map<String, SourceLifecycleDecision> lifecycleByDocumentId = {};
   int createCount = 0;
   int updateCount = 0;
@@ -38,6 +40,7 @@ class InMemoryCoursesRepository implements CoursesRepository {
   int getQuestionBankReadinessCount = 0;
   int getResumableRevisionSessionCount = 0;
   int getCourseRevisionSessionHistoryCount = 0;
+  int getCourseRichClosedHistoryCount = 0;
   int prepareQuestionBankCount = 0;
   int uploadCount = 0;
   int deleteDocumentCount = 0;
@@ -57,6 +60,7 @@ class InMemoryCoursesRepository implements CoursesRepository {
   String? lastQuickRevisionCourseId;
   String? lastResumableRevisionSessionCourseId;
   String? lastCourseRevisionSessionHistoryCourseId;
+  String? lastCourseRichClosedHistoryCourseId;
   int? lastQuickRevisionQuestionCount;
   String? lastArchivedCourseLifecycleId;
   String? lastDeletedCourseLifecycleId;
@@ -517,6 +521,24 @@ class InMemoryCoursesRepository implements CoursesRepository {
     );
   }

+  @override
+  Future<CourseRichClosedHistoryResponse> getCourseRichClosedHistory({
+    required String courseId,
+    int limit = 5,
+  }) async {
+    getCourseRichClosedHistoryCount += 1;
+    lastCourseRichClosedHistoryCourseId = courseId;
+
+    if (!detailsByCourse.containsKey(courseId)) {
+      throw const CourseNotFoundException('Course not found');
+    }
+
+    final items = richClosedHistoryByCourse[courseId] ?? const [];
+    return CourseRichClosedHistoryResponse(
+      items: List.unmodifiable(items.take(limit)),
+    );
+  }
+
   @override
   Future<CourseProgress> getCourseProgress({required String courseId}) {
     getCourseProgressCount += 1;
diff --git a/test/features/activities/fixtures/rich_closed_exercise_fixtures.dart b/test/features/activities/fixtures/rich_closed_exercise_fixtures.dart
index 7a7fbec..4687ccc 100644
--- a/test/features/activities/fixtures/rich_closed_exercise_fixtures.dart
+++ b/test/features/activities/fixtures/rich_closed_exercise_fixtures.dart
@@ -111,6 +111,12 @@ Map<String, Object?> richClosedResultJson() {
     'sessionId': 'rich-session-1',
     'type': 'rich_closed_exercise',
     'status': 'completed',
+    'subjectId': 'subject-1',
+    'documentId': 'document-1',
+    'knowledgeUnitId': 'unit-1',
+    'createdAt': '2026-06-18T10:00:00.000Z',
+    'completedAt': '2026-06-18T10:07:00.000Z',
+    'durationSeconds': 420,
     'correctAnswers': 5,
     'totalQuestions': 6,
     'score': 0.833,
diff --git a/test/features/activities/rich_closed_correction_presenter_test.dart b/test/features/activities/rich_closed_correction_presenter_test.dart
index f4e5127..cd85a7d 100644
--- a/test/features/activities/rich_closed_correction_presenter_test.dart
+++ b/test/features/activities/rich_closed_correction_presenter_test.dart
@@ -421,6 +421,12 @@ void main() {
       sessionId: result.sessionId,
       type: result.type,
       status: result.status,
+      subjectId: result.subjectId,
+      documentId: result.documentId,
+      knowledgeUnitId: result.knowledgeUnitId,
+      createdAt: result.createdAt,
+      completedAt: result.completedAt,
+      durationSeconds: result.durationSeconds,
       correctAnswers: result.correctAnswers,
       totalQuestions: result.totalQuestions,
       score: result.score,
diff --git a/test/features/activities/rich_closed_exercise_page_test.dart b/test/features/activities/rich_closed_exercise_page_test.dart
index 9df742d..7e03eb2 100644
--- a/test/features/activities/rich_closed_exercise_page_test.dart
+++ b/test/features/activities/rich_closed_exercise_page_test.dart
@@ -9,6 +9,7 @@ import 'package:Neralune/features/activities/domain/rich_closed_exercise.dart';
 import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
 import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_question_renderer.dart';
 import 'package:Neralune/presentation/pages/activities/rich_closed_exercise_page.dart';
+import 'package:Neralune/presentation/pages/activities/rich_closed_exercise_result_page.dart';
 import 'package:Neralune/presentation/widgets/revision_button.dart';

 import 'fixtures/rich_closed_exercise_fixtures.dart';
@@ -667,6 +668,40 @@ void main() {
     expect(find.text('Valeur attendue : 289'), findsWidgets);
   });

+  testWidgets(
+    'result page reloads a completed rich closed result by session id',
+    (tester) async {
+      final api = _FakeRichClosedActivityApi(
+        exercise: exercise,
+        result: result,
+      );
+
+      await tester.pumpWidget(
+        _TestHost(
+          child: RichClosedExerciseResultPage(
+            controller: ActivityController(api),
+            sessionId: 'rich-session-1',
+          ),
+        ),
+      );
+      await tester.pumpAndSettle();
+
+      expect(api.getExerciseCallCount, 1);
+      expect(api.getResultCallCount, 1);
+      expect(api.submitCallCount, 0);
+      expect(find.text('Score backend'), findsOneWidget);
+      expect(find.text('0.833'), findsOneWidget);
+      expect(
+        find.text('Quel critère caractérise un régime parlementaire ?'),
+        findsWidgets,
+      );
+      expect(
+        find.text('La responsabilité politique est centrale.'),
+        findsWidgets,
+      );
+    },
+  );
+
   testWidgets('page submit et affiche les corrections V1-022', (tester) async {
     final v1dExercise = RichClosedExercise.fromJson(
       richClosedV1DImageChoiceExerciseJson(),
@@ -993,6 +1028,8 @@ class _FakeRichClosedActivityApi implements ActivityApi {
   List<RichClosedAnswer>? submittedAnswers;
   int startCount = 0;
   int submitCallCount = 0;
+  int getExerciseCallCount = 0;
+  int getResultCallCount = 0;

   @override
   Future<DiagnosticQuizActivity> startNextActivity({
@@ -1048,6 +1085,7 @@ class _FakeRichClosedActivityApi implements ActivityApi {

   @override
   Future<RichClosedExercise> getRichClosedExercise(String sessionId) async {
+    getExerciseCallCount += 1;
     return exercise;
   }

@@ -1071,6 +1109,7 @@ class _FakeRichClosedActivityApi implements ActivityApi {
   Future<RichClosedExerciseResult> getRichClosedExerciseResult(
     String sessionId,
   ) async {
+    getResultCallCount += 1;
     return result;
   }
 }
diff --git a/test/features/activities/rich_closed_exercise_test.dart b/test/features/activities/rich_closed_exercise_test.dart
index 3ea1cce..fbf2957 100644
--- a/test/features/activities/rich_closed_exercise_test.dart
+++ b/test/features/activities/rich_closed_exercise_test.dart
@@ -950,6 +950,12 @@ void main() {
       expect(result.sessionId, 'rich-session-1');
       expect(result.type, richClosedExerciseType);
       expect(result.status, 'completed');
+      expect(result.subjectId, 'subject-1');
+      expect(result.documentId, 'document-1');
+      expect(result.knowledgeUnitId, 'unit-1');
+      expect(result.createdAt, DateTime.parse('2026-06-18T10:00:00.000Z'));
+      expect(result.completedAt, DateTime.parse('2026-06-18T10:07:00.000Z'));
+      expect(result.durationSeconds, 420);
       expect(result.correctAnswers, 5);
       expect(result.totalQuestions, 6);
       expect(result.score, 0.833);
diff --git a/test/features/courses/course_detail_page_test.dart b/test/features/courses/course_detail_page_test.dart
index de37d17..8795606 100644
--- a/test/features/courses/course_detail_page_test.dart
+++ b/test/features/courses/course_detail_page_test.dart
@@ -708,6 +708,7 @@ void main() {
     expect(find.text('Historique'), findsOneWidget);
     expect(find.text('Aucune session terminée pour ce cours.'), findsOneWidget);
     expect(repository.getCourseRevisionSessionHistoryCount, 1);
+    expect(repository.getCourseRichClosedHistoryCount, 1);
   });

   testWidgets('course detail opens a completed session result from history', (
@@ -737,6 +738,31 @@ void main() {
     expect(find.text('Résultat de session'), findsOneWidget);
   });

+  testWidgets('course detail opens a rich closed result from history', (
+    tester,
+  ) async {
+    final repository = InMemoryCoursesRepository()
+      ..detailsByCourse['course-1'] = courseDetail()
+      ..richClosedHistoryByCourse['course-1'] = [richClosedHistoryItem()];
+
+    await tester.pumpWidget(
+      routerTestApp(repository: repository, picker: FakeCoursePdfPicker(null)),
+    );
+    await tester.pumpAndSettle();
+
+    await tester.scrollUntilVisible(find.text('5/6'), 400);
+    await tester.pumpAndSettle();
+
+    expect(find.text('Historique'), findsOneWidget);
+    expect(find.text('5/6'), findsOneWidget);
+    expect(find.textContaining('83 %'), findsOneWidget);
+
+    await tester.tap(find.text('Voir le résultat'));
+    await tester.pumpAndSettle();
+
+    expect(find.text('Résultat questions riches'), findsOneWidget);
+  });
+
   testWidgets('course detail prioritizes a resumable quick session', (
     tester,
   ) async {
@@ -841,6 +867,17 @@ Widget routerTestApp({
           ),
         ),
       ),
+      GoRoute(
+        path: AppRoutes.richClosedExerciseResultPath,
+        builder: (context, state) => Scaffold(
+          body: Text(
+            state.pathParameters['sessionId'] == 'rich-session-1' &&
+                    state.uri.queryParameters['courseId'] == 'course-1'
+                ? 'Résultat questions riches'
+                : 'Résultat introuvable',
+          ),
+        ),
+      ),
     ],
   );

@@ -939,6 +976,36 @@ RevisionSessionHistoryItem revisionSessionHistoryItem({
   );
 }

+CourseRichClosedHistoryItem richClosedHistoryItem({
+  String sessionId = 'rich-session-1',
+  int correctAnswers = 5,
+  int totalQuestions = 6,
+  double score = 0.833,
+}) {
+  return CourseRichClosedHistoryItem(
+    id: sessionId,
+    sessionId: sessionId,
+    type: 'rich_closed_exercise',
+    status: 'completed',
+    title: 'Questions riches - Constitution',
+    subjectId: 'subject-1',
+    documentId: 'document-1',
+    knowledgeUnit: const CourseRichClosedHistoryKnowledgeUnit(
+      id: 'unit-1',
+      title: 'Séparation des pouvoirs',
+    ),
+    course: const CourseRichClosedHistoryCourse(
+      id: 'course-1',
+      title: 'Droit constitutionnel',
+    ),
+    correctAnswers: correctAnswers,
+    totalQuestions: totalQuestions,
+    score: score,
+    completedAt: DateTime.utc(2026, 6, 18, 10, 7),
+    resultPath: '/activities/rich-closed/$sessionId/result',
+  );
+}
+
 class FakeCoursePdfPicker implements CoursePdfPicker {
   FakeCoursePdfPicker(this.result);

diff --git a/test/features/courses/http_courses_repository_test.dart b/test/features/courses/http_courses_repository_test.dart
index 50d8b7f..363e8fe 100644
--- a/test/features/courses/http_courses_repository_test.dart
+++ b/test/features/courses/http_courses_repository_test.dart
@@ -604,6 +604,46 @@ void main() {
     expect(history.items, isEmpty);
   });

+  test('loads completed course rich closed history', () async {
+    final adapter = CapturingHttpClientAdapter(
+      jsonResponse({
+        'items': [
+          richClosedHistoryItemJson(
+            sessionId: 'rich-session-2',
+            correctAnswers: 5,
+            totalQuestions: 6,
+            score: 0.833,
+          ),
+        ],
+      }),
+    );
+    final repository = HttpCoursesRepository(
+      dio: Dio()..httpClientAdapter = adapter,
+      getIdToken: () async => 'firebase-id-token',
+    );
+
+    final history = await repository.getCourseRichClosedHistory(
+      courseId: 'course-1',
+      limit: 5,
+    );
+
+    expect(history.items, hasLength(1));
+    expect(history.items.single.sessionId, 'rich-session-2');
+    expect(history.items.single.type, 'rich_closed_exercise');
+    expect(history.items.single.correctAnswers, 5);
+    expect(history.items.single.totalQuestions, 6);
+    expect(history.items.single.score, 0.833);
+    expect(history.items.single.course.title, 'Droit constitutionnel');
+    expect(history.items.single.knowledgeUnit.title, 'Séparation des pouvoirs');
+    expect(
+      history.items.single.resultPath,
+      '/activities/rich-closed/rich-session-2/result',
+    );
+    expect(adapter.lastOptions?.method, 'GET');
+    expect(adapter.lastOptions?.path, '/courses/course-1/rich-closed/history');
+    expect(adapter.lastOptions?.queryParameters, {'limit': 5});
+  });
+
   test('maps course history 404 to CourseNotFoundException', () async {
     final adapter = CapturingHttpClientAdapter(
       jsonResponse({'message': 'Course not found'}, statusCode: 404),
@@ -824,6 +864,30 @@ void main() {
   });
 }

+Map<String, Object?> richClosedHistoryItemJson({
+  String sessionId = 'rich-session-1',
+  int correctAnswers = 4,
+  int totalQuestions = 6,
+  double score = 0.667,
+}) {
+  return {
+    'id': sessionId,
+    'sessionId': sessionId,
+    'type': 'rich_closed_exercise',
+    'status': 'completed',
+    'title': 'Questions riches - Constitution',
+    'subjectId': 'subject-1',
+    'documentId': 'document-1',
+    'knowledgeUnit': {'id': 'unit-1', 'title': 'Séparation des pouvoirs'},
+    'course': {'id': 'course-1', 'title': 'Droit constitutionnel'},
+    'correctAnswers': correctAnswers,
+    'totalQuestions': totalQuestions,
+    'score': score,
+    'completedAt': '2026-06-18T10:07:00.000Z',
+    'resultPath': '/activities/rich-closed/$sessionId/result',
+  };
+}
+
 Map<String, Object?> revisionSessionJson({required String courseId}) {
   return {
     'session': {
```

## Nouveaux fichiers produit/test non suivis

### `lib/presentation/pages/activities/rich_closed_exercise_result_page.dart`

```diff
diff --git a/lib/presentation/pages/activities/rich_closed_exercise_result_page.dart b/lib/presentation/pages/activities/rich_closed_exercise_result_page.dart
new file mode 100644
index 0000000..6ae7b90
--- /dev/null
+++ b/lib/presentation/pages/activities/rich_closed_exercise_result_page.dart
@@ -0,0 +1,155 @@
+import 'package:flutter/material.dart';
+import 'package:go_router/go_router.dart';
+import 'package:Neralune/app/router/app_routes.dart';
+import 'package:Neralune/features/activities/application/activity_controller.dart';
+import 'package:Neralune/features/activities/domain/rich_closed_exercise.dart';
+import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_correction_list.dart';
+import 'package:Neralune/presentation/theme/app_spacing.dart';
+import 'package:Neralune/presentation/widgets/revision_button.dart';
+import 'package:Neralune/presentation/widgets/revision_message.dart';
+import 'package:Neralune/presentation/widgets/revision_page.dart';
+import 'package:Neralune/presentation/widgets/revision_panel.dart';
+
+class RichClosedExerciseResultPage extends StatefulWidget {
+  const RichClosedExerciseResultPage({
+    required this.controller,
+    required this.sessionId,
+    this.courseId,
+    super.key,
+  });
+
+  final ActivityController controller;
+  final String sessionId;
+  final String? courseId;
+
+  @override
+  State<RichClosedExerciseResultPage> createState() =>
+      _RichClosedExerciseResultPageState();
+}
+
+class _RichClosedExerciseResultPageState
+    extends State<RichClosedExerciseResultPage> {
+  late Future<_LoadedRichClosedResult> _result;
+
+  @override
+  void initState() {
+    super.initState();
+    _result = _loadResult();
+  }
+
+  @override
+  void didUpdateWidget(covariant RichClosedExerciseResultPage oldWidget) {
+    super.didUpdateWidget(oldWidget);
+
+    if (oldWidget.sessionId != widget.sessionId) {
+      _result = _loadResult();
+    }
+  }
+
+  @override
+  Widget build(BuildContext context) {
+    return RevisionPage(
+      title: 'Résultat questions riches',
+      subtitle: 'Correction enregistrée côté serveur.',
+      children: [
+        FutureBuilder<_LoadedRichClosedResult>(
+          future: _result,
+          builder: (context, snapshot) {
+            if (snapshot.connectionState != ConnectionState.done) {
+              return const RevisionPanel(
+                child: Center(child: CircularProgressIndicator()),
+              );
+            }
+
+            final loaded = snapshot.data;
+            if (snapshot.hasError || loaded == null) {
+              return _ResultErrorPanel(onRetry: _retry);
+            }
+
+            return Column(
+              crossAxisAlignment: CrossAxisAlignment.start,
+              children: [
+                RichClosedCorrectionList(
+                  exercise: loaded.exercise,
+                  result: loaded.result,
+                ),
+                if (_normalized(widget.courseId) != null) ...[
+                  const SizedBox(height: AppSpacing.m),
+                  RevisionButton(
+                    label: 'Retour au cours',
+                    icon: Icons.arrow_back,
+                    onPressed: () => context.go(
+                      AppRoutes.course(_normalized(widget.courseId)!),
+                    ),
+                  ),
+                ],
+              ],
+            );
+          },
+        ),
+      ],
+    );
+  }
+
+  Future<_LoadedRichClosedResult> _loadResult() async {
+    final sessionId = _normalized(widget.sessionId);
+    if (sessionId == null) {
+      throw ArgumentError('Activity session id is required');
+    }
+
+    final exercise = await widget.controller.getRichClosedExercise(sessionId);
+    final result = await widget.controller.getRichClosedExerciseResult(
+      sessionId,
+    );
+
+    return _LoadedRichClosedResult(exercise: exercise, result: result);
+  }
+
+  void _retry() {
+    setState(() {
+      _result = _loadResult();
+    });
+  }
+
+  String? _normalized(String? value) {
+    final trimmedValue = value?.trim();
+    return trimmedValue == null || trimmedValue.isEmpty ? null : trimmedValue;
+  }
+}
+
+class _LoadedRichClosedResult {
+  const _LoadedRichClosedResult({required this.exercise, required this.result});
+
+  final RichClosedExercise exercise;
+  final RichClosedExerciseResult result;
+}
+
+class _ResultErrorPanel extends StatelessWidget {
+  const _ResultErrorPanel({required this.onRetry});
+
+  final VoidCallback onRetry;
+
+  @override
+  Widget build(BuildContext context) {
+    return RevisionPanel(
+      padding: const EdgeInsets.all(AppSpacing.l),
+      child: Column(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: [
+          RevisionMessage(
+            message:
+                'Impossible de charger ce résultat. Réessaie dans un instant.',
+            color: Theme.of(context).colorScheme.error,
+            icon: Icons.error_outline,
+          ),
+          const SizedBox(height: AppSpacing.m),
+          RevisionButton(
+            label: 'Réessayer',
+            icon: Icons.refresh,
+            onPressed: onRetry,
+          ),
+        ],
+      ),
+    );
+  }
+}
```

