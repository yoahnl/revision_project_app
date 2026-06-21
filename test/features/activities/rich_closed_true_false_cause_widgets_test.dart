import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/activities/domain/rich_closed_exercise.dart';
import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_cause_consequence_widget.dart';
import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_true_false_grid_widget.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;

  setUp(() {
    exercise = RichClosedExercise.fromJson(richClosedV1BFullExerciseJson());
  });

  testWidgets('true_false_grid affiche les lignes et produit values', (
    tester,
  ) async {
    final answers = <RichClosedTrueFalseGridAnswer?>[];
    final question = _question<RichClosedTrueFalseGridQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedTrueFalseGridWidget(
          question: question,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    expect(
      find.text('Le gouvernement peut être responsable devant le Parlement.'),
      findsOneWidget,
    );
    expect(
      find.text('La séparation des pouvoirs interdit toute collaboration.'),
      findsOneWidget,
    );
    _expectNoPreSubmitLeaks();

    await tester.tap(find.byKey(const ValueKey('true-false-row-1-true')));
    await tester.pump();
    expect(answers.last, isNull);

    await tester.tap(find.byKey(const ValueKey('true-false-row-2-false')));
    await tester.tap(find.byKey(const ValueKey('true-false-row-3-true')));
    await tester.pump();

    final answer = answers.last;
    expect(answer, isNotNull);
    expect(answer!.values.map((value) => '${value.rowId}:${value.value}'), [
      'row-1:true',
      'row-2:false',
      'row-3:true',
    ]);
  });

  testWidgets('cause_consequence affiche les causes et produit pairs', (
    tester,
  ) async {
    final answers = <RichClosedCauseConsequenceAnswer?>[];
    final question = _question<RichClosedCauseConsequenceQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedCauseConsequenceWidget(
          question: question,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    expect(find.text('Motion de censure adoptée'), findsOneWidget);
    expect(find.text('Dissolution de l’Assemblée'), findsOneWidget);
    expect(find.text('Choisir une conséquence'), findsNWidgets(3));
    _expectNoPreSubmitLeaks();

    _selectDropdown(
      tester,
      key: 'cause-consequence-cause-consequence-1-cause-1',
      value: 'consequence-1',
    );
    await tester.pump();
    expect(answers.last, isNull);

    _selectDropdown(
      tester,
      key: 'cause-consequence-cause-consequence-1-cause-2',
      value: 'consequence-2',
    );
    _selectDropdown(
      tester,
      key: 'cause-consequence-cause-consequence-1-cause-3',
      value: 'consequence-3',
    );
    await tester.pump();

    final answer = answers.last;
    expect(answer, isNotNull);
    expect(
      answer!.pairs.map((pair) => '${pair.causeId}:${pair.consequenceId}'),
      [
        'cause-1:consequence-1',
        'cause-2:consequence-2',
        'cause-3:consequence-3',
      ],
    );
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
  expect(find.text('correctPairs'), findsNothing);
  expect(find.text('explanation'), findsNothing);
  expect(find.text('feedback'), findsNothing);
  expect(find.text('score'), findsNothing);
  expect(find.text('modelAnswer'), findsNothing);
}
