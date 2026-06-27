import 'package:Neralune/app/router/app_routes.dart';
import 'package:Neralune/features/activities/domain/open_question_activity.dart';
import 'package:Neralune/features/courses/application/courses_providers.dart';
import 'package:Neralune/features/courses/domain/course_models.dart';
import 'package:Neralune/features/courses/presentation/course_deep_revision_page.dart';
import 'package:Neralune/presentation/widgets/revision_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../fakes/in_memory_courses_repository.dart';

void main() {
  testWidgets('deep revision page starts and corrects an open question', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..deepRevisionOptionsByCourse['course-1'] = deepRevisionOptionsFixture()
      ..deepRevisionResponse = deepRevisionSessionFixture()
      ..deepRevisionSubmitResponse = deepRevisionSubmitResponseFixture();

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    expect(repository.getDeepRevisionOptionsCount, 1);
    expect(repository.lastDeepRevisionOptionsCourseId, 'course-1');
    expect(find.text('Révision approfondie'), findsOneWidget);
    expect(
      find.text('Rédige une réponse et reçois une correction détaillée.'),
      findsOneWidget,
    );
    expect(find.text('Prêt'), findsOneWidget);
    expect(find.text('Responsabilité politique'), findsOneWidget);
    expect(find.text('Support 1'), findsOneWidget);
    expect(find.text('CM.pdf'), findsNothing);
    expect(find.text('Démarrer la question ouverte'), findsOneWidget);
    expect(find.textContaining('backend'), findsNothing);
    expect(find.textContaining('payload'), findsNothing);
    expect(find.textContaining('ActivitySession'), findsNothing);
    expect(find.textContaining('RevisionSession'), findsNothing);
    expect(find.textContaining('sessionId'), findsNothing);
    expect(find.textContaining('documentId'), findsNothing);
    expect(find.textContaining('knowledgeUnitId'), findsNothing);

    await tester.ensureVisible(find.text('Démarrer la question ouverte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Démarrer la question ouverte'));
    await tester.pumpAndSettle();

    expect(repository.startDeepRevisionCount, 1);
    expect(repository.lastDeepRevisionCourseId, 'course-1');
    expect(
      repository.lastDeepRevisionConfig?.scopeKind,
      CourseDeepRevisionScopeKind.knowledgeUnit,
    );
    expect(repository.lastDeepRevisionConfig?.scopeId, 'ku-1');
    expect(find.text('Question ouverte'), findsOneWidget);
    expect(
      find.text('Explique la responsabilité politique du Gouvernement.'),
      findsOneWidget,
    );
    expect(find.text('Sources du cours'), findsWidgets);

    await tester.enterText(find.byType(TextField), 'Trop court');
    await tester.pumpAndSettle();
    expect(find.text('Réponse trop courte'), findsOneWidget);
    final shortButton = tester.widget<RevisionButton>(
      find.widgetWithText(RevisionButton, 'Envoyer ma réponse'),
    );
    expect(shortButton.onPressed, isNull);

    await tester.enterText(
      find.byType(TextField),
      'La responsabilité politique permet au Parlement de contrôler le Gouvernement.',
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Envoyer ma réponse'));
    await tester.tap(find.text('Envoyer ma réponse'));
    await tester.pumpAndSettle();

    expect(repository.submitDeepRevisionAnswerCount, 1);
    expect(repository.lastDeepRevisionSubmitCourseId, 'course-1');
    expect(repository.lastDeepRevisionSubmitSessionId, 'deep-session-1');
    expect(repository.lastDeepRevisionAnswer, contains('contrôler'));
    expect(find.textContaining('Score 0.7 / 1'), findsOneWidget);
    expect(
      find.text('Bonne structure, mais il manque une nuance.'),
      findsOneWidget,
    );
    expect(find.text('Points réussis'), findsOneWidget);
    expect(find.textContaining('Contrôle parlementaire'), findsOneWidget);
    expect(find.text('Points à compléter'), findsOneWidget);
    expect(find.textContaining('Responsabilité collective'), findsOneWidget);
    expect(find.text('Réponse modèle'), findsOneWidget);
    expect(
      find.text('Une réponse modèle rappelle le contrôle politique.'),
      findsOneWidget,
    );
    expect(find.text('Sources du cours'), findsWidgets);
    expect(find.text('Voir le résultat'), findsOneWidget);
    expect(find.text('Retour au cours'), findsOneWidget);

    await tester.ensureVisible(find.text('Voir le résultat'));
    await tester.tap(find.text('Voir le résultat'));
    await tester.pumpAndSettle();

    expect(find.text('Résultat réel de révision approfondie'), findsOneWidget);
  });

  testWidgets('deep revision page explains blocked state without fake button', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..deepRevisionOptionsByCourse['course-1'] = deepRevisionOptionsFixture(
        state: CourseDeepRevisionReadinessState.blocked,
      );

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Action nécessaire'), findsOneWidget);
    expect(find.text('Configuration indisponible'), findsOneWidget);
    expect(
      find.text('Ajoute une source pour rédiger une réponse.'),
      findsWidgets,
    );
    expect(find.text('Notion'), findsNothing);
    expect(find.text('Démarrer la question ouverte'), findsNothing);
    expect(repository.startDeepRevisionCount, 0);
  });
}

