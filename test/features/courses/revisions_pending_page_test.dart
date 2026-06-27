import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/app/di/providers.dart';
import 'package:Neralune/app/router/app_routes.dart';
import 'package:Neralune/features/courses/application/courses_providers.dart';
import 'package:Neralune/features/courses/domain/course_models.dart';
import 'package:Neralune/features/courses/domain/courses_repository.dart';
import 'package:Neralune/features/courses/presentation/revisions_pending_page.dart';
import 'package:Neralune/features/documents/domain/revision_document.dart';
import 'package:Neralune/features/subjects/domain/subject.dart';

import '../../fakes/in_memory_courses_repository.dart';
import '../../fakes/in_memory_subjects_repository.dart';

void main() {
  testWidgets('revision hub stays actionable when no course is ready', (
    tester,
  ) async {
    final coursesRepository = InMemoryCoursesRepository()
      ..coursesBySubject['subject-1'] = const [
        CourseListItem(
          id: 'course-1',
          subjectId: 'subject-1',
          title: 'Cours sans source prête',
          sourceCount: 1,
          processingSourceCount: 1,
        ),
      ];

    await tester.pumpWidget(
      revisionHubTestApp(coursesRepository: coursesRepository),
    );
    await tester.pumpAndSettle();

    expect(find.text('Réviser depuis un cours'), findsOneWidget);
    expect(
      find.text(
        'Choisis un cours prêt pour lancer une session courte. Les questions sont préparées à partir de tes sources.',
      ),
      findsOneWidget,
    );
    expect(find.text('Préparer un cours'), findsOneWidget);
    expect(find.text('Ouvrir les cours'), findsOneWidget);
    expect(find.text('Commencer 5 questions'), findsNothing);
    expect(find.textContaining('MVP+'), findsNothing);
    expect(find.textContaining('backend'), findsNothing);
    expect(find.textContaining('payload'), findsNothing);
  });

  testWidgets('revision hub starts quick revision directly with 5 questions', (
    tester,
  ) async {
    final coursesRepository = InMemoryCoursesRepository()
      ..coursesBySubject['subject-1'] = const [
        CourseListItem(
          id: 'course-1',
          subjectId: 'subject-1',
          title: 'Institutions',
          sourceCount: 1,
          readySourceCount: 1,
        ),
      ]
      ..detailsByCourse['course-1'] = const CourseDetail(
        course: CourseListItem(
          id: 'course-1',
          subjectId: 'subject-1',
          title: 'Institutions',
          sourceCount: 1,
          readySourceCount: 1,
        ),
        subject: CourseSubjectSummary(id: 'subject-1', name: 'Droits'),
        sources: [
          CourseDocument(
            id: 'source-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'cours.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      );

    await tester.pumpWidget(
      revisionHubTestApp(coursesRepository: coursesRepository),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Commencer 5 questions').first);
    await tester.pumpAndSettle();

    expect(coursesRepository.startQuickRevisionCount, 1);
    expect(coursesRepository.lastQuickRevisionCourseId, 'course-1');
    expect(coursesRepository.lastQuickRevisionQuestionCount, 5);
    expect(find.text('Session démarrée'), findsOneWidget);
  });

  testWidgets('revision hub quick preparation error offers sheet fallback', (
    tester,
  ) async {
    final coursesRepository = InMemoryCoursesRepository()
      ..coursesBySubject['subject-1'] = const [
        CourseListItem(
          id: 'course-1',
          subjectId: 'subject-1',
          title: 'Institutions',
          sourceCount: 1,
          readySourceCount: 1,
        ),
      ]
      ..detailsByCourse['course-1'] = const CourseDetail(
        course: CourseListItem(
          id: 'course-1',
          subjectId: 'subject-1',
          title: 'Institutions',
          sourceCount: 1,
          readySourceCount: 1,
        ),
        subject: CourseSubjectSummary(id: 'subject-1', name: 'Droits'),
        sources: [
          CourseDocument(
            id: 'source-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'cours.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      )
      ..revisionSheetsByCourse['course-1'] = revisionSheet()
      ..quickRevisionError = const CourseQuickRevisionUnavailableException(
        'COURSE_QUICK_REVISION_QUESTIONS_PREPARING',
        readiness: CourseQuestionBankReadiness(
          courseId: 'course-1',
          status: CourseQuestionBankReadinessStatus.preparing,
          readyQuestionCount: 0,
          targetQuestionCount: 5,
          canStartQuickRevision: false,
          canPrepare: false,
          userMessage:
              'Les questions sont en préparation. Réessaie dans un instant.',
        ),
      );

    await tester.pumpWidget(
      revisionHubTestApp(coursesRepository: coursesRepository),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Commencer 5 questions').first);
    await tester.pumpAndSettle();

    expect(find.text('Questions en préparation'), findsOneWidget);
    expect(find.text('Lire la fiche'), findsOneWidget);
    expect(find.text('Voir le parcours'), findsOneWidget);
    expect(find.textContaining('COURSE_QUICK_REVISION'), findsNothing);
    expect(find.textContaining('409'), findsNothing);
    expect(find.textContaining('backend'), findsNothing);
    expect(find.textContaining('payload'), findsNothing);

    await tester.tap(find.text('Lire la fiche'));
    await tester.pumpAndSettle();

    expect(find.text('Fiche prête'), findsOneWidget);
  });
}

Widget revisionHubTestApp({
  required InMemoryCoursesRepository coursesRepository,
}) {
  final subjectsRepository = InMemorySubjectsRepository()
    ..subjects.add(const Subject(id: 'subject-1', name: 'Droits', priority: 3));

  final router = GoRouter(
    initialLocation: AppRoutes.revisions,
    routes: [
      GoRoute(
        path: AppRoutes.revisions,
        builder: (context, state) => const RevisionsPendingPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const Text('Accueil'),
      ),
      GoRoute(
        path: AppRoutes.coursePath,
        builder: (context, state) =>
            Text('Cours ${state.pathParameters['courseId']}'),
      ),
      GoRoute(
        path: AppRoutes.courseSheetPath,
        builder: (context, state) => const Text('Fiche prête'),
      ),
      GoRoute(
        path: AppRoutes.revisionSessionV2Path,
        builder: (context, state) => const Text('Session démarrée'),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      subjectsRepositoryProvider.overrideWithValue(subjectsRepository),
      coursesRepositoryProvider.overrideWithValue(coursesRepository),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

RevisionSheet revisionSheet() {
  return const RevisionSheet(
    id: 'sheet-1',
    documentId: 'document-1',
    subjectId: 'subject-1',
    status: 'READY',
    title: 'Fiche de cours',
    introduction: 'Introduction',
    sections: [
      RevisionSheetSection(
        id: 'section-1',
        displayOrder: 0,
        title: 'Institutions',
        content: 'Le Parlement contrôle le Gouvernement.',
        sources: [],
      ),
    ],
    keyPoints: ['Point clé'],
    commonMistakes: ['Erreur fréquente'],
    mustKnow: ['À savoir'],
    practiceSuggestions: ['S’entraîner'],
    errorCode: null,
  );
}
