# LOT V1-012 — Scoring/correction UI V1-A

## 1. Résultat

Le lot V1-012 ajoute une couche Flutter post-submit dédiée aux corrections rich closed V1-A.

Le frontend affiche désormais un résumé de résultat et une liste de corrections lisibles pour les six types V1-A : `single_choice`, `multiple_choice`, `matching`, `ordering`, `case_qualification` et `error_detection`.

Le score, `correctAnswers`, `totalQuestions`, `isCorrect` et `partialScore` sont repris depuis `RichClosedExerciseResult` sans recalcul. Le frontend résout uniquement les IDs vers les labels publics déjà présents dans `RichClosedExercise`.

Aucune page routée complète, aucune intégration Today, aucune intégration revision sessions, aucun GenUI catalogue et aucun backend n'ont été modifiés.

## 2. Sources inspectées

### Domaine V1-A

- `revision_app/lib/features/activities/domain/rich_closed_exercise.dart`
- `revision_app/test/features/activities/rich_closed_exercise_test.dart`
- `revision_app/test/features/activities/fixtures/rich_closed_exercise_fixtures.dart`

### Widgets V1-010 / V1-011

- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_question_card.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_choice_group.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_single_choice_widget.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_multiple_choice_widget.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_case_qualification_widget.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_error_detection_widget.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_matching_widget.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_ordering_widget.dart`

### Tests existants

- `revision_app/test/features/activities/rich_closed_answer_controller_test.dart`
- `revision_app/test/features/activities/rich_closed_core_widgets_test.dart`
- `revision_app/test/features/activities/rich_closed_matching_ordering_widgets_test.dart`
- `revision_app/test/features/activities/http_activities_api_test.dart`

### UI / design system

- `revision_app/lib/presentation/widgets/revision_choice_tile.dart`
- `revision_app/lib/presentation/widgets/revision_panel.dart`
- `revision_app/lib/presentation/widgets/revision_message.dart`
- `revision_app/lib/presentation/widgets/revision_status_pill.dart`
- `revision_app/lib/presentation/widgets/revision_button.dart`
- `revision_app/lib/presentation/theme/app_spacing.dart`
- `revision_app/lib/presentation/theme/app_colors.dart`

### Docs V1

- `revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`
- `revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_009_FLUTTER_DOMAIN_V1A.md`
- `revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_010_FLUTTER_WIDGETS_CORE_V1A.md`
- `revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_011_FLUTTER_MATCHING_ORDERING.md`

## 3. Préflight Git

Repo `revision_app` :

- Racine : `/Users/karim/Project/app-révision/revision_app`
- Branche : `main`
- Statut initial : `## main...origin/main`
- Derniers commits initiaux :
  - `3f1bd89 V1-011 — Ajout du rapport d'exécution du lot Widgets Flutter matching/ordering et mise à jour du contrôleur`
  - `debe6f8 V1-010 — Ajout du rapport d'exécution du lot Widgets Flutter V1-A pour single/multiple/case/error et contrôleur de réponses`
  - `341a7c6 V1-009 — Ajout du rapport d'exécution du lot Domain models Flutter V1-A, modèles rich closed, DTOs, parsers et tests`
  - `7f400b6 V1-008B — Ajout du rapport d'exécution du lot Hardening API/scoring rich closed V1-A et mise à jour du plan`
  - `fd7710c V1-007/V1-008 — Ajout des rapports d'exécution des lots Persistance minimale V1-A et API publique pré-submit/post-submit V1-A, mise à jour du plan`

Aucun fichier backend n'a été modifié. Aucune commande n'a été lancée dans `api/`.

## 4. Périmètre réalisé

- Ajout d'un presenter pur `RichClosedCorrectionPresenter`.
- Ajout de view models de résumé et de correction.
- Ajout d'une exception contrôlée `RichClosedCorrectionPresentationException`.
- Ajout de `RichClosedResultSummaryCard`.
- Ajout de `RichClosedCorrectionCard`.
- Ajout de `RichClosedCorrectionList`.
- Ajout de tests unitaires presenter.
- Ajout de widget tests correction UI.
- Mise à jour du plan V1 sur V1-012 uniquement.
- Création du rapport V1-012 dans `docs/v1`.

## 5. Architecture retenue

### Presenter / view models

`RichClosedCorrectionPresenter` reçoit un `RichClosedExercise` public et un `RichClosedExerciseResult` post-submit. Il associe les items de correction à leurs questions publiques, résout les IDs en labels et produit un `RichClosedCorrectionViewModel`.

Les widgets consomment ensuite des view models lisibles plutôt que de contenir des switchs métier dispersés.

### Widgets de summary

`RichClosedResultSummaryCard` affiche `status`, `correctAnswers / totalQuestions` et `score` depuis le backend. Le message qualitatif est uniquement un wording UI dérivé du score affiché, pas un calcul métier de correction.

### Widgets de correction

`RichClosedCorrectionCard` affiche le type, le statut backend, le score partiel backend, le prompt, un contexte éventuel, la réponse envoyée, la réponse attendue, l'explication et les sources minimales.

`RichClosedCorrectionList` joue le rôle de wrapper non routé : il appelle le presenter puis rend le résumé et les cartes.

### Mapping IDs → labels

Le mapping se fait uniquement à partir de l'exercice public :

- choices pour single/multiple/case;
- errorOptions pour error detection;
- leftItems/rightItems pour matching;
- items pour ordering.

### Gestion incohérences

Le presenter lève `RichClosedCorrectionPresentationException` si le résultat référence une question inconnue, un ID inconnu, un type incohérent ou une correction incompatible avec le type de question. Le wrapper affiche alors un `RevisionMessage` contrôlé.

### Anti-recalcul

Le presenter ne compare jamais la réponse soumise à la correction pour calculer `isCorrect`. Il ne recalcule ni score global, ni score partiel, ni nombre de bonnes réponses.

### Absence de routing

Aucune route, page complète ou navigation n'a été ajoutée.

### Absence de Today/session

TodayPlan et les sessions IA ne sont pas modifiés.

## 6. Corrections couvertes

- `single_choice` : réponse choisie et bonne réponse en labels.
- `multiple_choice` : réponses choisies et bonnes réponses en listes de labels.
- `matching` : associations `left label → right label`.
- `ordering` : ordres soumis/corrects en listes numérotées.
- `case_qualification` : cas public, réponse choisie, bonne qualification.
- `error_detection` : statement public, erreur choisie, bonne erreur.

## 7. Anti-recalcul

- Le score backend est affiché tel quel via `score.toString()`.
- `correctAnswers / totalQuestions` vient du backend.
- `isCorrect` vient du backend.
- `partialScore` vient du backend.
- Les labels sont résolus uniquement pour lisibilité.
- Les tests artificiels couvrent :
  - score `0.123`, `99 / 100`;
  - réponse soumise égale à la bonne réponse mais `isCorrect = false`;
  - réponse soumise différente de la bonne réponse mais `isCorrect = true`.

## 8. Anti-fuite / sécurité UI

Post-submit, l'UI peut afficher la correction et l'explication backend. Elle ne rend pas de JSON brut, pas de widget libre et pas de source text complète si le texte source n'est pas disponible.

