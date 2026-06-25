# RICH-01B -- QCM complet sequential mobile UX evidence pack

Date : 2026-06-25

Repo : App `yoahnl/revision_project_app`

## Baseline

- HEAD initial App : `21d16f880213644f417b3a5adc0ae6c7f08bac7f`
- API : non touchee

## Fichiers applicatifs modifies

- `lib/presentation/pages/activities/rich_closed_exercise_page.dart`
- `lib/features/activities/presentation/rich_closed/rich_closed_result_summary_card.dart`

## Tests modifies

- `test/features/activities/rich_closed_exercise_page_test.dart`

## Documents modifies ou crees

- `docs/roadmap/v3.1/EXECUTION_LOT_TRACKER_V3_1.md`
- `docs/roadmap/v3.1/LOT_TRACKER_V3_1.md`
- `docs/roadmap/v3.1/RICH_01B_QCM_COMPLET_SEQUENTIAL_UX_REPORT.md`
- `docs/roadmap/v3.1/RICH_01B_QCM_COMPLET_SEQUENTIAL_UX_EVIDENCE_PACK.md`

## Preuve UX

- `RichClosedExercisePage` ne boucle plus sur toutes les questions.
- La page affiche `Question X / N`.
- La progression utilise `LinearProgressIndicator`.
- Le renderer recoit seulement la question courante.
- `Precedent` est desactive sur la premiere question.
- `Suivant` est desactive tant que la question courante est incomplete.
- La derniere etape affiche `Valider le QCM`.
- La soumission finale reste celle du controleur existant.
- La carte resultat affiche `Score final` au lieu de `Score backend`.

## Preuve anti-regression

- Le chargement par session existante appelle `getRichClosedExercise` une seule fois et ne declenche pas `start`.
- Le demarrage legacy par `subjectId` / `knowledgeUnitId` reste couvert par le test de demarrage existant.
- La correction existante est toujours affichee apres soumission.
- Les routes course-level et result/history restent couvertes par les suites `courses` et `app/router`.

## Patch applicatif principal

```diff
diff --git a/lib/presentation/pages/activities/rich_closed_exercise_page.dart b/lib/presentation/pages/activities/rich_closed_exercise_page.dart
--- a/lib/presentation/pages/activities/rich_closed_exercise_page.dart
+++ b/lib/presentation/pages/activities/rich_closed_exercise_page.dart
@@
-class _ReadyExercisePanel extends StatelessWidget {
+class _ReadyExercisePanel extends StatefulWidget {
@@
+class _ReadyExercisePanelState extends State<_ReadyExercisePanel> {
+  int _questionIndex = 0;
+  ...
+  final currentQuestion = exercise.questions[_questionIndex];
+  final canLeaveQuestion = answerController.canSubmitQuestion(currentQuestion);
+  ...
+  Text('Question ${_questionIndex + 1} / $totalQuestions')
+  LinearProgressIndicator(value: (_questionIndex + 1) / totalQuestions)
+  RichClosedQuestionRenderer(
+    key: ValueKey(currentQuestion.id),
+    question: currentQuestion,
+    controller: answerController,
+    enabled: !isSubmitting,
+    onChanged: (answer) => widget.onAnswerChanged(currentQuestion, answer),
+  )
+  _StepNavigationBar(
+    isFirstQuestion: isFirstQuestion,
+    isLastQuestion: isLastQuestion,
+    canGoNext: canLeaveQuestion && !isSubmitting,
+    canSubmit: canSubmit,
+    isSubmitting: isSubmitting,
+    onPrevious: _goPrevious,
+    onNext: _goNext,
+    onSubmit: widget.onSubmit,
+  )
+}
```

## Patch anti-jargon resultat

```diff
-Text('Score backend', style: Theme.of(context).textTheme.labelMedium),
+Text('Score final', style: Theme.of(context).textTheme.labelMedium),
```

## Tests de preuve

```text
page affiche une question a la fois et conserve la reponse au retour
page charge une session existante et navigue sans double demarrage
page demarre, collecte six reponses et affiche la correction
result page reloads a completed rich closed result by session id
```

Les helpers de test repondent maintenant question par question et tapent `Suivant` jusqu'a la derniere etape, puis `Valider le QCM`.

## Validations finales

- `dart analyze lib test` : OK
- `flutter test test/features/activities/rich_closed_exercise_page_test.dart --reporter compact` : OK
- `flutter test test/features/activities --reporter compact` : OK
- `flutter test test/features/courses --reporter compact` : OK
- `flutter test test/app/router --reporter compact` : OK
- `git diff --check` : OK

## Hors scope confirme

- Pas de backend.
- Pas de Prisma.
- Pas de prompt IA.
- Pas de provider IA.
- Pas de nouveau type de question.
- Pas de nouveau moteur QCM.
- Pas de refonte resultat.
- Pas de refonte historique.
- Pas de DEEP-01A.
- Pas de calcul de score cote App.
