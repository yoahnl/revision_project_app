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

État CORE-09 : les sources utilisées sont archivées logiquement et les listes actives les excluent ; le cleanup blob/storage post-delete est traité côté API ; les matières et cours disposent maintenant de rename, archive logique et suppression safe pour les éléments vides.

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
