# HOTFIX-028B — Entrée directe question ouverte depuis une notion

## 1. Résultat

Le chemin produit `DocumentDetailPage` → bouton `Question ouverte` → `ActivitiesPage` démarre maintenant directement une activité `open_question` quand `subjectId` et `knowledgeUnitId` sont fournis.

Le comportement QCM historique reste inchangé quand seul `subjectId` est fourni, et le bouton `QCM` permet toujours de revenir explicitement au QCM depuis une question ouverte.

`ActivitiesPage` réagit aussi aux changements de paramètres via `didUpdateWidget`, sans conserver un vieux futur QCM ou question ouverte quand les query params changent.

## 2. Problème corrigé

Avant ce hotfix, `ActivitiesPage.initState` démarrait systématiquement `_loadDiagnosticQuiz(subjectId)` dès qu'un `subjectId` existait, même si un `knowledgeUnitId` était aussi présent.

Conséquence UX : depuis une notion, le bouton `Question ouverte` envoyait bien `subjectId + knowledgeUnitId`, mais la page activités affichait d'abord un QCM. L'utilisateur devait recliquer sur `Question ouverte`.

## 3. Sources inspectées

- `revision_app/docs/ROADMAP_EXECUTION_LOT_028_OPEN_QUESTION_UI.md`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- `revision_app/AGENTS.md`
- `revision_app/codex_rule.md`
- `revision_app/lib/app/router/app_router.dart`
- `revision_app/lib/core/routing/route_paths.dart`
- `revision_app/lib/presentation/pages/documents/document_detail_page.dart`
- `revision_app/lib/presentation/pages/activities/activities_page.dart`
- `revision_app/lib/presentation/pages/activities/open_question_page.dart`
- `revision_app/lib/features/activities/application/activity_controller.dart`
- `revision_app/lib/features/activities/data/http_activities_api.dart`
- `revision_app/test/features/activities/activity_controller_test.dart`
- `revision_app/test/features/activities/open_question_page_test.dart`
- `revision_app/test/features/activities/http_activities_api_test.dart`
- `revision_app/test/features/documents/document_detail_page_test.dart`
- `revision_app/test/fakes/in_memory_activity_api.dart`

## 4. Préflight Git

### API

- Répertoire : `/Users/karim/Project/app-révision/api`
- Branche : `main`
- État initial : `## main...origin/main`
- Aucun fichier modifié ou non suivi au préflight.
- Derniers commits lus : `0f25fed`, `0cf3f17`, `ba5daba`, `93dad71`, `02d3e57`.

### Frontend

- Répertoire : `/Users/karim/Project/app-révision/revision_app`
- Branche : `main`
- État initial : `## main...origin/main`
- Aucun fichier modifié ou non suivi au préflight.
- Derniers commits lus : `2c8b57d`, `513b4f0`, `5304d61`, `a208a72`, `ce4cc5b`.

Aucun changement utilisateur existant n'a dû être préservé dans les fichiers du hotfix.

## 5. Décisions d'implémentation

- Le mode initial de `ActivitiesPage` est résolu depuis les paramètres normalisés.
- `subjectId + knowledgeUnitId` sélectionne et charge directement `_ActivityKind.openQuestion`.
- `subjectId` seul sélectionne et charge `_ActivityKind.diagnosticQuiz`.
- Aucun `subjectId` laisse `_activity = null` et affiche l'état vide existant.
- `didUpdateWidget` compare `subjectId` et `knowledgeUnitId` normalisés pour éviter les rechargements inutiles.
- Les actions manuelles restent explicites : `QCM` recharge un QCM, `Question ouverte` recharge une question ouverte seulement si une notion existe.

## 6. Fichiers modifiés

- Modifié : `revision_app/lib/presentation/pages/activities/activities_page.dart`
- Modifié : `revision_app/test/fakes/in_memory_activity_api.dart`
- Créé : `revision_app/test/features/activities/activities_page_test.dart`
- Créé : `revision_app/docs/ROADMAP_EXECUTION_HOTFIX_028B_OPEN_QUESTION_ENTRY.md`

`ROADMAP_EXECUTION_PLAN.md` n'a pas été modifié : le projet ne nécessite pas de ligne de tableau principale pour ce hotfix, et le prompt recommandait de ne pas changer le statut des lots.

## 7. Tests ajoutés/modifiés

