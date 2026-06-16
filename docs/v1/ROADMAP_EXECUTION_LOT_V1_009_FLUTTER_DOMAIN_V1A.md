# LOT V1-009 — Domain models Flutter V1-A

## 1. Résultat

Le lot V1-009 est réalisé côté Flutter. Les modèles discriminés rich closed V1-A existent, les parsers pré-submit sont stricts et anti-fuite, les DTO de soumission sérialisent les six formes de réponse, les résultats post-submit parsèrent les corrections backend, et `HttpActivitiesApi` expose les quatre méthodes rich closed sans les brancher à l’UI.

## 2. Sources inspectées

- `revision_app/pubspec.yaml`
- `revision_app/lib/main.dart`
- `revision_app/lib/app/**`
- `revision_app/lib/core/**`
- `revision_app/lib/features/activities/**`
- `revision_app/lib/features/today/**`
- `revision_app/lib/features/revision_sessions/**`
- `revision_app/test/**`
- `revision_app/lib/features/activities/domain/diagnostic_quiz_activity.dart`
- `revision_app/lib/features/activities/domain/open_question_activity.dart`
- `revision_app/lib/features/activities/data/http_activities_api.dart`
- `revision_app/lib/features/activities/application/activity_controller.dart`
- `revision_app/lib/features/activities/data/demo_activity_api.dart`
- `revision_app/test/features/activities/http_activities_api_test.dart`
- `revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`
- `revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_007_PERSISTENCE_V1A.md`
- `revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_008_PUBLIC_API_V1A.md`
- `revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_008B_RICH_CLOSED_API_SCORING_HARDENING.md`

## 3. Préflight Git

`revision_app` :

```text
/Users/karim/Project/app-révision/revision_app
/Users/karim/Project/app-révision/revision_app
main
## main...origin/main
7f400b6 V1-008B — Ajout du rapport d'exécution du lot Hardening API/scoring rich closed V1-A et mise à jour du plan
fd7710c V1-007/V1-008 — Ajout des rapports d'exécution des lots Persistance minimale V1-A et API publique pré-submit/post-submit V1-A, mise à jour du plan
786d22b V1-006 — Ajout du rapport d'exécution du lot Génération Genkit rich closed questions V1-A et mise à jour du plan d'exécution
31cdf95 LOT_V1_005B_RICH_CLOSED_CONTRACT_HARDENING - Mise à jour plan V1 et ajout rapport LOT_V1_005B (Rich Closed Contract Hardening)
75bda98 LOT_V1_002_005 - Ajout ADR, audit DTO Prisma, roadmap V1 (lots 002 à 005 : rich questions, backend, qualité pédagogique)
```

Le repo `revision_app` était propre au préflight. Aucun fichier backend n’a été modifié et aucune commande n’a été lancée dans `api`.

## 4. Périmètre réalisé

- Ajout du domaine `RichClosedExercise` V1-A avec six variantes explicites.
- Ajout des enums bornées `questionKind`, `difficulty`, `cognitiveSkill` et `complexityProfile`.
- Ajout des réponses utilisateur `RichClosedAnswer` et du wrapper `RichClosedExerciseSubmission`.
- Ajout du parsing post-submit `RichClosedExerciseResult`, `RichClosedCorrectionItem` et corrections typées.
- Extension de `HttpActivitiesApi` avec start/get/submit/result rich closed.
- Ajout de fixtures et tests domain/HTTP.
- Mise à jour du plan V1.

## 5. Architecture retenue

Les modèles rich closed sont dans un fichier domaine dédié : `lib/features/activities/domain/rich_closed_exercise.dart`. Le contrat est discriminé par `RichClosedQuestionKind`, avec une classe explicite par type V1-A. Les parsers stricts vivent dans le domaine pour que toute consommation future, UI ou non, hérite du même garde-fou anti-fuite.

`HttpActivitiesApi` expose des méthodes publiques rich closed, mais `ActivityApi` et les contrôleurs UI existants ne sont pas étendus dans ce lot afin de ne pas brancher de comportement visible. Aucune route Flutter, page, Today ou session IA n’a été modifiée.

## 6. Contrat JSON supporté

Endpoints préparés :

- `POST /activities/rich-closed/start`
- `GET /activities/rich-closed/:sessionId`
- `POST /activities/rich-closed/:sessionId/submit`
- `GET /activities/rich-closed/:sessionId/result`

Payload start : `subjectId`, `knowledgeUnitId`, `questionCount`, `complexityProfile`, `documentId` seulement si non nul, `questionTypeMix` seulement si fourni.

Payload submit : `{ "answers": [...] }` avec une shape stricte par `questionKind`.

Payload result : `type = rich_closed_exercise`, `status = completed`, score backend, items corrigés et correction payload cohérent avec le type de question.

## 7. Anti-fuite

Le parser pré-submit rejette récursivement tout champ de correction ou semi-privé : `correct*`, `correction`, `correctionPayload`, `explanation`, `feedback`, `choiceFeedback`, `modelAnswer`, `answerText`, `freeTextAnswer`, `textAnswer`, `score`, `partialScore`, `workedSteps`, `expectedAnswer`, `expectedAnswers`.

Les `RichClosedChoice` pré-submit rejettent explicitement `feedback`. Les réponses utilisateur rejettent aussi les champs libres/correction et leur `toJson` ne produit que les champs attendus par le backend.

## 8. Fichiers créés/modifiés/supprimés

Fichiers créés :

- `revision_app/lib/features/activities/domain/rich_closed_exercise.dart`
- `revision_app/test/features/activities/fixtures/rich_closed_exercise_fixtures.dart`
- `revision_app/test/features/activities/rich_closed_exercise_test.dart`
- `revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_009_FLUTTER_DOMAIN_V1A.md`

Fichiers modifiés :

- `revision_app/lib/features/activities/data/http_activities_api.dart`
- `revision_app/test/features/activities/http_activities_api_test.dart`
- `revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`

Aucun fichier supprimé.

## 9. Tests ajoutés ou renforcés

- Parsing d’un exercice complet avec les six question kinds V1-A.
- Rejet des types hors V1-A.
- Rejet des champs de correction pré-submit, feedback, score, modelAnswer et answerText.
- Rejet des enums inconnues, bornes multiple choice incohérentes, IDs/labels vides.
- Sérialisation `toJson` des six réponses utilisateur et du wrapper submit.
- Parsing d’un résultat complet, des cinq formes de correction et des submitted answers.
- Rejet des résultats incohérents.
- Tests HTTP des quatre méthodes rich closed et des erreurs de parsing anti-fuite.

## 10. Validations lancées avec résultats

- `dart format <fichiers modifiés>` : OK, formatage ciblé uniquement.
- `flutter test test/features/activities --reporter compact` : premier passage KO sur constructeurs `const`, deuxième passage KO sur une assertion de test trop stricte, dernier passage OK.
- `dart analyze lib test` : premier passage avec infos de lint, dernier passage OK, aucun issue.
- `flutter test --reporter compact` : OK, suite complète verte.
- `git diff --check` : OK.

## 11. Validations non lancées avec justification

- Tests backend : non lancés, le lot interdit les commandes côté `api`.
- Commandes dans `api` : non lancées.
- `dart fix --apply` : non lancé, interdit.
- `dart format .` global : non lancé, formatage ciblé uniquement.
- App Flutter en mode manuel : non lancée, hors périmètre.
- Provider IA réel : non appelé.

## 12. Risques restants

- Les modèles ne sont pas encore branchés à une UI ; l’ergonomie des futures interactions sera traitée en V1-010/V1-011.
- `HttpActivitiesApi` expose les méthodes, mais l’interface `ActivityApi` n’est pas encore étendue pour éviter de brancher les contrôleurs existants trop tôt.
- La stratégie de rendu/correction devra rester alignée avec le parser strict pour ne pas réintroduire de tolérance dangereuse dans les widgets.

## 13. Recommandation prochain lot

Poursuivre avec `V1-010 — Widgets Flutter V1-A single/multiple/case/error`. Aucun mini-bis n’est nécessaire à ce stade si la revue accepte que `ActivityApi` reste inchangée jusqu’au branchement UI.

## 14. Passes de review

- Domain models : six classes V1-A explicites, enums bornées.
- JSON parsing : type/version/status stricts, result correction cohérent avec `questionKind`.
- Anti-fuite : rejet récursif des champs privés pré-submit et tests dédiés.
- HTTP API : routes et payloads conformes, pas de backend réel.
- Scope/no UI : aucune page, route, Today ou session IA modifiée.
- Tests : domain + HTTP + suite Flutter complète.

## 15. Critique honnête du prompt initial

Le prompt est très clair sur la séparation modèle/widgets. Le point le plus délicat est l’équilibre entre “API client prête” et “pas de branchement UI” : j’ai donc ajouté les méthodes sur `HttpActivitiesApi` sans étendre `ActivityApi`, pour éviter de modifier les contrôleurs/fakes UI hors périmètre. Les exigences anti-fuite sont nombreuses mais justifiées avant de construire les widgets.

## 16. Contenu complet des fichiers créés/modifiés/supprimés pour review

> Note : le rapport lui-même n’est pas auto-recopié dans sa propre section afin d’éviter une récursion documentaire infinie. Tous les autres fichiers créés/modifiés par le lot sont inclus en entier ci-dessous.

### revision_app/lib/features/activities/domain/rich_closed_exercise.dart

````dart
const richClosedExerciseType = 'rich_closed_exercise';
const richClosedExerciseVersion = 'rich-closed-question-v1';

class RichClosedExerciseParseException implements Exception {
  const RichClosedExerciseParseException(this.message);

  final String message;

  @override
  String toString() => 'RichClosedExerciseParseException: $message';
}

enum RichClosedQuestionKind {
  singleChoice('single_choice'),
  multipleChoice('multiple_choice'),
  matching('matching'),
  ordering('ordering'),
  caseQualification('case_qualification'),
  errorDetection('error_detection');

  const RichClosedQuestionKind(this.wireValue);

  final String wireValue;

  static RichClosedQuestionKind parse(Object? value) {
    for (final kind in values) {
      if (value == kind.wireValue) {
        return kind;
      }
    }

    throw const RichClosedExerciseParseException(
      'Invalid rich closed question kind',
    );
  }
}

enum RichClosedDifficulty {
  low('LOW'),
  medium('MEDIUM'),
  high('HIGH');

  const RichClosedDifficulty(this.wireValue);

  final String wireValue;

  static RichClosedDifficulty parse(Object? value) {
    for (final difficulty in values) {
      if (value == difficulty.wireValue) {
        return difficulty;
      }
    }

    throw const RichClosedExerciseParseException(
      'Invalid rich closed difficulty',
    );
  }
}

enum RichClosedCognitiveSkill {
  memorization('memorization'),
  comprehension('comprehension'),
  comparison('comparison'),
  classification('classification'),
  caseApplication('case_application'),
  procedure('procedure'),
  errorDetection('error_detection'),
  causality('causality');

  const RichClosedCognitiveSkill(this.wireValue);

  final String wireValue;

  static RichClosedCognitiveSkill parse(Object? value) {
    for (final skill in values) {
      if (value == skill.wireValue) {
        return skill;
      }
    }

    throw const RichClosedExerciseParseException(
      'Invalid rich closed cognitive skill',
    );
  }
}

enum RichClosedComplexityProfile {
  standard('standard'),
  exam('exam'),
  advanced('advanced');

  const RichClosedComplexityProfile(this.wireValue);

  final String wireValue;
}

class RichClosedExercise {
  const RichClosedExercise({
    required this.sessionId,
    required this.type,
    required this.id,
    required this.version,
    required this.title,
    required this.subjectId,
    required this.documentId,
    required this.knowledgeUnitId,
    required this.questions,
  });

  factory RichClosedExercise.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed exercise response');
    _assertNoPreSubmitLeaks(json);

    final type = _readString(json['type'], 'Invalid rich closed exercise type');
    final version = _readString(
      json['version'],
      'Invalid rich closed exercise version',
    );
    final questions = _readList(
      json['questions'],
      'Invalid rich closed exercise questions',
    );

    if (type != richClosedExerciseType ||
        version != richClosedExerciseVersion) {
      throw const RichClosedExerciseParseException(
        'Invalid rich closed exercise envelope',
      );
    }

    if (questions.isEmpty) {
      throw const RichClosedExerciseParseException(
        'Rich closed exercise must contain questions',
      );
    }

