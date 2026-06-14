# LOT-030 — GenUI composants activité et correction

## 1. Résultat

`LOT-030` ajoute au catalogue GenUI Flutter des composants bornés pour afficher des activités QCM et leurs corrections sans remplacer le rendu natif existant.

Composants ajoutés :

* `McqQuestionCard` ;
* `McqCorrectionPanel` ;
* `ActivityResultCard` ;
* `QuestionChartCard` ;
* `QuestionDiagramCard`.

Le fallback natif `DiagnosticQuizPage` reste le rendu principal du produit. Aucun backend, Prisma, Genkit, data layer HTTP, controller ou page QCM native n’a été modifié.

## 2. Sources inspectées

Documentation :

* `docs/ROADMAP.md`
* `docs/ROADMAP_EXECUTION_PLAN.md`
* `docs/ROADMAP_EXECUTION_LOT_021_029.md`
* `docs/ROADMAP_EXECUTION_LOT_022.md`
* `docs/ROADMAP_EXECUTION_LOT_023.md`
* `docs/ROADMAP_EXECUTION_LOT_024.md`
* `docs/ROADMAP_EXECUTION_LOT_025.md`
* `docs/ROADMAP_EXECUTION_LOT_025B_QCM_QUESTION_COUNT_MEDIA_MULTI_CONTRACT.md`
* `docs/ROADMAP_EXECUTION_LOT_025C_QCM_MEDIA_MULTI_BACKEND_CONTRACT.md`
* `docs/ROADMAP_EXECUTION_LOT_025D_QCM_MEDIA_MULTI_BACKEND.md`
* `docs/ROADMAP_EXECUTION_LOT_025E_QCM_MEDIA_MULTI_UI.md`
* `docs/ROADMAP_EXECUTION_LOT_025F_QCM_V3_DB_RUNTIME_VALIDATION.md`
* `AGENTS.md`
* `codex_rule.md`

Frontend :

* `pubspec.yaml`
* `lib/features/activities/genui/revision_activity_catalog.dart`
* `lib/features/activities/genui/diagnostic_quiz_activity_validator.dart`
* `lib/features/activities/genui/sourced_reading_component_validator.dart`
* `lib/features/activities/domain/diagnostic_quiz_activity.dart`
* `lib/features/activities/application/activity_controller.dart`
* `lib/features/activities/data/http_activities_api.dart`
* `lib/features/activities/data/demo_activity_api.dart`
* `lib/presentation/pages/activities/diagnostic_quiz_page.dart`
* `lib/presentation/widgets/revision_panel.dart`
* `lib/presentation/widgets/revision_choice_tile.dart`
* `lib/presentation/widgets/revision_status_pill.dart`
* `lib/presentation/widgets/revision_message.dart`
* `lib/presentation/widgets/documents/document_source_excerpt.dart`
* `test/features/activities/revision_activity_catalog_test.dart`
* `test/features/activities/diagnostic_quiz_activity_validator_test.dart`
* `test/features/activities/sourced_reading_component_validator_test.dart`
* `test/features/activities/diagnostic_quiz_page_test.dart`
* `test/features/activities/http_activities_api_test.dart`
* `test/features/activities/activity_controller_test.dart`
* `test/fakes/in_memory_activity_api.dart`

Backend en lecture seule :

* `api/src/modules/activities/interfaces/activities.controller.ts`
* `api/src/modules/activities/application/activities.repository.ts`
* `api/src/modules/activities/application/start-next-activity.use-case.ts`
* `api/src/modules/activities/application/submit-activity-result.use-case.ts`
* `api/src/modules/activities/infrastructure/prisma-activities.repository.ts`
* `api/prisma/schema.prisma`

## 3. Préflight Git

API :

```text
pwd: /Users/karim/Project/app-révision/api
branch: main
status initial: ## main...origin/main
fichiers modifiés/non suivis initiaux: aucun fichier listé
derniers commits:
02d3e57 #135: finalise corrections du générateur de quiz diagnostique
1fc13d5 #134: améliore entrée de génération d'artefacts et générateur de fiches de révision
fa23091 #133: corrige implémentation et tests du générateur de quiz diagnostique
2c31e40 #132: ajoute tests d'intégration pour le repository d'activités
2d4bf1e #131: ajoute suppression de documents et matières avec tests associés
```

Frontend :

```text
pwd: /Users/karim/Project/app-révision/revision_app
branch: main
status initial: ## main...origin/main
fichiers modifiés/non suivis initiaux: aucun fichier listé
derniers commits:
769c73a LOT_027 - Mise à jour API HTTP activités et tests associés
4af6f0b LOT_025F_QCM_V3_DB_RUNTIME_VALIDATION - Mise à jour plan d'exécution et ajout rapport LOT_025F (QCM V3 DB runtime validation)
63f815d LOT_026 - Mise à jour contrôleurs documents/matières, APIs, pages et tests, ajout test subjects_home_page
7a9f377 LOT_025E_QCM_MEDIA_MULTI_UI - Mise à jour contrôleur QCM, API, UI et tests, ajout rapport LOT_025E
b1fc797 HOTFIX_025D_BIS_QCM_V3_VERSIONING - Ajout rapport hotfix 025D BIS (QCM V3 versioning)
```

Décision : aucun fichier utilisateur hors scope n’a été écrasé.

## 4. Périmètre réalisé

Le lot est limité au catalogue GenUI Flutter et à ses tests :

* ajout de validators stricts pour les composants d’activité/correction ;
* ajout des cinq composants GenUI au catalogue ;
* ajout de rendus bornés pour QCM pré-submit, correction post-submit, résultat, chart et diagram ;
* ajout d’un fallback sûr `Composant GenUI indisponible` pour payload invalide ;
* extension des tests catalogue et ajout de tests validators anti-fuite.

## 5. Composants GenUI ajoutés

`McqQuestionCard` :

* rendu pré-submit uniquement ;
* affiche question, difficulté, mode de sélection, choix et indication de sources disponibles après correction ;
* accepte une sélection fournie par le runtime, mais ne calcule rien ;
* rejette les champs de correction.

`McqCorrectionPanel` :

* rendu post-submit uniquement ;
* affiche réponse sélectionnée, réponse attendue, état correct/à revoir, score partiel, explication, feedback et sources textuelles ;
* ne calcule pas la correction.

`ActivityResultCard` :

* affiche un résultat déjà calculé : statut, score, bonnes réponses et message optionnel ;
* ne crée aucune navigation ni action backend.

`QuestionChartCard` :

* rend un chart borné sous forme lisible ;
* accepte `bar`, `line`, `pie`, `scatter` ;
* ne rend aucune spec libre de bibliothèque.

`QuestionDiagramCard` :

* rend un diagramme simple sous forme de nodes et relations ;
* ne rend ni Mermaid, ni SVG, ni HTML.

## 6. Validators ajoutés ou modifiés

Nouveau fichier :

* `lib/features/activities/genui/activity_correction_component_validator.dart`

Fonctions publiques :

* `isActivityCorrectionComponentPayloadSafe`
* `isMcqQuestionCardPayloadSafe`
* `isMcqCorrectionPanelPayloadSafe`
* `isActivityResultCardPayloadSafe`
* `isQuestionChartCardPayloadSafe`
* `isQuestionDiagramCardPayloadSafe`

Bornes principales :

* prompt : `600` caractères ;
* titre : `120` caractères ;
* description : `600` caractères ;
* choix : `6` maximum ;
* sources : `4` maximum ;
* extrait source post-submit : `520` caractères ;
* explication : `1200` caractères ;
* feedback : `600` caractères ;
* feedbacks : `8` maximum ;
* chart rows : `12` maximum ;
* chart columns : `8` maximum ;
* diagram nodes : `12` maximum ;
* diagram edges : `20` maximum.

Les validators rejettent les champs inconnus, les longueurs excessives, les listes excessives, les clés chart invalides, les edges incohérentes et les marqueurs dangereux : `<script`, `<svg`, `<iframe`, `javascript:`, Mermaid et variantes `graph`/`flowchart`.

## 7. Stratégie anti-fuite

`McqQuestionCard` rejette explicitement :

* `correctChoiceId` ;
* `correctChoiceIds` ;
* `isCorrect` ;
* `explanation` ;
* `feedback` ;
* `choiceFeedback` ;
* `partialScore` ;
* `sources[].text`.

Le fallback sûr n’affiche jamais le payload invalide. Il affiche uniquement `Composant GenUI indisponible`.

La correction reste post-submit via `McqCorrectionPanel`. Le frontend GenUI ne calcule pas `isCorrect`, ne déduit pas la bonne réponse et ne modifie pas le runtime natif.

## 8. Chart/diagram payloads bornés

Charts :

* types autorisés : `bar`, `line`, `pie`, `scatter` ;
* data limitée en lignes et colonnes ;
* clés limitées au pattern simple `A-Za-z0-9_` ;
* valeurs limitées à `string`, `number`, `null` ;
* aucun objet imbriqué arbitraire.

Diagrams :

* nodes bornés ;
* edges bornées ;
* chaque edge doit référencer deux nodes existants ;
* labels bornés ;
* pas de moteur libre.

## 9. Fallback natif et fallback GenUI

Fallback natif :

* `DiagnosticQuizPage` reste inchangé ;
* sélection single/multiple inchangée ;
* soumission inchangée ;
* parsing HTTP inchangé ;
* correction native inchangée.

Fallback GenUI :

