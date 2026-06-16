# LOT V1-011 — Widgets Flutter matching/ordering

## 1. Résultat

Le lot V1-011 complète la couverture Flutter pré-submit des six types rich closed V1-A en ajoutant les widgets natifs pour `matching` et `ordering`.

Les réponses locales produites sont maintenant supportées par `RichClosedCoreAnswerController` pour les six types V1-A : `single_choice`, `multiple_choice`, `matching`, `ordering`, `case_qualification` et `error_detection`.

Aucune page rich closed complète, aucun routing, aucune intégration Today, aucune intégration session IA, aucune correction UI complète et aucune modification backend n'ont été ajoutés.

## 2. Sources inspectées

### Domaine V1-A

- `revision_app/lib/features/activities/domain/rich_closed_exercise.dart`
- `revision_app/test/features/activities/rich_closed_exercise_test.dart`
- `revision_app/test/features/activities/fixtures/rich_closed_exercise_fixtures.dart`

### Widgets V1-010

- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_question_card.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_choice_group.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_single_choice_widget.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_multiple_choice_widget.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_case_qualification_widget.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_error_detection_widget.dart`

### Tests V1-010

- `revision_app/test/features/activities/rich_closed_answer_controller_test.dart`
- `revision_app/test/features/activities/rich_closed_core_widgets_test.dart`

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
- `revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_010_FLUTTER_WIDGETS_CORE_V1A.md`

## 3. Préflight Git

Repo `revision_app` :

- Racine : `/Users/karim/Project/app-révision/revision_app`
- Branche : `main`
- Statut initial : `## main...origin/main`
- Derniers commits initiaux :
  - `debe6f8 V1-010 — Ajout du rapport d'exécution du lot Widgets Flutter V1-A pour single/multiple/case/error et contrôleur de réponses`
  - `341a7c6 V1-009 — Ajout du rapport d'exécution du lot Domain models Flutter V1-A, modèles rich closed, DTOs, parsers et tests`
  - `7f400b6 V1-008B — Hardening API rich closed questions`
  - `fd7710c V1-007/V1-008 — Persistance minimale et API publique rich closed V1-A`
  - `786d22b V1-006 — Génération Genkit rich closed questions V1-A`

Aucun fichier backend n'a été modifié. Aucune commande n'a été lancée dans `api/` pour ce lot.

## 4. Périmètre réalisé

- Extension du contrôleur local pré-submit pour `matching` et `ordering`.
- Ajout de `RichClosedMatchingWidget`.
- Ajout de `RichClosedOrderingWidget`.
- Ajout de tests unitaires contrôleur pour matching/ordering.
- Ajout de widget tests matching/ordering.
- Mise à jour du plan V1 pour marquer V1-011 réalisé.
- Création du rapport V1-011 dans `revision_app/docs/v1`.

## 5. Architecture retenue

### Extension du contrôleur

`RichClosedCoreAnswerController` reste un contrôleur local pur, sans dépendance Flutter widget ni backend. Il garde l'état utilisateur par question et produit uniquement des `RichClosedAnswer` pré-submit.

Pour `matching`, le contrôleur conserve une association `leftId -> rightId`. La réutilisation d'un `rightId` retire l'ancienne association afin de garantir une réponse toujours unique et fluide côté mobile.

Pour `ordering`, le contrôleur conserve un ordre local complet d'IDs. À défaut d'état local, l'ordre initial correspond à l'ordre public fourni par le backend.

### Stratégie matching

Le widget affiche une ligne par item gauche et un sélecteur explicite pour choisir l'item droit. Ce choix évite une interaction drag-only et rend les tests déterministes.

### Stratégie ordering

Le widget affiche une liste numérotée avec boutons `Monter` / `Descendre`. Le déplacement par boutons est accessible, testable et ne dépend pas d'un geste caché.

### Choix UX sans drag-only

Aucun widget V1-011 ne dépend exclusivement du drag-and-drop. Les interactions principales sont des dropdowns et boutons iconés avec tooltips.

### Anti-fuite

Les widgets affichent seulement les champs publics pré-submit : prompt, labels, difficulté, compétence cognitive et compteur de sources via `RichClosedQuestionCard`. Aucune correction, explication, score, feedback ou champ `correct*` n'est rendu.

### Absence de routing

Le lot n'ajoute aucune route, aucune page complète et aucun flow submit global.

### Absence de Today/session

TodayPlan et les sessions IA ne sont pas modifiés. L'intégration produit reste reportée à un lot ultérieur.

## 6. Widgets couverts

- `RichClosedMatchingWidget` : rendu des items gauche/droite, sélection contrôlée, unicité des associations, callback `RichClosedMatchingAnswer?`.
- `RichClosedOrderingWidget` : rendu numéroté, boutons monter/descendre, callback `RichClosedOrderingAnswer` après déplacement valide.
- Les widgets V1-010 `single_choice`, `multiple_choice`, `case_qualification` et `error_detection` existaient déjà et restent couverts par leurs tests.
- La correction UI complète est explicitement reportée à V1-012.

## 7. Anti-fuite

