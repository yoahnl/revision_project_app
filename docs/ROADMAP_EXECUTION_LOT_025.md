# LOT-025 — UI QCM enrichi

## 1. Résultat

`LOT-025` adapte le frontend Flutter au QCM enrichi produit par le backend `LOT-024`, sans modifier le backend.

Le frontend sait maintenant :

- parser le QCM v2 pré-submit avec `version`, `documentId`, `subjectId`, `knowledgeUnitId`, `difficulty` et références sources non textuelles ;
- soumettre une réponse mono-choix par question via le contrat existant `POST /activities/:sessionId/result` ;
- parser un résultat enrichi avec `score`, correction détaillée, feedback par choix et sources textuelles ;
- afficher une UI pré-submit sans fuite de correction ;
- afficher après submit le score, la bonne réponse, la réponse sélectionnée, l'explication, le feedback et les sources ;
- gérer un QCM long, testé avec 15 questions, sans limite artificielle à 2 ou 3 questions.

Aucun support fake n'a été ajouté pour images, graphiques ou multi-réponse.

## 2. Sources inspectées

Documentation :

- `docs/ROADMAP.md`
- `docs/ROADMAP_EXECUTION_PLAN.md`
- `docs/ROADMAP_EXECUTION_LOT_022.md`
- `docs/ROADMAP_EXECUTION_LOT_023.md`
- `docs/ROADMAP_EXECUTION_LOT_024.md`
- `docs/ROADMAP_EXECUTION_HOTFIX_024B_AI_MODEL_FALLBACK.md`
- `AGENTS.md`
- `codex_rule.md`

Frontend :

- `pubspec.yaml`
- `lib/features/activities/domain/diagnostic_quiz_activity.dart`
- `lib/features/activities/application/activity_controller.dart`
- `lib/features/activities/data/http_activities_api.dart`
- `lib/features/activities/data/demo_activity_api.dart`
- `lib/presentation/pages/activities/activities_page.dart`
- `lib/presentation/pages/activities/diagnostic_quiz_page.dart`
- `lib/features/activities/genui/diagnostic_quiz_activity_validator.dart`
- `lib/features/activities/genui/revision_activity_catalog.dart`
- `lib/presentation/widgets/revision_button.dart`
- `lib/presentation/widgets/revision_choice_tile.dart`
- `lib/presentation/widgets/revision_panel.dart`
- `lib/presentation/widgets/revision_status_pill.dart`
- `lib/presentation/widgets/revision_message.dart`
- `lib/presentation/widgets/documents/document_source_excerpt.dart`
- `test/features/activities/http_activities_api_test.dart`
- `test/features/activities/activity_controller_test.dart`
- `test/features/activities/diagnostic_quiz_page_test.dart`
- `test/features/activities/diagnostic_quiz_activity_validator_test.dart`
- `test/features/activities/revision_activity_catalog_test.dart`
- `test/features/activities/sourced_reading_component_validator_test.dart`
- `test/fakes/in_memory_activity_api.dart`

Backend en lecture seule :

