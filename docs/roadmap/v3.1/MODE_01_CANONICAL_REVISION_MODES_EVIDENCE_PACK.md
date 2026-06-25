# MODE-01 Evidence Pack - App

Ce pack documente les preuves App du lot `MODE-01`.

## Diff summary

```text
lib/features/courses/data/http_courses_repository.dart
lib/features/courses/presentation/course_detail_page.dart
lib/features/courses/presentation/course_exam_preparation_page.dart
lib/features/courses/presentation/revisions_pending_page.dart
lib/features/revision_sessions/presentation/exam_revision_session_flow.dart
lib/presentation/pages/revision_sessions/revision_session_page.dart
lib/presentation/pages/revision_sessions/revision_session_result_page.dart
test/features/courses/course_detail_page_test.dart
test/features/courses/course_exam_preparation_page_test.dart
test/features/revision_sessions/revision_session_page_test.dart
test/features/revision_sessions/revision_session_result_page_test.dart
```

## Code and test hunks

### `http_courses_repository.dart`

```diff
-          _responseMessage(error) ?? 'Préparation examen indisponible',
+          _responseMessage(error) ?? 'Préparation examen - QCM indisponible',
```

### `course_detail_page.dart`

```diff
-                  '${_scorePercent(summary.score)} · Entraînement examen · ${_historyDate(item.session.completedAt)}',
+                  '${_scorePercent(summary.score)} · Préparation examen - QCM · ${_historyDate(item.session.completedAt)}',

-                  '${_scorePercent(summary.score)} · ${_historyDate(item.session.completedAt)}',
+                  '${_scorePercent(summary.score)} · Révision rapide · ${_historyDate(item.session.completedAt)}',

-                  '${_scorePercent(item.score)} · Questions riches · ${_historyDate(item.completedAt)}',
+                  '${_scorePercent(item.score)} · QCM complet · ${_historyDate(item.completedAt)}',

+        RevisionModeCard(
+          title: 'QCM complet',
+          description: 'Questions variées pour t’entraîner plus sérieusement.',
+          icon: Icons.extension_rounded,
+          accent: RevisionColors.green,
+          trailingLabel: 'Bientôt',
+          enabled: false,
+        ),
+        const SizedBox(height: RevisionSpacing.m),
         RevisionModeCard(
           title: 'Révision approfondie',
-          description: 'Cours complet et exemples détaillés.',
+          description: 'Question ouverte, rédaction et correction détaillée.',
           icon: Icons.menu_book_rounded,
           accent: RevisionColors.violet,
-          trailingLabel: 'Bientôt disponible',
+          trailingLabel: 'Bientôt',
           enabled: false,
         ),
         const SizedBox(height: RevisionSpacing.m),
         RevisionModeCard(
-          title: 'Préparation examen',
+          title: 'Préparation examen - QCM',
           description:
-              'Construis un entraînement plus proche d’un sujet d’examen.',
+              'Construis un entraînement QCM court, proche d’un sujet d’examen.',
```

### `course_exam_preparation_page.dart`

```diff
-        Text('Préparation examen', style: RevisionTypography.hero),
+        Text('Préparation examen - QCM', style: RevisionTypography.hero),
         Text(
-          'Construis un entraînement plus proche d’un sujet d’examen, à partir de ce cours.',
+          'Construis un entraînement QCM court, proche d’un sujet d’examen, à partir de ce cours.',
           style: RevisionTypography.body,
         ),

-            label: 'Chargement de la préparation examen',
+            label: 'Chargement de la préparation examen - QCM',

-              title: 'Préparation indisponible',
+              title: 'Préparation QCM indisponible',
               message:
-                  'Impossible de charger cette préparation pour le moment.',
+                  'Impossible de charger cette préparation QCM pour le moment.',

-                          options.nextStep.userMessage,
+                          _examQcmUserMessage(options.nextStep.userMessage),

-                      : 'Démarrer l’entraînement',
+                      : 'Démarrer l’entraînement QCM',

-                  'Impossible de démarrer cette préparation pour le moment.',
+                  'Impossible de démarrer cette préparation QCM pour le moment.',

-                Text(readiness.userMessage, style: RevisionTypography.body),
+                Text(
+                  _examQcmUserMessage(readiness.userMessage),
+                  style: RevisionTypography.body,
+                ),

+String _examQcmUserMessage(String value) {
+  return value
+      .replaceAllMapped(
+        RegExp(r'Préparation examen(?! - QCM)'),
+        (_) => 'Préparation examen - QCM',
+      )
+      .replaceAllMapped(
+        RegExp(r'préparation examen(?! - QCM)'),
+        (_) => 'préparation examen - QCM',
+      )
+      .replaceAll('entraînement examen', 'entraînement QCM')
+      .replaceAll('Entraînement examen', 'Entraînement QCM');
+}
```

