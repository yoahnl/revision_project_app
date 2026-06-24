import 'package:Neralune/features/courses/application/courses_providers.dart';
import 'package:Neralune/features/courses/domain/course_models.dart';
import 'package:Neralune/features/courses/presentation/course_exam_preparation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/in_memory_courses_repository.dart';

void main() {
  testWidgets(
    'exam preparation page displays ready options without fake start',
    (tester) async {
      final repository = InMemoryCoursesRepository()
        ..detailsByCourse['course-1'] = courseDetail()
        ..examPreparationOptionsByCourse['course-1'] =
            examPreparationOptionsFixture();

      await tester.pumpWidget(testApp(repository));
      await tester.pumpAndSettle();

      expect(repository.getExamPreparationOptionsCount, 1);
      expect(repository.lastExamPreparationOptionsCourseId, 'course-1');
      expect(find.text('Préparation examen'), findsOneWidget);
      expect(find.text('Prêt'), findsOneWidget);
      expect(find.text('Tout le cours'), findsOneWidget);
      expect(find.text('CM.pdf'), findsOneWidget);
      expect(find.text('20 questions'), findsOneWidget);
      expect(find.text('Types de questions'), findsOneWidget);
      expect(find.text('choix simple, choix multiple'), findsOneWidget);
      expect(find.text('Configuration prête'), findsOneWidget);
      expect(find.textContaining('session complète arrive'), findsOneWidget);
      expect(find.textContaining('Démarrer'), findsNothing);

      final tenQuestionsChip = find.widgetWithText(ChoiceChip, '10 questions');
      await tester.ensureVisible(tenQuestionsChip);
      await tester.tap(tenQuestionsChip);
      await tester.pumpAndSettle();

      final selectedChip = tester.widget<ChoiceChip>(tenQuestionsChip);
      expect(selectedChip.selected, isTrue);
    },
  );

  testWidgets('exam preparation page explains blocked state without options', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..examPreparationOptionsByCourse['course-1'] =
          examPreparationOptionsFixture(
            state: CourseExamPreparationReadinessState.blocked,
          );

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Action nécessaire'), findsOneWidget);
    expect(find.text('Configuration indisponible'), findsOneWidget);
    expect(
      find.text(
        'Ajoute une source prête avant de configurer une préparation examen.',
      ),
      findsWidgets,
    );
    expect(find.text('Périmètre'), findsNothing);
    expect(find.text('Nombre de questions'), findsNothing);
    expect(find.textContaining('Démarrer'), findsNothing);
  });
}

Widget testApp(InMemoryCoursesRepository repository) {
  return ProviderScope(
    overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(
      home: CourseExamPreparationPage(courseId: 'course-1'),
    ),
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

CourseExamPreparationOptions examPreparationOptionsFixture({
  CourseExamPreparationReadinessState state =
      CourseExamPreparationReadinessState.ready,
}) {
  final canPrepare = state == CourseExamPreparationReadinessState.ready;

  return CourseExamPreparationOptions(
    course: const CourseExamPreparationCourse(
      id: 'course-1',
      title: 'Droit constitutionnel',
      subjectId: 'subject-1',
    ),
    readiness: CourseExamPreparationReadiness(
      canPrepare: canPrepare,
      state: state,
      userMessage: canPrepare
          ? 'Ton cours est prêt pour une préparation examen.'
          : 'Ajoute une source prête avant de configurer une préparation examen.',
      blockers: canPrepare ? const [] : const ['NO_READY_SOURCE'],
      readySourceCount: canPrepare ? 1 : 0,
      readyKnowledgeUnitCount: canPrepare ? 2 : 0,
      availableQuestionCount: canPrepare ? 20 : 0,
    ),
    scopeOptions: canPrepare
        ? const [
            CourseExamPreparationScopeOption(
              kind: CourseExamPreparationScopeKind.course,
              id: 'course-1',
              label: 'Tout le cours',
              readyQuestionCount: 20,
              readyKnowledgeUnitCount: 2,
              canSelect: true,
            ),
            CourseExamPreparationScopeOption(
              kind: CourseExamPreparationScopeKind.source,
              id: 'document-1',
              label: 'CM.pdf',
              readyQuestionCount: 12,
              readyKnowledgeUnitCount: 1,
              canSelect: true,
            ),
          ]
        : const [],
    questionCountOptions: canPrepare ? const [10, 20] : const [],
    defaultQuestionCount: canPrepare ? 20 : null,
    supportedQuestionKinds: const ['single_choice', 'multiple_choice'],
    defaultConfig: canPrepare
        ? const CourseExamPreparationConfig(
            scopeKind: CourseExamPreparationScopeKind.course,
            scopeId: 'course-1',
            questionCount: 20,
            complexityProfile: 'exam',
          )
        : null,
    nextStep: CourseExamPreparationNextStep(
      kind: canPrepare ? 'configuration_ready' : 'blocked',
      userMessage: canPrepare
          ? 'Configuration prête. La session complète arrive ensuite.'
          : 'Ajoute une source prête avant de configurer une préparation examen.',
    ),
  );
}