Les réponses produites par le contrôleur ne contiennent aucune correction, aucun score, aucune explication et aucun feedback.

Les widget tests vérifient l'absence de chaînes de fuite telles que `correctPairs`, `correctOrder`, `explanation`, `feedback`, `score` et `modelAnswer`.

Le frontend ne recalcule pas la correction, ne recalcule pas le score et ne rend aucun JSON arbitraire.

## 8. Accessibilité

- Matching : association gauche/droite compréhensible textuellement, sans dépendance à la couleur, via un sélecteur attaché à chaque item gauche.
- Ordering : liste numérotée et boutons `Monter` / `Descendre` avec tooltips explicites.
- Les boutons impossibles sont désactivés : premier item non montable, dernier item non descendable.
- Les interactions restent utilisables sans drag-and-drop.

## 9. Fichiers créés/modifiés/supprimés

### Créés

- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_matching_widget.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_ordering_widget.dart`
- `revision_app/test/features/activities/rich_closed_matching_ordering_widgets_test.dart`
- `revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_011_FLUTTER_MATCHING_ORDERING.md`

### Modifiés

- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart`
- `revision_app/test/features/activities/rich_closed_answer_controller_test.dart`
- `revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`

### Supprimés

Aucun fichier supprimé.

## 10. Tests ajoutés ou renforcés

### Tests unitaires contrôleur

- Matching incomplet au départ.
- Matching complet produit `RichClosedMatchingAnswer`.
- Paires matching produites dans l'ordre des `leftItems`.
- Réutilisation d'un `rightId` garde l'unicité.
- IDs inconnus ignorés sans casser l'état.
- Ordering retourne l'ordre initial.
- Ordering autorise monter/descendre sans doublons.
- Déplacements impossibles ignorés.
- Réponses matching/ordering sans correction.
- Régression V1-010 : les quatre types existants restent couverts.

### Widget tests

- Matching rend le prompt, les items et produit une réponse complète.
- Matching met à jour l'answer et garde l'unicité.
- Matching `enabled: false` bloque les changements.
- Ordering rend le prompt, les items et les contrôles accessibles.
- Ordering monte/descend les items et produit une réponse.
- Ordering `enabled: false` bloque les changements.
- Anti-fuite commun pré-submit.

## 11. Validations lancées avec résultats

Depuis `revision_app` :

- `dart format lib/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart lib/features/activities/presentation/rich_closed/rich_closed_matching_widget.dart lib/features/activities/presentation/rich_closed/rich_closed_ordering_widget.dart test/features/activities/rich_closed_answer_controller_test.dart test/features/activities/rich_closed_matching_ordering_widgets_test.dart` : réussi.
- `dart analyze lib test` : réussi, `No issues found!`.
- `flutter test test/features/activities --reporter compact` : réussi, `All tests passed!`.
- `flutter test --reporter compact` : réussi, `All tests passed!`.
- `git diff --check` : réussi.

## 12. Validations non lancées avec justification

- Aucun test backend lancé : interdit par le périmètre V1-011.
- Aucune commande dans `api/` lancée : interdit par le périmètre V1-011.
- Aucun lancement manuel de l'app : non demandé, et le lot est couvert par analyse + tests Flutter.
- `dart fix --apply` non lancé : explicitement interdit.
- `dart format .` non lancé : explicitement interdit ; seuls les fichiers modifiés ont été formatés.

## 13. Risques restants

- Les widgets matching/ordering ne sont pas encore intégrés dans une page rich closed complète ; V1-011 livre les briques pré-submit isolées.
- La correction UI post-submit reste à concevoir en V1-012.
- Le rendu mobile réel devra être revu lors de l'intégration page complète, même si les widgets évitent déjà les interactions drag-only.

## 14. Recommandation prochain lot

Recommandation : passer à `V1-012 — Scoring/correction UI V1-A`.

Un mini-bis ne paraît pas nécessaire avant V1-012 tant que l'intégration page complète reste bien hors scope.

## 15. Passes de review

- Matching : unicité des droits, callback nul tant que la réponse est incomplète, ordre stable des paires.
- Ordering : liste complète, déplacements bornés, pas de doublons, boutons accessibles.
- Controller/state : six types V1-A couverts, pas de dépendance UI, pas de correction produite.
- Anti-fuite : pas de correction pré-submit, pas de score recalculé, pas de JSON arbitraire.
- Accessibilité : pas de drag-only, tooltips pour ordering, sélection textuelle pour matching.
- Scope/no routing : aucune page, aucune route, aucun Today, aucune session IA.
- Tests : unitaires + widget tests + suite activities + suite Flutter complète.

## 16. Critique honnête du prompt initial

Le prompt était précis sur le périmètre, les interactions accessibles et les anti-objectifs, ce qui a permis de garder le lot chirurgical. La seule tension pratique concerne l'exigence de rapport avec contenu complet des fichiers modifiés : elle rend le rapport très volumineux, mais elle reste utile pour review hors IDE.

## 17. Contenu complet des fichiers créés/modifiés/supprimés pour review

Note : ce rapport est lui-même un fichier créé. Son contenu complet correspond au présent document ; il n'est pas répété récursivement dans cette section pour éviter une auto-inclusion infinie.