* payload invalide : `Composant GenUI indisponible` ;
* composant inconnu : le catalogue ne l’ajoute pas comme item métier ;
* aucun payload brut n’est rendu.

## 10. Question ouverte

Reportée.

Justification : aucun contrat question ouverte runtime complet n’est disponible côté Flutter pour ce lot, et le prompt interdit de démarrer `LOT-026`. Aucun composant `OpenQuestionCard`, `CorrectionPanel` ou `RubricCard` n’a donc été créé.

## 11. Fichiers modifiés

Créés :

* `lib/features/activities/genui/activity_correction_component_validator.dart`
* `test/features/activities/activity_correction_component_validator_test.dart`
* `docs/ROADMAP_EXECUTION_LOT_030_GENUI_ACTIVITY_CORRECTION.md`

Modifiés :

* `lib/features/activities/genui/revision_activity_catalog.dart`
* `test/features/activities/revision_activity_catalog_test.dart`
* `docs/ROADMAP_EXECUTION_PLAN.md`

Supprimés :

* aucun.

## 12. Tests créés ou modifiés

Créé :

* `test/features/activities/activity_correction_component_validator_test.dart`

Modifié :

* `test/features/activities/revision_activity_catalog_test.dart`

Couverture ajoutée :

* payload valide/invalide pour les cinq nouveaux composants ;
* anti-fuite pré-submit explicite ;
* rejet des sources textuelles pré-submit ;
* rejet des champs inconnus ;
* rejet HTML/SVG/JS/Mermaid ;
* chart borné ;
* diagram borné ;
* fallback sûr ;
* rendu catalogue des cinq composants.

## 13. Validations lancées avec résultats

```bash
cd /Users/karim/Project/app-révision/revision_app
flutter test test/features/activities/activity_correction_component_validator_test.dart test/features/activities/revision_activity_catalog_test.dart
```

Résultat : succès, `18` tests passés.

```bash
cd /Users/karim/Project/app-révision/revision_app
dart analyze lib test
```

Résultat : succès, `No issues found!`

```bash
cd /Users/karim/Project/app-révision/revision_app
flutter test test/features/activities
```

Résultat : succès, `51` tests passés.

```bash
cd /Users/karim/Project/app-révision/revision_app
flutter test
```

Résultat : succès, `136` tests passés.

```bash
cd /Users/karim/Project/app-révision/revision_app
git diff --check
```

Résultat : succès, aucune sortie.

```bash
cd /Users/karim/Project/app-révision/api
git diff --check
```

Résultat : succès, aucune sortie.

## 14. Validations non lancées avec justification

Non lancés :

* tests backend complets : aucun fichier backend modifié ;
* migrations Prisma : interdites et hors scope ;
* provider IA réel : interdit et inutile ;
* déploiement : interdit ;
* `flutter pub upgrade` : interdit ;
* `npm run lint`, `npm run format`, `npm run test:cov` : interdits par le prompt.

## 15. Risques restants

* GenUI n’est pas encore branché à une session IA runtime.
* Les composants chart/diagram sont volontairement simples ; ils devront être enrichis seulement après validation produit.
* Les composants question ouverte sont reportés à `LOT-026` et lots suivants.
* Les images restent non supportées runtime.
* Les payloads GenUI doivent continuer à être reconstruits depuis des objets métier validés, jamais depuis une sortie IA arbitraire.

## 16. Recommandation prochain lot

Recommandation : `LOT-031 — Session de révision IA minimale`, seulement si le catalogue GenUI doit être réellement orchestré dans une session. Si la priorité produit est la question ouverte, faire d’abord `LOT-026 — Contrat question ouverte`.

## 17. Code créé/modifié pour review

Cette section contient maintenant le code nécessaire à la review directement dans le rapport.

### Fichiers créés — contenu complet

### lib/features/activities/genui/activity_correction_component_validator.dart

~~~~dart
const int maxActivityComponentTitleLength = 120;
const int maxActivityComponentPromptLength = 600;
const int maxActivityComponentDescriptionLength = 600;
const int maxActivityChoiceLabelLength = 180;
const int maxActivityChoices = 6;
const int maxActivitySources = 4;
const int maxActivitySourceTextLength = 520;
const int maxActivityExplanationLength = 1200;
const int maxActivityFeedbackLength = 600;
const int maxActivityFeedbackItems = 8;
const int maxActivityComponentActionLabelLength = 80;
const int maxQuestionVisuals = 2;
const int maxQuestionChartRows = 12;
const int maxQuestionChartColumns = 8;
const int maxQuestionChartKeyLength = 32;
const int maxQuestionChartValueLength = 120;
const int maxQuestionDiagramNodes = 12;
const int maxQuestionDiagramEdges = 20;

bool isActivityCorrectionComponentPayloadSafe(
  String component,
  Map<String, Object?> payload,
) {
  return switch (component) {
    'McqQuestionCard' => isMcqQuestionCardPayloadSafe(payload),
    'McqCorrectionPanel' => isMcqCorrectionPanelPayloadSafe(payload),
    'ActivityResultCard' => isActivityResultCardPayloadSafe(payload),
    'QuestionChartCard' => isQuestionChartCardPayloadSafe(payload),
    'QuestionDiagramCard' => isQuestionDiagramCardPayloadSafe(payload),
    _ => false,
  };
}

bool isMcqQuestionCardPayloadSafe(Map<String, Object?> payload) {
  if (!_hasOnlyKeys(payload, {
        'questionId',
        'displayOrder',
        'totalQuestions',
        'prompt',
        'difficulty',
        'selectionMode',
        'minSelections',
        'maxSelections',
        'choices',
        'selectedChoiceId',
        'selectedChoiceIds',
        'sources',
        'visuals',
      }) ||
      payload.containsKey('correctChoiceId') ||
      payload.containsKey('correctChoiceIds') ||
      payload.containsKey('isCorrect') ||
      payload.containsKey('explanation') ||
      payload.containsKey('feedback') ||
      payload.containsKey('choiceFeedback') ||
      payload.containsKey('partialScore')) {
    return false;
  }

  final displayOrder = payload['displayOrder'];
  final totalQuestions = payload['totalQuestions'];
  final selectionMode = payload['selectionMode'];
  final choiceIds = _choiceIds(payload['choices']);

  if (!_plainString(payload['questionId']) ||
      !_boundedString(payload['prompt'], maxActivityComponentPromptLength) ||
      displayOrder is! int ||
      displayOrder < 1 ||
      totalQuestions is! int ||
      totalQuestions < displayOrder ||
      !_difficultySafe(payload['difficulty']) ||
      !_selectionModeSafe(selectionMode) ||
      choiceIds == null) {
    return false;
  }

  if (!_selectionBoundsSafe(
    selectionMode,
    payload['minSelections'],
    payload['maxSelections'],
    choiceIds.length,
  )) {
    return false;
  }

  if (!_selectedChoicesSafe(
    selectionMode,
    payload['selectedChoiceId'],
    payload['selectedChoiceIds'],
    choiceIds,
  )) {
    return false;
  }

  final sources = payload['sources'];
  if (sources != null && !_sourceRefListSafe(sources, allowText: false)) {
    return false;
  }

  final visuals = payload['visuals'];
  if (visuals != null && !_visualListSafe(visuals)) {
    return false;
  }

  return true;
}

bool isMcqCorrectionPanelPayloadSafe(Map<String, Object?> payload) {
  if (!_hasOnlyKeys(payload, {
    'questionId',
    'knowledgeUnitId',
    'prompt',
    'selectionMode',
    'choices',
    'selectedChoiceId',
    'correctChoiceId',
    'selectedChoiceIds',
    'correctChoiceIds',
    'isCorrect',
    'partialScore',
    'explanation',
    'choiceFeedback',
    'sources',
  })) {
    return false;
  }

  final selectionMode = payload['selectionMode'];
  final choiceIds = _choiceIds(payload['choices']);

  if (!_plainString(payload['questionId']) ||
      !_optionalPlainString(payload['knowledgeUnitId']) ||
      !_boundedString(payload['prompt'], maxActivityComponentPromptLength) ||
      !_selectionModeSafe(selectionMode) ||
      choiceIds == null ||
      payload['isCorrect'] is! bool ||
      !_numberInRange(payload['partialScore'], min: 0, max: 1, optional: true) ||
      !_boundedString(
        payload['explanation'],
        maxActivityExplanationLength,
      )) {
    return false;
  }

  if (!_correctionChoicesSafe(
    selectionMode,
    payload['selectedChoiceId'],
    payload['correctChoiceId'],
    payload['selectedChoiceIds'],
    payload['correctChoiceIds'],
    choiceIds,
  )) {
    return false;
  }

  final choiceFeedback = payload['choiceFeedback'];
  if (choiceFeedback != null &&
      !_choiceFeedbackListSafe(choiceFeedback, choiceIds)) {
    return false;
  }

  final sources = payload['sources'];
  if (sources != null && !_sourceRefListSafe(sources, allowText: true)) {
    return false;
  }

  return true;
}

