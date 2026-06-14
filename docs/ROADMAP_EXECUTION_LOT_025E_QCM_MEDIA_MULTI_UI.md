# LOT-025E — QCM média et multi-réponse : UI

## 1. Résultat

Le frontend Flutter consomme maintenant le contrat QCM v3 backend pour la multi-réponse et les visuels bornés. Le parcours legacy mono-réponse reste compatible.

Le QCM peut afficher des questions `single` et `multiple`, envoyer `choiceId` ou `choiceIds` selon le mode, afficher une correction multi-réponse après submit, afficher un score partiel post-submit, rendre des graphiques simples et des diagrammes simples, et refuser les visuels non supportés via un fallback explicite.

## 2. Sources inspectées

- `revision_app/docs/ROADMAP.md`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_022.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_023.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_024.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_025.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_025B_QCM_QUESTION_COUNT_MEDIA_MULTI_CONTRACT.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_025C_QCM_MEDIA_MULTI_BACKEND_CONTRACT.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_025D_QCM_MEDIA_MULTI_BACKEND.md`
- `revision_app/docs/ROADMAP_EXECUTION_HOTFIX_025D_BIS_QCM_V3_VERSIONING.md`
- `revision_app/AGENTS.md`
- `revision_app/codex_rule.md`
- `revision_app/pubspec.yaml`
- `revision_app/lib/features/activities/domain/diagnostic_quiz_activity.dart`
- `revision_app/lib/features/activities/application/activity_controller.dart`
- `revision_app/lib/features/activities/data/http_activities_api.dart`
- `revision_app/lib/features/activities/data/demo_activity_api.dart`
- `revision_app/lib/presentation/pages/activities/activities_page.dart`
- `revision_app/lib/presentation/pages/activities/diagnostic_quiz_page.dart`
- `revision_app/lib/presentation/widgets/revision_choice_tile.dart`
- `revision_app/lib/presentation/widgets/revision_panel.dart`
- `revision_app/lib/presentation/widgets/documents/document_source_excerpt.dart`
- `revision_app/lib/features/activities/genui/revision_activity_catalog.dart`
- `revision_app/lib/features/activities/genui/diagnostic_quiz_activity_validator.dart`
- `revision_app/test/features/activities/http_activities_api_test.dart`
- `revision_app/test/features/activities/activity_controller_test.dart`
- `revision_app/test/features/activities/diagnostic_quiz_page_test.dart`
- `revision_app/test/features/activities/revision_activity_catalog_test.dart`
- `revision_app/test/fakes/in_memory_activity_api.dart`
- `api/src/modules/activities/interfaces/activities.controller.ts`
- `api/src/modules/activities/application/start-next-activity.use-case.ts`
- `api/src/modules/activities/application/submit-activity-result.use-case.ts`
- `api/src/modules/activities/application/activities.repository.ts`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`
- `api/prisma/schema.prisma`

## 3. Préflight Git

État initial API : `## main...origin/main`, aucun fichier modifié.

État initial frontend : `## main...origin/main`, puis les tests RED ont modifié uniquement les fichiers activities avant l’implémentation.

Les rapports `LOT-025D` et `HOTFIX-025D-BIS` existent. Les fichiers hors scope ont été laissés inchangés. Aucun fichier backend n’a été modifié.

## 4. Contrat API consommé

Pré-submit :

- `sessionId`, `type`, `version`, `title`, `documentId`, `subjectId`.
- questions avec `id`, `knowledgeUnitId`, `prompt`, `difficulty`, `selectionMode`, `minSelections`, `maxSelections`, `choices`, `sources`, `visuals`.
- `selectionMode` vaut `single` ou `multiple`.
- les sources pré-submit restent des références sans texte complet.
- les visuels consommés sont `CHART` et `DIAGRAM`.
- `IMAGE` ou tout type inconnu est affiché en fallback non supporté.

Soumission :

- les questions single envoient `{ questionId, choiceId }`.
- les questions multiple envoient `{ questionId, choiceIds }`.
- aucun calcul de correction n’est fait côté frontend.

Post-submit :

- résultat legacy minimal toujours supporté.
- résultat enrichi avec `score`, `items`, `selectedChoiceId`, `correctChoiceId`, `selectedChoiceIds`, `correctChoiceIds`, `partialScore`, `explanation`, `choiceFeedback`, `sources`.

## 5. Modèles Flutter

`DiagnosticQuizActivity` garde ses champs existants et accepte `version`, `documentId`, `subjectId`.

`DiagnosticQuizQuestion` supporte maintenant :

- `selectionMode`;
- `minSelections`;
- `maxSelections`;
- `sources`;
- `visuals`.

Nouveaux modèles visuels :

- `DiagnosticQuizVisual`;
- `DiagnosticQuizChartVisual`;
- `DiagnosticQuizDiagramVisual`;
- `DiagnosticQuizUnsupportedVisual`;
- `DiagnosticQuizDiagramNode`;
- `DiagnosticQuizDiagramEdge`;
- `DiagnosticQuizChartType`.

`DiagnosticQuizAnswer` supporte maintenant `choiceId` pour single et `choiceIds` pour multiple.

`DiagnosticQuizCorrectionItem` supporte maintenant les champs single legacy et les champs multiples v3, dont `partialScore`.

