import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/app/di/providers.dart';
import 'package:Neralune/app/router/app_routes.dart';
import 'package:Neralune/features/courses/application/courses_providers.dart';
import 'package:Neralune/features/courses/domain/course_models.dart';
import 'package:Neralune/features/courses/presentation/courses_home_page.dart';
import 'package:Neralune/features/subjects/domain/subject.dart';
import 'package:Neralune/presentation/design_system/components/revision_mvp_components.dart';
import 'package:Neralune/presentation/theme/app_theme.dart';
import 'package:Neralune/presentation/widgets/revision_background.dart';

import '../../fakes/in_memory_courses_repository.dart';
import '../../fakes/in_memory_subjects_repository.dart';

void main() {
  testWidgets('shows the V4 library for an active subject without fake data', (
    tester,
  ) async {
    final subjectsRepository = InMemorySubjectsRepository()
      ..subjects.addAll(const [
        Subject(id: 'subject-law', name: 'Droit', priority: 4),
        Subject(id: 'subject-economy', name: 'Économie', priority: 3),
      ]);
    final coursesRepository = InMemoryCoursesRepository()
      ..coursesBySubject['subject-law'] = [
        _course(
          id: 'course-constitutional',
          title: 'Droit constitutionnel',
          readySourceCount: 1,
          sourceCount: 1,
          progress: _progress(
            courseId: 'course-constitutional',
            estimatedGlobalMastery: 0.62,
            knowledgeUnitCount: 6,
            practicedKnowledgeUnitCount: 4,
            state: CourseProgressState.practiced,
          ),
        ),
        _course(
          id: 'course-administrative',
          title: 'Droit administratif',
          readySourceCount: 1,
          sourceCount: 2,
          progress: _progress(
            courseId: 'course-administrative',
            estimatedGlobalMastery: 0.38,
            knowledgeUnitCount: 4,
            practicedKnowledgeUnitCount: 2,
            state: CourseProgressState.readyNotPracticed,
          ),
        ),
        _course(
          id: 'course-eu',
          title: 'Institutions européennes',
          readySourceCount: 1,
          sourceCount: 1,
        ),
      ];

    final router = _router(
      subjectsRepository: subjectsRepository,
      coursesRepository: coursesRepository,
    );

    await tester.pumpWidget(
      _buildApp(
        router: router,
        subjectsRepository: subjectsRepository,
        coursesRepository: coursesRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cours'), findsOneWidget);
    expect(find.byTooltip('Créer'), findsOneWidget);
    expect(find.byType(RevisionSubjectSwitcher), findsOneWidget);
    expect(find.text('Droit'), findsWidgets);
    expect(find.text('3 cours · 10 notions'), findsOneWidget);
    expect(find.text('28 notions'), findsNothing);
    expect(find.text('Continue ton progrès'), findsNothing);

    expect(find.text('Réviser cette matière'), findsOneWidget);
    expect(find.text('On commence par Droit administratif.'), findsOneWidget);
    expect(find.text('Commencer'), findsOneWidget);
    expect(find.text('12 min · priorités du moment'), findsNothing);

    expect(find.text('Droit constitutionnel'), findsOneWidget);
    expect(find.text('4 solides · 2 à renforcer'), findsOneWidget);
    expect(find.text('62%'), findsOneWidget);
    expect(find.text('Droit administratif'), findsWidgets);
    expect(find.text('2 solides · 2 à renforcer'), findsOneWidget);
    expect(find.text('38%'), findsOneWidget);
    expect(find.text('Institutions européennes'), findsOneWidget);
    expect(find.text('1 source prête'), findsOneWidget);

    expect(find.text('Global 62%'), findsNothing);
    expect(find.text('Durée à préciser'), findsNothing);
    expect(find.text('À préciser'), findsNothing);
    expect(find.text('MVP'), findsNothing);
    expect(find.text('backend'), findsNothing);
    expect(find.text('legacy'), findsNothing);

    await tester.tap(find.byType(RevisionSubjectSwitcher));
    await tester.pumpAndSettle();
    expect(find.text('Choisir une matière'), findsOneWidget);
    expect(find.text('Économie'), findsOneWidget);

    await tester.tap(find.text('Droit').last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Commencer'));
    await tester.pumpAndSettle();
    expect(find.text('Détail course-administrative'), findsOneWidget);
  });

  testWidgets('opens course creation from + when a subject exists', (
    tester,
  ) async {
    final subjectsRepository = InMemorySubjectsRepository()
      ..subjects.add(
        const Subject(id: 'subject-law', name: 'Droit', priority: 4),
      );
    final coursesRepository = InMemoryCoursesRepository();
    final router = _router(
      subjectsRepository: subjectsRepository,
      coursesRepository: coursesRepository,
    );

    await tester.pumpWidget(
      _buildApp(
        router: router,
        subjectsRepository: subjectsRepository,
        coursesRepository: coursesRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aucun cours pour le moment'), findsOneWidget);
    expect(
      find.text(
        'Crée ton premier cours dans Droit, puis ajoute une source PDF.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Créer'));
    await tester.pumpAndSettle();

    expect(find.text('Créer un cours'), findsWidgets);
  });

  testWidgets('opens subject creation from + when no subject exists', (
    tester,
  ) async {
    final subjectsRepository = InMemorySubjectsRepository();
    final coursesRepository = InMemoryCoursesRepository();
    final router = _router(
      subjectsRepository: subjectsRepository,
      coursesRepository: coursesRepository,
    );

    await tester.pumpWidget(
      _buildApp(
        router: router,
        subjectsRepository: subjectsRepository,
        coursesRepository: coursesRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Crée ta première matière'), findsOneWidget);
    expect(
      find.text('Ajoute une matière pour commencer à organiser tes cours.'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Créer'));
    await tester.pumpAndSettle();

    expect(find.text('Créer une matière'), findsWidgets);
  });
}

Widget _buildApp({
  required GoRouter router,
  required InMemorySubjectsRepository subjectsRepository,
  required InMemoryCoursesRepository coursesRepository,
}) {
  return ProviderScope(
    overrides: [
      subjectsRepositoryProvider.overrideWithValue(subjectsRepository),
      coursesRepositoryProvider.overrideWithValue(coursesRepository),
    ],
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    ),
  );
}

GoRouter _router({
  required InMemorySubjectsRepository subjectsRepository,
  required InMemoryCoursesRepository coursesRepository,
}) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) =>
            const RevisionBackground(child: CoursesHomePage()),
      ),
      GoRoute(
        path: AppRoutes.coursePath,
        builder: (context, state) =>
            Text('Détail ${state.pathParameters['courseId']}'),
      ),
    ],
  );
}

CourseListItem _course({
  required String id,
  required String title,
  int sourceCount = 0,
  int readySourceCount = 0,
  CourseProgress? progress,
}) {
  return CourseListItem(
    id: id,
    subjectId: 'subject-law',
    title: title,
    sourceCount: sourceCount,
    readySourceCount: readySourceCount,
    progress: progress,
  );
}

CourseProgress _progress({
  required String courseId,
  required double estimatedGlobalMastery,
  required int knowledgeUnitCount,
  required int practicedKnowledgeUnitCount,
  required CourseProgressState state,
}) {
  return CourseProgress(
    courseId: courseId,
    subjectId: 'subject-law',
    coverage: knowledgeUnitCount == 0
        ? 0
        : practicedKnowledgeUnitCount / knowledgeUnitCount,
    estimatedGlobalMastery: estimatedGlobalMastery,
    knowledgeUnitCount: knowledgeUnitCount,
    practicedKnowledgeUnitCount: practicedKnowledgeUnitCount,
    readySourceCount: 1,
    processingSourceCount: 0,
    failedSourceCount: 0,
    state: state,
  );
}
