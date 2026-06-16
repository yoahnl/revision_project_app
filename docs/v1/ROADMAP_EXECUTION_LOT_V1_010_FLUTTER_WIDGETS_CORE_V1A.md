# LOT V1-010 — Widgets Flutter V1-A single/multiple/case/error

## 1. Résultat

Le lot V1-010 est réalisé côté Flutter. Une couche de widgets natifs non routés permet maintenant d'afficher et manipuler les quatre types rich closed V1-A à choix : `single_choice`, `multiple_choice`, `case_qualification` et `error_detection`. Un contrôleur de brouillon local produit les `RichClosedAnswer` correspondantes sans correction, sans score et sans rendu de payload arbitraire.

Aucune page produit, aucun router, aucun TodayPlan, aucune session de révision et aucun fichier backend n'ont été modifiés.

## 2. Sources inspectées

- `revision_app/lib/features/activities/domain/rich_closed_exercise.dart`
- `revision_app/test/features/activities/rich_closed_exercise_test.dart`
- `revision_app/test/features/activities/fixtures/rich_closed_exercise_fixtures.dart`
- `revision_app/lib/features/activities/data/http_activities_api.dart`
- `revision_app/test/features/activities/http_activities_api_test.dart`
- `revision_app/lib/features/activities/application/activity_controller.dart`
- `revision_app/lib/features/activities/domain/diagnostic_quiz_activity.dart`
- `revision_app/lib/features/activities/domain/open_question_activity.dart`
- `revision_app/lib/presentation/pages/activities/activities_page.dart`
- `revision_app/lib/presentation/pages/activities/diagnostic_quiz_page.dart`
- `revision_app/lib/presentation/pages/activities/open_question_page.dart`
- `revision_app/lib/presentation/widgets/revision_choice_tile.dart`
- `revision_app/lib/presentation/widgets/revision_panel.dart`
- `revision_app/lib/presentation/widgets/revision_button.dart`
- `revision_app/lib/presentation/widgets/revision_message.dart`
- `revision_app/lib/presentation/widgets/revision_page.dart`
- `revision_app/lib/presentation/widgets/revision_status_pill.dart`
- `revision_app/lib/presentation/theme/app_spacing.dart`
- `revision_app/lib/presentation/theme/app_colors.dart`
- `revision_app/test/features/activities/diagnostic_quiz_page_test.dart`
- `revision_app/test/features/activities/open_question_page_test.dart`
- `revision_app/test/features/activities/activities_page_test.dart`
- `revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`
- `revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_009_FLUTTER_DOMAIN_V1A.md`

## 3. Préflight Git

`revision_app` :

```text
/Users/karim/Project/app-révision/revision_app
/Users/karim/Project/app-révision/revision_app
main
## main...origin/main
341a7c6 V1-009 — Ajout du rapport d'exécution du lot Domain models Flutter V1-A, modèles rich closed, DTOs, parsers et tests
7f400b6 V1-008B — Ajout du rapport d'exécution du lot Hardening API/scoring rich closed V1-A et mise à jour du plan
fd7710c V1-007/V1-008 — Ajout des rapports d'exécution des lots Persistance minimale V1-A et API publique pré-submit/post-submit V1-A, mise à jour du plan
786d22b V1-006 — Ajout du rapport d'exécution du lot Génération Genkit rich closed questions V1-A et mise à jour du plan d'exécution
31cdf95 LOT_V1_005B_RICH_CLOSED_CONTRACT_HARDENING - Mise à jour plan V1 et ajout rapport LOT_V1_005B (Rich Closed Contract Hardening)
```

Le repo `revision_app` était propre au préflight. Aucun fichier backend n'a été modifié et aucune commande n'a été lancée dans `api/`.

## 4. Périmètre réalisé

- Ajout d'un dossier `lib/features/activities/presentation/rich_closed` isolé.
- Ajout d'un contrôleur local `RichClosedCoreAnswerController` pour gérer les réponses pré-submit V1-010.
- Ajout des widgets pré-submit pour choix unique, choix multiple, qualification de cas et détection d'erreur.
- Réutilisation des primitives existantes `RevisionPanel`, `RevisionChoiceTile`, `RevisionStatusPill` et `RevisionMessage`.
- Ajout de tests unitaires du contrôleur et de tests widget pour les quatre types.
- Mise à jour de la ligne V1-010 du plan V1 et ajout d'une note courte.

## 5. Architecture retenue