    return RichClosedExercise(
      sessionId: _readString(
        json['sessionId'],
        'Invalid rich closed exercise session id',
      ),
      type: type,
      id: _readString(json['id'], 'Invalid rich closed exercise id'),
      version: version,
      title: _readString(json['title'], 'Invalid rich closed exercise title'),
      subjectId: _readString(
        json['subjectId'],
        'Invalid rich closed exercise subject id',
      ),
      documentId: _readOptionalString(json['documentId']),
      knowledgeUnitId: _readString(
        json['knowledgeUnitId'],
        'Invalid rich closed exercise knowledge unit id',
      ),
      questions: questions
          .map(RichClosedQuestion.fromJson)
          .toList(growable: false),
    );
  }

  final String sessionId;
  final String type;
  final String id;
  final String version;
  final String title;
  final String subjectId;
  final String? documentId;
  final String knowledgeUnitId;
  final List<RichClosedQuestion> questions;
}

sealed class RichClosedQuestion {
  const RichClosedQuestion({
    required this.id,
    required this.questionKind,
    required this.prompt,
    required this.difficulty,
    required this.cognitiveSkill,
    required this.sourceChunkIds,
  });

  factory RichClosedQuestion.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed question response');
    final kind = RichClosedQuestionKind.parse(json['questionKind']);
    final base = RichClosedQuestionBase.fromJson(json, kind);

    return switch (kind) {
      RichClosedQuestionKind.singleChoice => RichClosedSingleChoiceQuestion(
        base: base,
        choices: _choices(json['choices']),
      ),
      RichClosedQuestionKind.multipleChoice => RichClosedMultipleChoiceQuestion(
        base: base,
        choices: _choices(json['choices']),
        minSelections: _readInt(
          json['minSelections'],
          'Invalid multiple choice min selections',
        ),
        maxSelections: _readInt(
          json['maxSelections'],
          'Invalid multiple choice max selections',
        ),
      ).._validateSelectionBounds(),
      RichClosedQuestionKind.matching => RichClosedMatchingQuestion(
        base: base,
        leftItems: _labelItems(json['leftItems'], 'Invalid matching left'),
        rightItems: _labelItems(json['rightItems'], 'Invalid matching right'),
      ),
      RichClosedQuestionKind.ordering => RichClosedOrderingQuestion(
        base: base,
        items: _labelItems(json['items'], 'Invalid ordering items'),
      ),
      RichClosedQuestionKind.caseQualification =>
        RichClosedCaseQualificationQuestion(
          base: base,
          caseText: _readString(
            json['caseText'],
            'Invalid case qualification text',
          ),
          choices: _choices(json['choices']),
        ),
      RichClosedQuestionKind.errorDetection => RichClosedErrorDetectionQuestion(
        base: base,
        statement: _readString(
          json['statement'],
          'Invalid error detection statement',
        ),
        errorOptions: _choices(json['errorOptions']),
      ),
    };
  }

  final String id;
  final RichClosedQuestionKind questionKind;
  final String prompt;
  final RichClosedDifficulty difficulty;
  final RichClosedCognitiveSkill cognitiveSkill;
  final List<String> sourceChunkIds;
}

class RichClosedSingleChoiceQuestion extends RichClosedQuestion {
  RichClosedSingleChoiceQuestion({
    required RichClosedQuestionBase base,
    required this.choices,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.singleChoice,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final List<RichClosedChoice> choices;
}

class RichClosedMultipleChoiceQuestion extends RichClosedQuestion {
  RichClosedMultipleChoiceQuestion({
    required RichClosedQuestionBase base,
    required this.choices,
    required this.minSelections,
    required this.maxSelections,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.multipleChoice,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final List<RichClosedChoice> choices;
  final int minSelections;
  final int maxSelections;

  void _validateSelectionBounds() {
    if (minSelections < 1 ||
        maxSelections < minSelections ||
        maxSelections > choices.length) {
      throw const RichClosedExerciseParseException(
        'Invalid multiple choice selection bounds',
      );
    }
  }
}

class RichClosedMatchingQuestion extends RichClosedQuestion {
  RichClosedMatchingQuestion({
    required RichClosedQuestionBase base,
    required this.leftItems,
    required this.rightItems,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.matching,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final List<RichClosedLabelItem> leftItems;
  final List<RichClosedLabelItem> rightItems;
}

class RichClosedOrderingQuestion extends RichClosedQuestion {
  RichClosedOrderingQuestion({
    required RichClosedQuestionBase base,
    required this.items,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.ordering,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final List<RichClosedLabelItem> items;
}

class RichClosedCaseQualificationQuestion extends RichClosedQuestion {
  RichClosedCaseQualificationQuestion({
    required RichClosedQuestionBase base,
    required this.caseText,
    required this.choices,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.caseQualification,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final String caseText;
  final List<RichClosedChoice> choices;
}

class RichClosedErrorDetectionQuestion extends RichClosedQuestion {
  RichClosedErrorDetectionQuestion({
    required RichClosedQuestionBase base,
    required this.statement,
    required this.errorOptions,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.errorDetection,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final String statement;
  final List<RichClosedChoice> errorOptions;
}

class RichClosedQuestionBase {
  const RichClosedQuestionBase({
    required this.id,
    required this.prompt,
    required this.difficulty,
    required this.cognitiveSkill,
    required this.sourceChunkIds,
  });

  factory RichClosedQuestionBase.fromJson(
    Map<String, Object?> json,
    RichClosedQuestionKind kind,
  ) {
    return RichClosedQuestionBase(
      id: _readString(json['id'], 'Invalid rich closed question id'),
      prompt: _readString(
        json['prompt'],
        'Invalid rich closed question prompt',
      ),
      difficulty: RichClosedDifficulty.parse(json['difficulty']),
      cognitiveSkill: RichClosedCognitiveSkill.parse(json['cognitiveSkill']),
      sourceChunkIds: _stringList(
        json['sourceChunkIds'],
        'Invalid rich closed source chunk ids',
      ),
    );
  }

  final String id;
  final String prompt;
  final RichClosedDifficulty difficulty;
  final RichClosedCognitiveSkill cognitiveSkill;
  final List<String> sourceChunkIds;
}

class RichClosedChoice {
  const RichClosedChoice({required this.id, required this.label});

  factory RichClosedChoice.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed choice');
    if (json.containsKey('feedback')) {
      throw const RichClosedExerciseParseException(
        'Rich closed pre-submit choices cannot contain feedback',
      );
    }

    return RichClosedChoice(
      id: _readString(json['id'], 'Invalid rich closed choice id'),
      label: _readString(json['label'], 'Invalid rich closed choice label'),
    );
  }

  final String id;
  final String label;
}

class RichClosedLabelItem {
  const RichClosedLabelItem({required this.id, required this.label});

  factory RichClosedLabelItem.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed label item');

    return RichClosedLabelItem(
      id: _readString(json['id'], 'Invalid rich closed label item id'),
      label: _readString(json['label'], 'Invalid rich closed label item label'),
    );
  }

  final String id;
  final String label;
}

class RichClosedPair {
  const RichClosedPair({required this.leftId, required this.rightId});

  factory RichClosedPair.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed pair');

    return RichClosedPair(
      leftId: _readString(json['leftId'], 'Invalid rich closed pair left id'),
      rightId: _readString(
        json['rightId'],
        'Invalid rich closed pair right id',
      ),
    );
  }

  Map<String, Object?> toJson() => {'leftId': leftId, 'rightId': rightId};

  final String leftId;
  final String rightId;
}

sealed class RichClosedAnswer {
  const RichClosedAnswer({
    required this.questionId,
    required this.questionKind,
  });

  factory RichClosedAnswer.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed answer');
    _assertNoAnswerLeaks(json);

    final questionId = _readString(json['questionId'], 'Invalid answer id');
    final kind = RichClosedQuestionKind.parse(json['questionKind']);

    return switch (kind) {
      RichClosedQuestionKind.singleChoice => RichClosedSingleChoiceAnswer(
        questionId: questionId,
        choiceId: _readString(json['choiceId'], 'Invalid single choice answer'),
      ),
      RichClosedQuestionKind.multipleChoice => RichClosedMultipleChoiceAnswer(
        questionId: questionId,
        choiceIds: _nonEmptyStringList(
          json['choiceIds'],
          'Invalid multiple choice answer',
        ),
      ),
      RichClosedQuestionKind.matching => RichClosedMatchingAnswer(
        questionId: questionId,
        pairs: _pairs(json['pairs']),
      ),
      RichClosedQuestionKind.ordering => RichClosedOrderingAnswer(
        questionId: questionId,
        orderedIds: _nonEmptyStringList(
          json['orderedIds'],
          'Invalid ordering answer',
        ),
      ),
      RichClosedQuestionKind.caseQualification =>
        RichClosedCaseQualificationAnswer(
          questionId: questionId,
          choiceId: _readString(
            json['choiceId'],
            'Invalid case qualification answer',
          ),
        ),
      RichClosedQuestionKind.errorDetection => RichClosedErrorDetectionAnswer(
        questionId: questionId,
        errorId: _readString(json['errorId'], 'Invalid error detection answer'),
      ),
    };
  }

  final String questionId;
  final RichClosedQuestionKind questionKind;

  Map<String, Object?> toJson();
}

class RichClosedSingleChoiceAnswer extends RichClosedAnswer {
  const RichClosedSingleChoiceAnswer({
    required super.questionId,
    required this.choiceId,
  }) : super(questionKind: RichClosedQuestionKind.singleChoice);

  final String choiceId;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'choiceId': choiceId,
  };
}

class RichClosedMultipleChoiceAnswer extends RichClosedAnswer {
  const RichClosedMultipleChoiceAnswer({
    required super.questionId,
    required this.choiceIds,
  }) : super(questionKind: RichClosedQuestionKind.multipleChoice);

  final List<String> choiceIds;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'choiceIds': choiceIds,
  };
}

class RichClosedMatchingAnswer extends RichClosedAnswer {
  const RichClosedMatchingAnswer({
    required super.questionId,
    required this.pairs,
  }) : super(questionKind: RichClosedQuestionKind.matching);

  final List<RichClosedPair> pairs;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'pairs': [for (final pair in pairs) pair.toJson()],
  };
}

class RichClosedOrderingAnswer extends RichClosedAnswer {
  const RichClosedOrderingAnswer({
    required super.questionId,
    required this.orderedIds,
  }) : super(questionKind: RichClosedQuestionKind.ordering);

  final List<String> orderedIds;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'orderedIds': orderedIds,
  };
}

class RichClosedCaseQualificationAnswer extends RichClosedAnswer {
  const RichClosedCaseQualificationAnswer({
    required super.questionId,
    required this.choiceId,
  }) : super(questionKind: RichClosedQuestionKind.caseQualification);

  final String choiceId;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'choiceId': choiceId,
  };
}

class RichClosedErrorDetectionAnswer extends RichClosedAnswer {
  const RichClosedErrorDetectionAnswer({
    required super.questionId,
    required this.errorId,
  }) : super(questionKind: RichClosedQuestionKind.errorDetection);

  final String errorId;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'errorId': errorId,
  };
}

class RichClosedExerciseSubmission {
  const RichClosedExerciseSubmission({required this.answers});

  final List<RichClosedAnswer> answers;

  Map<String, Object?> toJson() => {
    'answers': [for (final answer in answers) answer.toJson()],
  };
}

class RichClosedExerciseResult {
  const RichClosedExerciseResult({
    required this.sessionId,
    required this.type,
    required this.status,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.score,
    required this.items,
  });

  factory RichClosedExerciseResult.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed result response');
    final type = _readString(json['type'], 'Invalid rich closed result type');
    final status = _readString(
      json['status'],
      'Invalid rich closed result status',
    );
    final score = json['score'];

    if (type != richClosedExerciseType || status != 'completed') {
      throw const RichClosedExerciseParseException(
        'Invalid rich closed result envelope',
      );
    }

    if (score is! num) {
      throw const RichClosedExerciseParseException(
        'Invalid rich closed result score',
      );
    }

    return RichClosedExerciseResult(
      sessionId: _readString(json['sessionId'], 'Invalid result session id'),
      type: type,
      status: status,
      correctAnswers: _readInt(
        json['correctAnswers'],
        'Invalid result correct answers',
      ),
      totalQuestions: _readInt(
        json['totalQuestions'],
        'Invalid result total questions',
      ),
      score: score.toDouble(),
      items: _readList(
        json['items'],
        'Invalid rich closed result items',
      ).map(RichClosedCorrectionItem.fromJson).toList(growable: false),
    );
  }

  final String sessionId;
  final String type;
  final String status;
  final int correctAnswers;
  final int totalQuestions;
  final double score;
  final List<RichClosedCorrectionItem> items;
}

class RichClosedCorrectionItem {
  const RichClosedCorrectionItem({
    required this.questionId,
    required this.questionKind,
    required this.prompt,
    required this.submittedAnswer,
    required this.isCorrect,
    required this.partialScore,
    required this.explanation,
    required this.sourceChunkIds,
    required this.correction,
  });

