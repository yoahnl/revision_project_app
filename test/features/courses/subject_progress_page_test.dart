import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/app/di/providers.dart';
import 'package:revision_app/app/router/app_routes.dart';
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/courses/presentation/subject_progress_page.dart';
import 'package:revision_app/features/subjects/domain/subject.dart';

import '../../fakes/in_memory_courses_repository.dart';
import '../../fakes/in_memory_subjects_repository.dart';

void main() {
  testWidgets('progress page shows an honest empty state without subjects', (
    tester,
  ) async {
    await tester.pumpWidget(
      progressTestApp(
        subjectsRepository: InMemorySubjectsRepository(),
        coursesRepository: InMemoryCoursesRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Progrès'), findsOneWidget);
    expect(find.text('Aucune matière réelle'), findsOneWidget);
    expect(find.text('78%'), findsNothing);
    expect(find.text('870'), findsNothing);
    expect(find.text('7 jours'), findsNothing);
  });

  testWidgets('progress page displays real subject and course progress', (
    tester,
  ) async {
    final subjectsRepository = InMemorySubjectsRepository()
      ..subjects.add(
        const Subject(
          id: 'subject-1',
          name: 'Droit constitutionnel',
          priority: 4,
        ),
      );
    final coursesRepository = InMemoryCoursesRepository()
      ..progressBySubject['subject-1'] = subjectProgress();

    await tester.pumpWidget(
      progressTestApp(
        subjectsRepository: subjectsRepository,
        coursesRepository: coursesRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Droit constitutionnel'), findsOneWidget);
    expect(find.text('3/12 notions travaillées'), findsWidgets);
    expect(find.text('Maîtrise travaillée : 72%'), findsOneWidget);
    expect(find.text('Estimation globale : 18%'), findsOneWidget);
    expect(find.text('Institutions'), findsOneWidget);
    expect(
      find.text('Progression réelle basée sur tes réponses.'),
      findsOneWidget,
    );
    expect(find.text('78%'), findsNothing);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('progress page opens a course from the real progress list', (
    tester,
  ) async {
    final subjectsRepository = InMemorySubjectsRepository()
      ..subjects.add(
        const Subject(
          id: 'subject-1',
          name: 'Droit constitutionnel',
          priority: 4,
        ),
      );
    final coursesRepository = InMemoryCoursesRepository()
      ..progressBySubject['subject-1'] = subjectProgress();

    final router = GoRouter(
      initialLocation: AppRoutes.progress,
      routes: [
        GoRoute(
          path: AppRoutes.progress,
          builder: (context, state) => const SubjectProgressPage(),
        ),
        GoRoute(
          path: AppRoutes.coursePath,
          builder: (context, state) => Text(
            'Cours ${state.pathParameters['courseId']}',
            textDirection: TextDirection.ltr,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      progressTestApp(
        subjectsRepository: subjectsRepository,
        coursesRepository: coursesRepository,
        router: router,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Institutions'));
    await tester.pumpAndSettle();

    expect(find.text('Cours course-1'), findsOneWidget);
  });
}

Widget progressTestApp({
  required InMemorySubjectsRepository subjectsRepository,
  required InMemoryCoursesRepository coursesRepository,
  GoRouter? router,
}) {
  return ProviderScope(
    overrides: [
      subjectsRepositoryProvider.overrideWithValue(subjectsRepository),
      coursesRepositoryProvider.overrideWithValue(coursesRepository),
    ],
    child: router == null
        ? const MaterialApp(home: Scaffold(body: SubjectProgressPage()))
        : MaterialApp.router(routerConfig: router),
  );
}

SubjectProgress subjectProgress() {
  return const SubjectProgress(
    subjectId: 'subject-1',
    knowledgeUnitCount: 12,
    practicedKnowledgeUnitCount: 3,
    coverage: 0.25,
    mastery: 0.72,
    estimatedGlobalMastery: 0.18,
    courseCount: 1,
    readyCourseCount: 1,
    courses: [
      SubjectCourseProgressItem(
        courseId: 'course-1',
        title: 'Institutions',
        knowledgeUnitCount: 12,
        practicedKnowledgeUnitCount: 3,
        coverage: 0.25,
        mastery: 0.72,
        estimatedGlobalMastery: 0.18,
        state: CourseProgressState.practiced,
      ),
    ],
  );
}