Les widgets sont volontairement placés dans `features/activities/presentation/rich_closed` plutôt que dans `presentation/pages`, car ce lot prépare des briques UI réutilisables sans exposer encore de page produit. Le contrôleur local reste pur et ne dépend ni d'une API, ni de Riverpod, ni de GoRouter.

La sélection est locale :

- `single_choice` remplace la sélection précédente ;
- `case_qualification` remplace la sélection précédente ;
- `error_detection` remplace la sélection précédente ;
- `multiple_choice` toggle les choix, respecte `minSelections` et `maxSelections`, puis produit une answer seulement quand l'état est valide.

L'anti-fuite repose sur deux couches : le domaine V1-009 parse déjà un payload pré-submit strict, et les widgets V1-010 ne consomment que ces modèles publics. Aucune correction, explication, bonne réponse ou score n'est affiché par ces widgets.

Aucun routing, Today, session IA ou intégration `ActivitiesPage` n'a été ajouté.

## 6. Widgets couverts

- `RichClosedSingleChoiceWidget` : prompt, métadonnées, sources minimales, choix unique et callback `RichClosedSingleChoiceAnswer`.
- `RichClosedMultipleChoiceWidget` : prompt, instruction min/max, choix multiples bornés, message local de dépassement et callback nullable `RichClosedMultipleChoiceAnswer?`.
- `RichClosedCaseQualificationWidget` : prompt, bloc de cas distinct, choix unique et callback `RichClosedCaseQualificationAnswer`.
- `RichClosedErrorDetectionWidget` : prompt, bloc d'énoncé à vérifier, options d'erreur et callback `RichClosedErrorDetectionAnswer`.

`matching` et `ordering` sont explicitement exclus de V1-010 et restent prévus pour V1-011.

## 7. Anti-fuite

Les widgets pré-submit n'affichent que les champs publics du modèle Flutter : prompt, labels de choix, case text, statement, difficulté, compétence et nombre de sources. Les sources sont indiquées sous forme de compteur, sans texte source complet.

Le frontend ne recalcule ni correction, ni score, ni validité pédagogique. Le mode post-submit complet est reporté à V1-012. Les tests vérifient l'absence de textes de correction, de `correctChoiceId`, `correctErrorId`, `score`, `modelAnswer` et `feedback` dans les widgets pré-submit.

## 8. Fichiers créés/modifiés/supprimés

Fichiers créés :

- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_question_card.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_choice_group.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_single_choice_widget.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_multiple_choice_widget.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_case_qualification_widget.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_error_detection_widget.dart`
- `revision_app/test/features/activities/rich_closed_answer_controller_test.dart`
- `revision_app/test/features/activities/rich_closed_core_widgets_test.dart`

Fichiers modifiés :

- `revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`

Aucun fichier supprimé.

## 9. Tests ajoutés ou renforcés

- Tests unitaires de `RichClosedCoreAnswerController` : remplacement des sélections single/case/error, toggle multiple, respect `maxSelections`, `canSubmit`, production des quatre answers V1-010, refus matching/ordering, absence de correction dans le JSON.
- Tests widget : rendu prompt/choix/cas/énoncé, sélection et remplacement, callback typé, min/max multiple choice, message de dépassement, anti-fuite commune.

## 10. Validations lancées avec résultats

- `dart format <liste explicite des fichiers modifiés>` : OK.
- `flutter test test/features/activities --reporter compact` : premier passage KO sur un appel `putIfAbsent`, correction appliquée, dernier passage OK.
- `dart analyze lib test` : OK, aucun issue.
- `flutter test --reporter compact` : OK, suite complète verte.
- `git diff --check` : OK.

## 11. Validations non lancées avec justification

- Commandes backend : non lancées, interdites par le lot.
- Tests backend : non lancés, hors périmètre.
- `dart fix --apply` : non lancé, interdit.
- `dart format .` global : non lancé, formatage ciblé uniquement.
- App Flutter manuelle : non lancée, hors périmètre.
- Provider IA réel : non appelé.

## 12. Risques restants

- Les widgets ne sont pas encore intégrés à une page rich closed complète ; V1-012 devra gérer le rendu post-submit complet avec corrections backend.
- `matching` et `ordering` nécessitent encore une interaction dédiée en V1-011.
- `RevisionChoiceTile` reste commun avec le QCM actuel ; si l'UX V1 demande une distinction visuelle plus forte, elle pourra être traitée dans le polish V1.

## 13. Recommandation prochain lot

Poursuivre avec `V1-011 — Widgets Flutter matching/ordering`. Aucun mini-bis n'est nécessaire avant V1-011 si la review accepte que la correction UI complète reste bien reportée à V1-012.

## 14. Passes de review

- UI core widgets : quatre widgets natifs créés, non routés, cohérents avec les primitives existantes.
- State/controller : logique locale testée, sans API et sans correction.
- Anti-fuite : aucune donnée post-submit ou privée affichée pré-submit.
- Accessibilité : cibles tactiles via `RevisionChoiceTile`, état sélectionné visible par icône et sémantique `selected`.
- Scope/no routing : aucune page, Today, session IA, GenUI ou backend modifié.
- Tests : unitaires et widget tests ajoutés, suite Flutter complète verte avant finalisation du rapport.

## 15. Critique honnête du prompt initial

Le prompt est clair et utilement strict sur la séparation V1-010/V1-011. Le seul point délicat est le post-submit minimal : je l'ai volontairement laissé hors scope pour ne pas empiéter sur V1-012, tout en gardant les widgets pré-submit robustes et testés. La demande de rapport avec contenu complet reste coûteuse mais cohérente avec la cadence de review du projet.

## 16. Contenu complet des fichiers créés/modifiés/supprimés pour review

> Note : ce rapport ne se recopie pas lui-même dans sa propre section afin d'éviter une récursion documentaire infinie. Tous les autres fichiers créés ou modifiés par le lot sont inclus ci-dessous en entier.

### revision_app/lib/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart

```dart
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';