- `api/src/modules/activities/interfaces/activities.controller.ts`
- `api/src/modules/activities/application/start-next-activity.use-case.ts`
- `api/src/modules/activities/application/submit-activity-result.use-case.ts`
- `api/src/modules/activities/application/activities.repository.ts`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.ts`
- `api/prisma/schema.prisma`

## 3. Préflight Git

État initial API :

```text
## main...origin/main
```

État initial frontend :

```text
## main...origin/main
```

Fichiers modifiés/non suivis existants au préflight :

- Aucun fichier listé par `git status --short --branch --untracked-files=all` côté API.
- Aucun fichier listé par `git status --short --branch --untracked-files=all` côté `revision_app`.

Décision :

- Backend, Prisma, Genkit, GenUI, TodayPlan, upload et Dokploy laissés intacts.
- Les fichiers hors scope n'ont pas été modifiés.

## 4. Contrat API consommé

Endpoints conservés :

- `POST /activities/next`
- `POST /activities/:sessionId/result`

Pré-submit consommé par Flutter :

```json
{
  "sessionId": "session-1",
  "type": "diagnostic_quiz",
  "version": 2,
  "documentId": "document-1",
  "subjectId": "subject-1",
  "title": "Diagnostic sourcé",
  "questions": [
    {
      "id": "question-1",
      "knowledgeUnitId": "unit-1",
      "prompt": "Question ?",
      "difficulty": "MEDIUM",
      "choices": [
        {
          "id": "a",
          "label": "Réponse A"
        }
      ],
      "sources": [
        {
          "chunkId": "chunk-1",
          "pageNumber": null,
          "index": 0
        }
      ]
    }
  ]
}
```

Pré-submit ignoré par Flutter même si le backend l'envoyait par erreur :

- `correctChoiceId`
- `isCorrect`
- `explanation`
- `feedback`
- `sources[].text`

Post-submit consommé par Flutter :

```json
{
  "correctAnswers": 0,
  "totalQuestions": 1,
  "score": 0,
  "items": [
    {
      "questionId": "question-1",
      "knowledgeUnitId": "unit-1",
      "prompt": "Question ?",
      "selectedChoiceId": "b",
      "correctChoiceId": "a",
      "isCorrect": false,
      "explanation": "Explication pédagogique.",
      "choiceFeedback": [
        {
          "choiceId": "b",
          "feedback": "Pourquoi ce choix était incorrect."
        }
      ],
      "sources": [
        {
          "chunkId": "chunk-1",
          "text": "Extrait source.",
          "pageNumber": null,
          "index": 0
        }
      ]
    }
  ]
}
```

Compatibilité legacy :

- `DiagnosticQuizActivity` reste constructible avec `sessionId`, `title`, `questions`.
- `DiagnosticQuizResult` reste constructible avec `correctAnswers`, `totalQuestions`.
- `score` et `items` sont optionnels.

Erreurs :

- Les erreurs HTTP restent propagées par `Dio`.
- Les JSON invalides produisent des `FormatException` contrôlées côté parsing.
- L'UI affiche une erreur générique de validation en cas d'échec de submit.

## 5. Modèles Flutter

Modèles enrichis :

- `DiagnosticQuizActivity`
  - `sessionId`
  - `type`
  - `version`
  - `title`
  - `documentId`
  - `subjectId`
  - `questions`

- `DiagnosticQuizQuestion`
  - `id`
  - `knowledgeUnitId`
  - `prompt`
  - `difficulty`
  - `choices`
  - `sources`

- `DiagnosticQuizChoice`
  - `id`
  - `label`

- `DiagnosticQuizSourceRef`
  - `chunkId`
  - `pageNumber`
  - `index`

- `DiagnosticQuizResult`
  - `correctAnswers`
  - `totalQuestions`
  - `score`
  - `items`

- `DiagnosticQuizCorrectionItem`
  - `questionId`
  - `knowledgeUnitId`
  - `prompt`
  - `selectedChoiceId`
  - `correctChoiceId`
  - `isCorrect`
  - `explanation`
  - `choiceFeedback`
  - `sources`

- `DiagnosticQuizChoiceFeedback`
  - `choiceId`
  - `feedback`

- `DiagnosticQuizCorrectionSource`
  - `chunkId`
  - `text`
  - `pageNumber`
  - `index`

## 6. Data layer

`HttpActivitiesApi` parse désormais :

- activité legacy ;
- activité v2 ;
- références sources pré-submit sans texte ;
- résultat legacy minimal ;
- résultat enrichi ;
- feedback par choix ;
- sources textuelles post-submit.

Le parsing pré-submit ne mappe pas les champs correctifs. Le modèle Flutter pré-submit ne possède aucun champ pour les stocker.

## 7. Controller/state

Ajout de `DiagnosticQuizSessionController` dans `activity_controller.dart`.

Responsabilités :

- garder les choix sélectionnés par question ;
- remplacer une réponse si l'utilisateur change de choix ;
- calculer uniquement la complétude du formulaire, jamais la correction ;
- refuser le submit si toutes les questions ne sont pas répondues ;
- empêcher un double submit pendant une soumission en cours ;
- conserver le résultat de correction renvoyé par l'API ;
- conserver une erreur de soumission affichable.

Le frontend ne calcule jamais `isCorrect`, `correctChoiceId`, le score ou l'explication.

## 8. UI QCM enrichi

Avant submit :

- titre du quiz ;
- nombre de questions ;
- progression `réponses / total` ;
- numéro de question ;
- difficulté si disponible ;
- choix mono-sélection ;
- indication sobre `Sources disponibles après correction` si des sources existent ;
- bouton `Valider` désactivé tant que toutes les questions n'ont pas une réponse.

Après submit :

- score `correctAnswers / totalQuestions` ;
- pourcentage si `score` est présent ;
- statut par question ;
- réponse sélectionnée ;
- réponse attendue ;
- explication pédagogique ;
- feedback par choix si disponible ;
- sources textuelles via `DocumentSourceExcerpt`.

QCM longs :

- la page reste une liste scrollable ;
- aucun plafond UI à 2 ou 3 questions ;
- test widget avec 15 questions.

## 9. Stratégie anti-fuite

Avant submit :

- pas de `correctChoiceId` dans le modèle de question ;
- pas de `isCorrect` dans le modèle de question ;
- pas d'explication dans le modèle de question ;
- pas de feedback dans le modèle de choix ;
- pas de texte source complet dans `DiagnosticQuizSourceRef` ;
- l'UI n'affiche que les choix, la difficulté et une indication de sources futures.

Après submit :

- les champs correctifs viennent uniquement de `DiagnosticQuizResult.items`.
- la bonne réponse et l'explication sont affichées seulement après retour API.

Tests anti-fuite :

- payload pré-submit contenant accidentellement `correctChoiceId`, `isCorrect`, `explanation`, `feedback` et `sources[].text` ;
- parsing vérifie que seuls les champs publics sûrs sont mappés ;
- widget vérifie que les textes correctifs ne sont pas affichés avant submit.

## 10. Images, graphiques et multi-réponse — hors scope de LOT-025

Ce lot ne crée pas de support images, graphiques ou multi-réponse parce que le backend actuel ne fournit aucun contrat public pour ces formats.

Contrats manquants :

- `QuestionVisual` ;
- `imageUrl` ou référence média signée ;
- `chartSpec` borné et validé ;
- `mediaAltText` ;
- `selectionMode` ;
- `multipleCorrectChoiceIds` ;
- soumission multi-réponse côté API ;
- correction partielle côté backend ;
- persistance des médias et sources associées.

Décision :

- ne pas inventer de champs Flutter inexistants ;
- ne pas permettre plusieurs réponses tant que l'API attend un seul `choiceId` ;
- ne pas créer de modèle média fake ;
- garder la structure de carte de question extensible pour accueillir plus tard un bloc visuel validé.

Lots futurs recommandés si cette priorité revient avant la question ouverte :

- `LOT-025B — Contrat QCM média, graphiques, multi-réponse et questionCount`
- `LOT-025C — Persistance et génération QCM média/multi-réponse`
- extension UI ou GenUI dédiée dans un lot ultérieur, par exemple autour de `LOT-030`.

Pour 10 à 20 questions :

- l'UI est prête à les afficher ;
- l'augmentation du nombre généré relève du backend Genkit/config, pas de `LOT-025`.

## 11. Tests créés ou modifiés

Tests modifiés :

- `test/features/activities/http_activities_api_test.dart`
  - parse QCM legacy ;
  - parse QCM v2 pré-submit ;
  - parse `version`, `difficulty`, références sources ;
  - ignore les champs correctifs accidentels pré-submit ;
  - parse résultat legacy minimal ;
  - parse résultat enrichi avec `score`, `items`, `choiceFeedback`, sources textuelles ;
  - rejette JSON invalide.

- `test/features/activities/activity_controller_test.dart`
  - sélection d'une réponse ;
  - remplacement d'une réponse ;
  - correction absente avant submit ;
  - submit happy path ;
  - double submit bloqué ;
  - erreur de submit conservée ;
  - activité avec 15 questions supportée.

- `test/features/activities/diagnostic_quiz_page_test.dart`
  - rendu legacy ;
  - bouton submit désactivé avant réponse ;
  - aucune correction visible avant submit ;
  - score et correction visibles après submit ;
  - feedback visible après submit ;
  - sources textuelles visibles après submit ;
  - rendu d'un QCM de 15 questions sans exception de layout.

## 12. Validations lancées

Depuis `revision_app` :

```bash
flutter test test/features/activities
```

Résultat :

```text
All tests passed! 30 tests.
```

```bash
dart analyze lib test
```

Résultat :

```text
Analyzing lib, test...
No issues found!
```

```bash
flutter test
```

Résultat :

```text
All tests passed! 105 tests.
```

Note : les commandes Flutter affichent des notices de dépendances plus récentes disponibles, sans échec. La suite complète affiche aussi le log attendu du test d'échec d'import document existant, mais le test passe.

Depuis `revision_app` :

```bash
git diff --check
```

Résultat :

```text
OK, aucune sortie.
```

Depuis `api` :

```bash
git diff --check
```

Résultat :

```text
OK, aucune sortie.
```

## 13. Validations non lancées

Non lancées :

- tests backend complets, car aucun code backend n'a été modifié ;
- migrations Prisma, interdites et hors scope ;
- provider IA réel, interdit et hors scope ;
- déploiement, interdit et hors scope ;
- `flutter pub upgrade`, interdit.

## 14. Risques restants

- Le backend peut encore générer peu de questions selon sa configuration Genkit actuelle.
- Pas de média question, pas d'image, pas de graphique.
- Pas de multi-réponse.
- Pas de GenUI QCM.
- Les migrations backend récentes restent à valider en runtime DB si ce point n'a pas été traité hors de ce lot.
- L'UI des QCM 10 à 20 questions est testée en widget, mais reste à valider sur vrais devices et avec vrais contenus longs.
- Le message d'erreur submit est volontairement générique ; un mapping produit plus fin pourra être ajouté si le data layer standardise les erreurs HTTP.

## 15. Recommandation prochain lot

Deux chemins sont raisonnables :

- `LOT-026 — Contrat question ouverte`, si la priorité produit est d'avancer vers l'activité différenciante suivante ;
- `LOT-025B — Contrat QCM média, graphiques, multi-réponse et questionCount`, si la priorité immédiate est d'enrichir le QCM avant de passer à la question ouverte.

Recommandation : faire `LOT-025B` seulement si les images/graphiques/multi-réponse deviennent prioritaires maintenant. Sinon, passer à `LOT-026`.

## 16. Passes de review

Passe Audit / Architecture :

- Verdict : le contrat backend réel confirme le pré-submit sans correction et le post-submit enrichi.
- Décision : ne pas modifier backend, Prisma, Genkit ou GenUI.

Passe Implémentation :

- Verdict : extension des modèles et du parsing sans rupture legacy.
- Décision : ajouter `DiagnosticQuizSessionController` pour isoler l'état d'interaction.

Passe Tests :

- Verdict : TDD appliqué, les tests ont d'abord échoué sur les champs absents puis sont passés après implémentation.
- Décision : couvrir explicitement l'anti-fuite et les longs QCM.

Passe Build / Validation :

- Verdict : analyse statique, tests ciblés et suite complète Flutter passent.
- Décision : tests backend non lancés car backend inchangé.

Passe Critique finale :

- Verdict : scope respecté, aucun support fake média/multi-réponse, aucune correction calculée côté frontend.
- Point d'autocritique : un remplacement mécanique dans un test a été fait une fois via commande shell au lieu de `apply_patch`; les éditions suivantes sont revenues à `apply_patch`.

## 17. Code modifié — extraits

### `lib/features/activities/domain/diagnostic_quiz_activity.dart`

```dart
class DiagnosticQuizActivity {
  const DiagnosticQuizActivity({
    required this.sessionId,
    required this.title,
    required this.questions,
    this.type = 'diagnostic_quiz',
    this.version,
    this.documentId,
    this.subjectId,
  });