bool isActivityResultCardPayloadSafe(Map<String, Object?> payload) {
  if (!_hasOnlyKeys(payload, {
    'title',
    'status',
    'correctAnswers',
    'totalQuestions',
    'score',
    'partialScore',
    'message',
    'primaryActionLabel',
    'secondaryActionLabel',
  })) {
    return false;
  }

  final correctAnswers = payload['correctAnswers'];
  final totalQuestions = payload['totalQuestions'];

  return _boundedString(payload['title'], maxActivityComponentTitleLength) &&
      _boundedString(payload['status'], maxActivityComponentTitleLength) &&
      correctAnswers is int &&
      totalQuestions is int &&
      totalQuestions > 0 &&
      correctAnswers >= 0 &&
      correctAnswers <= totalQuestions &&
      _numberInRange(payload['score'], min: 0, max: 1, optional: true) &&
      _numberInRange(payload['partialScore'], min: 0, max: 1, optional: true) &&
      _optionalBoundedString(
        payload['message'],
        maxActivityComponentDescriptionLength,
      ) &&
      _optionalBoundedString(
        payload['primaryActionLabel'],
        maxActivityComponentActionLabelLength,
      ) &&
      _optionalBoundedString(
        payload['secondaryActionLabel'],
        maxActivityComponentActionLabelLength,
      );
}

bool isQuestionChartCardPayloadSafe(Map<String, Object?> payload) {
  if (!_hasOnlyKeys(payload, {
    'visualId',
    'chartType',
    'title',
    'description',
    'data',
    'xKey',
    'yKeys',
    'sources',
  })) {
    return false;
  }

  final data = payload['data'];
  final xKey = payload['xKey'];
  final yKeys = payload['yKeys'];
  final columns = _chartColumns(data);

  if (!_plainString(payload['visualId']) ||
      !_chartTypeSafe(payload['chartType']) ||
      !_boundedString(payload['title'], maxActivityComponentTitleLength) ||
      !_optionalBoundedString(
        payload['description'],
        maxActivityComponentDescriptionLength,
      ) ||
      columns == null ||
      !_optionalChartKeySafe(xKey) ||
      !_chartKeyListSafe(yKeys, optional: true) ||
      !_sourceRefListSafe(payload['sources'], allowText: false)) {
    return false;
  }

  if (xKey is String && !columns.contains(xKey)) {
    return false;
  }

  if (yKeys is List &&
      yKeys.any((key) => key is! String || !columns.contains(key))) {
    return false;
  }

  return true;
}

bool isQuestionDiagramCardPayloadSafe(Map<String, Object?> payload) {
  if (!_hasOnlyKeys(payload, {
    'visualId',
    'title',
    'description',
    'nodes',
    'edges',
    'sources',
  })) {
    return false;
  }

  final nodes = _diagramNodeIds(payload['nodes']);
  if (!_plainString(payload['visualId']) ||
      !_boundedString(payload['title'], maxActivityComponentTitleLength) ||
      !_optionalBoundedString(
        payload['description'],
        maxActivityComponentDescriptionLength,
      ) ||
      nodes == null ||
      !_diagramEdgesSafe(payload['edges'], nodes) ||
      !_sourceRefListSafe(payload['sources'], allowText: false)) {
    return false;
  }

  return true;
}

bool _visualListSafe(Object? value) {
  if (value is! List || value.length > maxQuestionVisuals) {
    return false;
  }

  return value.every((item) {
    final payload = _jsonMap(item);
    if (payload == null) {
      return false;
    }
    return isQuestionChartCardPayloadSafe(payload) ||
        isQuestionDiagramCardPayloadSafe(payload);
  });
}

Set<String>? _choiceIds(Object? value) {
  if (value is! List ||
      value.length < 2 ||
      value.length > maxActivityChoices) {
    return null;
  }

  final ids = <String>{};
  for (final item in value) {
    final payload = _jsonMap(item);
    if (payload == null ||
        !_hasOnlyKeys(payload, {'id', 'label'}) ||
        !_plainString(payload['id']) ||
        !_boundedString(payload['label'], maxActivityChoiceLabelLength)) {
      return null;
    }
    final id = payload['id'] as String;
    if (!ids.add(id)) {
      return null;
    }
  }

  return ids;
}

bool _selectedChoicesSafe(
  Object? selectionMode,
  Object? selectedChoiceId,
  Object? selectedChoiceIds,
  Set<String> choiceIds,
) {
  if (selectedChoiceId != null && selectedChoiceIds != null) {
    return false;
  }

  if (selectedChoiceId != null) {
    return selectedChoiceId is String && choiceIds.contains(selectedChoiceId);
  }

  if (selectedChoiceIds != null) {
    final ids = _stringSet(selectedChoiceIds);
    if (ids == null || ids.isEmpty) {
      return false;
    }
    return ids.every(choiceIds.contains);
  }

  return true;
}

bool _correctionChoicesSafe(
  Object? selectionMode,
  Object? selectedChoiceId,
  Object? correctChoiceId,
  Object? selectedChoiceIds,
  Object? correctChoiceIds,
  Set<String> choiceIds,
) {
  if (selectionMode == 'single') {
    return selectedChoiceId is String &&
        correctChoiceId is String &&
        selectedChoiceIds == null &&
        correctChoiceIds == null &&
        choiceIds.contains(selectedChoiceId) &&
        choiceIds.contains(correctChoiceId);
  }

  final selectedIds = _stringSet(selectedChoiceIds);
  final correctIds = _stringSet(correctChoiceIds);

  return selectedChoiceId == null &&
      correctChoiceId == null &&
      selectedIds != null &&
      correctIds != null &&
      selectedIds.isNotEmpty &&
      correctIds.isNotEmpty &&
      selectedIds.every(choiceIds.contains) &&
      correctIds.every(choiceIds.contains);
}

bool _choiceFeedbackListSafe(Object? value, Set<String> choiceIds) {
  if (value is! List || value.length > maxActivityFeedbackItems) {
    return false;
  }

  final feedbackChoiceIds = <String>{};
  for (final item in value) {
    final payload = _jsonMap(item);
    if (payload == null ||
        !_hasOnlyKeys(payload, {'choiceId', 'feedback'}) ||
        payload['choiceId'] is! String ||
        !choiceIds.contains(payload['choiceId']) ||
        !_boundedString(payload['feedback'], maxActivityFeedbackLength)) {
      return false;
    }
    if (!feedbackChoiceIds.add(payload['choiceId'] as String)) {
      return false;
    }
  }

  return true;
}

bool _sourceRefListSafe(Object? value, {required bool allowText}) {
  if (value is! List || value.length > maxActivitySources) {
    return false;
  }

  return value.every((item) => _sourceRefSafe(item, allowText: allowText));
}

bool _sourceRefSafe(Object? value, {required bool allowText}) {
  final payload = _jsonMap(value);
  final allowedKeys = allowText
      ? {'chunkId', 'text', 'pageNumber', 'index', 'label'}
      : {'chunkId', 'pageNumber', 'index'};

  if (payload == null || !_hasOnlyKeys(payload, allowedKeys)) {
    return false;
  }

  final pageNumber = payload['pageNumber'];
  final index = payload['index'];
  final text = payload['text'];
  final label = payload['label'];

  return _plainString(payload['chunkId']) &&
      (pageNumber == null || pageNumber is int) &&
      index is int &&
      index >= 0 &&
      (!allowText ||
          _boundedString(text, maxActivitySourceTextLength)) &&
      (!allowText ||
          label == null ||
          _boundedString(label, maxActivityComponentActionLabelLength));
}

Set<String>? _chartColumns(Object? value) {
  if (value is! List ||
      value.isEmpty ||
      value.length > maxQuestionChartRows) {
    return null;
  }

  final columns = <String>{};
  for (final row in value) {
    final payload = _jsonMap(row);
    if (payload == null ||
        payload.isEmpty ||
        payload.length > maxQuestionChartColumns) {
      return null;
    }

    for (final entry in payload.entries) {
      if (!_chartKeySafe(entry.key) || !_chartValueSafe(entry.value)) {
        return null;
      }
      columns.add(entry.key);
    }
  }

  if (columns.length > maxQuestionChartColumns) {
    return null;
  }

  return columns;
}

Set<String>? _diagramNodeIds(Object? value) {
  if (value is! List ||
      value.isEmpty ||
      value.length > maxQuestionDiagramNodes) {
    return null;
  }

  final ids = <String>{};
  for (final item in value) {
    final payload = _jsonMap(item);
    if (payload == null ||
        !_hasOnlyKeys(payload, {'id', 'label'}) ||
        !_plainString(payload['id']) ||
        !_boundedString(payload['label'], maxActivityComponentTitleLength)) {
      return null;
    }
    if (!ids.add(payload['id'] as String)) {
      return null;
    }
  }

  return ids;
}

bool _diagramEdgesSafe(Object? value, Set<String> nodeIds) {
  if (value == null) {
    return true;
  }

  if (value is! List || value.length > maxQuestionDiagramEdges) {
    return false;
  }

  for (final item in value) {
    final payload = _jsonMap(item);
    if (payload == null ||
        !_hasOnlyKeys(payload, {'from', 'to', 'label'}) ||
        payload['from'] is! String ||
        payload['to'] is! String ||
        !nodeIds.contains(payload['from']) ||
        !nodeIds.contains(payload['to']) ||
        !_optionalBoundedString(
          payload['label'],
          maxActivityComponentTitleLength,
        )) {
      return false;
    }
  }

  return true;
}

bool _selectionBoundsSafe(
  Object? selectionMode,
  Object? minSelections,
  Object? maxSelections,
  int choiceCount,
) {
  if (selectionMode == 'single') {
    return minSelections == null && maxSelections == null;
  }

  return minSelections is int &&
      maxSelections is int &&
      minSelections >= 1 &&
      maxSelections >= minSelections &&
      maxSelections <= choiceCount;
}

