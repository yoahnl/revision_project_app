import 'package:Neralune/app/router/app_routes.dart';
import 'package:Neralune/features/activities/domain/open_question_activity.dart';
import 'package:Neralune/features/courses/application/courses_providers.dart';
import 'package:Neralune/features/courses/domain/course_models.dart';
import 'package:Neralune/features/courses/domain/courses_repository.dart';
import 'package:Neralune/features/courses/presentation/course_deep_revision_result_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../fakes/in_memory_courses_repository.dart';

void main() {
  testWidgets('deep revision result page displays backend result details', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..deepRevisionResultBySession['deep-session-1'] = deepRevisionResult();

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    expect(repository.getCourseDeepRevisionResultCount, 1);
    expect(repository.lastDeepRevisionResultCourseId, 'course-1');
    expect(repository.lastDeepRevisionResultSessionId, 'deep-session-1');
    expect(find.text('Résultat de révision approfondie'), findsOneWidget);
    expect(find.text('Responsabilité politique'), findsOneWidget);
    expect(find.text('Support 1'), findsOneWidget);
    expect(find.text('CM.pdf'), findsNothing);
    expect(find.textContaining('Score 0.7 / 1'), findsOneWidget);
    expect(
      find.text('Explique la responsabilité politique du Gouvernement.'),
      findsOneWidget,
    );
    expect(find.text('Réponse envoyée'), findsOneWidget);
    expect(find.textContaining('contrôler le Gouvernement'), findsOneWidget);
    expect(
      find.text('Bonne structure, mais il manque une nuance.'),
      findsOneWidget,
    );
    expect(find.text('Points réussis'), findsOneWidget);
    expect(find.text('Points à compléter'), findsOneWidget);
    expect(find.text('Réponse modèle'), findsOneWidget);
    expect(find.text('Sources du cours'), findsOneWidget);
    expect(find.text('Retour au cours'), findsOneWidget);
    expect(find.textContaining('backend'), findsNothing);
    expect(find.textContaining('payload'), findsNothing);
    expect(find.textContaining('ActivitySession'), findsNothing);
    expect(find.textContaining('RevisionSession'), findsNothing);
    expect(find.textContaining('sessionId'), findsNothing);
    expect(find.textContaining('documentId'), findsNothing);
    expect(find.textContaining('knowledgeUnitId'), findsNothing);
  });

  testWidgets(
    'deep revision result page shows a user-facing unavailable state',
    (tester) async {
      final repository = InMemoryCoursesRepository()
        ..deepRevisionResultError = const CourseRequestException(
          'Résultat indisponible',
        );

      await tester.pumpWidget(testApp(repository));
      await tester.pumpAndSettle();

      expect(find.text('Résultat indisponible'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
      expect(find.textContaining('backend'), findsNothing);
    },
  );
}

Widget testApp(InMemoryCoursesRepository repository) {
  final router = GoRouter(
    initialLocation: AppRoutes.courseDeepRevisionResult(
      courseId: 'course-1',
      sessionId: 'deep-session-1',
    ),
    routes: [
      GoRoute(
        path: AppRoutes.courseDeepRevisionResultPath,
        builder: (context, state) => CourseDeepRevisionResultPage(
          courseId: state.pathParameters['courseId']!,
          sessionId: state.pathParameters['sessionId']!,
        ),
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

CourseDeepRevisionResult deepRevisionResult() {
  return CourseDeepRevisionResult(
    session: CourseDeepRevisionResultSession(
      id: 'deep-session-1',
      status: 'COMPLETED',
      courseId: 'course-1',
      completedAt: DateTime.parse('2026-06-25T12:00:00.000Z'),
    ),
    scope: const CourseDeepRevisionScope(
      kind: CourseDeepRevisionScopeKind.knowledgeUnit,
      id: 'ku-1',
      label: 'Responsabilité politique',
      sourceLabel: 'CM.pdf',
    ),
    question: const OpenQuestion(
      id: 'open-question-1',
      prompt: 'Explique la responsabilité politique du Gouvernement.',
      instructions: 'Structure ta réponse en deux idées.',
      maxAnswerLength: 4000,
      sources: [
        OpenQuestionSource(chunkId: 'chunk-1', pageNumber: 4, index: 0),
      ],
    ),
    answer: CourseDeepRevisionAnswer(
      text:
          'La responsabilité politique permet au Parlement de contrôler le Gouvernement.',
      submittedAt: DateTime.parse('2026-06-25T12:00:00.000Z'),
    ),
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
