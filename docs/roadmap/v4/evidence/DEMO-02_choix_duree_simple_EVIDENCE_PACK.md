# DEMO-02 — Choix durée simple 5 / 15 / 30 — Evidence Pack

## 1. Objectif

Permettre a l'utilisateur de choisir simplement une duree de revision depuis le detail d'un cours : `5 min`, `15 min` ou `30 min`, puis lancer le flow quick revision existant sans exposer le `questionCount`.

Phrase produit du lot :

> Je suis sur un cours, je choisis 5, 15 ou 30 minutes, puis je commence une session courte.

## 2. Rappel du verrou MVP démo

Le lot respecte `docs/roadmap/v4/MVP_DEMO_LOCK.md` :

- flow demo prioritaire : Aujourd'hui -> Cours -> Detail cours -> Choix duree -> Session courte ;
- pas de nouvelle page principale ;
- pas de nouveau backend ;
- pas de nouveau mode ;
- pas de sujet long ;
- pas d'epreuve blanche ;
- pas de dashboard additionnel.

## 3. Résumé des changements

- Remplacement du bottom sheet technique de quantite par un bottom sheet duree.
- Ajout des options visibles `5 min`, `15 min`, `30 min` avec labels `Métro`, `Standard`, `Approfondi`.
- CTA unique `Commencer`.
- Branchement depuis le CTA principal du detail cours quand `primaryAction` permet une revision.
- Branchement depuis l'action basse `Reviser ce cours`.
- Wording de lancement transforme en `Preparation de la session` / `Ta session courte se prepare`.
- Action basse rendue honnete : `Reviser ce cours` au lieu de `Reviser cette notion` tant que la session notion-specific n'est pas livree.
- Tests detail cours mis a jour pour verifier la bottom sheet duree, la selection visuelle, le mapping interne et l'absence de jargon visible.

## 4. Fichiers modifiés

- `lib/features/courses/presentation/course_detail_page.dart`
- `lib/features/courses/presentation/course_quick_revision_launcher.dart`
- `lib/features/courses/presentation/widgets/quick_revision_question_count_sheet.dart`
- `test/features/courses/course_detail_page_test.dart`
- `docs/roadmap/v4/EXECUTION_TRACKER_V4.md`
- `docs/roadmap/v4/evidence/DEMO-02_choix_duree_simple_EVIDENCE_PACK.md`

## 5. Comportement utilisateur obtenu

- Depuis le detail cours, l'action principale `Continuer` ouvre le choix de duree si la revision est disponible.
- L'action basse affiche `Reviser ce cours` et ouvre aussi le choix de duree.
- Le bottom sheet affiche :
  - `Combien de temps as-tu ?`
  - `5 min` / `Métro`
  - `15 min` / `Standard`
  - `30 min` / `Approfondi`
  - `Commencer`
- La selection est visuelle et stable.
- Le lancement affiche une preparation de session, sans mentionner les questions.
- Aucun champ `questionCount` n'est visible dans le nouveau flow.
- Aucun nouveau backend ni nouvelle route `/study-sessions` n'est requis.

## 6. Mapping durée → moteur existant

Le backend quick revision existant accepte un `questionCount` borne. Audit read-only cote API :

- minimum quick : `5`
- defaut quick : `10`
- maximum quick : `30`

Mapping retenu :

- `5 min` -> `questionCount = 5`
- `15 min` -> `questionCount = 10`
- `30 min` -> `questionCount = 30`

Pourquoi ce mapping est honnete :

- il respecte les bornes existantes du moteur quick ;
- il ne promet pas une vraie planification temporelle ;
- la duree sert d'intention utilisateur demo ;
- `questionCount` reste interne au flow technique existant ;
- aucune duree ou session future n'est inventee.

## 7. Non-objectifs respectés

- Pas de backend.
- Pas de Prisma.
- Pas de GenUI.
- Pas de Study Session V4.
- Pas de `/study-sessions`.
- Pas de nouveau mode de revision.
- Pas de sujet long.
- Pas d'epreuve blanche.
- Pas de modification Today.
- Pas de modification Progres.
- Pas de nouvel asset.
- Pas de nouvelle dependance.

## 8. Tests exécutés

| Commande | Résultat | Notes |
| --- | --- | --- |
| `dart format lib/features/courses/presentation/course_detail_page.dart lib/features/courses/presentation/course_quick_revision_launcher.dart lib/features/courses/presentation/widgets/quick_revision_question_count_sheet.dart test/features/courses/course_detail_page_test.dart` | PASS | Formatage applique. |
| `flutter test test/features/courses/course_detail_page_test.dart` | FAIL initial, puis corrige | Premier passage : les tests tapaient une action hors viewport et attendaient un ancien libelle transitoire. Tests ajustes. |
| `dart format test/features/courses/course_detail_page_test.dart && flutter test test/features/courses/course_detail_page_test.dart` | PASS | 31 tests passes. |
| `flutter test test/app/router/app_router_test.dart` | PASS | 23 tests passes. |
| `flutter test test/app/revision_app_test.dart` | PASS | 12 tests passes. |
| `flutter analyze` | FAIL outil | Crash analysis server : `FormatException: Unexpected end of input`, `analysis server exited with code 255`. Crash report ecrit dans `flutter_20.log`. Aucun diagnostic Dart du lot n'a ete produit. |
| `flutter test test/features/courses/http_courses_repository_test.dart` | Non execute | Repository/parsing non modifies. |
| `git diff --check` | PASS | Aucun whitespace error. |
| `git status --short` | PASS | Fichiers attendus modifies : tracker, evidence pack, detail cours, launcher quick, sheet duree, tests detail cours. |

## 9. Risques restants

- Le mapping duree reste base sur le moteur quick existant, pas sur une vraie planification temporelle.
- La vraie facade Study Session V4 reste hors scope.
- La session immersive reste a faire en `DEMO-03`.
- Les modes legacy restent accessibles dans les actions avancees pour compatibilite, meme s'ils ne reviennent pas dans le flux principal.
- Le fichier `quick_revision_question_count_sheet.dart` garde son nom historique pour limiter le churn, mais expose maintenant des classes/UI de duree.

## 10. Autocritique finale

Le lot tient le couloir demo sans ouvrir de chantier backend. Le principal compromis est le mapping interne vers `questionCount`, necessaire tant que la facade Study Session n'existe pas. Le wording visible est maintenant coherent, mais les actions avancees legacy restent un point a surveiller pendant le hardening demo.

## 11. Prochain lot recommandé

`DEMO-03 — Session immersive quick-only`
