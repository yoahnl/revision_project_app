import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_institution_matrix_widget.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;

  setUp(() {
    exercise = RichClosedExercise.fromJson(richClosedV1CExerciseJson());
  });

  testWidgets('institution_matrix affiche lignes, colonnes et produit values', (
    tester,
  ) async {
    final answers = <RichClosedInstitutionMatrixAnswer?>[];
    final question = _question<RichClosedInstitutionMatrixQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedInstitutionMatrixWidget(
          question: question,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    expect(find.text('Président de la République'), findsOneWidget);
    expect(find.text('Gouvernement'), findsOneWidget);
    expect(find.text('Assemblée nationale'), findsOneWidget);
    expect(find.text('Mode de légitimité'), findsOneWidget);
    expect(find.text('Responsabilité politique'), findsOneWidget);
    expect(find.text('Moyen d’action'), findsOneWidget);
    expect(find.text('Choisir une option'), findsNWidgets(3));
    _expectNoPreSubmitLeaks();

    _selectDropdown(
      tester,
      key: 'institution-matrix-institution-matrix-1-cell-president-legitimacy',
      value: 'option-legitimacy-election',
    );
    await tester.pump();
    expect(answers.last, isNull);

    _selectDropdown(
      tester,
      key:
          'institution-matrix-institution-matrix-1-cell-government-responsibility',
      value: 'option-responsibility-assembly',
    );
    _selectDropdown(
      tester,
      key: 'institution-matrix-institution-matrix-1-cell-assembly-action',
      value: 'option-action-censure',
    );
    await tester.pump();

    final answer = answers.last;
    expect(answer, isNotNull);
    expect(answer!.values.map((value) => '${value.cellId}:${value.optionId}'), [
      'cell-president-legitimacy:option-legitimacy-election',
      'cell-government-responsibility:option-responsibility-assembly',
      'cell-assembly-action:option-action-censure',
    ]);
  });
}

class _TestHost extends StatelessWidget {
  const _TestHost({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

T _question<T extends RichClosedQuestion>(RichClosedExercise exercise) {
  return exercise.questions.whereType<T>().single;
}

void _selectDropdown(
  WidgetTester tester, {
  required String key,
  required String value,
}) {
  final dropdown = tester.widget<DropdownButton<String>>(
    find.byKey(ValueKey(key)),
  );
  dropdown.onChanged!(value);
}

void _expectNoPreSubmitLeaks() {
  expect(find.text('correctValues'), findsNothing);
  expect(find.text('explanation'), findsNothing);
  expect(find.text('feedback'), findsNothing);
  expect(find.text('score'), findsNothing);
  expect(find.text('modelAnswer'), findsNothing);
}
