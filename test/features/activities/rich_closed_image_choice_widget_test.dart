import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/activities/domain/rich_closed_exercise.dart';
import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_image_choice_widget.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;

  setUp(() {
    exercise = RichClosedExercise.fromJson(
      richClosedV1DImageChoiceExerciseJson(),
    );
  });

  testWidgets('image_choice affiche les choix contrôlés et produit choiceId', (
    tester,
  ) async {
    final answers = <RichClosedImageChoiceAnswer?>[];
    final question = _question<RichClosedImageChoiceQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedImageChoiceWidget(
          question: question,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    expect(find.text('Image'), findsOneWidget);
    expect(find.text('Image A'), findsOneWidget);
    expect(find.text('Image B'), findsOneWidget);
    expect(find.text('Image C'), findsOneWidget);
    expect(find.text('Portrait historique A'), findsWidgets);
    expect(find.text('Asset de démonstration contrôlé'), findsWidgets);
    _expectNoPreSubmitLeaks();

    await tester.tap(
      find.byKey(const ValueKey('image-choice-image-choice-1-choice-image-a')),
    );
    await tester.pump();

    final answer = answers.last;
    expect(answer, isNotNull);
    expect(answer!.choiceId, 'choice-image-a');
    expect(answer.toJson(), {
      'questionId': 'image-choice-1',
      'questionKind': 'image_choice',
      'choiceId': 'choice-image-a',
    });
  });

  testWidgets('image_choice garde un fallback lisible sur petit écran', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(260, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final question = _question<RichClosedImageChoiceQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedImageChoiceWidget(
          question: question,
          onAnswerChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Image non disponible'), findsWidgets);
    expect(find.text('Charles de Gaulle'), findsNothing);
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

void _expectNoPreSubmitLeaks() {
  expect(find.text('Charles de Gaulle'), findsNothing);
  expect(find.text('correctChoiceId'), findsNothing);
  expect(find.text('semanticLabel'), findsNothing);
  expect(find.text('answerHint'), findsNothing);
  expect(find.text('imageUrl'), findsNothing);
  expect(find.text('storagePath'), findsNothing);
  expect(find.text('base64'), findsNothing);
  expect(find.text('explanation'), findsNothing);
  expect(find.text('feedback'), findsNothing);
  expect(find.text('score'), findsNothing);
  expect(find.text('renderPayload'), findsNothing);
}
