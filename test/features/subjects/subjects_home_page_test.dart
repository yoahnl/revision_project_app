import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/app/di/providers.dart';
import 'package:revision_app/features/subjects/domain/subject.dart';
import 'package:revision_app/presentation/pages/subjects/subjects_home_page.dart';

import '../../fakes/in_memory_subjects_repository.dart';

void main() {
  testWidgets('deletes a subject after confirmation', (tester) async {
    final repository = InMemorySubjectsRepository()
      ..subjects.add(
        const Subject(
          id: 'subject-1',
          name: 'Droit constitutionnel',
          priority: 4,
        ),
      );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [subjectsRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: SubjectsHomePage()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Droit constitutionnel'), findsOneWidget);

    await tester.tap(find.byTooltip('Supprimer la matiere'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();

    expect(repository.subjects, isEmpty);
    expect(find.text('Droit constitutionnel'), findsNothing);
  });
}
