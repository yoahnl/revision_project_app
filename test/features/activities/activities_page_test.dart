import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/activities/application/activity_controller.dart';
import 'package:Neralune/presentation/pages/activities/activities_page.dart';
import 'package:Neralune/presentation/widgets/revision_button.dart';

import '../../fakes/in_memory_activity_api.dart';

void main() {
  testWidgets('starts open question directly with subject and knowledge unit', (
    tester,
  ) async {
    final api = InMemoryActivityApi();

    await tester.pumpWidget(
      _ActivitiesHarness(
        api: api,
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
      ),
    );
    await tester.pumpAndSettle();

    expect(api.startedOpenQuestionSubjectId, 'subject-1');
    expect(api.startedOpenQuestionKnowledgeUnitId, 'unit-1');
    expect(api.startedOpenQuestionCount, 1);
    expect(api.startedDiagnosticQuizCount, 0);
    expect(find.text('Question ouverte test'), findsOneWidget);
    expect(find.text('Question test'), findsNothing);
  });

  testWidgets('keeps diagnostic quiz as default with subject only', (
    tester,
  ) async {
    final api = InMemoryActivityApi();

    await tester.pumpWidget(
      _ActivitiesHarness(api: api, subjectId: 'subject-1'),
    );
    await tester.pumpAndSettle();

    expect(api.startedSubjectId, 'subject-1');
    expect(api.startedDiagnosticQuizCount, 1);
    expect(api.startedOpenQuestionCount, 0);
    expect(find.text('Question test'), findsOneWidget);

    await tester.tap(find.widgetWithText(RevisionButton, 'Question ouverte'));
    await tester.pumpAndSettle();

    expect(api.startedOpenQuestionCount, 0);
  });

  testWidgets('can switch from direct open question to diagnostic quiz', (
    tester,
  ) async {
    final api = InMemoryActivityApi();

    await tester.pumpWidget(
      _ActivitiesHarness(
        api: api,
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(RevisionButton, 'QCM'));
    await tester.pumpAndSettle();

    expect(api.startedSubjectId, 'subject-1');
    expect(api.startedKnowledgeUnitId, 'unit-1');
    expect(api.startedDiagnosticQuizCount, 1);
    expect(find.text('Question test'), findsOneWidget);
  });

  testWidgets('can switch back to open question when a knowledge unit exists', (
    tester,
  ) async {
    final api = InMemoryActivityApi();

    await tester.pumpWidget(
      _ActivitiesHarness(
        api: api,
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(RevisionButton, 'QCM'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(RevisionButton, 'Question ouverte'));
    await tester.pumpAndSettle();

    expect(api.startedOpenQuestionSubjectId, 'subject-1');
    expect(api.startedOpenQuestionKnowledgeUnitId, 'unit-1');
    expect(api.startedOpenQuestionCount, 2);
    expect(find.text('Question ouverte test'), findsOneWidget);
  });

  testWidgets('reloads when activity params change', (tester) async {
    final api = InMemoryActivityApi();

    await tester.pumpWidget(
      _ActivitiesHarness(api: api, subjectId: 'subject-1'),
    );
    await tester.pumpAndSettle();

    expect(api.startedDiagnosticQuizCount, 1);
    expect(api.startedOpenQuestionCount, 0);
    expect(find.text('Question test'), findsOneWidget);

    await tester.pumpWidget(
      _ActivitiesHarness(
        api: api,
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
      ),
    );
    await tester.pumpAndSettle();

    expect(api.startedOpenQuestionKnowledgeUnitId, 'unit-1');
    expect(api.startedOpenQuestionCount, 1);
    expect(find.text('Question ouverte test'), findsOneWidget);

    await tester.pumpWidget(
      _ActivitiesHarness(
        api: api,
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-2',
      ),
    );
    await tester.pumpAndSettle();

    expect(api.startedOpenQuestionKnowledgeUnitId, 'unit-2');
    expect(api.startedOpenQuestionCount, 2);

    await tester.pumpWidget(
      _ActivitiesHarness(api: api, subjectId: 'subject-1'),
    );
    await tester.pumpAndSettle();

    expect(api.startedDiagnosticQuizCount, 2);
    expect(find.text('Question test'), findsOneWidget);
  });

  testWidgets('does not load an activity without subject', (tester) async {
    final api = InMemoryActivityApi();

    await tester.pumpWidget(_ActivitiesHarness(api: api));
    await tester.pumpAndSettle();

    expect(api.startedDiagnosticQuizCount, 0);
    expect(api.startedOpenQuestionCount, 0);
    expect(find.text('Aucune activite selectionnee'), findsOneWidget);
  });
}

class _ActivitiesHarness extends StatelessWidget {
  const _ActivitiesHarness({
    required this.api,
    this.subjectId,
    this.knowledgeUnitId,
  });

  final InMemoryActivityApi api;
  final String? subjectId;
  final String? knowledgeUnitId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ActivitiesPage(
        controller: ActivityController(api),
        subjectId: subjectId,
        knowledgeUnitId: knowledgeUnitId,
      ),
    );
  }
}
