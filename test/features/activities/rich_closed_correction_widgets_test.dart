import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/activities/domain/rich_closed_exercise.dart';
import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_correction_card.dart';
import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_correction_list.dart';
import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_correction_presenter.dart';
import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_result_summary_card.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;
  late RichClosedExerciseResult result;
  late RichClosedCorrectionPresenter presenter;

  setUp(() {
    exercise = RichClosedExercise.fromJson(richClosedExerciseJson());
    result = RichClosedExerciseResult.fromJson(richClosedResultJson());
    presenter = const RichClosedCorrectionPresenter();
  });

  testWidgets('summary affiche les valeurs backend sans recalcul', (
    tester,
  ) async {
    final json = richClosedResultJson()
      ..['score'] = 0.123
      ..['correctAnswers'] = 99
      ..['totalQuestions'] = 100;
    final viewModel = presenter
        .present(
          exercise: exercise,
          result: RichClosedExerciseResult.fromJson(json),
        )
        .summary;

    await tester.pumpWidget(
      _TestHost(child: RichClosedResultSummaryCard(summary: viewModel)),
    );

    expect(find.text('Résultat'), findsOneWidget);
    expect(find.text('completed'), findsOneWidget);
    expect(find.text('99 / 100'), findsOneWidget);
    expect(find.text('0.123'), findsOneWidget);
  });

  testWidgets('correction list affiche une correction par item', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestHost(
        child: RichClosedCorrectionList(exercise: exercise, result: result),
      ),
    );

    expect(find.text('Réponse envoyée'), findsNWidgets(6));
    expect(find.text('Réponse attendue'), findsNWidgets(6));
    expect(find.text('Correct'), findsNWidgets(5));
    expect(find.text('Incorrect'), findsOneWidget);
    expect(
      find.text('La responsabilité politique est centrale.'),
      findsOneWidget,
    );
    expect(find.text('Source chunk-1'), findsWidgets);
    expect(find.textContaining('{'), findsNothing);
  });

  testWidgets('affiche les labels lisibles pour les six types', (tester) async {
    await tester.pumpWidget(
      _TestHost(
        child: RichClosedCorrectionList(exercise: exercise, result: result),
      ),
    );

    expect(find.text('Responsabilité politique'), findsWidgets);
    expect(find.text('Responsabilité du gouvernement'), findsWidgets);
    expect(find.text('Régime parlementaire'), findsWidgets);
    expect(find.text('Confusion avec l’État fédéral'), findsWidgets);
    expect(
      find.text('Motion de censure → Responsabilité politique'),
      findsWidgets,
    );
    expect(find.text('1. Repérer les organes'), findsWidgets);
  });

  testWidgets('affiche incorrect quand le backend dit false même si égal', (
    tester,
  ) async {
    final json = richClosedResultJson();
    final single =
        (json['items']! as List<Object?>).first! as Map<String, Object?>;
    single['isCorrect'] = false;

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedCorrectionList(
          exercise: exercise,
          result: RichClosedExerciseResult.fromJson(json),
        ),
      ),
    );

    final singleCard = find.ancestor(
      of: find.text('Quel critère caractérise un régime parlementaire ?'),
      matching: find.byType(RichClosedCorrectionCard),
    );

    expect(
      find.descendant(of: singleCard, matching: find.text('Incorrect')),
      findsOneWidget,
    );
  });

  testWidgets('affiche correct quand le backend dit true même si différent', (
    tester,
  ) async {
    final json = richClosedResultJson();
    final single =
        (json['items']! as List<Object?>).first! as Map<String, Object?>;
    final answer = single['submittedAnswer']! as Map<String, Object?>;
    answer['choiceId'] = 'choice-b';
    single['isCorrect'] = true;

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedCorrectionList(
          exercise: exercise,
          result: RichClosedExerciseResult.fromJson(json),
        ),
      ),
    );

    final singleCard = find.ancestor(
      of: find.text('Quel critère caractérise un régime parlementaire ?'),
      matching: find.byType(RichClosedCorrectionCard),
    );

    expect(
      find.descendant(of: singleCard, matching: find.text('Correct')),
      findsOneWidget,
    );
    expect(find.text('Séparation étanche'), findsOneWidget);
    expect(find.text('Responsabilité politique'), findsWidgets);
  });

  testWidgets('affiche une erreur contrôlée si le presenter échoue', (
    tester,
  ) async {
    final json = richClosedResultJson();
    final single =
        (json['items']! as List<Object?>).first! as Map<String, Object?>;
    final answer = single['submittedAnswer']! as Map<String, Object?>;
    answer['choiceId'] = 'unknown-choice';

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedCorrectionList(
          exercise: exercise,
          result: RichClosedExerciseResult.fromJson(json),
        ),
      ),
    );

    expect(find.textContaining('Correction indisponible'), findsOneWidget);
    expect(find.textContaining('unknown-choice'), findsOneWidget);
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