class RichClosedCoreAnswerController {
  final Map<String, String> _singleSelections = {};
  final Map<String, Set<String>> _multipleSelections = {};

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

  bool canSubmitQuestion(RichClosedQuestion question) {
    return switch (question) {
      RichClosedSingleChoiceQuestion() =>
        _singleSelections[question.id] != null,
      RichClosedMultipleChoiceQuestion() => _canSubmitMultipleChoice(question),
      RichClosedCaseQualificationQuestion() =>
        _singleSelections[question.id] != null,
      RichClosedErrorDetectionQuestion() =>
        _singleSelections[question.id] != null,
      RichClosedMatchingQuestion() || RichClosedOrderingQuestion() => false,
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
      RichClosedMatchingQuestion() || RichClosedOrderingQuestion() => null,
    };
  }

  bool _canSubmitMultipleChoice(RichClosedMultipleChoiceQuestion question) {
    final selectedCount = _multipleSelections[question.id]?.length ?? 0;
    return selectedCount >= question.minSelections &&
        selectedCount <= question.maxSelections;
  }

  bool _hasChoice(List<RichClosedChoice> choices, String choiceId) {
    return choices.any((choice) => choice.id == choiceId);
  }
}

```

### revision_app/lib/features/activities/presentation/rich_closed/rich_closed_question_card.dart

```dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';
import 'package:revision_app/presentation/widgets/revision_status_pill.dart';

class RichClosedQuestionCard extends StatelessWidget {
  const RichClosedQuestionCard({
    required this.question,
    required this.children,
    this.leading,
    super.key,
  });

  final RichClosedQuestion question;
  final Widget? leading;
  final List<Widget> children;

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
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              RevisionStatusPill(
                label: _kindLabel(question.questionKind),
                color: colorScheme.primary,
                icon: Icons.checklist_rtl,
              ),
              RevisionStatusPill(
                label: _difficultyLabel(question.difficulty),
                color: colorScheme.tertiary,
              ),
              RevisionStatusPill(
                label: _cognitiveSkillLabel(question.cognitiveSkill),
                color: colorScheme.secondary,
              ),
              if (question.sourceChunkIds.isNotEmpty)
                RevisionStatusPill(
                  label: '${question.sourceChunkIds.length} source(s)',
                  color: colorScheme.secondary,
                  icon: Icons.source_outlined,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(question.prompt, style: Theme.of(context).textTheme.titleMedium),
          if (leading != null) ...[
            const SizedBox(height: AppSpacing.m),
            leading!,
          ],
          const SizedBox(height: AppSpacing.m),
          ...children,
        ],
      ),
    );
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

  String _difficultyLabel(RichClosedDifficulty difficulty) {
    return switch (difficulty) {
      RichClosedDifficulty.low => 'Facile',
      RichClosedDifficulty.medium => 'Intermédiaire',
      RichClosedDifficulty.high => 'Avancé',
    };
  }

  String _cognitiveSkillLabel(RichClosedCognitiveSkill skill) {
    return switch (skill) {
      RichClosedCognitiveSkill.memorization => 'Mémorisation',
      RichClosedCognitiveSkill.comprehension => 'Compréhension',
      RichClosedCognitiveSkill.comparison => 'Comparaison',
      RichClosedCognitiveSkill.classification => 'Classification',
      RichClosedCognitiveSkill.caseApplication => 'Cas pratique',
      RichClosedCognitiveSkill.procedure => 'Procédure',
      RichClosedCognitiveSkill.errorDetection => 'Détection d’erreur',
      RichClosedCognitiveSkill.causality => 'Causalité',
    };
  }
}