  factory RichClosedCorrectionItem.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed correction item');
    final kind = RichClosedQuestionKind.parse(json['questionKind']);
    final partialScore = json['partialScore'];

    if (partialScore is! num) {
      throw const RichClosedExerciseParseException(
        'Invalid rich closed correction partial score',
      );
    }

    return RichClosedCorrectionItem(
      questionId: _readString(json['questionId'], 'Invalid correction id'),
      questionKind: kind,
      prompt: _readString(json['prompt'], 'Invalid correction prompt'),
      submittedAnswer: RichClosedAnswer.fromJson(json['submittedAnswer']),
      isCorrect: _readBool(json['isCorrect'], 'Invalid correction status'),
      partialScore: partialScore.toDouble(),
      explanation: _readString(
        json['explanation'],
        'Invalid correction explanation',
      ),
      sourceChunkIds: _stringList(
        json['sourceChunkIds'],
        'Invalid correction sources',
      ),
      correction: RichClosedCorrectionPayload.fromJson(
        kind,
        json['correction'],
      ),
    );
  }

  final String questionId;
  final RichClosedQuestionKind questionKind;
  final String prompt;
  final RichClosedAnswer submittedAnswer;
  final bool isCorrect;
  final double partialScore;
  final String explanation;
  final List<String> sourceChunkIds;
  final RichClosedCorrectionPayload correction;
}

sealed class RichClosedCorrectionPayload {
  const RichClosedCorrectionPayload();

  factory RichClosedCorrectionPayload.fromJson(
    RichClosedQuestionKind kind,
    Object? value,
  ) {
    final json = _readObject(value, 'Invalid rich closed correction payload');

    return switch (kind) {
      RichClosedQuestionKind.singleChoice ||
      RichClosedQuestionKind.caseQualification =>
        RichClosedCorrectChoiceIdCorrection(
          correctChoiceId: _readString(
            json['correctChoiceId'],
            'Invalid correct choice id',
          ),
        ),
      RichClosedQuestionKind.multipleChoice =>
        RichClosedCorrectChoiceIdsCorrection(
          correctChoiceIds: _nonEmptyStringList(
            json['correctChoiceIds'],
            'Invalid correct choice ids',
          ),
        ),
      RichClosedQuestionKind.matching => RichClosedCorrectPairsCorrection(
        correctPairs: _pairs(json['correctPairs']),
      ),
      RichClosedQuestionKind.ordering => RichClosedCorrectOrderCorrection(
        correctOrder: _nonEmptyStringList(
          json['correctOrder'],
          'Invalid correct order',
        ),
      ),
      RichClosedQuestionKind.errorDetection =>
        RichClosedCorrectErrorIdCorrection(
          correctErrorId: _readString(
            json['correctErrorId'],
            'Invalid correct error id',
          ),
        ),
    };
  }
}

class RichClosedCorrectChoiceIdCorrection extends RichClosedCorrectionPayload {
  const RichClosedCorrectChoiceIdCorrection({required this.correctChoiceId});

  final String correctChoiceId;
}

class RichClosedCorrectChoiceIdsCorrection extends RichClosedCorrectionPayload {
  const RichClosedCorrectChoiceIdsCorrection({required this.correctChoiceIds});

  final List<String> correctChoiceIds;
}

class RichClosedCorrectPairsCorrection extends RichClosedCorrectionPayload {
  const RichClosedCorrectPairsCorrection({required this.correctPairs});

  final List<RichClosedPair> correctPairs;
}

class RichClosedCorrectOrderCorrection extends RichClosedCorrectionPayload {
  const RichClosedCorrectOrderCorrection({required this.correctOrder});

  final List<String> correctOrder;
}

class RichClosedCorrectErrorIdCorrection extends RichClosedCorrectionPayload {
  const RichClosedCorrectErrorIdCorrection({required this.correctErrorId});

  final String correctErrorId;
}

List<RichClosedChoice> _choices(Object? value) {
  final choices = _readList(
    value,
    'Invalid rich closed choices',
  ).map(RichClosedChoice.fromJson).toList(growable: false);

  if (choices.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Rich closed choices cannot be empty',
    );
  }

  return choices;
}

List<RichClosedLabelItem> _labelItems(Object? value, String message) {
  final items = _readList(
    value,
    message,
  ).map(RichClosedLabelItem.fromJson).toList(growable: false);

  if (items.isEmpty) {
    throw RichClosedExerciseParseException(message);
  }

  return items;
}

List<RichClosedPair> _pairs(Object? value) {
  final pairs = _readList(
    value,
    'Invalid rich closed pairs',
  ).map(RichClosedPair.fromJson).toList(growable: false);

  if (pairs.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Rich closed pairs cannot be empty',
    );
  }

  return pairs;
}

Map<String, Object?> _readObject(Object? value, String message) {
  if (value is Map<String, Object?>) {
    return value;
  }

  throw RichClosedExerciseParseException(message);
}

List<Object?> _readList(Object? value, String message) {
  if (value is List) {
    return value.cast<Object?>();
  }

  throw RichClosedExerciseParseException(message);
}

String _readString(Object? value, String message) {
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }

  throw RichClosedExerciseParseException(message);
}

String? _readOptionalString(Object? value) {
  if (value == null) {
    return null;
  }

  return _readString(value, 'Invalid optional rich closed string');
}

int _readInt(Object? value, String message) {
  if (value is int) {
    return value;
  }

  throw RichClosedExerciseParseException(message);
}

bool _readBool(Object? value, String message) {
  if (value is bool) {
    return value;
  }

  throw RichClosedExerciseParseException(message);
}

List<String> _stringList(Object? value, String message) {
  return _readList(
    value,
    message,
  ).map((item) => _readString(item, message)).toList(growable: false);
}

List<String> _nonEmptyStringList(Object? value, String message) {
  final values = _stringList(value, message);
  if (values.isEmpty) {
    throw RichClosedExerciseParseException(message);
  }

  return values;
}

void _assertNoPreSubmitLeaks(Object? value) {
  if (_containsForbiddenPreSubmitField(value)) {
    throw const RichClosedExerciseParseException(
      'Rich closed pre-submit payload contains correction data',
    );
  }
}

void _assertNoAnswerLeaks(Object? value) {
  if (_containsForbiddenAnswerField(value)) {
    throw const RichClosedExerciseParseException(
      'Rich closed answer payload contains forbidden data',
    );
  }
}

bool _containsForbiddenPreSubmitField(Object? value) {
  return _containsForbiddenField(value, _forbiddenPreSubmitKeys);
}

bool _containsForbiddenAnswerField(Object? value) {
  return _containsForbiddenField(value, _forbiddenAnswerKeys);
}

bool _containsForbiddenField(Object? value, Set<String> forbiddenKeys) {
  if (value is List) {
    return value.any((item) => _containsForbiddenField(item, forbiddenKeys));
  }

  if (value is! Map) {
    return false;
  }

  for (final entry in value.entries) {
    final key = entry.key;
    if (key is String &&
        (key.startsWith('correct') || forbiddenKeys.contains(key))) {
      return true;
    }

    if (_containsForbiddenField(entry.value, forbiddenKeys)) {
      return true;
    }
  }

  return false;
}

const _forbiddenPreSubmitKeys = {
  'correctionPayload',
  'correction',
  'explanation',
  'feedback',
  'choiceFeedback',
  'modelAnswer',
  'answerText',
  'freeTextAnswer',
  'textAnswer',
  'score',
  'partialScore',
  'workedSteps',
  'expectedAnswer',
  'expectedAnswers',
};

const _forbiddenAnswerKeys = {
  'correctionPayload',
  'correction',
  'explanation',
  'feedback',
  'choiceFeedback',
  'modelAnswer',
  'answerText',
  'freeTextAnswer',
  'textAnswer',
  'score',
  'partialScore',
  'workedSteps',
  'expectedAnswer',
  'expectedAnswers',
};
````

### revision_app/lib/features/activities/data/http_activities_api.dart

````dart
import 'package:dio/dio.dart';

import '../application/activity_controller.dart';
import '../domain/diagnostic_quiz_activity.dart';
import '../domain/open_question_activity.dart';
import '../domain/rich_closed_exercise.dart';

class HttpActivitiesApi implements ActivityApi {
  HttpActivitiesApi({
    required Dio dio,
    required Future<String> Function() getIdToken,
  }) : this._(dio, getIdToken);

  const HttpActivitiesApi._(this._dio, this._getIdToken);

  final Dio _dio;
  final Future<String> Function() _getIdToken;

  @override
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) async {
    final data = <String, Object>{
      'subjectId': subjectId,
      'selectionModes': ['single', 'multiple'],
      'visualsEnabled': true,
      'visualTypes': ['CHART', 'DIAGRAM'],
    };
    if (knowledgeUnitId != null) {
      data['knowledgeUnitId'] = knowledgeUnitId;
    }

    final response = await _dio.post<Object?>(
      '/activities/next',
      data: data,
      options: await _authorizedOptions(),
    );

    return _ActivityJson(response.data).toActivity();
  }

  @override
  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  }) async {
    final response = await _dio.post<Object?>(
      '/activities/$sessionId/result',
      data: {
        'answers': [for (final answer in answers) _AnswerJson(answer).toJson()],
      },
      options: await _authorizedOptions(),
    );

    return _ResultJson(response.data).toResult();
  }

  @override
  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) async {
    final response = await _dio.post<Object?>(
      '/activities/open-question',
      data: {'subjectId': subjectId, 'knowledgeUnitId': knowledgeUnitId},
      options: await _authorizedOptions(),
    );

    return _OpenQuestionActivityJson(response.data).toActivity();
  }

  @override
  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  }) async {
    final response = await _dio.post<Object?>(
      '/activities/$sessionId/open-answer',
      data: {'answerText': answerText},
      options: await _authorizedOptions(),
    );

    return _OpenAnswerSubmissionJson(response.data).toResult();
  }

  Future<RichClosedExercise> startRichClosedExercise({
    required String subjectId,
    required String knowledgeUnitId,
    String? documentId,
    int questionCount = 6,
    RichClosedComplexityProfile complexityProfile =
        RichClosedComplexityProfile.exam,
    Map<RichClosedQuestionKind, int>? questionTypeMix,
  }) async {
    final data = <String, Object?>{
      'subjectId': subjectId,
      'knowledgeUnitId': knowledgeUnitId,
      'questionCount': questionCount,
      'complexityProfile': complexityProfile.wireValue,
    };

    if (documentId != null) {
      data['documentId'] = documentId;
    }

    if (questionTypeMix != null) {
      data['questionTypeMix'] = {
        for (final entry in questionTypeMix.entries)
          entry.key.wireValue: entry.value,
      };
    }

    final response = await _dio.post<Object?>(
      '/activities/rich-closed/start',
      data: data,
      options: await _authorizedOptions(),
    );

    return RichClosedExercise.fromJson(response.data);
  }

  Future<RichClosedExercise> getRichClosedExercise(String sessionId) async {
    final response = await _dio.get<Object?>(
      '/activities/rich-closed/$sessionId',
      options: await _authorizedOptions(),
    );

    return RichClosedExercise.fromJson(response.data);
  }

  Future<RichClosedExerciseResult> submitRichClosedExercise({
    required String sessionId,
    required List<RichClosedAnswer> answers,
  }) async {
    final response = await _dio.post<Object?>(
      '/activities/rich-closed/$sessionId/submit',
      data: RichClosedExerciseSubmission(answers: answers).toJson(),
      options: await _authorizedOptions(),
    );

    return RichClosedExerciseResult.fromJson(response.data);
  }

  Future<RichClosedExerciseResult> getRichClosedExerciseResult(
    String sessionId,
  ) async {
    final response = await _dio.get<Object?>(
      '/activities/rich-closed/$sessionId/result',
      options: await _authorizedOptions(),
    );

    return RichClosedExerciseResult.fromJson(response.data);
  }

  Future<Options> _authorizedOptions() async {
    final token = (await _getIdToken()).trim();

    if (token.isEmpty) {
      throw StateError('A Firebase ID token is required for activities');
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }
}