## 6. Data layer

`HttpActivitiesApi` parse les champs v3 sans mapper les champs de correction dans le modèle pré-submit.

Le parser :

- ignore `correctChoiceId`, `correctChoiceIds`, `isCorrect`, `explanation`, `feedback` avant submit;
- parse `selectionMode`, `minSelections`, `maxSelections`;
- valide la cohérence min/max pour les questions multiples;
- parse les charts bornés (`bar`, `line`, `pie`, `scatter`);
- parse les diagrammes bornés (`nodes`, `edges`);
- transforme les visuels inconnus ou invalides en `DiagnosticQuizUnsupportedVisual`;
- parse la correction multi-réponse après submit.

## 7. Controller/state

`DiagnosticQuizSessionController` conserve les sélections par question sous forme d’ensemble ordonné par les choix de la question.

Comportements ajoutés :

- sélection single : une seule réponse active;
- sélection multiple : toggle par choix;
- respect de `minSelections` et `maxSelections`;
- submit impossible tant que toutes les questions ne sont pas complètes;
- double submit toujours bloqué;
- construction de payload `choiceId` ou `choiceIds`;
- correction conservée après submit.

## 8. UI QCM média et multi-réponse

Avant submit :

- affichage du titre, du nombre de questions, de la progression;
- pastille `Une seule réponse` ou `Plusieurs réponses possibles`;
- indication de contrainte de sélection pour les questions multiples;
- choix en sélection unique ou multiple selon le contrat;
- bouton submit désactivé tant que le QCM n’est pas complet;
- sources pré-submit indiquées sans texte complet;
- correction non affichée.

Après submit :

- affichage du score global;
- affichage des réponses sélectionnées;
- affichage des réponses attendues;
- affichage du score partiel si présent;
- affichage de l’explication;
- affichage du feedback par choix si présent;
- affichage des sources textuelles post-submit.

## 9. Graphiques

Les charts sont rendus en fallback natif borné :

- `bar` affiche des lignes avec barres proportionnelles simples;
- `line`, `pie` et `scatter` sont affichés en table lisible;
- les données sont limitées au payload validé côté backend et parsées sans exécuter de code;
- aucun HTML, JS, SVG ou payload widget arbitraire n’est rendu.

## 10. Diagrammes

Les diagrammes sont rendus en fallback natif borné :

- titre et description;
- noeuds affichés en pastilles;
- relations affichées en texte `from -> to`;
- aucun Mermaid, SVG ou HTML libre n’est rendu.

## 11. Stratégie anti-fuite

Avant submit :

- pas de `correctChoiceId`;
- pas de `correctChoiceIds`;
- pas de `isCorrect`;
- pas d’explication;
- pas de feedback;
- pas de texte source complet;
- pas de calcul frontend de la correction.

Après submit, les champs de correction viennent uniquement du DTO résultat backend.

## 12. Tests créés ou modifiés

- `test/features/activities/http_activities_api_test.dart`
  - parse QCM v3 multi-réponse et visuels bornés;
  - payload single vs multiple;
  - parse correction multiple;
  - anti-fuite pré-submit.
- `test/features/activities/activity_controller_test.dart`
  - sélection multiple;
  - min/max selections;
  - payload `choiceIds`;
  - non-régression double submit et QCM long.
- `test/features/activities/diagnostic_quiz_page_test.dart`
  - rendu v3 multi-réponse;
  - chart;
  - diagram;
  - fallback visuel non supporté;
  - anti-fuite pré-submit;
  - correction multiple post-submit;
  - QCM long 20 questions.

## 13. Validations lancées

- `flutter test test/features/activities` : échec RED attendu avant implémentation, puis succès final, 37 tests passés.
- `dart format` sur les fichiers Dart touchés : succès.
- `dart analyze lib test` : succès, aucun issue.
- `flutter test test/features/activities` : succès, 37 tests passés.
- `flutter test` : succès, 112 tests passés.
- `git diff --check` dans `revision_app` : succès.
- `git diff --check` dans `api` : succès.

## 14. Validations non lancées

- Tests backend complets non lancés : aucun code backend n’a été modifié.
- Migrations non lancées : lot strictement frontend, aucune modification Prisma.
- Provider IA réel non lancé : hors scope et interdit pour ce lot.
- Déploiement non lancé : hors scope et interdit.

## 15. Risques restants

- Les visuels `IMAGE` restent volontairement non rendus tant que le pipeline média contrôlé n’existe pas.
- Les charts sont volontairement simples côté Flutter; une visualisation plus riche doit rester bornée.
- Les diagrammes sont textuels et simples; pas de moteur de graph avancé.
- Le backend/runtime DB de `LOT-025D` reste à valider en production/staging si ce n’est pas déjà fait.
- Les vrais contenus de 20 questions doivent encore être validés sur appareils réels.
- GenUI QCM n’est pas encore implémenté.

## 16. Recommandation prochain lot

Recommandation : stabiliser le runtime backend/DB de `LOT-025D`, puis lancer `LOT-030 — GenUI composants activité et correction` seulement après confirmation que le fallback natif v3 couvre correctement les parcours single/multiple et chart/diagram.
