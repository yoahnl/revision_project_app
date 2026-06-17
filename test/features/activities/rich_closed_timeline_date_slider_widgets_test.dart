import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_date_slider_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_timeline_widget.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;

  setUp(() {
    exercise = RichClosedExercise.fromJson(richClosedV1BExerciseJson());
  });

  testWidgets('timeline rend les événements et produit orderedEventIds', (
    tester,
  ) async {
    final answers = <RichClosedTimelineAnswer>[];
    final question = _question<RichClosedTimelineQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedTimelineWidget(
          question: question,
          onAnswerChanged: answers.add,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Dépôt de la motion'), findsOneWidget);
    expect(find.text('Débat politique'), findsOneWidget);
    expect(find.text('Vote de la chambre'), findsOneWidget);
    expect(answers.last.orderedEventIds, ['event-1', 'event-2', 'event-3']);
    _expectNoPreSubmitLeaks();

    await tester.tap(find.byKey(const ValueKey('timeline-down-event-1')));
    await tester.pump();

    expect(answers.last.orderedEventIds, ['event-2', 'event-1', 'event-3']);

    await tester.tap(find.byKey(const ValueKey('timeline-up-event-1')));
    await tester.pump();

    expect(answers.last.orderedEventIds, ['event-1', 'event-2', 'event-3']);
  });

  testWidgets('date slider affiche les bornes et produit year', (tester) async {
    final answers = <RichClosedDateSliderAnswer>[];
    final question = _question<RichClosedDateSliderQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedDateSliderWidget(
          question: question,
          onAnswerChanged: answers.add,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('1945'), findsOneWidget);
    expect(find.text('1970'), findsOneWidget);
    expect(find.text('Année sélectionnée : 1958'), findsOneWidget);
    expect(answers.last.year, 1958);
    _expectNoPreSubmitLeaks();

    final slider = tester.widget<Slider>(
      find.byKey(const ValueKey('date-slider-date-slider-1')),
    );
    slider.onChanged!(1960);
    await tester.pump();

    expect(find.text('Année sélectionnée : 1960'), findsOneWidget);
    expect(answers.last.year, 1960);
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
  expect(find.text('correctOrder'), findsNothing);
  expect(find.text('correctYear'), findsNothing);
  expect(find.text('explanation'), findsNothing);
  expect(find.text('feedback'), findsNothing);
  expect(find.text('score'), findsNothing);
  expect(find.text('modelAnswer'), findsNothing);
}