class _ActivityJson {
  const _ActivityJson(this.value);

  final Object? value;

  DiagnosticQuizActivity toActivity() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid activity response');
    }

    final sessionId = json['sessionId'];
    final type = json['type'];
    final version = json['version'];
    final title = json['title'];
    final documentId = json['documentId'];
    final subjectId = json['subjectId'];
    final questions = json['questions'];

    if (sessionId is! String || title is! String || questions is! List) {
      throw const FormatException('Invalid activity response');
    }

    return DiagnosticQuizActivity(
      sessionId: sessionId,
      type: type is String ? type : 'diagnostic_quiz',
      version: version is int ? version : null,
      title: title,
      documentId: documentId is String ? documentId : null,
      subjectId: subjectId is String ? subjectId : null,
      questions: questions
          .map((question) => _QuestionJson(question).toQuestion())
          .toList(growable: false),
    );
  }
}

class _QuestionJson {
  const _QuestionJson(this.value);

  final Object? value;

  DiagnosticQuizQuestion toQuestion() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid question response');
    }

    final id = json['id'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final prompt = json['prompt'];
    final difficulty = json['difficulty'];
    final choices = json['choices'];
    final sources = json['sources'];
    final visuals = json['visuals'];

    if (id is! String || prompt is! String || choices is! List) {
      throw const FormatException('Invalid question response');
    }

    final parsedChoices = choices
        .map((choice) => _ChoiceJson(choice).toChoice())
        .toList(growable: false);
    final selectionMode = _selectionMode(json['selectionMode']);
    final minSelections = _selectionCount(
      json['minSelections'],
      fallback: 1,
      fieldName: 'minSelections',
    );
    final maxSelections = _selectionCount(
      json['maxSelections'],
      fallback: selectionMode == DiagnosticQuizSelectionMode.multiple
          ? parsedChoices.length
          : 1,
      fieldName: 'maxSelections',
    );

    if (selectionMode == DiagnosticQuizSelectionMode.multiple &&
        (minSelections < 1 ||
            maxSelections < minSelections ||
            maxSelections > parsedChoices.length)) {
      throw const FormatException('Invalid question selection response');
    }

    final parsedVisuals = <DiagnosticQuizVisual>[];
    if (visuals is List) {
      parsedVisuals.addAll([
        for (final (index, visual) in visuals.indexed)
          _VisualJson(visual, index).toVisual(),
      ]);
      parsedVisuals.sort(
        (left, right) => left.displayOrder.compareTo(right.displayOrder),
      );
    }

    return DiagnosticQuizQuestion(
      id: id,
      knowledgeUnitId: knowledgeUnitId is String ? knowledgeUnitId : null,
      prompt: prompt,
      difficulty: difficulty is String ? difficulty : null,
      selectionMode: selectionMode,
      minSelections: selectionMode == DiagnosticQuizSelectionMode.multiple
          ? minSelections
          : 1,
      maxSelections: selectionMode == DiagnosticQuizSelectionMode.multiple
          ? maxSelections
          : 1,
      choices: parsedChoices,
      sources: sources is List
          ? sources
                .map((source) => _SourceRefJson(source).toSourceRef())
                .toList(growable: false)
          : const [],
      visuals: parsedVisuals,
    );
  }

  DiagnosticQuizSelectionMode _selectionMode(Object? value) {
    if (value == null || value == 'single') {
      return DiagnosticQuizSelectionMode.single;
    }

    if (value == 'multiple') {
      return DiagnosticQuizSelectionMode.multiple;
    }

    throw const FormatException('Invalid question selection response');
  }

  int _selectionCount(
    Object? value, {
    required int fallback,
    required String fieldName,
  }) {
    if (value == null) {
      return fallback;
    }

    if (value is int) {
      return value;
    }

    throw FormatException('Invalid question selection response: $fieldName');
  }
}

class _ChoiceJson {
  const _ChoiceJson(this.value);

  final Object? value;

  DiagnosticQuizChoice toChoice() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid choice response');
    }

    final id = json['id'];
    final label = json['label'];

    if (id is! String || label is! String) {
      throw const FormatException('Invalid choice response');
    }

    return DiagnosticQuizChoice(id: id, label: label);
  }
}

class _VisualJson {
  const _VisualJson(this.value, this.fallbackIndex);

  final Object? value;
  final int fallbackIndex;

  DiagnosticQuizVisual toVisual() {
    final json = value;

    if (json is! Map<String, Object?>) {
      return _unsupported('UNKNOWN');
    }

    final type = json['type'];
    if (type is! String) {
      return _unsupported('UNKNOWN', json: json);
    }

    return switch (type) {
      'CHART' => _chart(json),
      'DIAGRAM' => _diagram(json),
      _ => _unsupported(type, json: json),
    };
  }

  DiagnosticQuizVisual _chart(Map<String, Object?> json) {
    try {
      final id = _id(json);
      final displayOrder = _displayOrder(json);
      final chartType = _chartType(json['chartType']);
      final title = json['title'];
      final description = json['description'];
      final data = json['data'];
      final xKey = json['xKey'];
      final yKeys = json['yKeys'];
      final sources = json['sources'];

      if (title is! String || data is! List) {
        return _unsupported('CHART', json: json);
      }

      return DiagnosticQuizChartVisual(
        id: id,
        displayOrder: displayOrder,
        chartType: chartType,
        title: title,
        description: description is String ? description : null,
        data: data.map(_chartRow).toList(growable: false),
        xKey: xKey is String ? xKey : null,
        yKeys: yKeys is List ? _stringList(yKeys) : const [],
        sources: sources is List ? _sourceRefs(sources) : const [],
      );
    } on FormatException {
      return _unsupported('CHART', json: json);
    }
  }

  DiagnosticQuizVisual _diagram(Map<String, Object?> json) {
    try {
      final id = _id(json);
      final displayOrder = _displayOrder(json);
      final title = json['title'];
      final description = json['description'];
      final nodes = json['nodes'];
      final edges = json['edges'];
      final sources = json['sources'];

      if (title is! String || nodes is! List) {
        return _unsupported('DIAGRAM', json: json);
      }

      return DiagnosticQuizDiagramVisual(
        id: id,
        displayOrder: displayOrder,
        title: title,
        description: description is String ? description : null,
        nodes: nodes.map(_diagramNode).toList(growable: false),
        edges: edges is List
            ? edges.map(_diagramEdge).toList(growable: false)
            : const [],
        sources: sources is List ? _sourceRefs(sources) : const [],
      );
    } on FormatException {
      return _unsupported('DIAGRAM', json: json);
    }
  }

  DiagnosticQuizUnsupportedVisual _unsupported(
    String type, {
    Map<String, Object?>? json,
  }) {
    final sources = json?['sources'];

    return DiagnosticQuizUnsupportedVisual(
      id: json == null ? 'visual-$fallbackIndex' : _safeId(json),
      displayOrder: json == null ? fallbackIndex : _safeDisplayOrder(json),
      type: type,
      sources: sources is List ? _safeSourceRefs(sources) : const [],
    );
  }

  String _id(Map<String, Object?> json) {
    final id = json['id'];
    if (id is String && id.trim().isNotEmpty) {
      return id;
    }

    throw const FormatException('Invalid visual response');
  }

  String _safeId(Map<String, Object?> json) {
    final id = json['id'];
    return id is String && id.trim().isNotEmpty ? id : 'visual-$fallbackIndex';
  }

  int _displayOrder(Map<String, Object?> json) {
    final displayOrder = json['displayOrder'];
    if (displayOrder == null) {
      return fallbackIndex;
    }

    if (displayOrder is int) {
      return displayOrder;
    }

    throw const FormatException('Invalid visual response');
  }

  int _safeDisplayOrder(Map<String, Object?> json) {
    final displayOrder = json['displayOrder'];
    return displayOrder is int ? displayOrder : fallbackIndex;
  }

  DiagnosticQuizChartType _chartType(Object? value) {
    return switch (value) {
      'bar' => DiagnosticQuizChartType.bar,
      'line' => DiagnosticQuizChartType.line,
      'pie' => DiagnosticQuizChartType.pie,
      'scatter' => DiagnosticQuizChartType.scatter,
      _ => throw const FormatException('Invalid chart visual response'),
    };
  }

  Map<String, Object?> _chartRow(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid chart visual response');
    }

    return json.map((key, value) {
      if (value == null || value is String || value is num) {
        return MapEntry(key, value);
      }

      throw const FormatException('Invalid chart visual response');
    });
  }

  DiagnosticQuizDiagramNode _diagramNode(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid diagram visual response');
    }

    final id = json['id'];
    final label = json['label'];
    if (id is! String || label is! String) {
      throw const FormatException('Invalid diagram visual response');
    }

    return DiagnosticQuizDiagramNode(id: id, label: label);
  }

  DiagnosticQuizDiagramEdge _diagramEdge(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid diagram visual response');
    }

    final from = json['from'];
    final to = json['to'];
    final label = json['label'];
    if (from is! String || to is! String) {
      throw const FormatException('Invalid diagram visual response');
    }

    return DiagnosticQuizDiagramEdge(
      from: from,
      to: to,
      label: label is String ? label : null,
    );
  }

  List<String> _stringList(List<Object?> values) {
    return values
        .map((value) {
          if (value is String) {
            return value;
          }

          throw const FormatException('Invalid visual response');
        })
        .toList(growable: false);
  }

  List<DiagnosticQuizSourceRef> _sourceRefs(List<Object?> values) {
    return values
        .map((source) => _SourceRefJson(source).toSourceRef())
        .toList(growable: false);
  }

  List<DiagnosticQuizSourceRef> _safeSourceRefs(List<Object?> values) {
    try {
      return _sourceRefs(values);
    } on FormatException {
      return const [];
    }
  }
}

class _SourceRefJson {
  const _SourceRefJson(this.value);

  final Object? value;

  DiagnosticQuizSourceRef toSourceRef() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid question source response');
    }

    final chunkId = json['chunkId'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || index is! int) {
      throw const FormatException('Invalid question source response');
    }

    return DiagnosticQuizSourceRef(
      chunkId: chunkId,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

class _AnswerJson {
  const _AnswerJson(this.answer);

  final DiagnosticQuizAnswer answer;

  Map<String, Object?> toJson() {
    final choiceId = answer.choiceId;
    if (choiceId != null) {
      return {'questionId': answer.questionId, 'choiceId': choiceId};
    }

    return {'questionId': answer.questionId, 'choiceIds': answer.choiceIds};
  }
}

class _ResultJson {
  const _ResultJson(this.value);

  final Object? value;

  DiagnosticQuizResult toResult() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid activity result response');
    }

    final correctAnswers = json['correctAnswers'];
    final totalQuestions = json['totalQuestions'];
    final score = json['score'];
    final items = json['items'];

    if (correctAnswers is! int || totalQuestions is! int) {
      throw const FormatException('Invalid activity result response');
    }

    return DiagnosticQuizResult(
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      score: score is num ? score.toDouble() : null,
      items: items is List
          ? items
                .map((item) => _CorrectionItemJson(item).toCorrectionItem())
                .toList(growable: false)
          : const [],
    );
  }
}

class _CorrectionItemJson {
  const _CorrectionItemJson(this.value);

  final Object? value;