bool _selectionModeSafe(Object? value) {
  return value == 'single' || value == 'multiple';
}

bool _difficultySafe(Object? value) {
  return value == null || value == 'LOW' || value == 'MEDIUM' || value == 'HIGH';
}

bool _chartTypeSafe(Object? value) {
  return value == 'bar' ||
      value == 'line' ||
      value == 'pie' ||
      value == 'scatter';
}

bool _chartValueSafe(Object? value) {
  return value == null ||
      value is num ||
      _boundedString(value, maxQuestionChartValueLength);
}

bool _chartKeyListSafe(Object? value, {required bool optional}) {
  if (value == null) {
    return optional;
  }

  if (value is! List || value.isEmpty || value.length > maxQuestionChartColumns) {
    return false;
  }

  final keys = <String>{};
  for (final item in value) {
    if (item is! String || !_chartKeySafe(item) || !keys.add(item)) {
      return false;
    }
  }

  return true;
}

bool _optionalChartKeySafe(Object? value) {
  return value == null || value is String && _chartKeySafe(value);
}

bool _chartKeySafe(String value) {
  return RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(value) &&
      value.length <= maxQuestionChartKeyLength;
}

Set<String>? _stringSet(Object? value) {
  if (value is! List || value.isEmpty) {
    return null;
  }

  final ids = <String>{};
  for (final item in value) {
    if (item is! String || item.trim().isEmpty || !ids.add(item)) {
      return null;
    }
  }

  return ids;
}

bool _numberInRange(
  Object? value, {
  required num min,
  required num max,
  required bool optional,
}) {
  if (value == null) {
    return optional;
  }

  return value is num && value >= min && value <= max;
}

bool _optionalPlainString(Object? value) {
  return value == null || _plainString(value);
}

bool _plainString(Object? value) {
  return _boundedString(value, maxActivityComponentTitleLength);
}

bool _optionalBoundedString(Object? value, int maxLength) {
  return value == null || _boundedString(value, maxLength);
}

bool _boundedString(Object? value, int maxLength) {
  return value is String &&
      value.trim().isNotEmpty &&
      value.runes.length <= maxLength &&
      !_containsUnsafeMarkup(value);
}

bool _containsUnsafeMarkup(String value) {
  final normalized = value.toLowerCase();
  return normalized.contains('<script') ||
      normalized.contains('<svg') ||
      normalized.contains('<iframe') ||
      normalized.contains('javascript:') ||
      normalized.contains('```mermaid') ||
      normalized.contains('graph td') ||
      normalized.contains('graph lr') ||
      normalized.contains('flowchart');
}

bool _hasOnlyKeys(Map<String, Object?> payload, Set<String> allowedKeys) {
  return payload.keys.every(allowedKeys.contains);
}

Map<String, Object?>? _jsonMap(Object? value) {
  if (value is! Map) {
    return null;
  }

  final result = <String, Object?>{};

  for (final entry in value.entries) {
    final key = entry.key;
    if (key is! String) {
      return null;
    }
    result[key] = entry.value;
  }

  return result;
}
~~~~

### test/features/activities/activity_correction_component_validator_test.dart

~~~~dart
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/genui/activity_correction_component_validator.dart';

void main() {
  group('activity correction GenUI validators', () {
    test('accepts valid McqQuestionCard payloads', () {
      expect(isMcqQuestionCardPayloadSafe(validQuestionPayload()), isTrue);
    });

    test('rejects McqQuestionCard correction leaks before submit', () {
      for (final entry in {
        'correctChoiceId': 'choice-a',
        'correctChoiceIds': ['choice-a'],
        'isCorrect': true,
        'explanation': 'Explication interdite.',
        'feedback': 'Feedback interdit.',
        'choiceFeedback': [
          {'choiceId': 'choice-a', 'feedback': 'Interdit'},
        ],
      }.entries) {
        expect(
          isMcqQuestionCardPayloadSafe({
            ...validQuestionPayload(),
            entry.key: entry.value,
          }),
          isFalse,
          reason: entry.key,
        );
      }
    });

    test('rejects McqQuestionCard source text before submit', () {
      expect(
        isMcqQuestionCardPayloadSafe({
          ...validQuestionPayload(),
          'sources': [
            {
              'chunkId': 'chunk-1',
              'text': 'Texte source interdit avant correction.',
              'pageNumber': null,
              'index': 0,
            },
          ],
        }),
        isFalse,
      );
    });

    test('rejects McqQuestionCard unknown fields and unsafe text', () {
      expect(
        isMcqQuestionCardPayloadSafe({
          ...validQuestionPayload(),
          'extra': true,
        }),
        isFalse,
      );
      expect(
        isMcqQuestionCardPayloadSafe({
          ...validQuestionPayload(),
          'prompt': '<script>alert(1)</script>',
        }),
        isFalse,
      );
    });

    test('accepts valid McqCorrectionPanel payloads', () {
      expect(isMcqCorrectionPanelPayloadSafe(validCorrectionPayload()), isTrue);
    });

    test('rejects invalid McqCorrectionPanel payloads', () {
      expect(
        isMcqCorrectionPanelPayloadSafe({
          ...validCorrectionPayload(),
          'selectedChoiceId': 'choice-a',
          'selectedChoiceIds': ['choice-a'],
        }),
        isFalse,
      );
      expect(
        isMcqCorrectionPanelPayloadSafe({
          ...validCorrectionPayload(),
          'explanation': '',
        }),
        isFalse,
      );
    });

    test('accepts and rejects ActivityResultCard payloads', () {
      expect(
        isActivityResultCardPayloadSafe({
          'title': 'Résultat',
          'status': 'completed',
          'correctAnswers': 7,
          'totalQuestions': 10,
          'score': 0.7,
          'message': 'Bon début.',
        }),
        isTrue,
      );
      expect(
        isActivityResultCardPayloadSafe({
          'title': 'Résultat',
          'status': 'completed',
          'correctAnswers': 11,
          'totalQuestions': 10,
        }),
        isFalse,
      );
    });

    test('accepts valid QuestionChartCard payloads', () {
      expect(isQuestionChartCardPayloadSafe(validChartPayload()), isTrue);
    });

    test('rejects unsafe or unbounded chart payloads', () {
      expect(
        isQuestionChartCardPayloadSafe({
          ...validChartPayload(),
          'chartType': 'radar',
        }),
        isFalse,
      );
      expect(
        isQuestionChartCardPayloadSafe({
          ...validChartPayload(),
          'data': List.generate(
            maxQuestionChartRows + 1,
            (index) => {'label': 'L$index', 'value': index},
          ),
        }),
        isFalse,
      );
      expect(
        isQuestionChartCardPayloadSafe({
          ...validChartPayload(),
          'data': [
            {
              for (var index = 0; index < maxQuestionChartColumns + 1; index++)
                'column$index': index,
            },
          ],
        }),
        isFalse,
      );
      expect(
        isQuestionChartCardPayloadSafe({
          ...validChartPayload(),
          'xKey': 'invalid key with spaces',
        }),
        isFalse,
      );
      expect(
        isQuestionChartCardPayloadSafe({
          ...validChartPayload(),
          'title': '<svg></svg>',
        }),
        isFalse,
      );
    });

    test('accepts valid QuestionDiagramCard payloads', () {
      expect(isQuestionDiagramCardPayloadSafe(validDiagramPayload()), isTrue);
    });

    test('rejects unsafe or incoherent diagram payloads', () {
      expect(
        isQuestionDiagramCardPayloadSafe({
          ...validDiagramPayload(),
          'edges': [
            {'from': 'node-1', 'to': 'missing-node'},
          ],
        }),
        isFalse,
      );
      expect(
        isQuestionDiagramCardPayloadSafe({
          ...validDiagramPayload(),
          'nodes': List.generate(
            maxQuestionDiagramNodes + 1,
            (index) => {'id': 'node-$index', 'label': 'Node $index'},
          ),
        }),
        isFalse,
      );
      expect(
        isQuestionDiagramCardPayloadSafe({
          ...validDiagramPayload(),
          'edges': List.generate(
            maxQuestionDiagramEdges + 1,
            (index) => {'from': 'node-1', 'to': 'node-2'},
          ),
        }),
        isFalse,
      );
      expect(
        isQuestionDiagramCardPayloadSafe({
          ...validDiagramPayload(),
          'description': '```mermaid\ngraph TD\n```',
        }),
        isFalse,
      );
    });

    test('rejects unknown components', () {
      expect(
        isActivityCorrectionComponentPayloadSafe('UnknownCard', {
          'title': 'Rien',
        }),
        isFalse,
      );
    });
  });
}

Map<String, Object?> validQuestionPayload() {
  return {
    'questionId': 'question-1',
    'displayOrder': 1,
    'totalQuestions': 10,
    'prompt': 'Quelle conséquence découle de cette règle ?',
    'difficulty': 'MEDIUM',
    'selectionMode': 'multiple',
    'minSelections': 1,
    'maxSelections': 2,
    'choices': [
      {'id': 'choice-a', 'label': 'Réponse A'},
      {'id': 'choice-b', 'label': 'Réponse B'},
    ],
    'selectedChoiceIds': ['choice-a'],
    'sources': [
      {'chunkId': 'chunk-1', 'pageNumber': null, 'index': 0},
    ],
    'visuals': [validChartPayload()],
  };
}