### lib/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart

```dart
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';

class RichClosedCoreAnswerController {
  final Map<String, String> _singleSelections = {};
  final Map<String, Set<String>> _multipleSelections = {};
  final Map<String, Map<String, String>> _matchingSelections = {};
  final Map<String, List<String>> _orderingSelections = {};

  String? _message;

  String? get message => _message;

  String? selectedChoiceIdFor(String questionId) {
    return _singleSelections[questionId];
  }

  List<String> selectedChoiceIdsFor(RichClosedMultipleChoiceQuestion question) {
    final selectedIds = _multipleSelections[question.id];
    if (selectedIds == null || selectedIds.isEmpty) {
      return const [];
    }

    return question.choices
        .where((choice) => selectedIds.contains(choice.id))
        .map((choice) => choice.id)
        .toList(growable: false);
  }

  String? selectedRightIdFor(String questionId, String leftId) {
    return _matchingSelections[questionId]?[leftId];
  }

  List<RichClosedPair> matchingPairsFor(RichClosedMatchingQuestion question) {
    final selections = _matchingSelections[question.id];
    if (selections == null || selections.isEmpty) {
      return const [];
    }

    return [
      for (final leftItem in question.leftItems)
        if (selections[leftItem.id] != null)
          RichClosedPair(
            leftId: leftItem.id,
            rightId: selections[leftItem.id]!,
          ),
    ];
  }

  List<String> orderedIdsFor(RichClosedOrderingQuestion question) {
    final orderedIds = _orderingSelections[question.id];
    if (orderedIds == null || !_isCompleteOrdering(question, orderedIds)) {
      return question.items.map((item) => item.id).toList(growable: false);
    }

    return orderedIds.toList(growable: false);
  }

  void selectSingleChoice({
    required RichClosedSingleChoiceQuestion question,
    required String choiceId,
  }) {
    if (!_hasChoice(question.choices, choiceId)) {
      return;
    }

    _singleSelections[question.id] = choiceId;
    _message = null;
  }

  void selectCaseQualification({
    required RichClosedCaseQualificationQuestion question,
    required String choiceId,
  }) {
    if (!_hasChoice(question.choices, choiceId)) {
      return;
    }

    _singleSelections[question.id] = choiceId;
    _message = null;
  }

  void selectErrorDetection({
    required RichClosedErrorDetectionQuestion question,
    required String errorId,
  }) {
    if (!_hasChoice(question.errorOptions, errorId)) {
      return;
    }

    _singleSelections[question.id] = errorId;
    _message = null;
  }

  void toggleMultipleChoice({
    required RichClosedMultipleChoiceQuestion question,
    required String choiceId,
  }) {
    if (!_hasChoice(question.choices, choiceId)) {
      return;
    }

    final selectedIds = _multipleSelections.putIfAbsent(
      question.id,
      () => <String>{},
    );

    if (selectedIds.contains(choiceId)) {
      selectedIds.remove(choiceId);
      _message = null;
      return;
    }

    if (selectedIds.length >= question.maxSelections) {
      _message =
          'Tu peux sélectionner ${question.maxSelections} réponses au maximum.';
      return;
    }

    selectedIds.add(choiceId);
    _message = null;
  }

  void setMatchingPair({
    required RichClosedMatchingQuestion question,
    required String leftId,
    required String rightId,
  }) {
    if (!_hasLabelItem(question.leftItems, leftId) ||
        !_hasLabelItem(question.rightItems, rightId)) {
      return;
    }

    final selections = _matchingSelections.putIfAbsent(
      question.id,
      () => <String, String>{},
    );

    selections.removeWhere(
      (existingLeftId, existingRightId) =>
          existingLeftId != leftId && existingRightId == rightId,
    );
    selections[leftId] = rightId;
    _message = null;
  }

  void moveOrderingItemUp({
    required RichClosedOrderingQuestion question,
    required String itemId,
  }) {
    _moveOrderingItem(question: question, itemId: itemId, delta: -1);
  }

  void moveOrderingItemDown({
    required RichClosedOrderingQuestion question,
    required String itemId,
  }) {
    _moveOrderingItem(question: question, itemId: itemId, delta: 1);
  }

  bool canSubmitQuestion(RichClosedQuestion question) {
    return switch (question) {
      RichClosedSingleChoiceQuestion() =>
        _singleSelections[question.id] != null,
      RichClosedMultipleChoiceQuestion() => _canSubmitMultipleChoice(question),
      RichClosedCaseQualificationQuestion() =>
        _singleSelections[question.id] != null,
      RichClosedErrorDetectionQuestion() =>
        _singleSelections[question.id] != null,
      RichClosedMatchingQuestion() => _canSubmitMatching(question),
      RichClosedOrderingQuestion() => _canSubmitOrdering(question),
    };
  }

  RichClosedAnswer? answerFor(RichClosedQuestion question) {
    if (!canSubmitQuestion(question)) {
      return null;
    }

    return switch (question) {
      RichClosedSingleChoiceQuestion() => RichClosedSingleChoiceAnswer(
        questionId: question.id,
        choiceId: _singleSelections[question.id]!,
      ),
      RichClosedMultipleChoiceQuestion() => RichClosedMultipleChoiceAnswer(
        questionId: question.id,
        choiceIds: selectedChoiceIdsFor(question),
      ),
      RichClosedCaseQualificationQuestion() =>
        RichClosedCaseQualificationAnswer(
          questionId: question.id,
          choiceId: _singleSelections[question.id]!,
        ),
      RichClosedErrorDetectionQuestion() => RichClosedErrorDetectionAnswer(
        questionId: question.id,
        errorId: _singleSelections[question.id]!,
      ),
      RichClosedMatchingQuestion() => RichClosedMatchingAnswer(
        questionId: question.id,
        pairs: matchingPairsFor(question),
      ),
      RichClosedOrderingQuestion() => RichClosedOrderingAnswer(
        questionId: question.id,
        orderedIds: orderedIdsFor(question),
      ),
    };
  }

  bool _canSubmitMultipleChoice(RichClosedMultipleChoiceQuestion question) {
    final selectedCount = _multipleSelections[question.id]?.length ?? 0;
    return selectedCount >= question.minSelections &&
        selectedCount <= question.maxSelections;
  }

  bool _canSubmitMatching(RichClosedMatchingQuestion question) {
    final selections = _matchingSelections[question.id];
    if (selections == null || selections.length != question.leftItems.length) {
      return false;
    }

    final leftIds = question.leftItems.map((item) => item.id).toSet();
    final rightIds = question.rightItems.map((item) => item.id).toSet();
    final selectedRightIds = selections.values.toSet();

    return selections.keys.every(leftIds.contains) &&
        selections.values.every(rightIds.contains) &&
        selectedRightIds.length == selections.length;
  }

  bool _canSubmitOrdering(RichClosedOrderingQuestion question) {
    return _isCompleteOrdering(question, orderedIdsFor(question));
  }

  void _moveOrderingItem({
    required RichClosedOrderingQuestion question,
    required String itemId,
    required int delta,
  }) {
    if (!_hasLabelItem(question.items, itemId)) {
      return;
    }

    final orderedIds = orderedIdsFor(question).toList();
    final currentIndex = orderedIds.indexOf(itemId);
    final nextIndex = currentIndex + delta;

    if (currentIndex < 0 || nextIndex < 0 || nextIndex >= orderedIds.length) {
      return;
    }

    final movedId = orderedIds.removeAt(currentIndex);
    orderedIds.insert(nextIndex, movedId);
    _orderingSelections[question.id] = orderedIds;
    _message = null;
  }

  bool _isCompleteOrdering(
    RichClosedOrderingQuestion question,
    List<String> orderedIds,
  ) {
    final expectedIds = question.items.map((item) => item.id).toSet();
    final actualIds = orderedIds.toSet();

    return orderedIds.length == question.items.length &&
        actualIds.length == orderedIds.length &&
        actualIds.length == expectedIds.length &&
        actualIds.every(expectedIds.contains);
  }

  bool _hasChoice(List<RichClosedChoice> choices, String choiceId) {
    return choices.any((choice) => choice.id == choiceId);
  }

  bool _hasLabelItem(List<RichClosedLabelItem> items, String itemId) {
    return items.any((item) => item.id == itemId);
  }
}

```