  DiagnosticQuizCorrectionItem toCorrectionItem() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid correction item response');
    }

    final questionId = json['questionId'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final prompt = json['prompt'];
    final selectedChoiceId = json['selectedChoiceId'];
    final correctChoiceId = json['correctChoiceId'];
    final selectedChoiceIds = json['selectedChoiceIds'];
    final correctChoiceIds = json['correctChoiceIds'];
    final isCorrect = json['isCorrect'];
    final partialScore = json['partialScore'];
    final explanation = json['explanation'];
    final choiceFeedback = json['choiceFeedback'];
    final sources = json['sources'];

    if (questionId is! String ||
        prompt is! String ||
        isCorrect is! bool ||
        explanation is! String) {
      throw const FormatException('Invalid correction item response');
    }

    final parsedSelectedChoiceIds = selectedChoiceIds is List
        ? _stringList(selectedChoiceIds)
        : const <String>[];
    final parsedCorrectChoiceIds = correctChoiceIds is List
        ? _stringList(correctChoiceIds)
        : const <String>[];

    if (selectedChoiceId is! String &&
        correctChoiceId is! String &&
        (parsedSelectedChoiceIds.isEmpty || parsedCorrectChoiceIds.isEmpty)) {
      throw const FormatException('Invalid correction item response');
    }

    return DiagnosticQuizCorrectionItem(
      questionId: questionId,
      knowledgeUnitId: knowledgeUnitId is String ? knowledgeUnitId : null,
      prompt: prompt,
      selectedChoiceId: selectedChoiceId is String ? selectedChoiceId : null,
      correctChoiceId: correctChoiceId is String ? correctChoiceId : null,
      selectedChoiceIds: parsedSelectedChoiceIds,
      correctChoiceIds: parsedCorrectChoiceIds,
      isCorrect: isCorrect,
      partialScore: partialScore is num ? partialScore.toDouble() : null,
      explanation: explanation,
      choiceFeedback: choiceFeedback is List
          ? choiceFeedback
                .map(
                  (feedback) =>
                      _ChoiceFeedbackJson(feedback).toChoiceFeedback(),
                )
                .toList(growable: false)
          : const [],
      sources: sources is List
          ? sources
                .map((source) => _CorrectionSourceJson(source).toSource())
                .toList(growable: false)
          : const [],
    );
  }

  List<String> _stringList(List<Object?> values) {
    return values
        .map((value) {
          if (value is String) {
            return value;
          }

          throw const FormatException('Invalid correction item response');
        })
        .toList(growable: false);
  }
}

class _ChoiceFeedbackJson {
  const _ChoiceFeedbackJson(this.value);

  final Object? value;

  DiagnosticQuizChoiceFeedback toChoiceFeedback() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid choice feedback response');
    }

    final choiceId = json['choiceId'];
    final feedback = json['feedback'];

    if (choiceId is! String || feedback is! String) {
      throw const FormatException('Invalid choice feedback response');
    }

    return DiagnosticQuizChoiceFeedback(choiceId: choiceId, feedback: feedback);
  }
}

class _CorrectionSourceJson {
  const _CorrectionSourceJson(this.value);

  final Object? value;

  DiagnosticQuizCorrectionSource toSource() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid correction source response');
    }

    final chunkId = json['chunkId'];
    final text = json['text'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || text is! String || index is! int) {
      throw const FormatException('Invalid correction source response');
    }

    return DiagnosticQuizCorrectionSource(
      chunkId: chunkId,
      text: text,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

class _OpenQuestionActivityJson {
  const _OpenQuestionActivityJson(this.value);

  final Object? value;

  OpenQuestionActivity toActivity() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid open question response');
    }

    final sessionId = json['sessionId'];
    final type = json['type'];
    final version = json['version'];
    final subjectId = json['subjectId'];
    final documentId = json['documentId'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final question = json['question'];

    if (sessionId is! String ||
        type != 'open_question' ||
        subjectId is! String ||
        knowledgeUnitId is! String ||
        question is! Map<String, Object?>) {
      throw const FormatException('Invalid open question response');
    }

    return OpenQuestionActivity(
      sessionId: sessionId,
      type: type as String,
      version: version is int ? version : null,
      subjectId: subjectId,
      documentId: documentId is String ? documentId : null,
      knowledgeUnitId: knowledgeUnitId,
      question: _OpenQuestionJson(question).toQuestion(),
    );
  }
}

class _OpenQuestionJson {
  const _OpenQuestionJson(this.value);

  final Map<String, Object?> value;

  OpenQuestion toQuestion() {
    final id = value['id'];
    final prompt = value['prompt'];
    final instructions = value['instructions'];
    final maxAnswerLength = value['maxAnswerLength'];
    final sources = value['sources'];

    if (id is! String || prompt is! String || maxAnswerLength is! int) {
      throw const FormatException('Invalid open question response');
    }

    return OpenQuestion(
      id: id,
      prompt: prompt,
      instructions: instructions is String ? instructions : null,
      maxAnswerLength: maxAnswerLength,
      sources: sources is List
          ? sources
                .map((source) => _OpenQuestionSourceJson(source).toSource())
                .toList(growable: false)
          : const [],
    );
  }
}

class _OpenQuestionSourceJson {
  const _OpenQuestionSourceJson(this.value);

  final Object? value;

  OpenQuestionSource toSource() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid open question source response');
    }

    final chunkId = json['chunkId'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || index is! int) {
      throw const FormatException('Invalid open question source response');
    }

    return OpenQuestionSource(
      chunkId: chunkId,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

class _OpenAnswerSubmissionJson {
  const _OpenAnswerSubmissionJson(this.value);

  final Object? value;

  OpenAnswerSubmissionResult toResult() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid open answer response');
    }

    final sessionId = json['sessionId'];
    final type = json['type'];
    final status = json['status'];
    final evaluation = json['evaluation'];

    if (sessionId is! String ||
        type != 'open_question' ||
        status is! String ||
        evaluation is! Map<String, Object?>) {
      throw const FormatException('Invalid open answer response');
    }

    return OpenAnswerSubmissionResult(
      sessionId: sessionId,
      type: type as String,
      status: status,
      evaluation: _OpenAnswerEvaluationJson(evaluation).toEvaluation(),
    );
  }
}

class _OpenAnswerEvaluationJson {
  const _OpenAnswerEvaluationJson(this.value);

  final Map<String, Object?> value;

  OpenAnswerEvaluation toEvaluation() {
    final id = value['id'];
    final status = value['status'];
    final score = value['score'];
    final maxScore = value['maxScore'];
    final feedback = value['feedback'];
    final presentPoints = value['presentPoints'];
    final missingPoints = value['missingPoints'];
    final errors = value['errors'];
    final modelAnswer = value['modelAnswer'];
    final advice = value['advice'];
    final sources = value['sources'];

    if (id is! String || status is! String) {
      throw const FormatException('Invalid open answer evaluation response');
    }

    return OpenAnswerEvaluation(
      id: id,
      status: _openAnswerEvaluationStatus(status),
      score: score is num ? score.toDouble() : null,
      maxScore: maxScore is num ? maxScore.toDouble() : null,
      feedback: feedback is String ? feedback : null,
      presentPoints: presentPoints is List
          ? _stringList(
              presentPoints,
              'Invalid open answer evaluation response',
            )
          : const [],
      missingPoints: missingPoints is List
          ? _stringList(
              missingPoints,
              'Invalid open answer evaluation response',
            )
          : const [],
      errors: errors is List
          ? _stringList(errors, 'Invalid open answer evaluation response')
          : const [],
      modelAnswer: modelAnswer is String ? modelAnswer : null,
      advice: advice is String ? advice : null,
      sources: sources is List
          ? sources
                .map((source) => _OpenAnswerSourceJson(source).toSource())
                .toList(growable: false)
          : const [],
    );
  }

  OpenAnswerEvaluationStatus _openAnswerEvaluationStatus(String status) {
    return switch (status) {
      'PENDING' => OpenAnswerEvaluationStatus.pending,
      'READY' => OpenAnswerEvaluationStatus.ready,
      'FAILED' => OpenAnswerEvaluationStatus.failed,
      _ => throw const FormatException(
        'Invalid open answer evaluation response',
      ),
    };
  }
}

class _OpenAnswerSourceJson {
  const _OpenAnswerSourceJson(this.value);

  final Object? value;