Map<String, Object?> validCorrectionPayload() {
  return {
    'questionId': 'question-1',
    'prompt': 'Quelle conséquence découle de cette règle ?',
    'selectionMode': 'single',
    'choices': [
      {'id': 'choice-a', 'label': 'Réponse A'},
      {'id': 'choice-b', 'label': 'Réponse B'},
    ],
    'selectedChoiceId': 'choice-a',
    'correctChoiceId': 'choice-b',
    'isCorrect': false,
    'partialScore': 0,
    'explanation': 'La réponse attendue découle du passage source.',
    'choiceFeedback': [
      {'choiceId': 'choice-a', 'feedback': 'Ce choix confond deux notions.'},
      {'choiceId': 'choice-b', 'feedback': 'Ce choix reprend la règle.'},
    ],
    'sources': [
      {
        'chunkId': 'chunk-1',
        'text': 'Extrait source post-submit.',
        'pageNumber': null,
        'index': 0,
      },
    ],
  };
}

Map<String, Object?> validChartPayload() {
  return {
    'visualId': 'visual-chart-1',
    'chartType': 'bar',
    'title': 'Répartition',
    'description': 'Comparaison bornée.',
    'data': [
      {'label': 'A', 'value': 2},
      {'label': 'B', 'value': 3},
    ],
    'xKey': 'label',
    'yKeys': ['value'],
    'sources': [
      {'chunkId': 'chunk-1', 'pageNumber': null, 'index': 0},
    ],
  };
}

Map<String, Object?> validDiagramPayload() {
  return {
    'visualId': 'visual-diagram-1',
    'title': 'Enchaînement',
    'description': 'Relation simple.',
    'nodes': [
      {'id': 'node-1', 'label': 'Règle'},
      {'id': 'node-2', 'label': 'Conséquence'},
    ],
    'edges': [
      {'from': 'node-1', 'to': 'node-2', 'label': 'implique'},
    ],
    'sources': [
      {'chunkId': 'chunk-1', 'pageNumber': null, 'index': 0},
    ],
  };
}
~~~~

### Fichiers modifiés — diff complet

~~~~diff
diff --git a/docs/ROADMAP_EXECUTION_PLAN.md b/docs/ROADMAP_EXECUTION_PLAN.md
index 2cd1ee8..3b04357 100644
--- a/docs/ROADMAP_EXECUTION_PLAN.md
+++ b/docs/ROADMAP_EXECUTION_PLAN.md
@@ -208,7 +208,7 @@ Ce tableau doit être mis à jour à chaque lot réalisé. Cette règle est éga
 | LOT-027 | Genkit question ouverte et correction | À faire | À créer |
 | LOT-028 | UI question ouverte corrigée | À faire | À créer |
 | LOT-029 | GenUI composants lecture sourcée | Réalisé | `docs/ROADMAP_EXECUTION_LOT_021_029.md` |
-| LOT-030 | GenUI composants activité et correction | À faire | À créer |
+| LOT-030 | GenUI composants activité et correction | Réalisé | `docs/ROADMAP_EXECUTION_LOT_030_GENUI_ACTIVITY_CORRECTION.md` |
 | LOT-031 | Session de révision IA minimale | À faire | À créer |
 | LOT-032 | Écran Révision IA minimal | À faire | À créer |
 | LOT-033 | Orchestration coach Genkit | À faire | À créer |
diff --git a/lib/features/activities/genui/revision_activity_catalog.dart b/lib/features/activities/genui/revision_activity_catalog.dart
index a238d54..8ac8dab 100644
--- a/lib/features/activities/genui/revision_activity_catalog.dart
+++ b/lib/features/activities/genui/revision_activity_catalog.dart
@@ -1,20 +1,27 @@
 import 'package:flutter/material.dart';
 import 'package:genui/genui.dart';
 import 'package:json_schema_builder/json_schema_builder.dart';
+import 'package:revision_app/features/activities/genui/activity_correction_component_validator.dart';
 import 'package:revision_app/features/activities/genui/sourced_reading_component_validator.dart';
 import 'package:revision_app/presentation/theme/app_colors.dart';
 import 'package:revision_app/presentation/theme/app_radius.dart';
 import 'package:revision_app/presentation/theme/app_spacing.dart';
 import 'package:revision_app/presentation/widgets/documents/document_source_excerpt.dart';
+import 'package:revision_app/presentation/widgets/revision_choice_tile.dart';
+import 'package:revision_app/presentation/widgets/revision_message.dart';
 import 'package:revision_app/presentation/widgets/revision_panel.dart';
+import 'package:revision_app/presentation/widgets/revision_status_pill.dart';
 
 const revisionActivityCatalogId = 'com.revision.activity_catalog';
 
 const _revisionActivityCatalogRules =
-    'Use QuestionCard for diagnostic quiz question prompts before rendering '
-    'the available answer choices with basic catalog widgets. Use SummaryCard, '
-    'KeyPointsList and SourceExcerptCard only for bounded sourced reading '
-    'content. Do not invent sources and do not render arbitrary widgets.';
+    'Use McqQuestionCard only for pre-submit MCQ rendering without correction '
+    'fields. Use McqCorrectionPanel and ActivityResultCard only for '
+    'post-submit correction and result data already computed by the backend. '
+    'Use QuestionChartCard and QuestionDiagramCard only for bounded validated '
+    'question visuals. Use SummaryCard, KeyPointsList and SourceExcerptCard '
+    'only for bounded sourced reading content. Do not invent sources, do not '
+    'render arbitrary widgets, HTML, SVG, Mermaid or JavaScript.';
 
 Catalog buildRevisionActivityCatalog() {
   final questionCardSchema = S.object(
@@ -166,14 +173,497 @@ Catalog buildRevisionActivityCatalog() {
     },
   );
 
+  final mcqQuestionCard = CatalogItem(
+    name: 'McqQuestionCard',
+    dataSchema: _mcqQuestionSchema(),
+    widgetBuilder: (itemContext) {
+      final json = _jsonMap(itemContext.data);
+      if (json == null || !isMcqQuestionCardPayloadSafe(json)) {
+        return _safeUnavailableComponent(itemContext.buildContext);
+      }
+      return _GenUiComponentFrame(child: _McqQuestionCard(payload: json));
+    },
+  );
+
+  final mcqCorrectionPanel = CatalogItem(
+    name: 'McqCorrectionPanel',
+    dataSchema: _mcqCorrectionSchema(),
+    widgetBuilder: (itemContext) {
+      final json = _jsonMap(itemContext.data);
+      if (json == null || !isMcqCorrectionPanelPayloadSafe(json)) {
+        return _safeUnavailableComponent(itemContext.buildContext);
+      }
+      return _GenUiComponentFrame(child: _McqCorrectionPanel(payload: json));
+    },
+  );
+
+  final activityResultCard = CatalogItem(
+    name: 'ActivityResultCard',
+    dataSchema: _activityResultSchema(),
+    widgetBuilder: (itemContext) {
+      final json = _jsonMap(itemContext.data);
+      if (json == null || !isActivityResultCardPayloadSafe(json)) {
+        return _safeUnavailableComponent(itemContext.buildContext);
+      }
+      return _GenUiComponentFrame(child: _ActivityResultCard(payload: json));
+    },
+  );
+
+  final questionChartCard = CatalogItem(
+    name: 'QuestionChartCard',
+    dataSchema: _questionChartSchema(),
+    widgetBuilder: (itemContext) {
+      final json = _jsonMap(itemContext.data);
+      if (json == null || !isQuestionChartCardPayloadSafe(json)) {
+        return _safeUnavailableComponent(itemContext.buildContext);
+      }
+      return _GenUiComponentFrame(child: _QuestionChartCard(payload: json));
+    },
+  );
+
+  final questionDiagramCard = CatalogItem(
+    name: 'QuestionDiagramCard',
+    dataSchema: _questionDiagramSchema(),
+    widgetBuilder: (itemContext) {
+      final json = _jsonMap(itemContext.data);
+      if (json == null || !isQuestionDiagramCardPayloadSafe(json)) {
+        return _safeUnavailableComponent(itemContext.buildContext);
+      }
+      return _GenUiComponentFrame(child: _QuestionDiagramCard(payload: json));
+    },
+  );
+
   return BasicCatalogItems.asNoAssetCatalog(
     systemPromptFragments: const [_revisionActivityCatalogRules],
   ).copyWith(
-    newItems: [questionCard, summaryCard, keyPointsList, sourceExcerptCard],
+    newItems: [
+      questionCard,
+      summaryCard,
+      keyPointsList,
+      sourceExcerptCard,
+      mcqQuestionCard,
+      mcqCorrectionPanel,
+      activityResultCard,
+      questionChartCard,
+      questionDiagramCard,
+    ],
     catalogId: revisionActivityCatalogId,
   );
 }
 
