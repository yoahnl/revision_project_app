# CORE-09A Source Lifecycle App Report

## 1. Resume

CORE-09A connecte l'app Flutter au nouveau contrat lifecycle des sources. La suppression depuis le detail cours ou le detail matiere consulte maintenant la decision backend : suppression directe si sure, archive si la source a deja servi, blocage clair si aucune action n'est autorisee. Les sources archivees disparaissent des surfaces actives via les providers invalides.

## 2. Audit initial

L'audit a montre deux chemins utilisateur principaux : la bottom sheet sources du cours et le detail matiere legacy. Les deux pouvaient presenter une action de suppression sans distinguer source inutilisee, source deja utilisee ou source en analyse.

## 3. Sub-agents / passes utilisees

- App Integration Audit Agent : chemins Flutter et tests existants.
- Source Lifecycle UX Agent : confirmations delete/archive/block.
- Repository Client Agent : contrat HTTP et parsing decision.
- QA Agent : tests courses/documents/subjects/full Flutter.
- Reviewer Agent : wording utilisateur, pas de backend modifie depuis le repo app.

## 4. Contrat App

Nouveau modele partage : `SourceLifecycleDecision` avec statut, action recommandee, droits delete/archive, raisons et message utilisateur. L'app consomme :

- `GET /courses/:courseId/sources/:documentId/lifecycle`
- `POST /courses/:courseId/sources/:documentId/archive`
- `GET /documents/:documentId/lifecycle`
- `POST /documents/:documentId/archive`

## 5. UX source

- Source inutilisee : confirmation de suppression.
- Source utilisee : confirmation d'archivage, avec indication que l'historique est conserve.
- Source bloquee : dialogue lisible, sans `documentId`, `courseId`, Prisma ou code brut.
- Pendant upload/suppression/archive : les actions sources sont desactivees.

## 6. Tests ajoutes / modifies

- `course_detail_page_test.dart` : archive d'une source utilisee.
- `courses_providers_test.dart` : controller d'archive et invalidations.
- `http_courses_repository_test.dart` : lifecycle/archive/delete 409.
- `subject_detail_page_test.dart` : archive d'un document utilise.
- Fakes documents/courses et tests documents adaptes au nouveau contrat.

## 7. Commandes executees et resultats

- `flutter --version` : PASS, Flutter 3.44.0 stable, Dart 3.12.0.
- `flutter pub get` : PASS, avec 23 packages ayant des versions plus recentes incompatibles avec les contraintes actuelles (informatif).
- `dart analyze lib test` : PASS, `No issues found!` apres correction d'un usage `BuildContext` apres await.
- `flutter test test/app/router/app_router_test.dart --reporter compact` : PASS, 20 tests.
- `flutter test test/app/revision_app_test.dart --reporter compact` : PASS, 10 tests.
- `flutter test test/features/courses --reporter compact` : PASS.
- `flutter test test/features/documents --reporter compact` : PASS.
- `flutter test test/features/subjects --reporter compact` : PASS.
- `flutter test --reporter compact` : PASS, 464 tests. Un log attendu de test d'echec upload apparait : `Document import failed: Bad state: upload failed`.

## 8. Recherches statiques

- `rg -n "deleteDocument|deleteSource|archive|lifecycle|SourceLifecycle|documentId|courseId" lib test || true` : nombreuses sorties attendues dans code, fakes et tests. Les identifiants `documentId/courseId` sont des identifiants techniques internes, pas des libelles utilisateur.
- `rg -n "SOURCE_DELETE_BLOCKED|HAS_KNOWLEDGE_UNITS|foreign key|constraint|Prisma|payload|backend|cascade|KnowledgeUnit" lib || true` : sorties hors scope utilisateur existantes dans pages/flows legacy et validateurs techniques. Les nouvelles surfaces de suppression n'exposent pas ces libelles.

## 9. Roadmap

- `CORE-09A` passe a `DONE` dans l'execution tracker app.
- `CORE-09` passe a `IN_PROGRESS` dans le macro tracker app.
- `DEC-009` passe a `ACCEPTED` : une source utilisee doit etre archivee plutot que supprimee naivement.
- `UX_UI_TARGET_V2.md` indique que la suppression de source inutilisee et l'archive de source utilisee sont disponibles.

## 10. Limitations

- Pas d'ecran historique des sources archivees.
- Pas de cleanup physique de fichiers.
- Pas de lifecycle matiere/cours avance.
- Les libelles techniques existants dans des zones legacy non touchees restent pour des lots dedies.

## 11. Dette restante

- CORE-09B : cleanup blob/storage.
- CORE-09C : lifecycle matiere/cours.
- STAB-02/legacy : finir d'eliminer certains wordings techniques hors surfaces source.

## 12. Auto-review

- Suppression naive retiree des surfaces source principales : oui.
- Archive utilisateur disponible : oui.
- UI premium conservee : oui.
- Pas de fallback mock runtime : oui.
- Pas de backend modifie depuis le repo app : oui.
- Aucun commit effectue : oui.

## 13. Fichiers crees/modifies/supprimes

### Crees

- `docs/core/CORE_09A_SOURCE_LIFECYCLE_APP_REPORT.md`
- `lib/features/documents/domain/source_lifecycle.dart`

### Modifies

Voir l'annexe complete ci-dessous.

### Supprimes

Aucun.

## 14. Contenu complet des fichiers crees/modifies/supprimes

Le rapport courant ne s'inclut pas lui-meme pour eviter une recursion infinie.

### `docs/roadmap/v2/DECISIONS_V2.md`

~~~text
# Decisions V2

Ce journal est canonique côté produit. Le repo API pointe vers ce fichier au lieu de maintenir un doublon.

Statuts autorisés : `PROPOSED`, `ACCEPTED`, `REJECTED`, `SUPERSEDED`.

| ID | Décision | Statut | Date | Motif | Impact | Lot |
| --- | --- | --- | --- | --- | --- | --- |
| DEC-001 | La roadmap produit canonique vit dans le repo app. | ACCEPTED | 2026-06-20 | La roadmap décrit aussi l'UX, les écrans et le wording produit. | Le repo API garde une roadmap backend alignée, sans dupliquer toute la vision. | STAB-00 |
| DEC-002 | L'application affiche une seule matière active à la fois. | ACCEPTED | 2026-06-20 | Le produit doit rester lisible et orienté "une matière, des cours, des sources". | Le shell et la home doivent éviter les dashboards multi-matières prématurés. | STAB-01A |
| DEC-003 | La navigation cible est de quatre onglets. | ACCEPTED | 2026-06-21 | L'onglet Sources global est peu actionnable tant que les sources vivent dans les cours. | Appliqué par STAB-01A : Accueil, Progrès, Réviser, Profil. | STAB-01A |
| DEC-004 | Sources vit d'abord dans les cours. | ACCEPTED | 2026-06-20 | Les sources sont attachées à un cours et pilotent fiche, quick et progression. | La page Sources globale doit être informative ou devenir une vraie bibliothèque plus tard. | CORE-09A |
| DEC-005 | Today ne devient pas l'accueil avant une vraie recommandation. | PROPOSED | 2026-06-20 | Un "Aujourd'hui" sans moteur adaptatif deviendrait une façade trompeuse. | Today attend ADAPT-01 ou reste hors navigation principale. | ADAPT-01 |
| DEC-006 | Les modes non disponibles sont masqués ou clairement verrouillés. | ACCEPTED | 2026-06-20 | Un bouton visible doit avoir un contrat honnête. | Les labels utilisateur ne doivent plus dire `MVP+`. | STAB-01B |
| DEC-007 | Macro-lots et lots exécutables sont suivis séparément. | ACCEPTED | 2026-06-20 | Les macro-lots sont utiles stratégiquement mais trop gros pour un prompt unique. | Deux trackers sont maintenus : stratégique et exécutable. | STAB-00B |
| DEC-008 | La CI baseline arrive avant les gros refactors. | ACCEPTED | 2026-06-20 | Les refactors de shell/design/lifecycle ont besoin d'une preuve reproductible. | QUALITY-00 dépend seulement de STAB-00B et peut avancer en parallèle de STAB-01A. | QUALITY-00 |
| DEC-009 | Une source utilisée doit être archivée plutôt que supprimée naïvement. | ACCEPTED | 2026-06-21 | CORE-09A a ajouté une décision delete/archive/block, une archive logique et un guard backend contre la suppression dangereuse. | Les sources utilisées sont retirées des listes actives par archive, sans casser les données pédagogiques existantes. | CORE-09A |
| DEC-010 | La planche UI V2 est la référence visuelle canonique. | PROPOSED | 2026-06-20 | L'asset final n'est pas encore présent dans `docs/roadmap/v2/assets`. | Dès ajout de l'image, elle devient référence de direction visuelle sans autoriser de données fictives. | STAB-01A |

~~~

### `docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md`

~~~text
# Execution Lot Tracker V2

Ce tracker suit les lots réellement exécutables. Les macro-lots restent suivis dans `LOT_TRACKER_V2.md`.

Statuts autorisés : `TODO`, `IN_PROGRESS`, `DONE`, `BLOCKED`, `DEFERRED`, `REPLACED`.

Horizons autorisés : `FOUNDATION`, `MVP_STABLE`, `MVP_PLUS`, `POST_MVP`, `RELEASE`.

| Lot | Parent macro-lot | Horizon | Repo(s) | Statut | Dépend de | Travaux parallélisables | Objectif | Validation | Rapport |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| STAB-00B | STAB-00 | FOUNDATION | App + API | DONE | STAB-00 | Aucun | Durcir la roadmap V2 et créer les lots exécutables. | Docs, trackers et protocole synchronisés. | `docs/roadmap/v2/STAB_00B_ROADMAP_V2_HARDENING_REPORT.md` |
| QUALITY-00 | QUALITY-00 | FOUNDATION | App + API | DONE | STAB-00B | STAB-01A | Installer une baseline CI reproductible. | Flutter analyze/tests côté app ; Prisma/build/lint/tests/e2e côté API. | `docs/roadmap/v2/QUALITY_00_CI_BASELINE_REPORT.md` |
| STAB-01A | STAB-01 | MVP_STABLE | App | DONE | STAB-00B | QUALITY-00 | Corriger shell, navigation, scaffold et scrolls globaux. | Bottom nav 4 onglets, routes session immersives, routes legacy conservées, scaffolds top-aligned. | `docs/ui/STAB_01A_SHELL_NAVIGATION_SCAFFOLD_REPORT.md` |
| STAB-01B | STAB-01 | MVP_STABLE | App | DONE | STAB-01A | CORE-09A | Clarifier Home, Hub Révisions et hiérarchie des actions cours. | Home, hub Réviser et détail cours ont une action principale honnête, sans impasse ni wording technique. | `docs/ui/STAB_01B_HOME_REVISION_HUB_COURSE_ACTIONS_REPORT.md` |
| STAB-01C | STAB-01 | MVP_STABLE | App | DONE | STAB-01B | Aucun | Corriger fiche, progrès, wording et découvrabilité des matières. | Fiche sans faux onglets actifs, Progrès plus lisible, wording utilisateur nettoyé. | `docs/ui/STAB_01C_SHEET_PROGRESS_WORDING_SUBJECTS_REPORT.md` |
| STAB-02A | STAB-02 | MVP_STABLE | App | DONE | STAB-01C | CORE-10A si CORE-09A fait | Migrer Auth, Onboarding, Profil et Matières vers le design premium. | Une seule direction visuelle, sans faux état produit. | `docs/ui/STAB_02A_LEGACY_PREMIUM_ALIGNMENT_REPORT.md` |
| STAB-02B | STAB-02 | MVP_STABLE | App | DONE | STAB-02A | Aucun | Extraire les widgets feature, isoler ou déprécier le legacy. | Parcours canonique isolé du legacy, inventaire créé, microfixes review STAB-02B-bis intégrés. | `docs/ui/STAB_02B_CANONICAL_FLOW_LEGACY_ISOLATION_REPORT.md` |
| CORE-09A | CORE-09 | MVP_STABLE | App + API | DONE | STAB-01A | STAB-01B | Définir archive/delete des sources. | Une source utilisée n'est plus supprimée naïvement. | `docs/core/CORE_09A_SOURCE_LIFECYCLE_APP_REPORT.md` |
| CORE-09B | CORE-09 | MVP_STABLE | API | TODO | CORE-09A | CORE-09C | Durcir cleanup blob et abstraction storage. | Politique local/cloud documentée et testée. | À créer |
| CORE-09C | CORE-09 | MVP_STABLE | App + API | TODO | CORE-09A | CORE-09B | Ajouter les APIs de lifecycle sujet/cours nécessaires à l'UX. | Renommer/archiver devient disponible seulement si API réelle. | À créer |
| CORE-10A | CORE-10 | MVP_STABLE | App + API | TODO | CORE-09A | STAB-02A | Préparer la question bank en asynchrone. | Plus de génération longue bloquante au démarrage quick. | À créer |
| CORE-10B | CORE-10 | MVP_STABLE | API | TODO | CORE-10A | CORE-11A | Sélection multi-KU et verrouillage concurrence. | Répartition robuste, pas de double réservation évidente. | À créer |
| CORE-10C | CORE-10 | MVP_STABLE | API | TODO | CORE-10B | ADAPT-01 | Découpler QuestionBankService et ajouter métriques qualité/coût. | Service testable, métriques exploitables. | À créer |
| CORE-11A | CORE-11 | MVP_STABLE | App + API | TODO | CORE-10A | CORE-10B, PLUS-01A | Sauvegarder brouillons de session et reprise. | Une session en cours peut être reprise après fermeture. | À créer |
| CORE-11B | CORE-11 | MVP_STABLE | App + API | TODO | CORE-11A | Aucun | Historique de sessions et détail des sessions terminées. | Historique utilisable sans rouvrir un quiz terminé. | À créer |
| PLUS-01A | PLUS-01 | MVP_PLUS | App + API | TODO | STAB-02A, CORE-10A, quick lifecycle stable | CORE-11A | Deep Revision course-level avec question ouverte V1. | Action open-question réelle, correction IA, pas de résultat deep complet si hors lot. | À créer |
| PLUS-01B | PLUS-01 | MVP_PLUS | App + API | TODO | PLUS-01A, CORE-11A | Aucun | Lifecycle, completion et résultat Deep. | Deep dispose d'un résultat cohérent et testable. | À créer |
| PLUS-02 | PLUS-02 | MVP_PLUS | App + API | TODO | STAB-02B, CORE-09A | PLUS-01A | Fiches complète et pré-examen réelles. | Les faux onglets ne mentent plus. | À créer |
| ADAPT-01 | ADAPT-01 | MVP_PLUS | App + API | TODO | CORE-10B | CORE-10C | Page Today et coach adaptatif. | Recommandation honnête basée sur données réelles. | À créer |
| PLUS-03 | PLUS-03 | POST_MVP | App + API | TODO | PLUS-01B, PLUS-02, CORE-11B | Aucun | Préparation examen V1. | Mode examen distinct, résultat distinct, sources adaptées. | À créer |
| GENUI-01 | GENUI-01 | POST_MVP | App + API | TODO | STAB-02B, ADAPT-01, PLUS-01A | Aucun | Surface GenUI contrôlée par catalogue. | Payloads validés, fallback sûr, aucun UI arbitraire. | À créer |
| RELEASE-01 | RELEASE-01 | RELEASE | App + API | TODO | QUALITY-00, lots MVP_STABLE requis | Aucun | Préparation production complète. | CI, stockage, secrets, monitoring, accessibilité et conformité prêts. | À créer |

~~~

### `docs/roadmap/v2/LOT_TRACKER_V2.md`

~~~text
# Lot Tracker V2

Ce tracker suit les macro-lots stratégiques. Le détail exécutable vit dans `EXECUTION_LOT_TRACKER_V2.md`.

Statuts autorisés : `TODO`, `IN_PROGRESS`, `DONE`, `BLOCKED`, `DEFERRED`, `REPLACED`.

Horizons autorisés : `FOUNDATION`, `MVP_STABLE`, `MVP_PLUS`, `POST_MVP`, `RELEASE`.

| Lot | Titre | Horizon | Repo(s) | Statut | Dépend de | Lots exécutables | Objectif | Validation | Rapport |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| STAB-00 | Roadmap V2 canonicalisation | FOUNDATION | App + API | DONE | Aucun | STAB-00B | Créer la source de vérité V2 et le protocole de mise à jour. | Documents V2 créés dans les deux repos. | `docs/roadmap/v2/` |
| STAB-00B | Roadmap V2 hardening, execution slicing & governance | FOUNDATION | App + API | DONE | STAB-00 | STAB-00B | Durcir la roadmap, ajouter horizons, lots exécutables et gouvernance. | Trackers, plans, décisions et protocoles synchronisés. | `docs/roadmap/v2/STAB_00B_ROADMAP_V2_HARDENING_REPORT.md` |
| QUALITY-00 | CI baseline | FOUNDATION | App + API | DONE | STAB-00B | QUALITY-00 | Ajouter une baseline CI avant les gros refactors. | Analyse, tests ciblés et full Flutter test côté app ; Prisma, build, lint, unit et e2e côté API. | `docs/roadmap/v2/QUALITY_00_CI_BASELINE_REPORT.md` |
| STAB-01 | Product navigation & UX coherence | MVP_STABLE | App | DONE | STAB-00B | STAB-01A, STAB-01B, STAB-01C | Corriger navigation, faux affordances et parcours confus. | Tests router/widget + smoke visuel. | `docs/ui/STAB_01A_SHELL_NAVIGATION_SCAFFOLD_REPORT.md`, `docs/ui/STAB_01B_HOME_REVISION_HUB_COURSE_ACTIONS_REPORT.md`, `docs/ui/STAB_01C_SHEET_PROGRESS_WORDING_SUBJECTS_REPORT.md` |
| STAB-02 | Frontend design system unification | MVP_STABLE | App | DONE | STAB-01C | STAB-02A, STAB-02B | Unifier les écrans legacy et premium. | Écrans legacy alignés, parcours canonique isolé, inventaire legacy créé, microfixes STAB-02B-bis intégrés. | `docs/ui/STAB_02A_LEGACY_PREMIUM_ALIGNMENT_REPORT.md`, `docs/ui/STAB_02B_CANONICAL_FLOW_LEGACY_ISOLATION_REPORT.md` |
| CORE-09 | Source lifecycle & storage policy | MVP_STABLE | API + App | IN_PROGRESS | STAB-01A | CORE-09A, CORE-09B, CORE-09C | Sécuriser archive/suppression de sources et stockage. | Tests Prisma + API + UI. | `docs/core/CORE_09A_SOURCE_LIFECYCLE_APP_REPORT.md` |
| CORE-10 | Question bank production hardening | MVP_STABLE | API + App | TODO | CORE-09A | CORE-10A, CORE-10B, CORE-10C | Rendre la banque de questions robuste et moins synchrone. | Tests génération, sélection, concurrence. | À créer |
| CORE-11 | Session resume & history | MVP_STABLE | API + App | TODO | CORE-10A | CORE-11A, CORE-11B | Reprise de session et historique utilisateur. | Tests lifecycle + navigation. | À créer |
| PLUS-01 | Deep Revision course-level | MVP_PLUS | API + App | TODO | STAB-02A, CORE-10A | PLUS-01A, PLUS-01B | Activer la révision approfondie réelle. | Tests open question + correction IA. | À créer |
| PLUS-02 | Revision sheet complete / exam modes | MVP_PLUS | API + App | TODO | STAB-02B, CORE-09A | PLUS-02 | Remplacer les faux onglets fiche par de vrais contenus. | Tests fiche complète/examen. | À créer |
| ADAPT-01 | Today / adaptive coach | MVP_PLUS | API + App | TODO | CORE-10B | ADAPT-01 | Guider l'utilisateur vers la prochaine action utile. | Tests recommandation + UI Today. | À créer |
| PLUS-03 | Exam preparation V1 | POST_MVP | API + App | TODO | PLUS-01B, PLUS-02, CORE-11B | PLUS-03 | Créer un vrai mode préparation examen. | Tests session exam + résultat. | À créer |
| GENUI-01 | Controlled GenUI surface | POST_MVP | API + App | TODO | STAB-02B, ADAPT-01, PLUS-01A | GENUI-01 | Réintroduire GenUI avec widgets strictement contrôlés. | Validation payload + fallback. | À créer |
| RELEASE-01 | Production readiness | RELEASE | API + App + Infra | TODO | QUALITY-00, lots MVP_STABLE requis | RELEASE-01 | Préparer CI complète, monitoring, stockage et exploitation. | Checklist release complète. | À créer |

~~~

### `docs/roadmap/v2/REVISION_PROJECT_ROADMAP_V2.md`

~~~text
# Revision Project Roadmap V2

## 1. Vision produit

Revision Project doit devenir un Duolingo généré depuis les propres cours de l'utilisateur.

Phrase de référence :

> Une matière à la fois. Des cours clairs. Des sources accessibles. Des modes de révision simples.

Le parcours cible est :

```text
Import de sources personnelles
-> structuration du savoir
-> sessions courtes
-> feedback immédiat
-> maîtrise par notion
-> recommandation quotidienne
```

L'utilisateur doit pouvoir créer une matière, créer un cours, ajouter ses PDF, laisser l'IA extraire les notions, obtenir une fiche, faire une session rapide, recevoir une correction, voir sa progression et être guidé vers la prochaine action utile.

## 2. État réel actuel

### 2.1 Audit initial

Fichiers et dossiers inspectés côté Flutter :

- `docs/ui/`
- `docs/core/`
- `lib/app/router/app_router.dart`
- `lib/app/router/app_routes.dart`
- `lib/presentation/shell/revision_home_shell.dart`
- `lib/presentation/design_system/`
- `lib/presentation/widgets/`
- `lib/presentation/pages/auth/sign_in_page.dart`
- `lib/presentation/pages/onboarding/onboarding_page.dart`
- `lib/presentation/pages/profile/profile_page.dart`
- `lib/presentation/pages/subjects/subjects_home_page.dart`
- `lib/features/courses/presentation/courses_home_page.dart`
- `lib/features/courses/presentation/course_detail_page.dart`
- `lib/features/courses/presentation/course_revision_sheet_page.dart`
- `lib/features/courses/presentation/revisions_pending_page.dart`
- `lib/features/courses/presentation/sources_pending_page.dart`
- `lib/features/courses/presentation/subject_progress_page.dart`
- `lib/features/revision_sessions/presentation/quick_revision_quiz_flow.dart`
- `lib/presentation/pages/revision_sessions/revision_session_page.dart`
- `lib/presentation/pages/revision_sessions/revision_session_result_page.dart`
- `lib/presentation/pages/activities/open_question_page.dart`
- `lib/presentation/pages/activities/rich_closed_exercise_page.dart`
- `lib/features/courses/application/courses_providers.dart`
- `lib/features/courses/domain/courses_repository.dart`
- `lib/features/revision_sessions/`
- `pubspec.yaml`

Fichiers et dossiers inspectés côté API pour alignement :

- `docs/core/`
- `prisma/schema.prisma`
- `src/modules/auth/`
- `src/modules/subjects/`
- `src/modules/courses/`
- `src/modules/documents/`
- `src/modules/jobs/`
- `src/modules/ai/`
- `src/modules/activities/`
- `src/modules/revision/`
- `src/modules/revision-sessions/`
- `src/modules/study-artifacts/`
- `test/critical-paths.e2e-spec.ts`
- `package.json`
- `.env.example`

### 2.2 Ce qui existe déjà

Côté backend, le produit possède déjà l'auth Firebase, les matières, les cours, l'upload PDF course-level, le processing documentaire, l'extraction de `KnowledgeUnit`, les fiches rapides, la progression cours/matière, les sessions de révision, la quick revision course-level, la complétion/résultat quick, la banque de questions persistée, le signalement de questions, les corrections détaillées et plusieurs providers IA. Les questions ouvertes et rich closed legacy existent encore.

Côté Flutter, le produit possède déjà Riverpod, GoRouter, l'auth, l'accueil par matière active, la création de cours, le détail cours, l'upload/delete source, la fiche rapide, la session quick premium, le résultat de session, les corrections détaillées, la progression, le choix du nombre de questions et une fondation de design premium partielle.

### 2.3 Ce qui reste fragile

- La question bank peut encore générer trop de travail en synchrone.
- La quick revision course-level reste centrée sur une notion sélectionnée.
- La suppression de source peut devenir dangereuse si une source a déjà servi à des sessions.
- Le stockage reste local et doit être clarifié avant production.
- `QuestionBankService` est trop large et trop couplé à Prisma.
- Il n'existe pas encore de route deep course-level ni de mode exam réel.
- Les preuves CI ne sont pas encore une discipline visible et systématique.
- Deux sensibilités de design system coexistent encore dans l'app.
- Les écrans onboarding, profil, matières legacy, open question et rich closed ne sont pas encore alignés.
- L'onglet Sources global reste peu utile.
- Le hub Révisions reste trop indirect.
- La bottom navigation apparaît encore dans des parcours qui devraient être immersifs.
- Certains libellés comme `MVP+` ou des faux onglets créent une promesse utilisateur trop technique.
- La page cours peut devenir trop chargée.
- La progression peut être confondue avec le statut des sources.

## 3. Non-objectifs immédiats

- Ne pas ajouter deep/exam avant stabilisation UX.
- Ne pas ajouter de gamification tant que les métriques réelles ne sont pas prêtes.
- Ne pas réintroduire de fixtures ou de valeurs de maquette.
- Ne pas rendre GenUI arbitraire.
- Ne pas faire de refonte massive non testée.
- Ne pas exposer au client des choix internes comme `documentId`, `KnowledgeUnit`, `payload` ou `courseId`.

## 4. Principes non négociables

### Produit

- Le moteur est déjà meilleur que l'UX qui l'explique.
- Ne pas ajouter de nouvelle feature majeure tant que STAB-01/STAB-02 ne sont pas terminés.
- Ne pas afficher une option qui ne fait rien.
- Ne pas afficher `MVP+` à l'utilisateur.
- Ne pas utiliser des termes comme `fixture`, `backend`, `payload`, `courseId` ou `KnowledgeUnit` dans l'UI utilisateur.
- Ne pas confondre source prête et progression pédagogique.
- Une destination de navigation principale doit permettre une action principale claire.
- Les sessions doivent être immersives.
- Les fiches doivent cacher les modes non disponibles ou les présenter comme verrouillés clairement.
- Les sources doivent vivre d'abord dans les cours, pas forcément comme onglet global.
- Les recommandations doivent être honnêtes : pas de `Reprendre` si l'app ne connaît pas encore la dernière activité.
- Les scores affichés doivent venir du backend.
- Les données fictives sont interdites en production.
- Les fonctionnalités legacy doivent être migrées, isolées ou explicitement dépréciées.

### Technique

- Auth et ownership serveur obligatoires.
- Le client n'envoie jamais `studentId`.
- Le client ne choisit pas directement `documentId` ou `knowledgeUnitId` pour les flows course-level.
- La sélection source/KU reste backend.
- Les générations IA doivent être structurées, validées et versionnées.
- Les corrections IA doivent distinguer score, feedback, points présents, points manquants et conseil.
- Les sources utilisées par l'IA doivent être traçables.
- Les suppressions de données doivent respecter l'historique pédagogique.
- Les services application ne doivent pas devenir des blobs Prisma géants.
- `QuestionBank` doit être progressivement découplée.
- Toute nouvelle route doit avoir tests auth, 404/409 et happy path.
- Toute nouvelle page Flutter doit avoir loading, error et empty.

## 5. Architecture produit cible

L'objet central côté produit est le cours. Une matière contient des cours ; un cours contient des sources ; les sources produisent des notions ; les notions alimentent fiches, questions, sessions et progression.