  OpenAnswerCorrectionSource toSource() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid open answer source response');
    }

    final chunkId = json['chunkId'];
    final text = json['text'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || text is! String || index is! int) {
      throw const FormatException('Invalid open answer source response');
    }

    return OpenAnswerCorrectionSource(
      chunkId: chunkId,
      text: text,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

List<String> _stringList(List<Object?> values, String errorMessage) {
  return values
      .map((value) {
        if (value is String) {
          return value;
        }

        throw FormatException(errorMessage);
      })
      .toList(growable: false);
}
````

### revision_app/test/features/activities/fixtures/rich_closed_exercise_fixtures.dart

````dart
Map<String, Object?> richClosedExerciseJson() {
  return {
    'sessionId': 'rich-session-1',
    'type': 'rich_closed_exercise',
    'id': 'exercise-1',
    'version': 'rich-closed-question-v1',
    'title': 'Exercice institutions politiques',
    'subjectId': 'subject-1',
    'documentId': 'document-1',
    'knowledgeUnitId': 'unit-1',
    'questions': [
      {
        'id': 'single-1',
        'questionKind': 'single_choice',
        'prompt': 'Quel critère caractérise un régime parlementaire ?',
        'difficulty': 'MEDIUM',
        'cognitiveSkill': 'classification',
        'sourceChunkIds': ['chunk-1'],
        'choices': [
          {'id': 'choice-a', 'label': 'Responsabilité politique'},
          {'id': 'choice-b', 'label': 'Séparation étanche'},
          {'id': 'choice-c', 'label': 'Confédération'},
        ],
      },
      {
        'id': 'multiple-1',
        'questionKind': 'multiple_choice',
        'prompt': 'Quels indices orientent vers un régime parlementaire ?',
        'difficulty': 'MEDIUM',
        'cognitiveSkill': 'comparison',
        'sourceChunkIds': ['chunk-1', 'chunk-2'],
        'choices': [
          {'id': 'choice-a', 'label': 'Responsabilité du gouvernement'},
          {'id': 'choice-b', 'label': 'Collaboration des pouvoirs'},
          {'id': 'choice-c', 'label': 'Indépendance absolue'},
          {'id': 'choice-d', 'label': 'Absence de Parlement'},
        ],
        'minSelections': 2,
        'maxSelections': 2,
      },
      {
        'id': 'matching-1',
        'questionKind': 'matching',
        'prompt': 'Associe chaque mécanisme à sa fonction.',
        'difficulty': 'HIGH',
        'cognitiveSkill': 'comparison',
        'sourceChunkIds': ['chunk-2'],
        'leftItems': [
          {'id': 'left-1', 'label': 'Motion de censure'},
          {'id': 'left-2', 'label': 'Dissolution'},
          {'id': 'left-3', 'label': 'Contrôle constitutionnel'},
        ],
        'rightItems': [
          {'id': 'right-1', 'label': 'Responsabilité politique'},
          {'id': 'right-2', 'label': 'Fin anticipée d’une chambre'},
          {'id': 'right-3', 'label': 'Vérification d’une norme'},
        ],
      },
      {
        'id': 'ordering-1',
        'questionKind': 'ordering',
        'prompt': 'Ordonne les étapes du raisonnement.',
        'difficulty': 'LOW',
        'cognitiveSkill': 'procedure',
        'sourceChunkIds': ['chunk-3'],
        'items': [
          {'id': 'item-1', 'label': 'Repérer les organes'},
          {'id': 'item-2', 'label': 'Analyser les moyens d’action'},
          {'id': 'item-3', 'label': 'Qualifier le régime'},
        ],
      },
      {
        'id': 'case-1',
        'questionKind': 'case_qualification',
        'prompt': 'Choisis la qualification la plus pertinente.',
        'difficulty': 'HIGH',
        'cognitiveSkill': 'case_application',
        'sourceChunkIds': ['chunk-4'],
        'caseText':
            'Un gouvernement doit conserver la confiance d’une chambre élue.',
        'choices': [
          {'id': 'choice-a', 'label': 'Régime parlementaire'},
          {'id': 'choice-b', 'label': 'Régime présidentiel'},
          {'id': 'choice-c', 'label': 'Confédération'},
        ],
      },
      {
        'id': 'error-1',
        'questionKind': 'error_detection',
        'prompt': 'Repère l’erreur dominante.',
        'difficulty': 'MEDIUM',
        'cognitiveSkill': 'error_detection',
        'sourceChunkIds': ['chunk-5'],
        'statement':
            'Un régime présidentiel se définit par la responsabilité politique du gouvernement devant le Parlement.',
        'errorOptions': [
          {'id': 'error-a', 'label': 'Confusion avec le parlementarisme'},
          {'id': 'error-b', 'label': 'Confusion avec l’État fédéral'},
          {
            'id': 'error-c',
            'label': 'Confusion avec le contrôle juridictionnel',
          },
        ],
      },
    ],
  };
}

Map<String, Object?> richClosedResultJson() {
  return {
    'sessionId': 'rich-session-1',
    'type': 'rich_closed_exercise',
    'status': 'completed',
    'correctAnswers': 5,
    'totalQuestions': 6,
    'score': 0.833,
    'items': [
      {
        'questionId': 'single-1',
        'questionKind': 'single_choice',
        'prompt': 'Quel critère caractérise un régime parlementaire ?',
        'submittedAnswer': {
          'questionId': 'single-1',
          'questionKind': 'single_choice',
          'choiceId': 'choice-a',
        },
        'isCorrect': true,
        'partialScore': 1,
        'explanation': 'La responsabilité politique est centrale.',
        'sourceChunkIds': ['chunk-1'],
        'correction': {'correctChoiceId': 'choice-a'},
      },
      {
        'questionId': 'multiple-1',
        'questionKind': 'multiple_choice',
        'prompt': 'Quels indices orientent vers un régime parlementaire ?',
        'submittedAnswer': {
          'questionId': 'multiple-1',
          'questionKind': 'multiple_choice',
          'choiceIds': ['choice-a', 'choice-b'],
        },
        'isCorrect': true,
        'partialScore': 1,
        'explanation': 'Responsabilité et collaboration sont attendues.',
        'sourceChunkIds': ['chunk-1', 'chunk-2'],
        'correction': {
          'correctChoiceIds': ['choice-a', 'choice-b'],
        },
      },
      {
        'questionId': 'matching-1',
        'questionKind': 'matching',
        'prompt': 'Associe chaque mécanisme à sa fonction.',
        'submittedAnswer': {
          'questionId': 'matching-1',
          'questionKind': 'matching',
          'pairs': [
            {'leftId': 'left-1', 'rightId': 'right-1'},
            {'leftId': 'left-2', 'rightId': 'right-2'},
            {'leftId': 'left-3', 'rightId': 'right-3'},
          ],
        },
        'isCorrect': true,
        'partialScore': 1,
        'explanation': 'Chaque mécanisme renvoie à sa fonction.',
        'sourceChunkIds': ['chunk-2'],
        'correction': {
          'correctPairs': [
            {'leftId': 'left-1', 'rightId': 'right-1'},
            {'leftId': 'left-2', 'rightId': 'right-2'},
            {'leftId': 'left-3', 'rightId': 'right-3'},
          ],
        },
      },
      {
        'questionId': 'ordering-1',
        'questionKind': 'ordering',
        'prompt': 'Ordonne les étapes du raisonnement.',
        'submittedAnswer': {
          'questionId': 'ordering-1',
          'questionKind': 'ordering',
          'orderedIds': ['item-1', 'item-2', 'item-3'],
        },
        'isCorrect': true,
        'partialScore': 1,
        'explanation': 'La qualification vient après l’analyse.',
        'sourceChunkIds': ['chunk-3'],
        'correction': {
          'correctOrder': ['item-1', 'item-2', 'item-3'],
        },
      },
      {
        'questionId': 'case-1',
        'questionKind': 'case_qualification',
        'prompt': 'Choisis la qualification la plus pertinente.',
        'submittedAnswer': {
          'questionId': 'case-1',
          'questionKind': 'case_qualification',
          'choiceId': 'choice-a',
        },
        'isCorrect': true,
        'partialScore': 1,
        'explanation': 'La confiance parlementaire qualifie le régime.',
        'sourceChunkIds': ['chunk-4'],
        'correction': {'correctChoiceId': 'choice-a'},
      },
      {
        'questionId': 'error-1',
        'questionKind': 'error_detection',
        'prompt': 'Repère l’erreur dominante.',
        'submittedAnswer': {
          'questionId': 'error-1',
          'questionKind': 'error_detection',
          'errorId': 'error-b',
        },
        'isCorrect': false,
        'partialScore': 0,
        'explanation': 'L’erreur dominante est la confusion de régime.',
        'sourceChunkIds': ['chunk-5'],
        'correction': {'correctErrorId': 'error-a'},
      },
    ],
  };
}

Map<String, Object?> richClosedExerciseWithCorrectChoiceLeak() {
  final json = richClosedExerciseJson();
  ((json['questions']! as List<Object?>).first!
          as Map<String, Object?>)['correctChoiceId'] =
      'choice-a';
  return json;
}

Map<String, Object?> richClosedExerciseWithFeedbackLeak() {
  final json = richClosedExerciseJson();
  final question =
      (json['questions']! as List<Object?>).first! as Map<String, Object?>;
  final choice =
      (question['choices']! as List<Object?>).first! as Map<String, Object?>;
  choice['feedback'] = 'Ne doit pas être présent en pré-submit.';
  return json;
}

Map<String, Object?> richClosedExerciseWithUnknownKind() {
  final json = richClosedExerciseJson();
  ((json['questions']! as List<Object?>).first!
          as Map<String, Object?>)['questionKind'] =
      'timeline';
  return json;
}

Map<String, Object?> richClosedResultWithIncoherentCorrection() {
  final json = richClosedResultJson();
  final item = (json['items']! as List<Object?>).first! as Map<String, Object?>;
  item['correction'] = {
    'correctOrder': ['item-1', 'item-2'],
  };
  return json;
}
````

### revision_app/test/features/activities/rich_closed_exercise_test.dart

````dart
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  group('RichClosedExercise parsing', () {
    test('parses a complete V1-A pre-submit exercise', () {
      final exercise = RichClosedExercise.fromJson(richClosedExerciseJson());

      expect(exercise.sessionId, 'rich-session-1');
      expect(exercise.type, richClosedExerciseType);
      expect(exercise.version, richClosedExerciseVersion);
      expect(exercise.documentId, 'document-1');
      expect(exercise.questions, hasLength(6));
      expect(exercise.questions[0], isA<RichClosedSingleChoiceQuestion>());
      expect(exercise.questions[1], isA<RichClosedMultipleChoiceQuestion>());
      expect(exercise.questions[2], isA<RichClosedMatchingQuestion>());
      expect(exercise.questions[3], isA<RichClosedOrderingQuestion>());
      expect(exercise.questions[4], isA<RichClosedCaseQualificationQuestion>());
      expect(exercise.questions[5], isA<RichClosedErrorDetectionQuestion>());
    });

    test('parses all V1-A question fields explicitly', () {
      final questions = RichClosedExercise.fromJson(
        richClosedExerciseJson(),
      ).questions;

      final single = questions[0] as RichClosedSingleChoiceQuestion;
      final multiple = questions[1] as RichClosedMultipleChoiceQuestion;
      final matching = questions[2] as RichClosedMatchingQuestion;
      final ordering = questions[3] as RichClosedOrderingQuestion;
      final caseQuestion = questions[4] as RichClosedCaseQualificationQuestion;
      final error = questions[5] as RichClosedErrorDetectionQuestion;

      expect(single.choices.first.label, 'Responsabilité politique');
      expect(single.difficulty, RichClosedDifficulty.medium);
      expect(single.cognitiveSkill, RichClosedCognitiveSkill.classification);
      expect(multiple.minSelections, 2);
      expect(multiple.maxSelections, 2);
      expect(matching.leftItems, hasLength(3));
      expect(matching.rightItems, hasLength(3));
      expect(ordering.items.map((item) => item.id), [
        'item-1',
        'item-2',
        'item-3',
      ]);
      expect(caseQuestion.caseText, contains('confiance'));
      expect(error.statement, contains('régime présidentiel'));
      expect(error.errorOptions.first.id, 'error-a');
    });

    test('rejects unsupported question kinds', () {
      expectParseError(
        () => RichClosedExercise.fromJson(richClosedExerciseWithUnknownKind()),
      );
    });

    test('rejects pre-submit correction and feedback leaks', () {
      expectParseError(
        () => RichClosedExercise.fromJson(
          richClosedExerciseWithCorrectChoiceLeak(),
        ),
      );
      expectParseError(
        () => RichClosedExercise.fromJson(richClosedExerciseWithFeedbackLeak()),
      );
    });

    test('rejects every forbidden pre-submit correction field', () {
      for (final field in [
        'correctChoiceIds',
        'correctPairs',
        'correctOrder',
        'correctErrorId',
        'explanation',
        'score',
        'modelAnswer',
        'answerText',
        'freeTextAnswer',
        'textAnswer',
      ]) {
        final json = richClosedExerciseJson();
        ((json['questions']! as List<Object?>).first!
            as Map<String, Object?>)[field] = field == 'score'
            ? 1
            : 'forbidden';

        expectParseError(() => RichClosedExercise.fromJson(json));
      }
    });

    test('rejects unknown enums and incoherent multiple choice bounds', () {
      final badDifficulty = richClosedExerciseJson();
      ((badDifficulty['questions']! as List<Object?>).first!
              as Map<String, Object?>)['difficulty'] =
          'UNKNOWN';
      expectParseError(() => RichClosedExercise.fromJson(badDifficulty));

      final badSkill = richClosedExerciseJson();
      ((badSkill['questions']! as List<Object?>).first!
              as Map<String, Object?>)['cognitiveSkill'] =
          'analysis';
      expectParseError(() => RichClosedExercise.fromJson(badSkill));

      final badBounds = richClosedExerciseJson();
      final multiple =
          (badBounds['questions']! as List<Object?>)[1]!
              as Map<String, Object?>;
      multiple['minSelections'] = 3;
      multiple['maxSelections'] = 2;
      expectParseError(() => RichClosedExercise.fromJson(badBounds));
    });

    test('rejects empty ids and labels', () {
      final badId = richClosedExerciseJson();
      ((badId['questions']! as List<Object?>).first!
              as Map<String, Object?>)['id'] =
          ' ';
      expectParseError(() => RichClosedExercise.fromJson(badId));

      final badLabel = richClosedExerciseJson();
      final question =
          (badLabel['questions']! as List<Object?>).first!
              as Map<String, Object?>;
      ((question['choices']! as List<Object?>).first!
              as Map<String, Object?>)['label'] =
          '';
      expectParseError(() => RichClosedExercise.fromJson(badLabel));
    });
  });

  group('RichClosedAnswer submit DTO', () {
    test('serializes each V1-A answer shape', () {
      expect(
        const RichClosedSingleChoiceAnswer(
          questionId: 'single-1',
          choiceId: 'choice-a',
        ).toJson(),
        {
          'questionId': 'single-1',
          'questionKind': 'single_choice',
          'choiceId': 'choice-a',
        },
      );
      expect(
        const RichClosedMultipleChoiceAnswer(
          questionId: 'multiple-1',
          choiceIds: ['choice-a', 'choice-b'],
        ).toJson(),
        {
          'questionId': 'multiple-1',
          'questionKind': 'multiple_choice',
          'choiceIds': ['choice-a', 'choice-b'],
        },
      );
      expect(
        const RichClosedMatchingAnswer(
          questionId: 'matching-1',
          pairs: [RichClosedPair(leftId: 'left-1', rightId: 'right-1')],
        ).toJson(),
        {
          'questionId': 'matching-1',
          'questionKind': 'matching',
          'pairs': [
            {'leftId': 'left-1', 'rightId': 'right-1'},
          ],
        },
      );
      expect(
        const RichClosedOrderingAnswer(
          questionId: 'ordering-1',
          orderedIds: ['item-1', 'item-2'],
        ).toJson(),
        {
          'questionId': 'ordering-1',
          'questionKind': 'ordering',
          'orderedIds': ['item-1', 'item-2'],
        },
      );
      expect(
        const RichClosedCaseQualificationAnswer(
          questionId: 'case-1',
          choiceId: 'choice-a',
        ).toJson(),
        {
          'questionId': 'case-1',
          'questionKind': 'case_qualification',
          'choiceId': 'choice-a',
        },
      );
      expect(
        const RichClosedErrorDetectionAnswer(
          questionId: 'error-1',
          errorId: 'error-a',
        ).toJson(),
        {
          'questionId': 'error-1',
          'questionKind': 'error_detection',
          'errorId': 'error-a',
        },
      );
    });

    test('serializes submit wrapper without correction or free text', () {
      final json = const RichClosedExerciseSubmission(
        answers: [
          RichClosedSingleChoiceAnswer(
            questionId: 'single-1',
            choiceId: 'choice-a',
          ),
        ],
      ).toJson();
      final serialized = json.toString();

      expect(json, {
        'answers': [
          {
            'questionId': 'single-1',
            'questionKind': 'single_choice',
            'choiceId': 'choice-a',
          },
        ],
      });
      expect(serialized, isNot(contains('correct')));
      expect(serialized, isNot(contains('answerText')));
      expect(serialized, isNot(contains('feedback')));
    });
  });

  group('RichClosedExerciseResult parsing', () {
    test('parses a complete post-submit result from backend score', () {
      final result = RichClosedExerciseResult.fromJson(richClosedResultJson());

      expect(result.sessionId, 'rich-session-1');
      expect(result.type, richClosedExerciseType);
      expect(result.status, 'completed');
      expect(result.correctAnswers, 5);
      expect(result.totalQuestions, 6);
      expect(result.score, 0.833);
      expect(result.items, hasLength(6));
      expect(result.items.last.isCorrect, isFalse);
    });

    test('parses submitted answers and all correction payload forms', () {
      final result = RichClosedExerciseResult.fromJson(richClosedResultJson());

      expect(
        result.items[0].submittedAnswer,
        isA<RichClosedSingleChoiceAnswer>(),
      );
      expect(
        result.items[0].correction,
        isA<RichClosedCorrectChoiceIdCorrection>(),
      );
      expect(
        result.items[1].correction,
        isA<RichClosedCorrectChoiceIdsCorrection>(),
      );
      expect(
        result.items[2].correction,
        isA<RichClosedCorrectPairsCorrection>(),
      );
      expect(
        result.items[3].correction,
        isA<RichClosedCorrectOrderCorrection>(),
      );
      expect(
        result.items[5].correction,
        isA<RichClosedCorrectErrorIdCorrection>(),
      );
    });

    test('rejects absent or incoherent correction payloads', () {
      final missing = richClosedResultJson();
      final item =
          (missing['items']! as List<Object?>).first! as Map<String, Object?>;
      item.remove('correction');
      expectParseError(() => RichClosedExerciseResult.fromJson(missing));

      expectParseError(
        () => RichClosedExerciseResult.fromJson(
          richClosedResultWithIncoherentCorrection(),
        ),
      );
    });

    test('rejects invalid result envelope and score', () {
      final wrongStatus = richClosedResultJson()..['status'] = 'pending';
      expectParseError(() => RichClosedExerciseResult.fromJson(wrongStatus));

      final wrongType = richClosedResultJson()..['type'] = 'open_question';
      expectParseError(() => RichClosedExerciseResult.fromJson(wrongType));

      final wrongScore = richClosedResultJson()..['score'] = '0.8';
      expectParseError(() => RichClosedExerciseResult.fromJson(wrongScore));
    });
  });
}