Widget testApp(InMemoryCoursesRepository repository) {
  final router = GoRouter(
    initialLocation: AppRoutes.courseDeepRevision('course-1'),
    routes: [
      GoRoute(
        path: AppRoutes.courseDeepRevisionPath,
        builder: (context, state) =>
            CourseDeepRevisionPage(courseId: state.pathParameters['courseId']!),
      ),
      GoRoute(
        path: AppRoutes.courseDeepRevisionResultPath,
        builder: (context, state) =>
            const Scaffold(body: Text('Résultat réel de révision approfondie')),
      ),
      GoRoute(
        path: AppRoutes.coursePath,
        builder: (context, state) => const Scaffold(body: Text('Cours')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp.router(routerConfig: router),
  );
}

CourseDetail courseDetail() {
  const course = CourseListItem(
    id: 'course-1',
    subjectId: 'subject-1',
    title: 'Droit constitutionnel',
    sourceCount: 1,
    readySourceCount: 1,
    processingSourceCount: 0,
    failedSourceCount: 0,
  );
  return CourseDetail(
    course: course,
    subject: const CourseSubjectSummary(id: 'subject-1', name: 'Droit'),
    sources: const [
      CourseDocument(
        id: 'document-1',
        courseId: 'course-1',
        documentId: 'document-1',
        fileName: 'CM.pdf',
        status: CourseDocumentStatus.ready,
      ),
    ],
  );
}

CourseDeepRevisionOptions deepRevisionOptionsFixture({
  CourseDeepRevisionReadinessState state =
      CourseDeepRevisionReadinessState.ready,
}) {
  final canStart = state == CourseDeepRevisionReadinessState.ready;

  return CourseDeepRevisionOptions(
    course: const CourseDeepRevisionCourse(
      id: 'course-1',
      title: 'Droit constitutionnel',
      subjectId: 'subject-1',
    ),
    readiness: CourseDeepRevisionReadiness(
      canStart: canStart,
      state: state,
      userMessage: canStart
          ? 'Ton cours est prêt pour une révision approfondie.'
          : 'Ajoute une source pour rédiger une réponse.',
      blockers: canStart ? const [] : const ['NO_READY_SOURCE'],
      readySourceCount: canStart ? 1 : 0,
      readyKnowledgeUnitCount: canStart ? 1 : 0,
    ),
    scopeOptions: canStart
        ? const [
            CourseDeepRevisionScopeOption(
              kind: CourseDeepRevisionScopeKind.knowledgeUnit,
              id: 'ku-1',
              documentId: 'document-1',
              label: 'Responsabilité politique',
              sourceLabel: 'CM.pdf',
              canSelect: true,
            ),
          ]
        : const [],
    answerGuidelines: const CourseDeepRevisionAnswerGuidelines(
      minLength: 12,
      maxLength: 4000,
      userMessage: 'Rédige une réponse structurée avec tes propres mots.',
    ),
    defaultConfig: canStart
        ? const CourseDeepRevisionConfig(
            scopeKind: CourseDeepRevisionScopeKind.knowledgeUnit,
            scopeId: 'ku-1',
          )
        : null,
    nextStep: CourseDeepRevisionNextStep(
      kind: canStart ? 'configuration_ready' : 'blocked',
      userMessage: canStart
          ? 'Choisis une notion et démarre la question ouverte.'
          : 'Ajoute une source pour rédiger une réponse.',
    ),
  );
}

CourseDeepRevisionSession deepRevisionSessionFixture() {
  return const CourseDeepRevisionSession(
    session: CourseDeepRevisionSessionSummary(
      id: 'deep-session-1',
      mode: 'DEEP',
      status: 'STARTED',
      courseId: 'course-1',
    ),
    question: OpenQuestion(
      id: 'open-question-1',
      prompt: 'Explique la responsabilité politique du Gouvernement.',
      instructions: 'Structure ta réponse en deux idées.',
      maxAnswerLength: 4000,
      sources: [
        OpenQuestionSource(chunkId: 'chunk-1', pageNumber: 4, index: 0),
      ],
    ),
    scope: CourseDeepRevisionScope(
      kind: CourseDeepRevisionScopeKind.knowledgeUnit,
      id: 'ku-1',
      label: 'Responsabilité politique',
      sourceLabel: 'CM.pdf',
    ),
    answerGuidelines: CourseDeepRevisionAnswerGuidelines(
      minLength: 12,
      maxLength: 4000,
      userMessage: 'Rédige une réponse structurée avec tes propres mots.',
    ),
  );
}

CourseDeepRevisionSubmitResponse deepRevisionSubmitResponseFixture() {
  return CourseDeepRevisionSubmitResponse(
    session: CourseDeepRevisionSessionSummary(
      id: 'deep-session-1',
      mode: 'DEEP',
      status: 'COMPLETED',
      courseId: 'course-1',
      completedAt: DateTime.parse('2026-06-25T12:00:00.000Z'),
    ),
    resultPath:
        '/courses/course-1/deep-revision/sessions/deep-session-1/result',
    evaluation: const OpenAnswerEvaluation(
      id: 'evaluation-1',
      status: OpenAnswerEvaluationStatus.ready,
      score: 0.72,
      maxScore: 1,
      feedback: 'Bonne structure, mais il manque une nuance.',
      presentPoints: ['Contrôle parlementaire'],
      missingPoints: ['Responsabilité collective'],
      errors: ['Confusion légère avec la responsabilité pénale'],
      modelAnswer: 'Une réponse modèle rappelle le contrôle politique.',
      advice: 'Reprends les conditions de mise en jeu.',
      sources: [
        OpenAnswerCorrectionSource(
          chunkId: 'chunk-1',
          text: 'Le Gouvernement est responsable devant le Parlement.',
          pageNumber: 4,
          index: 0,
        ),
      ],
    ),
  );
}