```text
Subject
-> Course
-> Document source
-> KnowledgeUnit
-> QuestionBankItem
-> RevisionSession
-> ActivityResult
-> MasteryState
```

La page d'accueil doit rester centrée sur une seule matière active. Les sources ne sont pas une fin en soi : elles sont la matière première des cours. Les sessions ne sont pas une liste technique d'activités : ce sont des moments immersifs de révision courte.

## 6. Navigation cible

Navigation recommandée à court terme :

- Accueil : matière active, cours, reprise honnête.
- Progrès : progression réelle de la matière active.
- Révisions : entrée directe vers quick, puis plus tard deep/exam.
- Profil : compte, préférences, données.

Point ouvert : l'onglet Sources doit soit devenir une vraie bibliothèque globale, soit quitter la navigation principale pour vivre depuis les cours. La recommandation V2 est de ne pas le garder comme onglet principal tant qu'il n'offre pas une action forte.

Les sessions quick, deep et exam doivent masquer la bottom nav et utiliser une navigation immersive avec sortie contrôlée.

## 7. Écrans cibles

La cible détaillée vit dans `UX_UI_TARGET_V2.md`. Les priorités de correction sont :

1. Accueil.
2. Détail cours.
3. Hub Révisions.
4. Session quick.
5. Résultat quick.
6. Fiche.
7. Progrès.
8. Onboarding.
9. Profil.
10. Gestion matières.
11. Sources/course source sheet.

## 8. Axes techniques

- Stabiliser la navigation et les états.
- Unifier le design system Flutter.
- Sécuriser le lifecycle des sources.
- Durcir la question bank et sortir la génération longue des taps utilisateur.
- Sauvegarder/reprendre les sessions.
- Préparer deep puis exam sans casser quick.
- Mettre une politique de production : CI, stockage, quotas IA, logs, monitoring et suppression de données.

## 9. Roadmap par lots

## STAB-00 — Roadmap V2 canonicalisation

### Objectif

Créer la roadmap V2 officielle et le protocole de mise à jour.

### Pourquoi maintenant

Le produit a avancé vite. Sans source de vérité, les prochains lots risquent de réouvrir de vieux débats ou d'ajouter des features sur une UX confuse.

### Repos concernés

App + API.

### Dépendances

Aucune.

### Backend scope

Créer la roadmap API V2 alignée.

### Frontend scope

Créer la roadmap produit canonique, le tracker, la cible UX et le protocole.

### UX scope

Documenter les problèmes actuels et la cible.

### Tests attendus

Format documentation et `git diff --check`.

### Critères d'acceptation

Les deux repos possèdent `docs/roadmap/v2/` et le prochain lot logique est clair.

### Non-objectifs

Aucune modification runtime.

### Risques

Roadmap trop détaillée et difficile à maintenir.

### Rapport attendu

Réponse finale du lot + documents V2.

## STAB-00B — Roadmap V2 hardening, execution slicing & governance

### Objectif

Durcir la Roadmap V2 sans la réécrire : ajouter les horizons, séparer macro-lots et lots exécutables, introduire `QUALITY-00`, créer un journal de décisions et synchroniser les trackers app/API.

### Pourquoi maintenant

Les macro-lots restent utiles pour la stratégie, mais ils sont trop gros pour être exécutés proprement en un seul prompt.

### Repos concernés

App + API.

### Dépendances

STAB-00.

### Backend scope

Créer la couche d'exécution API alignée et pointer vers le journal de décisions canonique côté app.

### Frontend scope

Créer le plan d'exécution canonique, la matrice UX/API, le journal de décisions et le tracker exécutable.

### UX scope

Clarifier quelles capacités sont disponibles maintenant, lesquelles nécessitent une API, et lesquelles sont futures.

### Tests attendus

Validations documentaires uniquement.

### Critères d'acceptation

`EXECUTION_PLAN_V2.md`, `EXECUTION_LOT_TRACKER_V2.md`, `DECISIONS_V2.md`, `QUALITY-00`, les horizons et les règles `REPLACED` existent.

### Non-objectifs

Aucune modification runtime, aucune CI réelle.

### Risques

Dupliquer trop d'information entre app et API.

### Rapport attendu

`docs/roadmap/v2/STAB_00B_ROADMAP_V2_HARDENING_REPORT.md`.

## QUALITY-00 — CI baseline

### Objectif

Ajouter une baseline CI avant les gros refactors : analyse Flutter, tests Flutter, build/lint/tests API, e2e critiques, Prisma validate et vérification de format/diff.

### Pourquoi maintenant

La stabilisation UX et les refactors de lifecycle doivent être protégés par une preuve reproductible avant d'avancer.

### Repos concernés

App + API.

### Dépendances

STAB-00B.

### Backend scope

CI API minimale : Prisma validate, build, lint, tests Jest et e2e critiques.

### Frontend scope

CI Flutter minimale : analyse, tests ciblés, routeur/app smoke.

### UX scope

Aucun changement runtime.

### Tests attendus

La CI doit exécuter les commandes retenues sur pull request ou branche de validation.

### Critères d'acceptation

Un lot futur peut citer une preuve CI au lieu de dépendre seulement d'un run local.

### Non-objectifs

Monitoring, release pipeline, secrets production complets.

### Risques

Une baseline trop ambitieuse peut devenir instable ; une baseline trop faible ne protège pas assez.

### Rapport attendu

Rapport QUALITY-00 dans les repos touchés.

## STAB-01 — Product navigation & UX coherence

### Objectif

Reprendre le contrôle UX avant toute nouvelle feature majeure.

### Pourquoi maintenant

Les fondations techniques existent, mais l'utilisateur voit encore des destinations ambiguës, des modes partiels et des états qui ressemblent à des explications internes.

### Repos concernés

App.

### Dépendances

STAB-00.

### Backend scope

Aucun nouvel endpoint.

### Frontend scope

Corriger le centrage vertical global, clarifier la navigation, décider du rôle de Sources, masquer ou verrouiller les faux onglets, remplacer `MVP+`, rendre le hub Révisions actionnable, cacher la bottom nav en session, clarifier la progression, réduire la friction du choix de questions, corriger les ellipses critiques et rendre la gestion matières accessible.

### UX scope

Une page principale doit offrir une action principale. Une session doit être immersive. Une option non disponible doit être absente ou expliquée en langage utilisateur.

### Tests attendus

Tests router, widget smoke, anti-fixtures, tests de navigation back/replace.

### Critères d'acceptation

L'utilisateur comprend où créer, réviser, lire une fiche, suivre ses progrès et gérer ses matières sans lire des textes de lot.

### Non-objectifs

Pas de deep, exam, Today intelligent ou backend.

### Risques

Déplacer Sources peut perturber l'habitude récente.

### Rapport attendu

`docs/ui/STAB_01_PRODUCT_NAVIGATION_UX_COHERENCE_REPORT.md`.

## STAB-02 — Frontend design system unification

### Objectif

Supprimer l'impression de deux applications différentes.

### Pourquoi maintenant

Le premium partiel donne une bonne direction, mais les écrans legacy restent très visibles.

### Repos concernés

App.

### Dépendances

STAB-01.

### Backend scope

Aucun.

### Frontend scope

Migrer onboarding, profil, matières legacy, open question et rich closed si nécessaire ; isoler ou supprimer progressivement `presentation/widgets` legacy ; extraire les gros widgets de `course_detail_page.dart` ; créer des composants réutilisables.

### UX scope

Unifier couleurs, surfaces, typographie, scroll, headers fixes et comportement des états.

### Tests attendus

Tests widget des pages migrées, tests accessibilité basiques, anti-régression routing.

### Critères d'acceptation

Les écrans principaux et legacy ne donnent plus l'impression de changer d'app.

### Non-objectifs

Pas de nouvelle feature.

### Risques

Refactor UI trop large si les composants sont extraits sans limites.

### Rapport attendu

`docs/ui/STAB_02_FRONTEND_DESIGN_SYSTEM_UNIFICATION_REPORT.md`.

## CORE-09 — Source lifecycle & storage policy

### Objectif

Sécuriser la suppression/archivage des sources et préparer la production.

### Pourquoi maintenant

Les sources alimentent les notions, questions, fiches et résultats. Une suppression naïve peut casser l'historique pédagogique.

### Repos concernés

API + App.

### Dépendances

STAB-01.

### Backend scope

Définir archive vs suppression physique, empêcher la suppression dangereuse d'une source utilisée, masquer les sources archivées des nouvelles sessions, préparer l'abstraction stockage cloud, tester cascades et relations.

### Frontend scope

Adapter delete/archive, messages utilisateur, sources sheet et états.

### UX scope

Expliquer clairement `Retirer du cours`, `Archiver`, ou `Supprimer définitivement` si ces actions coexistent.

### Tests attendus

Tests Prisma relations, API 409/404/auth, UI confirmation.

### Critères d'acceptation

Une source utilisée ne détruit pas l'historique ; une source inutilisée peut être supprimée proprement.

État CORE-09A : la décision delete/archive/block existe, les sources utilisées sont archivées logiquement et les listes actives les excluent. Le cleanup blob/storage et le lifecycle matière/cours restent dans CORE-09B/CORE-09C.

### Non-objectifs

Pas de multi-source avancé.

### Risques

Migration de données si un statut d'archive est ajouté.

### Rapport attendu

`docs/core/CORE_09A_SOURCE_LIFECYCLE_APP_REPORT.md` côté app et `docs/core/CORE_09A_SOURCE_LIFECYCLE_API_REPORT.md` côté API pour CORE-09A.

## CORE-10 — Question bank production hardening

### Objectif

Faire de la banque de questions un vrai moteur robuste.

### Pourquoi maintenant

La question bank existe, mais elle doit devenir moins synchrone, moins couplée et plus prédictible avant d'ajouter deep/exam.

### Repos concernés

API + App.

### Dépendances

CORE-09.

### Backend scope

Génération asynchrone ou pré-génération, statut de disponibilité, sélection multi-notions, équilibre difficulté/maîtrise, verrouillage concurrentiel, amélioration signalement, métriques coût/qualité, découplage progressif de `QuestionBankService`.

### Frontend scope

Afficher préparation en cours, retry honnête, état banque insuffisante, choix de questions plus fluide.

### UX scope

Le bouton Révision rapide ne doit pas sembler cassé pendant une génération longue.

### Tests attendus

Tests sélection, concurrence, cap actif, flagged exclusion, fallback IA, erreurs lisibles.

### Critères d'acceptation

Une session quick ne dépend plus d'une génération longue fragile au moment du tap.

### Non-objectifs

Pas de streaming live question par question en V1 sans nouveau lifecycle.

### Risques

Complexité worker/queue et concurrence.

### Rapport attendu

`docs/core/CORE_10_QUESTION_BANK_PRODUCTION_HARDENING_REPORT.md`.

## CORE-11 — Session resume & history

### Objectif

Ne pas perdre une session en cours et créer un historique.

### Pourquoi maintenant

Le premier flow complet existe. Il doit survivre à une fermeture d'app, un retour arrière et une reprise.

### Repos concernés

API + App.

### Dépendances

CORE-10.

### Backend scope

État de session persistant, réponses partielles, historique des sessions, détail d'une session terminée.

### Frontend scope

UI continuer la session, historique, reprise, protection des routes completed.

### UX scope

Une session commencée doit être retrouvable sans surprise.

### Tests attendus

Tests lifecycle, resume, abandon, completed, navigation.

### Critères d'acceptation

L'utilisateur peut reprendre une session non terminée et consulter une session terminée.

### Non-objectifs

Pas de deep/exam complet.

### Risques

Lifecycle plus complexe autour des réponses partielles.

### Rapport attendu

`docs/core/CORE_11_SESSION_RESUME_HISTORY_REPORT.md`.

## PLUS-01 — Deep Revision course-level

### Objectif

Activer Révision approfondie en V1.

### Pourquoi maintenant

Deep doit venir après quick stable, sinon il duplique les mêmes fragilités.

### Repos concernés

API + App.

### Dépendances

STAB-02, CORE-11.

### Backend scope

Route course-level deep, sélection source/KU backend, action `OPEN_QUESTION`, correction IA réelle, mise à jour mastery, lifecycle deep minimal.

### Frontend scope

Déverrouiller le mode, page question ouverte premium, correction lisible, résultat ou retour progression.

### UX scope

Deep doit être présenté comme comprendre et expliquer, pas comme un QCM plus long.

### Tests attendus

Tests API deep, correction IA, mastery, UI open question, legacy non cassé.

### Critères d'acceptation

Un cours prêt permet une révision approfondie réelle et corrige une réponse ouverte.

### Non-objectifs

Pas d'exam.

### Risques

Coût IA et qualité de correction.

### Rapport attendu

`docs/core/PLUS_01_DEEP_REVISION_COURSE_LEVEL_REPORT.md`.

## PLUS-02 — Revision sheet complete / exam modes

### Objectif

Remplacer les faux onglets fiche par de vrais contenus.

### Pourquoi maintenant

Les onglets `Complète` et `Examen` ne doivent pas rester des promesses vides.

### Repos concernés

API + App.

### Dépendances

PLUS-01.

### Backend scope

Fiche complète multi-section, fiche avant examen, citations consultables, génération/régénération versionnée.

### Frontend scope

Vrais contenus d'onglets, états d'indisponibilité honnêtes, sources lisibles.

### UX scope

Une fiche doit être un outil de lecture, pas un mur de texte.

### Tests attendus

Tests génération, parser, sources, UI tabs.

### Critères d'acceptation

Chaque onglet visible a un comportement réel ou est clairement verrouillé.

### Non-objectifs

Pas de session exam.

### Risques

Contrats de fiche trop gros si non versionnés.

### Rapport attendu

`docs/core/PLUS_02_REVISION_SHEET_COMPLETE_EXAM_MODES_REPORT.md`.

## PLUS-03 — Exam preparation V1

### Objectif

Préparer un mode examen réel.

### Pourquoi maintenant

Exam doit utiliser des sources et résultats solides, pas être un skin du quick.

### Repos concernés

API + App.

### Dépendances

PLUS-02.

### Backend scope

Type de source examen, correction si utile, session chronométrée, QCM + questions ouvertes + cas pratiques, résultat exam distinct.

### Frontend scope

Flow exam immersif, timer, résultat, points faibles.

### UX scope

Exam doit être clairement plus exigeant et plus long que quick.

### Tests attendus

Tests session exam, scoring, temps, abandon, résultat.

### Critères d'acceptation

L'utilisateur peut lancer un entraînement examen réel depuis un cours prêt.

### Non-objectifs

Pas de proctoring, pas de notation officielle.

### Risques

Scope pédagogique très large.

### Rapport attendu

`docs/core/PLUS_03_EXAM_PREPARATION_V1_REPORT.md`.

## ADAPT-01 — Today / adaptive coach

### Objectif

Créer le vrai coach quotidien.

### Pourquoi maintenant

La progression existe, mais elle ne recommande pas encore l'action suivante.

### Repos concernés

API + App.

### Dépendances

CORE-11.

### Backend scope

Prochaine action recommandée, notion due, répétition espacée simple, plan 5/10/20 minutes, raisons pédagogiques.

### Frontend scope

Page Aujourd'hui, CTA direct, explication lisible.

### UX scope

L'utilisateur doit savoir quoi faire maintenant.

### Tests attendus

Tests recommandation, states no data, UI.

### Critères d'acceptation

Une page Today recommande une action honnête basée sur données réelles.

### Non-objectifs

Pas de gamification fictive.

### Risques

Recommandations pauvres si données insuffisantes.

### Rapport attendu

`docs/core/ADAPT_01_TODAY_ADAPTIVE_COACH_REPORT.md`.

## GENUI-01 — Controlled GenUI surface

### Objectif

Réintroduire GenUI de manière strictement bornée.

### Pourquoi maintenant

GenUI peut enrichir la pédagogie seulement si le payload est contrôlé.

### Repos concernés

API + App.

### Dépendances

STAB-02, ADAPT-01.

### Backend scope

Catalogue de widgets pédagogiques, validation de payload, fallback.

### Frontend scope

Rendu uniquement des widgets autorisés : `SummaryCard`, `SourceExcerptCard`, `McqQuestionCard`, `OpenQuestionCard`, `CorrectionPanel`, `NextActionCard`, `WeaknessCard`.

### UX scope

GenUI ne doit jamais ressembler à une interface arbitraire.

### Tests attendus

Tests schema, renderer, fallback invalid payload.

### Critères d'acceptation

Un payload invalide ne casse pas l'app et ne rend pas d'UI libre.

### Non-objectifs

Pas de génération de layout arbitraire.

### Risques

Sécurité et maintenabilité.

### Rapport attendu

`docs/core/GENUI_01_CONTROLLED_GENUI_SURFACE_REPORT.md`.

## RELEASE-01 — Production readiness

### Objectif

Préparer la mise en production.

### Pourquoi maintenant

La production ne peut pas reposer sur des validations manuelles dispersées.

### Repos concernés

API + App + Infra.

### Dépendances

Lots MVP validés.

### Backend scope

CI, tests backend complets, tests DB réels, worker/Redis, secrets/env, monitoring, logs IA, quotas IA, stockage cloud, suppression compte/données.

### Frontend scope

Tests Flutter complets, crash reporting, accessibilité, performances, builds signés.

### UX scope

Accessibilité, messages d'erreur, états offline si nécessaire.

### Tests attendus

Pipeline complet reproductible.

### Critères d'acceptation

Le produit peut être déployé et observé sans dépendre d'une session Codex.

### Non-objectifs

Pas de nouvelle feature produit.

### Risques

Temps d'infrastructure sous-estimé.

### Rapport attendu

`docs/core/RELEASE_01_PRODUCTION_READINESS_REPORT.md`.

## 10. Dépendances entre lots

```text
STAB-00
-> STAB-00B

STAB-00B
-> QUALITY-00
-> STAB-01A

STAB-01A
-> STAB-01B
-> CORE-09A

STAB-01B -> STAB-01C -> STAB-02A -> STAB-02B

CORE-09A
-> CORE-09B
-> CORE-09C
-> CORE-10A

CORE-10A
-> CORE-10B
-> CORE-11A
-> PLUS-01A

CORE-10B
-> CORE-10C
-> ADAPT-01

CORE-11A
-> CORE-11B
-> PLUS-01B

PLUS-01A -> PLUS-01B
STAB-02B + CORE-09A -> PLUS-02
PLUS-01B + PLUS-02 + CORE-11B -> PLUS-03
STAB-02B + ADAPT-01 + PLUS-01A -> GENUI-01
QUALITY-00 + lots MVP_STABLE requis -> RELEASE-01
```

Ce graphe n'est pas strictement linéaire. `QUALITY-00` peut avancer en parallèle de `STAB-01A`, et `PLUS-01A` ne dépend plus de tout `CORE-11`.

Le détail exécutable vit dans `EXECUTION_PLAN_V2.md`.

Le prochain lot recommandé est `QUALITY-00` en parallèle de `STAB-01A`.

## 11. Critères de sortie MVP

### MVP_STABLE

`MVP_STABLE` est atteint lorsque :

- `QUALITY-00` est terminé ;
- `STAB-01A`, `STAB-01B`, `STAB-01C` sont terminés ;
- `STAB-02A`, `STAB-02B` sont terminés ;
- `CORE-09A` est terminé ;
- `CORE-10A` est terminé ;
- `CORE-11A` est terminé ;
- le quick flow reste vert ;
- la suppression de source ne casse pas l'historique ;
- les sessions peuvent être reprises ;
- aucun onglet principal ne mène à une impasse ;
- aucun mode visible ne ment à l'utilisateur ;
- les validations CI sont reproductibles.

Deep, fiche complète, Exam, Today adaptatif et GenUI ne sont pas nécessaires pour déclarer le `MVP_STABLE`.

### Critères fonctionnels MVP Core déjà attendus

- Créer matière, cours et source PDF.
- Source traitée avec statut lisible.
- Fiche rapide réelle disponible.
- Quick revision réelle avec banque de questions persistée.
- Résultat réel avec corrections détaillées.
- Progression course/subject réelle.
- Navigation claire et immersive.
- Suppression/archive de source sûre.
- Aucun texte technique interne dans l'UI utilisateur.
- Tests critiques backend et Flutter reproductibles.
- Rapport et tracker à jour.

## 12. Risques majeurs

- UX trop confuse par rapport au moteur réel.
- Génération IA synchrone trop fragile.
- Source lifecycle insuffisant.
- Design system fragmenté.
- Trop de modes visibles mais non disponibles.
- Coût IA et quotas.
- Absence de CI systématique.
- Couplage Prisma trop fort dans certains services.
- Historique pédagogique cassé par suppression de données.

## 13. Politique de mise à jour

La roadmap doit être mise à jour après chaque lot selon `ROADMAP_UPDATE_PROTOCOL.md`. Elle ne doit pas être entièrement réécrite sauf décision produit explicite. Les lots futurs doivent ajouter leurs rapports dans `docs/core/`, `docs/ui/` ou un dossier équivalent, puis référencer ces rapports dans `LOT_TRACKER_V2.md`.

## 14. Points discutables

### Faut-il retirer Sources de la navigation principale ou le transformer en vraie bibliothèque globale ?

Avis : à court terme, retirer ou déprioriser Sources est plus cohérent. Les sources vivent d'abord dans les cours. Une bibliothèque globale peut devenir utile plus tard avec recherche, filtres, archives et usages cross-cours.

### Faut-il faire STAB-01/STAB-02 avant Deep ?

Avis : oui. Le moteur quick fonctionne déjà assez pour exposer les problèmes UX. Ajouter Deep maintenant amplifierait la confusion.

### Faut-il garder la navigation 5 onglets ou passer à 4 ?

Avis : 4 onglets semblent plus forts si Sources reste interne aux cours. Décision produit à valider par Yoahn après STAB-01.

### Faut-il faire de Today la page principale ?

Avis : pas encore. Today doit être principal quand la recommandation est réelle. Avant ADAPT-01, l'accueil matière active reste plus honnête.

### Faut-il masquer ou verrouiller les modes non disponibles ?

Avis : masquer si aucune valeur utilisateur ; verrouiller seulement si cela clarifie une trajectoire proche et avec wording non technique.

### Faut-il pré-générer la question bank en background avant de continuer ?

Avis : oui, probablement dans CORE-10. Le tap utilisateur ne doit pas dépendre d'une génération IA longue.

### Faut-il archiver les sources au lieu de les supprimer ?

Avis : oui dès qu'une source a servi à des sessions, fiches ou questions. La suppression physique doit être réservée aux sources sans historique ou à une purge encadrée.

### Faut-il dupliquer la roadmap dans les deux repos ou garder une source canonique côté frontend ?

Avis : source canonique côté app pour le produit, roadmap backend alignée côté API. Une duplication complète divergerait vite.

### Faut-il maintenir les flows legacy visibles ?

Avis : seulement s'ils ont une valeur actuelle. Sinon, les isoler ou les déprécier explicitement.

### Faut-il intégrer GenUI maintenant ou plus tard ?

Avis : plus tard. GenUI doit revenir après stabilisation des contrats et du design system.

~~~

### `docs/roadmap/v2/UX_UI_TARGET_V2.md`

~~~text
# UX/UI Target V2

Ce document décrit la cible UX/UI future de Revision Project. Il ne remplace pas les rapports UI existants ; il sert de boussole pour les prochains lots.

## 0. Référence visuelle canonique

La planche UI V2 doit vivre à terme ici :

```text
docs/roadmap/v2/assets/revision_project_ui_v2_board.png
```

Statut actuel : asset manquant. La direction visuelle reste décrite par ce document et par les rapports UI existants, mais aucune image ne doit être inventée.

La planche, une fois ajoutée, définit palette, surfaces, gradients, densité, navigation, matière active, hiérarchie des CTA, bottom sheets, sessions immersives, résultats et progression. Elle n'autorise jamais l'ajout de chiffres, streaks, gems, cours ou scores fictifs.

## 1. Principes de navigation

- Une matière active à la fois.
- Un cours est le point d'entrée principal pour sources, fiche, révision et progression.
- Une session est immersive : pas de bottom nav pendant le quiz, la correction ou un exam futur.
- Une destination principale doit porter une action claire.
- Les sources doivent d'abord être accessibles depuis le cours. L'onglet Sources global doit être justifié par une vraie bibliothèque ou retiré de la navigation principale.
- Le retour arrière ne doit pas empiler de nouvelles pages.

## 2. Règles de wording

- Ne pas afficher `MVP+`, `backend`, `payload`, `fixture`, `courseId`, `documentId`, `KnowledgeUnit`.
- Préférer `Bientôt disponible`, `Mode verrouillé`, `Ajoute une source`, `Source en analyse`, `Notions prêtes`.
- Ne pas utiliser d'écriture inclusive avec points médians dans l'interface utilisateur.
- Ne pas inventer des scores, streaks, gemmes ou jours de série.
- Ne pas promettre `Reprendre` si la dernière activité réelle n'est pas connue.

## 3. Règles de modes disabled

- Un mode non disponible doit être masqué ou verrouillé.
- Un mode verrouillé doit expliquer la condition utilisateur : `Disponible après une source prête`, `Disponible après une première session`, ou `Prévu plus tard`.
- Ne pas afficher un bouton actif qui déclenche seulement un snackbar d'échec.

## 4. Règles de loading, empty et error

- Loading : bloquer les actions concurrentes qui cassent la navigation, surtout au démarrage d'une session.
- Empty : expliquer l'action suivante, pas l'architecture.
- Error : dire quoi faire maintenant, sans codes techniques sauf écran debug.
- Retry : présent seulement si l'action peut réellement être retentée.

## 5. Règles design system

- Unifier les surfaces premium et les écrans legacy.
- Centraliser couleurs, gradients, rayons, ombres et styles texte.
- Éviter les styles locaux copiés dans les pages.
- Les headers doivent rester en haut ; éviter les centrages verticaux qui créent de grands vides.
- Le scroll doit concerner le contenu utile, pas toute la page par défaut.

## 6. Écrans cibles

### 6.1 Sign in / onboarding

- Rôle utilisateur : entrer dans le produit et comprendre la promesse.
- Données réelles nécessaires : état auth.
- Action principale : se connecter.
- Actions secondaires : aide, confidentialité si disponible.
- États empty/loading/error : chargement auth, erreur connexion.
- Ce qui est interdit : promesses IA non livrées, jargon technique.
- Problèmes actuels : écran encore legacy par rapport au premium.
- Lot de correction associé : STAB-02.

### 6.2 Accueil matière active

- Rôle utilisateur : voir la matière active et continuer.
- Données réelles nécessaires : matières, cours, sources prêtes, éventuellement dernière activité réelle.
- Action principale : ouvrir le cours pertinent ou créer un cours.
- Actions secondaires : changer/créer une matière, créer un cours.
- États empty/loading/error : aucune matière, aucune course, erreur sujets/cours.
- Ce qui est interdit : faux streaks, faux gemmes, `Reprendre` mensonger.
- Problèmes actuels : logique de reprise encore naïve, cartes parfois ellipsées.
- Lot de correction associé : STAB-01.

### 6.3 Sélecteur matière

- Rôle utilisateur : changer de contexte.
- Données réelles nécessaires : liste des matières.
- Action principale : choisir une matière.
- Actions secondaires : créer une matière.
- États empty/loading/error : aucune matière, erreur chargement.
- Ce qui est interdit : bloquer la création dans un cul-de-sac.
- Problèmes actuels : sélection possible, création moins accessible selon contexte.
- Lot de correction associé : STAB-01.

### 6.4 Gestion matières