void expectParseError(Object? Function() parse) {
  expect(parse, throwsA(isA<RichClosedExerciseParseException>()));
}
````

### revision_app/test/features/activities/http_activities_api_test.dart

````dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/data/http_activities_api.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

class CapturingHttpClientAdapter implements HttpClientAdapter {
  CapturingHttpClientAdapter(this.response);

  ResponseBody response;
  int fetchCallCount = 0;
  RequestOptions? lastOptions;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    fetchCallCount += 1;
    lastOptions = options;
    return response;
  }
}

void main() {
  test('starts the next activity with subject id and bearer token', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse(activityJson()));
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final activity = await api.startNextActivity(subjectId: 'subject-1');

    expect(activity.sessionId, 'session-1');
    expect(adapter.lastOptions?.path, '/activities/next');
    expect(adapter.lastOptions?.data, {
      'subjectId': 'subject-1',
      'selectionModes': ['single', 'multiple'],
      'visualsEnabled': true,
      'visualTypes': ['CHART', 'DIAGRAM'],
    });
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
  });

  test(
    'starts an open question activity with subject and knowledge unit',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(openQuestionStartJson()),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpActivitiesApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      final activity = await api.startOpenQuestion(
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
      );

      expect(activity.sessionId, 'open-session-1');
      expect(activity.type, 'open_question');
      expect(activity.version, 1);
      expect(activity.documentId, 'document-1');
      expect(activity.subjectId, 'subject-1');
      expect(activity.knowledgeUnitId, 'unit-1');
      expect(activity.question.id, 'open-question-1');
      expect(activity.question.prompt, 'Explique la séparation des pouvoirs.');
      expect(activity.question.instructions, 'Réponds en quelques phrases.');
      expect(activity.question.maxAnswerLength, 4000);
      expect(activity.question.sources.single.chunkId, 'chunk-1');
      expect(activity.question.sources.single.pageNumber, isNull);
      expect(activity.question.sources.single.index, 0);
      expect(adapter.lastOptions?.path, '/activities/open-question');
      expect(adapter.lastOptions?.data, {
        'subjectId': 'subject-1',
        'knowledgeUnitId': 'unit-1',
      });
    },
  );

  test('parses an open question activity without document', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(openQuestionStartJson(documentId: null)),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final activity = await api.startOpenQuestion(
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
    );

    expect(activity.documentId, isNull);
    expect(activity.question.sources.single.chunkId, 'chunk-1');
  });

  test('ignores source text in open question pre-submit payload', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(openQuestionStartJson(includeSourceText: true)),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final activity = await api.startOpenQuestion(
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
    );

    expect(activity.question.sources.single, isA<OpenQuestionSource>());
    expect(activity.question.sources.single.chunkId, 'chunk-1');
  });

  test('submits an open answer and parses a READY evaluation', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(openAnswerReadyJson()),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final result = await api.submitOpenAnswer(
      sessionId: 'open-session-1',
      answerText: 'La séparation des pouvoirs limite chaque autorité.',
    );
    final evaluation = result.evaluation;

    expect(result.sessionId, 'open-session-1');
    expect(result.type, 'open_question');
    expect(result.status, 'submitted');
    expect(evaluation.status, OpenAnswerEvaluationStatus.ready);
    expect(evaluation.score, 16);
    expect(evaluation.maxScore, 20);
    expect(evaluation.feedback, 'Réponse solide.');
    expect(evaluation.presentPoints, ['Définition correcte']);
    expect(evaluation.missingPoints, ['Exemple jurisprudentiel']);
    expect(evaluation.errors, isEmpty);
    expect(evaluation.modelAnswer, 'Modèle de réponse.');
    expect(evaluation.advice, 'Ajoute un exemple.');
    expect(evaluation.sources.single.text, 'Extrait source post-submit.');
    expect(adapter.lastOptions?.path, '/activities/open-session-1/open-answer');
    expect(adapter.lastOptions?.data, {
      'answerText': 'La séparation des pouvoirs limite chaque autorité.',
    });
  });

  test('submits an open answer and parses a FAILED evaluation', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(openAnswerFailedJson()),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final result = await api.submitOpenAnswer(
      sessionId: 'open-session-1',
      answerText: 'La séparation des pouvoirs limite chaque autorité.',
    );

    expect(result.evaluation.status, OpenAnswerEvaluationStatus.failed);
    expect(result.evaluation.score, isNull);
    expect(result.evaluation.feedback, isNull);
    expect(result.evaluation.errors, ['OPEN_ANSWER_EVALUATION_FAILED']);
    expect(result.evaluation.sources, isEmpty);
  });

  test('maps null open answer lists to empty lists', () async {
    final readyJson = openAnswerReadyJson()
      ..['evaluation'] = {
        'id': 'evaluation-1',
        'status': 'READY',
        'score': 12,
        'maxScore': 20,
        'feedback': 'Réponse exploitable.',
        'presentPoints': null,
        'missingPoints': null,
        'errors': null,
        'modelAnswer': null,
        'advice': null,
        'sources': null,
      };
    final adapter = CapturingHttpClientAdapter(jsonResponse(readyJson));
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final result = await api.submitOpenAnswer(
      sessionId: 'open-session-1',
      answerText: 'La séparation des pouvoirs limite chaque autorité.',
    );

    expect(result.evaluation.presentPoints, isEmpty);
    expect(result.evaluation.missingPoints, isEmpty);
    expect(result.evaluation.errors, isEmpty);
    expect(result.evaluation.sources, isEmpty);
  });

  test('rejects unknown open question activity types', () async {
    final json = openQuestionStartJson()..['type'] = 'diagnostic_quiz';
    final adapter = CapturingHttpClientAdapter(jsonResponse(json));
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      api.startOpenQuestion(subjectId: 'subject-1', knowledgeUnitId: 'unit-1'),
      throwsFormatException,
    );
  });

  test(
    'parses an enriched pre-submit quiz without correction fields',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(enrichedActivityJsonWithAccidentalCorrection()),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpActivitiesApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      final activity = await api.startNextActivity(subjectId: 'subject-1');
      final question = activity.questions.single;

      expect(activity.version, 2);
      expect(activity.documentId, 'document-1');
      expect(activity.subjectId, 'subject-1');
      expect(question.knowledgeUnitId, 'unit-1');
      expect(question.difficulty, 'MEDIUM');
      expect(question.sources.single.chunkId, 'chunk-1');
      expect(question.sources.single.pageNumber, isNull);
      expect(question.sources.single.index, 0);
      expect(question.choices.single.label, 'Réponse A');
    },
  );

  test(
    'parses a v3 quiz with multiple selection and bounded visuals',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(v3ActivityJsonWithAccidentalCorrection()),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpActivitiesApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      final activity = await api.startNextActivity(subjectId: 'subject-1');
      final question = activity.questions.single;
      final chart = question.visuals
          .whereType<DiagnosticQuizChartVisual>()
          .single;
      final diagram = question.visuals
          .whereType<DiagnosticQuizDiagramVisual>()
          .single;

      expect(activity.version, 3);
      expect(question.selectionMode, DiagnosticQuizSelectionMode.multiple);
      expect(question.minSelections, 1);
      expect(question.maxSelections, 2);
      expect(question.visuals, hasLength(3));
      expect(chart.title, 'Contrôles');
      expect(chart.chartType, DiagnosticQuizChartType.bar);
      expect(chart.data.single['value'], 2);
      expect(chart.sources.single.chunkId, 'chunk-1');
      expect(diagram.nodes.map((node) => node.label), ['Pouvoir', 'Contrôle']);
      expect(diagram.edges.single.label, 'limite');
      expect(
        question.visuals
            .whereType<DiagnosticQuizUnsupportedVisual>()
            .single
            .type,
        'IMAGE',
      );
      expect(question.choices.map((choice) => choice.label), [
        'Contrôle juridictionnel',
        'Pouvoir absolu',
        'Séparation des pouvoirs',
      ]);
    },
  );

  test('submits answers and maps the public score', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({'correctAnswers': 1, 'totalQuestions': 2}),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final result = await api.submitResult(
      sessionId: 'session-1',
      answers: const [
        DiagnosticQuizAnswer(questionId: 'question-1', choiceId: 'a'),
      ],
    );

    expect(result.correctAnswers, 1);
    expect(result.items, isEmpty);
    expect(adapter.lastOptions?.path, '/activities/session-1/result');
    expect(adapter.lastOptions?.data, {
      'answers': [
        {'questionId': 'question-1', 'choiceId': 'a'},
      ],
    });
  });

  test(
    'submits single and multiple answers with distinct payload shapes',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse({'correctAnswers': 2, 'totalQuestions': 2}),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpActivitiesApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      await api.submitResult(
        sessionId: 'session-1',
        answers: const [
          DiagnosticQuizAnswer(questionId: 'question-single', choiceId: 'a'),
          DiagnosticQuizAnswer(
            questionId: 'question-multiple',
            choiceIds: ['a', 'c'],
          ),
        ],
      );

      expect(adapter.lastOptions?.data, {
        'answers': [
          {'questionId': 'question-single', 'choiceId': 'a'},
          {
            'questionId': 'question-multiple',
            'choiceIds': ['a', 'c'],
          },
        ],
      });
    },
  );

  test(
    'parses enriched correction result with score feedback and sources',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(enrichedResultJson()),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpActivitiesApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      final result = await api.submitResult(
        sessionId: 'session-1',
        answers: const [
          DiagnosticQuizAnswer(questionId: 'question-1', choiceId: 'b'),
        ],
      );
      final item = result.items.single;

      expect(result.correctAnswers, 0);
      expect(result.totalQuestions, 1);
      expect(result.score, 0);
      expect(item.questionId, 'question-1');
      expect(item.knowledgeUnitId, 'unit-1');
      expect(item.selectedChoiceId, 'b');
      expect(item.correctChoiceId, 'a');
      expect(item.isCorrect, isFalse);
      expect(item.explanation, 'Le myocarde assure la contraction.');
      expect(item.choiceFeedback.single.choiceId, 'b');
      expect(item.sources.single.text, 'Le myocarde est le muscle cardiaque.');
    },
  );

  test('parses v3 multiple correction result', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(v3MultipleResultJson()),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final result = await api.submitResult(
      sessionId: 'session-1',
      answers: const [
        DiagnosticQuizAnswer(
          questionId: 'question-multiple',
          choiceIds: ['a', 'c'],
        ),
      ],
    );
    final item = result.items.single;

    expect(item.selectedChoiceId, isNull);
    expect(item.correctChoiceId, isNull);
    expect(item.selectedChoiceIds, ['a', 'c']);
    expect(item.correctChoiceIds, ['a', 'b']);
    expect(item.partialScore, 0.5);
    expect(item.sources.single.text, 'Source textuelle après submit.');
  });

  test(
    'rejects invalid activity JSON with a controlled format error',
    () async {
      final adapter = CapturingHttpClientAdapter(jsonResponse({'bad': true}));
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpActivitiesApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      await expectLater(
        api.startNextActivity(subjectId: 'subject-1'),
        throwsFormatException,
      );
    },
  );

  test('starts a rich closed exercise and omits null document id', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(richClosedExerciseJson()),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final exercise = await api.startRichClosedExercise(
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
    );

    expect(exercise.sessionId, 'rich-session-1');
    expect(exercise.questions, hasLength(6));
    expect(adapter.lastOptions?.path, '/activities/rich-closed/start');
    expect(adapter.lastOptions?.data, {
      'subjectId': 'subject-1',
      'knowledgeUnitId': 'unit-1',
      'questionCount': 6,
      'complexityProfile': 'exam',
    });
  });

  test('starts a rich closed exercise with optional payload fields', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(richClosedExerciseJson()),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await api.startRichClosedExercise(
      subjectId: 'subject-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      questionCount: 10,
      complexityProfile: RichClosedComplexityProfile.advanced,
      questionTypeMix: {
        RichClosedQuestionKind.singleChoice: 1,
        RichClosedQuestionKind.multipleChoice: 2,
        RichClosedQuestionKind.matching: 2,
        RichClosedQuestionKind.ordering: 1,
        RichClosedQuestionKind.caseQualification: 2,
        RichClosedQuestionKind.errorDetection: 2,
      },
    );

    expect(adapter.lastOptions?.data, {
      'subjectId': 'subject-1',
      'knowledgeUnitId': 'unit-1',
      'questionCount': 10,
      'complexityProfile': 'advanced',
      'documentId': 'document-1',
      'questionTypeMix': {
        'single_choice': 1,
        'multiple_choice': 2,
        'matching': 2,
        'ordering': 1,
        'case_qualification': 2,
        'error_detection': 2,
      },
    });
  });

  test('gets a rich closed exercise by session id', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(richClosedExerciseJson()),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final exercise = await api.getRichClosedExercise('rich-session-1');

    expect(exercise.type, richClosedExerciseType);
    expect(adapter.lastOptions?.path, '/activities/rich-closed/rich-session-1');
  });

  test('submits rich closed answers and parses the result', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(richClosedResultJson()),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final result = await api.submitRichClosedExercise(
      sessionId: 'rich-session-1',
      answers: const [
        RichClosedSingleChoiceAnswer(
          questionId: 'single-1',
          choiceId: 'choice-a',
        ),
      ],
    );

    expect(result.score, 0.833);
    expect(
      adapter.lastOptions?.path,
      '/activities/rich-closed/rich-session-1/submit',
    );
    expect(adapter.lastOptions?.data, {
      'answers': [
        {
          'questionId': 'single-1',
          'questionKind': 'single_choice',
          'choiceId': 'choice-a',
        },
      ],
    });
  });

  test('gets a rich closed result by session id', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(richClosedResultJson()),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final result = await api.getRichClosedExerciseResult('rich-session-1');

    expect(result.status, 'completed');
    expect(
      adapter.lastOptions?.path,
      '/activities/rich-closed/rich-session-1/result',
    );
  });

  test(
    'rejects rich closed correction leaks in start and get responses',
    () async {
      final startAdapter = CapturingHttpClientAdapter(
        jsonResponse(richClosedExerciseWithCorrectChoiceLeak()),
      );
      final startApi = HttpActivitiesApi(
        dio: Dio()..httpClientAdapter = startAdapter,
        getIdToken: () async => 'firebase-id-token',
      );
      await expectLater(
        startApi.startRichClosedExercise(
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
        ),
        throwsA(isA<RichClosedExerciseParseException>()),
      );

      final getAdapter = CapturingHttpClientAdapter(
        jsonResponse(richClosedExerciseWithFeedbackLeak()),
      );
      final getApi = HttpActivitiesApi(
        dio: Dio()..httpClientAdapter = getAdapter,
        getIdToken: () async => 'firebase-id-token',
      );
      await expectLater(
        getApi.getRichClosedExercise('rich-session-1'),
        throwsA(isA<RichClosedExerciseParseException>()),
      );
    },
  );

  test('rejects blank Firebase ID tokens before calling the API', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse(activityJson()));
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpActivitiesApi(dio: dio, getIdToken: () async => '  ');

    await expectLater(
      api.startNextActivity(subjectId: 'subject-1'),
      throwsStateError,
    );

    expect(adapter.fetchCallCount, 0);
  });
}