### `revisions_pending_page.dart`

```diff
               title: 'Révision approfondie',
-              description: 'Cours complet et exemples détaillés.',
+              description:
+                  'Question ouverte, rédaction et correction détaillée.',
               icon: Icons.menu_book_rounded,
               accent: visual.accent,
-              trailingLabel: 'Bientôt disponible',
+              trailingLabel: 'Bientôt',
               enabled: false,
             ),
             const SizedBox(height: RevisionSpacing.m),
             RevisionModeCard(
-              title: 'Préparation examen',
-              description: 'Entraînements et sujets corrigés.',
+              title: 'Préparation examen - QCM',
+              description: 'Entraînement QCM court, proche d’un sujet.',
               icon: Icons.gps_fixed_rounded,
               accent: RevisionColors.pink,
-              trailingLabel: 'Bientôt disponible',
+              trailingLabel: 'Bientôt',
```

### `exam_revision_session_flow.dart`

```diff
-          Text('Préparation examen', style: RevisionTypography.sectionTitle),
+          Text(
+            'Préparation examen - QCM',
+            style: RevisionTypography.sectionTitle,
+          ),

-                  'Préparation examen',
+                  'Préparation examen - QCM',

-          _ExamHeader(
-            courseTitle: widget.activity.title,
-            questionCount: _questions.length,
-          ),
+          _ExamHeader(courseTitle: _examQcmTitle(widget.activity.title)),

-  const _ExamHeader({required this.courseTitle, required this.questionCount});
+  const _ExamHeader({required this.courseTitle});

   final String courseTitle;
-  final int questionCount;

-                  '$questionCount question(s) · score calculé à la validation',
+                  'Entraînement QCM · score calculé à la validation',

+String _examQcmTitle(String title) {
+  return title.trim() == 'Préparation examen'
+      ? 'Préparation examen - QCM'
+      : title;
+}
```

### `revision_session_page.dart`

```diff
-      title: 'Préparation examen terminée',
+      title: 'Préparation examen - QCM terminée',

-          Text(
-            'Questions riches',
-            style: Theme.of(context).textTheme.titleMedium,
-          ),
+          Text('QCM complet', style: Theme.of(context).textTheme.titleMedium),

-          Text(payload.reason),
+          Text(_richClosedReasonLabel(payload.reason)),

-    RevisionSessionActionKind.richClosedExercise => 'Questions riches',
+    RevisionSessionActionKind.richClosedExercise => 'QCM complet',

+String _richClosedReasonLabel(String reason) {
+  return reason
+      .replaceAll('Questions riches recommandées.', 'QCM complet recommandé.')
+      .replaceAll('Questions riches', 'QCM complet');
+}
```

### `revision_session_result_page.dart`

```diff
               result.session.mode == RevisionSessionMode.exam
-                  ? 'Examen terminé'
+                  ? 'Préparation examen - QCM terminée'
                   : 'Session terminée',
```

## Test hunks

### `course_detail_page_test.dart`