+Schema _mcqQuestionSchema() {
+  return S.object(
+    properties: {
+      'questionId': S.string(minLength: 1),
+      'displayOrder': S.integer(minimum: 1),
+      'totalQuestions': S.integer(minimum: 1),
+      'prompt': S.string(maxLength: maxActivityComponentPromptLength),
+      'difficulty': S.string(enumValues: ['LOW', 'MEDIUM', 'HIGH']),
+      'selectionMode': S.string(enumValues: ['single', 'multiple']),
+      'minSelections': S.integer(minimum: 1),
+      'maxSelections': S.integer(minimum: 1),
+      'choices': S.list(items: S.any(), minItems: 2, maxItems: maxActivityChoices),
+      'selectedChoiceId': S.string(minLength: 1),
+      'selectedChoiceIds': S.list(items: S.string(minLength: 1)),
+      'sources': S.list(items: S.any(), maxItems: maxActivitySources),
+      'visuals': S.list(items: S.any(), maxItems: maxQuestionVisuals),
+    },
+    required: [
+      'questionId',
+      'displayOrder',
+      'totalQuestions',
+      'prompt',
+      'selectionMode',
+      'choices',
+    ],
+    additionalProperties: false,
+  );
+}
+
+Schema _mcqCorrectionSchema() {
+  return S.object(
+    properties: {
+      'questionId': S.string(minLength: 1),
+      'knowledgeUnitId': S.string(minLength: 1),
+      'prompt': S.string(maxLength: maxActivityComponentPromptLength),
+      'selectionMode': S.string(enumValues: ['single', 'multiple']),
+      'choices': S.list(items: S.any(), minItems: 2, maxItems: maxActivityChoices),
+      'selectedChoiceId': S.string(minLength: 1),
+      'correctChoiceId': S.string(minLength: 1),
+      'selectedChoiceIds': S.list(items: S.string(minLength: 1)),
+      'correctChoiceIds': S.list(items: S.string(minLength: 1)),
+      'isCorrect': S.boolean(),
+      'partialScore': S.number(minimum: 0, maximum: 1),
+      'explanation': S.string(maxLength: maxActivityExplanationLength),
+      'choiceFeedback': S.list(items: S.any(), maxItems: maxActivityFeedbackItems),
+      'sources': S.list(items: S.any(), maxItems: maxActivitySources),
+    },
+    required: [
+      'questionId',
+      'prompt',
+      'selectionMode',
+      'choices',
+      'isCorrect',
+      'explanation',
+    ],
+    additionalProperties: false,
+  );
+}
+
+Schema _activityResultSchema() {
+  return S.object(
+    properties: {
+      'title': S.string(maxLength: maxActivityComponentTitleLength),
+      'status': S.string(maxLength: maxActivityComponentTitleLength),
+      'correctAnswers': S.integer(minimum: 0),
+      'totalQuestions': S.integer(minimum: 1),
+      'score': S.number(minimum: 0, maximum: 1),
+      'partialScore': S.number(minimum: 0, maximum: 1),
+      'message': S.string(maxLength: maxActivityComponentDescriptionLength),
+      'primaryActionLabel': S.string(maxLength: maxActivityComponentActionLabelLength),
+      'secondaryActionLabel': S.string(maxLength: maxActivityComponentActionLabelLength),
+    },
+    required: ['title', 'status', 'correctAnswers', 'totalQuestions'],
+    additionalProperties: false,
+  );
+}
+
+Schema _questionChartSchema() {
+  return S.object(
+    properties: {
+      'visualId': S.string(minLength: 1),
+      'chartType': S.string(enumValues: ['bar', 'line', 'pie', 'scatter']),
+      'title': S.string(maxLength: maxActivityComponentTitleLength),
+      'description': S.string(maxLength: maxActivityComponentDescriptionLength),
+      'data': S.list(items: S.any(), minItems: 1, maxItems: maxQuestionChartRows),
+      'xKey': S.string(maxLength: maxQuestionChartKeyLength),
+      'yKeys': S.list(
+        items: S.string(maxLength: maxQuestionChartKeyLength),
+        maxItems: maxQuestionChartColumns,
+      ),
+      'sources': S.list(items: S.any(), maxItems: maxActivitySources),
+    },
+    required: ['visualId', 'chartType', 'title', 'data', 'sources'],
+    additionalProperties: false,
+  );
+}
+
+Schema _questionDiagramSchema() {
+  return S.object(
+    properties: {
+      'visualId': S.string(minLength: 1),
+      'title': S.string(maxLength: maxActivityComponentTitleLength),
+      'description': S.string(maxLength: maxActivityComponentDescriptionLength),
+      'nodes': S.list(items: S.any(), minItems: 1, maxItems: maxQuestionDiagramNodes),
+      'edges': S.list(items: S.any(), maxItems: maxQuestionDiagramEdges),
+      'sources': S.list(items: S.any(), maxItems: maxActivitySources),
+    },
+    required: ['visualId', 'title', 'nodes', 'sources'],
+    additionalProperties: false,
+  );
+}
+
+Widget _safeUnavailableComponent(BuildContext context) {
+  return _GenUiComponentFrame(
+    child: RevisionMessage(
+      message: 'Composant GenUI indisponible',
+      color: Theme.of(context).colorScheme.error,
+      icon: Icons.warning_amber_rounded,
+    ),
+  );
+}
+
+class _McqQuestionCard extends StatelessWidget {
+  const _McqQuestionCard({required this.payload});
+
+  final JsonMap payload;
+
+  @override
+  Widget build(BuildContext context) {
+    final choices = _choiceList(payload['choices']);
+    final selectedIds = _selectedIds(payload);
+    final visuals = _visualList(payload['visuals']);
+    final selectionMode = payload['selectionMode'] as String;
+    final displayOrder = payload['displayOrder'] as int;
+    final totalQuestions = payload['totalQuestions'] as int;
+
+    return RevisionPanel(
+      child: Column(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: [
+          Wrap(
+            spacing: AppSpacing.s,
+            runSpacing: AppSpacing.xs,
+            children: [
+              RevisionStatusPill(
+                label: 'Question $displayOrder / $totalQuestions',
+                color: Theme.of(context).colorScheme.primary,
+              ),
+              if (payload['difficulty'] case final String difficulty)
+                RevisionStatusPill(
+                  label: difficulty,
+                  color: AppColors.amber,
+                ),
+              RevisionStatusPill(
+                label: selectionMode == 'multiple'
+                    ? 'Plusieurs réponses possibles'
+                    : 'Une seule réponse',
+                color: AppColors.primary,
+              ),
+            ],
+          ),
+          const SizedBox(height: AppSpacing.m),
+          Text(
+            payload['prompt'] as String,
+            style: Theme.of(context).textTheme.titleMedium,
+          ),
+          if (visuals.isNotEmpty) ...[
+            const SizedBox(height: AppSpacing.m),
+            Column(spacing: AppSpacing.s, children: visuals),
+          ],
+          const SizedBox(height: AppSpacing.m),
+          Text(
+            'Sources disponibles après correction',
+            style: Theme.of(context).textTheme.bodySmall,
+          ),
+          const SizedBox(height: AppSpacing.m),
+          Column(
+            spacing: AppSpacing.s,
+            children: [
+              for (final choice in choices)
+                RevisionChoiceTile(
+                  label: choice.label,
+                  selected: selectedIds.contains(choice.id),
+                  enabled: false,
+                ),
+            ],
+          ),
+        ],
+      ),
+    );
+  }
+}
+
+class _McqCorrectionPanel extends StatelessWidget {
+  const _McqCorrectionPanel({required this.payload});
+
+  final JsonMap payload;
+
+  @override
+  Widget build(BuildContext context) {
+    final choices = _choiceList(payload['choices']);
+    final selectedIds = _selectedCorrectionIds(payload);
+    final correctIds = _correctCorrectionIds(payload);
+    final isCorrect = payload['isCorrect'] as bool;
+    final feedback = _feedbackList(payload['choiceFeedback']);
+    final sources = _sourceList(payload['sources']);
+
+    return RevisionPanel(
+      child: Column(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: [
+          Wrap(
+            spacing: AppSpacing.s,
+            runSpacing: AppSpacing.xs,
+            children: [
+              RevisionStatusPill(
+                label: isCorrect ? 'Correct' : 'À revoir',
+                color: isCorrect ? AppColors.primary : AppColors.coral,
+              ),
+              if (payload['partialScore'] case final num partialScore)
+                RevisionStatusPill(
+                  label: '${(partialScore * 100).round()} %',
+                  color: Theme.of(context).colorScheme.primary,
+                ),
+            ],
+          ),
+          const SizedBox(height: AppSpacing.m),
+          Text(
+            payload['prompt'] as String,
+            style: Theme.of(context).textTheme.titleMedium,
+          ),
+          const SizedBox(height: AppSpacing.m),
+          _AnswerSummary(
+            title: 'Réponse sélectionnée',
+            labels: _labelsForIds(choices, selectedIds),
+          ),
+          const SizedBox(height: AppSpacing.s),
+          _AnswerSummary(
+            title: 'Réponse attendue',
+            labels: _labelsForIds(choices, correctIds),
+          ),
+          const SizedBox(height: AppSpacing.m),
+          Text(payload['explanation'] as String),
+          if (feedback.isNotEmpty) ...[
+            const SizedBox(height: AppSpacing.m),
+            _CatalogTextList(title: 'Feedback', items: feedback),
+          ],
+          if (sources.isNotEmpty) ...[
+            const SizedBox(height: AppSpacing.m),
+            Column(
+              spacing: AppSpacing.s,
+              children: [
+                for (final source in sources)
+                  DocumentSourceExcerpt(
+                    text: source.text,
+                    index: source.index,
+                    pageNumber: source.pageNumber,
+                    label: source.label,
+                  ),
+              ],
+            ),
+          ],
+        ],
+      ),
+    );
+  }
+}
+
+class _ActivityResultCard extends StatelessWidget {
+  const _ActivityResultCard({required this.payload});
+
+  final JsonMap payload;
+
+  @override
+  Widget build(BuildContext context) {
+    final score = payload['score'];
+    return RevisionPanel(
+      child: Column(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: [
+          Text(
+            payload['title'] as String,
+            style: Theme.of(context).textTheme.titleMedium,
+          ),
+          const SizedBox(height: AppSpacing.m),
+          Wrap(
+            spacing: AppSpacing.s,
+            runSpacing: AppSpacing.xs,
+            children: [
+              RevisionStatusPill(
+                label:
+                    '${payload['correctAnswers']} / ${payload['totalQuestions']}',
+                color: Theme.of(context).colorScheme.primary,
+              ),
+              RevisionStatusPill(
+                label: payload['status'] as String,
+                color: AppColors.primary,
+              ),
+              if (score is num)
+                RevisionStatusPill(
+                  label: '${(score * 100).round()} %',
+                  color: AppColors.amber,
+                ),
+            ],
+          ),
+          if (payload['message'] case final String message) ...[
+            const SizedBox(height: AppSpacing.m),
+            Text(message),
+          ],
+        ],
+      ),
+    );
+  }
+}
+
+class _QuestionChartCard extends StatelessWidget {
+  const _QuestionChartCard({required this.payload});
+
+  final JsonMap payload;
+
+  @override
+  Widget build(BuildContext context) {
+    final rows = _chartRows(payload['data']);
+    return RevisionPanel(
+      child: Column(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: [
+          Wrap(
+            spacing: AppSpacing.s,
+            runSpacing: AppSpacing.xs,
+            children: [
+              RevisionStatusPill(
+                label: payload['chartType'] as String,
+                color: Theme.of(context).colorScheme.primary,
+              ),
+              RevisionStatusPill(label: 'Graphique', color: AppColors.primary),
+            ],
+          ),
+          const SizedBox(height: AppSpacing.m),
+          Text(
+            payload['title'] as String,
+            style: Theme.of(context).textTheme.titleMedium,
+          ),
+          if (payload['description'] case final String description) ...[
+            const SizedBox(height: AppSpacing.s),
+            Text(description),
+          ],
+          const SizedBox(height: AppSpacing.m),
+          Column(
+            crossAxisAlignment: CrossAxisAlignment.start,
+            spacing: AppSpacing.xs,
+            children: [for (final row in rows) Text(row)],
+          ),
+        ],
+      ),
+    );
+  }
+}
+
+class _QuestionDiagramCard extends StatelessWidget {
+  const _QuestionDiagramCard({required this.payload});
+
+  final JsonMap payload;
+
+  @override
+  Widget build(BuildContext context) {
+    final nodes = _diagramNodes(payload['nodes']);
+    final edges = _diagramEdges(payload['edges']);
+    return RevisionPanel(
+      child: Column(
+        crossAxisAlignment: CrossAxisAlignment.start,
+        children: [
+          RevisionStatusPill(label: 'Diagramme', color: AppColors.primary),
+          const SizedBox(height: AppSpacing.m),
+          Text(
+            payload['title'] as String,
+            style: Theme.of(context).textTheme.titleMedium,
+          ),
+          if (payload['description'] case final String description) ...[
+            const SizedBox(height: AppSpacing.s),
+            Text(description),
+          ],
+          const SizedBox(height: AppSpacing.m),
+          _CatalogTextList(title: 'Étapes', items: nodes),
+          if (edges.isNotEmpty) ...[
+            const SizedBox(height: AppSpacing.m),
+            _CatalogTextList(title: 'Relations', items: edges),
+          ],
+        ],
+      ),
+    );
+  }
+}
+
+class _AnswerSummary extends StatelessWidget {
+  const _AnswerSummary({required this.title, required this.labels});
+
+  final String title;
+  final List<String> labels;
+
+  @override
+  Widget build(BuildContext context) {
+    return Column(
+      crossAxisAlignment: CrossAxisAlignment.start,
+      children: [
+        Text(title, style: Theme.of(context).textTheme.titleSmall),
+        const SizedBox(height: AppSpacing.xs),
+        for (final label in labels) Text(label),
+      ],
+    );
+  }
+}
+
 class _GenUiComponentFrame extends StatelessWidget {
   const _GenUiComponentFrame({required this.child});
 
@@ -277,6 +767,20 @@ class _CatalogSource {
   }
 }
 
