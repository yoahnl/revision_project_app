import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_correction_presenter.dart';

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

  test('construit un summary depuis les valeurs backend', () {
    final viewModel = presenter.present(exercise: exercise, result: result);

    expect(viewModel.summary.sessionId, 'rich-session-1');
    expect(viewModel.summary.status, 'completed');
    expect(viewModel.summary.correctAnswers, 5);
    expect(viewModel.summary.totalQuestions, 6);
    expect(viewModel.summary.score, 0.833);
    expect(viewModel.summary.scoreLabel, '0.833');
    expect(viewModel.summary.answerRatioLabel, '5 / 6');
  });

  test('mappe les six types de corrections en labels lisibles', () {
    final viewModel = presenter.present(exercise: exercise, result: result);

    expect(_item(viewModel, 'single-1').submittedAnswerLines, [
      'Responsabilité politique',
    ]);
    expect(_item(viewModel, 'single-1').correctAnswerLines, [
      'Responsabilité politique',
    ]);

    expect(_item(viewModel, 'multiple-1').submittedAnswerLines, [
      'Responsabilité du gouvernement',
      'Collaboration des pouvoirs',
    ]);
    expect(_item(viewModel, 'multiple-1').correctAnswerLines, [
      'Responsabilité du gouvernement',
      'Collaboration des pouvoirs',
    ]);

    expect(_item(viewModel, 'case-1').contextText, contains('confiance'));
    expect(_item(viewModel, 'case-1').submittedAnswerLines, [
      'Régime parlementaire',
    ]);
    expect(_item(viewModel, 'case-1').correctAnswerLines, [
      'Régime parlementaire',
    ]);

    expect(_item(viewModel, 'error-1').contextText, contains('présidentiel'));
    expect(_item(viewModel, 'error-1').submittedAnswerLines, [
      'Confusion avec l’État fédéral',
    ]);
    expect(_item(viewModel, 'error-1').correctAnswerLines, [
      'Confusion avec le parlementarisme',
    ]);

    expect(_item(viewModel, 'matching-1').submittedAnswerLines, [
      'Motion de censure → Responsabilité politique',
      'Dissolution → Fin anticipée d’une chambre',
      'Contrôle constitutionnel → Vérification d’une norme',
    ]);
    expect(_item(viewModel, 'matching-1').correctAnswerLines, [
      'Motion de censure → Responsabilité politique',
      'Dissolution → Fin anticipée d’une chambre',
      'Contrôle constitutionnel → Vérification d’une norme',
    ]);

    expect(_item(viewModel, 'ordering-1').submittedAnswerLines, [
      '1. Repérer les organes',
      '2. Analyser les moyens d’action',
      '3. Qualifier le régime',
    ]);
    expect(_item(viewModel, 'ordering-1').correctAnswerLines, [
      '1. Repérer les organes',
      '2. Analyser les moyens d’action',
      '3. Qualifier le régime',
    ]);
  });

  test('mappe timeline et date_slider depuis les corrections backend', () {
    final v1bExercise = RichClosedExercise.fromJson(
      richClosedV1BExerciseJson(),
    );
    final v1bResult = RichClosedExerciseResult.fromJson(
      richClosedV1BResultJson(),
    );
    final viewModel = presenter.present(
      exercise: v1bExercise,
      result: v1bResult,
    );

    expect(_item(viewModel, 'timeline-1').kindLabel, 'Chronologie');
    expect(_item(viewModel, 'timeline-1').submittedAnswerLines, [
      '1. Dépôt de la motion',
      '2. Débat politique',
      '3. Vote de la chambre',
    ]);
    expect(_item(viewModel, 'timeline-1').correctAnswerLines, [
      '1. Dépôt de la motion',
      '2. Débat politique',
      '3. Vote de la chambre',
    ]);

    expect(_item(viewModel, 'date-slider-1').kindLabel, 'Curseur temporel');
    expect(_item(viewModel, 'date-slider-1').submittedAnswerLines, [
      'Année choisie : 1960',
    ]);
    expect(_item(viewModel, 'date-slider-1').correctAnswerLines, [
      'Année correcte : 1958',
      'Plage acceptée : 1958 - 1958',
    ]);
    expect(_item(viewModel, 'date-slider-1').isCorrect, isFalse);
  });

  test(
    'mappe true_false_grid et cause_consequence depuis les corrections backend',
    () {
      final v1bFullExercise = RichClosedExercise.fromJson(
        richClosedV1BFullExerciseJson(),
      );
      final v1bFullResult = RichClosedExerciseResult.fromJson(
        richClosedV1BFullResultJson(),
      );
      final viewModel = presenter.present(
        exercise: v1bFullExercise,
        result: v1bFullResult,
      );

      expect(_item(viewModel, 'true-false-grid-1').kindLabel, 'Vrai / faux');
      expect(_item(viewModel, 'true-false-grid-1').submittedAnswerLines, [
        'Le gouvernement peut être responsable devant le Parlement. : Vrai',
        'La séparation des pouvoirs interdit toute collaboration. : Vrai',
        'La dissolution peut être un moyen réciproque. : Vrai',
      ]);
      expect(_item(viewModel, 'true-false-grid-1').correctAnswerLines, [
        'Le gouvernement peut être responsable devant le Parlement. : Vrai',
        'La séparation des pouvoirs interdit toute collaboration. : Faux',
        'La dissolution peut être un moyen réciproque. : Vrai',
      ]);
      expect(_item(viewModel, 'true-false-grid-1').isCorrect, isFalse);

      expect(
        _item(viewModel, 'cause-consequence-1').kindLabel,
        'Cause / conséquence',
      );
      expect(_item(viewModel, 'cause-consequence-1').submittedAnswerLines, [
        'Motion de censure adoptée → Démission du gouvernement',
        'Dissolution de l’Assemblée → Nouvelles élections législatives',
        'Question de confiance rejetée → Crise politique ou départ du gouvernement',
      ]);
      expect(_item(viewModel, 'cause-consequence-1').correctAnswerLines, [
        'Motion de censure adoptée → Démission du gouvernement',
        'Dissolution de l’Assemblée → Nouvelles élections législatives',
        'Question de confiance rejetée → Crise politique ou départ du gouvernement',
      ]);
    },
  );

  test('mappe institution_matrix depuis les corrections backend', () {
    final v1cExercise = RichClosedExercise.fromJson(
      richClosedV1CExerciseJson(),
    );
    final v1cResult = RichClosedExerciseResult.fromJson(
      richClosedV1CResultJson(),
    );
    final viewModel = presenter.present(
      exercise: v1cExercise,
      result: v1cResult,
    );

    expect(_item(viewModel, 'institution-matrix-1').kindLabel, 'Matrice');
    expect(_item(viewModel, 'institution-matrix-1').submittedAnswerLines, [
      'Président de la République / Mode de légitimité : Élection nationale',
      'Gouvernement / Responsabilité politique : Assemblée nationale',
      'Assemblée nationale / Moyen d’action : Motion de censure',
    ]);
    expect(_item(viewModel, 'institution-matrix-1').correctAnswerLines, [
      'Président de la République / Mode de légitimité : Élection nationale',
      'Gouvernement / Responsabilité politique : Assemblée nationale',
      'Assemblée nationale / Moyen d’action : Motion de censure',
    ]);
    expect(_item(viewModel, 'institution-matrix-1').isCorrect, isTrue);
  });

  test('conserve isCorrect et partialScore backend sans recalcul', () {
    final json = richClosedResultJson();
    final single =
        (json['items']! as List<Object?>).first! as Map<String, Object?>;
    single['isCorrect'] = false;
    single['partialScore'] = 0.42;

    final viewModel = presenter.present(
      exercise: exercise,
      result: RichClosedExerciseResult.fromJson(json),
    );
    final item = _item(viewModel, 'single-1');

    expect(item.submittedAnswerLines, item.correctAnswerLines);
    expect(item.isCorrect, isFalse);
    expect(item.statusLabel, 'Incorrect');
    expect(item.partialScore, 0.42);
    expect(item.partialScoreLabel, '0.42');
  });

  test('conserve isCorrect true même si les labels soumis diffèrent', () {
    final json = richClosedResultJson();
    final single =
        (json['items']! as List<Object?>).first! as Map<String, Object?>;
    final answer = single['submittedAnswer']! as Map<String, Object?>;
    answer['choiceId'] = 'choice-b';
    single['isCorrect'] = true;

    final viewModel = presenter.present(
      exercise: exercise,
      result: RichClosedExerciseResult.fromJson(json),
    );
    final item = _item(viewModel, 'single-1');

    expect(item.submittedAnswerLines, ['Séparation étanche']);
    expect(item.correctAnswerLines, ['Responsabilité politique']);
    expect(item.isCorrect, isTrue);
    expect(item.statusLabel, 'Correct');
  });

  test('conserve score/correctAnswers/totalQuestions backend atypiques', () {
    final json = richClosedResultJson()
      ..['score'] = 0.123
      ..['correctAnswers'] = 99
      ..['totalQuestions'] = 100;

    final viewModel = presenter.present(
      exercise: exercise,
      result: RichClosedExerciseResult.fromJson(json),
    );

    expect(viewModel.summary.score, 0.123);
    expect(viewModel.summary.scoreLabel, '0.123');
    expect(viewModel.summary.correctAnswers, 99);
    expect(viewModel.summary.totalQuestions, 100);
    expect(viewModel.summary.answerRatioLabel, '99 / 100');
  });

  test('rejette une question inconnue', () {
    final json = richClosedResultJson();
    final item =
        (json['items']! as List<Object?>).first! as Map<String, Object?>;
    item['questionId'] = 'unknown-question';
    final answer = item['submittedAnswer']! as Map<String, Object?>;
    answer['questionId'] = 'unknown-question';

    expect(
      () => presenter.present(
        exercise: exercise,
        result: RichClosedExerciseResult.fromJson(json),
      ),
      throwsA(isA<RichClosedCorrectionPresentationException>()),
    );
  });

  test('rejette un choice soumis inconnu', () {
    final json = richClosedResultJson();
    final item =
        (json['items']! as List<Object?>).first! as Map<String, Object?>;
    final answer = item['submittedAnswer']! as Map<String, Object?>;
    answer['choiceId'] = 'unknown-choice';

    expect(
      () => presenter.present(
        exercise: exercise,
        result: RichClosedExerciseResult.fromJson(json),
      ),
      throwsA(isA<RichClosedCorrectionPresentationException>()),
    );
  });

  test('rejette une paire matching inconnue', () {
    final json = richClosedResultJson();
    final item = (json['items']! as List<Object?>)[2]! as Map<String, Object?>;
    final answer = item['submittedAnswer']! as Map<String, Object?>;
    final pairs = answer['pairs']! as List<Object?>;
    (pairs.first! as Map<String, Object?>)['rightId'] = 'unknown-right';

    expect(
      () => presenter.present(
        exercise: exercise,
        result: RichClosedExerciseResult.fromJson(json),
      ),
      throwsA(isA<RichClosedCorrectionPresentationException>()),
    );
  });

  test('rejette un item ordering inconnu', () {
    final json = richClosedResultJson();
    final item = (json['items']! as List<Object?>)[3]! as Map<String, Object?>;
    final answer = item['submittedAnswer']! as Map<String, Object?>;
    answer['orderedIds'] = ['item-1', 'unknown-item', 'item-3'];

    expect(
      () => presenter.present(
        exercise: exercise,
        result: RichClosedExerciseResult.fromJson(json),
      ),
      throwsA(isA<RichClosedCorrectionPresentationException>()),
    );
  });

  test('rejette une correction incohérente avec questionKind', () {
    final badResult = RichClosedExerciseResult(
      sessionId: result.sessionId,
      type: result.type,
      status: result.status,
      correctAnswers: result.correctAnswers,
      totalQuestions: result.totalQuestions,
      score: result.score,
      items: [
        RichClosedCorrectionItem(
          questionId: 'single-1',
          questionKind: RichClosedQuestionKind.singleChoice,
          prompt: 'Quel critère caractérise un régime parlementaire ?',
          submittedAnswer: const RichClosedSingleChoiceAnswer(
            questionId: 'single-1',
            choiceId: 'choice-a',
          ),
          isCorrect: true,
          partialScore: 1,
          explanation: 'Correction incohérente.',
          sourceChunkIds: const ['chunk-1'],
          correction: const RichClosedCorrectOrderCorrection(
            correctOrder: ['item-1'],
          ),
        ),
      ],
    );

    expect(
      () => presenter.present(exercise: exercise, result: badResult),
      throwsA(isA<RichClosedCorrectionPresentationException>()),
    );
  });
}

RichClosedCorrectionItemViewModel _item(
  RichClosedCorrectionViewModel viewModel,
  String questionId,
) {
  return viewModel.items.singleWhere((item) => item.questionId == questionId);
}