Les sources sont affichées sous forme minimale `Source <chunkId>`.

## 9. Accessibilité

- Statut `Correct` / `Incorrect` affiché en texte et icône, pas uniquement par couleur.
- Listes de réponses affichées en texte lisible.
- Matching et ordering affichés en blocs empilés, compatibles mobile.
- Primitives existantes utilisées : `RevisionPanel`, `RevisionStatusPill`, `RevisionMessage`.

## 10. Fichiers créés/modifiés/supprimés

### Créés

- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_correction_presenter.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_result_summary_card.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_correction_card.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_correction_list.dart`
- `revision_app/test/features/activities/rich_closed_correction_presenter_test.dart`
- `revision_app/test/features/activities/rich_closed_correction_widgets_test.dart`
- `revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_012_SCORING_CORRECTION_UI_V1A.md`

### Modifiés

- `revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`

### Supprimés

Aucun fichier supprimé.

## 11. Tests ajoutés ou renforcés

### Presenter

- Construction du summary depuis le résultat backend.
- Mapping labels pour les six types V1-A.
- Conservation de `isCorrect`, `partialScore`, `score`, `correctAnswers`, `totalQuestions`.
- Rejet d'une question inconnue.
- Rejet d'un choice inconnu.
- Rejet d'une paire matching inconnue.
- Rejet d'un item ordering inconnu.
- Rejet d'une correction incohérente avec `questionKind`.

### Widgets

- Résumé affichant score et ratio backend.
- Liste avec une correction par item.
- Affichage des labels lisibles pour les six types.
- Anti-recalcul UI sur `isCorrect`.
- Message d'erreur contrôlé si le presenter échoue.

## 12. Validations lancées avec résultats

Depuis `revision_app` :

- `flutter test test/features/activities/rich_closed_correction_presenter_test.dart test/features/activities/rich_closed_correction_widgets_test.dart --reporter compact` : échec RED attendu avant implémentation, classes manquantes.
- `dart format lib/features/activities/presentation/rich_closed/rich_closed_correction_presenter.dart lib/features/activities/presentation/rich_closed/rich_closed_result_summary_card.dart lib/features/activities/presentation/rich_closed/rich_closed_correction_card.dart lib/features/activities/presentation/rich_closed/rich_closed_correction_list.dart test/features/activities/rich_closed_correction_presenter_test.dart test/features/activities/rich_closed_correction_widgets_test.dart` : réussi.
- `flutter test test/features/activities/rich_closed_correction_presenter_test.dart test/features/activities/rich_closed_correction_widgets_test.dart --reporter compact` : réussi, `All tests passed!`.
- `dart analyze lib test` : réussi, `No issues found!`.
- `flutter test test/features/activities --reporter compact` : réussi, `All tests passed!`.
- `flutter test --reporter compact` : réussi, `All tests passed!`.
- `git diff --check` : réussi.

## 13. Validations non lancées avec justification

- Aucun test backend lancé : interdit par le périmètre V1-012.
- Aucune commande dans `api/` lancée : interdit par le périmètre V1-012.
- Aucun lancement manuel de l'app : non demandé, et ce lot est couvert par analyse + tests Flutter.
- `dart fix --apply` non lancé : explicitement interdit.
- `dart format .` non lancé : explicitement interdit ; seuls les fichiers modifiés ont été formatés.

## 14. Risques restants

- Les composants post-submit ne sont pas encore intégrés dans une page rich closed complète.
- V1-013 demande probablement un lot de consolidation ou d'intégration page rich closed avant l'intégration Today, sinon Today n'aura pas encore de destination produit complète.
- Les sources restent affichées sous forme d'IDs/chips, faute de texte source dans le modèle post-submit Flutter.

## 15. Recommandation prochain lot

Recommandation : faire un mini-lot de consolidation avant `V1-013 — Today integration V1` si la page rich closed complète n'existe pas encore.

Nom possible : `V1-012B — Page rich closed complète et flow submit local`.

Sinon, V1-013 risque de brancher Today vers une expérience encore morcelée.

## 16. Passes de review

- Presenter : mapping par type centralisé, exceptions contrôlées.
- Mapping labels : choix, erreurs, paires et ordres résolus depuis l'exercice public.
- Anti-recalcul : score, ratio, `isCorrect` et `partialScore` conservés depuis backend.
- Correction widgets : résumé, cards et list wrapper non routés.
- Accessibilité : statut textuel + icône, listes lisibles, pas d'interaction post-submit.
- Scope/no routing : aucune page complète, aucune route, aucun Today, aucune session.
- Tests : tests unitaires presenter + widget tests + suite activities + suite Flutter complète.

## 17. Critique honnête du prompt initial

Le prompt était bien cadré sur le point crucial : interdire tout recalcul frontend. La recommandation presenter/view model était nécessaire pour éviter une UI faite de switchs dispersés. La seule tension est le prochain lot : intégrer Today directement après V1-012 pourrait être prématuré si la page rich closed complète n'est pas encore assemblée.

## 18. Contenu complet des fichiers créés/modifiés/supprimés pour review

Note : ce rapport est lui-même un fichier créé. Son contenu complet correspond au présent document ; il n'est pas répété récursivement dans cette section pour éviter une auto-inclusion infinie.

### lib/features/activities/presentation/rich_closed/rich_closed_correction_presenter.dart

```dart
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';

class RichClosedCorrectionPresentationException implements Exception {
  const RichClosedCorrectionPresentationException(this.message);

  final String message;

  @override
  String toString() => 'RichClosedCorrectionPresentationException: $message';
}

class RichClosedCorrectionPresenter {
  const RichClosedCorrectionPresenter();

  RichClosedCorrectionViewModel present({
    required RichClosedExercise exercise,
    required RichClosedExerciseResult result,
  }) {
    final questionsById = {
      for (final question in exercise.questions) question.id: question,
    };

    final items = <RichClosedCorrectionItemViewModel>[
      for (final item in result.items)
        _presentItem(
          question: _questionFor(questionsById, item.questionId),
          item: item,
        ),
    ];

    return RichClosedCorrectionViewModel(
      summary: RichClosedResultSummaryViewModel(
        sessionId: result.sessionId,
        status: result.status,
        correctAnswers: result.correctAnswers,
        totalQuestions: result.totalQuestions,
        score: result.score,
      ),
      items: items,
    );
  }

  RichClosedCorrectionItemViewModel _presentItem({
    required RichClosedQuestion question,
    required RichClosedCorrectionItem item,
  }) {
    _assertQuestionContract(question, item);

    return switch (question) {
      RichClosedSingleChoiceQuestion() => _presentSingleChoice(question, item),
      RichClosedMultipleChoiceQuestion() => _presentMultipleChoice(
        question,
        item,
      ),
      RichClosedMatchingQuestion() => _presentMatching(question, item),
      RichClosedOrderingQuestion() => _presentOrdering(question, item),
      RichClosedCaseQualificationQuestion() => _presentCaseQualification(
        question,
        item,
      ),
      RichClosedErrorDetectionQuestion() => _presentErrorDetection(
        question,
        item,
      ),
    };
  }