  final String sessionId;
  final String type;
  final int? version;
  final String title;
  final String? documentId;
  final String? subjectId;
  final List<DiagnosticQuizQuestion> questions;
}

class DiagnosticQuizSourceRef {
  const DiagnosticQuizSourceRef({
    required this.chunkId,
    required this.pageNumber,
    required this.index,
  });

  final String chunkId;
  final int? pageNumber;
  final int index;
}
```

```dart
class DiagnosticQuizResult {
  const DiagnosticQuizResult({
    required this.correctAnswers,
    required this.totalQuestions,
    this.score,
    this.items = const [],
  });

  final int correctAnswers;
  final int totalQuestions;
  final double? score;
  final List<DiagnosticQuizCorrectionItem> items;
}

class DiagnosticQuizCorrectionItem {
  const DiagnosticQuizCorrectionItem({
    required this.questionId,
    required this.knowledgeUnitId,
    required this.prompt,
    required this.selectedChoiceId,
    required this.correctChoiceId,
    required this.isCorrect,
    required this.explanation,
    this.choiceFeedback = const [],
    this.sources = const [],
  });

  final String questionId;
  final String? knowledgeUnitId;
  final String prompt;
  final String selectedChoiceId;
  final String correctChoiceId;
  final bool isCorrect;
  final String explanation;
  final List<DiagnosticQuizChoiceFeedback> choiceFeedback;
  final List<DiagnosticQuizCorrectionSource> sources;
}
```

### `lib/features/activities/application/activity_controller.dart`

```dart
class DiagnosticQuizSessionController {
  DiagnosticQuizSessionController({required this.activity, this.submitter});

