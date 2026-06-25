import 'package:Neralune/app/router/app_routes.dart';
import 'package:Neralune/features/activities/domain/rich_closed_exercise.dart';
import 'package:Neralune/features/courses/application/courses_providers.dart';
import 'package:Neralune/features/courses/domain/course_models.dart';
import 'package:Neralune/features/courses/presentation/course_rich_revision_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../fakes/in_memory_courses_repository.dart';
import '../activities/fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  testWidgets('QCM complet page starts a real rich exercise by session', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..richRevisionOptionsByCourse['course-1'] = richRevisionOptionsFixture()
      ..richRevisionResponse = RichClosedExercise.fromJson(
        richClosedExerciseJson(),
      );

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    expect(repository.getRichRevisionOptionsCount, 1);
    expect(repository.lastRichRevisionOptionsCourseId, 'course-1');
    expect(find.text('QCM complet'), findsOneWidget);
    expect(find.textContaining('questions variées'), findsOneWidget);
    expect(find.text('Prêt'), findsOneWidget);
    expect(find.text('Responsabilité politique'), findsOneWidget);
    expect(find.text('CM.pdf'), findsOneWidget);
    expect(find.text('6 questions'), findsOneWidget);
    expect(find.text('10 questions'), findsOneWidget);
    expect(find.text('13 questions'), findsOneWidget);
    expect(find.text('14 questions'), findsNothing);
    expect(find.text('Standard'), findsOneWidget);
    expect(find.text('Avancé'), findsOneWidget);
    expect(find.text('Démarrer le QCM complet'), findsOneWidget);
    expect(find.textContaining('rich closed'), findsNothing);
    expect(find.textContaining('backend'), findsNothing);
    expect(find.textContaining('sessionId'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, '10 questions'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Avancé'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Avancé'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Démarrer le QCM complet'));
    await tester.tap(find.text('Démarrer le QCM complet'));
    await tester.pumpAndSettle();

    expect(repository.startRichRevisionCount, 1);
    expect(repository.lastRichRevisionCourseId, 'course-1');
    expect(
      repository.lastRichRevisionConfig?.scopeKind,
      CourseRichRevisionScopeKind.knowledgeUnit,
    );
    expect(repository.lastRichRevisionConfig?.scopeId, 'ku-1');
    expect(repository.lastRichRevisionConfig?.questionCount, 10);
    expect(repository.lastRichRevisionConfig?.complexityProfile, 'advanced');
    expect(find.text('QCM session rich-session-1'), findsOneWidget);
  });

  testWidgets('QCM complet page explains blocked state without fake button', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..richRevisionOptionsByCourse['course-1'] = richRevisionOptionsFixture(
        state: CourseRichRevisionReadinessState.blocked,
      );

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Action nécessaire'), findsOneWidget);
    expect(find.text('Configuration indisponible'), findsOneWidget);
    expect(
      find.text('Ajoute une source pour lancer un QCM complet.'),
      findsWidgets,
    );
    expect(find.text('Notion'), findsNothing);
    expect(find.text('Nombre de questions'), findsNothing);
    expect(find.textContaining('Démarrer'), findsNothing);
    expect(repository.startRichRevisionCount, 0);
  });
}

Widget testApp(InMemoryCoursesRepository repository) {
  final router = GoRouter(
    initialLocation: AppRoutes.courseRichRevision('course-1'),
    routes: [
      GoRoute(
        path: AppRoutes.courseRichRevisionPath,
        builder: (context, state) =>
            CourseRichRevisionPage(courseId: state.pathParameters['courseId']!),
      ),
      GoRoute(
        path: AppRoutes.richClosedExercisePath,
        builder: (context, state) => Scaffold(
          body: Text('QCM session ${state.uri.queryParameters['sessionId']}'),
        ),
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

CourseRichRevisionOptions richRevisionOptionsFixture({
  CourseRichRevisionReadinessState state =
      CourseRichRevisionReadinessState.ready,
}) {
  final canStart = state == CourseRichRevisionReadinessState.ready;

  return CourseRichRevisionOptions(
    course: const CourseRichRevisionCourse(
      id: 'course-1',
      title: 'Droit constitutionnel',
      subjectId: 'subject-1',
    ),
    readiness: CourseRichRevisionReadiness(
      canStart: canStart,
      state: state,
      userMessage: canStart
          ? 'Ton cours est prêt pour un QCM complet.'
          : 'Ajoute une source pour lancer un QCM complet.',
      blockers: canStart ? const [] : const ['NO_READY_SOURCE'],
      readySourceCount: canStart ? 1 : 0,
      readyKnowledgeUnitCount: canStart ? 1 : 0,
    ),
    scopeOptions: canStart
        ? const [
            CourseRichRevisionScopeOption(
              kind: CourseRichRevisionScopeKind.knowledgeUnit,
              id: 'ku-1',
              documentId: 'document-1',
              label: 'Responsabilité politique',
              sourceLabel: 'CM.pdf',
              canSelect: true,
            ),
          ]
        : const [],
    questionCountOptions: canStart ? const [6, 10, 13] : const [],
    defaultQuestionCount: canStart ? 6 : null,
    supportedQuestionKinds: const [
      'single_choice',
      'multiple_choice',
      'matching',
    ],
    complexityProfiles: const ['standard', 'advanced'],
    defaultConfig: canStart
        ? const CourseRichRevisionConfig(
            scopeKind: CourseRichRevisionScopeKind.knowledgeUnit,
            scopeId: 'ku-1',
            questionCount: 6,
            complexityProfile: 'standard',
          )
        : null,
    nextStep: CourseRichRevisionNextStep(
      kind: canStart ? 'configuration_ready' : 'blocked',
      userMessage: canStart
          ? 'Choisis une notion et démarre le QCM complet.'
          : 'Ajoute une source pour lancer un QCM complet.',
    ),
  );
}