### lib/features/activities/presentation/rich_closed/rich_closed_matching_widget.dart

```dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

class RichClosedMatchingWidget extends StatefulWidget {
  const RichClosedMatchingWidget({
    required this.question,
    required this.onAnswerChanged,
    this.enabled = true,
    super.key,
  });

  final RichClosedMatchingQuestion question;
  final ValueChanged<RichClosedMatchingAnswer?> onAnswerChanged;
  final bool enabled;

  @override
  State<RichClosedMatchingWidget> createState() =>
      _RichClosedMatchingWidgetState();
}

class _RichClosedMatchingWidgetState extends State<RichClosedMatchingWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedMatchingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id) {
      _controller = RichClosedCoreAnswerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RichClosedQuestionCard(
      question: widget.question,
      children: [
        Text(
          'Associe chaque élément de gauche à une proposition de droite.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.s),
        for (final leftItem in widget.question.leftItems)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: _MatchingRow(
              question: widget.question,
              leftItem: leftItem,
              selectedRightId: _controller.selectedRightIdFor(
                widget.question.id,
                leftItem.id,
              ),
              enabled: widget.enabled,
              onChanged: (rightId) => _selectPair(leftItem.id, rightId),
            ),
          ),
      ],
    );
  }

  void _selectPair(String leftId, String? rightId) {
    if (!widget.enabled || rightId == null) {
      return;
    }

    setState(() {
      _controller.setMatchingPair(
        question: widget.question,
        leftId: leftId,
        rightId: rightId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    widget.onAnswerChanged(answer is RichClosedMatchingAnswer ? answer : null);
  }
}

class _MatchingRow extends StatelessWidget {
  const _MatchingRow({
    required this.question,
    required this.leftItem,
    required this.selectedRightId,
    required this.enabled,
    required this.onChanged,
  });

  final RichClosedMatchingQuestion question;
  final RichClosedLabelItem leftItem;
  final String? selectedRightId;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(leftItem.label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.s),
          InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                key: ValueKey('matching-${question.id}-${leftItem.id}'),
                value: selectedRightId,
                isExpanded: true,
                hint: const Text('Choisir une association'),
                items: [
                  for (final rightItem in question.rightItems)
                    DropdownMenuItem<String>(
                      value: rightItem.id,
                      child: Text(rightItem.label),
                    ),
                ],
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

```