  RichClosedCorrectionItemViewModel _presentSingleChoice(
    RichClosedSingleChoiceQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _singleChoiceAnswer(item);
    final correction = _choiceIdCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      submittedAnswerLines: [
        _choiceLabel(question.choices, submitted.choiceId, question.id),
      ],
      correctAnswerLines: [
        _choiceLabel(question.choices, correction.correctChoiceId, question.id),
      ],
    );
  }

  RichClosedCorrectionItemViewModel _presentMultipleChoice(
    RichClosedMultipleChoiceQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _multipleChoiceAnswer(item);
    final correction = _choiceIdsCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      submittedAnswerLines: [
        for (final choiceId in submitted.choiceIds)
          _choiceLabel(question.choices, choiceId, question.id),
      ],
      correctAnswerLines: [
        for (final choiceId in correction.correctChoiceIds)
          _choiceLabel(question.choices, choiceId, question.id),
      ],
    );
  }

  RichClosedCorrectionItemViewModel _presentMatching(
    RichClosedMatchingQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _matchingAnswer(item);
    final correction = _pairsCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      submittedAnswerLines: _matchingLines(question, submitted.pairs),
      correctAnswerLines: _matchingLines(question, correction.correctPairs),
    );
  }

  RichClosedCorrectionItemViewModel _presentOrdering(
    RichClosedOrderingQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _orderingAnswer(item);
    final correction = _orderCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      submittedAnswerLines: _orderedLines(question, submitted.orderedIds),
      correctAnswerLines: _orderedLines(question, correction.correctOrder),
    );
  }

  RichClosedCorrectionItemViewModel _presentCaseQualification(
    RichClosedCaseQualificationQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _caseQualificationAnswer(item);
    final correction = _choiceIdCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      contextText: question.caseText,
      submittedAnswerLines: [
        _choiceLabel(question.choices, submitted.choiceId, question.id),
      ],
      correctAnswerLines: [
        _choiceLabel(question.choices, correction.correctChoiceId, question.id),
      ],
    );
  }

  RichClosedCorrectionItemViewModel _presentErrorDetection(
    RichClosedErrorDetectionQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _errorDetectionAnswer(item);
    final correction = _errorIdCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      contextText: question.statement,
      submittedAnswerLines: [
        _choiceLabel(question.errorOptions, submitted.errorId, question.id),
      ],
      correctAnswerLines: [
        _choiceLabel(
          question.errorOptions,
          correction.correctErrorId,
          question.id,
        ),
      ],
    );
  }

  RichClosedCorrectionItemViewModel _baseItem({
    required RichClosedQuestion question,
    required RichClosedCorrectionItem item,
    required List<String> submittedAnswerLines,
    required List<String> correctAnswerLines,
    String? contextText,
  }) {
    return RichClosedCorrectionItemViewModel(
      questionId: question.id,
      questionKind: question.questionKind,
      kindLabel: _kindLabel(question.questionKind),
      prompt: item.prompt,
      contextText: contextText,
      isCorrect: item.isCorrect,
      partialScore: item.partialScore,
      explanation: item.explanation,
      sourceLabels: [
        for (final sourceChunkId in item.sourceChunkIds)
          'Source $sourceChunkId',
      ],
      submittedAnswerLines: submittedAnswerLines,
      correctAnswerLines: correctAnswerLines,
    );
  }

  RichClosedQuestion _questionFor(
    Map<String, RichClosedQuestion> questionsById,
    String questionId,
  ) {
    final question = questionsById[questionId];
    if (question == null) {
      throw RichClosedCorrectionPresentationException(
        'Correction references unknown question $questionId',
      );
    }
    return question;
  }

  void _assertQuestionContract(
    RichClosedQuestion question,
    RichClosedCorrectionItem item,
  ) {
    if (item.questionKind != question.questionKind) {
      throw RichClosedCorrectionPresentationException(
        'Correction kind mismatch for question ${question.id}',
      );
    }

    if (item.submittedAnswer.questionId != question.id ||
        item.submittedAnswer.questionKind != question.questionKind) {
      throw RichClosedCorrectionPresentationException(
        'Submitted answer mismatch for question ${question.id}',
      );
    }
  }

  RichClosedSingleChoiceAnswer _singleChoiceAnswer(
    RichClosedCorrectionItem item,
  ) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedSingleChoiceAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid single choice submitted answer for ${item.questionId}',
    );
  }

  RichClosedMultipleChoiceAnswer _multipleChoiceAnswer(
    RichClosedCorrectionItem item,
  ) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedMultipleChoiceAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid multiple choice submitted answer for ${item.questionId}',
    );
  }

  RichClosedMatchingAnswer _matchingAnswer(RichClosedCorrectionItem item) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedMatchingAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid matching submitted answer for ${item.questionId}',
    );
  }

  RichClosedOrderingAnswer _orderingAnswer(RichClosedCorrectionItem item) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedOrderingAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid ordering submitted answer for ${item.questionId}',
    );
  }

  RichClosedCaseQualificationAnswer _caseQualificationAnswer(
    RichClosedCorrectionItem item,
  ) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedCaseQualificationAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid case qualification submitted answer for ${item.questionId}',
    );
  }

  RichClosedErrorDetectionAnswer _errorDetectionAnswer(
    RichClosedCorrectionItem item,
  ) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedErrorDetectionAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid error detection submitted answer for ${item.questionId}',
    );
  }

  RichClosedCorrectChoiceIdCorrection _choiceIdCorrection(
    RichClosedCorrectionItem item,
  ) {
    final correction = item.correction;
    if (correction is RichClosedCorrectChoiceIdCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid choice correction for ${item.questionId}',
    );
  }

  RichClosedCorrectChoiceIdsCorrection _choiceIdsCorrection(
    RichClosedCorrectionItem item,
  ) {
    final correction = item.correction;
    if (correction is RichClosedCorrectChoiceIdsCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid choices correction for ${item.questionId}',
    );
  }

  RichClosedCorrectPairsCorrection _pairsCorrection(
    RichClosedCorrectionItem item,
  ) {
    final correction = item.correction;
    if (correction is RichClosedCorrectPairsCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid matching correction for ${item.questionId}',
    );
  }

  RichClosedCorrectOrderCorrection _orderCorrection(
    RichClosedCorrectionItem item,
  ) {
    final correction = item.correction;
    if (correction is RichClosedCorrectOrderCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid ordering correction for ${item.questionId}',
    );
  }

  RichClosedCorrectErrorIdCorrection _errorIdCorrection(
    RichClosedCorrectionItem item,
  ) {
    final correction = item.correction;
    if (correction is RichClosedCorrectErrorIdCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid error detection correction for ${item.questionId}',
    );
  }

  String _choiceLabel(
    List<RichClosedChoice> choices,
    String choiceId,
    String questionId,
  ) {
    for (final choice in choices) {
      if (choice.id == choiceId) {
        return choice.label;
      }
    }
    throw RichClosedCorrectionPresentationException(
      'Unknown choice $choiceId for question $questionId',
    );
  }

  String _labelItem(
    List<RichClosedLabelItem> items,
    String itemId,
    String questionId,
  ) {
    for (final item in items) {
      if (item.id == itemId) {
        return item.label;
      }
    }
    throw RichClosedCorrectionPresentationException(
      'Unknown item $itemId for question $questionId',
    );
  }

  List<String> _matchingLines(
    RichClosedMatchingQuestion question,
    List<RichClosedPair> pairs,
  ) {
    return [
      for (final pair in pairs)
        '${_labelItem(question.leftItems, pair.leftId, question.id)} → '
            '${_labelItem(question.rightItems, pair.rightId, question.id)}',
    ];
  }

  List<String> _orderedLines(
    RichClosedOrderingQuestion question,
    List<String> orderedIds,
  ) {
    return [
      for (var index = 0; index < orderedIds.length; index += 1)
        '${index + 1}. ${_labelItem(question.items, orderedIds[index], question.id)}',
    ];
  }

  String _kindLabel(RichClosedQuestionKind kind) {
    return switch (kind) {
      RichClosedQuestionKind.singleChoice => 'Choix unique',
      RichClosedQuestionKind.multipleChoice => 'Choix multiples',
      RichClosedQuestionKind.matching => 'Association',
      RichClosedQuestionKind.ordering => 'Ordonnancement',
      RichClosedQuestionKind.caseQualification => 'Qualification',
      RichClosedQuestionKind.errorDetection => 'Erreur à repérer',
    };
  }
}