```

### revision_app/lib/features/activities/presentation/rich_closed/rich_closed_choice_group.dart

```dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_choice_tile.dart';

class RichClosedChoiceGroup extends StatelessWidget {
  const RichClosedChoiceGroup({
    required this.choices,
    required this.selectedChoiceIds,
    required this.onChoiceSelected,
    this.enabled = true,
    super.key,
  });

  final List<RichClosedChoice> choices;
  final List<String> selectedChoiceIds;
  final ValueChanged<String> onChoiceSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final choice in choices)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: Semantics(
              selected: selectedChoiceIds.contains(choice.id),
              button: true,
              child: RevisionChoiceTile(
                label: choice.label,
                selected: selectedChoiceIds.contains(choice.id),
                enabled: enabled,
                onTap: () => onChoiceSelected(choice.id),
              ),
            ),
          ),
      ],
    );
  }
}

```

### revision_app/lib/features/activities/presentation/rich_closed/rich_closed_single_choice_widget.dart

```dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_choice_group.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';

class RichClosedSingleChoiceWidget extends StatefulWidget {
  const RichClosedSingleChoiceWidget({
    required this.question,
    required this.onAnswerChanged,
    this.enabled = true,
    super.key,
  });

  final RichClosedSingleChoiceQuestion question;
  final ValueChanged<RichClosedSingleChoiceAnswer> onAnswerChanged;
  final bool enabled;

  @override
  State<RichClosedSingleChoiceWidget> createState() =>
      _RichClosedSingleChoiceWidgetState();
}

class _RichClosedSingleChoiceWidgetState
    extends State<RichClosedSingleChoiceWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedSingleChoiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id) {
      _controller = RichClosedCoreAnswerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedChoiceId = _controller.selectedChoiceIdFor(
      widget.question.id,
    );

    return RichClosedQuestionCard(
      question: widget.question,
      children: [
        RichClosedChoiceGroup(
          choices: widget.question.choices,
          selectedChoiceIds: selectedChoiceId == null
              ? const []
              : [selectedChoiceId],
          enabled: widget.enabled,
          onChoiceSelected: _selectChoice,
        ),
      ],
    );
  }

  void _selectChoice(String choiceId) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _controller.selectSingleChoice(
        question: widget.question,
        choiceId: choiceId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    if (answer is RichClosedSingleChoiceAnswer) {
      widget.onAnswerChanged(answer);
    }
  }
}

```

### revision_app/lib/features/activities/presentation/rich_closed/rich_closed_multiple_choice_widget.dart

```dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_choice_group.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_message.dart';

class RichClosedMultipleChoiceWidget extends StatefulWidget {
  const RichClosedMultipleChoiceWidget({
    required this.question,
    required this.onAnswerChanged,
    this.enabled = true,
    super.key,
  });

  final RichClosedMultipleChoiceQuestion question;
  final ValueChanged<RichClosedMultipleChoiceAnswer?> onAnswerChanged;
  final bool enabled;

  @override
  State<RichClosedMultipleChoiceWidget> createState() =>
      _RichClosedMultipleChoiceWidgetState();
}

class _RichClosedMultipleChoiceWidgetState
    extends State<RichClosedMultipleChoiceWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedMultipleChoiceWidget oldWidget) {
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
          _selectionInstruction(widget.question),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.s),
        if (_controller.message != null) ...[
          RevisionMessage(
            message: _controller.message!,
            color: Theme.of(context).colorScheme.error,
            icon: Icons.info_outline,
          ),
          const SizedBox(height: AppSpacing.s),
        ],
        RichClosedChoiceGroup(
          choices: widget.question.choices,
          selectedChoiceIds: _controller.selectedChoiceIdsFor(widget.question),
          enabled: widget.enabled,
          onChoiceSelected: _toggleChoice,
        ),
      ],
    );
  }

  void _toggleChoice(String choiceId) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _controller.toggleMultipleChoice(
        question: widget.question,
        choiceId: choiceId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    widget.onAnswerChanged(
      answer is RichClosedMultipleChoiceAnswer ? answer : null,
    );
  }

  String _selectionInstruction(RichClosedMultipleChoiceQuestion question) {
    if (question.minSelections == question.maxSelections) {
      return 'Choisis ${question.minSelections} réponses.';
    }

    return 'Choisis entre ${question.minSelections} et ${question.maxSelections} réponses.';
  }
}