### lib/features/activities/presentation/rich_closed/rich_closed_ordering_widget.dart

```dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

class RichClosedOrderingWidget extends StatefulWidget {
  const RichClosedOrderingWidget({
    required this.question,
    required this.onAnswerChanged,
    this.enabled = true,
    super.key,
  });

  final RichClosedOrderingQuestion question;
  final ValueChanged<RichClosedOrderingAnswer> onAnswerChanged;
  final bool enabled;

  @override
  State<RichClosedOrderingWidget> createState() =>
      _RichClosedOrderingWidgetState();
}

class _RichClosedOrderingWidgetState extends State<RichClosedOrderingWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedOrderingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id) {
      _controller = RichClosedCoreAnswerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderedIds = _controller.orderedIdsFor(widget.question);
    final itemsById = {for (final item in widget.question.items) item.id: item};

    return RichClosedQuestionCard(
      question: widget.question,
      children: [
        Text(
          'Réorganise les étapes avec les boutons monter et descendre.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.s),
        for (final indexedItem in orderedIds.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: _OrderingRow(
              item: itemsById[indexedItem.$2]!,
              position: indexedItem.$1 + 1,
              canMoveUp: widget.enabled && indexedItem.$1 > 0,
              canMoveDown:
                  widget.enabled && indexedItem.$1 < orderedIds.length - 1,
              onMoveUp: () => _moveUp(indexedItem.$2),
              onMoveDown: () => _moveDown(indexedItem.$2),
            ),
          ),
      ],
    );
  }

  void _moveUp(String itemId) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _controller.moveOrderingItemUp(question: widget.question, itemId: itemId);
    });
    _emitAnswer();
  }

  void _moveDown(String itemId) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _controller.moveOrderingItemDown(
        question: widget.question,
        itemId: itemId,
      );
    });
    _emitAnswer();
  }

  void _emitAnswer() {
    final answer = _controller.answerFor(widget.question);
    if (answer is RichClosedOrderingAnswer) {
      widget.onAnswerChanged(answer);
    }
  }
}

class _OrderingRow extends StatelessWidget {
  const _OrderingRow({
    required this.item,
    required this.position,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final RichClosedLabelItem item;
  final int position;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$position.',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(child: Text(item.label)),
          const SizedBox(width: AppSpacing.s),
          IconButton(
            key: ValueKey('ordering-up-${item.id}'),
            tooltip: 'Monter ${item.label}',
            onPressed: canMoveUp ? onMoveUp : null,
            icon: const Icon(Icons.arrow_upward),
          ),
          IconButton(
            key: ValueKey('ordering-down-${item.id}'),
            tooltip: 'Descendre ${item.label}',
            onPressed: canMoveDown ? onMoveDown : null,
            icon: const Icon(Icons.arrow_downward),
          ),
        ],
      ),
    );
  }
}

```