class RichClosedCorrectionViewModel {
  const RichClosedCorrectionViewModel({
    required this.summary,
    required this.items,
  });

  final RichClosedResultSummaryViewModel summary;
  final List<RichClosedCorrectionItemViewModel> items;
}

class RichClosedResultSummaryViewModel {
  const RichClosedResultSummaryViewModel({
    required this.sessionId,
    required this.status,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.score,
  });

  final String sessionId;
  final String status;
  final int correctAnswers;
  final int totalQuestions;
  final double score;

  String get scoreLabel => score.toString();
  String get answerRatioLabel => '$correctAnswers / $totalQuestions';

  String get message {
    if (score >= 0.85) {
      return 'Excellent résultat.';
    }
    if (score >= 0.6) {
      return 'Solide, avec quelques points à consolider.';
    }
    return 'À retravailler en priorité.';
  }
}

class RichClosedCorrectionItemViewModel {
  const RichClosedCorrectionItemViewModel({
    required this.questionId,
    required this.questionKind,
    required this.kindLabel,
    required this.prompt,
    required this.contextText,
    required this.isCorrect,
    required this.partialScore,
    required this.explanation,
    required this.sourceLabels,
    required this.submittedAnswerLines,
    required this.correctAnswerLines,
  });

  final String questionId;
  final RichClosedQuestionKind questionKind;
  final String kindLabel;
  final String prompt;
  final String? contextText;
  final bool isCorrect;
  final double partialScore;
  final String explanation;
  final List<String> sourceLabels;
  final List<String> submittedAnswerLines;
  final List<String> correctAnswerLines;

  String get statusLabel => isCorrect ? 'Correct' : 'Incorrect';
  String get partialScoreLabel => partialScore.toString();
}
```

### lib/features/activities/presentation/rich_closed/rich_closed_result_summary_card.dart

```dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_correction_presenter.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';
import 'package:revision_app/presentation/widgets/revision_status_pill.dart';

class RichClosedResultSummaryCard extends StatelessWidget {
  const RichClosedResultSummaryCard({required this.summary, super.key});