```diff
+  testWidgets('course detail exposes canonical revision modes honestly', (
+    tester,
+  ) async {
+    final repository = InMemoryCoursesRepository()
+      ..detailsByCourse['course-1'] = courseDetail(
+        sources: const [
+          CourseDocument(
+            id: 'document-1',
+            courseId: 'course-1',
+            documentId: 'document-1',
+            fileName: 'ready.pdf',
+            status: CourseDocumentStatus.ready,
+          ),
+        ],
+      );
+
+    await tester.pumpWidget(
+      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
+    );
+    await tester.pumpAndSettle();
+
+    await scrollToQuickRevision(tester);
+
+    expect(
+      find.widgetWithText(RevisionModeCard, 'Révision rapide'),
+      findsOneWidget,
+    );
+    expect(
+      find.widgetWithText(RevisionModeCard, 'QCM complet'),
+      findsOneWidget,
+    );
+    expect(
+      find.widgetWithText(RevisionModeCard, 'Révision approfondie'),
+      findsOneWidget,
+    );
+    expect(
+      find.widgetWithText(RevisionModeCard, 'Préparation examen - QCM'),
+      findsOneWidget,
+    );
+    expect(find.text('Bientôt'), findsNWidgets(2));
+
+    final qcmCard = tester.widget<RevisionModeCard>(
+      find.widgetWithText(RevisionModeCard, 'QCM complet'),
+    );
+    expect(qcmCard.enabled, isFalse);
+    expect(qcmCard.onTap, isNull);
+
+    final deepCard = tester.widget<RevisionModeCard>(
+      find.widgetWithText(RevisionModeCard, 'Révision approfondie'),
+    );
+    expect(deepCard.enabled, isFalse);
+    expect(deepCard.onTap, isNull);
+
+    final examCard = tester.widget<RevisionModeCard>(
+      find.widgetWithText(RevisionModeCard, 'Préparation examen - QCM'),
+    );
+    expect(examCard.enabled, isTrue);
+    expect(examCard.onTap, isNotNull);
+
+    expect(find.textContaining('Questions riches'), findsNothing);
+    expect(find.textContaining('rich closed'), findsNothing);
+    expect(find.textContaining('MVP+'), findsNothing);
+    expect(find.textContaining('backend'), findsNothing);
+  });

-    expect(find.text('Résultat questions riches'), findsOneWidget);
+    expect(find.text('Résultat QCM complet'), findsOneWidget);

-    expect(find.textContaining('Entraînement examen'), findsOneWidget);
+    expect(find.textContaining('Préparation examen - QCM'), findsWidgets);

-    expect(find.text('Résultat examen'), findsOneWidget);
+    expect(find.text('Résultat Préparation examen - QCM'), findsOneWidget);

-      await tester.scrollUntilVisible(find.text('Préparation examen'), 400);
+      await tester.scrollUntilVisible(
+        find.text('Préparation examen - QCM'),
+        400,
+      );

-        find.widgetWithText(RevisionModeCard, 'Préparation examen'),
+        find.widgetWithText(RevisionModeCard, 'Préparation examen - QCM'),

-      expect(find.text('Préparation examen dédiée'), findsOneWidget);
+      expect(find.text('Préparation examen - QCM dédiée'), findsOneWidget);
```

### `course_exam_preparation_page_test.dart`

```diff
-    expect(find.text('Préparation examen'), findsOneWidget);
+    expect(find.text('Préparation examen - QCM'), findsOneWidget);
+    expect(find.textContaining('entraînement QCM court'), findsOneWidget);

-      find.textContaining('démarrer un entraînement examen'),
+    expect(find.textContaining('démarrer un entraînement QCM'), findsOneWidget);
+    expect(find.text('Démarrer l’entraînement QCM'), findsOneWidget);
+    expect(find.textContaining('entraînement examen'), findsNothing);

-    await tester.ensureVisible(find.text('Démarrer l’entraînement'));
-    await tester.tap(find.text('Démarrer l’entraînement'));
+    await tester.ensureVisible(find.text('Démarrer l’entraînement QCM'));
+    await tester.tap(find.text('Démarrer l’entraînement QCM'));

-        'Ajoute une source prête avant de configurer une préparation examen.',
+        'Ajoute une source prête avant de configurer une préparation examen - QCM.',
```

### `revision_session_page_test.dart`

```diff
-      expect(find.text('Questions riches'), findsWidgets);
+      expect(find.text('QCM complet'), findsWidgets);
       expect(find.text('Notion : Institutions politiques'), findsOneWidget);
-      expect(find.text('Questions riches recommandées.'), findsOneWidget);
+      expect(find.text('QCM complet recommandé.'), findsOneWidget);
+      expect(find.textContaining('Questions riches'), findsNothing);

-      expect(find.text('Préparation examen'), findsWidgets);
+      expect(find.text('Préparation examen - QCM'), findsWidgets);
+      expect(find.text('Préparation examen'), findsNothing);
```

### `revision_session_result_page_test.dart`

```diff
-    expect(find.text('Examen terminé'), findsOneWidget);
+    expect(find.text('Préparation examen - QCM terminée'), findsOneWidget);
+    expect(find.text('Examen terminé'), findsNothing);
```

## Validation evidence

Les validations completes sont consignees dans `MODE_01_CANONICAL_REVISION_MODES_REPORT.md`.