### test/features/activities/rich_closed_answer_controller_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;

  setUp(() {
    exercise = RichClosedExercise.fromJson(richClosedExerciseJson());
  });

  test('single choice remplace la sélection précédente', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedSingleChoiceQuestion>(exercise);

    controller.selectSingleChoice(question: question, choiceId: 'choice-a');
    controller.selectSingleChoice(question: question, choiceId: 'choice-b');

    final answer = controller.answerFor(question);
    expect(answer, isA<RichClosedSingleChoiceAnswer>());
    expect((answer! as RichClosedSingleChoiceAnswer).choiceId, 'choice-b');
  });

  test('case qualification remplace la sélection précédente', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedCaseQualificationQuestion>(exercise);

    controller.selectCaseQualification(
      question: question,
      choiceId: 'choice-a',
    );
    controller.selectCaseQualification(
      question: question,
      choiceId: 'choice-b',
    );

    final answer = controller.answerFor(question);
    expect(answer, isA<RichClosedCaseQualificationAnswer>());
    expect((answer! as RichClosedCaseQualificationAnswer).choiceId, 'choice-b');
  });

  test('error detection remplace la sélection précédente', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedErrorDetectionQuestion>(exercise);

    controller.selectErrorDetection(question: question, errorId: 'error-a');
    controller.selectErrorDetection(question: question, errorId: 'error-b');

    final answer = controller.answerFor(question);
    expect(answer, isA<RichClosedErrorDetectionAnswer>());
    expect((answer! as RichClosedErrorDetectionAnswer).errorId, 'error-b');
  });

  test('multiple choice toggle ajoute et enlève', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedMultipleChoiceQuestion>(exercise);

    controller.toggleMultipleChoice(question: question, choiceId: 'choice-a');
    controller.toggleMultipleChoice(question: question, choiceId: 'choice-b');
    expect(controller.selectedChoiceIdsFor(question), ['choice-a', 'choice-b']);

    controller.toggleMultipleChoice(question: question, choiceId: 'choice-a');
    expect(controller.selectedChoiceIdsFor(question), ['choice-b']);
  });

  test('multiple choice ne dépasse pas maxSelections', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedMultipleChoiceQuestion>(exercise);

    controller.toggleMultipleChoice(question: question, choiceId: 'choice-a');
    controller.toggleMultipleChoice(question: question, choiceId: 'choice-b');
    controller.toggleMultipleChoice(question: question, choiceId: 'choice-c');

    expect(controller.selectedChoiceIdsFor(question), ['choice-a', 'choice-b']);
    expect(controller.message, contains('2 réponses au maximum'));
  });

  test('multiple choice canSubmit est faux sous minSelections', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedMultipleChoiceQuestion>(exercise);

    controller.toggleMultipleChoice(question: question, choiceId: 'choice-a');

    expect(controller.canSubmitQuestion(question), isFalse);
    expect(controller.answerFor(question), isNull);
  });

  test(
    'multiple choice canSubmit est vrai quand les bornes sont respectées',
    () {
      final controller = RichClosedCoreAnswerController();
      final question = _question<RichClosedMultipleChoiceQuestion>(exercise);

      controller.toggleMultipleChoice(question: question, choiceId: 'choice-a');
      controller.toggleMultipleChoice(question: question, choiceId: 'choice-b');

      final answer = controller.answerFor(question);
      expect(controller.canSubmitQuestion(question), isTrue);
      expect(answer, isA<RichClosedMultipleChoiceAnswer>());
      expect((answer! as RichClosedMultipleChoiceAnswer).choiceIds, [
        'choice-a',
        'choice-b',
      ]);
    },
  );

  test('produit les quatre réponses V1-010', () {
    final controller = RichClosedCoreAnswerController();
    final single = _question<RichClosedSingleChoiceQuestion>(exercise);
    final multiple = _question<RichClosedMultipleChoiceQuestion>(exercise);
    final caseQuestion = _question<RichClosedCaseQualificationQuestion>(
      exercise,
    );
    final error = _question<RichClosedErrorDetectionQuestion>(exercise);

    controller.selectSingleChoice(question: single, choiceId: 'choice-a');
    controller.toggleMultipleChoice(question: multiple, choiceId: 'choice-a');
    controller.toggleMultipleChoice(question: multiple, choiceId: 'choice-b');
    controller.selectCaseQualification(
      question: caseQuestion,
      choiceId: 'choice-a',
    );
    controller.selectErrorDetection(question: error, errorId: 'error-a');

    expect(controller.answerFor(single), isA<RichClosedSingleChoiceAnswer>());
    expect(
      controller.answerFor(multiple),
      isA<RichClosedMultipleChoiceAnswer>(),
    );
    expect(
      controller.answerFor(caseQuestion),
      isA<RichClosedCaseQualificationAnswer>(),
    );
    expect(controller.answerFor(error), isA<RichClosedErrorDetectionAnswer>());
  });

  test(
    'matching commence incomplet et devient submitable une fois complet',
    () {
      final controller = RichClosedCoreAnswerController();
      final matching = _question<RichClosedMatchingQuestion>(exercise);

      expect(controller.canSubmitQuestion(matching), isFalse);
      expect(controller.answerFor(matching), isNull);

      controller.setMatchingPair(
        question: matching,
        leftId: 'left-1',
        rightId: 'right-1',
      );

      expect(controller.selectedRightIdFor(matching.id, 'left-1'), 'right-1');
      expect(controller.answerFor(matching), isNull);

      controller.setMatchingPair(
        question: matching,
        leftId: 'left-2',
        rightId: 'right-2',
      );
      controller.setMatchingPair(
        question: matching,
        leftId: 'left-3',
        rightId: 'right-3',
      );

      final answer = controller.answerFor(matching);
      expect(controller.canSubmitQuestion(matching), isTrue);
      expect(answer, isA<RichClosedMatchingAnswer>());
      final matchingAnswer = answer! as RichClosedMatchingAnswer;
      expect(matchingAnswer.pairs.map((pair) => pair.leftId), [
        'left-1',
        'left-2',
        'left-3',
      ]);
      expect(matchingAnswer.pairs.map((pair) => pair.rightId), [
        'right-1',
        'right-2',
        'right-3',
      ]);
    },
  );

  test('matching garantit unicité des rightIds', () {
    final controller = RichClosedCoreAnswerController();
    final matching = _question<RichClosedMatchingQuestion>(exercise);

    controller.setMatchingPair(
      question: matching,
      leftId: 'left-1',
      rightId: 'right-1',
    );
    controller.setMatchingPair(
      question: matching,
      leftId: 'left-2',
      rightId: 'right-1',
    );

    expect(controller.selectedRightIdFor(matching.id, 'left-1'), isNull);
    expect(controller.selectedRightIdFor(matching.id, 'left-2'), 'right-1');
    expect(controller.canSubmitQuestion(matching), isFalse);
  });

  test('matching ignore les IDs inconnus sans casser l’état', () {
    final controller = RichClosedCoreAnswerController();
    final matching = _question<RichClosedMatchingQuestion>(exercise);

    controller.setMatchingPair(
      question: matching,
      leftId: 'left-1',
      rightId: 'right-1',
    );
    controller.setMatchingPair(
      question: matching,
      leftId: 'left-unknown',
      rightId: 'right-2',
    );
    controller.setMatchingPair(
      question: matching,
      leftId: 'left-2',
      rightId: 'right-unknown',
    );

    expect(controller.matchingPairsFor(matching).single.leftId, 'left-1');
    expect(controller.matchingPairsFor(matching).single.rightId, 'right-1');
  });

  test('ordering retourne l’ordre initial complet', () {
    final controller = RichClosedCoreAnswerController();
    final ordering = _question<RichClosedOrderingQuestion>(exercise);

    expect(controller.orderedIdsFor(ordering), ['item-1', 'item-2', 'item-3']);
    expect(controller.canSubmitQuestion(ordering), isTrue);
  });

  test('ordering move down et move up déplacent les items', () {
    final controller = RichClosedCoreAnswerController();
    final ordering = _question<RichClosedOrderingQuestion>(exercise);

    controller.moveOrderingItemDown(question: ordering, itemId: 'item-1');
    expect(controller.orderedIdsFor(ordering), ['item-2', 'item-1', 'item-3']);

    controller.moveOrderingItemUp(question: ordering, itemId: 'item-1');
    expect(controller.orderedIdsFor(ordering), ['item-1', 'item-2', 'item-3']);
  });

  test('ordering ignore les déplacements impossibles ou inconnus', () {
    final controller = RichClosedCoreAnswerController();
    final ordering = _question<RichClosedOrderingQuestion>(exercise);

    controller.moveOrderingItemUp(question: ordering, itemId: 'item-1');
    controller.moveOrderingItemDown(question: ordering, itemId: 'item-3');
    controller.moveOrderingItemDown(question: ordering, itemId: 'item-unknown');

    expect(controller.orderedIdsFor(ordering), ['item-1', 'item-2', 'item-3']);
  });

  test('ordering produit une answer complète sans doublons', () {
    final controller = RichClosedCoreAnswerController();
    final ordering = _question<RichClosedOrderingQuestion>(exercise);

    controller.moveOrderingItemDown(question: ordering, itemId: 'item-1');

    final answer = controller.answerFor(ordering);
    expect(answer, isA<RichClosedOrderingAnswer>());
    final orderingAnswer = answer! as RichClosedOrderingAnswer;
    expect(orderingAnswer.orderedIds, ['item-2', 'item-1', 'item-3']);
    expect(
      orderingAnswer.orderedIds.toSet().length,
      orderingAnswer.orderedIds.length,
    );
  });

  test('matching et ordering ne produisent jamais de correction', () {
    final controller = RichClosedCoreAnswerController();
    final matching = _question<RichClosedMatchingQuestion>(exercise);
    final ordering = _question<RichClosedOrderingQuestion>(exercise);

    controller.setMatchingPair(
      question: matching,
      leftId: 'left-1',
      rightId: 'right-1',
    );
    controller.setMatchingPair(
      question: matching,
      leftId: 'left-2',
      rightId: 'right-2',
    );
    controller.setMatchingPair(
      question: matching,
      leftId: 'left-3',
      rightId: 'right-3',
    );

    final matchingJson = controller.answerFor(matching)!.toJson();
    final orderingJson = controller.answerFor(ordering)!.toJson();

    for (final json in [matchingJson, orderingJson]) {
      expect(json.keys.any((key) => key.startsWith('correct')), isFalse);
      expect(json.containsKey('correction'), isFalse);
      expect(json.containsKey('score'), isFalse);
      expect(json.containsKey('explanation'), isFalse);
    }
  });

  test('ne produit jamais de correction dans le JSON de réponse', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedSingleChoiceQuestion>(exercise);

    controller.selectSingleChoice(question: question, choiceId: 'choice-a');

    final json = controller.answerFor(question)!.toJson();
    expect(json.keys.any((key) => key.startsWith('correct')), isFalse);
    expect(json.containsKey('correction'), isFalse);
    expect(json.containsKey('score'), isFalse);
    expect(json.containsKey('explanation'), isFalse);
  });
}