- Rôle utilisateur : créer, renommer, supprimer ou archiver une matière.
- Données réelles nécessaires : sujets et contraintes de suppression.
- Action principale : créer une matière.
- Actions secondaires : modifier, supprimer/archiver.
- États empty/loading/error : liste vide, conflit suppression.
- Ce qui est interdit : suppression destructive silencieuse.
- Problèmes actuels : page matières legacy.
- Lot de correction associé : STAB-02.

### 6.5 Création cours

- Rôle utilisateur : structurer une matière en cours.
- Données réelles nécessaires : matière active.
- Action principale : créer cours.
- Actions secondaires : durée, description, chapitre si utile.
- États empty/loading/error : erreur validation, matière absente.
- Ce qui est interdit : champs techniques.
- Problèmes actuels : acceptable mais à aligner premium.
- Lot de correction associé : STAB-02.

### 6.6 Détail cours

- Rôle utilisateur : piloter un cours.
- Données réelles nécessaires : course detail, sources, progress, fiche availability, quick availability.
- Action principale : lancer l'action la plus utile selon état.
- Actions secondaires : fiche, sources, modifier, supprimer.
- États empty/loading/error : cours introuvable, source absente, source processing, progression vide.
- Ce qui est interdit : boutons actifs qui échouent sans explication.
- Problèmes actuels : page chargée, plusieurs sections concurrentes.
- Lot de correction associé : STAB-01.

### 6.7 Sources du cours

- Rôle utilisateur : ajouter, voir, supprimer ou archiver les PDF du cours.
- Données réelles nécessaires : documents course-level et statuts.
- Action principale : ajouter une source.
- Actions secondaires : refresh, supprimer/archiver, voir erreur.
- États empty/loading/error : aucune source, processing, failed.
- Ce qui est interdit : supprimer une source utilisée sans garde.
- Problèmes actuels : lifecycle source à durcir.
- Lot de correction associé : CORE-09.

### 6.8 Ajout source

- Rôle utilisateur : importer un PDF.
- Données réelles nécessaires : picker PDF, endpoint upload, statut processing.
- Action principale : choisir PDF.
- Actions secondaires : annuler.
- États empty/loading/error : upload en cours, PDF invalide, quota/provider IA.
- Ce qui est interdit : laisser l'utilisateur croire que le cours est prêt avant processing.
- Problèmes actuels : erreurs IA/provider encore trop visibles indirectement.
- Lot de correction associé : CORE-09.

### 6.9 Fiche de cours

- Rôle utilisateur : lire une synthèse exploitable.
- Données réelles nécessaires : revision sheet, sources de fiche.
- Action principale : lire la fiche rapide ou générer si possible.
- Actions secondaires : consulter sources, revenir au cours.
- États empty/loading/error : aucune source prête, fiche absente, génération en échec.
- Ce qui est interdit : faux onglets avec contenu absent, énorme bloc source inline.
- Problèmes actuels : tabs `Complète`/`Examen` encore partiels, sources déplacées mais à stabiliser.
- Lot de correction associé : STAB-01, PLUS-02.

### 6.10 Hub Révisions

- Rôle utilisateur : choisir comment travailler.
- Données réelles nécessaires : cours prêts, session en cours, modes disponibles.
- Action principale : lancer quick ou reprendre session.
- Actions secondaires : ouvrir un cours prêt.
- États empty/loading/error : aucun cours prêt, génération en cours.
- Ce qui est interdit : page explicative sans action directe.
- Problèmes actuels : encore trop dépendant de l'ouverture d'un cours.
- Lot de correction associé : STAB-01.

### 6.11 Session quick

- Rôle utilisateur : répondre à des questions courtes.
- Données réelles nécessaires : session, questions snapshot, réponses partielles futures.
- Action principale : répondre puis continuer.
- Actions secondaires : signaler question, quitter avec confirmation.
- États empty/loading/error : préparation, question invalide, submit failure, completion retry.
- Ce qui est interdit : bottom nav, score local, correction pré-submit.
- Problèmes actuels : reprise/historique partiels.
- Lot de correction associé : CORE-11.

### 6.12 Résultat quick

- Rôle utilisateur : comprendre ce qui est réussi et ce qui manque.
- Données réelles nécessaires : backend result, corrections, knowledge units, score.
- Action principale : revenir au cours ou revoir correction.
- Actions secondaires : voir fiche, refaire une session.
- États empty/loading/error : résultat absent, session non terminée.
- Ce qui est interdit : score client, confetti sous 70%.
- Problèmes actuels : résultat fonctionnel mais à relier à l'historique.
- Lot de correction associé : CORE-11.

### 6.13 Progrès

- Rôle utilisateur : voir la maîtrise réelle.
- Données réelles nécessaires : subject progress, course progress, mastery.
- Action principale : ouvrir un cours à travailler.
- Actions secondaires : changer matière.
- États empty/loading/error : aucune matière, aucune notion, aucune session.
- Ce qui est interdit : confondre source prête et maîtrise.
- Problèmes actuels : visuel amélioré mais encore perfectible.
- Lot de correction associé : STAB-01.

### 6.14 Profil

- Rôle utilisateur : gérer compte, préférences, données.
- Données réelles nécessaires : étudiant, auth, paramètres.
- Action principale : voir/mettre à jour le compte.
- Actions secondaires : déconnexion, suppression compte future.
- États empty/loading/error : auth absente, erreur profil.
- Ce qui est interdit : afficher des badges/gemmes fictifs.
- Problèmes actuels : écran legacy.
- Lot de correction associé : STAB-02.

### 6.15 Future Deep session

- Rôle utilisateur : répondre longuement et recevoir une correction.
- Données réelles nécessaires : source/KU backend, open question, correction IA, mastery update.
- Action principale : rédiger une réponse.
- Actions secondaires : consulter aide après correction.
- États empty/loading/error : pas de source prête, correction en cours, correction échouée.
- Ce qui est interdit : réutiliser quick avec un simple nouveau titre.
- Problèmes actuels : mode non implémenté.
- Lot de correction associé : PLUS-01.

### 6.16 Future Exam session

- Rôle utilisateur : s'entraîner en conditions d'examen.
- Données réelles nécessaires : sources examen, questions, timer, résultat exam.
- Action principale : lancer et terminer un entraînement.
- Actions secondaires : revoir points faibles.
- États empty/loading/error : aucune source examen, temps écoulé, correction échouée.
- Ce qui est interdit : vendre un mode examen sans contrat distinct.
- Problèmes actuels : mode non implémenté.
- Lot de correction associé : PLUS-03.

## 7. Éléments reportés

- Gamification réelle.
- Coach Today.
- Deep revision.
- Exam mode.
- GenUI contrôlé.
- Bibliothèque globale Sources.

## 8. Matrice de capacités UX/API

Statuts autorisés :

- `AVAILABLE_NOW` : contrat backend et écran ou flow déjà disponibles.
- `NEEDS_API` : l'UX souhaitée nécessite un lot backend avant d'afficher l'action comme disponible.
- `FUTURE` : capacité hors MVP stable ou horizon ultérieur.

| Capacité | Statut | Lot associé | Règle UX |
| --- | --- | --- | --- |
| Créer une matière | AVAILABLE_NOW | STAB-01C | Doit être découvrable depuis le sélecteur matière. |
| Supprimer une matière | AVAILABLE_NOW | STAB-01C | Afficher les conflits réels, pas de suppression silencieuse. |
| Renommer une matière | NEEDS_API | CORE-09C | Ne pas afficher comme action active avant l'API. |
| Archiver une matière | NEEDS_API | CORE-09C | Ne pas simuler côté front. |
| Créer un cours | AVAILABLE_NOW | STAB-01B | Action principale si une matière existe. |
| Supprimer un cours vide | AVAILABLE_NOW | STAB-01B | Garder les erreurs 409 lisibles. |
| Renommer ou modifier un cours | NEEDS_API | CORE-09C | Ne pas créer de bouton actif sans endpoint. |
| Ajouter une source | AVAILABLE_NOW | CORE-09A | Disponible depuis le cours. |
| Supprimer une source inutilisée | AVAILABLE_NOW | CORE-09A | Autorisé uniquement après décision lifecycle `DELETE`. |
| Archiver une source utilisée | AVAILABLE_NOW | CORE-09A | Retire la source des listes actives sans casser l'historique pédagogique. |
| Révision rapide | AVAILABLE_NOW | CORE-10A, CORE-11A | Disponible si source prête et questions préparées. |
| Révision approfondie | FUTURE | PLUS-01A | Masquer ou verrouiller clairement. |
| Préparation examen | FUTURE | PLUS-03 | Masquer ou verrouiller clairement. |
| Fiche rapide | AVAILABLE_NOW | STAB-01C | Ne pas afficher de contenu fictif si absente. |
| Fiche complète | FUTURE | PLUS-02 | Onglet masqué ou verrouillé tant que non livré. |
| Fiche examen | FUTURE | PLUS-02 | Onglet masqué ou verrouillé tant que non livré. |

Un lot frontend ne doit pas créer un bouton utilisateur pour une capacité `NEEDS_API` sans lot backend correspondant.

Le renommage et l'archive de matière/cours sont reliés à `CORE-09C`.

~~~

### `lib/features/courses/application/courses_providers.dart`

~~~text
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../documents/domain/revision_document.dart';
import '../../revision_sessions/domain/revision_session.dart';
import '../data/http_courses_repository.dart';
import '../domain/course_models.dart';
import '../domain/courses_repository.dart';
import 'course_pdf_picker.dart';

final coursesRepositoryProvider = Provider<CoursesRepository>((ref) {
  final dio = ref.read(dioProvider);
  final auth = ref.read(authControllerProvider);
  return HttpCoursesRepository(dio: dio, getIdToken: auth.requireIdToken);
});

final coursesProvider = FutureProvider.family<List<CourseListItem>, String>((
  ref,
  subjectId,
) {
  return ref.read(coursesRepositoryProvider).listCourses(subjectId: subjectId);
});

final courseDetailProvider = FutureProvider.family<CourseDetail, String>((
  ref,
  courseId,
) {
  return ref.read(coursesRepositoryProvider).getCourse(courseId: courseId);
});

final courseProgressProvider = FutureProvider.family<CourseProgress, String>((
  ref,
  courseId,
) {
  return ref
      .read(coursesRepositoryProvider)
      .getCourseProgress(courseId: courseId);
});

final subjectProgressProvider = FutureProvider.family<SubjectProgress, String>((
  ref,
  subjectId,
) {
  return ref
      .read(coursesRepositoryProvider)
      .getSubjectProgress(subjectId: subjectId);
});

final courseRevisionSheetProvider =
    FutureProvider.family<RevisionSheet?, String>((ref, courseId) {
      return ref
          .read(coursesRepositoryProvider)
          .getCourseRevisionSheet(courseId: courseId);
    });

final createCourseControllerProvider =
    NotifierProvider<CreateCourseController, AsyncValue<void>>(
      CreateCourseController.new,
    );

final uploadCourseDocumentControllerProvider =
    NotifierProvider<
      UploadCourseDocumentController,
      AsyncValue<CourseDocument?>
    >(UploadCourseDocumentController.new);

final deleteCourseDocumentControllerProvider =
    NotifierProvider<DeleteCourseDocumentController, AsyncValue<void>>(
      DeleteCourseDocumentController.new,
    );

final archiveCourseDocumentControllerProvider =
    NotifierProvider<ArchiveCourseDocumentController, AsyncValue<void>>(
      ArchiveCourseDocumentController.new,
    );

final generateCourseRevisionSheetControllerProvider =
    NotifierProvider<
      GenerateCourseRevisionSheetController,
      AsyncValue<RevisionSheet?>
    >(GenerateCourseRevisionSheetController.new);

final startCourseQuickRevisionControllerProvider =
    NotifierProvider<
      StartCourseQuickRevisionController,
      AsyncValue<RevisionSessionResponse?>
    >(StartCourseQuickRevisionController.new);

class CreateCourseController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<CourseListItem> create({
    required String subjectId,
    required CreateCourseInput input,
  }) async {
    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.createCourse(subjectId: subjectId, input: input),
    );
    state = result.whenData((_) {});

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    final course = result.requireValue;
    ref.invalidate(coursesProvider(subjectId));
    ref.invalidate(courseDetailProvider(course.id));

    return course;
  }
}

class UploadCourseDocumentController
    extends Notifier<AsyncValue<CourseDocument?>> {
  @override
  AsyncValue<CourseDocument?> build() => const AsyncData(null);

  Future<CourseDocument?> upload({required CourseDetail detail}) async {
    final picked = await ref.read(coursePdfPickerProvider).pickPdf();

    if (picked == null) {
      state = const AsyncData(null);
      return null;
    }

    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.uploadCoursePdf(
        courseId: detail.course.id,
        fileName: picked.fileName,
        bytes: picked.bytes,
      ),
    );

    state = result.whenData<CourseDocument?>((document) => document);

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    final uploaded = result.requireValue;
    ref.invalidate(courseDetailProvider(detail.course.id));
    ref.invalidate(courseProgressProvider(detail.course.id));
    ref.invalidate(coursesProvider(detail.course.subjectId));
    ref.invalidate(subjectProgressProvider(detail.course.subjectId));

    return uploaded;
  }
}

class DeleteCourseDocumentController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> delete({
    required CourseDetail detail,
    required String documentId,
  }) async {
    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.deleteCourseDocument(
        courseId: detail.course.id,
        documentId: documentId,
      ),
    );

    state = result;

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    ref.invalidate(courseDetailProvider(detail.course.id));
    ref.invalidate(courseProgressProvider(detail.course.id));
    ref.invalidate(coursesProvider(detail.course.subjectId));
    ref.invalidate(subjectProgressProvider(detail.course.subjectId));
  }
}

class ArchiveCourseDocumentController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> archive({
    required CourseDetail detail,
    required String documentId,
  }) async {
    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.archiveCourseDocument(
        courseId: detail.course.id,
        documentId: documentId,
      ),
    );

    state = result.whenData((_) {});

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    ref.invalidate(courseDetailProvider(detail.course.id));
    ref.invalidate(courseProgressProvider(detail.course.id));
    ref.invalidate(coursesProvider(detail.course.subjectId));
    ref.invalidate(subjectProgressProvider(detail.course.subjectId));
  }
}

class GenerateCourseRevisionSheetController
    extends Notifier<AsyncValue<RevisionSheet?>> {
  @override
  AsyncValue<RevisionSheet?> build() => const AsyncData(null);

  Future<RevisionSheet> generate({required String courseId}) async {
    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.generateCourseRevisionSheet(courseId: courseId),
    );

    state = result.whenData<RevisionSheet?>((sheet) => sheet);

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    final sheet = result.requireValue;
    ref.invalidate(courseRevisionSheetProvider(courseId));

    return sheet;
  }
}

class StartCourseQuickRevisionController
    extends Notifier<AsyncValue<RevisionSessionResponse?>> {
  @override
  AsyncValue<RevisionSessionResponse?> build() => const AsyncData(null);

  Future<RevisionSessionResponse> start({
    CourseDetail? detail,
    String? courseId,
    int questionCount = 10,
  }) async {
    final resolvedCourseId = courseId ?? detail?.course.id;
    if (resolvedCourseId == null) {
      throw ArgumentError('A course id is required to start quick revision');
    }

    state = const AsyncLoading();
    final repository = ref.read(coursesRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.startCourseQuickRevision(
        courseId: resolvedCourseId,
        questionCount: questionCount,
      ),
    );

    state = result.whenData<RevisionSessionResponse?>((response) => response);

    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }

    return result.requireValue;
  }
}

~~~

### `lib/features/courses/data/http_courses_repository.dart`

~~~text
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../domain/course_models.dart';
import '../domain/courses_repository.dart';
import '../../documents/data/revision_sheet_json.dart';
import '../../documents/domain/revision_document.dart';
import '../../documents/domain/source_lifecycle.dart';
import '../../revision_sessions/data/http_revision_sessions_api.dart';
import '../../revision_sessions/domain/revision_session.dart';

class HttpCoursesRepository implements CoursesRepository {
  HttpCoursesRepository({
    required Dio dio,
    required Future<String> Function() getIdToken,
  }) : this._(dio, getIdToken);

  const HttpCoursesRepository._(this._dio, this._getIdToken);

  final Dio _dio;
  final Future<String> Function() _getIdToken;

  @override
  Future<List<CourseListItem>> listCourses({required String subjectId}) async {
    final response = await _dio.get<Object?>(
      '/subjects/${Uri.encodeComponent(subjectId)}/courses',
      options: await _authorizedOptions(),
    );
    final rawCourses = response.data;

    if (rawCourses is! List) {
      throw const FormatException('Invalid courses response');
    }

    return rawCourses
        .map((course) => _CourseJson(course).toListItem())
        .toList(growable: false);
  }

  @override
  Future<CourseDetail> getCourse({required String courseId}) async {
    try {
      final response = await _dio.get<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}',
        options: await _authorizedOptions(),
      );

      return _CourseDetailJson(response.data).toDetail();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      rethrow;
    }
  }

  @override
  Future<CourseListItem> createCourse({
    required String subjectId,
    required CreateCourseInput input,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/subjects/${Uri.encodeComponent(subjectId)}/courses',
        data: {
          'title': input.title,
          'description': input.description,
          'chapterLabel': input.chapterLabel,
          'estimatedMinutes': input.estimatedMinutes,
        },
        options: await _authorizedOptions(),
      );

      return _CourseJson(response.data).toListItem();
    } on DioException catch (error) {
      if (error.response?.statusCode == 400) {
        throw const CourseRequestException('Invalid course request');
      }
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course subject not found');
      }
      rethrow;
    }
  }

  @override
  Future<CourseDocument> uploadCoursePdf({
    required String courseId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/source/course-pdf',
        data: FormData.fromMap({
          'file': MultipartFile.fromBytes(
            bytes,
            filename: fileName,
            contentType: DioMediaType('application', 'pdf'),
          ),
        }),
        options: await _authorizedOptions(),
      );

      return _CourseDocumentJson(response.data).toDocument();
    } on DioException catch (error) {
      if (error.response?.statusCode == 400) {
        throw const CourseUploadException('Invalid course PDF upload');
      }
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteCourseDocument({
    required String courseId,
    required String documentId,
  }) async {
    try {
      await _dio.delete<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/sources/${Uri.encodeComponent(documentId)}',
        options: await _authorizedOptions(),
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course source not found');
      }
      if (error.response?.statusCode == 409) {
        throw CourseRequestException(
          _responseMessage(error) ?? 'Cette source ne peut pas être supprimée.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<SourceLifecycleDecision> getCourseDocumentLifecycle({
    required String courseId,
    required String documentId,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/sources/${Uri.encodeComponent(documentId)}/lifecycle',
        options: await _authorizedOptions(),
      );

      return SourceLifecycleDecisionJson(response.data).toDecision();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course source not found');
      }
      rethrow;
    }
  }

  @override
  Future<SourceLifecycleDecision> archiveCourseDocument({
    required String courseId,
    required String documentId,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/sources/${Uri.encodeComponent(documentId)}/archive',
        options: await _authorizedOptions(),
      );

      return SourceLifecycleDecisionJson(response.data).toDecision();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course source not found');
      }
      if (error.response?.statusCode == 409) {
        throw CourseRequestException(
          _responseMessage(error) ?? 'Cette source ne peut pas être archivée.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<RevisionSheet?> getCourseRevisionSheet({
    required String courseId,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/revision-sheet',
        options: await _authorizedOptions(),
      );

      return RevisionSheetJson(response.data).toRevisionSheet();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        final message = _responseMessage(error);
        if (message == 'Revision sheet not found') {
          return null;
        }

        // CORE-04-bis: an ambiguous 404 is safer as a missing course than as
        // a missing sheet, otherwise a deleted/unknown course looks generatable.
        throw const CourseNotFoundException('Course not found');
      }
      if (error.response?.statusCode == 409) {
        throw const CourseRevisionSheetNotReadyException(
          'Course has no ready source',
        );
      }
      rethrow;
    }
  }

  @override
  Future<RevisionSheet> generateCourseRevisionSheet({
    required String courseId,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/revision-sheet',
        options: await _authorizedOptions(),
      );

      return RevisionSheetJson(response.data).toRevisionSheet();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      if (error.response?.statusCode == 409) {
        throw const CourseRevisionSheetNotReadyException(
          'Course has no ready source',
        );
      }
      rethrow;
    }
  }

  @override
  Future<RevisionSessionResponse> startCourseQuickRevision({
    required String courseId,
    int questionCount = 10,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/revision-sessions/quick',
        data: {'questionCount': questionCount},
        options: await _authorizedOptions(),
      );

      return RevisionSessionResponseJson(response.data).toResponse();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      if (error.response?.statusCode == 409) {
        final message = _responseMessage(error);
        throw CourseQuickRevisionUnavailableException(
          message ?? 'Course quick revision is not available',
        );
      }
      rethrow;
    }
  }

  @override
  Future<CourseProgress> getCourseProgress({required String courseId}) async {
    try {
      final response = await _dio.get<Object?>(
        '/courses/${Uri.encodeComponent(courseId)}/progress',
        options: await _authorizedOptions(),
      );

      return _CourseProgressJson(response.data).toProgress();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course not found');
      }
      rethrow;
    }
  }

  @override
  Future<SubjectProgress> getSubjectProgress({
    required String subjectId,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/subjects/${Uri.encodeComponent(subjectId)}/progress',
        options: await _authorizedOptions(),
      );

      return _SubjectProgressJson(response.data).toProgress();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        throw const CourseNotFoundException('Course subject not found');
      }
      rethrow;
    }
  }

  Future<Options> _authorizedOptions() async {
    final token = (await _getIdToken()).trim();

    if (token.isEmpty) {
      throw StateError('A Firebase ID token is required to load courses');
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  String? _responseMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, Object?>) {
      final message = data['message'];
      if (message is String) {
        return message;
      }
    }

    return null;
  }
}

class _CourseJson {
  const _CourseJson(this.value);

  final Object? value;

  CourseListItem toListItem() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid course response');
    }

    final id = json['id'];
    final subjectId = json['subjectId'];
    final title = json['title'];
    final description = json['description'];
    final chapterLabel = json['chapterLabel'];
    final estimatedMinutes = json['estimatedMinutes'];
    final displayOrder = json['displayOrder'];
    final sourceCount = json['sourceCount'];
    final readySourceCount = json['readySourceCount'];
    final processingSourceCount = json['processingSourceCount'];
    final failedSourceCount = json['failedSourceCount'];

    if (id is! String ||
        subjectId is! String ||
        title is! String ||
        displayOrder is! int ||
        sourceCount is! int ||
        readySourceCount is! int ||
        processingSourceCount is! int ||
        failedSourceCount is! int) {
      throw const FormatException('Invalid course response');
    }

    return CourseListItem(
      id: id,
      subjectId: subjectId,
      title: title,
      description: description is String ? description : null,
      chapterLabel: chapterLabel is String ? chapterLabel : null,
      estimatedMinutes: estimatedMinutes is int ? estimatedMinutes : null,
      displayOrder: displayOrder,
      createdAt: _parseOptionalDate(json['createdAt']),
      updatedAt: _parseOptionalDate(json['updatedAt']),
      sourceCount: sourceCount,
      readySourceCount: readySourceCount,
      processingSourceCount: processingSourceCount,
      failedSourceCount: failedSourceCount,
    );
  }
}

class _CourseDetailJson {
  const _CourseDetailJson(this.value);

  final Object? value;

  CourseDetail toDetail() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid course detail response');
    }

    final subject = json['subject'];
    final sources = json['sources'];

    if (subject is! Map<String, Object?> || sources is! List) {
      throw const FormatException('Invalid course detail response');
    }

    final subjectId = subject['id'];
    final subjectName = subject['name'];

    if (subjectId is! String || subjectName is! String) {
      throw const FormatException('Invalid course detail response');
    }

    return CourseDetail(
      course: _CourseJson(json['course']).toListItem(),
      subject: CourseSubjectSummary(id: subjectId, name: subjectName),
      sources: sources
          .map((source) => _CourseDocumentJson(source).toDocument())
          .toList(growable: false),
    );
  }
}

class _CourseDocumentJson {
  const _CourseDocumentJson(this.value);

  final Object? value;

  CourseDocument toDocument() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid course source response');
    }

    final id = json['id'];
    final courseId = json['courseId'];
    final documentId = json['documentId'];
    final fileName = json['fileName'];
    final kind = json['kind'];
    final status = json['status'];
    final errorCode = json['errorCode'];

    if (id is! String ||
        courseId is! String ||
        documentId is! String ||
        fileName is! String ||
        kind is! String ||
        status is! String) {
      throw const FormatException('Invalid course source response');
    }

    return CourseDocument(
      id: id,
      courseId: courseId,
      documentId: documentId,
      fileName: fileName,
      kind: kind,
      status: _parseDocumentStatus(status),
      errorCode: errorCode is String ? errorCode : null,
      createdAt: _parseOptionalDate(json['createdAt']),
      updatedAt: _parseOptionalDate(json['updatedAt']),
    );
  }
}

class _CourseProgressJson {
  const _CourseProgressJson(this.value);

  final Object? value;

  CourseProgress toProgress() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid course progress response');
    }

    final courseId = json['courseId'];
    final subjectId = json['subjectId'];
    final knowledgeUnitCount = json['knowledgeUnitCount'];
    final practicedKnowledgeUnitCount = json['practicedKnowledgeUnitCount'];
    final coverage = json['coverage'];
    final mastery = json['mastery'];
    final estimatedGlobalMastery = json['estimatedGlobalMastery'];
    final readySourceCount = json['readySourceCount'];
    final processingSourceCount = json['processingSourceCount'];
    final failedSourceCount = json['failedSourceCount'];
    final state = json['state'];

    if (courseId is! String ||
        subjectId is! String ||
        knowledgeUnitCount is! int ||
        practicedKnowledgeUnitCount is! int ||
        coverage is! num ||
        (mastery != null && mastery is! num) ||
        estimatedGlobalMastery is! num ||
        readySourceCount is! int ||
        processingSourceCount is! int ||
        failedSourceCount is! int ||
        state is! String) {
      throw const FormatException('Invalid course progress response');
    }

    return CourseProgress(
      courseId: courseId,
      subjectId: subjectId,
      knowledgeUnitCount: knowledgeUnitCount,
      practicedKnowledgeUnitCount: practicedKnowledgeUnitCount,
      coverage: coverage.toDouble(),
      mastery: mastery is num ? mastery.toDouble() : null,
      estimatedGlobalMastery: estimatedGlobalMastery.toDouble(),
      readySourceCount: readySourceCount,
      processingSourceCount: processingSourceCount,
      failedSourceCount: failedSourceCount,
      lastPracticedAt: _parseOptionalDate(json['lastPracticedAt']),
      state: _parseProgressState(state),
    );
  }
}

class _SubjectProgressJson {
  const _SubjectProgressJson(this.value);

  final Object? value;

  SubjectProgress toProgress() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid subject progress response');
    }

    final subjectId = json['subjectId'];
    final knowledgeUnitCount = json['knowledgeUnitCount'];
    final practicedKnowledgeUnitCount = json['practicedKnowledgeUnitCount'];
    final coverage = json['coverage'];
    final mastery = json['mastery'];
    final estimatedGlobalMastery = json['estimatedGlobalMastery'];
    final courseCount = json['courseCount'];
    final readyCourseCount = json['readyCourseCount'];
    final courses = json['courses'];

    if (subjectId is! String ||
        knowledgeUnitCount is! int ||
        practicedKnowledgeUnitCount is! int ||
        coverage is! num ||
        (mastery != null && mastery is! num) ||
        estimatedGlobalMastery is! num ||
        courseCount is! int ||
        readyCourseCount is! int ||
        courses is! List) {
      throw const FormatException('Invalid subject progress response');
    }

    return SubjectProgress(
      subjectId: subjectId,
      knowledgeUnitCount: knowledgeUnitCount,
      practicedKnowledgeUnitCount: practicedKnowledgeUnitCount,
      coverage: coverage.toDouble(),
      mastery: mastery is num ? mastery.toDouble() : null,
      estimatedGlobalMastery: estimatedGlobalMastery.toDouble(),
      courseCount: courseCount,
      readyCourseCount: readyCourseCount,
      lastPracticedAt: _parseOptionalDate(json['lastPracticedAt']),
      courses: courses
          .map((course) => _SubjectCourseProgressJson(course).toItem())
          .toList(growable: false),
    );
  }
}

