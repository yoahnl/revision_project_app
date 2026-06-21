import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/app/di/providers.dart';
import 'package:Neralune/app/router/app_routes.dart';
import 'package:Neralune/features/courses/application/courses_providers.dart';
import 'package:Neralune/features/courses/domain/course_models.dart';
import 'package:Neralune/features/courses/presentation/revisions_pending_page.dart';
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

    expect(find.text('Réviser'), findsWidgets);
    expect(find.text('Choisis une session courte et utile.'), findsOneWidget);
    expect(find.text('Préparer un cours'), findsOneWidget);
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