Map<String, Object?> activityJson() {
  return {
    'sessionId': 'session-1',
    'type': 'diagnostic_quiz',
    'title': 'Diagnostic rapide',
    'questions': [
      {
        'id': 'question-1',
        'prompt': 'Question test',
        'choices': [
          {'id': 'a', 'label': 'Reponse A'},
          {'id': 'b', 'label': 'Reponse B'},
        ],
      },
    ],
  };
}

Map<String, Object?> openQuestionStartJson({
  Object? documentId = 'document-1',
  bool includeSourceText = false,
}) {
  return {
    'sessionId': 'open-session-1',
    'type': 'open_question',
    'version': 1,
    'subjectId': 'subject-1',
    'documentId': documentId,
    'knowledgeUnitId': 'unit-1',
    'question': {
      'id': 'open-question-1',
      'prompt': 'Explique la séparation des pouvoirs.',
      'instructions': 'Réponds en quelques phrases.',
      'maxAnswerLength': 4000,
      'sources': [
        {
          'chunkId': 'chunk-1',
          'pageNumber': null,
          'index': 0,
          if (includeSourceText) 'text': 'Ne doit pas fuiter pré-submit.',
        },
      ],
    },
  };
}

Map<String, Object?> openAnswerReadyJson() {
  return {
    'sessionId': 'open-session-1',
    'type': 'open_question',
    'status': 'submitted',
    'evaluation': {
      'id': 'evaluation-1',
      'status': 'READY',
      'score': 16,
      'maxScore': 20,
      'feedback': 'Réponse solide.',
      'presentPoints': ['Définition correcte'],
      'missingPoints': ['Exemple jurisprudentiel'],
      'errors': [],
      'modelAnswer': 'Modèle de réponse.',
      'advice': 'Ajoute un exemple.',
      'sources': [
        {
          'chunkId': 'chunk-1',
          'text': 'Extrait source post-submit.',
          'pageNumber': null,
          'index': 0,
        },
      ],
    },
  };
}

Map<String, Object?> openAnswerFailedJson() {
  return {
    'sessionId': 'open-session-1',
    'type': 'open_question',
    'status': 'submitted',
    'evaluation': {
      'id': 'evaluation-1',
      'status': 'FAILED',
      'score': null,
      'maxScore': null,
      'feedback': null,
      'presentPoints': [],
      'missingPoints': [],
      'errors': ['OPEN_ANSWER_EVALUATION_FAILED'],
      'modelAnswer': null,
      'advice': null,
      'sources': [],
    },
  };
}

Map<String, Object?> enrichedActivityJsonWithAccidentalCorrection() {
  return {
    'sessionId': 'session-1',
    'type': 'diagnostic_quiz',
    'version': 2,
    'documentId': 'document-1',
    'subjectId': 'subject-1',
    'title': 'Diagnostic sourcé',
    'questions': [
      {
        'id': 'question-1',
        'knowledgeUnitId': 'unit-1',
        'prompt': 'Question test',
        'difficulty': 'MEDIUM',
        'correctChoiceId': 'a',
        'isCorrect': true,
        'explanation': 'Ne doit jamais être mappée avant submit.',
        'choices': [
          {
            'id': 'a',
            'label': 'Réponse A',
            'feedback': 'Ne doit jamais être mappé avant submit.',
          },
        ],
        'sources': [
          {
            'chunkId': 'chunk-1',
            'pageNumber': null,
            'index': 0,
            'text': 'Ne doit pas être lu avant submit.',
          },
        ],
      },
    ],
  };
}

Map<String, Object?> v3ActivityJsonWithAccidentalCorrection() {
  return {
    'sessionId': 'session-v3',
    'type': 'diagnostic_quiz',
    'version': 3,
    'documentId': 'document-1',
    'subjectId': 'subject-1',
    'title': 'Diagnostic v3',
    'questions': [
      {
        'id': 'question-multiple',
        'knowledgeUnitId': 'unit-1',
        'prompt': 'Quels éléments contrôlent le pouvoir ?',
        'difficulty': 'MEDIUM',
        'selectionMode': 'multiple',
        'minSelections': 1,
        'maxSelections': 2,
        'correctChoiceIds': ['a', 'c'],
        'explanation': 'Ne doit jamais être mappée avant submit.',
        'choices': [
          {
            'id': 'a',
            'label': 'Contrôle juridictionnel',
            'feedback': 'Ne doit jamais être mappé avant submit.',
          },
          {'id': 'b', 'label': 'Pouvoir absolu'},
          {'id': 'c', 'label': 'Séparation des pouvoirs'},
        ],
        'sources': [
          {
            'chunkId': 'chunk-1',
            'pageNumber': null,
            'index': 0,
            'text': 'Ne doit pas être lu avant submit.',
          },
        ],
        'visuals': [
          {
            'id': 'visual-chart',
            'type': 'CHART',
            'displayOrder': 0,
            'chartType': 'bar',
            'title': 'Contrôles',
            'description': 'Répartition des éléments',
            'data': [
              {'category': 'Contrôle', 'value': 2},
            ],
            'xKey': 'category',
            'yKeys': ['value'],
            'sources': [
              {'chunkId': 'chunk-1', 'pageNumber': null, 'index': 0},
            ],
          },
          {
            'id': 'visual-diagram',
            'type': 'DIAGRAM',
            'displayOrder': 1,
            'title': 'Relations',
            'nodes': [
              {'id': 'n1', 'label': 'Pouvoir'},
              {'id': 'n2', 'label': 'Contrôle'},
            ],
            'edges': [
              {'from': 'n1', 'to': 'n2', 'label': 'limite'},
            ],
            'sources': [
              {'chunkId': 'chunk-1', 'pageNumber': null, 'index': 0},
            ],
          },
          {
            'id': 'visual-image',
            'type': 'IMAGE',
            'displayOrder': 2,
            'sources': [
              {'chunkId': 'chunk-1', 'pageNumber': null, 'index': 0},
            ],
          },
        ],
      },
    ],
  };
}

Map<String, Object?> enrichedResultJson() {
  return {
    'correctAnswers': 0,
    'totalQuestions': 1,
    'score': 0.0,
    'items': [
      {
        'questionId': 'question-1',
        'knowledgeUnitId': 'unit-1',
        'prompt': 'Question test',
        'selectedChoiceId': 'b',
        'correctChoiceId': 'a',
        'isCorrect': false,
        'explanation': 'Le myocarde assure la contraction.',
        'choiceFeedback': [
          {'choiceId': 'b', 'feedback': 'Le péricarde protège le coeur.'},
        ],
        'sources': [
          {
            'chunkId': 'chunk-1',
            'text': 'Le myocarde est le muscle cardiaque.',
            'pageNumber': null,
            'index': 0,
          },
        ],
      },
    ],
  };
}

Map<String, Object?> v3MultipleResultJson() {
  return {
    'correctAnswers': 0,
    'totalQuestions': 1,
    'score': 0.0,
    'items': [
      {
        'questionId': 'question-multiple',
        'knowledgeUnitId': 'unit-1',
        'prompt': 'Quels éléments contrôlent le pouvoir ?',
        'selectedChoiceIds': ['a', 'c'],
        'correctChoiceIds': ['a', 'b'],
        'isCorrect': false,
        'partialScore': 0.5,
        'explanation': 'Explication post-submit.',
        'choiceFeedback': [
          {'choiceId': 'c', 'feedback': 'Feedback post-submit.'},
        ],
        'sources': [
          {
            'chunkId': 'chunk-1',
            'text': 'Source textuelle après submit.',
            'pageNumber': null,
            'index': 0,
          },
        ],
      },
    ],
  };
}

ResponseBody jsonResponse(Object body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}
````

### revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md

````md
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
| V1-010 | Widgets Flutter V1-A single/multiple/case/error | À faire | À créer |
| V1-011 | Widgets Flutter matching/ordering | À faire | À créer |
| V1-012 | Scoring/correction UI V1-A | À faire | À créer |
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
````