class _SubjectCourseProgressJson {
  const _SubjectCourseProgressJson(this.value);

  final Object? value;

  SubjectCourseProgressItem toItem() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid subject course progress response');
    }

    final courseId = json['courseId'];
    final title = json['title'];
    final knowledgeUnitCount = json['knowledgeUnitCount'];
    final practicedKnowledgeUnitCount = json['practicedKnowledgeUnitCount'];
    final coverage = json['coverage'];
    final mastery = json['mastery'];
    final estimatedGlobalMastery = json['estimatedGlobalMastery'];
    final state = json['state'];

    if (courseId is! String ||
        title is! String ||
        knowledgeUnitCount is! int ||
        practicedKnowledgeUnitCount is! int ||
        coverage is! num ||
        (mastery != null && mastery is! num) ||
        estimatedGlobalMastery is! num ||
        state is! String) {
      throw const FormatException('Invalid subject course progress response');
    }

    return SubjectCourseProgressItem(
      courseId: courseId,
      title: title,
      knowledgeUnitCount: knowledgeUnitCount,
      practicedKnowledgeUnitCount: practicedKnowledgeUnitCount,
      coverage: coverage.toDouble(),
      mastery: mastery is num ? mastery.toDouble() : null,
      estimatedGlobalMastery: estimatedGlobalMastery.toDouble(),
      state: _parseProgressState(state),
    );
  }
}

CourseDocumentStatus _parseDocumentStatus(String value) {
  return switch (value) {
    'UPLOADED' => CourseDocumentStatus.uploaded,
    'PROCESSING' => CourseDocumentStatus.processing,
    'READY' => CourseDocumentStatus.ready,
    'FAILED' => CourseDocumentStatus.failed,
    _ => throw const FormatException('Unknown course source status'),
  };
}

CourseProgressState _parseProgressState(String value) {
  return switch (value) {
    'NO_SOURCE' => CourseProgressState.noSource,
    'PROCESSING' => CourseProgressState.processing,
    'FAILED_ONLY' => CourseProgressState.failedOnly,
    'NO_KNOWLEDGE_UNITS' => CourseProgressState.noKnowledgeUnits,
    'READY_NOT_PRACTICED' => CourseProgressState.readyNotPracticed,
    'PRACTICED' => CourseProgressState.practiced,
    _ => CourseProgressState.unknown,
  };
}

DateTime? _parseOptionalDate(Object? value) {
  if (value == null) {
    return null;
  }

  if (value is! String) {
    throw const FormatException('Invalid date response');
  }

  return DateTime.parse(value);
}

~~~

### `lib/features/courses/domain/courses_repository.dart`

~~~text
import 'dart:typed_data';

import '../../documents/domain/revision_document.dart';
import '../../documents/domain/source_lifecycle.dart';
import '../../revision_sessions/domain/revision_session.dart';
import 'course_models.dart';

abstract interface class CoursesRepository {
  Future<List<CourseListItem>> listCourses({required String subjectId});

  Future<CourseDetail> getCourse({required String courseId});

  Future<CourseListItem> createCourse({
    required String subjectId,
    required CreateCourseInput input,
  });

  Future<CourseDocument> uploadCoursePdf({
    required String courseId,
    required String fileName,
    required Uint8List bytes,
  });

  Future<void> deleteCourseDocument({
    required String courseId,
    required String documentId,
  });

  Future<SourceLifecycleDecision> getCourseDocumentLifecycle({
    required String courseId,
    required String documentId,
  });

  Future<SourceLifecycleDecision> archiveCourseDocument({
    required String courseId,
    required String documentId,
  });

  Future<RevisionSheet?> getCourseRevisionSheet({required String courseId});

  Future<RevisionSheet> generateCourseRevisionSheet({required String courseId});

  Future<RevisionSessionResponse> startCourseQuickRevision({
    required String courseId,
    int questionCount = 10,
  });

  Future<CourseProgress> getCourseProgress({required String courseId});

  Future<SubjectProgress> getSubjectProgress({required String subjectId});
}

class CreateCourseInput {
  const CreateCourseInput({
    required this.title,
    this.description,
    this.chapterLabel,
    this.estimatedMinutes,
  });

  final String title;
  final String? description;
  final String? chapterLabel;
  final int? estimatedMinutes;
}

class CourseNotFoundException implements Exception {
  const CourseNotFoundException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CourseRequestException implements Exception {
  const CourseRequestException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CourseUploadException implements Exception {
  const CourseUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CourseRevisionSheetNotReadyException implements Exception {
  const CourseRevisionSheetNotReadyException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CourseQuickRevisionUnavailableException implements Exception {
  const CourseQuickRevisionUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}

~~~

### `lib/features/courses/presentation/widgets/course_sources_bottom_sheet.dart`

~~~text
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../../presentation/design_system/components/revision_states.dart';
import '../../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../../presentation/design_system/tokens/revision_typography.dart';
import '../../../documents/domain/source_lifecycle.dart';
import '../../application/courses_providers.dart';
import '../../domain/course_models.dart';

class CourseSourcesBottomSheet extends ConsumerWidget {
  const CourseSourcesBottomSheet({required this.detail, super.key});

  final CourseDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadCourseDocumentControllerProvider);
    final deleteState = ref.watch(deleteCourseDocumentControllerProvider);
    final archiveState = ref.watch(archiveCourseDocumentControllerProvider);
    final isUploading = uploadState.isLoading;
    final isUpdatingSource = deleteState.isLoading || archiveState.isLoading;
    final sources = detail.sources;

    return RevisionBottomSheetFrame(
      title: 'Sources',
      subtitle: detail.course.title,
      floatingAction: RevisionFloatingAddButton(
        onTap: isUploading ? null : () => _uploadSource(context, ref),
      ),
      children: [
        if (sources.isEmpty)
          RevisionEmptyState(
            title: 'Aucune source attachée',
            message:
                'Ajoute un PDF pour lancer le traitement documentaire de ce cours.',
            icon: Icons.source_outlined,
          )
        else
          for (final source in sources)
            RevisionSourceFileCard(
              fileName: source.fileName,
              statusLabel: _sourceStatusLabel(source),
              statusColor: _statusColor(source.status),
              trailing: IconButton(
                tooltip: 'Gérer la source ${source.fileName}',
                onPressed: isUpdatingSource
                    ? null
                    : () => _manageSource(context, ref, source),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: RevisionColors.textMuted,
                ),
              ),
            ),
        if (isUploading)
          const RevisionProcessingState(
            title: 'Upload en cours...',
            message: 'La source est envoyée pour analyse.',
          ),
        if (uploadState.hasError)
          Text(
            'Upload impossible pour le moment.',
            style: RevisionTypography.caption.copyWith(
              color: RevisionColors.red,
            ),
          ),
        if (deleteState.hasError)
          Text(
            'Impossible de modifier cette source.',
            style: RevisionTypography.caption.copyWith(
              color: RevisionColors.red,
            ),
          ),
        if (archiveState.hasError)
          Text(
            'Impossible d’archiver cette source.',
            style: RevisionTypography.caption.copyWith(
              color: RevisionColors.red,
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              ref.invalidate(courseDetailProvider(detail.course.id));
              ref.invalidate(courseProgressProvider(detail.course.id));
              ref.invalidate(subjectProgressProvider(detail.course.subjectId));
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Rafraîchir'),
          ),
        ),
      ],
    );
  }

  Future<void> _uploadSource(BuildContext context, WidgetRef ref) async {
    try {
      final uploaded = await ref
          .read(uploadCourseDocumentControllerProvider.notifier)
          .upload(detail: detail);

      if (!context.mounted || uploaded == null) {
        return;
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Source ajoutée')));
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ajouter cette source PDF.')),
      );
    }
  }

  Future<void> _manageSource(
    BuildContext context,
    WidgetRef ref,
    CourseDocument source,
  ) async {
    SourceLifecycleDecision decision;
    try {
      decision = await ref
          .read(coursesRepositoryProvider)
          .getCourseDocumentLifecycle(
            courseId: detail.course.id,
            documentId: source.documentId,
          );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de vérifier cette source.')),
      );
      return;
    }

    if (!context.mounted) {
      return;
    }

    switch (decision.recommendedAction) {
      case SourceLifecycleAction.delete:
        await _deleteSource(context, ref, source);
        break;
      case SourceLifecycleAction.archive:
        await _archiveSource(context, ref, source);
        break;
      case SourceLifecycleAction.block:
      case SourceLifecycleAction.unknown:
        await _showLifecycleBlockedDialog(context, decision);
        break;
    }
  }

  Future<void> _deleteSource(
    BuildContext context,
    WidgetRef ref,
    CourseDocument source,
  ) async {
    final confirmed = await _confirmDeleteSource(context, source.fileName);
    if (!confirmed || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(deleteCourseDocumentControllerProvider.notifier)
          .delete(detail: detail, documentId: source.documentId);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Source supprimée')));
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de supprimer cette source.')),
      );
    }
  }

  Future<void> _archiveSource(
    BuildContext context,
    WidgetRef ref,
    CourseDocument source,
  ) async {
    final confirmed = await _confirmArchiveSource(context, source.fileName);
    if (!confirmed || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(archiveCourseDocumentControllerProvider.notifier)
          .archive(detail: detail, documentId: source.documentId);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Source archivée')));
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’archiver cette source.')),
      );
    }
  }
}

Future<bool> _confirmDeleteSource(BuildContext context, String fileName) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Supprimer cette source ?'),
      content: Text(
        'Le PDF "$fileName" sera retiré de ce cours. Tu pourras le rajouter plus tard si besoin.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}

Future<bool> _confirmArchiveSource(
  BuildContext context,
  String fileName,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Archiver cette source ?'),
      content: Text(
        'Le PDF "$fileName" ne sera plus utilisé pour préparer de nouvelles révisions, mais l’historique déjà créé sera conservé.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Archiver'),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}

Future<void> _showLifecycleBlockedDialog(
  BuildContext context,
  SourceLifecycleDecision decision,
) {
  final message = decision.blockingReasons.contains('SOURCE_PROCESSING')
      ? 'Cette source est encore en cours d’analyse. Réessaie quand elle sera prête.'
      : 'Cette source ne peut pas être modifiée pour le moment.';

  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Action indisponible'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Compris'),
        ),
      ],
    ),
  );
}

String _statusLabel(CourseDocumentStatus status) {
  return switch (status) {
    CourseDocumentStatus.uploaded => 'Téléversée',
    CourseDocumentStatus.processing => 'Traitement en cours',
    CourseDocumentStatus.ready => 'Prête',
    CourseDocumentStatus.failed => 'Erreur',
    CourseDocumentStatus.unknown => 'Statut inconnu',
  };
}

String _sourceStatusLabel(CourseDocument source) {
  if (source.status != CourseDocumentStatus.failed) {
    return _statusLabel(source.status);
  }

  return '${_statusLabel(source.status)} · ${_analysisErrorLabel(source.errorCode)}';
}

String _analysisErrorLabel(String? errorCode) {
  return switch (errorCode) {
    'KNOWLEDGE_EXTRACTION_FAILED' => 'Analyse du PDF impossible',
    'KNOWLEDGE_EXTRACTION_EMPTY' => 'Aucune notion trouvée',
    'DOCUMENT_TEXT_EMPTY' => 'PDF sans texte exploitable',
    _ => 'Erreur d’analyse',
  };
}

Color _statusColor(CourseDocumentStatus status) {
  return switch (status) {
    CourseDocumentStatus.ready => RevisionColors.mint,
    CourseDocumentStatus.processing => RevisionColors.blue,
    CourseDocumentStatus.failed => RevisionColors.red,
    CourseDocumentStatus.uploaded => RevisionColors.amber,
    CourseDocumentStatus.unknown => RevisionColors.violet,
  };
}

~~~

### `lib/features/documents/application/documents_controller.dart`

~~~text
import 'dart:typed_data';

import '../domain/revision_document.dart';
import '../domain/source_lifecycle.dart';

abstract interface class DocumentsApi {
  Future<RevisionDocument> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  });

  Future<List<RevisionDocument>> listSubjectDocuments({
    required String subjectId,
  });

  Future<RevisionDocument> getDocument({required String documentId});

  Future<void> deleteDocument({required String documentId});

  Future<SourceLifecycleDecision> getDocumentLifecycle({
    required String documentId,
  });

  Future<SourceLifecycleDecision> archiveDocument({required String documentId});

  Future<DocumentKnowledgeUnitsResponse> listDocumentKnowledgeUnits({
    required String documentId,
  });

  Future<DocumentSummary?> getDocumentSummary({required String documentId});

  Future<DocumentSummary> generateDocumentSummary({required String documentId});

  Future<RevisionSheet?> getRevisionSheet({required String documentId});

  Future<RevisionSheet> generateRevisionSheet({required String documentId});
}

enum DocumentDetailLoadState { notReady, ready, failed }

class DocumentDetail {
  const DocumentDetail({
    required this.document,
    required this.knowledgeUnits,
    required this.state,
  });

  final RevisionDocument document;
  final List<DocumentKnowledgeUnit> knowledgeUnits;
  final DocumentDetailLoadState state;
}

class DocumentArtifacts {
  const DocumentArtifacts({required this.summary, required this.revisionSheet});

  final DocumentSummary? summary;
  final RevisionSheet? revisionSheet;

  DocumentArtifacts copyWith({
    DocumentSummary? summary,
    RevisionSheet? revisionSheet,
  }) {
    return DocumentArtifacts(
      summary: summary ?? this.summary,
      revisionSheet: revisionSheet ?? this.revisionSheet,
    );
  }
}

class DocumentsController {
  const DocumentsController(this._api);

  final DocumentsApi _api;

  Future<RevisionDocument> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    return _api.uploadCoursePdf(
      subjectId: subjectId,
      fileName: fileName,
      bytes: bytes,
    );
  }

  Future<List<RevisionDocument>> listSubjectDocuments(String subjectId) {
    return _api.listSubjectDocuments(subjectId: subjectId);
  }

  Future<RevisionDocument> getDocument(String documentId) {
    return _api.getDocument(documentId: documentId);
  }

  Future<void> deleteDocument(String documentId) {
    final trimmed = documentId.trim();

    if (trimmed.isEmpty) {
      throw ArgumentError('Document id is required');
    }

    return _api.deleteDocument(documentId: trimmed);
  }

  Future<SourceLifecycleDecision> getDocumentLifecycle(String documentId) {
    final trimmed = documentId.trim();

    if (trimmed.isEmpty) {
      throw ArgumentError('Document id is required');
    }

    return _api.getDocumentLifecycle(documentId: trimmed);
  }

  Future<SourceLifecycleDecision> archiveDocument(String documentId) {
    final trimmed = documentId.trim();

    if (trimmed.isEmpty) {
      throw ArgumentError('Document id is required');
    }

    return _api.archiveDocument(documentId: trimmed);
  }

  Future<DocumentKnowledgeUnitsResponse> listDocumentKnowledgeUnits(
    String documentId,
  ) {
    return _api.listDocumentKnowledgeUnits(documentId: documentId);
  }

  Future<DocumentArtifacts> loadDocumentArtifacts(String documentId) async {
    final summary = await _api.getDocumentSummary(documentId: documentId);
    final revisionSheet = await _api.getRevisionSheet(documentId: documentId);

    return DocumentArtifacts(summary: summary, revisionSheet: revisionSheet);
  }

  Future<DocumentSummary> generateDocumentSummary(String documentId) {
    return _api.generateDocumentSummary(documentId: documentId);
  }

  Future<RevisionSheet> generateRevisionSheet(String documentId) {
    return _api.generateRevisionSheet(documentId: documentId);
  }

  Future<DocumentDetail> loadDocumentDetail(String documentId) async {
    final document = await getDocument(documentId);

    if (document.status == 'FAILED') {
      return DocumentDetail(
        document: document,
        knowledgeUnits: const [],
        state: DocumentDetailLoadState.failed,
      );
    }

    if (document.status != 'READY') {
      return DocumentDetail(
        document: document,
        knowledgeUnits: const [],
        state: DocumentDetailLoadState.notReady,
      );
    }

    try {
      final response = await listDocumentKnowledgeUnits(documentId);

      return DocumentDetail(
        document: document,
        knowledgeUnits: response.items,
        state: DocumentDetailLoadState.ready,
      );
    } on DocumentNotReadyException {
      return DocumentDetail(
        document: document,
        knowledgeUnits: const [],
        state: DocumentDetailLoadState.notReady,
      );
    }
  }
}

class DocumentNotReadyException implements Exception {
  const DocumentNotReadyException();
}

class DocumentArtifactRequestException implements Exception {
  const DocumentArtifactRequestException({required this.statusCode});

  final int statusCode;
}

~~~

### `lib/features/documents/application/subject_documents_notifier.dart`

~~~text
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/di/providers.dart';
import '../domain/revision_document.dart';

part 'subject_documents_notifier.g.dart';

@riverpod
class SubjectDocumentsNotifier extends _$SubjectDocumentsNotifier {
  @override
  Future<List<RevisionDocument>> build(String subjectId) {
    return ref
        .read(documentsApiProvider)
        .listSubjectDocuments(subjectId: subjectId);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(documentsApiProvider)
          .listSubjectDocuments(subjectId: subjectId),
    );
  }

  Future<void> deleteDocument(String documentId) async {
    await ref.read(documentsApiProvider).deleteDocument(documentId: documentId);
    await reload();
  }

  Future<void> archiveDocument(String documentId) async {
    await ref
        .read(documentsApiProvider)
        .archiveDocument(documentId: documentId);
    await reload();
  }
}

final subjectDocumentsNotifierProvider = subjectDocumentsProvider;

~~~

### `lib/features/documents/data/documents_api.dart`

~~~text
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../application/documents_controller.dart';
import '../domain/revision_document.dart';
import '../domain/source_lifecycle.dart';
import 'revision_sheet_json.dart';

class HttpDocumentsApi implements DocumentsApi {
  HttpDocumentsApi({
    required Dio dio,
    required Future<String?> Function() getIdToken,
  }) : this._(dio, getIdToken);

  const HttpDocumentsApi._(this._dio, this._getIdToken);

  final Dio _dio;
  final Future<String?> Function() _getIdToken;

  @override
  Future<RevisionDocument> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final response = await _dio.post<Object?>(
      '/documents/course-pdf',
      data: FormData.fromMap({
        'subjectId': subjectId,
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: DioMediaType('application', 'pdf'),
        ),
      }),
      options: await _authorizedOptions(
        'A Firebase ID token is required to upload documents',
      ),
    );

    return _DocumentJson(response.data).toDocument();
  }

  @override
  Future<List<RevisionDocument>> listSubjectDocuments({
    required String subjectId,
  }) async {
    final response = await _dio.get<Object?>(
      '/subjects/$subjectId/documents',
      options: await _authorizedOptions(
        'A Firebase ID token is required to load documents',
      ),
    );
    final rawDocuments = response.data;

    if (rawDocuments is! List) {
      throw const FormatException('Invalid documents response');
    }

    return rawDocuments
        .map((document) => _DocumentJson(document).toDocument())
        .toList(growable: false);
  }

  @override
  Future<RevisionDocument> getDocument({required String documentId}) async {
    final response = await _dio.get<Object?>(
      '/documents/$documentId',
      options: await _authorizedOptions(
        'A Firebase ID token is required to load documents',
      ),
    );

    return _DocumentJson(response.data).toDocument();
  }

  @override
  Future<void> deleteDocument({required String documentId}) async {
    try {
      await _dio.delete<Object?>(
        '/documents/$documentId',
        options: await _authorizedOptions(
          'A Firebase ID token is required to delete documents',
        ),
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 409) {
        throw SourceLifecycleException(
          _responseMessage(error) ?? 'Cette source ne peut pas être supprimée.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<SourceLifecycleDecision> getDocumentLifecycle({
    required String documentId,
  }) async {
    final response = await _dio.get<Object?>(
      '/documents/$documentId/lifecycle',
      options: await _authorizedOptions(
        'A Firebase ID token is required to load document lifecycle',
      ),
    );

    return SourceLifecycleDecisionJson(response.data).toDecision();
  }

  @override
  Future<SourceLifecycleDecision> archiveDocument({
    required String documentId,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/documents/$documentId/archive',
        options: await _authorizedOptions(
          'A Firebase ID token is required to archive documents',
        ),
      );

      return SourceLifecycleDecisionJson(response.data).toDecision();
    } on DioException catch (error) {
      if (error.response?.statusCode == 409) {
        throw SourceLifecycleException(
          _responseMessage(error) ?? 'Cette source ne peut pas être archivée.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<DocumentKnowledgeUnitsResponse> listDocumentKnowledgeUnits({
    required String documentId,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/documents/$documentId/knowledge-units',
        options: await _authorizedOptions(
          'A Firebase ID token is required to load document knowledge units',
        ),
      );

      return _KnowledgeUnitsJson(response.data).toResponse();
    } on DioException catch (error) {
      if (error.response?.statusCode == 409) {
        throw const DocumentNotReadyException();
      }

      rethrow;
    }
  }

  @override
  Future<DocumentSummary?> getDocumentSummary({
    required String documentId,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/documents/$documentId/summary',
        options: await _authorizedOptions(
          'A Firebase ID token is required to load document summaries',
        ),
      );

      return _DocumentSummaryJson(response.data).toSummary();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      _throwArtifactRequestException(error);
    }
  }

  @override
  Future<DocumentSummary> generateDocumentSummary({
    required String documentId,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/documents/$documentId/summary',
        options: await _authorizedOptions(
          'A Firebase ID token is required to generate document summaries',
        ),
      );

      return _DocumentSummaryJson(response.data).toSummary();
    } on DioException catch (error) {
      _throwArtifactRequestException(error);
    }
  }

  @override
  Future<RevisionSheet?> getRevisionSheet({required String documentId}) async {
    try {
      final response = await _dio.get<Object?>(
        '/documents/$documentId/revision-sheet',
        options: await _authorizedOptions(
          'A Firebase ID token is required to load revision sheets',
        ),
      );

      return RevisionSheetJson(response.data).toRevisionSheet();
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      _throwArtifactRequestException(error);
    }
  }

  @override
  Future<RevisionSheet> generateRevisionSheet({
    required String documentId,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/documents/$documentId/revision-sheet',
        options: await _authorizedOptions(
          'A Firebase ID token is required to generate revision sheets',
        ),
      );

      return RevisionSheetJson(response.data).toRevisionSheet();
    } on DioException catch (error) {
      _throwArtifactRequestException(error);
    }
  }

  Future<Options> _authorizedOptions(String missingTokenMessage) async {
    final token = (await _getIdToken())?.trim();

    if (token == null || token.isEmpty) {
      throw StateError(missingTokenMessage);
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  String? _responseMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, Object?>) {
      final message = data['message'];
      if (message is String) {
        return message;
      }
    }

    return null;
  }

  Never _throwArtifactRequestException(DioException error) {
    final statusCode = error.response?.statusCode;

    if (statusCode == 409) {
      throw const DocumentNotReadyException();
    }

    if (statusCode != null) {
      throw DocumentArtifactRequestException(statusCode: statusCode);
    }

    throw error;
  }
}

class _DocumentJson {
  const _DocumentJson(this.value);

  final Object? value;

  RevisionDocument toDocument() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid document response');
    }

    final id = json['id'];
    final subjectId = json['subjectId'];
    final kind = json['kind'];
    final fileName = json['fileName'];
    final status = json['status'];
    final mimeType = json['mimeType'];
    final errorCode = json['errorCode'];

    if (id is! String ||
        subjectId is! String ||
        kind is! String ||
        fileName is! String ||
        status is! String ||
        mimeType is! String ||
        (errorCode != null && errorCode is! String)) {
      throw const FormatException('Invalid document response');
    }

    return RevisionDocument(
      id: id,
      subjectId: subjectId,
      kind: kind,
      fileName: fileName,
      status: status,
      mimeType: mimeType,
      errorCode: errorCode as String?,
    );
  }
}

class _KnowledgeUnitsJson {
  const _KnowledgeUnitsJson(this.value);

  final Object? value;

  DocumentKnowledgeUnitsResponse toResponse() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid knowledge units response');
    }

    final documentId = json['documentId'];
    final items = json['items'];

    if (documentId is! String || items is! List) {
      throw const FormatException('Invalid knowledge units response');
    }

    return DocumentKnowledgeUnitsResponse(
      documentId: documentId,
      items: items
          .map((item) => _KnowledgeUnitJson(item).toKnowledgeUnit())
          .toList(growable: false),
    );
  }
}

class _KnowledgeUnitJson {
  const _KnowledgeUnitJson(this.value);

  final Object? value;

  DocumentKnowledgeUnit toKnowledgeUnit() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid knowledge unit response');
    }

    final id = json['id'];
    final title = json['title'];
    final summary = json['summary'];
    final difficulty = json['difficulty'];
    final displayOrder = json['displayOrder'];
    final confidence = json['confidence'];
    final sources = json['sources'];

    if (id is! String ||
        title is! String ||
        summary is! String ||
        (difficulty != null && difficulty is! String) ||
        (displayOrder != null && displayOrder is! int) ||
        (confidence != null && confidence is! num) ||
        sources is! List) {
      throw const FormatException('Invalid knowledge unit response');
    }

    return DocumentKnowledgeUnit(
      id: id,
      title: title,
      summary: summary,
      difficulty: difficulty as String?,
      displayOrder: displayOrder as int?,
      confidence: (confidence as num?)?.toDouble(),
      sources: sources
          .map((source) => _KnowledgeUnitSourceJson(source).toSource())
          .toList(growable: false),
    );
  }
}

class _KnowledgeUnitSourceJson {
  const _KnowledgeUnitSourceJson(this.value);

  final Object? value;

  DocumentKnowledgeUnitSource toSource() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid knowledge unit source response');
    }

    final chunkId = json['chunkId'];
    final text = json['text'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String ||
        text is! String ||
        (pageNumber != null && pageNumber is! int) ||
        index is! int) {
      throw const FormatException('Invalid knowledge unit source response');
    }

    return DocumentKnowledgeUnitSource(
      chunkId: chunkId,
      text: text,
      pageNumber: pageNumber as int?,
      index: index,
    );
  }
}

class _DocumentSummaryJson {
  const _DocumentSummaryJson(this.value);

  final Object? value;

  DocumentSummary toSummary() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid document summary response');
    }

    final id = json['id'];
    final documentId = json['documentId'];
    final subjectId = json['subjectId'];
    final status = json['status'];
    final title = json['title'];
    final content = json['content'];
    final keyPoints = json['keyPoints'];
    final limits = json['limits'];
    final errorCode = json['errorCode'];
    final sources = json['sources'];

    if (id is! String ||
        documentId is! String ||
        subjectId is! String ||
        status is! String ||
        title is! String ||
        content is! String ||
        keyPoints is! List ||
        (limits != null && limits is! String) ||
        (errorCode != null && errorCode is! String) ||
        sources is! List) {
      throw const FormatException('Invalid document summary response');
    }

    return DocumentSummary(
      id: id,
      documentId: documentId,
      subjectId: subjectId,
      status: status,
      title: title,
      content: content,
      keyPoints: _stringList(keyPoints, 'Invalid document summary response'),
      limits: limits as String?,
      errorCode: errorCode as String?,
      sources: sources
          .map((source) => _DocumentArtifactSourceJson(source).toSource())
          .toList(growable: false),
    );
  }
}