  final RichClosedResultSummaryViewModel summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              RevisionStatusPill(
                label: summary.status,
                color: colorScheme.tertiary,
                icon: Icons.check_circle_outline,
              ),
              RevisionStatusPill(
                label: summary.answerRatioLabel,
                color: colorScheme.primary,
                icon: Icons.fact_check_outlined,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text('Résultat', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          Text('Score backend', style: Theme.of(context).textTheme.labelMedium),
          Text(
            summary.scoreLabel,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(summary.message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
```

### lib/features/activities/presentation/rich_closed/rich_closed_correction_card.dart

```dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_correction_presenter.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';
import 'package:revision_app/presentation/widgets/revision_status_pill.dart';

class RichClosedCorrectionCard extends StatelessWidget {
  const RichClosedCorrectionCard({required this.item, super.key});

  final RichClosedCorrectionItemViewModel item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = item.isCorrect
        ? colorScheme.tertiary
        : colorScheme.error;
    final statusIcon = item.isCorrect
        ? Icons.check_circle_outline
        : Icons.cancel_outlined;

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              RevisionStatusPill(
                label: item.kindLabel,
                color: colorScheme.primary,
                icon: Icons.checklist_rtl,
              ),
              RevisionStatusPill(
                label: item.statusLabel,
                color: statusColor,
                icon: statusIcon,
              ),
              RevisionStatusPill(
                label: 'Score partiel ${item.partialScoreLabel}',
                color: colorScheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(item.prompt, style: Theme.of(context).textTheme.titleMedium),
          if (item.contextText != null) ...[
            const SizedBox(height: AppSpacing.s),
            _TextBlock(label: 'Contexte', lines: [item.contextText!]),
          ],
          const SizedBox(height: AppSpacing.m),
          _TextBlock(
            label: 'Réponse envoyée',
            lines: item.submittedAnswerLines,
          ),
          const SizedBox(height: AppSpacing.m),
          _TextBlock(label: 'Réponse attendue', lines: item.correctAnswerLines),
          const SizedBox(height: AppSpacing.m),
          _TextBlock(label: 'Explication', lines: [item.explanation]),
          if (item.sourceLabels.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.m),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: [
                for (final sourceLabel in item.sourceLabels)
                  RevisionStatusPill(
                    label: sourceLabel,
                    color: colorScheme.secondary,
                    icon: Icons.source_outlined,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  const _TextBlock({required this.label, required this.lines});

  final String label;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.xs),
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(line, style: textTheme.bodyMedium),
          ),
      ],
    );
  }
}
```

### lib/features/activities/presentation/rich_closed/rich_closed_correction_list.dart

```dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_correction_card.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_correction_presenter.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_result_summary_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_message.dart';

class RichClosedCorrectionList extends StatelessWidget {
  const RichClosedCorrectionList({
    required this.exercise,
    required this.result,
    this.presenter = const RichClosedCorrectionPresenter(),
    super.key,
  });

  final RichClosedExercise exercise;
  final RichClosedExerciseResult result;
  final RichClosedCorrectionPresenter presenter;

  @override
  Widget build(BuildContext context) {
    late final RichClosedCorrectionViewModel viewModel;
    try {
      viewModel = presenter.present(exercise: exercise, result: result);
    } on RichClosedCorrectionPresentationException catch (error) {
      return RichClosedCorrectionErrorMessage(
        message: 'Correction indisponible : ${error.message}',
        color: Theme.of(context).colorScheme.error,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichClosedResultSummaryCard(summary: viewModel.summary),
        const SizedBox(height: AppSpacing.l),
        for (final item in viewModel.items) ...[
          RichClosedCorrectionCard(item: item),
          const SizedBox(height: AppSpacing.l),
        ],
      ],
    );
  }
}

class RichClosedCorrectionErrorMessage extends StatelessWidget {
  const RichClosedCorrectionErrorMessage({
    required this.message,
    required this.color,
    super.key,
  });

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RevisionMessage(
      message: message,
      color: color,
      icon: Icons.error_outline,
    );
  }
}
```

### test/features/activities/rich_closed_correction_presenter_test.dart

```dart
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
```

### test/features/activities/rich_closed_correction_widgets_test.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_correction_card.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_correction_list.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_correction_presenter.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_result_summary_card.dart';

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
```

### docs/v1/ROADMAP_EXECUTION_PLAN_V1.md

```md
# Plan d'exécution V1 — Questions riches fermées

## Introduction

Ce plan découpe la V1 “questions riches fermées” en lots atomiques. La règle directrice est d'éviter le big bang : on stabilise d'abord le contrat, puis les quality gates, puis un sous-ensemble V1-A très rentable pédagogiquement, avant d'étendre progressivement Today, les sessions IA, les fixtures et les types plus complexes.

Tous les rapports V1 doivent être créés dans `docs/v1`.

## Principes d'exécution

- Lots de 0,5 à 2 jours quand possible.
- Aucun type de question n'est ajouté sans contrat backend, parser frontend, tests anti-fuite et fallback.
- Le QCM v3 V0 reste compatible jusqu'à migration explicite.
- La réponse libre reste exclusivement dans `open_question`.
- Genkit ne choisit jamais de widget libre.
- Flutter ne rend jamais un payload arbitraire.
- Les corrections restent post-submit.
- Chaque lot doit documenter les validations lancées et les validations non lancées.

## Tableau des lots V1

| Lot | Titre | Statut | Rapport |
| --- | --- | --- | --- |
| V1-001 | Roadmap et catalogue questions riches fermées | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_001_RICH_QUESTIONS_ROADMAP.md |
| V1-002 | ADR contrat rich closed questions | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_002_RICH_CLOSED_QUESTIONS_ADR.md |
| V1-003 | Audit Prisma/DTO et décision versioning | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_003_PRISMA_DTO_VERSIONING_AUDIT.md |
| V1-004 | Contrat backend rich question kinds | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_004_BACKEND_RICH_QUESTION_KINDS.md |
| V1-005 | Quality gates pédagogiques backend | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_005_PEDAGOGICAL_QUALITY_GATES.md |
| V1-005B | Hardening contrat public et validators rich closed questions | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_005B_RICH_CLOSED_CONTRACT_HARDENING.md |
| V1-006 | Génération Genkit rich closed questions V1-A | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_006_GENKIT_RICH_CLOSED_V1A.md |
| V1-007 | Persistance minimale V1-A | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_007_PERSISTENCE_V1A.md |
| V1-008 | API publique pré-submit/post-submit V1-A | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_008_PUBLIC_API_V1A.md |
| V1-008B | Hardening API/scoring rich closed V1-A | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_008B_RICH_CLOSED_API_SCORING_HARDENING.md |
| V1-009 | Domain models Flutter V1-A | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_009_FLUTTER_DOMAIN_V1A.md |
| V1-010 | Widgets Flutter V1-A single/multiple/case/error | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_010_FLUTTER_WIDGETS_CORE_V1A.md |
| V1-011 | Widgets Flutter matching/ordering | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_011_FLUTTER_MATCHING_ORDERING.md |
| V1-012 | Scoring/correction UI V1-A | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_012_SCORING_CORRECTION_UI_V1A.md |
| V1-013 | Today integration V1 | À faire | À créer |
| V1-014 | Revision session integration V1 | À faire | À créer |
| V1-015 | Seed V1 rich demo fixtures | À faire | À créer |
| V1-016 | E2E/smoke V1 rich questions | À faire | À créer |
| V1-017 | Timeline/date slider V1-B | À faire | À créer |
| V1-018 | True/false grid + cause/consequence V1-B | À faire | À créer |
| V1-019 | Institution matrix V1-C | À faire | À créer |
| V1-020 | Diagram labeling V1-C | À faire | À créer |
| V1-021 | Calculation MCQ modes de scrutin V1-C | À faire | À créer |
| V1-022 | Image choice/personnages historiques V1-D | À faire | À créer |
| V1-023 | Runbook demo V1 | À faire | À créer |
| V1-024 | Polish UI/accessibilité/performance | À faire | À créer |
| V1-025 | Revue finale V1 et readiness audit | À faire | À créer |

## Lots détaillés

### V1-001 — Roadmap et catalogue questions riches fermées

- Objectif : créer la vision V1, le catalogue, les exemples et le plan d'exécution.
- Pourquoi maintenant : la V0 est stable, mais les QCM restent trop basiques.
- Périmètre inclus : documentation stratégique dans `docs/v1`.
- Non-objectifs : runtime, Prisma, Genkit, Flutter, tests.
- Fichiers probablement concernés : `docs/v1/*`.
- Backend : audit seulement.
- Frontend : audit seulement.
- Genkit : audit seulement.
- GenUI : audit seulement.
- Prisma : audit seulement.
- API : aucune modification.
- Tests attendus : aucun test applicatif.
- Validations à lancer : `git diff --check` depuis `revision_app`.
- Critères d'acceptation : docs V1 créées, aucun runtime modifié.
- Critère de stop : si les repos complets ne sont pas accessibles.
- Risques : plan trop large ou trop proche d'une implémentation.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_001_RICH_QUESTIONS_ROADMAP.md`.

### V1-002 — ADR contrat rich closed questions

- Objectif : trancher le modèle de contrat : QCM v4, nouvelle activité `RICH_CLOSED_EXERCISE`, JSON typé ou tables spécialisées.
- Pourquoi maintenant : toutes les implémentations futures dépendent de cette décision.
- Périmètre inclus : ADR, alternatives, décision recommandée, impacts.
- Non-objectifs : migration ou code runtime.
- Fichiers probablement concernés : `docs/v1/ADR_RICH_CLOSED_QUESTIONS_CONTRACT.md`, rapport V1-002.
- Backend : définir discriminant `questionKind`, `answerShape`, `interactionPayload`, `correctionPayload`.
- Frontend : définir besoins de parser discriminé.
- Genkit : définir nom de schema version.
- GenUI : définir place du catalogue borné.
- Prisma : comparer stratégie JSON typé et tables dédiées.
- API : définir endpoints futurs.
- Tests attendus : aucun test runtime, checklist ADR.
- Validations à lancer : `git diff --check`.
- Critères d'acceptation : une décision claire et réversible.
- Critère de stop : si l'ADR demande une migration destructive.
- Risques : sous-estimer la dette du modèle `Question`.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_002_RICH_CLOSED_QUESTIONS_ADR.md`.

### V1-003 — Audit Prisma/DTO et décision versioning

- Objectif : auditer précisément les modèles, DTO publics, serializers et mappings nécessaires à la décision V1.
- Pourquoi maintenant : éviter une migration ou un contrat incomplet.
- Périmètre inclus : documentation technique, diagrammes de mapping, risques DB.
- Non-objectifs : création de migration.
- Fichiers probablement concernés : docs V1 uniquement.
- Backend : `ActivitySession`, `Question`, `QuestionAnswer`, `QuestionVisual`, `RevisionSessionAction`.
- Frontend : modèles QCM actuels et parsers sessions.
- Genkit : versions de prompts et schemas.
- GenUI : validators existants.
- Prisma : inventaire des colonnes et contraintes.
- API : inventaire pré-submit/post-submit.
- Tests attendus : aucun test runtime.
- Validations à lancer : `git diff --check`.
- Critères d'acceptation : table claire des champs réutilisables vs manquants.
- Critère de stop : si l'audit révèle un besoin de refonte plus large.
- Risques : ambiguïté entre `DIAGNOSTIC_QUIZ` et nouveau type.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_003_PRISMA_DTO_VERSIONING_AUDIT.md`.

### V1-004 — Contrat backend rich question kinds

- Objectif : ajouter les types applicatifs backend V1-A sans Genkit réel.
- Pourquoi maintenant : stabiliser les invariants avant génération.
- Périmètre inclus : union discriminée V1-A, validators purs, tests unitaires.
- Non-objectifs : persistance complète ou UI.
- Fichiers probablement concernés : `api/src/modules/activities/application/**`.
- Backend : `single_choice`, `multiple_choice`, `matching`, `ordering`, `case_qualification`, `error_detection`.
- Frontend : aucun.
- Genkit : aucun flow.
- GenUI : aucun.
- Prisma : aucune migration si possible.
- API : pas encore exposée publiquement sauf helpers internes.
- Tests attendus : validators et anti-fuite.
- Validations à lancer : `npm test -- activities --runInBand`, `npm run lint:check`, `npm run build`.
- Critères d'acceptation : types fermés validés et corrections séparées.
- Critère de stop : si l'ADR n'est pas validée.
- Risques : contrat trop abstrait.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_004_BACKEND_RICH_QUESTION_KINDS.md`.

### V1-005 — Quality gates pédagogiques backend

- Objectif : refuser les exercices trop basiques ou incohérents.
- Pourquoi maintenant : éviter que Genkit V1-A produise un QCM classique.
- Périmètre inclus : règles de mix, sources, correction, tailles minimales.
- Non-objectifs : régénération IA complexe.
- Fichiers probablement concernés : générateurs/validators activities.
- Backend : quality gate pur et testé.
- Frontend : aucun.
- Genkit : prépare l'intégration.
- GenUI : aucun.
- Prisma : aucun.
- API : erreurs contrôlées.
- Tests attendus : mix insuffisant, type interdit, correction pré-submit, source invalide.
- Validations à lancer : tests activities, lint check, build.
- Critères d'acceptation : une sortie 100 % QCM simple est rejetée.
- Critère de stop : gates trop stricts pour données pauvres.
- Risques : faux négatifs sur petits documents.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_005_PEDAGOGICAL_QUALITY_GATES.md`.

### V1-005B — Hardening contrat public et validators rich closed questions

- Objectif : durcir le contrat public, les validators et les gates avant Genkit.
- Pourquoi maintenant : éviter que V1-006 produise ou accepte des payloads ambigus ou semi-privés.
- Périmètre inclus : types publics sans feedback, validation stricte de `cognitiveSkill`, bornes `multiple_choice`, scan anti-fuite renforcé.
- Non-objectifs : Genkit réel, Prisma, API publique, Flutter UI.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_005B_RICH_CLOSED_CONTRACT_HARDENING.md`.

### V1-006 — Génération Genkit rich closed questions V1-A

- Objectif : générer les types V1-A via Genkit avec quotas stricts.
- Pourquoi maintenant : le contrat et les gates existent.
- Périmètre inclus : prompt, schema Zod, observer metadata-only, fallback contrôlé.
- Non-objectifs : images, matrices, timeline.
- Fichiers probablement concernés : `api/src/modules/activities/infrastructure/genkit-*`.
- Backend : adapter generator V1-A.
- Frontend : aucun.
- Genkit : nouveau flow ou nouveau mode selon ADR.
- GenUI : aucun.
- Prisma : aucun.
- API : pas encore public si persistance absente.
- Note V1-006 réalisé : le générateur reste non public, non persisté et non branché API.
- Tests attendus : mock Genkit, schema strict, error codes whitelistés.
- Validations à lancer : tests ai/activities, lint check, build.
- Critères d'acceptation : le prompt impose `questionTypeMix`.
- Critère de stop : provider réel requis dans tests.
- Risques : prompts trop longs.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_006_GENKIT_RICH_CLOSED_V1A.md`.

### V1-007 — Persistance minimale V1-A

- Objectif : persister les questions riches V1-A.
- Pourquoi maintenant : génération utile seulement si relue et soumise.
- Périmètre inclus : modèle choisi par ADR, migration si nécessaire, repository.
- Non-objectifs : UI Flutter.
- Fichiers probablement concernés : Prisma, repository activities.
- Backend : adapter Prisma.
- Frontend : aucun.
- Genkit : aucun changement fonctionnel.
- GenUI : aucun.
- Prisma : migration non destructive si nécessaire.
- API : mapping interne.
- Note V1-007 réalisé : persistance dédiée `RichClosedExercisePayload` et `RichClosedExerciseResult`, payload interne JSON typé, relecture pré-submit via mapper public.
- Tests attendus : persistance, relecture pré-submit, anti-fuite.
- Validations à lancer : `npx prisma validate`, `npm run prisma:generate`, tests activities, migration sur DB jetable si créée.
- Critères d'acceptation : données privées jamais exposées pré-submit.
- Critère de stop : migration destructive.
- Risques : JSON difficile à requêter.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_007_PERSISTENCE_V1A.md`.

### V1-008 — API publique pré-submit/post-submit V1-A

- Objectif : exposer un contrat public pour démarrer et soumettre un exercice riche fermé.
- Pourquoi maintenant : la persistance existe.
- Périmètre inclus : endpoints ou extension contrôlée, DTO, error mapping.
- Non-objectifs : Flutter UI.
- Fichiers probablement concernés : controller activities, use cases.
- Backend : pré-submit sans correction, post-submit avec correction.
- Frontend : lecture seule du contrat.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : nouveau type d'activité ou version selon ADR.
- Note V1-008 réalisé : endpoints `/activities/rich-closed/start`, `/activities/rich-closed/:sessionId`, `/activities/rich-closed/:sessionId/submit` et `/activities/rich-closed/:sessionId/result`.
- Tests attendus : e2e critiques, 400/404/409/422, anti-fuite.
- Validations à lancer : tests e2e, activities, lint check, build.
- Critères d'acceptation : endpoints exploitables par Flutter.
- Critère de stop : contrat public ambigu.
- Risques : casser QCM v3.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_008_PUBLIC_API_V1A.md`.

### V1-008B — Hardening API/scoring rich closed V1-A

- Objectif : corriger les validations de soumission et le cas `documentId: null` avant l’intégration Flutter.
- Pourquoi maintenant : éviter que V1-009 consomme un contrat qui accepte des IDs inconnus ou rejette artificiellement un document nul.
- Périmètre inclus : scorer rich closed, use case de démarrage, tests module/use case/scorer.
- Non-objectifs : Prisma, Genkit, Flutter, Today, revision sessions, seed.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_008B_RICH_CLOSED_API_SCORING_HARDENING.md`.

### V1-009 — Domain models Flutter V1-A

- Objectif : ajouter les modèles Flutter discriminés pour V1-A.
- Pourquoi maintenant : le contrat API est public.
- Périmètre inclus : domain, parsers data, fakes, tests.
- Non-objectifs : widgets complets.
- Fichiers probablement concernés : `lib/features/activities/domain/**`, data, tests.
- Backend : aucun.
- Frontend : sealed classes par `questionKind`.
- Note V1-009 réalisé : modèles discriminés, parsers stricts, API client préparée, aucune UI branchée.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : consommation stricte.
- Tests attendus : parse valide/invalide, correction pré-submit rejetée.
- Validations à lancer : `dart analyze lib test`, tests activities.
- Critères d'acceptation : parser discriminé strict.
- Critère de stop : contrat backend instable.
- Risques : duplication avec QCM v3.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_009_FLUTTER_DOMAIN_V1A.md`.

### V1-010 — Widgets Flutter V1-A single/multiple/case/error

- Objectif : rendre les premiers types V1-A natifs.
- Pourquoi maintenant : modèles Flutter disponibles.
- Périmètre inclus : choix unique, multiple, cas, détection d'erreur.
- Non-objectifs : matching/ordering.
- Note V1-010 réalisé : widgets core V1-A ajoutés pour single/multiple/case/error, matching/ordering non inclus, correction UI complète reportée à V1-012, aucune intégration Today/session.
- Fichiers probablement concernés : pages/widgets activities.
- Backend : aucun.
- Frontend : widgets natifs accessibles.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : aucun.
- Tests attendus : pré-submit, sélection, submit, correction.
- Validations à lancer : analyze, widget tests, full flutter test si possible.
- Critères d'acceptation : aucune correction visible avant submit.
- Critère de stop : overflow mobile non résolu.
- Risques : UX trop proche du QCM actuel.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_010_FLUTTER_WIDGETS_CORE_V1A.md`.

### V1-011 — Widgets Flutter matching/ordering

- Objectif : ajouter association et remise en ordre.
- Pourquoi maintenant : ce sont les interactions V1-A les plus nouvelles.
- Périmètre inclus : matching, ordering, validations locales.
- Non-objectifs : timeline complète.
- Note V1-011 réalisé : widgets matching/ordering ajoutés avec interactions accessibles sans drag-only, correction UI complète reportée à V1-012, aucune intégration Today/session.
- Fichiers probablement concernés : widgets activities, tests.
- Backend : aucun.
- Frontend : menus/dropdowns ou reordering accessible.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : aucun.
- Tests attendus : associations, ordre, correction, accessibilité minimale.
- Validations à lancer : analyze, tests activities.
- Critères d'acceptation : interactions utilisables sans drag-only obligatoire.
- Critère de stop : interaction inaccessible.
- Risques : ergonomie mobile.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_011_FLUTTER_MATCHING_ORDERING.md`.

### V1-012 — Scoring/correction UI V1-A

- Objectif : unifier affichage des corrections et scores V1-A.
- Pourquoi maintenant : plusieurs widgets existent.
- Périmètre inclus : panels correction, score par type, sources post-submit.
- Non-objectifs : recalcul frontend.
- Note V1-012 réalisé : summary/result UI et correction cards V1-A ajoutées, aucun recalcul frontend, aucune intégration Today/session.
- Fichiers probablement concernés : widgets correction activities.
- Backend : aucun sauf bug de contrat.
- Frontend : affichage post-submit.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : consommation.
- Tests attendus : aucune correction pré-submit, rendu post-submit.
- Validations à lancer : analyze, tests activities.
- Critères d'acceptation : correction lisible pour chaque type V1-A.
- Critère de stop : score frontend inventé.
- Risques : incohérence visuelle.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_012_SCORING_CORRECTION_UI_V1A.md`.

### V1-013 — Today integration V1

- Objectif : permettre à Today de recommander un exercice riche fermé.
- Pourquoi maintenant : runtime V1-A complet.
- Périmètre inclus : action type, start payload, routing.
- Non-objectifs : ranking IA.
- Fichiers probablement concernés : backend revision Today, Flutter Today.
- Backend : action déterministe `rich_closed_exercise`.
- Frontend : navigation vers activité V1.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : Today DTO enrichi.
- Tests attendus : ranking stable, navigation.
- Validations à lancer : backend revision tests, flutter today tests.
- Critères d'acceptation : Today peut lancer un exercice riche ciblé.
- Critère de stop : ambiguïté avec open question.
- Risques : route Activities actuelle.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_013_TODAY_INTEGRATION_V1.md`.

### V1-014 — Revision session integration V1

- Objectif : orchestrer les exercices riches dans la session IA.
- Pourquoi maintenant : Today et activité V1 sont prêts.
- Périmètre inclus : action kind fermée, next-action bornée.
- Non-objectifs : widget libre ou chat libre.
- Fichiers probablement concernés : revision-sessions backend, Flutter session.
- Backend : `RICH_CLOSED_EXERCISE` action.
- Frontend : rendu payload métier.
- Genkit : coach choisit une enum, pas un widget.
- GenUI : aucun widget arbitraire.
- Prisma : migration possible si enum action.
- API : session response.
- Tests attendus : action, anti-fuite, routing.
- Validations à lancer : tests revision-sessions, activities, flutter revision sessions.
- Critères d'acceptation : session peut enchaîner rich closed exercise.
- Critère de stop : action coach non bornée.
- Risques : migration enum.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_014_REVISION_SESSION_INTEGRATION_V1.md`.

### V1-015 — Seed V1 rich demo fixtures

- Objectif : préparer une démo stable d'exercices riches.
- Pourquoi maintenant : intégrations principales prêtes.
- Périmètre inclus : fixtures synthétiques, dry-run, docs.
- Non-objectifs : provider IA réel.
- Fichiers probablement concernés : demo-seed API, docs demo.
- Backend : seed fixtures.
- Frontend : aucun.
- Genkit : aucun appel.
- GenUI : aucun.
- Prisma : aucun schéma si possible.
- API : aucun endpoint.
- Tests attendus : fixtures sans secret, IDs stables.
- Validations à lancer : demo-seed tests, revision/activities si impact.
- Critères d'acceptation : golden demo V1 rejouable.
- Critère de stop : besoin de données propriétaires.
- Risques : seed trop couplé au schéma.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_015_RICH_DEMO_FIXTURES.md`.

### V1-016 — E2E/smoke V1 rich questions

- Objectif : protéger les chemins critiques V1.
- Pourquoi maintenant : seed V1 disponible.
- Périmètre inclus : e2e API, smoke docs.
- Non-objectifs : couverture exhaustive.
- Fichiers probablement concernés : tests e2e API, docs demo.
- Backend : tests endpoints V1.
- Frontend : smoke manuel.
- Genkit : mocké.
- GenUI : anti-widget libre.
- Prisma : DB mockée ou test safe.
- API : contrats critiques.
- Tests attendus : pré-submit, submit, anti-fuite, error mapping.
- Validations à lancer : e2e, activities, build.
- Critères d'acceptation : régression démo détectée.
- Critère de stop : test dépendant d'un provider réel.
- Risques : flakiness.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_016_E2E_SMOKE_RICH_QUESTIONS.md`.

### V1-017 — Timeline/date slider V1-B

- Objectif : ajouter chronologie et date slider.
- Pourquoi maintenant : V1-A stabilisé.
- Périmètre inclus : backend contrat, Flutter widgets, tests.
- Non-objectifs : matrices.
- Fichiers probablement concernés : activities backend/frontend.
- Backend : validation bornes.
- Frontend : timeline responsive, slider accessible.
- Genkit : schema V1-B.
- GenUI : optionnel catalogué.
- Prisma : selon ADR.
- API : type V1-B.
- Tests attendus : ordre, bornes, correction.
- Validations à lancer : backend + Flutter targeted.
- Critères d'acceptation : dates bornées et accessibles.
- Critère de stop : slider inaccessible.
- Risques : dates discutables.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_017_TIMELINE_DATE_SLIDER.md`.

### V1-018 — True/false grid + cause/consequence V1-B

- Objectif : ajouter grille et relations cause/conséquence.
- Pourquoi maintenant : interactions comparatives avancées.
- Périmètre inclus : contrats, widgets, correction.
- Non-objectifs : matrix institutionnelle complète.
- Fichiers probablement concernés : activities.
- Backend : validations lignes/paires.
- Frontend : grille accessible et matching spécialisé.
- Genkit : quotas V1-B.
- GenUI : optionnel.
- Prisma : selon ADR.
- API : types V1-B.
- Tests attendus : lignes complètes, paires univoques.
- Validations à lancer : tests ciblés.
- Critères d'acceptation : pas de grille trop large.
- Critère de stop : UX mobile illisible.
- Risques : surcharge cognitive.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_018_TRUE_FALSE_GRID_CAUSE_CONSEQUENCE.md`.

### V1-019 — Institution matrix V1-C

- Objectif : ajouter matrice institutionnelle.
- Pourquoi maintenant : base des grids disponible.
- Périmètre inclus : contrat borné, widget table.
- Non-objectifs : diagram labeling.
- Fichiers probablement concernés : activities.
- Backend : dimensions bornées.
- Frontend : table scrollable accessible.
- Genkit : schema V1-C.
- GenUI : non principal.
- Prisma : selon ADR.
- API : type matrix.
- Tests attendus : dimensions, cellules, correction.
- Validations à lancer : targeted backend/flutter.
- Critères d'acceptation : matrice lisible mobile.
- Critère de stop : table inaccessible.
- Risques : complexité UI.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_019_INSTITUTION_MATRIX.md`.

### V1-020 — Diagram labeling V1-C

- Objectif : compléter des schémas institutionnels bornés.
- Pourquoi maintenant : type coûteux mais différenciant.
- Périmètre inclus : slots, labels, correction.
- Non-objectifs : SVG/Mermaid libre.
- Fichiers probablement concernés : activities widgets/validators.
- Backend : schéma de diagramme strict.
- Frontend : rendu Flutter natif.
- Genkit : payload borné.
- GenUI : éventuellement composant catalogué.
- Prisma : selon ADR.
- API : type diagram_labeling.
- Tests attendus : pas de rendu arbitraire, slots complets.
- Validations à lancer : tests ciblés.
- Critères d'acceptation : aucun HTML/SVG/Mermaid.
- Critère de stop : payload libre requis.
- Risques : tentation de Mermaid.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_020_DIAGRAM_LABELING.md`.

### V1-021 — Calculation MCQ modes de scrutin V1-C

- Objectif : gérer des calculs fermés.
- Pourquoi maintenant : utile mais nécessite validation forte.
- Périmètre inclus : mini-données, choix, étapes post-submit.
- Non-objectifs : réponse de calcul libre.
- Fichiers probablement concernés : activities.
- Backend : vérification déterministe si possible.
- Frontend : tableau + choix.
- Genkit : génération bornée.
- GenUI : aucun libre.
- Prisma : selon ADR.
- API : type calculation_mcq.
- Tests attendus : résultats déterministes.
- Validations à lancer : tests unitaires calcul.
- Critères d'acceptation : pas de calcul IA non vérifié.
- Critère de stop : impossibilité de valider les résultats.
- Risques : erreurs de calcul.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_021_CALCULATION_MCQ.md`.

### V1-022 — Image choice/personnages historiques V1-D

- Objectif : ajouter choix d'image avec assets contrôlés.
- Pourquoi maintenant : après stabilisation de la chaîne d'assets.
- Périmètre inclus : allowlist assets, alt text, droits.
- Non-objectifs : URL image libre générée par IA.
- Fichiers probablement concernés : storage/assets, activities.
- Backend : asset refs.
- Frontend : grille image accessible.
- Genkit : référence uniquement des assets autorisés.
- GenUI : aucun asset libre.
- Prisma : table asset possible.
- API : image_choice.
- Tests attendus : droits/allowlist, alt text obligatoire.
- Validations à lancer : tests targeted.
- Critères d'acceptation : aucun asset non allowlisté.
- Critère de stop : droits non clarifiés.
- Risques : copyright.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_022_IMAGE_CHOICE.md`.

### V1-023 — Runbook demo V1

- Objectif : documenter démo V1 de bout en bout.
- Pourquoi maintenant : fonctionnalités et seed V1 prêts.
- Périmètre inclus : runbook, smoke, scénario.
- Non-objectifs : déploiement prod.
- Fichiers probablement concernés : docs demo V1.
- Backend : commandes confirmées.
- Frontend : commandes confirmées.
- Genkit : config provider documentée.
- GenUI : limites documentées.
- Prisma : commandes non destructives.
- API : smoke.
- Tests attendus : docs diff check.
- Validations à lancer : git diff check, validations non destructives.
- Critères d'acceptation : démo rejouable.
- Critère de stop : commande non vérifiable présentée comme certaine.
- Risques : drift documentaire.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_023_DEMO_RUNBOOK_V1.md`.

### V1-024 — Polish UI/accessibilité/performance

- Objectif : rendre l'expérience V1 robuste et agréable.
- Pourquoi maintenant : les types principaux existent.
- Périmètre inclus : accessibilité, petits écrans, performance, états vides.
- Non-objectifs : nouveaux types.
- Fichiers probablement concernés : Flutter widgets activities.
- Backend : aucun sauf bug.
- Frontend : UI polish.
- Genkit : aucun.
- GenUI : aucun arbitraire.
- Prisma : aucun.
- API : aucun.
- Tests attendus : widget tests, screenshots si possible.
- Validations à lancer : analyze, flutter test.
- Critères d'acceptation : pas d'overflow, interactions accessibles.
- Critère de stop : refactor massif requis.
- Risques : dérive design.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_024_UI_ACCESSIBILITY_PERFORMANCE.md`.

### V1-025 — Revue finale V1 et readiness audit

- Objectif : auditer la readiness V1.
- Pourquoi maintenant : clôturer la roadmap.
- Périmètre inclus : audit produit, sécurité, tests, docs, démo.
- Non-objectifs : nouvelle feature.
- Fichiers probablement concernés : docs V1, tests smoke.
- Backend : vérification.
- Frontend : vérification.
- Genkit : vérification logs et prompts.
- GenUI : vérification catalogue borné.
- Prisma : migration status.
- API : e2e.
- Tests attendus : suite non destructive complète selon contexte.
- Validations à lancer : backend + frontend ciblés, build, diff check.
- Critères d'acceptation : V1 présentable et sûre.
- Critère de stop : fuite de correction, widget libre, tests critiques rouges.
- Risques : dette non documentée.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_025_READINESS_AUDIT.md`.

```