- Nouveau fichier `activities_page_test.dart` avec 6 tests :
  - démarrage direct question ouverte avec `subjectId + knowledgeUnitId` ;
  - QCM par défaut avec `subjectId` seul ;
  - switch manuel question ouverte → QCM ;
  - switch manuel QCM → question ouverte ;
  - rechargement via `didUpdateWidget` quand les paramètres changent ;
  - état vide sans `subjectId`.
- `InMemoryActivityApi` trace maintenant le nombre de démarrages QCM/question ouverte et le `knowledgeUnitId` envoyé au QCM.

## 8. Validations lancées

- `flutter test test/features/activities/activities_page_test.dart --reporter compact` : échec RED attendu avant correctif, puis succès après correctif.
- `dart analyze lib test` : succès, aucun problème détecté.
- `flutter test test/features/activities --reporter compact` : succès.
- `flutter test test/features/documents/document_detail_page_test.dart --reporter compact` : succès.
- `flutter test --reporter compact` : succès.
- `git diff --check` depuis `revision_app` : succès.
- `git diff --check` depuis `api` : succès.

## 9. Validations non lancées avec justification

- Aucun test backend : aucun fichier `api/**` n'a été modifié.
- Aucun test GenUI dédié : le hotfix ne modifie pas `revision_app/lib/features/activities/genui/**`.
- Aucun `dart fix --apply`, `dart format .`, `flutter pub upgrade`, `flutter pub add` : explicitement interdits et inutiles.
- Aucun provider IA réel, aucune migration, aucun déploiement.

## 10. Risques restants

- L'entrée produit dépend toujours de la présence effective de `knowledgeUnitId` dans la navigation depuis une notion. Le routeur actuel le transmet correctement, mais une future entrée sans notion retombera volontairement sur QCM.
- Les futures activités pourraient nécessiter une résolution de mode plus explicite qu'un simple couple `subjectId/knowledgeUnitId`.
- Le rapport ne met pas à jour le plan principal, conformément à la consigne de ne pas suivre ce hotfix dans le tableau des lots sauf convention explicite.

## 11. Code complet créé/modifié/supprimé pour review

### `revision_app/lib/presentation/pages/activities/activities_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';
import 'package:revision_app/features/activities/genui/diagnostic_quiz_activity_validator.dart';
import 'package:revision_app/features/activities/genui/revision_activity_catalog.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';
import 'package:revision_app/presentation/widgets/revision_message.dart';
import 'package:revision_app/presentation/widgets/revision_page.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