class _DocumentArtifactSourceJson {
  const _DocumentArtifactSourceJson(this.value);

  final Object? value;

  DocumentArtifactSource toSource() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid artifact source response');
    }

    final chunkId = json['chunkId'];
    final text = json['text'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String ||
        text is! String ||
        (pageNumber != null && pageNumber is! int) ||
        index is! int) {
      throw const FormatException('Invalid artifact source response');
    }

    return DocumentArtifactSource(
      chunkId: chunkId,
      text: text,
      pageNumber: pageNumber as int?,
      index: index,
    );
  }
}

List<String> _stringList(List value, String message) {
  if (value.any((item) => item is! String)) {
    throw FormatException(message);
  }

  return value.cast<String>().toList(growable: false);
}

~~~

### `lib/features/documents/domain/source_lifecycle.dart`

~~~text
enum SourceLifecycleStatus { active, archived, unknown }

enum SourceLifecycleAction { delete, archive, block, unknown }

class SourceLifecycleDecision {
  const SourceLifecycleDecision({
    required this.documentId,
    required this.courseId,
    required this.status,
    required this.recommendedAction,
    required this.canDelete,
    required this.canArchive,
    required this.blockingReasons,
    required this.userMessage,
  });

  final String documentId;
  final String? courseId;
  final SourceLifecycleStatus status;
  final SourceLifecycleAction recommendedAction;
  final bool canDelete;
  final bool canArchive;
  final List<String> blockingReasons;
  final String userMessage;
}

class SourceLifecycleDecisionJson {
  const SourceLifecycleDecisionJson(this.value);

  final Object? value;

  SourceLifecycleDecision toDecision() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid source lifecycle response');
    }

    final documentId = json['documentId'];
    final courseId = json['courseId'];
    final status = json['status'];
    final recommendedAction = json['recommendedAction'];
    final canDelete = json['canDelete'];
    final canArchive = json['canArchive'];
    final blockingReasons = json['blockingReasons'];
    final userMessage = json['userMessage'];

    if (documentId is! String ||
        (courseId != null && courseId is! String) ||
        status is! String ||
        recommendedAction is! String ||
        canDelete is! bool ||
        canArchive is! bool ||
        blockingReasons is! List ||
        userMessage is! String) {
      throw const FormatException('Invalid source lifecycle response');
    }

    return SourceLifecycleDecision(
      documentId: documentId,
      courseId: courseId as String?,
      status: _parseStatus(status),
      recommendedAction: _parseAction(recommendedAction),
      canDelete: canDelete,
      canArchive: canArchive,
      blockingReasons: blockingReasons.whereType<String>().toList(),
      userMessage: userMessage,
    );
  }

  SourceLifecycleStatus _parseStatus(String value) {
    return switch (value) {
      'ACTIVE' => SourceLifecycleStatus.active,
      'ARCHIVED' => SourceLifecycleStatus.archived,
      _ => SourceLifecycleStatus.unknown,
    };
  }

  SourceLifecycleAction _parseAction(String value) {
    return switch (value) {
      'DELETE' => SourceLifecycleAction.delete,
      'ARCHIVE' => SourceLifecycleAction.archive,
      'BLOCK' => SourceLifecycleAction.block,
      _ => SourceLifecycleAction.unknown,
    };
  }
}

class SourceLifecycleException implements Exception {
  const SourceLifecycleException(this.message);

  final String message;

  @override
  String toString() => message;
}

~~~

### `lib/presentation/pages/subjects/subject_detail_page.dart`

~~~text
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/app/router/app_routes.dart';
import 'package:Neralune/features/courses/application/active_subject_provider.dart';
import 'package:Neralune/features/documents/application/documents_controller.dart';
import 'package:Neralune/features/documents/application/subject_documents_notifier.dart';
import 'package:Neralune/features/documents/domain/revision_document.dart';
import 'package:Neralune/features/documents/domain/source_lifecycle.dart';
import 'package:Neralune/features/subjects/application/subjects_controller.dart';
import 'package:Neralune/features/subjects/domain/subject.dart';
import 'package:Neralune/presentation/design_system/components/revision_mvp_components.dart';
import 'package:Neralune/presentation/design_system/components/revision_states.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_colors.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_spacing.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_subject_visuals.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_typography.dart';
import 'package:Neralune/presentation/pages/subjects/widgets/subject_document_list_item.dart';
import 'package:Neralune/presentation/widgets/documents/document_import_button.dart';

class SubjectDetailPage extends ConsumerStatefulWidget {
  const SubjectDetailPage({
    required this.subjectId,
    required this.controller,
    required this.documentsController,
    super.key,
  });

  final String subjectId;
  final SubjectsController controller;
  final DocumentsController documentsController;