+class _CatalogChoice {
+  const _CatalogChoice({required this.id, required this.label});
+
+  final String id;
+  final String label;
+
+  factory _CatalogChoice.fromJson(JsonMap json) {
+    return _CatalogChoice(
+      id: json['id'] as String,
+      label: json['label'] as String,
+    );
+  }
+}
+
 List<String> _stringList(Object? value) {
   if (value is! List) {
     return const [];
@@ -291,7 +795,146 @@ List<_CatalogSource> _sourceList(Object? value) {
   }
 
   return value
+      .map(_jsonMap)
       .whereType<JsonMap>()
       .map(_CatalogSource.fromJson)
       .toList(growable: false);
 }
+
+List<_CatalogChoice> _choiceList(Object? value) {
+  if (value is! List) {
+    return const [];
+  }
+
+  return value
+      .map(_jsonMap)
+      .whereType<JsonMap>()
+      .map(_CatalogChoice.fromJson)
+      .toList(growable: false);
+}
+
+List<String> _selectedIds(JsonMap payload) {
+  if (payload['selectedChoiceId'] case final String id) {
+    return [id];
+  }
+
+  return _stringList(payload['selectedChoiceIds']);
+}
+
+List<String> _selectedCorrectionIds(JsonMap payload) {
+  if (payload['selectedChoiceId'] case final String id) {
+    return [id];
+  }
+
+  return _stringList(payload['selectedChoiceIds']);
+}
+
+List<String> _correctCorrectionIds(JsonMap payload) {
+  if (payload['correctChoiceId'] case final String id) {
+    return [id];
+  }
+
+  return _stringList(payload['correctChoiceIds']);
+}
+
+List<String> _labelsForIds(List<_CatalogChoice> choices, List<String> ids) {
+  final labelsById = {for (final choice in choices) choice.id: choice.label};
+  return [
+    for (final id in ids)
+      if (labelsById[id] case final String label) label,
+  ];
+}
+
+List<String> _feedbackList(Object? value) {
+  if (value is! List) {
+    return const [];
+  }
+
+  return value
+      .map(_jsonMap)
+      .whereType<JsonMap>()
+      .map((payload) => payload['feedback'])
+      .whereType<String>()
+      .toList(growable: false);
+}
+
+List<Widget> _visualList(Object? value) {
+  if (value is! List) {
+    return const [];
+  }
+
+  return value
+      .map(_jsonMap)
+      .whereType<JsonMap>()
+      .map((payload) {
+        if (isQuestionChartCardPayloadSafe(payload)) {
+          return _QuestionChartCard(payload: payload);
+        }
+        if (isQuestionDiagramCardPayloadSafe(payload)) {
+          return _QuestionDiagramCard(payload: payload);
+        }
+        return null;
+      })
+      .whereType<Widget>()
+      .toList(growable: false);
+}
+
+List<String> _chartRows(Object? value) {
+  if (value is! List) {
+    return const [];
+  }
+
+  return value.map(_jsonMap).whereType<JsonMap>().map((row) {
+    return row.entries.map((entry) => '${entry.key}: ${entry.value}').join(' · ');
+  }).toList(growable: false);
+}
+
+List<String> _diagramNodes(Object? value) {
+  if (value is! List) {
+    return const [];
+  }
+
+  return value
+      .map(_jsonMap)
+      .whereType<JsonMap>()
+      .map((node) => node['label'])
+      .whereType<String>()
+      .toList(growable: false);
+}
+
+List<String> _diagramEdges(Object? value) {
+  if (value is! List) {
+    return const [];
+  }
+
+  return value
+      .map(_jsonMap)
+      .whereType<JsonMap>()
+      .map((edge) {
+        final from = edge['from'];
+        final to = edge['to'];
+        if (from is! String || to is! String) {
+          return null;
+        }
+        return '$from → $to';
+      })
+      .whereType<String>()
+      .toList(growable: false);
+}
+
+JsonMap? _jsonMap(Object? value) {
+  if (value is! Map) {
+    return null;
+  }
+
+  final result = <String, Object?>{};
+  for (final entry in value.entries) {
+    final key = entry.key;
+    if (key is! String) {
+      return null;
+    }
+    result[key] = entry.value;
+  }
+
+  return result;
+}
diff --git a/test/features/activities/revision_activity_catalog_test.dart b/test/features/activities/revision_activity_catalog_test.dart
index 16ecb87..ae1b7ae 100644
--- a/test/features/activities/revision_activity_catalog_test.dart
+++ b/test/features/activities/revision_activity_catalog_test.dart
@@ -15,6 +15,11 @@ void main() {
       expect(itemNames, contains('SummaryCard'));
       expect(itemNames, contains('KeyPointsList'));
       expect(itemNames, contains('SourceExcerptCard'));
+      expect(itemNames, contains('McqQuestionCard'));
+      expect(itemNames, contains('McqCorrectionPanel'));
+      expect(itemNames, contains('ActivityResultCard'));
+      expect(itemNames, contains('QuestionChartCard'));
+      expect(itemNames, contains('QuestionDiagramCard'));
       expect(itemNames, contains('Text'));
       expect(itemNames, contains('Column'));
       expect(itemNames, isNot(contains('Image')));
@@ -39,6 +44,11 @@ void main() {
       expect(components, contains('SummaryCard'));
       expect(components, contains('KeyPointsList'));
       expect(components, contains('SourceExcerptCard'));
+      expect(components, contains('McqQuestionCard'));
+      expect(components, contains('McqCorrectionPanel'));
+      expect(components, contains('ActivityResultCard'));
+      expect(components, contains('QuestionChartCard'));
+      expect(components, contains('QuestionDiagramCard'));
 
       final questionCard = components['QuestionCard'] as Map<String, Object?>;
       expect(questionCard['required'], containsAll(['component', 'prompt']));
@@ -54,6 +64,90 @@ void main() {
       expect(summaryCard['additionalProperties'], isFalse);
     });
 
+    testWidgets('renders activity and correction components with safe payloads', (
+      tester,
+    ) async {
+      final catalog = buildRevisionActivityCatalog();
+
+      await tester.pumpWidget(
+        MaterialApp(
+          home: SingleChildScrollView(
+            child: Column(
+              children: [
+                catalogWidget(
+                  catalog,
+                  type: 'McqQuestionCard',
+                  data: mcqQuestionPayload(),
+                ),
+                catalogWidget(
+                  catalog,
+                  type: 'McqCorrectionPanel',
+                  data: mcqCorrectionPayload(),
+                ),
+                catalogWidget(
+                  catalog,
+                  type: 'ActivityResultCard',
+                  data: {
+                    'title': 'Résultat',
+                    'status': 'completed',
+                    'correctAnswers': 7,
+                    'totalQuestions': 10,
+                    'score': 0.7,
+                    'message': 'Bon début.',
+                  },
+                ),
+                catalogWidget(
+                  catalog,
+                  type: 'QuestionChartCard',
+                  data: chartPayload(),
+                ),
+                catalogWidget(
+                  catalog,
+                  type: 'QuestionDiagramCard',
+                  data: diagramPayload(),
+                ),
+              ],
+            ),
+          ),
+        ),
+      );
+
+      expect(find.text('Quelle conséquence découle de cette règle ?'), findsNWidgets(2));
+      expect(find.text('Plusieurs réponses possibles'), findsOneWidget);
+      expect(find.text('Réponse A'), findsWidgets);
+      expect(find.text('Réponse attendue'), findsOneWidget);
+      expect(find.text('La réponse attendue découle du passage source.'), findsOneWidget);
+      expect(find.text('7 / 10'), findsOneWidget);
+      expect(find.text('Répartition'), findsOneWidget);
+      expect(find.text('Enchaînement'), findsOneWidget);
+      expect(find.text('node-1 → node-2'), findsOneWidget);
+    });
+
+    testWidgets('uses a safe fallback for invalid McqQuestionCard payloads', (
+      tester,
+    ) async {
+      final catalog = buildRevisionActivityCatalog();
+
+      await tester.pumpWidget(
+        MaterialApp(
+          home: catalogWidget(
+            catalog,
+            type: 'McqQuestionCard',
+            data: {
+              ...mcqQuestionPayload(),
+              'correctChoiceId': 'choice-a',
+              'explanation': 'Explication qui ne doit pas fuiter.',
+            },
+          ),
+        ),
+      );
+
+      expect(find.text('Composant GenUI indisponible'), findsOneWidget);
+      expect(find.text('choice-a'), findsNothing);
+      expect(find.text('Explication qui ne doit pas fuiter.'), findsNothing);
+      expect(find.text('Quelle conséquence découle de cette règle ?'), findsNothing);
+    });
+
     testWidgets('renders sourced reading components with bounded payloads', (
       tester,
     ) async {
@@ -114,45 +208,77 @@ void main() {
 
       await tester.pumpWidget(
         MaterialApp(
-          home: Column(
-            children: [
-              catalogWidget(
-                catalog,
-                type: 'QuestionCard',
-                data: {'prompt': 'Quelle est la bonne réponse ?'},
-              ),
-              catalogWidget(
-                catalog,
-                type: 'SummaryCard',
-                data: {
-                  'title': 'Résumé',
-                  'content': 'Contenu synthétique.',
-                  'keyPoints': ['Point 1'],
-                },
-              ),
-              catalogWidget(
-                catalog,
-                type: 'KeyPointsList',
-                data: {
-                  'title': 'Points clés',
-                  'items': ['Point A'],
-                },
-              ),
-              catalogWidget(
-                catalog,
-                type: 'SourceExcerptCard',
-                data: {
-                  'text': 'Source isolée.',
-                  'pageNumber': null,
-                  'index': 1,
-                },
-              ),
-            ],
+          home: SingleChildScrollView(
+            child: Column(
+              children: [
+                catalogWidget(
+                  catalog,
+                  type: 'QuestionCard',
+                  data: {'prompt': 'Quelle est la bonne réponse ?'},
+                ),
+                catalogWidget(
+                  catalog,
+                  type: 'SummaryCard',
+                  data: {
+                    'title': 'Résumé',
+                    'content': 'Contenu synthétique.',
+                    'keyPoints': ['Point 1'],
+                  },
+                ),
+                catalogWidget(
+                  catalog,
+                  type: 'KeyPointsList',
+                  data: {
+                    'title': 'Points clés',
+                    'items': ['Point A'],
+                  },
+                ),
+                catalogWidget(
+                  catalog,
+                  type: 'SourceExcerptCard',
+                  data: {
+                    'text': 'Source isolée.',
+                    'pageNumber': null,
+                    'index': 1,
+                  },
+                ),
+                catalogWidget(
+                  catalog,
+                  type: 'McqQuestionCard',
+                  data: mcqQuestionPayload(),
+                ),
+                catalogWidget(
+                  catalog,
+                  type: 'McqCorrectionPanel',
+                  data: mcqCorrectionPayload(),
+                ),
+                catalogWidget(
+                  catalog,
+                  type: 'ActivityResultCard',
+                  data: {
+                    'title': 'Résultat',
+                    'status': 'completed',
+                    'correctAnswers': 1,
+                    'totalQuestions': 2,
+                  },
+                ),
+                catalogWidget(
+                  catalog,
+                  type: 'QuestionChartCard',
+                  data: chartPayload(),
+                ),
+                catalogWidget(
+                  catalog,
+                  type: 'QuestionDiagramCard',
+                  data: diagramPayload(),
+                ),
+              ],
+            ),
           ),
         ),
       );
 
-      expect(find.text('genUI'), findsNWidgets(4));
+      expect(find.text('genUI'), findsNWidgets(9));
     });
   });
 }
@@ -183,3 +309,89 @@ Widget catalogWidget(
     },
   );
 }
