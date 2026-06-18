import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/courses_repository.dart';
import 'package:revision_app/features/courses/presentation/course_revision_sheet_page.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';

import '../../fakes/in_memory_courses_repository.dart';

void main() {
  testWidgets('course revision sheet page displays an existing sheet', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..revisionSheetsByCourse['course-1'] = revisionSheet();

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Fiche de cours'), findsWidgets);
    expect(find.text('Introduction'), findsOneWidget);
    expect(find.text('Institutions'), findsOneWidget);
    expect(find.text('Le Parlement contrôle le Gouvernement.'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.text('870'), findsNothing);
    expect(find.text('7 jours'), findsNothing);
  });

  testWidgets('course revision sheet page can generate a missing sheet', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..generatedRevisionSheetsByCourse['course-1'] = revisionSheet();

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Fiche non générée'), findsOneWidget);

    await tester.tap(find.text('Générer la fiche'));
    await tester.pumpAndSettle();

    expect(repository.generateRevisionSheetCount, 1);
    expect(find.text('Institutions'), findsOneWidget);
  });

  testWidgets('course revision sheet page shows no-ready-source errors', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..revisionSheetErrorsByCourse['course-1'] =
          const CourseRevisionSheetNotReadyException(
            'Course has no ready source',
          );

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Aucune source prête'), findsOneWidget);
    expect(find.textContaining('traitée avec succès'), findsOneWidget);
  });

  testWidgets('course revision sheet page shows course not found errors', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..revisionSheetErrorsByCourse['course-1'] = const CourseNotFoundException(
        'Course not found',
      );

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Cours introuvable'), findsOneWidget);
    expect(find.text('Fiche non générée'), findsNothing);
  });
}

Widget testApp(InMemoryCoursesRepository repository) {
  return ProviderScope(
    overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(
      home: Scaffold(body: CourseRevisionSheetPage(courseId: 'course-1')),
    ),
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