  @override
  ConsumerState<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends ConsumerState<SubjectDetailPage> {
  late Future<Subject> _subject;

  @override
  void initState() {
    super.initState();
    _subject = widget.controller.getSubject(widget.subjectId);
  }

  void _reloadSubject() {
    setState(() {
      _subject = widget.controller.getSubject(widget.subjectId);
    });
    _reloadDocuments();
  }

  void _reloadDocuments() {
    ref
        .read(subjectDocumentsNotifierProvider(widget.subjectId).notifier)
        .reload();
  }

  Future<void> _deleteDocument(RevisionDocument document) async {
    SourceLifecycleDecision decision;
    try {
      decision = await widget.documentsController.getDocumentLifecycle(
        document.id,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de vérifier cette source.')),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    if (decision.recommendedAction == SourceLifecycleAction.archive) {
      await _archiveDocument(document);
      return;
    }

    if (decision.recommendedAction != SourceLifecycleAction.delete) {
      await _showDocumentLifecycleBlockedDialog(decision);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la source ?'),
        content: Text(
          'Le PDF "${document.fileName}" sera retiré de cette matière. Tu pourras le rajouter plus tard si besoin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await ref
          .read(subjectDocumentsNotifierProvider(widget.subjectId).notifier)
          .deleteDocument(document.id);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de supprimer la source')),
      );
    }
  }

  Future<void> _archiveDocument(RevisionDocument document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archiver la source ?'),
        content: Text(
          'Le PDF "${document.fileName}" ne sera plus utilisé pour préparer de nouvelles révisions, mais l’historique déjà créé sera conservé.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Archiver'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await ref
          .read(subjectDocumentsNotifierProvider(widget.subjectId).notifier)
          .archiveDocument(document.id);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’archiver la source')),
      );
    }
  }

  Future<void> _showDocumentLifecycleBlockedDialog(
    SourceLifecycleDecision decision,
  ) {
    final message = decision.blockingReasons.contains('SOURCE_PROCESSING')
        ? 'Cette source est encore en cours d’analyse. Réessaie quand elle sera prête.'
        : 'Cette source ne peut pas être modifiée pour le moment.';

    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Action indisponible'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Subject>(
      future: _subject,
      builder: (context, snapshot) {
        final subject = snapshot.data;

        if (snapshot.connectionState != ConnectionState.done) {
          return const RevisionPageScaffold(
            children: [RevisionLoadingState(label: 'Chargement de la matière')],
          );
        }

        if (snapshot.hasError || subject == null) {
          return RevisionPageScaffold(
            children: [
              RevisionErrorState(
                title: 'Matière indisponible',
                message: 'Impossible de charger cette matière pour le moment.',
                actionLabel: 'Réessayer',
                onAction: _reloadSubject,
              ),
            ],
          );
        }

        final visualTheme = revisionSubjectVisualThemeFor(subject.name);
        final documents = ref.watch(
          subjectDocumentsNotifierProvider(widget.subjectId),
        );

        return RevisionPageScaffold(
          headerChildren: [
            RevisionGlassCard(
              gradient: visualTheme.gradient,
              borderColor: visualTheme.accent.withValues(alpha: 0.40),
              child: Row(
                children: [
                  RevisionIconTile(
                    icon: visualTheme.icon,
                    accent: visualTheme.accent,
                    size: 58,
                  ),
                  const SizedBox(width: RevisionSpacing.l),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: RevisionTypography.pageTitle,
                        ),
                        const SizedBox(height: RevisionSpacing.xs),
                        Text(
                          'Priorité ${subject.priority} · ${_subjectRhythmLabel(subject)}',
                          style: RevisionTypography.body.copyWith(
                            color: RevisionColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: RevisionSpacing.s,
              runSpacing: RevisionSpacing.s,
              children: [
                RevisionHeaderActionPill(
                  label: 'Réviser',
                  icon: Icons.play_arrow_rounded,
                  accent: visualTheme.accent,
                  onTap: () {
                    ref
                        .read(activeSubjectIdProvider.notifier)
                        .select(widget.subjectId);
                    context.go(AppRoutes.revisions);
                  },
                ),
                RevisionHeaderActionPill(
                  label: 'Rafraîchir',
                  icon: Icons.refresh_rounded,
                  accent: RevisionColors.cyan,
                  onTap: _reloadSubject,
                ),
              ],
            ),
          ],
          children: [
            RevisionSectionHeader(
              title: 'Sources importées',
              subtitle:
                  'Ajoute des PDF pour préparer les notions et les fiches.',
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: DocumentImportButton(
                subjectId: widget.subjectId,
                controller: widget.documentsController,
                onImported: _reloadDocuments,
              ),
            ),
            documents.when(
              loading: () =>
                  const RevisionLoadingState(label: 'Chargement des sources'),
              error: (error, stackTrace) => RevisionErrorState(
                title: 'Sources indisponibles',
                message: 'Impossible de charger les sources de cette matière.',
                actionLabel: 'Réessayer',
                onAction: _reloadDocuments,
              ),
              data: (documents) {
                if (documents.isEmpty) {
                  return RevisionEmptyState(
                    icon: Icons.upload_file_rounded,
                    title: 'Aucune source importée',
                    message:
                        'Importe un PDF de cours pour commencer à structurer cette matière.',
                    actionLabel: 'Réessayer',
                    onAction: _reloadDocuments,
                  );
                }

                return Column(
                  children: [
                    for (final (index, document) in documents.indexed) ...[
                      if (index > 0) const SizedBox(height: RevisionSpacing.m),
                      SubjectDocumentListItem(
                        document: document,
                        onTap: () => context.go(
                          '/subjects/${widget.subjectId}/documents/${document.id}',
                        ),
                        onDelete: () => _deleteDocument(document),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

String _subjectRhythmLabel(Subject subject) {
  if (subject.weeklyMinutes <= 0) {
    return 'rythme à préciser';
  }

  final hours = subject.weeklyMinutes ~/ 60;
  final minutes = subject.weeklyMinutes % 60;

  if (minutes == 0) {
    return '$hours h par semaine';
  }

  if (hours == 0) {
    return '$minutes min par semaine';
  }

  return '$hours h $minutes min par semaine';
}

~~~

### `test/fakes/in_memory_courses_repository.dart`

~~~text
import 'dart:typed_data';

import 'package:Neralune/features/courses/domain/course_models.dart';
import 'package:Neralune/features/courses/domain/courses_repository.dart';
import 'package:Neralune/features/documents/domain/revision_document.dart';
import 'package:Neralune/features/documents/domain/source_lifecycle.dart';
import 'package:Neralune/features/revision_sessions/domain/revision_session.dart';

class InMemoryCoursesRepository implements CoursesRepository {
  final Map<String, List<CourseListItem>> coursesBySubject = {};
  final Map<String, CourseDetail> detailsByCourse = {};
  final Map<String, CourseProgress> progressByCourse = {};
  final Map<String, SubjectProgress> progressBySubject = {};
  final Map<String, RevisionSheet?> revisionSheetsByCourse = {};
  final Map<String, RevisionSheet> generatedRevisionSheetsByCourse = {};
  final Map<String, Object> revisionSheetErrorsByCourse = {};
  final Map<String, SourceLifecycleDecision> lifecycleByDocumentId = {};
  int createCount = 0;
  int listCoursesCount = 0;
  int getCourseCount = 0;
  int getCourseProgressCount = 0;
  int getSubjectProgressCount = 0;
  int getRevisionSheetCount = 0;
  int generateRevisionSheetCount = 0;
  int uploadCount = 0;
  int deleteDocumentCount = 0;
  int archiveDocumentCount = 0;
  int getLifecycleCount = 0;
  int startQuickRevisionCount = 0;
  String? lastUploadedCourseId;
  String? lastUploadedFileName;
  Uint8List? lastUploadedBytes;
  String? lastDeletedCourseId;
  String? lastDeletedDocumentId;
  String? lastArchivedCourseId;
  String? lastArchivedDocumentId;
  String? lastQuickRevisionCourseId;
  int? lastQuickRevisionQuestionCount;
  Object? uploadError;
  Object? deleteDocumentError;
  Object? archiveDocumentError;
  Object? quickRevisionError;
  RevisionSessionResponse? quickRevisionResponse;
  Duration uploadDelay = Duration.zero;
  Duration quickRevisionDelay = Duration.zero;

  @override
  Future<List<CourseListItem>> listCourses({required String subjectId}) async {
    listCoursesCount += 1;
    return List.unmodifiable(coursesBySubject[subjectId] ?? const []);
  }

  @override
  Future<CourseDetail> getCourse({required String courseId}) async {
    getCourseCount += 1;
    final detail = detailsByCourse[courseId];

    if (detail == null) {
      throw const CourseNotFoundException('Course not found');
    }

    return detail;
  }

  @override
  Future<CourseListItem> createCourse({
    required String subjectId,
    required CreateCourseInput input,
  }) async {
    createCount += 1;
    final course = CourseListItem(
      id: 'course-$createCount',
      subjectId: subjectId,
      title: input.title,
      description: input.description,
      chapterLabel: input.chapterLabel,
      estimatedMinutes: input.estimatedMinutes,
      sourceCount: 0,
      readySourceCount: 0,
      processingSourceCount: 0,
      failedSourceCount: 0,
    );
    coursesBySubject.putIfAbsent(subjectId, () => []).add(course);
    detailsByCourse[course.id] = CourseDetail(
      course: course,
      subject: CourseSubjectSummary(id: subjectId, name: 'Matière réelle'),
      sources: const [],
    );

    return course;
  }

  @override
  Future<CourseDocument> uploadCoursePdf({
    required String courseId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    if (uploadDelay > Duration.zero) {
      await Future<void>.delayed(uploadDelay);
    }

    final error = uploadError;
    if (error != null) {
      throw error;
    }

    final detail = detailsByCourse[courseId];
    if (detail == null) {
      throw const CourseNotFoundException('Course not found');
    }

    uploadCount += 1;
    lastUploadedCourseId = courseId;
    lastUploadedFileName = fileName;
    lastUploadedBytes = bytes;

    final document = CourseDocument(
      id: 'document-$uploadCount',
      courseId: courseId,
      documentId: 'document-$uploadCount',
      fileName: fileName,
      status: CourseDocumentStatus.uploaded,
      createdAt: DateTime.utc(2026, 6, 18, 12),
      updatedAt: DateTime.utc(2026, 6, 18, 12),
    );
    detailsByCourse[courseId] = CourseDetail(
      course: detail.course,
      subject: detail.subject,
      sources: [...detail.sources, document],
      progress: detail.progress,
    );

    return document;
  }

  @override
  Future<void> deleteCourseDocument({
    required String courseId,
    required String documentId,
  }) async {
    final error = deleteDocumentError;
    if (error != null) {
      throw error;
    }

    final detail = detailsByCourse[courseId];
    if (detail == null) {
      throw const CourseNotFoundException('Course not found');
    }

    final remainingSources = detail.sources
        .where((source) => source.documentId != documentId)
        .toList(growable: false);
    if (remainingSources.length == detail.sources.length) {
      throw const CourseNotFoundException('Course source not found');
    }

    deleteDocumentCount += 1;
    lastDeletedCourseId = courseId;
    lastDeletedDocumentId = documentId;
    detailsByCourse[courseId] = CourseDetail(
      course: detail.course,
      subject: detail.subject,
      sources: remainingSources,
      progress: detail.progress,
    );
  }

  @override
  Future<SourceLifecycleDecision> getCourseDocumentLifecycle({
    required String courseId,
    required String documentId,
  }) async {
    getLifecycleCount += 1;
    final detail = detailsByCourse[courseId];
    if (detail == null ||
        !detail.sources.any((source) => source.documentId == documentId)) {
      throw const CourseNotFoundException('Course source not found');
    }

    return lifecycleByDocumentId[documentId] ??
        SourceLifecycleDecision(
          documentId: documentId,
          courseId: courseId,
          status: SourceLifecycleStatus.active,
          recommendedAction: SourceLifecycleAction.delete,
          canDelete: true,
          canArchive: true,
          blockingReasons: const [],
          userMessage: 'Cette source peut être supprimée.',
        );
  }

  @override
  Future<SourceLifecycleDecision> archiveCourseDocument({
    required String courseId,
    required String documentId,
  }) async {
    final error = archiveDocumentError;
    if (error != null) {
      throw error;
    }

    final detail = detailsByCourse[courseId];
    if (detail == null) {
      throw const CourseNotFoundException('Course not found');
    }

    final remainingSources = detail.sources
        .where((source) => source.documentId != documentId)
        .toList(growable: false);
    if (remainingSources.length == detail.sources.length) {
      throw const CourseNotFoundException('Course source not found');
    }

    archiveDocumentCount += 1;
    lastArchivedCourseId = courseId;
    lastArchivedDocumentId = documentId;
    detailsByCourse[courseId] = CourseDetail(
      course: detail.course,
      subject: detail.subject,
      sources: remainingSources,
      progress: detail.progress,
    );

    return SourceLifecycleDecision(
      documentId: documentId,
      courseId: courseId,
      status: SourceLifecycleStatus.archived,
      recommendedAction: SourceLifecycleAction.block,
      canDelete: false,
      canArchive: false,
      blockingReasons: const ['ALREADY_ARCHIVED'],
      userMessage: 'Cette source est archivée.',
    );
  }

  @override
  Future<RevisionSheet?> getCourseRevisionSheet({
    required String courseId,
  }) async {
    getRevisionSheetCount += 1;
    final error = revisionSheetErrorsByCourse[courseId];
    if (error != null) {
      throw error;
    }

    return revisionSheetsByCourse[courseId];
  }

  @override
  Future<RevisionSheet> generateCourseRevisionSheet({
    required String courseId,
  }) async {
    generateRevisionSheetCount += 1;
    final error = revisionSheetErrorsByCourse[courseId];
    if (error != null) {
      throw error;
    }

    final existing = revisionSheetsByCourse[courseId];
    if (existing != null) {
      return existing;
    }

    final generated = generatedRevisionSheetsByCourse[courseId];
    if (generated != null) {
      revisionSheetsByCourse[courseId] = generated;
      return generated;
    }

    throw const CourseRevisionSheetNotReadyException(
      'Course has no ready source',
    );
  }

  @override
  Future<RevisionSessionResponse> startCourseQuickRevision({
    required String courseId,
    int questionCount = 10,
  }) async {
    if (quickRevisionDelay > Duration.zero) {
      await Future<void>.delayed(quickRevisionDelay);
    }

    final error = quickRevisionError;
    if (error != null) {
      throw error;
    }

    if (!detailsByCourse.containsKey(courseId)) {
      throw const CourseNotFoundException('Course not found');
    }

    startQuickRevisionCount += 1;
    lastQuickRevisionCourseId = courseId;
    lastQuickRevisionQuestionCount = questionCount;

    return quickRevisionResponse ?? quickRevisionSessionResponse(courseId);
  }

  @override
  Future<CourseProgress> getCourseProgress({required String courseId}) {
    getCourseProgressCount += 1;
    final progress = progressByCourse[courseId];

    if (progress == null) {
      throw const CourseNotFoundException('Course not found');
    }

    return Future.value(progress);
  }

  @override
  Future<SubjectProgress> getSubjectProgress({required String subjectId}) {
    getSubjectProgressCount += 1;
    final progress = progressBySubject[subjectId];

    if (progress == null) {
      throw const CourseNotFoundException('Course subject not found');
    }

    return Future.value(progress);
  }
}

RevisionSessionResponse quickRevisionSessionResponse(String courseId) {
  return RevisionSessionResponse(
    session: RevisionSession(
      id: 'revision-session-1',
      status: RevisionSessionStatus.started,
      mode: RevisionSessionMode.quick,
      subjectId: 'subject-1',
      courseId: courseId,
      documentId: 'document-1',
      knowledgeUnitId: 'knowledge-unit-1',
      createdAt: DateTime.utc(2026, 6, 18, 12),
      completedAt: null,
    ),
    currentAction: const RevisionSessionAction(
      id: 'action-1',
      kind: RevisionSessionActionKind.diagnosticQuiz,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: 'activity-session-1',
      documentId: 'document-1',
      knowledgeUnitId: 'knowledge-unit-1',
      payload: null,
    ),
    history: const [],
  );
}

~~~

### `test/fakes/in_memory_documents_api.dart`

~~~text
import 'dart:typed_data';

import 'package:Neralune/features/documents/application/documents_controller.dart';
import 'package:Neralune/features/documents/domain/revision_document.dart';
import 'package:Neralune/features/documents/domain/source_lifecycle.dart';

class InMemoryDocumentsApi implements DocumentsApi {
  final List<RevisionDocument> documents = [];
  final Map<String, DocumentSummary> summariesByDocumentId = {};
  final Map<String, RevisionSheet> revisionSheetsByDocumentId = {};
  final Map<String, SourceLifecycleDecision> lifecycleByDocumentId = {};

  @override
  Future<RevisionDocument> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final document = RevisionDocument(
      id: 'document-${documents.length + 1}',
      subjectId: subjectId,
      kind: 'COURSE_PDF',
      fileName: fileName,
      status: 'UPLOADED',
      mimeType: 'application/pdf',
    );
    documents.add(document);

    return document;
  }

  @override
  Future<List<RevisionDocument>> listSubjectDocuments({
    required String subjectId,
  }) async {
    return documents
        .where((document) => document.subjectId == subjectId)
        .toList(growable: false);
  }

  @override
  Future<void> deleteDocument({required String documentId}) async {
    documents.removeWhere((document) => document.id == documentId);
  }

  @override
  Future<SourceLifecycleDecision> getDocumentLifecycle({
    required String documentId,
  }) async {
    final document = documents.singleWhere(
      (document) => document.id == documentId,
    );
    return lifecycleByDocumentId[documentId] ??
        SourceLifecycleDecision(
          documentId: document.id,
          courseId: null,
          status: SourceLifecycleStatus.active,
          recommendedAction: SourceLifecycleAction.delete,
          canDelete: true,
          canArchive: true,
          blockingReasons: const [],
          userMessage: 'Cette source peut être supprimée.',
        );
  }

  @override
  Future<SourceLifecycleDecision> archiveDocument({
    required String documentId,
  }) async {
    documents.removeWhere((document) => document.id == documentId);
    return SourceLifecycleDecision(
      documentId: documentId,
      courseId: null,
      status: SourceLifecycleStatus.archived,
      recommendedAction: SourceLifecycleAction.block,
      canDelete: false,
      canArchive: false,
      blockingReasons: const ['ALREADY_ARCHIVED'],
      userMessage: 'Cette source est archivée.',
    );
  }

  @override
  Future<RevisionDocument> getDocument({required String documentId}) async {
    return documents.singleWhere((document) => document.id == documentId);
  }

  @override
  Future<DocumentKnowledgeUnitsResponse> listDocumentKnowledgeUnits({
    required String documentId,
  }) async {
    return DocumentKnowledgeUnitsResponse(
      documentId: documentId,
      items: const [],
    );
  }

  @override
  Future<DocumentSummary?> getDocumentSummary({
    required String documentId,
  }) async {
    return summariesByDocumentId[documentId];
  }

  @override
  Future<DocumentSummary> generateDocumentSummary({
    required String documentId,
  }) async {
    return summariesByDocumentId[documentId]!;
  }

  @override
  Future<RevisionSheet?> getRevisionSheet({required String documentId}) async {
    return revisionSheetsByDocumentId[documentId];
  }

  @override
  Future<RevisionSheet> generateRevisionSheet({
    required String documentId,
  }) async {
    return revisionSheetsByDocumentId[documentId]!;
  }
}

~~~

### `test/features/courses/course_detail_page_test.dart`

~~~text
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/app/router/app_routes.dart';
import 'package:Neralune/features/courses/application/course_pdf_picker.dart';
import 'package:Neralune/features/courses/application/courses_providers.dart';
import 'package:Neralune/features/courses/domain/course_models.dart';
import 'package:Neralune/features/courses/domain/courses_repository.dart';
import 'package:Neralune/features/courses/presentation/course_detail_page.dart';
import 'package:Neralune/features/documents/domain/source_lifecycle.dart';
import 'package:Neralune/presentation/design_system/components/revision_mvp_components.dart';

import '../../fakes/in_memory_courses_repository.dart';

void main() {
  testWidgets('course detail uploads a PDF source without fixture content', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..uploadDelay = const Duration(milliseconds: 50);
    final picker = FakeCoursePdfPicker(
      PickedCoursePdf(
        fileName: 'cours.pdf',
        bytes: Uint8List.fromList('%PDF-1.7'.codeUnits),
      ),
    );

    await tester.pumpWidget(testApp(repository: repository, picker: picker));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text('Droit constitutionnel'), findsOneWidget);
    expect(find.text('Sources'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.text('870'), findsNothing);
    expect(find.text('7 jours'), findsNothing);

    await openSourcesSheet(tester);
    await tester.tap(find.bySemanticsLabel('Ajouter une source'));
    await tester.pump();

    expect(find.text('Upload en cours...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump();

    expect(repository.uploadCount, 1);
    expect(repository.lastUploadedCourseId, 'course-1');
    expect(repository.lastUploadedFileName, 'cours.pdf');
    expect(find.text('Source ajoutée'), findsOneWidget);
  });

  testWidgets('course detail displays failed source errors', (tester) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'broken.pdf',
            status: CourseDocumentStatus.failed,
            errorCode: 'KNOWLEDGE_EXTRACTION_FAILED',
          ),
        ],
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await openSourcesSheet(tester);
    expect(find.text('broken.pdf'), findsOneWidget);
    expect(find.textContaining('Analyse du PDF impossible'), findsOneWidget);
    expect(find.textContaining('KNOWLEDGE_EXTRACTION_FAILED'), findsNothing);
    expect(find.textContaining('Code erreur'), findsNothing);
  });

  testWidgets('source upload button is disabled while upload is in progress', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..uploadDelay = const Duration(milliseconds: 80);
    final picker = FakeCoursePdfPicker(
      PickedCoursePdf(
        fileName: 'cours.pdf',
        bytes: Uint8List.fromList('%PDF-1.7'.codeUnits),
      ),
    );

    await tester.pumpWidget(testApp(repository: repository, picker: picker));
    await tester.pumpAndSettle();

    await openSourcesSheet(tester);
    await tester.tap(find.bySemanticsLabel('Ajouter une source'));
    await tester.pump();

    final addButton = tester.widget<RevisionFloatingAddButton>(
      find.byType(RevisionFloatingAddButton),
    );
    expect(addButton.onTap, isNull);

    await tester.tap(find.bySemanticsLabel('Ajouter une source'));
    await tester.pump(const Duration(milliseconds: 90));
    await tester.pump();

    expect(repository.uploadCount, 1);
  });

  testWidgets('course detail deletes a source after confirmation', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'cours.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await openSourcesSheet(tester);
    expect(find.text('cours.pdf'), findsOneWidget);

    await tester.tap(find.byTooltip('Gérer la source cours.pdf'));
    await tester.pumpAndSettle();

    expect(find.text('Supprimer cette source ?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Supprimer'));
    await tester.pumpAndSettle();

    expect(repository.deleteDocumentCount, 1);
    expect(repository.lastDeletedDocumentId, 'document-1');
    expect(find.text('Source supprimée'), findsOneWidget);
  });

  testWidgets('course detail archives a used source after confirmation', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'cours.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      )
      ..lifecycleByDocumentId['document-1'] = const SourceLifecycleDecision(
        documentId: 'document-1',
        courseId: 'course-1',
        status: SourceLifecycleStatus.active,
        recommendedAction: SourceLifecycleAction.archive,
        canDelete: false,
        canArchive: true,
        blockingReasons: ['HAS_KNOWLEDGE_UNITS'],
        userMessage: 'Cette source peut être archivée.',
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await openSourcesSheet(tester);
    await tester.tap(find.byTooltip('Gérer la source cours.pdf'));
    await tester.pumpAndSettle();

    expect(find.text('Archiver cette source ?'), findsOneWidget);
    expect(find.textContaining('historique déjà créé'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Archiver'));
    await tester.pumpAndSettle();

    expect(repository.archiveDocumentCount, 1);
    expect(repository.lastArchivedDocumentId, 'document-1');
    expect(find.text('Source archivée'), findsOneWidget);
  });

  testWidgets('course detail shows an error when source deletion fails', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'cours.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      )
      ..deleteDocumentError = const CourseNotFoundException(
        'Course source not found',
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    await openSourcesSheet(tester);
    await tester.tap(find.byTooltip('Gérer la source cours.pdf'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Supprimer'));
    await tester.pumpAndSettle();

    expect(repository.deleteDocumentCount, 0);
    expect(find.text('Impossible de supprimer cette source.'), findsWidgets);
    expect(find.text('cours.pdf'), findsOneWidget);
  });

  testWidgets('course detail displays no-source progress state', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..progressByCourse['course-1'] = courseProgress(
        state: CourseProgressState.noSource,
        knowledgeUnitCount: 0,
        practicedKnowledgeUnitCount: 0,
        coverage: 0,
        mastery: null,
        estimatedGlobalMastery: 0,
        readySourceCount: 0,
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Progression'), findsWidgets);
    expect(find.text('0/0 notions travaillées'), findsOneWidget);
    expect(find.text('Ajoute une source pour commencer.'), findsOneWidget);
    expect(find.text('78%'), findsNothing);
  });

  testWidgets('course detail displays practiced real progress', (tester) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'ready.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      )
      ..progressByCourse['course-1'] = courseProgress();

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('3/12 notions travaillées'), findsOneWidget);
    expect(find.text('Maîtrise sur notions travaillées : 72%'), findsOneWidget);
    expect(find.text('Estimation globale : 18%'), findsOneWidget);
    expect(find.text('Progression basée sur tes réponses.'), findsOneWidget);
  });

  testWidgets('processing sources trigger bounded detail refresh polling', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'processing.pdf',
            status: CourseDocumentStatus.processing,
          ),
        ],
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pump();
    await tester.pump();

    expect(repository.getCourseCount, 1);
    expect(repository.getCourseProgressCount, 1);
    await openSourcesSheet(tester);
    expect(find.text('Traitement en cours'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(repository.getCourseCount, greaterThanOrEqualTo(2));
    expect(repository.getCourseProgressCount, greaterThanOrEqualTo(2));
  });

  testWidgets('ready failed and empty sources do not trigger polling', (
    tester,
  ) async {
    for (final sources in [
      const <CourseDocument>[],
      const [
        CourseDocument(
          id: 'document-ready',
          courseId: 'course-1',
          documentId: 'document-ready',
          fileName: 'ready.pdf',
          status: CourseDocumentStatus.ready,
        ),
      ],
      const [
        CourseDocument(
          id: 'document-failed',
          courseId: 'course-1',
          documentId: 'document-failed',
          fileName: 'failed.pdf',
          status: CourseDocumentStatus.failed,
          errorCode: 'KNOWLEDGE_EXTRACTION_FAILED',
        ),
      ],
    ]) {
      final repository = InMemoryCoursesRepository()
        ..detailsByCourse['course-1'] = courseDetail(sources: sources);

      await tester.pumpWidget(
        testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
      );
      await tester.pump();
      await tester.pump();

      final detailReads = repository.getCourseCount;
      final progressReads = repository.getCourseProgressCount;

      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(repository.getCourseCount, detailReads);
      expect(repository.getCourseProgressCount, progressReads);
    }
  });

  testWidgets('course sheet CTA asks for a source when none exists', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail();

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Action recommandée'), findsOneWidget);
    expect(find.text('Ajouter une source'), findsWidgets);
    expect(find.textContaining('MVP+'), findsNothing);
    expect(find.textContaining('backend'), findsNothing);

    final emptySheetPill = tester.widget<RevisionHeaderActionPill>(
      find.widgetWithText(RevisionHeaderActionPill, 'Fiche'),
    );
    expect(emptySheetPill.onTap, isNull);

    await scrollToQuickRevision(tester);
    final emptyQuickCard = tester.widget<RevisionModeCard>(
      find.widgetWithText(RevisionModeCard, 'Révision rapide'),
    );
    expect(emptyQuickCard.enabled, isFalse);
    expect(find.text('Ajoute une source pour réviser'), findsOneWidget);
  });

  testWidgets('course sheet CTA waits while a source is processing', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'processing.pdf',
            status: CourseDocumentStatus.processing,
          ),
        ],
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Action recommandée'), findsOneWidget);
    expect(find.text('Voir les sources'), findsWidgets);
    expect(find.text('Source en analyse'), findsOneWidget);

    final processingSheetPill = tester.widget<RevisionHeaderActionPill>(
      find.widgetWithText(RevisionHeaderActionPill, 'Fiche'),
    );
    expect(processingSheetPill.onTap, isNull);

    await scrollToQuickRevision(tester);
    final processingQuickCard = tester.widget<RevisionModeCard>(
      find.widgetWithText(RevisionModeCard, 'Révision rapide'),
    );
    expect(processingQuickCard.enabled, isFalse);
    expect(find.text('Révision disponible après traitement'), findsOneWidget);
  });

  testWidgets('course sheet CTA is enabled when a READY source exists', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'ready.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      );

    await tester.pumpWidget(
      testApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Action recommandée'), findsOneWidget);
    expect(find.text('Commencer une session rapide'), findsOneWidget);

    final sheetPill = tester.widget<RevisionHeaderActionPill>(
      find.widgetWithText(RevisionHeaderActionPill, 'Fiche'),
    );
    expect(sheetPill.onTap, isNotNull);

    await scrollToQuickRevision(tester);
    final quickCard = tester.widget<RevisionModeCard>(
      find.widgetWithText(RevisionModeCard, 'Révision rapide'),
    );
    expect(quickCard.enabled, isTrue);
  });

  testWidgets('ready quick revision starts the real revision session route', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail(
        sources: const [
          CourseDocument(
            id: 'document-1',
            courseId: 'course-1',
            documentId: 'document-1',
            fileName: 'ready.pdf',
            status: CourseDocumentStatus.ready,
          ),
        ],
      )
      ..quickRevisionDelay = const Duration(milliseconds: 50);

    await tester.pumpWidget(
      routerTestApp(repository: repository, picker: FakeCoursePdfPicker(null)),
    );
    await tester.pumpAndSettle();
    await scrollToQuickRevision(tester);

    final quickButton = find.widgetWithText(
      RevisionModeCard,
      'Révision rapide',
    );
    await tester.tap(quickButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Choisis le nombre de questions pour cette session.'),
      findsOneWidget,
    );
    await tester.tap(find.text('20 questions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Démarrer'));
    await tester.pump();

    expect(find.text('Préparation des questions'), findsOneWidget);
    expect(
      find.text('20 questions sont chargées depuis la banque du cours.'),
      findsOneWidget,
    );
    expect(find.text('Démarrage...'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(repository.startQuickRevisionCount, 1);
    expect(repository.lastQuickRevisionCourseId, 'course-1');
    expect(repository.lastQuickRevisionQuestionCount, 20);
    expect(find.text('Session réelle'), findsOneWidget);
  });
}

Future<void> openSourcesSheet(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(RevisionHeaderActionPill, 'Sources'));
  await tester.pumpAndSettle();
}

Future<void> scrollToQuickRevision(WidgetTester tester) async {
  await tester.scrollUntilVisible(find.text('Révision rapide'), 400);
  await tester.pumpAndSettle();
}

Widget testApp({
  required InMemoryCoursesRepository repository,
  required CoursePdfPicker picker,
}) {
  _ensureDefaultProgress(repository);

  return ProviderScope(
    overrides: [
      coursesRepositoryProvider.overrideWithValue(repository),
      coursePdfPickerProvider.overrideWithValue(picker),
    ],
    child: const MaterialApp(
      home: Scaffold(body: CourseDetailPage(courseId: 'course-1')),
    ),
  );
}

Widget routerTestApp({
  required InMemoryCoursesRepository repository,
  required CoursePdfPicker picker,
}) {
  _ensureDefaultProgress(repository);

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const Scaffold(body: CourseDetailPage(courseId: 'course-1')),
      ),
      GoRoute(
        path: AppRoutes.revisionSessionV2Path,
        builder: (context, state) => Scaffold(
          body: Text(
            state.pathParameters['sessionId'] == 'revision-session-1'
                ? 'Session réelle'
                : 'Session inconnue',
          ),
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      coursesRepositoryProvider.overrideWithValue(repository),
      coursePdfPickerProvider.overrideWithValue(picker),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void _ensureDefaultProgress(InMemoryCoursesRepository repository) {
  repository.progressByCourse.putIfAbsent(
    'course-1',
    () => courseProgress(
      state: CourseProgressState.noSource,
      knowledgeUnitCount: 0,
      practicedKnowledgeUnitCount: 0,
      coverage: 0,
      mastery: null,
      estimatedGlobalMastery: 0,
      readySourceCount: 0,
    ),
  );
}

CourseDetail courseDetail({List<CourseDocument> sources = const []}) {
  const course = CourseListItem(
    id: 'course-1',
    subjectId: 'subject-1',
    title: 'Droit constitutionnel',
    sourceCount: 0,
    readySourceCount: 0,
    processingSourceCount: 0,
    failedSourceCount: 0,
  );
  return CourseDetail(
    course: course,
    subject: const CourseSubjectSummary(id: 'subject-1', name: 'Droit'),
    sources: sources,
  );
}

CourseProgress courseProgress({
  CourseProgressState state = CourseProgressState.practiced,
  int knowledgeUnitCount = 12,
  int practicedKnowledgeUnitCount = 3,
  double coverage = 0.25,
  double? mastery = 0.72,
  double estimatedGlobalMastery = 0.18,
  int readySourceCount = 1,
}) {
  return CourseProgress(
    courseId: 'course-1',
    subjectId: 'subject-1',
    knowledgeUnitCount: knowledgeUnitCount,
    practicedKnowledgeUnitCount: practicedKnowledgeUnitCount,
    coverage: coverage,
    mastery: mastery,
    estimatedGlobalMastery: estimatedGlobalMastery,
    readySourceCount: readySourceCount,
    processingSourceCount: 0,
    failedSourceCount: 0,
    lastPracticedAt: DateTime.utc(2026, 6, 18, 12),
    state: state,
  );
}

class FakeCoursePdfPicker implements CoursePdfPicker {
  FakeCoursePdfPicker(this.result);

  final PickedCoursePdf? result;

  @override
  Future<PickedCoursePdf?> pickPdf() async => result;
}

~~~

### `test/features/courses/courses_providers_test.dart`

~~~text
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/courses/application/course_pdf_picker.dart';
import 'package:Neralune/features/courses/application/courses_providers.dart';
import 'package:Neralune/features/courses/domain/course_models.dart';
import 'package:Neralune/features/courses/domain/courses_repository.dart';
import 'package:Neralune/features/documents/domain/revision_document.dart';
import 'package:Neralune/features/documents/domain/source_lifecycle.dart';

import '../../fakes/in_memory_courses_repository.dart';

void main() {
  test('coursesProvider loads real courses for a subject', () async {
    final repository = InMemoryCoursesRepository()
      ..coursesBySubject['subject-1'] = const [
        CourseListItem(
          id: 'course-1',
          subjectId: 'subject-1',
          title: 'Droit constitutionnel',
          sourceCount: 0,
          readySourceCount: 0,
          processingSourceCount: 0,
          failedSourceCount: 0,
        ),
      ];
    final container = ProviderContainer(
      overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final courses = await container.read(coursesProvider('subject-1').future);

    expect(courses.single.title, 'Droit constitutionnel');
  });

  test('createCourseController invalidates the subject course list', () async {
    final repository = InMemoryCoursesRepository();
    final container = ProviderContainer(
      overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    expect(await container.read(coursesProvider('subject-1').future), isEmpty);

    final created = await container
        .read(createCourseControllerProvider.notifier)
        .create(
          subjectId: 'subject-1',
          input: const CreateCourseInput(title: 'Droit constitutionnel'),
        );

    expect(created.title, 'Droit constitutionnel');
    expect(
      await container.read(coursesProvider('subject-1').future),
      hasLength(1),
    );
  });

  test('course detail repository exposes typed not-found errors', () async {
    final repository = InMemoryCoursesRepository();

    await expectLater(
      repository.getCourse(courseId: 'unknown'),
      throwsA(isA<CourseNotFoundException>()),
    );
  });

  test(
    'uploadCourseDocumentController does nothing when picking is cancelled',
    () async {
      final repository = InMemoryCoursesRepository()
        ..progressByCourse['course-1'] = courseProgress()
        ..progressBySubject['subject-1'] = subjectProgress();
      final picker = FakeCoursePdfPicker(null);
      final container = ProviderContainer(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(repository),
          coursePdfPickerProvider.overrideWithValue(picker),
        ],
      );
      addTearDown(container.dispose);

      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);
      final initialCourseProgressReads = repository.getCourseProgressCount;
      final initialSubjectProgressReads = repository.getSubjectProgressCount;

      final result = await container
          .read(uploadCourseDocumentControllerProvider.notifier)
          .upload(detail: courseDetail());

      expect(result, isNull);
      expect(picker.pickCount, 1);
      expect(repository.uploadCount, 0);
      expect(
        container.read(uploadCourseDocumentControllerProvider).hasError,
        false,
      );
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);
      expect(repository.getCourseProgressCount, initialCourseProgressReads);
      expect(repository.getSubjectProgressCount, initialSubjectProgressReads);
    },
  );

  test(
    'uploadCourseDocumentController uploads and invalidates detail lists and progress',
    () async {
      final repository = InMemoryCoursesRepository()
        ..coursesBySubject['subject-1'] = const [
          CourseListItem(
            id: 'course-1',
            subjectId: 'subject-1',
            title: 'Droit constitutionnel',
          ),
        ]
        ..detailsByCourse['course-1'] = courseDetail()
        ..progressByCourse['course-1'] = courseProgress()
        ..progressBySubject['subject-1'] = subjectProgress();
      final picker = FakeCoursePdfPicker(
        PickedCoursePdf(
          fileName: 'cours.pdf',
          bytes: Uint8List.fromList('%PDF-1.7'.codeUnits),
        ),
      );
      final container = ProviderContainer(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(repository),
          coursePdfPickerProvider.overrideWithValue(picker),
        ],
      );
      addTearDown(container.dispose);

      expect(
        (await container.read(courseDetailProvider('course-1').future)).sources,
        isEmpty,
      );
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);

      final initialDetailReads = repository.getCourseCount;
      final initialListReads = repository.listCoursesCount;
      final initialCourseProgressReads = repository.getCourseProgressCount;
      final initialSubjectProgressReads = repository.getSubjectProgressCount;

      final uploaded = await container
          .read(uploadCourseDocumentControllerProvider.notifier)
          .upload(detail: courseDetail());

      expect(uploaded?.fileName, 'cours.pdf');
      expect(repository.uploadCount, 1);
      expect(repository.lastUploadedCourseId, 'course-1');
      expect(
        (await container.read(courseDetailProvider('course-1').future)).sources,
        hasLength(1),
      );
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);

      expect(repository.getCourseCount, greaterThan(initialDetailReads));
      expect(repository.listCoursesCount, greaterThan(initialListReads));
      expect(
        repository.getCourseProgressCount,
        greaterThan(initialCourseProgressReads),
      );
      expect(
        repository.getSubjectProgressCount,
        greaterThan(initialSubjectProgressReads),
      );
    },
  );

  test('uploadCourseDocumentController exposes upload errors', () async {
    final repository = InMemoryCoursesRepository()
      ..progressByCourse['course-1'] = courseProgress()
      ..progressBySubject['subject-1'] = subjectProgress()
      ..uploadError = const CourseUploadException('Invalid PDF');
    final picker = FakeCoursePdfPicker(
      PickedCoursePdf(fileName: 'cours.pdf', bytes: Uint8List.fromList([1])),
    );
    final container = ProviderContainer(
      overrides: [
        coursesRepositoryProvider.overrideWithValue(repository),
        coursePdfPickerProvider.overrideWithValue(picker),
      ],
    );
    addTearDown(container.dispose);

    await container.read(courseProgressProvider('course-1').future);
    await container.read(subjectProgressProvider('subject-1').future);
    final initialCourseProgressReads = repository.getCourseProgressCount;
    final initialSubjectProgressReads = repository.getSubjectProgressCount;

    await expectLater(
      container
          .read(uploadCourseDocumentControllerProvider.notifier)
          .upload(detail: courseDetail()),
      throwsA(isA<CourseUploadException>()),
    );

    expect(
      container.read(uploadCourseDocumentControllerProvider).hasError,
      true,
    );
    await container.read(courseProgressProvider('course-1').future);
    await container.read(subjectProgressProvider('subject-1').future);
    expect(repository.getCourseProgressCount, initialCourseProgressReads);
    expect(repository.getSubjectProgressCount, initialSubjectProgressReads);
  });

  test(
    'deleteCourseDocumentController removes a source and refreshes course surfaces',
    () async {
      final repository = InMemoryCoursesRepository()
        ..coursesBySubject['subject-1'] = const [
          CourseListItem(
            id: 'course-1',
            subjectId: 'subject-1',
            title: 'Droit constitutionnel',
          ),
        ]
        ..detailsByCourse['course-1'] = courseDetail(
          sources: const [
            CourseDocument(
              id: 'document-1',
              courseId: 'course-1',
              documentId: 'document-1',
              fileName: 'cours.pdf',
              status: CourseDocumentStatus.ready,
            ),
          ],
        )
        ..progressByCourse['course-1'] = courseProgress()
        ..progressBySubject['subject-1'] = subjectProgress();
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      expect(
        (await container.read(courseDetailProvider('course-1').future)).sources,
        hasLength(1),
      );
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);

      final initialDetailReads = repository.getCourseCount;
      final initialListReads = repository.listCoursesCount;
      final initialCourseProgressReads = repository.getCourseProgressCount;
      final initialSubjectProgressReads = repository.getSubjectProgressCount;

      await container
          .read(deleteCourseDocumentControllerProvider.notifier)
          .delete(
            detail: repository.detailsByCourse['course-1']!,
            documentId: 'document-1',
          );

      expect(repository.deleteDocumentCount, 1);
      expect(repository.lastDeletedCourseId, 'course-1');
      expect(repository.lastDeletedDocumentId, 'document-1');
      expect(
        (await container.read(courseDetailProvider('course-1').future)).sources,
        isEmpty,
      );
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);

      expect(repository.getCourseCount, greaterThan(initialDetailReads));
      expect(repository.listCoursesCount, greaterThan(initialListReads));
      expect(
        repository.getCourseProgressCount,
        greaterThan(initialCourseProgressReads),
      );
      expect(
        repository.getSubjectProgressCount,
        greaterThan(initialSubjectProgressReads),
      );
    },
  );

  test(
    'deleteCourseDocumentController exposes errors without refreshing',
    () async {
      final repository = InMemoryCoursesRepository()
        ..coursesBySubject['subject-1'] = const [
          CourseListItem(
            id: 'course-1',
            subjectId: 'subject-1',
            title: 'Droit constitutionnel',
          ),
        ]
        ..detailsByCourse['course-1'] = courseDetail(
          sources: const [
            CourseDocument(
              id: 'document-1',
              courseId: 'course-1',
              documentId: 'document-1',
              fileName: 'cours.pdf',
              status: CourseDocumentStatus.ready,
            ),
          ],
        )
        ..progressByCourse['course-1'] = courseProgress()
        ..progressBySubject['subject-1'] = subjectProgress()
        ..deleteDocumentError = const CourseNotFoundException(
          'Course source not found',
        );
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container.read(courseDetailProvider('course-1').future);
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);

      final initialDetailReads = repository.getCourseCount;
      final initialListReads = repository.listCoursesCount;
      final initialCourseProgressReads = repository.getCourseProgressCount;
      final initialSubjectProgressReads = repository.getSubjectProgressCount;

      await expectLater(
        container
            .read(deleteCourseDocumentControllerProvider.notifier)
            .delete(
              detail: repository.detailsByCourse['course-1']!,
              documentId: 'document-1',
            ),
        throwsA(isA<CourseNotFoundException>()),
      );

      expect(
        container.read(deleteCourseDocumentControllerProvider).hasError,
        true,
      );
      await container.read(courseDetailProvider('course-1').future);
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);
      expect(repository.getCourseCount, initialDetailReads);
      expect(repository.listCoursesCount, initialListReads);
      expect(repository.getCourseProgressCount, initialCourseProgressReads);
      expect(repository.getSubjectProgressCount, initialSubjectProgressReads);
    },
  );

  test(
    'archiveCourseDocumentController archives a source and refreshes course surfaces',
    () async {
      final repository = InMemoryCoursesRepository()
        ..coursesBySubject['subject-1'] = const [
          CourseListItem(
            id: 'course-1',
            subjectId: 'subject-1',
            title: 'Droit constitutionnel',
          ),
        ]
        ..detailsByCourse['course-1'] = courseDetail(
          sources: const [
            CourseDocument(
              id: 'document-1',
              courseId: 'course-1',
              documentId: 'document-1',
              fileName: 'cours.pdf',
              status: CourseDocumentStatus.ready,
            ),
          ],
        )
        ..progressByCourse['course-1'] = courseProgress()
        ..progressBySubject['subject-1'] = subjectProgress()
        ..lifecycleByDocumentId['document-1'] = const SourceLifecycleDecision(
          documentId: 'document-1',
          courseId: 'course-1',
          status: SourceLifecycleStatus.active,
          recommendedAction: SourceLifecycleAction.archive,
          canDelete: false,
          canArchive: true,
          blockingReasons: ['HAS_KNOWLEDGE_UNITS'],
          userMessage: 'Cette source peut être archivée.',
        );
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container.read(courseDetailProvider('course-1').future);
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);

      final initialDetailReads = repository.getCourseCount;
      final initialListReads = repository.listCoursesCount;
      final initialCourseProgressReads = repository.getCourseProgressCount;
      final initialSubjectProgressReads = repository.getSubjectProgressCount;

      await container
          .read(archiveCourseDocumentControllerProvider.notifier)
          .archive(
            detail: repository.detailsByCourse['course-1']!,
            documentId: 'document-1',
          );

      expect(repository.archiveDocumentCount, 1);
      expect(repository.lastArchivedCourseId, 'course-1');
      expect(repository.lastArchivedDocumentId, 'document-1');
      expect(
        (await container.read(courseDetailProvider('course-1').future)).sources,
        isEmpty,
      );
      await container.read(coursesProvider('subject-1').future);
      await container.read(courseProgressProvider('course-1').future);
      await container.read(subjectProgressProvider('subject-1').future);

      expect(repository.getCourseCount, greaterThan(initialDetailReads));
      expect(repository.listCoursesCount, greaterThan(initialListReads));
      expect(
        repository.getCourseProgressCount,
        greaterThan(initialCourseProgressReads),
      );
      expect(
        repository.getSubjectProgressCount,
        greaterThan(initialSubjectProgressReads),
      );
    },
  );

  test(
    'courseRevisionSheetProvider loads an existing course-level sheet',
    () async {
      final repository = InMemoryCoursesRepository()
        ..revisionSheetsByCourse['course-1'] = revisionSheet();
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final sheet = await container.read(
        courseRevisionSheetProvider('course-1').future,
      );

      expect(sheet?.title, 'Fiche de cours');
      expect(repository.getRevisionSheetCount, 1);
    },
  );

  test('courseProgressProvider loads real course progress', () async {
    final repository = InMemoryCoursesRepository()
      ..progressByCourse['course-1'] = courseProgress();
    final container = ProviderContainer(
      overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final progress = await container.read(
      courseProgressProvider('course-1').future,
    );

    expect(progress.state, CourseProgressState.practiced);
    expect(progress.estimatedGlobalMastery, 0.18);
    expect(repository.getCourseProgressCount, 1);
  });

  test('subjectProgressProvider loads real subject progress', () async {
    final repository = InMemoryCoursesRepository()
      ..progressBySubject['subject-1'] = subjectProgress();
    final container = ProviderContainer(
      overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final progress = await container.read(
      subjectProgressProvider('subject-1').future,
    );

    expect(progress.courses.single.title, 'Droit constitutionnel');
    expect(progress.readyCourseCount, 1);
    expect(repository.getSubjectProgressCount, 1);
  });

  test(
    'generateCourseRevisionSheetController generates and invalidates',
    () async {
      final repository = InMemoryCoursesRepository()
        ..revisionSheetsByCourse['course-1'] = revisionSheet();
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container.read(courseRevisionSheetProvider('course-1').future);

      final sheet = await container
          .read(generateCourseRevisionSheetControllerProvider.notifier)
          .generate(courseId: 'course-1');

      expect(sheet.title, 'Fiche de cours');
      expect(repository.generateRevisionSheetCount, 1);
      expect(
        await container.read(courseRevisionSheetProvider('course-1').future),
        isNotNull,
      );
    },
  );

  test(
    'generateCourseRevisionSheetController exposes not-ready errors',
    () async {
      final repository = InMemoryCoursesRepository()
        ..revisionSheetErrorsByCourse['course-1'] =
            const CourseRevisionSheetNotReadyException(
              'Course has no ready source',
            );
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await expectLater(
        container
            .read(generateCourseRevisionSheetControllerProvider.notifier)
            .generate(courseId: 'course-1'),
        throwsA(isA<CourseRevisionSheetNotReadyException>()),
      );

      expect(
        container.read(generateCourseRevisionSheetControllerProvider).hasError,
        true,
      );
    },
  );

  test(
    'startCourseQuickRevisionController starts a real course session',
    () async {
      final repository = InMemoryCoursesRepository()
        ..detailsByCourse['course-1'] = courseDetail();
      final container = ProviderContainer(
        overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final response = await container
          .read(startCourseQuickRevisionControllerProvider.notifier)
          .start(detail: courseDetail());

      expect(response.session.id, 'revision-session-1');
      expect(response.session.courseId, 'course-1');
      expect(repository.startQuickRevisionCount, 1);
      expect(repository.lastQuickRevisionCourseId, 'course-1');
      expect(
        container.read(startCourseQuickRevisionControllerProvider).hasError,
        false,
      );
    },
  );

  test('startCourseQuickRevisionController exposes readiness errors', () async {
    final repository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = courseDetail()
      ..quickRevisionError = const CourseQuickRevisionUnavailableException(
        'Course has no ready knowledge unit',
      );
    final container = ProviderContainer(
      overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await expectLater(
      container
          .read(startCourseQuickRevisionControllerProvider.notifier)
          .start(detail: courseDetail()),
      throwsA(isA<CourseQuickRevisionUnavailableException>()),
    );

    expect(
      container.read(startCourseQuickRevisionControllerProvider).hasError,
      true,
    );
  });
}

CourseDetail courseDetail({List<CourseDocument> sources = const []}) {
  const course = CourseListItem(
    id: 'course-1',
    subjectId: 'subject-1',
    title: 'Droit constitutionnel',
  );
  return CourseDetail(
    course: course,
    subject: const CourseSubjectSummary(id: 'subject-1', name: 'Droit'),
    sources: sources,
  );
}

RevisionSheet revisionSheet() {
  return const RevisionSheet(
    id: 'sheet-1',
    documentId: 'document-1',
    subjectId: 'subject-1',
    status: 'READY',
    title: 'Fiche de cours',
    introduction: 'Introduction',
    sections: [
      RevisionSheetSection(
        id: 'section-1',
        displayOrder: 0,
        title: 'Institutions',
        content: 'Le Parlement contrôle le Gouvernement.',
        sources: [],
      ),
    ],
    keyPoints: ['Point clé'],
    commonMistakes: ['Erreur fréquente'],
    mustKnow: ['À savoir'],
    practiceSuggestions: ['S’entraîner'],
    errorCode: null,
  );
}

CourseProgress courseProgress() {
  return CourseProgress(
    courseId: 'course-1',
    subjectId: 'subject-1',
    knowledgeUnitCount: 12,
    practicedKnowledgeUnitCount: 3,
    coverage: 0.25,
    mastery: 0.72,
    estimatedGlobalMastery: 0.18,
    readySourceCount: 1,
    processingSourceCount: 0,
    failedSourceCount: 0,
    lastPracticedAt: DateTime.utc(2026, 6, 18, 12),
    state: CourseProgressState.practiced,
  );
}

SubjectProgress subjectProgress() {
  return SubjectProgress(
    subjectId: 'subject-1',
    knowledgeUnitCount: 12,
    practicedKnowledgeUnitCount: 3,
    coverage: 0.25,
    mastery: 0.72,
    estimatedGlobalMastery: 0.18,
    courseCount: 1,
    readyCourseCount: 1,
    lastPracticedAt: DateTime.utc(2026, 6, 18, 12),
    courses: const [
      SubjectCourseProgressItem(
        courseId: 'course-1',
        title: 'Droit constitutionnel',
        knowledgeUnitCount: 12,
        practicedKnowledgeUnitCount: 3,
        coverage: 0.25,
        mastery: 0.72,
        estimatedGlobalMastery: 0.18,
        state: CourseProgressState.practiced,
      ),
    ],
  );
}

class FakeCoursePdfPicker implements CoursePdfPicker {
  FakeCoursePdfPicker(this.result);

  final PickedCoursePdf? result;
  int pickCount = 0;

  @override
  Future<PickedCoursePdf?> pickPdf() async {
    pickCount += 1;
    return result;
  }
}

~~~

### `test/features/courses/http_courses_repository_test.dart`

~~~text
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/courses/data/http_courses_repository.dart';
import 'package:Neralune/features/courses/domain/course_models.dart';
import 'package:Neralune/features/courses/domain/courses_repository.dart';
import 'package:Neralune/features/documents/domain/source_lifecycle.dart';

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
  test('lists real courses with source counts and bearer token', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse([courseJson()]));
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final courses = await repository.listCourses(subjectId: 'subject-1');

    expect(courses.single.title, 'Droit constitutionnel');
    expect(courses.single.estimatedMinutes, 30);
    expect(courses.single.sourceCount, 2);
    expect(courses.single.readySourceCount, 1);
    expect(adapter.lastOptions?.path, '/subjects/subject-1/courses');
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
  });

  test('creates a real course with the CORE-02 payload', () async {
    final adapter = CapturingHttpClientAdapter(jsonResponse(courseJson()));
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final course = await repository.createCourse(
      subjectId: 'subject-1',
      input: const CreateCourseInput(
        title: 'Droit constitutionnel',
        description: 'Institutions',
        chapterLabel: 'Chapitre 1',
        estimatedMinutes: 30,
      ),
    );

    expect(course.id, 'course-1');
    expect(adapter.lastOptions?.method, 'POST');
    expect(adapter.lastOptions?.path, '/subjects/subject-1/courses');
    expect(adapter.lastOptions?.data, {
      'title': 'Droit constitutionnel',
      'description': 'Institutions',
      'chapterLabel': 'Chapitre 1',
      'estimatedMinutes': 30,
    });
  });

  test('loads course detail with subject and sources', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({
        'course': courseJson(sourceCount: 1, readySourceCount: 1),
        'subject': {'id': 'subject-1', 'name': 'Droit'},
        'sources': [sourceJson()],
      }),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final detail = await repository.getCourse(courseId: 'course-1');

    expect(detail.subject.name, 'Droit');
    expect(detail.sources.single.status, CourseDocumentStatus.ready);
    expect(detail.sources.single.errorCode, isNull);
    expect(adapter.lastOptions?.path, '/courses/course-1');
  });

  test('maps backend 404 to CourseNotFoundException', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({'message': 'Course not found'}, statusCode: 404),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      repository.getCourse(courseId: 'unknown'),
      throwsA(isA<CourseNotFoundException>()),
    );
  });

  test('uploads a course PDF as multipart without subjectId', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(sourceJsonWith(status: 'UPLOADED')),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final source = await repository.uploadCoursePdf(
      courseId: 'course-1',
      fileName: 'cours.pdf',
      bytes: Uint8List.fromList('%PDF-1.7'.codeUnits),
    );

    expect(source.status, CourseDocumentStatus.uploaded);
    expect(adapter.lastOptions?.method, 'POST');
    expect(adapter.lastOptions?.path, '/courses/course-1/source/course-pdf');
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );

    final formData = adapter.lastOptions?.data as FormData;
    expect(
      formData.fields.map((field) => field.key),
      isNot(contains('subjectId')),
    );
    expect(
      formData.fields.map((field) => field.key),
      isNot(contains('studentId')),
    );
    expect(formData.files.single.key, 'file');
    expect(formData.files.single.value.filename, 'cours.pdf');
  });

  test('maps upload 400 and 404 to typed course exceptions', () async {
    final badRequest = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({'message': 'Invalid file'}, statusCode: 400),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      badRequest.uploadCoursePdf(
        courseId: 'course-1',
        fileName: 'cours.txt',
        bytes: Uint8List.fromList([1, 2, 3]),
      ),
      throwsA(isA<CourseUploadException>()),
    );

    final notFound = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({'message': 'Course not found'}, statusCode: 404),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      notFound.uploadCoursePdf(
        courseId: 'missing',
        fileName: 'cours.pdf',
        bytes: Uint8List.fromList([1, 2, 3]),
      ),
      throwsA(isA<CourseNotFoundException>()),
    );
  });

  test(
    'deletes a course source through the encoded course-scoped endpoint',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(null, statusCode: 204),
      );
      final repository = HttpCoursesRepository(
        dio: Dio()..httpClientAdapter = adapter,
        getIdToken: () async => 'firebase-id-token',
      );

      await repository.deleteCourseDocument(
        courseId: 'course id/1',
        documentId: 'document id/1',
      );

      expect(adapter.lastOptions?.method, 'DELETE');
      expect(
        adapter.lastOptions?.path,
        '/courses/course%20id%2F1/sources/document%20id%2F1',
      );
      expect(adapter.lastOptions?.data, isNull);
      expect(
        adapter.lastOptions?.headers['Authorization'],
        'Bearer firebase-id-token',
      );
    },
  );

  test('maps course source delete 404 to CourseNotFoundException', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({'message': 'Course source not found'}, statusCode: 404),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      repository.deleteCourseDocument(
        courseId: 'course-1',
        documentId: 'missing-document',
      ),
      throwsA(isA<CourseNotFoundException>()),
    );
  });

  test(
    'maps course source delete 409 to a readable request exception',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse({
          'message': 'Cette source peut être archivée.',
        }, statusCode: 409),
      );
      final repository = HttpCoursesRepository(
        dio: Dio()..httpClientAdapter = adapter,
        getIdToken: () async => 'firebase-id-token',
      );

      await expectLater(
        repository.deleteCourseDocument(
          courseId: 'course-1',
          documentId: 'document-1',
        ),
        throwsA(
          isA<CourseRequestException>().having(
            (error) => error.message,
            'message',
            'Cette source peut être archivée.',
          ),
        ),
      );
    },
  );

  test('loads course source lifecycle from the encoded endpoint', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(sourceLifecycleJson()),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final decision = await repository.getCourseDocumentLifecycle(
      courseId: 'course id/1',
      documentId: 'document id/1',
    );

    expect(decision.recommendedAction, SourceLifecycleAction.archive);
    expect(decision.canArchive, true);
    expect(adapter.lastOptions?.method, 'GET');
    expect(
      adapter.lastOptions?.path,
      '/courses/course%20id%2F1/sources/document%20id%2F1/lifecycle',
    );
  });

  test('archives a course source through the encoded endpoint', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(sourceLifecycleJson(status: 'ARCHIVED', action: 'BLOCK')),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final decision = await repository.archiveCourseDocument(
      courseId: 'course id/1',
      documentId: 'document id/1',
    );

    expect(decision.status, SourceLifecycleStatus.archived);
    expect(adapter.lastOptions?.method, 'POST');
    expect(
      adapter.lastOptions?.path,
      '/courses/course%20id%2F1/sources/document%20id%2F1/archive',
    );
  });

  test(
    'loads a course-level revision sheet from the course endpoint',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(revisionSheetJson()),
      );
      final repository = HttpCoursesRepository(
        dio: Dio()..httpClientAdapter = adapter,
        getIdToken: () async => 'firebase-id-token',
      );

      final sheet = await repository.getCourseRevisionSheet(
        courseId: 'course-1',
      );

      expect(sheet?.title, 'Fiche de cours');
      expect(sheet?.sections.single.title, 'Institutions');
      expect(adapter.lastOptions?.method, 'GET');
      expect(adapter.lastOptions?.path, '/courses/course-1/revision-sheet');
    },
  );

  test(
    'generates a course-level revision sheet without documentId payload',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(revisionSheetJson()),
      );
      final repository = HttpCoursesRepository(
        dio: Dio()..httpClientAdapter = adapter,
        getIdToken: () async => 'firebase-id-token',
      );

      final sheet = await repository.generateCourseRevisionSheet(
        courseId: 'course-1',
      );

      expect(sheet.title, 'Fiche de cours');
      expect(adapter.lastOptions?.method, 'POST');
      expect(adapter.lastOptions?.path, '/courses/course-1/revision-sheet');
      expect(adapter.lastOptions?.data, isNull);
    },
  );

  test(
    'maps course-level revision sheet 404 and 409 to typed outcomes',
    () async {
      final notFoundRepository = HttpCoursesRepository(
        dio: Dio()
          ..httpClientAdapter = CapturingHttpClientAdapter(
            jsonResponse({
              'message': 'Revision sheet not found',
            }, statusCode: 404),
          ),
        getIdToken: () async => 'firebase-id-token',
      );

      await expectLater(
        notFoundRepository.getCourseRevisionSheet(courseId: 'course-1'),
        completion(isNull),
      );

      final missingCourseRepository = HttpCoursesRepository(
        dio: Dio()
          ..httpClientAdapter = CapturingHttpClientAdapter(
            jsonResponse({'message': 'Course not found'}, statusCode: 404),
          ),
        getIdToken: () async => 'firebase-id-token',
      );

      await expectLater(
        missingCourseRepository.getCourseRevisionSheet(courseId: 'course-1'),
        throwsA(isA<CourseNotFoundException>()),
      );

      final notReadyRepository = HttpCoursesRepository(
        dio: Dio()
          ..httpClientAdapter = CapturingHttpClientAdapter(
            jsonResponse({
              'message': 'Course has no ready source',
            }, statusCode: 409),
          ),
        getIdToken: () async => 'firebase-id-token',
      );

      await expectLater(
        notReadyRepository.generateCourseRevisionSheet(courseId: 'course-1'),
        throwsA(isA<CourseRevisionSheetNotReadyException>()),
      );
    },
  );

  test(
    'starts a course quick revision with the selected question count',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(revisionSessionJson(courseId: 'course-1')),
      );
      final repository = HttpCoursesRepository(
        dio: Dio()..httpClientAdapter = adapter,
        getIdToken: () async => 'firebase-id-token',
      );

      final response = await repository.startCourseQuickRevision(
        courseId: 'course-1',
        questionCount: 20,
      );

      expect(response.session.id, 'revision-session-1');
      expect(response.session.courseId, 'course-1');
      expect(response.currentAction?.kind.name, 'diagnosticQuiz');
      expect(adapter.lastOptions?.method, 'POST');
      expect(
        adapter.lastOptions?.path,
        '/courses/course-1/revision-sessions/quick',
      );
      expect(adapter.lastOptions?.data, {'questionCount': 20});
      expect(
        adapter.lastOptions?.headers['Authorization'],
        'Bearer firebase-id-token',
      );
    },
  );

  test('loads course progress from the course progress endpoint', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(courseProgressJson()),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final progress = await repository.getCourseProgress(courseId: 'course-1');

    expect(progress.knowledgeUnitCount, 12);
    expect(progress.practicedKnowledgeUnitCount, 3);
    expect(progress.coverage, 0.25);
    expect(progress.mastery, 0.72);
    expect(progress.estimatedGlobalMastery, 0.18);
    expect(progress.state, CourseProgressState.practiced);
    expect(adapter.lastOptions?.method, 'GET');
    expect(adapter.lastOptions?.path, '/courses/course-1/progress');
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
  });

  test('loads subject progress and maps unknown course state safely', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(
        subjectProgressJson(
          courses: [subjectCourseProgressJson(state: 'FUTURE_STATE')],
        ),
      ),
    );
    final repository = HttpCoursesRepository(
      dio: Dio()..httpClientAdapter = adapter,
      getIdToken: () async => 'firebase-id-token',
    );

    final progress = await repository.getSubjectProgress(
      subjectId: 'subject-1',
    );

    expect(progress.courseCount, 1);
    expect(progress.readyCourseCount, 1);
    expect(progress.courses.single.state, CourseProgressState.unknown);
    expect(adapter.lastOptions?.method, 'GET');
    expect(adapter.lastOptions?.path, '/subjects/subject-1/progress');
  });

  test('parses nullable mastery and progress 404 errors', () async {
    final noMasteryRepository = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse(courseProgressJson(mastery: null)),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    final progress = await noMasteryRepository.getCourseProgress(
      courseId: 'course-1',
    );

    expect(progress.mastery, isNull);

    final missingCourseRepository = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({'message': 'Course not found'}, statusCode: 404),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      missingCourseRepository.getCourseProgress(courseId: 'missing'),
      throwsA(isA<CourseNotFoundException>()),
    );
  });

  test('maps course quick revision 404 and 409 to typed exceptions', () async {
    final missingCourseRepository = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({'message': 'Course not found'}, statusCode: 404),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      missingCourseRepository.startCourseQuickRevision(courseId: 'missing'),
      throwsA(isA<CourseNotFoundException>()),
    );

    final notReadyRepository = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({
            'message': 'Course has no ready knowledge unit',
          }, statusCode: 409),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      notReadyRepository.startCourseQuickRevision(courseId: 'course-1'),
      throwsA(
        isA<CourseQuickRevisionUnavailableException>().having(
          (error) => error.message,
          'message',
          'Course has no ready knowledge unit',
        ),
      ),
    );
  });

  test('rejects unknown source status and invalid shapes', () async {
    final invalidStatus = sourceJson()..['status'] = 'ARCHIVED';
    final repository = HttpCoursesRepository(
      dio: Dio()
        ..httpClientAdapter = CapturingHttpClientAdapter(
          jsonResponse({
            'course': courseJson(),
            'subject': {'id': 'subject-1', 'name': 'Droit'},
            'sources': [invalidStatus],
          }),
        ),
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      repository.getCourse(courseId: 'course-1'),
      throwsFormatException,
    );
  });
}