import 'diagnostic_quiz_page.dart';
import 'open_question_page.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({
    required this.controller,
    required this.subjectId,
    this.knowledgeUnitId,
    super.key,
  });

  final ActivityController controller;
  final String? subjectId;
  final String? knowledgeUnitId;

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  Future<_LoadedActivity>? _activity;
  _ActivityKind _selectedKind = _ActivityKind.diagnosticQuiz;
  final _catalog = buildRevisionActivityCatalog();

  @override
  void initState() {
    super.initState();
    _setActivityFromCurrentParams();
  }

  @override
  void didUpdateWidget(covariant ActivitiesPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_normalizeId(oldWidget.subjectId) != _trimmedSubjectId ||
        _normalizeId(oldWidget.knowledgeUnitId) != _trimmedKnowledgeUnitId) {
      setState(_setActivityFromCurrentParams);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RevisionPage(
      title: 'Activites',
      subtitle: 'Diagnostics rapides et exercices adaptatifs.',
      children: [
        _ActivityActions(
          selectedKind: _selectedKind,
          canStartOpenQuestion: _canStartOpenQuestion,
          onDiagnosticSelected: _startDiagnosticQuiz,
          onOpenQuestionSelected: _startOpenQuestion,
        ),
        const SizedBox(height: AppSpacing.l),
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.68,
          child: _activity == null
              ? const Center(child: Text('Aucune activite selectionnee'))
              : FutureBuilder<_LoadedActivity>(
                  future: _activity,
                  builder: (context, snapshot) {
                    final loadedActivity = snapshot.data;

                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError || loadedActivity == null) {
                      return const Center(
                        child: Text("Impossible de charger l'activite"),
                      );
                    }

                    return switch (loadedActivity) {
                      _LoadedDiagnosticQuiz(:final activity) =>
                        _DiagnosticQuizActivityPanel(
                          activity: activity,
                          controller: widget.controller,
                          catalogId: _catalog.catalogId ?? 'revisionActivityCatalog',
                        ),
                      _LoadedOpenQuestion(:final activity) =>
                        _OpenQuestionActivityPanel(
                          activity: activity,
                          controller: widget.controller,
                        ),
                    };
                  },
                ),
        ),
      ],
    );
  }

  bool get _canStartOpenQuestion {
    return _trimmedSubjectId != null && _trimmedKnowledgeUnitId != null;
  }

  String? get _trimmedSubjectId {
    return _normalizeId(widget.subjectId);
  }

  String? get _trimmedKnowledgeUnitId {
    return _normalizeId(widget.knowledgeUnitId);
  }

  String? _normalizeId(String? value) {
    final trimmedValue = value?.trim();
    return trimmedValue == null || trimmedValue.isEmpty ? null : trimmedValue;
  }

  void _setActivityFromCurrentParams() {
    final subjectId = _trimmedSubjectId;
    if (subjectId == null) {
      _selectedKind = _ActivityKind.diagnosticQuiz;
      _activity = null;
      return;
    }

    final knowledgeUnitId = _trimmedKnowledgeUnitId;
    if (knowledgeUnitId != null) {
      _selectedKind = _ActivityKind.openQuestion;
      _activity = _loadOpenQuestion(
        subjectId: subjectId,
        knowledgeUnitId: knowledgeUnitId,
      );
      return;
    }

    _selectedKind = _ActivityKind.diagnosticQuiz;
    _activity = _loadDiagnosticQuiz(subjectId);
  }

  Future<_LoadedActivity> _loadDiagnosticQuiz(String subjectId) async {
    final activity = await widget.controller.startNextActivity(
      subjectId: subjectId,
      knowledgeUnitId: _trimmedKnowledgeUnitId,
    );

    return _LoadedDiagnosticQuiz(activity);
  }

  Future<_LoadedActivity> _loadOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) async {
    final activity = await widget.controller.startOpenQuestion(
      subjectId: subjectId,
      knowledgeUnitId: knowledgeUnitId,
    );

    return _LoadedOpenQuestion(activity);
  }

  void _startDiagnosticQuiz() {
    final subjectId = _trimmedSubjectId;
    if (subjectId == null) {
      return;
    }

    setState(() {
      _selectedKind = _ActivityKind.diagnosticQuiz;
      _activity = _loadDiagnosticQuiz(subjectId);
    });
  }

  void _startOpenQuestion() {
    final subjectId = _trimmedSubjectId;
    final knowledgeUnitId = _trimmedKnowledgeUnitId;
    if (subjectId == null || knowledgeUnitId == null) {
      return;
    }

    setState(() {
      _selectedKind = _ActivityKind.openQuestion;
      _activity = _loadOpenQuestion(
        subjectId: subjectId,
        knowledgeUnitId: knowledgeUnitId,
      );
    });
  }
}

enum _ActivityKind { diagnosticQuiz, openQuestion }

sealed class _LoadedActivity {
  const _LoadedActivity();
}

class _LoadedDiagnosticQuiz extends _LoadedActivity {
  const _LoadedDiagnosticQuiz(this.activity);

  final DiagnosticQuizActivity activity;
}

class _LoadedOpenQuestion extends _LoadedActivity {
  const _LoadedOpenQuestion(this.activity);

  final OpenQuestionActivity activity;
}

class _ActivityActions extends StatelessWidget {
  const _ActivityActions({
    required this.selectedKind,
    required this.canStartOpenQuestion,
    required this.onDiagnosticSelected,
    required this.onOpenQuestionSelected,
  });

  final _ActivityKind selectedKind;
  final bool canStartOpenQuestion;
  final VoidCallback onDiagnosticSelected;
  final VoidCallback onOpenQuestionSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: [
            RevisionButton(
              onPressed: onDiagnosticSelected,
              icon: Icons.quiz_outlined,
              label: 'QCM',
              style: selectedKind == _ActivityKind.diagnosticQuiz
                  ? RevisionButtonStyle.primary
                  : RevisionButtonStyle.ghost,
            ),
            RevisionButton(
              onPressed: canStartOpenQuestion ? onOpenQuestionSelected : null,
              icon: Icons.rate_review_outlined,
              label: 'Question ouverte',
              style: selectedKind == _ActivityKind.openQuestion
                  ? RevisionButtonStyle.primary
                  : RevisionButtonStyle.ghost,
            ),
          ],
        ),
        if (!canStartOpenQuestion) ...[
          const SizedBox(height: AppSpacing.s),
          RevisionMessage(
            message:
                'Question ouverte disponible depuis une notion précise du cours.',
            color: Theme.of(context).colorScheme.secondary,
            icon: Icons.info_outline,
          ),
        ],
      ],
    );
  }
}

