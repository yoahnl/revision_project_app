import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_case_qualification_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_error_detection_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_multiple_choice_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_single_choice_widget.dart';
import 'package:revision_app/presentation/widgets/revision_choice_tile.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;

  setUp(() {
    exercise = RichClosedExercise.fromJson(richClosedExerciseJson());
  });

  testWidgets('single choice rend le prompt, sélectionne et remplace', (
    tester,
  ) async {
    final answers = <RichClosedSingleChoiceAnswer>[];
    final question = _question<RichClosedSingleChoiceQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedSingleChoiceWidget(
          question: question,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    expect(
      find.text('Quel critère caractérise un régime parlementaire ?'),
      findsOneWidget,
    );
    expect(find.text('Responsabilité politique'), findsOneWidget);
    expect(find.text('Séparation étanche'), findsOneWidget);
    _expectNoPreSubmitLeaks();

    await tester.tap(find.text('Responsabilité politique'));
    await tester.pump();

    expect(answers.last.choiceId, 'choice-a');
    expect(_selectedChoiceTile('Responsabilité politique'), findsOneWidget);

    await tester.tap(find.text('Séparation étanche'));
    await tester.pump();

    expect(answers.last.choiceId, 'choice-b');
    expect(_selectedChoiceTile('Responsabilité politique'), findsNothing);
    expect(_selectedChoiceTile('Séparation étanche'), findsOneWidget);
  });

  testWidgets(
    'multiple choice respecte min/max et produit une réponse valide',
    (tester) async {
      final answers = <RichClosedMultipleChoiceAnswer?>[];
      final question = _question<RichClosedMultipleChoiceQuestion>(exercise);

      await tester.pumpWidget(
        _TestHost(
          child: RichClosedMultipleChoiceWidget(
            question: question,
            onAnswerChanged: answers.add,
          ),
        ),
      );

      expect(
        find.text('Quels indices orientent vers un régime parlementaire ?'),
        findsOneWidget,
      );
      expect(find.text('Choisis 2 réponses.'), findsOneWidget);
      expect(find.text('Responsabilité du gouvernement'), findsOneWidget);
      _expectNoPreSubmitLeaks();

      await tester.tap(find.text('Responsabilité du gouvernement'));
      await tester.pump();
      expect(answers.last, isNull);

      await tester.tap(find.text('Collaboration des pouvoirs'));
      await tester.pump();
      expect(answers.last, isA<RichClosedMultipleChoiceAnswer>());
      expect(answers.last!.choiceIds, ['choice-a', 'choice-b']);

      await tester.tap(find.text('Responsabilité du gouvernement'));
      await tester.pump();
      expect(answers.last, isNull);

      await tester.tap(find.text('Responsabilité du gouvernement'));
      await tester.pump();
      await tester.tap(find.text('Indépendance absolue'));
      await tester.pump();

      expect(answers.last!.choiceIds, ['choice-a', 'choice-b']);
      expect(find.textContaining('2 réponses au maximum'), findsOneWidget);
    },
  );

  testWidgets('case qualification rend le cas et produit une réponse', (
    tester,
  ) async {
    final answers = <RichClosedCaseQualificationAnswer>[];
    final question = _question<RichClosedCaseQualificationQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedCaseQualificationWidget(
          question: question,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    expect(
      find.text('Choisis la qualification la plus pertinente.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Un gouvernement doit conserver la confiance d’une chambre élue.',
      ),
      findsOneWidget,
    );
    expect(find.text('Régime parlementaire'), findsOneWidget);
    _expectNoPreSubmitLeaks();

    await tester.tap(find.text('Régime parlementaire'));
    await tester.pump();

    expect(answers.single.choiceId, 'choice-a');
    expect(_selectedChoiceTile('Régime parlementaire'), findsOneWidget);
  });

  testWidgets('error detection rend l’énoncé et produit une réponse', (
    tester,
  ) async {
    final answers = <RichClosedErrorDetectionAnswer>[];
    final question = _question<RichClosedErrorDetectionQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedErrorDetectionWidget(
          question: question,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    expect(find.text('Repère l’erreur dominante.'), findsOneWidget);
    expect(
      find.text(
        'Un régime présidentiel se définit par la responsabilité politique du gouvernement devant le Parlement.',
      ),
      findsOneWidget,
    );
    expect(find.text('Confusion avec le parlementarisme'), findsOneWidget);
    _expectNoPreSubmitLeaks();

    await tester.tap(find.text('Confusion avec le parlementarisme'));
    await tester.pump();

    expect(answers.single.errorId, 'error-a');
    expect(
      _selectedChoiceTile('Confusion avec le parlementarisme'),
      findsOneWidget,
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

Finder _selectedChoiceTile(String label) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is RevisionChoiceTile &&
        widget.label == label &&
        widget.selected,
  );
}

void _expectNoPreSubmitLeaks() {
  expect(find.text('La responsabilité politique est centrale.'), findsNothing);
  expect(
    find.text('Responsabilité et collaboration sont attendues.'),
    findsNothing,
  );
  expect(find.text('correctChoiceId'), findsNothing);
  expect(find.text('correctErrorId'), findsNothing);
  expect(find.text('score'), findsNothing);
  expect(find.text('modelAnswer'), findsNothing);
  expect(find.text('feedback'), findsNothing);
}