Map<String, Object?> revisionSessionJson({required String courseId}) {
  return {
    'session': {
      'id': 'revision-session-1',
      'status': 'STARTED',
      'mode': 'QUICK',
      'subjectId': 'subject-1',
      'courseId': courseId,
      'documentId': 'document-1',
      'knowledgeUnitId': 'knowledge-unit-1',
      'createdAt': '2026-06-18T10:00:00.000Z',
      'completedAt': null,
    },
    'currentAction': {
      'id': 'action-1',
      'kind': 'DIAGNOSTIC_QUIZ',
      'status': 'READY',
      'displayOrder': 0,
      'activitySessionId': 'activity-session-1',
      'documentId': 'document-1',
      'knowledgeUnitId': 'knowledge-unit-1',
      'payload': null,
    },
    'history': [],
  };
}

Map<String, Object?> courseJson({
  int sourceCount = 2,
  int readySourceCount = 1,
}) {
  return {
    'id': 'course-1',
    'subjectId': 'subject-1',
    'title': 'Droit constitutionnel',
    'description': 'Institutions',
    'chapterLabel': 'Chapitre 1',
    'estimatedMinutes': 30,
    'displayOrder': 0,
    'createdAt': '2026-06-18T10:00:00.000Z',
    'updatedAt': '2026-06-18T10:00:00.000Z',
    'sourceCount': sourceCount,
    'readySourceCount': readySourceCount,
    'processingSourceCount': 1,
    'failedSourceCount': 0,
  };
}

Map<String, Object?> sourceJson() {
  return sourceJsonWith(status: 'READY');
}

Map<String, Object?> sourceJsonWith({required String status}) {
  return {
    'id': 'document-1',
    'courseId': 'course-1',
    'documentId': 'document-1',
    'fileName': 'cours.pdf',
    'kind': 'COURSE_PDF',
    'status': status,
    'errorCode': null,
    'createdAt': '2026-06-18T10:00:00.000Z',
    'updatedAt': '2026-06-18T10:00:00.000Z',
  };
}

Map<String, Object?> sourceLifecycleJson({
  String status = 'ACTIVE',
  String action = 'ARCHIVE',
}) {
  return {
    'documentId': 'document-1',
    'courseId': 'course-1',
    'status': status,
    'recommendedAction': action,
    'canDelete': action == 'DELETE',
    'canArchive': action == 'ARCHIVE',
    'blockingReasons': action == 'ARCHIVE' ? ['HAS_KNOWLEDGE_UNITS'] : [],
    'userMessage': 'Cette source peut être archivée.',
  };
}

Map<String, Object?> courseProgressJson({Object? mastery = 0.72}) {
  return {
    'courseId': 'course-1',
    'subjectId': 'subject-1',
    'knowledgeUnitCount': 12,
    'practicedKnowledgeUnitCount': 3,
    'coverage': 0.25,
    'mastery': mastery,
    'estimatedGlobalMastery': 0.18,
    'readySourceCount': 1,
    'processingSourceCount': 0,
    'failedSourceCount': 0,
    'lastPracticedAt': '2026-06-18T12:00:00.000Z',
    'state': 'PRACTICED',
  };
}

Map<String, Object?> subjectProgressJson({
  List<Map<String, Object?>>? courses,
}) {
  return {
    'subjectId': 'subject-1',
    'knowledgeUnitCount': 12,
    'practicedKnowledgeUnitCount': 3,
    'coverage': 0.25,
    'mastery': 0.72,
    'estimatedGlobalMastery': 0.18,
    'courseCount': 1,
    'readyCourseCount': 1,
    'lastPracticedAt': '2026-06-18T12:00:00.000Z',
    'courses': courses ?? [subjectCourseProgressJson()],
  };
}

Map<String, Object?> subjectCourseProgressJson({String state = 'PRACTICED'}) {
  return {
    'courseId': 'course-1',
    'title': 'Droit constitutionnel',
    'knowledgeUnitCount': 12,
    'practicedKnowledgeUnitCount': 3,
    'coverage': 0.25,
    'mastery': 0.72,
    'estimatedGlobalMastery': 0.18,
    'state': state,
  };
}

Map<String, Object?> revisionSheetJson() {
  return {
    'id': 'sheet-1',
    'documentId': 'document-1',
    'subjectId': 'subject-1',
    'status': 'READY',
    'title': 'Fiche de cours',
    'introduction': 'Introduction',
    'keyPoints': ['Point clé'],
    'commonMistakes': ['Erreur fréquente'],
    'mustKnow': ['À savoir'],
    'practiceSuggestions': ['S’entraîner'],
    'errorCode': null,
    'sections': [
      {
        'id': 'section-1',
        'displayOrder': 0,
        'title': 'Institutions',
        'content': 'Le Parlement contrôle le Gouvernement.',
        'sources': [
          {
            'chunkId': 'chunk-1',
            'text': 'Extrait source',
            'pageNumber': 1,
            'index': 0,
          },
        ],
      },
    ],
  };
}

ResponseBody jsonResponse(Object? body, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

~~~

### `test/features/documents/document_detail_page_test.dart`

~~~text
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/documents/application/documents_controller.dart';
import 'package:Neralune/features/documents/domain/revision_document.dart';
import 'package:Neralune/features/documents/domain/source_lifecycle.dart';
import 'package:Neralune/presentation/pages/documents/document_detail_page.dart';

class DetailDocumentsApi implements DocumentsApi {
  DetailDocumentsApi({
    required this.document,
    this.knowledgeUnits = const [],
    this.summary,
    this.revisionSheet,
    this.generatedSummary,
    this.generatedRevisionSheet,
    this.error,
    this.summaryError,
    this.revisionSheetError,
  });

  final RevisionDocument document;
  final List<DocumentKnowledgeUnit> knowledgeUnits;
  DocumentSummary? summary;
  RevisionSheet? revisionSheet;
  final DocumentSummary? generatedSummary;
  final RevisionSheet? generatedRevisionSheet;
  final Object? error;
  final Object? summaryError;
  final Object? revisionSheetError;

  @override
  Future<RevisionDocument> getDocument({required String documentId}) async {
    final error = this.error;
    if (error != null) {
      throw error;
    }

    return document;
  }

  @override
  Future<void> deleteDocument({required String documentId}) async {}

  @override
  Future<SourceLifecycleDecision> getDocumentLifecycle({
    required String documentId,
  }) async {
    return SourceLifecycleDecision(
      documentId: documentId,
      courseId: null,
      status: SourceLifecycleStatus.active,
      recommendedAction: SourceLifecycleAction.delete,
      canDelete: true,
      canArchive: true,
      blockingReasons: const [],
      userMessage: 'Cette source peut être supprimée.',
    );
  }

  @override
  Future<SourceLifecycleDecision> archiveDocument({
    required String documentId,
  }) async {
    return SourceLifecycleDecision(
      documentId: documentId,
      courseId: null,
      status: SourceLifecycleStatus.archived,
      recommendedAction: SourceLifecycleAction.block,
      canDelete: false,
      canArchive: false,
      blockingReasons: const ['ALREADY_ARCHIVED'],
      userMessage: 'Cette source est archivée.',
    );
  }

  @override
  Future<DocumentKnowledgeUnitsResponse> listDocumentKnowledgeUnits({
    required String documentId,
  }) async {
    return DocumentKnowledgeUnitsResponse(
      documentId: documentId,
      items: knowledgeUnits,
    );
  }

  @override
  Future<DocumentSummary?> getDocumentSummary({
    required String documentId,
  }) async {
    final error = summaryError;
    if (error != null) {
      throw error;
    }

    return summary;
  }

  @override
  Future<DocumentSummary> generateDocumentSummary({
    required String documentId,
  }) async {
    final generated = generatedSummary ?? summary;
    if (generated == null) {
      throw StateError('summary generation failed');
    }
    summary = generated;
    return generated;
  }

  @override
  Future<RevisionSheet?> getRevisionSheet({required String documentId}) async {
    final error = revisionSheetError;
    if (error != null) {
      throw error;
    }

    return revisionSheet;
  }

  @override
  Future<RevisionSheet> generateRevisionSheet({
    required String documentId,
  }) async {
    final generated = generatedRevisionSheet ?? revisionSheet;
    if (generated == null) {
      throw StateError('revision sheet generation failed');
    }
    revisionSheet = generated;
    return generated;
  }

  @override
  Future<List<RevisionDocument>> listSubjectDocuments({
    required String subjectId,
  }) async {
    return [document];
  }

  @override
  Future<RevisionDocument> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('shows a waiting state for processing documents', (tester) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'PROCESSING',
          mimeType: 'application/pdf',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('cours.pdf'), findsOneWidget);
    expect(find.text('Analyse en cours'), findsWidgets);
    expect(
      find.text('Les notions apparaitront apres le traitement.'),
      findsOneWidget,
    );
  });

  testWidgets('shows failed document errors', (tester) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'FAILED',
          mimeType: 'application/pdf',
          errorCode: 'KNOWLEDGE_EXTRACTION_FAILED',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Analyse echouee'), findsWidgets);
    expect(find.text('Erreur IA'), findsWidgets);
  });

  testWidgets('shows ready knowledge units and source excerpts', (
    tester,
  ) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'READY',
          mimeType: 'application/pdf',
        ),
        knowledgeUnits: const [
          DocumentKnowledgeUnit(
            id: 'unit-1',
            title: 'Séparation des pouvoirs',
            summary: 'Résumé court.',
            difficulty: 'MEDIUM',
            displayOrder: 1,
            confidence: 0.84,
            sources: [
              DocumentKnowledgeUnitSource(
                chunkId: 'chunk-1',
                text: 'Extrait source issu du chunk.',
                pageNumber: null,
                index: 0,
              ),
            ],
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Séparation des pouvoirs'), findsOneWidget);
    expect(find.text('Résumé court.'), findsOneWidget);
    expect(find.text('Difficulte moyenne'), findsOneWidget);
    expect(find.text('Confiance 84%'), findsOneWidget);
    expect(find.text('Question ouverte'), findsOneWidget);
    expect(find.text('Extrait source issu du chunk.'), findsOneWidget);
    expect(find.text('Supports IA'), findsOneWidget);
    expect(find.text('Generer le resume'), findsOneWidget);
    expect(find.text('Generer la fiche'), findsOneWidget);
  });

  testWidgets('generates and displays a document summary', (tester) async {
    await tester.pumpWidget(
      documentDetailApp(document: readyDocument(), generatedSummary: summary()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Generer le resume'));
    await tester.pumpAndSettle();

    expect(find.text('Résumé du cours'), findsOneWidget);
    expect(find.text('Texte synthétique.'), findsOneWidget);
    expect(find.text('Point clé'), findsOneWidget);
    expect(find.text('Extrait summary.'), findsOneWidget);
  });

  testWidgets('generates and displays a revision sheet', (tester) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: readyDocument(),
        generatedRevisionSheet: revisionSheet(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Generer la fiche'));
    await tester.pumpAndSettle();

    expect(find.text('Fiche de révision'), findsOneWidget);
    expect(find.text('Principe clé'), findsOneWidget);
    expect(find.text('Explication structurée.'), findsOneWidget);
    expect(find.text('Extrait fiche.'), findsOneWidget);
  });

  testWidgets('does not show artifact generation CTAs before ready', (
    tester,
  ) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'PROCESSING',
          mimeType: 'application/pdf',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Generer le resume'), findsNothing);
    expect(find.text('Generer la fiche'), findsNothing);
  });

  testWidgets('shows artifact loading errors without hiding notions', (
    tester,
  ) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: readyDocument(),
        knowledgeUnits: const [
          DocumentKnowledgeUnit(
            id: 'unit-1',
            title: 'Constitution',
            summary: 'Norme fondamentale.',
            sources: [],
          ),
        ],
        summaryError: StateError('summary failed'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Constitution'), findsOneWidget);
    expect(find.text('Impossible de charger les supports IA'), findsOneWidget);
  });

  testWidgets('shows API errors with retry action', (tester) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'READY',
          mimeType: 'application/pdf',
        ),
        error: StateError('network failed'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Impossible de charger le document'), findsOneWidget);
    expect(find.text('Reessayer'), findsOneWidget);
  });
}

