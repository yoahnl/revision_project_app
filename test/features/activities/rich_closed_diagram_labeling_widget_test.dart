import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_diagram_labeling_widget.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;

  setUp(() {
    exercise = RichClosedExercise.fromJson(richClosedV1CFullExerciseJson());
  });

  testWidgets('diagram_labeling affiche le schema et produit values', (
    tester,
  ) async {
    final answers = <RichClosedDiagramLabelingAnswer?>[];
    final question = _question<RichClosedDiagramLabelingQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedDiagramLabelingWidget(
          question: question,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    expect(find.text('Rapports institutionnels'), findsOneWidget);
    expect(find.text('Président de la République'), findsOneWidget);
    expect(find.text('Gouvernement'), findsWidgets);
    expect(find.text('Assemblée nationale'), findsOneWidget);
    expect(
      find.text('Président de la République -> Gouvernement'),
      findsOneWidget,
    );
    expect(
      find.text('Quel organe conduit la politique nationale ?'),
      findsOneWidget,
    );
    expect(find.text('Choisir une option'), findsNWidgets(3));
    _expectNoPreSubmitLeaks();

    _selectDropdown(
      tester,
      key: 'diagram-labeling-diagram-labeling-1-slot-government-role',
      value: 'option-government',
    );
    await tester.pump();
    expect(answers.last, isNull);

    _selectDropdown(
      tester,
      key: 'diagram-labeling-diagram-labeling-1-slot-censure',
      value: 'option-motion-censure',
    );
    _selectDropdown(
      tester,
      key: 'diagram-labeling-diagram-labeling-1-slot-nomination',
      value: 'option-nomination',
    );
    await tester.pump();

    final answer = answers.last;
    expect(answer, isNotNull);
    expect(answer!.values.map((value) => '${value.slotId}:${value.optionId}'), [
      'slot-government-role:option-government',
      'slot-censure:option-motion-censure',
      'slot-nomination:option-nomination',
    ]);
  });

  testWidgets('diagram_labeling borne les longs libellés de menu', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const longLabel =
        'Nomination institutionnelle décrite avec un intitulé très long '
        'pour vérifier le comportement du menu avant la démo';
    final question = _withLongFirstOption(
      _question<RichClosedDiagramLabelingQuestion>(exercise),
      longLabel,
    );

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedDiagramLabelingWidget(
          question: question,
          onAnswerChanged: (_) {},
        ),
      ),
    );

    const dropdownKey = ValueKey(
      'diagram-labeling-diagram-labeling-1-slot-government-role',
    );
    await tester.ensureVisible(find.byKey(dropdownKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(dropdownKey));
    await tester.pumpAndSettle();

    expect(find.byTooltip(longLabel), findsOneWidget);
    expect(find.text('correctValues'), findsNothing);
    expect(tester.takeException(), isNull);
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

RichClosedDiagramLabelingQuestion _withLongFirstOption(
  RichClosedDiagramLabelingQuestion question,
  String longLabel,
) {
  final firstSlot = question.slots.first;

  return RichClosedDiagramLabelingQuestion(
    base: RichClosedQuestionBase(
      id: question.id,
      prompt: question.prompt,
      difficulty: question.difficulty,
      cognitiveSkill: question.cognitiveSkill,
      sourceChunkIds: question.sourceChunkIds,
    ),
    instruction: question.instruction,
    diagram: question.diagram,
    slots: [
      RichClosedDiagramLabelingSlot(
        id: firstSlot.id,
        anchorType: firstSlot.anchorType,
        anchorId: firstSlot.anchorId,
        prompt: firstSlot.prompt,
        options: [
          RichClosedChoice(id: firstSlot.options.first.id, label: longLabel),
          ...firstSlot.options.skip(1),
        ],
      ),
      ...question.slots.skip(1),
    ],
  );
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
  expect(find.text('svg'), findsNothing);
  expect(find.text('mermaid'), findsNothing);
  expect(find.text('renderPayload'), findsNothing);
}