  final DiagnosticQuizActivity activity;
  final DiagnosticQuizSubmitter? submitter;
  final Map<String, String> _selectedChoiceIdsByQuestion = {};

  DiagnosticQuizResult? _result;
  Object? _submitError;
  bool _isSubmitting = false;
  Future<void>? _activeSubmit;

  bool get canSubmit {
    return submitter != null &&
        !_isSubmitting &&
        _result == null &&
        activity.questions.isNotEmpty &&
        _selectedChoiceIdsByQuestion.length == activity.questions.length;
  }

  void selectChoice({required String questionId, required String choiceId}) {
    if (_result != null || _isSubmitting) {
      return;
    }

    final question = _questionById(questionId);
    if (question == null) {
      return;
    }

    if (!question.choices.any((choice) => choice.id == choiceId)) {
      return;
    }

    _selectedChoiceIdsByQuestion[questionId] = choiceId;
    _submitError = null;
  }
}
```

### `lib/features/activities/data/http_activities_api.dart`

```dart
return DiagnosticQuizQuestion(
  id: id,
  knowledgeUnitId: knowledgeUnitId is String ? knowledgeUnitId : null,
  prompt: prompt,
  difficulty: difficulty is String ? difficulty : null,
  choices: choices
      .map((choice) => _ChoiceJson(choice).toChoice())
      .toList(growable: false),
  sources: sources is List
      ? sources
            .map((source) => _SourceRefJson(source).toSourceRef())
            .toList(growable: false)
      : const [],
);
```

```dart
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
```

### `lib/presentation/pages/activities/diagnostic_quiz_page.dart`

```dart
if (correction == null && question.sources.isNotEmpty) ...[
  const SizedBox(height: AppSpacing.s),
  Text(
    'Sources disponibles après correction',
    style: Theme.of(context).textTheme.bodySmall,
  ),
],
```

```dart
if (correction != null) ...[
  const SizedBox(height: AppSpacing.m),
  _CorrectionBlock(question: question, correction: correction),
],
```

```dart
Text('Réponse sélectionnée: $selectedLabel'),
Text('Réponse attendue: $correctLabel'),
const SizedBox(height: AppSpacing.s),
Text(correction.explanation),
```

### Tests anti-fuite

```dart
expect(find.text('Réponse attendue: Myocarde'), findsNothing);
expect(find.text('Explication post-submit sensible.'), findsNothing);
expect(find.text('Feedback post-submit sensible.'), findsNothing);
expect(find.text('Texte source post-submit sensible.'), findsNothing);
expect(find.text('Sources disponibles après correction'), findsOneWidget);
```

```dart
expect(find.text('Réponse sélectionnée: Péricarde'), findsOneWidget);
expect(find.text('Réponse attendue: Myocarde'), findsOneWidget);
expect(find.text('Explication post-submit sensible.'), findsOneWidget);
expect(find.textContaining('Feedback post-submit sensible.'), findsOneWidget);
expect(find.text('Texte source post-submit sensible.'), findsOneWidget);
```

## 18. Fichiers créés/modifiés/supprimés

Créé :

- `docs/ROADMAP_EXECUTION_LOT_025.md`

Modifiés :

- `docs/ROADMAP_EXECUTION_PLAN.md`
- `lib/features/activities/domain/diagnostic_quiz_activity.dart`
- `lib/features/activities/application/activity_controller.dart`
- `lib/features/activities/data/http_activities_api.dart`
- `lib/presentation/pages/activities/diagnostic_quiz_page.dart`
- `test/features/activities/http_activities_api_test.dart`
- `test/features/activities/activity_controller_test.dart`
- `test/features/activities/diagnostic_quiz_page_test.dart`

Supprimés :

- Aucun.