class _DiagnosticQuizActivityPanel extends StatelessWidget {
  const _DiagnosticQuizActivityPanel({
    required this.activity,
    required this.controller,
    required this.catalogId,
  });

  final DiagnosticQuizActivity activity;
  final ActivityController controller;
  final String catalogId;

  @override
  Widget build(BuildContext context) {
    if (!isDiagnosticQuizActivityCatalogSafe(activity)) {
      return const Center(child: Text('Activite indisponible'));
    }

    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Semantics(
        label: catalogId,
        child: DiagnosticQuizPage(
          activity: activity,
          onSubmit: (answers) {
            return controller.submitResult(
              sessionId: activity.sessionId,
              answers: answers,
            );
          },
        ),
      ),
    );
  }
}

class _OpenQuestionActivityPanel extends StatelessWidget {
  const _OpenQuestionActivityPanel({
    required this.activity,
    required this.controller,
  });

  final OpenQuestionActivity activity;
  final ActivityController controller;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: OpenQuestionPage(
        activity: activity,
        onSubmit: (answerText) {
          return controller.submitOpenAnswer(
            sessionId: activity.sessionId,
            answerText: answerText,
          );
        },
      ),
    );
  }
}
```

### `revision_app/test/fakes/in_memory_activity_api.dart`

```dart
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';

class InMemoryActivityApi implements ActivityApi {
  String? startedSubjectId;
  String? startedKnowledgeUnitId;
  String? startedOpenQuestionSubjectId;
  String? startedOpenQuestionKnowledgeUnitId;
  int startedDiagnosticQuizCount = 0;
  int startedOpenQuestionCount = 0;
  List<DiagnosticQuizAnswer>? submittedAnswers;
  String? submittedOpenAnswerText;

  @override
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) async {
    startedSubjectId = subjectId;
    startedKnowledgeUnitId = knowledgeUnitId;
    startedDiagnosticQuizCount += 1;

    return const DiagnosticQuizActivity(
      sessionId: 'session-1',
      title: 'Diagnostic rapide',
      questions: [
        DiagnosticQuizQuestion(
          id: 'question-1',
          prompt: 'Question test',
          choices: [
            DiagnosticQuizChoice(id: 'a', label: 'Reponse A'),
            DiagnosticQuizChoice(id: 'b', label: 'Reponse B'),
          ],
        ),
      ],
    );
  }

  @override
  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  }) async {
    submittedAnswers = answers;

    return const DiagnosticQuizResult(correctAnswers: 1, totalQuestions: 1);
  }

  @override
  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) async {
    startedOpenQuestionSubjectId = subjectId;
    startedOpenQuestionKnowledgeUnitId = knowledgeUnitId;
    startedOpenQuestionCount += 1;

    return const OpenQuestionActivity(
      sessionId: 'open-session-1',
      type: 'open_question',
      version: 1,
      subjectId: 'subject-1',
      documentId: null,
      knowledgeUnitId: 'unit-1',
      question: OpenQuestion(
        id: 'open-question-1',
        prompt: 'Question ouverte test',
        instructions: 'Réponds en quelques phrases.',
        maxAnswerLength: 4000,
      ),
    );
  }

  @override
  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  }) async {
    submittedOpenAnswerText = answerText;

    return const OpenAnswerSubmissionResult(
      sessionId: 'open-session-1',
      type: 'open_question',
      status: 'submitted',
      evaluation: OpenAnswerEvaluation(
        id: 'evaluation-1',
        status: OpenAnswerEvaluationStatus.ready,
        score: 16,
        maxScore: 20,
        feedback: 'Réponse solide.',
        presentPoints: ['Point présent'],
        missingPoints: ['Point manquant'],
        errors: [],
        modelAnswer: 'Réponse modèle.',
        advice: 'Conseil de révision.',
        sources: [],
      ),
    );
  }
}
```

### `revision_app/test/features/activities/activities_page_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/presentation/pages/activities/activities_page.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';

import '../../fakes/in_memory_activity_api.dart';

