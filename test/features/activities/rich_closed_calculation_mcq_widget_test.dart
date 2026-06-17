import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_calculation_mcq_widget.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;

  setUp(() {
    exercise = RichClosedExercise.fromJson(
      richClosedV1CCalculationExerciseJson(),
    );
  });

  testWidgets('calculation_mcq affiche les donnees et produit choiceId', (
    tester,
  ) async {
    final answers = <RichClosedCalculationMcqAnswer?>[];
    final question = _question<RichClosedCalculationMcqQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedCalculationMcqWidget(
          question: question,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    expect(find.text('Calcul'), findsOneWidget);
    expect(find.textContaining('577 suffrages exprimés'), findsOneWidget);
    expect(find.text('Suffrages exprimés : 577'), findsOneWidget);
    expect(find.text('288 voix'), findsOneWidget);
    expect(find.text('289 voix'), findsOneWidget);
    expect(find.text('290 voix'), findsOneWidget);
    expect(find.text('Valeur : 289'), findsOneWidget);
    _expectNoPreSubmitLeaks();

    await tester.tap(
      find.byKey(
        const ValueKey('calculation-mcq-calculation-mcq-majority-1-choice-289'),
      ),
    );
    await tester.pump();

    final answer = answers.last;
    expect(answer, isNotNull);
    expect(answer!.choiceId, 'choice-289');
    expect(answer.toJson(), {
      'questionId': 'calculation-mcq-majority-1',
      'questionKind': 'calculation_mcq',
      'choiceId': 'choice-289',
    });
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

void _expectNoPreSubmitLeaks() {
  expect(find.text('correctChoiceId'), findsNothing);
  expect(find.text('expectedValue'), findsNothing);
  expect(find.text('workedSteps'), findsNothing);
  expect(find.text('explanation'), findsNothing);
  expect(find.text('feedback'), findsNothing);
  expect(find.text('score'), findsNothing);
  expect(find.text('formula'), findsNothing);
  expect(find.text('renderPayload'), findsNothing);
}
