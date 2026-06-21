import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/activities/domain/rich_closed_exercise.dart';
import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_matching_widget.dart';
import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_ordering_widget.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;

  setUp(() {
    exercise = RichClosedExercise.fromJson(richClosedExerciseJson());
  });

  testWidgets('matching rend les items et produit une réponse complète', (
    tester,
  ) async {
    final answers = <RichClosedMatchingAnswer?>[];
    final question = _question<RichClosedMatchingQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedMatchingWidget(
          question: question,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    expect(
      find.text('Associe chaque mécanisme à sa fonction.'),
      findsOneWidget,
    );
    expect(find.text('Motion de censure'), findsOneWidget);
    expect(find.text('Dissolution'), findsOneWidget);
    expect(find.text('Contrôle constitutionnel'), findsOneWidget);
    _expectNoPreSubmitLeaks();

    await _selectMatchingRight(
      tester,
      leftId: 'left-1',
      label: 'Responsabilité politique',
    );
    expect(answers.last, isNull);

    await _selectMatchingRight(
      tester,
      leftId: 'left-2',
      label: 'Fin anticipée d’une chambre',
    );
    expect(answers.last, isNull);

    await _selectMatchingRight(
      tester,
      leftId: 'left-3',
      label: 'Vérification d’une norme',
    );

    expect(answers.last, isA<RichClosedMatchingAnswer>());
    expect(answers.last!.pairs.map((pair) => pair.leftId), [
      'left-1',
      'left-2',
      'left-3',
    ]);
    expect(answers.last!.pairs.map((pair) => pair.rightId), [
      'right-1',
      'right-2',
      'right-3',
    ]);
  });

  testWidgets('matching met à jour une association et garde unicité', (
    tester,
  ) async {
    final answers = <RichClosedMatchingAnswer?>[];
    final question = _question<RichClosedMatchingQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedMatchingWidget(
          question: question,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    await _selectMatchingRight(
      tester,
      leftId: 'left-1',
      label: 'Responsabilité politique',
    );
    await _selectMatchingRight(
      tester,
      leftId: 'left-2',
      label: 'Fin anticipée d’une chambre',
    );
    await _selectMatchingRight(
      tester,
      leftId: 'left-3',
      label: 'Vérification d’une norme',
    );
    expect(answers.last, isA<RichClosedMatchingAnswer>());

    await _selectMatchingRight(
      tester,
      leftId: 'left-2',
      label: 'Responsabilité politique',
    );

    expect(answers.last, isNull);
  });

  testWidgets('matching disabled empêche les changements', (tester) async {
    final answers = <RichClosedMatchingAnswer?>[];
    final question = _question<RichClosedMatchingQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedMatchingWidget(
          question: question,
          enabled: false,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    final dropdown = tester.widget<DropdownButton<String>>(
      find.byKey(const ValueKey('matching-matching-1-left-1')),
    );

    expect(dropdown.onChanged, isNull);
    expect(answers, isEmpty);
  });

  testWidgets('ordering rend et déplace les items avec boutons accessibles', (
    tester,
  ) async {
    final answers = <RichClosedOrderingAnswer>[];
    final question = _question<RichClosedOrderingQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedOrderingWidget(
          question: question,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    expect(find.text('Ordonne les étapes du raisonnement.'), findsOneWidget);
    expect(find.text('1.'), findsOneWidget);
    expect(find.text('2.'), findsOneWidget);
    expect(find.text('3.'), findsOneWidget);
    expect(find.text('Repérer les organes'), findsOneWidget);
    expect(find.byTooltip('Monter Repérer les organes'), findsOneWidget);
    expect(find.byTooltip('Descendre Repérer les organes'), findsOneWidget);
    _expectNoPreSubmitLeaks();

    final firstUp = tester.widget<IconButton>(
      find.byKey(const ValueKey('ordering-up-item-1')),
    );
    final lastDown = tester.widget<IconButton>(
      find.byKey(const ValueKey('ordering-down-item-3')),
    );
    expect(firstUp.onPressed, isNull);
    expect(lastDown.onPressed, isNull);

    await tester.tap(find.byKey(const ValueKey('ordering-down-item-1')));
    await tester.pump();

    expect(answers.last.orderedIds, ['item-2', 'item-1', 'item-3']);

    await tester.tap(find.byKey(const ValueKey('ordering-up-item-1')));
    await tester.pump();

    expect(answers.last.orderedIds, ['item-1', 'item-2', 'item-3']);
  });

  testWidgets('ordering disabled empêche les changements', (tester) async {
    final answers = <RichClosedOrderingAnswer>[];
    final question = _question<RichClosedOrderingQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedOrderingWidget(
          question: question,
          enabled: false,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    final downButton = tester.widget<IconButton>(
      find.byKey(const ValueKey('ordering-down-item-1')),
    );

    expect(downButton.onPressed, isNull);
    expect(answers, isEmpty);
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

Future<void> _selectMatchingRight(
  WidgetTester tester, {
  required String leftId,
  required String label,
}) async {
  await tester.tap(find.byKey(ValueKey('matching-matching-1-$leftId')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void _expectNoPreSubmitLeaks() {
  expect(find.text('Chaque mécanisme renvoie à sa fonction.'), findsNothing);
  expect(find.text('La qualification vient après l’analyse.'), findsNothing);
  expect(find.text('correctPairs'), findsNothing);
  expect(find.text('correctOrder'), findsNothing);
  expect(find.text('explanation'), findsNothing);
  expect(find.text('feedback'), findsNothing);
  expect(find.text('score'), findsNothing);
  expect(find.text('modelAnswer'), findsNothing);
}