+
+Map<String, Object?> mcqQuestionPayload() {
+  return {
+    'questionId': 'question-1',
+    'displayOrder': 1,
+    'totalQuestions': 10,
+    'prompt': 'Quelle conséquence découle de cette règle ?',
+    'difficulty': 'MEDIUM',
+    'selectionMode': 'multiple',
+    'minSelections': 1,
+    'maxSelections': 2,
+    'choices': [
+      {'id': 'choice-a', 'label': 'Réponse A'},
+      {'id': 'choice-b', 'label': 'Réponse B'},
+    ],
+    'selectedChoiceIds': ['choice-a'],
+    'sources': [
+      {'chunkId': 'chunk-1', 'pageNumber': null, 'index': 0},
+    ],
+  };
+}
+
+Map<String, Object?> mcqCorrectionPayload() {
+  return {
+    'questionId': 'question-1',
+    'prompt': 'Quelle conséquence découle de cette règle ?',
+    'selectionMode': 'single',
+    'choices': [
+      {'id': 'choice-a', 'label': 'Réponse A'},
+      {'id': 'choice-b', 'label': 'Réponse B'},
+    ],
+    'selectedChoiceId': 'choice-a',
+    'correctChoiceId': 'choice-b',
+    'isCorrect': false,
+    'partialScore': 0,
+    'explanation': 'La réponse attendue découle du passage source.',
+    'choiceFeedback': [
+      {'choiceId': 'choice-a', 'feedback': 'Ce choix confond deux notions.'},
+      {'choiceId': 'choice-b', 'feedback': 'Ce choix reprend la règle.'},
+    ],
+    'sources': [
+      {
+        'chunkId': 'chunk-1',
+        'text': 'Extrait source post-submit.',
+        'pageNumber': null,
+        'index': 0,
+      },
+    ],
+  };
+}
+
+Map<String, Object?> chartPayload() {
+  return {
+    'visualId': 'visual-chart-1',
+    'chartType': 'bar',
+    'title': 'Répartition',
+    'description': 'Comparaison bornée.',
+    'data': [
+      {'label': 'A', 'value': 2},
+      {'label': 'B', 'value': 3},
+    ],
+    'xKey': 'label',
+    'yKeys': ['value'],
+    'sources': [
+      {'chunkId': 'chunk-1', 'pageNumber': null, 'index': 0},
+    ],
+  };
+}
+
+Map<String, Object?> diagramPayload() {
+  return {
+    'visualId': 'visual-diagram-1',
+    'title': 'Enchaînement',
+    'description': 'Relation simple.',
+    'nodes': [
+      {'id': 'node-1', 'label': 'Règle'},
+      {'id': 'node-2', 'label': 'Conséquence'},
+    ],
+    'edges': [
+      {'from': 'node-1', 'to': 'node-2', 'label': 'implique'},
+    ],
+    'sources': [
+      {'chunkId': 'chunk-1', 'pageNumber': null, 'index': 0},
+    ],
+  };
+}
~~~~
