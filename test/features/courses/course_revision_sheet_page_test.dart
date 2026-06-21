import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/courses/application/courses_providers.dart';
import 'package:Neralune/features/courses/domain/courses_repository.dart';
import 'package:Neralune/features/courses/presentation/course_revision_sheet_page.dart';
import 'package:Neralune/features/documents/domain/revision_document.dart';

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
    expect(find.text('Introduction destinée aux étudiants'), findsOneWidget);
    expect(find.text('Institutions'), findsOneWidget);
    expect(find.text('Le Parlement contrôle le Gouvernement.'), findsOneWidget);
    expect(find.text('Complète'), findsNothing);
    expect(find.text('Examen'), findsNothing);
    expect(find.textContaining('réel'), findsNothing);
    expect(find.textContaining('étudiant.es'), findsNothing);
    expect(find.textContaining('Cours mais à la disposition'), findsNothing);
    expect(find.text('Sources >'), findsOneWidget);
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
    expect(find.textContaining('données réelles'), findsNothing);
    expect(find.textContaining('fictive'), findsNothing);
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

  testWidgets(
    'course revision sheet sources page shows long sources separately',
    (tester) async {
      final repository = InMemoryCoursesRepository()
        ..revisionSheetsByCourse['course-1'] = revisionSheet();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
          child: const MaterialApp(
            home: Scaffold(
              body: CourseRevisionSheetSourcesPage(courseId: 'course-1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sources de la fiche'), findsOneWidget);
      expect(find.text('Institutions'), findsOneWidget);
      expect(
        find.textContaining('Cours mais à la disposition'),
        findsOneWidget,
      );
      expect(find.textContaining('étudiant.es'), findsNothing);
      expect(find.textContaining('étudiants'), findsOneWidget);
    },
  );
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
    introduction: 'Introduction destinée aux étudiant.es',
    sections: [
      RevisionSheetSection(
        id: 'section-1',
        displayOrder: 0,
        title: 'Institutions',
        content: 'Le Parlement contrôle le Gouvernement.',
        sources: [
          DocumentArtifactSource(
            chunkId: 'chunk-1',
            index: 0,
            text:
                'Cours mais à la disposition des étudiant.es de l’UFR 11. Table des matières très longue.',
            pageNumber: 1,
          ),
        ],
      ),
    ],
    keyPoints: ['Point clé'],
    commonMistakes: ['Erreur fréquente'],
    mustKnow: ['À savoir'],
    practiceSuggestions: ['S’entraîner'],
    errorCode: null,
  );
}
