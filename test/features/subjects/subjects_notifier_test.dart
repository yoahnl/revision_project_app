import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/app/di/providers.dart';
import 'package:revision_app/features/subjects/application/subjects_notifier.dart';
import 'package:revision_app/features/subjects/domain/subject.dart';

import '../../fakes/in_memory_subjects_repository.dart';

void main() {
  test(
    'subjects notifier loads subjects through repository provider',
    () async {
      final repository = InMemorySubjectsRepository()
        ..subjects.add(
          const Subject(
            id: 'subject-1',
            name: 'Droit constitutionnel',
            priority: 4,
          ),
        );
      final container = ProviderContainer(
        overrides: [subjectsRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final subjects = await container.read(subjectsNotifierProvider.future);

      expect(subjects.single.name, 'Droit constitutionnel');
    },
  );

  test('subjects notifier deletes a subject and reloads the list', () async {
    final repository = InMemorySubjectsRepository()
      ..subjects.add(
        const Subject(
          id: 'subject-1',
          name: 'Droit constitutionnel',
          priority: 4,
        ),
      );
    final container = ProviderContainer(
      overrides: [subjectsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(subjectsNotifierProvider.future);
    await container
        .read(subjectsNotifierProvider.notifier)
        .deleteSubject('subject-1');
    final subjects = await container.read(subjectsNotifierProvider.future);

    expect(subjects, isEmpty);
  });
}