Widget documentDetailApp({
  required RevisionDocument document,
  List<DocumentKnowledgeUnit> knowledgeUnits = const [],
  DocumentSummary? summary,
  RevisionSheet? revisionSheet,
  DocumentSummary? generatedSummary,
  RevisionSheet? generatedRevisionSheet,
  Object? error,
  Object? summaryError,
  Object? revisionSheetError,
}) {
  return MaterialApp(
    home: Scaffold(
      body: DocumentDetailPage(
        documentId: document.id,
        controller: DocumentsController(
          DetailDocumentsApi(
            document: document,
            knowledgeUnits: knowledgeUnits,
            summary: summary,
            revisionSheet: revisionSheet,
            generatedSummary: generatedSummary,
            generatedRevisionSheet: generatedRevisionSheet,
            error: error,
            summaryError: summaryError,
            revisionSheetError: revisionSheetError,
          ),
        ),
      ),
    ),
  );
}

RevisionDocument readyDocument() {
  return const RevisionDocument(
    id: 'document-1',
    subjectId: 'subject-1',
    kind: 'COURSE_PDF',
    fileName: 'cours.pdf',
    status: 'READY',
    mimeType: 'application/pdf',
  );
}

DocumentSummary summary() {
  return const DocumentSummary(
    id: 'summary-1',
    documentId: 'document-1',
    subjectId: 'subject-1',
    status: 'READY',
    title: 'Résumé du cours',
    content: 'Texte synthétique.',
    keyPoints: ['Point clé'],
    limits: 'Limite.',
    errorCode: null,
    sources: [
      DocumentArtifactSource(
        chunkId: 'chunk-1',
        text: 'Extrait summary.',
        pageNumber: null,
        index: 0,
      ),
    ],
  );
}

RevisionSheet revisionSheet() {
  return const RevisionSheet(
    id: 'sheet-1',
    documentId: 'document-1',
    subjectId: 'subject-1',
    status: 'READY',
    title: 'Fiche de révision',
    introduction: "Vue d'ensemble.",
    sections: [
      RevisionSheetSection(
        id: 'section-1',
        displayOrder: 0,
        title: 'Principe clé',
        content: 'Explication structurée.',
        sources: [
          DocumentArtifactSource(
            chunkId: 'chunk-1',
            text: 'Extrait fiche.',
            pageNumber: null,
            index: 0,
          ),
        ],
      ),
    ],
    keyPoints: ['À retenir'],
    commonMistakes: [],
    mustKnow: ['Indispensable'],
    practiceSuggestions: ['Relire la section.'],
    errorCode: null,
  );
}

~~~

### `test/features/documents/document_import_button_test.dart`

~~~text
import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/documents/application/documents_controller.dart';
import 'package:Neralune/features/documents/domain/revision_document.dart';
import 'package:Neralune/features/documents/domain/source_lifecycle.dart';
import 'package:Neralune/presentation/design_system/components/revision_mvp_components.dart';
import 'package:Neralune/presentation/widgets/documents/document_import_button.dart';

class CompletingDocumentsApi implements DocumentsApi {
  final completer = Completer<void>();
  int uploadCallCount = 0;

  @override
  Future<RevisionDocument> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    uploadCallCount += 1;
    await completer.future;

    return RevisionDocument(
      id: 'document-1',
      subjectId: subjectId,
      kind: 'COURSE_PDF',
      fileName: '1710000000000-cours.pdf',
      status: 'UPLOADED',
      mimeType: 'application/pdf',
    );
  }

  @override
  Future<List<RevisionDocument>> listSubjectDocuments({
    required String subjectId,
  }) async {
    return const [];
  }

  @override
  Future<RevisionDocument> getDocument({required String documentId}) async {
    throw StateError('No documents available');
  }

  @override
  Future<void> deleteDocument({required String documentId}) async {}

  @override
  Future<SourceLifecycleDecision> getDocumentLifecycle({
    required String documentId,
  }) async {
    return SourceLifecycleDecision(
      documentId: documentId,
      courseId: null,
      status: SourceLifecycleStatus.active,
      recommendedAction: SourceLifecycleAction.delete,
      canDelete: true,
      canArchive: true,
      blockingReasons: const [],
      userMessage: 'Cette source peut être supprimée.',
    );
  }

  @override
  Future<SourceLifecycleDecision> archiveDocument({
    required String documentId,
  }) async {
    return SourceLifecycleDecision(
      documentId: documentId,
      courseId: null,
      status: SourceLifecycleStatus.archived,
      recommendedAction: SourceLifecycleAction.block,
      canDelete: false,
      canArchive: false,
      blockingReasons: const ['ALREADY_ARCHIVED'],
      userMessage: 'Cette source est archivée.',
    );
  }

  @override
  Future<DocumentKnowledgeUnitsResponse> listDocumentKnowledgeUnits({
    required String documentId,
  }) async {
    return DocumentKnowledgeUnitsResponse(
      documentId: documentId,
      items: const [],
    );
  }

  @override
  Future<DocumentSummary?> getDocumentSummary({
    required String documentId,
  }) async {
    return null;
  }

  @override
  Future<DocumentSummary> generateDocumentSummary({
    required String documentId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<RevisionSheet?> getRevisionSheet({required String documentId}) async {
    return null;
  }

  @override
  Future<RevisionSheet> generateRevisionSheet({required String documentId}) {
    throw UnimplementedError();
  }
}

class FailingDocumentsApi extends CompletingDocumentsApi {
  @override
  Future<RevisionDocument> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    throw StateError('upload failed');
  }
}

void main() {
  testWidgets('disables the button while upload is in progress', (
    tester,
  ) async {
    final documentsApi = CompletingDocumentsApi();
    final controller = DocumentsController(documentsApi);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocumentImportButton(
            subjectId: 'subject-1',
            controller: controller,
            pickFiles: () async => FilePickerResult([
              PlatformFile(
                name: 'cours.pdf',
                size: 3,
                bytes: Uint8List.fromList([1, 2, 3]),
              ),
            ]),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(RevisionGradientButton));
    await tester.pump();

    expect(
      tester
          .widget<RevisionGradientButton>(find.byType(RevisionGradientButton))
          .onPressed,
      isNull,
    );

    await tester.tap(find.byType(RevisionGradientButton));
    await tester.pump();

    expect(documentsApi.uploadCallCount, 1);

    documentsApi.completer.complete();
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<RevisionGradientButton>(find.byType(RevisionGradientButton))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('shows a snackbar when upload fails', (tester) async {
    final controller = DocumentsController(FailingDocumentsApi());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocumentImportButton(
            subjectId: 'subject-1',
            controller: controller,
            pickFiles: () async => FilePickerResult([
              PlatformFile(
                name: 'cours.pdf',
                size: 3,
                bytes: Uint8List.fromList([1, 2, 3]),
              ),
            ]),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(RevisionGradientButton));
    await tester.pump();

    expect(find.text("Impossible d'importer le document"), findsOneWidget);
  });

  testWidgets('notifies parent widgets after a successful import', (
    tester,
  ) async {
    var importedCount = 0;
    final documentsApi = CompletingDocumentsApi();
    final controller = DocumentsController(documentsApi);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocumentImportButton(
            subjectId: 'subject-1',
            controller: controller,
            onImported: () => importedCount += 1,
            pickFiles: () async => FilePickerResult([
              PlatformFile(
                name: 'cours.pdf',
                size: 3,
                bytes: Uint8List.fromList([1, 2, 3]),
              ),
            ]),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(RevisionGradientButton));
    await tester.pump();

    documentsApi.completer.complete();
    await tester.pumpAndSettle();

    expect(importedCount, 1);
  });
}

~~~

### `test/features/documents/documents_controller_test.dart`

~~~text
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/documents/application/documents_controller.dart';
import 'package:Neralune/features/documents/domain/revision_document.dart';
import 'package:Neralune/features/documents/domain/source_lifecycle.dart';

class FakeDocumentsApi implements DocumentsApi {
  int uploadCallCount = 0;
  String? uploadedSubjectId;
  String? uploadedFileName;
  Uint8List? uploadedBytes;
  Object? uploadError;
  final Map<String, List<DocumentKnowledgeUnit>> unitsByDocumentId = {};
  final Map<String, DocumentSummary> summariesByDocumentId = {};
  final Map<String, RevisionSheet> revisionSheetsByDocumentId = {};
  final Map<String, SourceLifecycleDecision> lifecycleByDocumentId = {};
  final List<RevisionDocument> documents = [];
  int generateSummaryCallCount = 0;
  int generateRevisionSheetCallCount = 0;
  int deleteDocumentCallCount = 0;
  String? deletedDocumentId;

  @override
  Future<RevisionDocument> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    uploadCallCount += 1;
    uploadedSubjectId = subjectId;
    uploadedFileName = fileName;
    uploadedBytes = bytes;

    final error = uploadError;
    if (error != null) {
      throw error;
    }

    final document = RevisionDocument(
      id: 'document-${documents.length + 1}',
      subjectId: subjectId,
      kind: 'COURSE_PDF',
      fileName: '1710000000000-$fileName',
      status: 'UPLOADED',
      mimeType: 'application/pdf',
    );
    documents.add(document);

    return document;
  }

  @override
  Future<List<RevisionDocument>> listSubjectDocuments({
    required String subjectId,
  }) async {
    return documents
        .where((document) => document.subjectId == subjectId)
        .toList(growable: false);
  }

  @override
  Future<void> deleteDocument({required String documentId}) async {
    deleteDocumentCallCount += 1;
    deletedDocumentId = documentId;
    documents.removeWhere((document) => document.id == documentId);
  }

  @override
  Future<SourceLifecycleDecision> getDocumentLifecycle({
    required String documentId,
  }) async {
    final document = documents.firstWhere(
      (document) => document.id == documentId,
      orElse: () => RevisionDocument(
        id: documentId,
        subjectId: 'subject-1',
        kind: 'COURSE_PDF',
        fileName: 'cours.pdf',
        status: 'FAILED',
        mimeType: 'application/pdf',
      ),
    );

    return lifecycleByDocumentId[documentId] ??
        SourceLifecycleDecision(
          documentId: document.id,
          courseId: null,
          status: SourceLifecycleStatus.active,
          recommendedAction: SourceLifecycleAction.delete,
          canDelete: true,
          canArchive: true,
          blockingReasons: const [],
          userMessage: 'Cette source peut être supprimée.',
        );
  }

  @override
  Future<SourceLifecycleDecision> archiveDocument({
    required String documentId,
  }) async {
    documents.removeWhere((document) => document.id == documentId);
    return SourceLifecycleDecision(
      documentId: documentId,
      courseId: null,
      status: SourceLifecycleStatus.archived,
      recommendedAction: SourceLifecycleAction.block,
      canDelete: false,
      canArchive: false,
      blockingReasons: const ['ALREADY_ARCHIVED'],
      userMessage: 'Cette source est archivée.',
    );
  }

  @override
  Future<RevisionDocument> getDocument({required String documentId}) async {
    return documents.singleWhere((document) => document.id == documentId);
  }

  @override
  Future<DocumentKnowledgeUnitsResponse> listDocumentKnowledgeUnits({
    required String documentId,
  }) async {
    return DocumentKnowledgeUnitsResponse(
      documentId: documentId,
      items: unitsByDocumentId[documentId] ?? const [],
    );
  }

  @override
  Future<DocumentSummary?> getDocumentSummary({
    required String documentId,
  }) async {
    return summariesByDocumentId[documentId];
  }

  @override
  Future<DocumentSummary> generateDocumentSummary({
    required String documentId,
  }) async {
    generateSummaryCallCount += 1;
    return summariesByDocumentId[documentId]!;
  }

  @override
  Future<RevisionSheet?> getRevisionSheet({required String documentId}) async {
    return revisionSheetsByDocumentId[documentId];
  }

  @override
  Future<RevisionSheet> generateRevisionSheet({
    required String documentId,
  }) async {
    generateRevisionSheetCallCount += 1;
    return revisionSheetsByDocumentId[documentId]!;
  }
}

void main() {
  test('uploads a course PDF through the documents API', () async {
    final api = FakeDocumentsApi();
    final controller = DocumentsController(api);
    final bytes = Uint8List.fromList([1, 2, 3]);

    final document = await controller.uploadCoursePdf(
      subjectId: 'subject-1',
      fileName: 'cours.pdf',
      bytes: bytes,
    );

    expect(api.uploadCallCount, 1);
    expect(api.uploadedSubjectId, 'subject-1');
    expect(api.uploadedFileName, 'cours.pdf');
    expect(api.uploadedBytes, bytes);
    expect(document.status, 'UPLOADED');
  });

  test('surfaces upload failures', () async {
    final api = FakeDocumentsApi()..uploadError = StateError('upload failed');
    final controller = DocumentsController(api);

    await expectLater(
      controller.uploadCoursePdf(
        subjectId: 'subject-1',
        fileName: 'cours.pdf',
        bytes: Uint8List.fromList([1, 2, 3]),
      ),
      throwsStateError,
    );
  });

  test('lists documents for a subject', () async {
    final api = FakeDocumentsApi();
    final controller = DocumentsController(api);

    await controller.uploadCoursePdf(
      subjectId: 'subject-1',
      fileName: 'cours.pdf',
      bytes: Uint8List.fromList([1, 2, 3]),
    );

    final documents = await controller.listSubjectDocuments('subject-1');

    expect(documents.single.fileName, '1710000000000-cours.pdf');
  });

  test('trims document id before deleting a document', () async {
    final api = FakeDocumentsApi();
    final controller = DocumentsController(api);

    await controller.deleteDocument(' document-1 ');

    expect(api.deleteDocumentCallCount, 1);
    expect(api.deletedDocumentId, 'document-1');
  });

  test('rejects empty document ids before deleting a document', () async {
    final api = FakeDocumentsApi();
    final controller = DocumentsController(api);

    expect(() => controller.deleteDocument('  '), throwsArgumentError);
    expect(api.deleteDocumentCallCount, 0);
  });

  test('loads ready document detail with knowledge units', () async {
    final api = FakeDocumentsApi()
      ..documents.add(
        const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'READY',
          mimeType: 'application/pdf',
        ),
      )
      ..unitsByDocumentId['document-1'] = const [
        DocumentKnowledgeUnit(
          id: 'unit-1',
          title: 'Constitution',
          summary: 'Norme fondamentale.',
          difficulty: 'MEDIUM',
          displayOrder: 1,
          confidence: 0.8,
          sources: [
            DocumentKnowledgeUnitSource(
              chunkId: 'chunk-1',
              text: 'Extrait source.',
              pageNumber: null,
              index: 0,
            ),
          ],
        ),
      ];
    final controller = DocumentsController(api);

    final detail = await controller.loadDocumentDetail('document-1');

    expect(detail.document.status, 'READY');
    expect(detail.knowledgeUnits.single.title, 'Constitution');
    expect(detail.state, DocumentDetailLoadState.ready);
  });

  test('does not load knowledge units for processing documents', () async {
    final api = FakeDocumentsApi()
      ..documents.add(
        const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'PROCESSING',
          mimeType: 'application/pdf',
        ),
      );
    final controller = DocumentsController(api);

    final detail = await controller.loadDocumentDetail('document-1');

    expect(detail.state, DocumentDetailLoadState.notReady);
    expect(detail.knowledgeUnits, isEmpty);
  });

  test('exposes failed document detail error state', () async {
    final api = FakeDocumentsApi()
      ..documents.add(
        const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'FAILED',
          mimeType: 'application/pdf',
          errorCode: 'KNOWLEDGE_EXTRACTION_FAILED',
        ),
      );
    final controller = DocumentsController(api);

    final detail = await controller.loadDocumentDetail('document-1');

    expect(detail.state, DocumentDetailLoadState.failed);
    expect(detail.document.errorCode, 'KNOWLEDGE_EXTRACTION_FAILED');
  });

  test('loads existing document artifacts', () async {
    final api = FakeDocumentsApi()
      ..summariesByDocumentId['document-1'] = summary()
      ..revisionSheetsByDocumentId['document-1'] = revisionSheet();
    final controller = DocumentsController(api);

    final artifacts = await controller.loadDocumentArtifacts('document-1');

    expect(artifacts.summary?.title, 'Résumé');
    expect(artifacts.revisionSheet?.title, 'Fiche');
  });

  test('generates document artifacts through the API', () async {
    final api = FakeDocumentsApi()
      ..summariesByDocumentId['document-1'] = summary()
      ..revisionSheetsByDocumentId['document-1'] = revisionSheet();
    final controller = DocumentsController(api);

    await controller.generateDocumentSummary('document-1');
    await controller.generateRevisionSheet('document-1');

    expect(api.generateSummaryCallCount, 1);
    expect(api.generateRevisionSheetCallCount, 1);
  });
}

DocumentSummary summary() {
  return const DocumentSummary(
    id: 'summary-1',
    documentId: 'document-1',
    subjectId: 'subject-1',
    status: 'READY',
    title: 'Résumé',
    content: 'Contenu',
    keyPoints: ['Point'],
    limits: null,
    errorCode: null,
    sources: [
      DocumentArtifactSource(
        chunkId: 'chunk-1',
        text: 'Source',
        pageNumber: null,
        index: 0,
      ),
    ],
  );
}

RevisionSheet revisionSheet() {
  return const RevisionSheet(
    id: 'sheet-1',
    documentId: 'document-1',
    subjectId: 'subject-1',
    status: 'READY',
    title: 'Fiche',
    introduction: 'Intro',
    sections: [
      RevisionSheetSection(
        id: 'section-1',
        displayOrder: 0,
        title: 'Section',
        content: 'Contenu',
        sources: [
          DocumentArtifactSource(
            chunkId: 'chunk-1',
            text: 'Source',
            pageNumber: null,
            index: 0,
          ),
        ],
      ),
    ],
    keyPoints: ['Point'],
    commonMistakes: [],
    mustKnow: [],
    practiceSuggestions: [],
    errorCode: null,
  );
}

~~~

### `test/features/subjects/subject_detail_page_test.dart`

~~~text
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/app/router/app_routes.dart';
import 'package:Neralune/app/di/providers.dart';
import 'package:Neralune/features/courses/application/active_subject_provider.dart';
import 'package:Neralune/features/documents/application/documents_controller.dart';
import 'package:Neralune/features/documents/domain/revision_document.dart';
import 'package:Neralune/features/documents/domain/source_lifecycle.dart';
import 'package:Neralune/features/subjects/application/subjects_controller.dart';
import 'package:Neralune/features/subjects/domain/subject.dart';
import 'package:Neralune/features/subjects/presentation/subject_detail_page.dart';

class SingleSubjectRepository implements SubjectsRepository {
  SingleSubjectRepository({
    this.subjects = const [
      Subject(id: 'subject-1', name: 'Biologie', priority: 4),
    ],
  });

  final List<Subject> subjects;

  @override
  Future<Subject> createSubject({
    required String name,
    required int priority,
    int weeklyMinutes = 0,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteSubject(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Subject> getSubject(String id) async {
    return subjects.firstWhere((subject) => subject.id == id);
  }

  @override
  Future<List<Subject>> listSubjects() async => subjects;
}

class StaticDocumentsApi implements DocumentsApi {
  StaticDocumentsApi({this.lifecycleDecision});

  final SourceLifecycleDecision? lifecycleDecision;

  final documents = <RevisionDocument>[
    const RevisionDocument(
      id: 'document-1',
      subjectId: 'subject-1',
      kind: 'COURSE_PDF',
      fileName: 'cours.pdf',
      status: 'FAILED',
      mimeType: 'application/pdf',
      errorCode: 'KNOWLEDGE_EXTRACTION_FAILED',
    ),
  ];

  @override
  Future<RevisionDocument> getDocument({required String documentId}) {
    throw UnimplementedError();
  }

  @override
  Future<List<RevisionDocument>> listSubjectDocuments({
    required String subjectId,
  }) async {
    return documents
        .where((document) => document.subjectId == subjectId)
        .toList(growable: false);
  }

  @override
  Future<void> deleteDocument({required String documentId}) async {
    documents.removeWhere((document) => document.id == documentId);
  }

  @override
  Future<SourceLifecycleDecision> getDocumentLifecycle({
    required String documentId,
  }) async {
    return lifecycleDecision ??
        SourceLifecycleDecision(
          documentId: documentId,
          courseId: null,
          status: SourceLifecycleStatus.active,
          recommendedAction: SourceLifecycleAction.delete,
          canDelete: true,
          canArchive: true,
          blockingReasons: const [],
          userMessage: 'Cette source peut être supprimée.',
        );
  }

  @override
  Future<SourceLifecycleDecision> archiveDocument({
    required String documentId,
  }) async {
    documents.removeWhere((document) => document.id == documentId);
    return SourceLifecycleDecision(
      documentId: documentId,
      courseId: null,
      status: SourceLifecycleStatus.archived,
      recommendedAction: SourceLifecycleAction.block,
      canDelete: false,
      canArchive: false,
      blockingReasons: const ['ALREADY_ARCHIVED'],
      userMessage: 'Cette source est archivée.',
    );
  }

  @override
  Future<DocumentKnowledgeUnitsResponse> listDocumentKnowledgeUnits({
    required String documentId,
  }) async {
    return DocumentKnowledgeUnitsResponse(
      documentId: documentId,
      items: const [],
    );
  }

  @override
  Future<DocumentSummary?> getDocumentSummary({
    required String documentId,
  }) async {
    return null;
  }

  @override
  Future<DocumentSummary> generateDocumentSummary({
    required String documentId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<RevisionSheet?> getRevisionSheet({required String documentId}) async {
    return null;
  }

  @override
  Future<RevisionSheet> generateRevisionSheet({required String documentId}) {
    throw UnimplementedError();
  }

  @override
  Future<RevisionDocument> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('shows a readable reason for failed AI processing', (
    tester,
  ) async {
    final documentsApi = StaticDocumentsApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [documentsApiProvider.overrideWithValue(documentsApi)],
        child: MaterialApp(
          home: Scaffold(
            body: SubjectDetailPage(
              subjectId: 'subject-1',
              controller: SubjectsController(SingleSubjectRepository()),
              documentsController: DocumentsController(documentsApi),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('cours.pdf'), findsOneWidget);
    expect(find.textContaining('Erreur IA'), findsOneWidget);
  });

  testWidgets('opens document detail when tapping a document', (tester) async {
    final documentsApi = StaticDocumentsApi();
    final router = GoRouter(
      initialLocation: '/subjects/subject-1',
      routes: [
        GoRoute(
          path: '/subjects/:subjectId',
          builder: (context, state) => SubjectDetailPage(
            subjectId: state.pathParameters['subjectId'] ?? '',
            controller: SubjectsController(SingleSubjectRepository()),
            documentsController: DocumentsController(documentsApi),
          ),
          routes: [
            GoRoute(
              path: 'documents/:documentId',
              builder: (context, state) =>
                  Text('Document ${state.pathParameters['documentId']}'),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [documentsApiProvider.overrideWithValue(documentsApi)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('cours.pdf'));
    await tester.pumpAndSettle();

    expect(find.text('Document document-1'), findsOneWidget);
  });

  testWidgets('opens the canonical revision hub from the subject detail CTA', (
    tester,
  ) async {
    final documentsApi = StaticDocumentsApi();
    final router = GoRouter(
      initialLocation: '/subjects/subject-1',
      routes: [
        GoRoute(
          path: '/subjects/:subjectId',
          builder: (context, state) => SubjectDetailPage(
            subjectId: state.pathParameters['subjectId'] ?? '',
            controller: SubjectsController(SingleSubjectRepository()),
            documentsController: DocumentsController(documentsApi),
          ),
        ),
        GoRoute(
          path: AppRoutes.revisions,
          builder: (context, state) => const Text('Hub Réviser canonique'),
        ),
        GoRoute(
          path: AppRoutes.activities,
          builder: (context, state) => const Text('Activités legacy'),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [documentsApiProvider.overrideWithValue(documentsApi)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Réviser'));
    await tester.pumpAndSettle();

    expect(find.text('Hub Réviser canonique'), findsOneWidget);
    expect(find.text('Activités legacy'), findsNothing);
    expect(router.routeInformationProvider.value.uri.path, AppRoutes.revisions);
  });

  testWidgets(
    'selects the displayed subject before opening the canonical revision hub',
    (tester) async {
      final documentsApi = StaticDocumentsApi();
      final subjectsRepository = SingleSubjectRepository(
        subjects: const [
          Subject(id: 'subject-1', name: 'Biologie', priority: 4),
          Subject(id: 'subject-2', name: 'Japonais', priority: 2),
        ],
      );
      final router = GoRouter(
        initialLocation: '/subjects/subject-2',
        routes: [
          GoRoute(
            path: '/subjects/:subjectId',
            builder: (context, state) => SubjectDetailPage(
              subjectId: state.pathParameters['subjectId'] ?? '',
              controller: SubjectsController(subjectsRepository),
              documentsController: DocumentsController(documentsApi),
            ),
          ),
          GoRoute(
            path: AppRoutes.revisions,
            builder: (context, state) => Consumer(
              builder: (context, ref, child) {
                final activeSubject = ref.watch(activeSubjectProvider);
                return activeSubject.when(
                  data: (subject) => Text(subject?.name ?? 'Aucune matière'),
                  loading: () => const Text('Chargement'),
                  error: (error, stackTrace) => const Text('Erreur'),
                );
              },
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            subjectsRepositoryProvider.overrideWithValue(subjectsRepository),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Réviser'));
      await tester.pumpAndSettle();

      expect(find.text('Japonais'), findsOneWidget);
      expect(find.text('Biologie'), findsNothing);
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.revisions,
      );
    },
  );

  testWidgets('deletes a document after confirmation', (tester) async {
    final documentsApi = StaticDocumentsApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [documentsApiProvider.overrideWithValue(documentsApi)],
        child: MaterialApp(
          home: Scaffold(
            body: SubjectDetailPage(
              subjectId: 'subject-1',
              controller: SubjectsController(SingleSubjectRepository()),
              documentsController: DocumentsController(documentsApi),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('cours.pdf'), findsOneWidget);

    await tester.tap(find.byTooltip('Supprimer la source'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();

    expect(documentsApi.documents, isEmpty);
    expect(find.text('cours.pdf'), findsNothing);
  });

  testWidgets('archives a used document instead of deleting it', (
    tester,
  ) async {
    final documentsApi = StaticDocumentsApi(
      lifecycleDecision: const SourceLifecycleDecision(
        documentId: 'document-1',
        courseId: null,
        status: SourceLifecycleStatus.active,
        recommendedAction: SourceLifecycleAction.archive,
        canDelete: false,
        canArchive: true,
        blockingReasons: ['HAS_KNOWLEDGE_UNITS'],
        userMessage: 'Cette source peut être archivée.',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [documentsApiProvider.overrideWithValue(documentsApi)],
        child: MaterialApp(
          home: Scaffold(
            body: SubjectDetailPage(
              subjectId: 'subject-1',
              controller: SubjectsController(SingleSubjectRepository()),
              documentsController: DocumentsController(documentsApi),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Supprimer la source'));
    await tester.pumpAndSettle();

    expect(find.text('Archiver la source ?'), findsOneWidget);
    expect(find.textContaining('historique déjà créé'), findsOneWidget);

    await tester.tap(find.text('Archiver'));
    await tester.pumpAndSettle();

    expect(documentsApi.documents, isEmpty);
    expect(find.text('cours.pdf'), findsNothing);
  });
}

~~~