void main() {
  testWidgets('starts open question directly with subject and knowledge unit', (
    tester,
  ) async {
    final api = InMemoryActivityApi();

    await tester.pumpWidget(
      _ActivitiesHarness(
        api: api,
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
      ),
    );
    await tester.pumpAndSettle();

    expect(api.startedOpenQuestionSubjectId, 'subject-1');
    expect(api.startedOpenQuestionKnowledgeUnitId, 'unit-1');
    expect(api.startedOpenQuestionCount, 1);
    expect(api.startedDiagnosticQuizCount, 0);
    expect(find.text('Question ouverte test'), findsOneWidget);
    expect(find.text('Question test'), findsNothing);
  });

  testWidgets('keeps diagnostic quiz as default with subject only', (
    tester,
  ) async {
    final api = InMemoryActivityApi();

    await tester.pumpWidget(
      _ActivitiesHarness(api: api, subjectId: 'subject-1'),
    );
    await tester.pumpAndSettle();

    expect(api.startedSubjectId, 'subject-1');
    expect(api.startedDiagnosticQuizCount, 1);
    expect(api.startedOpenQuestionCount, 0);
    expect(find.text('Question test'), findsOneWidget);

    await tester.tap(find.widgetWithText(RevisionButton, 'Question ouverte'));
    await tester.pumpAndSettle();

    expect(api.startedOpenQuestionCount, 0);
  });

  testWidgets('can switch from direct open question to diagnostic quiz', (
    tester,
  ) async {
    final api = InMemoryActivityApi();

    await tester.pumpWidget(
      _ActivitiesHarness(
        api: api,
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(RevisionButton, 'QCM'));
    await tester.pumpAndSettle();

    expect(api.startedSubjectId, 'subject-1');
    expect(api.startedKnowledgeUnitId, 'unit-1');
    expect(api.startedDiagnosticQuizCount, 1);
    expect(find.text('Question test'), findsOneWidget);
  });

  testWidgets('can switch back to open question when a knowledge unit exists', (
    tester,
  ) async {
    final api = InMemoryActivityApi();

    await tester.pumpWidget(
      _ActivitiesHarness(
        api: api,
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(RevisionButton, 'QCM'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(RevisionButton, 'Question ouverte'));
    await tester.pumpAndSettle();

    expect(api.startedOpenQuestionSubjectId, 'subject-1');
    expect(api.startedOpenQuestionKnowledgeUnitId, 'unit-1');
    expect(api.startedOpenQuestionCount, 2);
    expect(find.text('Question ouverte test'), findsOneWidget);
  });

  testWidgets('reloads when activity params change', (tester) async {
    final api = InMemoryActivityApi();

    await tester.pumpWidget(
      _ActivitiesHarness(api: api, subjectId: 'subject-1'),
    );
    await tester.pumpAndSettle();

    expect(api.startedDiagnosticQuizCount, 1);
    expect(api.startedOpenQuestionCount, 0);
    expect(find.text('Question test'), findsOneWidget);

    await tester.pumpWidget(
      _ActivitiesHarness(
        api: api,
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
      ),
    );
    await tester.pumpAndSettle();

    expect(api.startedOpenQuestionKnowledgeUnitId, 'unit-1');
    expect(api.startedOpenQuestionCount, 1);
    expect(find.text('Question ouverte test'), findsOneWidget);

    await tester.pumpWidget(
      _ActivitiesHarness(
        api: api,
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-2',
      ),
    );
    await tester.pumpAndSettle();

    expect(api.startedOpenQuestionKnowledgeUnitId, 'unit-2');
    expect(api.startedOpenQuestionCount, 2);

    await tester.pumpWidget(
      _ActivitiesHarness(api: api, subjectId: 'subject-1'),
    );
    await tester.pumpAndSettle();

    expect(api.startedDiagnosticQuizCount, 2);
    expect(find.text('Question test'), findsOneWidget);
  });

  testWidgets('does not load an activity without subject', (tester) async {
    final api = InMemoryActivityApi();

    await tester.pumpWidget(_ActivitiesHarness(api: api));
    await tester.pumpAndSettle();

    expect(api.startedDiagnosticQuizCount, 0);
    expect(api.startedOpenQuestionCount, 0);
    expect(find.text('Aucune activite selectionnee'), findsOneWidget);
  });
}

class _ActivitiesHarness extends StatelessWidget {
  const _ActivitiesHarness({
    required this.api,
    this.subjectId,
    this.knowledgeUnitId,
  });

  final InMemoryActivityApi api;
  final String? subjectId;
  final String? knowledgeUnitId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ActivitiesPage(
        controller: ActivityController(api),
        subjectId: subjectId,
        knowledgeUnitId: knowledgeUnitId,
      ),
    );
  }
}
```

### `revision_app/docs/ROADMAP_EXECUTION_HOTFIX_028B_OPEN_QUESTION_ENTRY.md`

Ce fichier est le présent rapport. Son contenu complet est donc directement disponible dans cette page.

Aucun fichier supprimé.