T _question<T extends RichClosedQuestion>(RichClosedExercise exercise) {
  return exercise.questions.whereType<T>().single;
}

```

### test/features/activities/rich_closed_matching_ordering_widgets_test.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_matching_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_ordering_widget.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;

  setUp(() {
    exercise = RichClosedExercise.fromJson(richClosedExerciseJson());
  });

  testWidgets('matching rend les items et produit une réponse complète', (
    tester,
  ) async {
    final answers = <RichClosedMatchingAnswer?>[];
    final question = _question<RichClosedMatchingQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedMatchingWidget(
          question: question,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    expect(
      find.text('Associe chaque mécanisme à sa fonction.'),
      findsOneWidget,
    );
    expect(find.text('Motion de censure'), findsOneWidget);
    expect(find.text('Dissolution'), findsOneWidget);
    expect(find.text('Contrôle constitutionnel'), findsOneWidget);
    _expectNoPreSubmitLeaks();

    await _selectMatchingRight(
      tester,
      leftId: 'left-1',
      label: 'Responsabilité politique',
    );
    expect(answers.last, isNull);

    await _selectMatchingRight(
      tester,
      leftId: 'left-2',
      label: 'Fin anticipée d’une chambre',
    );
    expect(answers.last, isNull);

    await _selectMatchingRight(
      tester,
      leftId: 'left-3',
      label: 'Vérification d’une norme',
    );

    expect(answers.last, isA<RichClosedMatchingAnswer>());
    expect(answers.last!.pairs.map((pair) => pair.leftId), [
      'left-1',
      'left-2',
      'left-3',
    ]);
    expect(answers.last!.pairs.map((pair) => pair.rightId), [
      'right-1',
      'right-2',
      'right-3',
    ]);
  });

  testWidgets('matching met à jour une association et garde unicité', (
    tester,
  ) async {
    final answers = <RichClosedMatchingAnswer?>[];
    final question = _question<RichClosedMatchingQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedMatchingWidget(
          question: question,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    await _selectMatchingRight(
      tester,
      leftId: 'left-1',
      label: 'Responsabilité politique',
    );
    await _selectMatchingRight(
      tester,
      leftId: 'left-2',
      label: 'Fin anticipée d’une chambre',
    );
    await _selectMatchingRight(
      tester,
      leftId: 'left-3',
      label: 'Vérification d’une norme',
    );
    expect(answers.last, isA<RichClosedMatchingAnswer>());

    await _selectMatchingRight(
      tester,
      leftId: 'left-2',
      label: 'Responsabilité politique',
    );

    expect(answers.last, isNull);
  });

  testWidgets('matching disabled empêche les changements', (tester) async {
    final answers = <RichClosedMatchingAnswer?>[];
    final question = _question<RichClosedMatchingQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedMatchingWidget(
          question: question,
          enabled: false,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    final dropdown = tester.widget<DropdownButton<String>>(
      find.byKey(const ValueKey('matching-matching-1-left-1')),
    );

    expect(dropdown.onChanged, isNull);
    expect(answers, isEmpty);
  });

  testWidgets('ordering rend et déplace les items avec boutons accessibles', (
    tester,
  ) async {
    final answers = <RichClosedOrderingAnswer>[];
    final question = _question<RichClosedOrderingQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedOrderingWidget(
          question: question,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    expect(find.text('Ordonne les étapes du raisonnement.'), findsOneWidget);
    expect(find.text('1.'), findsOneWidget);
    expect(find.text('2.'), findsOneWidget);
    expect(find.text('3.'), findsOneWidget);
    expect(find.text('Repérer les organes'), findsOneWidget);
    expect(find.byTooltip('Monter Repérer les organes'), findsOneWidget);
    expect(find.byTooltip('Descendre Repérer les organes'), findsOneWidget);
    _expectNoPreSubmitLeaks();

    final firstUp = tester.widget<IconButton>(
      find.byKey(const ValueKey('ordering-up-item-1')),
    );
    final lastDown = tester.widget<IconButton>(
      find.byKey(const ValueKey('ordering-down-item-3')),
    );
    expect(firstUp.onPressed, isNull);
    expect(lastDown.onPressed, isNull);

    await tester.tap(find.byKey(const ValueKey('ordering-down-item-1')));
    await tester.pump();

    expect(answers.last.orderedIds, ['item-2', 'item-1', 'item-3']);

    await tester.tap(find.byKey(const ValueKey('ordering-up-item-1')));
    await tester.pump();

    expect(answers.last.orderedIds, ['item-1', 'item-2', 'item-3']);
  });

  testWidgets('ordering disabled empêche les changements', (tester) async {
    final answers = <RichClosedOrderingAnswer>[];
    final question = _question<RichClosedOrderingQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedOrderingWidget(
          question: question,
          enabled: false,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    final downButton = tester.widget<IconButton>(
      find.byKey(const ValueKey('ordering-down-item-1')),
    );

    expect(downButton.onPressed, isNull);
    expect(answers, isEmpty);
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

Future<void> _selectMatchingRight(
  WidgetTester tester, {
  required String leftId,
  required String label,
}) async {
  await tester.tap(find.byKey(ValueKey('matching-matching-1-$leftId')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void _expectNoPreSubmitLeaks() {
  expect(find.text('Chaque mécanisme renvoie à sa fonction.'), findsNothing);
  expect(find.text('La qualification vient après l’analyse.'), findsNothing);
  expect(find.text('correctPairs'), findsNothing);
  expect(find.text('correctOrder'), findsNothing);
  expect(find.text('explanation'), findsNothing);
  expect(find.text('feedback'), findsNothing);
  expect(find.text('score'), findsNothing);
  expect(find.text('modelAnswer'), findsNothing);
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