```

### revision_app/lib/features/activities/presentation/rich_closed/rich_closed_case_qualification_widget.dart

```dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_choice_group.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

class RichClosedCaseQualificationWidget extends StatefulWidget {
  const RichClosedCaseQualificationWidget({
    required this.question,
    required this.onAnswerChanged,
    this.enabled = true,
    super.key,
  });

  final RichClosedCaseQualificationQuestion question;
  final ValueChanged<RichClosedCaseQualificationAnswer> onAnswerChanged;
  final bool enabled;

  @override
  State<RichClosedCaseQualificationWidget> createState() =>
      _RichClosedCaseQualificationWidgetState();
}

class _RichClosedCaseQualificationWidgetState
    extends State<RichClosedCaseQualificationWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedCaseQualificationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id) {
      _controller = RichClosedCoreAnswerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedChoiceId = _controller.selectedChoiceIdFor(
      widget.question.id,
    );

    return RichClosedQuestionCard(
      question: widget.question,
      leading: _RichClosedContextBlock(
        label: 'Cas',
        text: widget.question.caseText,
      ),
      children: [
        RichClosedChoiceGroup(
          choices: widget.question.choices,
          selectedChoiceIds: selectedChoiceId == null
              ? const []
              : [selectedChoiceId],
          enabled: widget.enabled,
          onChoiceSelected: _selectChoice,
        ),
      ],
    );
  }

  void _selectChoice(String choiceId) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _controller.selectCaseQualification(
        question: widget.question,
        choiceId: choiceId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    if (answer is RichClosedCaseQualificationAnswer) {
      widget.onAnswerChanged(answer);
    }
  }
}

class _RichClosedContextBlock extends StatelessWidget {
  const _RichClosedContextBlock({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(text),
        ],
      ),
    );
  }
}

```

### revision_app/lib/features/activities/presentation/rich_closed/rich_closed_error_detection_widget.dart

```dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_choice_group.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

class RichClosedErrorDetectionWidget extends StatefulWidget {
  const RichClosedErrorDetectionWidget({
    required this.question,
    required this.onAnswerChanged,
    this.enabled = true,
    super.key,
  });

  final RichClosedErrorDetectionQuestion question;
  final ValueChanged<RichClosedErrorDetectionAnswer> onAnswerChanged;
  final bool enabled;

  @override
  State<RichClosedErrorDetectionWidget> createState() =>
      _RichClosedErrorDetectionWidgetState();
}

class _RichClosedErrorDetectionWidgetState
    extends State<RichClosedErrorDetectionWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedErrorDetectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id) {
      _controller = RichClosedCoreAnswerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedErrorId = _controller.selectedChoiceIdFor(widget.question.id);

    return RichClosedQuestionCard(
      question: widget.question,
      leading: _RichClosedStatementBlock(text: widget.question.statement),
      children: [
        RichClosedChoiceGroup(
          choices: widget.question.errorOptions,
          selectedChoiceIds: selectedErrorId == null
              ? const []
              : [selectedErrorId],
          enabled: widget.enabled,
          onChoiceSelected: _selectError,
        ),
      ],
    );
  }

  void _selectError(String errorId) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _controller.selectErrorDetection(
        question: widget.question,
        errorId: errorId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    if (answer is RichClosedErrorDetectionAnswer) {
      widget.onAnswerChanged(answer);
    }
  }
}

class _RichClosedStatementBlock extends StatelessWidget {
  const _RichClosedStatementBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Énoncé à vérifier',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(text),
        ],
      ),
    );
  }
}

```

### revision_app/test/features/activities/rich_closed_answer_controller_test.dart

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

  test('refuse matching et ordering dans ce lot', () {
    final controller = RichClosedCoreAnswerController();
    final matching = _question<RichClosedMatchingQuestion>(exercise);
    final ordering = _question<RichClosedOrderingQuestion>(exercise);

    expect(controller.canSubmitQuestion(matching), isFalse);
    expect(controller.answerFor(matching), isNull);
    expect(controller.canSubmitQuestion(ordering), isFalse);
    expect(controller.answerFor(ordering), isNull);
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

### revision_app/test/features/activities/rich_closed_core_widgets_test.dart

```dart
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

```

### revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md

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
