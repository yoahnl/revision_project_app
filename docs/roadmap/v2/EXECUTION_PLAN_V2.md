# Execution Plan V2

Ce document découpe les macro-lots de `REVISION_PROJECT_ROADMAP_V2.md` en lots réellement exécutables.

Les macro-lots ne disparaissent pas : ils restent la lecture stratégique. Ce plan sert à piloter l'exécution sans transformer un prompt en chantier incontrôlable.

## Horizons

- `FOUNDATION` : gouvernance, roadmap, CI, preuves minimales.
- `MVP_STABLE` : stabilisation du MVP Core réel déjà livré.
- `MVP_PLUS` : fonctionnalités produit au-dessus du MVP stable.
- `POST_MVP` : extensions plus ambitieuses ou différenciantes.
- `RELEASE` : préparation production.

## Graphe de dépendances exécutable

```text
STAB-00
-> STAB-00B

STAB-00B
-> QUALITY-00
-> STAB-01A

STAB-01A
-> STAB-01B
-> CORE-09A

STAB-01B
-> STAB-01C

STAB-01C
-> STAB-02A

STAB-02A
-> STAB-02B

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

PLUS-01A
-> PLUS-01B

STAB-02B + CORE-09A
-> PLUS-02

PLUS-01B + PLUS-02 + CORE-11B
-> PLUS-03

STAB-02B + ADAPT-01 + PLUS-01A
-> GENUI-01

QUALITY-00 + lots MVP_STABLE requis
-> RELEASE-01
```

## Travaux parallélisables

- `QUALITY-00` et `STAB-01A` peuvent avancer en parallèle après `STAB-00B`.
- `STAB-01B` et `CORE-09A` peuvent avancer en parallèle après `STAB-01A`.
- `STAB-02A` et `CORE-10A` peuvent avancer en parallèle lorsque leurs dépendances respectives sont remplies.
- `PLUS-02` n'a pas besoin d'attendre toute la Deep Revision.
- `PLUS-01A` n'a pas besoin d'attendre tout l'historique `CORE-11B`.

## STAB-00B — Roadmap V2 hardening

### Parent macro-lot
STAB-00.

### Horizon
FOUNDATION.

### Objectif
Durcir la Roadmap V2, créer les lots exécutables, ajouter les horizons, le journal de décisions, la baseline CI future et les règles d'agrégation.

### Pourquoi maintenant
Les macro-lots sont validés mais trop gros pour piloter l'exécution lot par lot.

### Repos concernés
App + API.

### Dépendances strictes
STAB-00.

### Travaux parallélisables
Aucun pendant le lot documentaire.

### Backend scope
Documentation API roadmap seulement.

### Frontend scope
Documentation produit, UX et exécution.

### UX scope
Clarifier les capacités disponibles, futures ou dépendantes d'API.

### Tests attendus
Validations documentaires : fichiers présents, IDs, horizons, statuts de décisions, `git diff --check`.

### Critères d'acceptation
Les trackers app/API sont synchronisés, `QUALITY-00` existe, `REPLACED` est défini, `MVP_STABLE` est explicite.

### Non-objectifs
Aucune feature, aucun runtime, aucune CI réelle.

### Risques
Créer trop de duplication entre les repos.

### Rapport attendu
`docs/roadmap/v2/STAB_00B_ROADMAP_V2_HARDENING_REPORT.md`.

## QUALITY-00 — CI baseline

### Parent macro-lot
QUALITY-00.

### Horizon
FOUNDATION.

### Objectif
Installer une baseline CI qui prouve analyse Flutter, tests Flutter, build/lint/tests API, Prisma validate, e2e critiques et format/diff.

### Pourquoi maintenant
Les refactors STAB-01/STAB-02 et les durcissements backend doivent être protégés avant d'avancer.

### Repos concernés
App + API.

### Dépendances strictes
STAB-00B.

### Travaux parallélisables
STAB-01A peut avancer en parallèle si le scope est coordonné.

### Backend scope
Jobs CI pour `npx prisma validate`, build, lint, tests Jest ciblés et e2e critiques.

### Frontend scope
Jobs CI pour `dart analyze`, tests Flutter ciblés et smoke routeur.

### UX scope
Aucun changement runtime.

### Tests attendus
Validation de la CI sur PR ou branche de test.

### Critères d'acceptation
Une PR ne peut plus être considérée fiable sans preuve automatisée minimale.

### Non-objectifs
Monitoring production, secrets complets, release pipeline.

### Risques
CI macOS/iOS plus lente ou fragile si elle est trop ambitieuse dès V0.

### Rapport attendu
Rapport QUALITY-00 dans les deux repos si les workflows touchent les deux.

## STAB-01A — Shell, navigation & scaffold coherence

### Parent macro-lot
STAB-01.

### Horizon
MVP_STABLE.

### Objectif
Corriger la structure globale : shell, navigation, stack arrière, scaffolds, scrolls, headers et immersion des sessions.

### Pourquoi maintenant
Le produit fonctionne, mais la navigation peut encore donner une impression instable ou web.

### Repos concernés
App.

### Dépendances strictes
STAB-00B.

### Travaux parallélisables
QUALITY-00.

### Backend scope
Aucun.

### Frontend scope
GoRouter, shell, bottom navigation, règles de scroll, pages immersives.

### UX scope
Décider si la navigation cible passe à quatre onglets et comment Sources est exposé.

### Tests attendus
Tests routeur, back navigation, bottom nav, sessions sans bottom nav.

### Critères d'acceptation
Le retour arrière ne push plus de nouvelles pages, les headers restent cohérents, les sessions sont immersives.

### Non-objectifs
Nouvelle API, refonte complète des pages.

### Risques
Changer le shell peut casser des routes legacy si le périmètre n'est pas tenu.

### Rapport attendu
Rapport STAB-01A côté app.

## STAB-01B — Home, Revision Hub & Course action hierarchy

### Parent macro-lot
STAB-01.

### Horizon
MVP_STABLE.

### Objectif
Rendre les entrées principales actionnables : Home, Hub Révisions et actions du détail cours.

### Pourquoi maintenant
Une destination principale doit permettre une action principale claire.

### Repos concernés
App.

### Dépendances strictes
STAB-01A.

### Travaux parallélisables
CORE-09A.

### Backend scope
Aucun.

### Frontend scope
Home centrée matière active, hub révisions direct, action quick, fiche, sources.

### UX scope
Remplacer les labels techniques ou internes par du wording utilisateur.

### Tests attendus
Widget tests Home, Hub, Course detail, anti-fixtures.

### Critères d'acceptation
Aucun onglet principal ne mène à une impasse et aucun mode visible ne ment.

### Non-objectifs
Deep/exam réels, Today adaptatif.

### Risques
Montrer trop de boutons verrouillés au lieu de clarifier le parcours.

### Rapport attendu
Rapport STAB-01B côté app.

## STAB-01C — Sheet, Progress, wording & subject discoverability

### Parent macro-lot
STAB-01.

### Horizon
MVP_STABLE.

### Objectif
Nettoyer fiche, progrès, wording, choix/création de matière et capacités qui nécessitent une API.

### Pourquoi maintenant
L'UX affiche encore des actions souhaitables qui ne sont pas toutes disponibles côté backend.

### Repos concernés
App + API si un ajustement minimal de contrat est validé.

### Dépendances strictes
STAB-01B.

### Travaux parallélisables
Aucun.

### Backend scope
Seulement si une action `NEEDS_API` est explicitement incluse ; sinon aucun.

### Frontend scope
Fiche plus lisible, sources en page ou sheet dédiée, progression clarifiée, création matière accessible.

### UX scope
Ne pas afficher de capacité `NEEDS_API` comme disponible.

### Tests attendus
Tests fiche, progrès, matière, anti-wording technique.

### Critères d'acceptation
La progression n'est plus confondue avec le statut des sources et la gestion matière est découvrable.

### Non-objectifs
Fiche complète, examen, édition complète de cours sans API.

### Risques
Ajouter des boutons qui attendent une API non livrée.

### Rapport attendu
Rapport STAB-01C côté app et API si touché.

## STAB-02A — Premium migration of Auth, Onboarding, Profile & Subjects

### Parent macro-lot
STAB-02.

### Horizon
MVP_STABLE.

### Objectif
Migrer les surfaces legacy vers la direction premium sans changer les contrats.

### Pourquoi maintenant
Deux directions visuelles coexistent encore.

### Repos concernés
App.

### Dépendances strictes
STAB-01C.

### Travaux parallélisables
CORE-10A si CORE-09A est terminé.

### Backend scope
Aucun.

### Frontend scope
Auth, onboarding, profil, matières legacy.

### UX scope
Unifier les empty/loading/error states.

### Tests attendus
Widget tests des pages migrées et routes.

### Critères d'acceptation
L'application ne donne plus l'impression de deux produits accolés.

### Non-objectifs
Nouvelles capacités profil ou compte.

### Risques
Toucher trop d'écrans en un seul diff.

### Rapport attendu
Rapport STAB-02A côté app.

## STAB-02B — Feature extraction, route isolation & legacy deprecation

### Parent macro-lot
STAB-02.

### Horizon
MVP_STABLE.

### Objectif
Extraire les widgets réutilisables vers `presentation/widgets`, isoler les routes legacy et documenter les dépréciations.

### Pourquoi maintenant
L'architecture de présentation doit redevenir lisible avant les modes avancés.

### Repos concernés
App.

### Dépendances strictes
STAB-02A.

### Travaux parallélisables
Aucun.

### Backend scope
Aucun.

### Frontend scope
Organisation Flutter, widgets communs, routes legacy.

### UX scope
Éviter que les anciennes pages soient prises pour le parcours principal.

### Tests attendus
Analyse Dart, tests routeur/app, tests pages déplacées.

### Critères d'acceptation
Les composants réutilisables sont centralisés et les pages feature ne dupliquent plus le design system.

### Non-objectifs
Refonte comportementale ou suppression brutale de legacy.

### Risques
Gros déplacement de fichiers difficile à relire sans CI.

### Rapport attendu
Rapport STAB-02B côté app.

## CORE-09A — Source archive/delete semantics

### Parent macro-lot
CORE-09.

### Horizon
MVP_STABLE.

### Objectif
Définir et implémenter la règle : une source utilisée par l'historique pédagogique ne doit pas être supprimée naïvement.

### Pourquoi maintenant
La suppression actuelle peut devenir dangereuse après sessions, fiches et question bank.

### Repos concernés
App + API.

### Dépendances strictes
STAB-01A.

### Travaux parallélisables
STAB-01B.

### Backend scope
Statuts archive/delete, ownership, refus ou archivage selon usage.

### Frontend scope
Confirmation et wording honnête.

### UX scope
Expliquer "retirer du cours" sans promettre suppression définitive.

### Tests attendus
Tests Prisma/repository/use case/controller/e2e et widget delete.

### Critères d'acceptation
Une source utilisée reste traçable et ne casse pas un résultat existant.

### Non-objectifs
Stockage cloud complet.

### Risques
Migration nécessaire si le modèle actuel ne porte pas le statut.

### Rapport attendu
Rapports CORE-09A app/API.

## CORE-09B — Blob cleanup & storage abstraction

### Parent macro-lot
CORE-09.

### Horizon
MVP_STABLE.

### Objectif
Clarifier stockage local/cloud et cleanup des blobs quand la suppression réelle est autorisée.

### Pourquoi maintenant
Le stockage local ne suffit pas à une production durable.

### Repos concernés
API.

### Dépendances strictes
CORE-09A.

### Travaux parallélisables
CORE-09C.

### Backend scope
Abstraction storage, cleanup idempotent, documentation env.

### Frontend scope
Aucun.

### UX scope
Aucun changement visible sauf messages d'erreur si cleanup échoue.

### Tests attendus
Unit tests storage, use cases delete/archive, erreurs cleanup.

### Critères d'acceptation
Le stockage est remplaçable sans changer les use cases produit.

### Non-objectifs
Migration cloud complète si secrets infra non disponibles.

### Risques
Orphelins historiques à traiter plus tard.

### Rapport attendu
Rapport CORE-09B API.

## CORE-09C — Subject and course lifecycle APIs

### Parent macro-lot
CORE-09.

### Horizon
MVP_STABLE.

### Objectif
Ajouter les APIs nécessaires aux capacités UX `NEEDS_API` : renommer/éditer/archiver matière et cours.

### Pourquoi maintenant
Le frontend ne doit pas afficher ces actions sans contrat backend.

### Repos concernés
App + API.

### Dépendances strictes
CORE-09A.

### Travaux parallélisables
CORE-09B.

### Backend scope
Routes lifecycle, ownership, conflits si données liées.

### Frontend scope
Formulaires et actions seulement pour les contrats livrés.

### UX scope
Gestion matière/cours complète mais sobre.

### Tests attendus
Auth/404/409/happy path et widget tests.

### Critères d'acceptation
Les actions de gestion visibles ont toutes une API réelle.

### Non-objectifs
Organisation multi-utilisateur ou partage.

### Risques
Trop élargir vers administration complète.

### Rapport attendu
Rapports CORE-09C app/API.

## CORE-10A — Async question bank readiness

### Parent macro-lot
CORE-10.

### Horizon
MVP_STABLE.

### Objectif
Sortir la préparation de question bank du démarrage quick synchrone.

### Pourquoi maintenant
Les providers IA peuvent échouer ou ralentir ; le quick doit rester fiable.

### Repos concernés
App + API.

### Dépendances strictes
CORE-09A.

### Travaux parallélisables
STAB-02A.

### Backend scope
Statut readiness, jobs, retry, fallback provider.

### Frontend scope
États "questions en préparation" et relance honnête.

### UX scope
Ne pas bloquer l'utilisateur dans un loader long sans information.

### Tests attendus
Jobs, repository, controller, e2e quick readiness, widgets.

### Critères d'acceptation
Démarrer une révision ne dépend plus d'une génération IA longue en ligne.

### Non-objectifs
Moteur adaptatif complet.

### Risques
Complexité worker/concurrence.

### Rapport attendu
Rapports CORE-10A app/API.

## CORE-10B — Multi-KU selection & concurrency hardening

### Parent macro-lot
CORE-10.

### Horizon
MVP_STABLE.

### Objectif
Équilibrer la sélection entre notions, difficulté et historique tout en évitant les réservations concurrentes.

### Pourquoi maintenant
La banque ne doit pas tourner autour d'une seule notion ou reposer toujours les mêmes questions.

### Repos concernés
API.

### Dépendances strictes
CORE-10A.

### Travaux parallélisables
CORE-11A.

### Backend scope
Sélection multi-KU, locks ou stratégie anti-double réservation, askedCount fiable.

### Frontend scope
Aucun sauf affichage des erreurs existantes.

### UX scope
Questions plus variées sans réglages utilisateur compliqués.

### Tests attendus
Repository Prisma, concurrence simulée, distribution.

### Critères d'acceptation
Deux démarrages proches ne sélectionnent pas naïvement le même lot.

### Non-objectifs
Spaced repetition complet.

### Risques
Verrouillage DB trop complexe ou non portable.

### Rapport attendu
Rapport CORE-10B API.

## CORE-10C — Question bank clean architecture & quality metrics

### Parent macro-lot
CORE-10.

### Horizon
MVP_STABLE.

### Objectif
Découpler `QuestionBankService`, ajouter métriques coût/qualité et améliorer le signalement.

### Pourquoi maintenant
Le service est critique et ne doit pas devenir un blob Prisma.

### Repos concernés
API.

### Dépendances strictes
CORE-10B.

### Travaux parallélisables
ADAPT-01.

### Backend scope
Ports dédiés, mappers, métriques, raisons de flag.

### Frontend scope
Éventuellement catégories simples de signalement si API prête.

### UX scope
Signaler une question devient plus utile sans exposer des détails techniques.

### Tests attendus
Unit tests purs, repository tests, e2e non-régression quick.

### Critères d'acceptation
La banque est maintenable et mesurable.

### Non-objectifs
Dashboard admin complet.

### Risques
Refactor trop large si non borné.

### Rapport attendu
Rapports CORE-10C selon repos touchés.

## CORE-11A — Session draft persistence & resume

### Parent macro-lot
CORE-11.

### Horizon
MVP_STABLE.

### Objectif
Persister les réponses partielles et permettre la reprise d'une session commencée.

### Pourquoi maintenant
Un flow mobile doit survivre à la fermeture ou au changement de page.

### Repos concernés
App + API.

### Dépendances strictes
CORE-10A.

### Travaux parallélisables
CORE-10B, PLUS-01A.

### Backend scope
Draft answers, ownership, lifecycle idempotent.

### Frontend scope
Sauvegarde locale/serveur selon contrat et écran "continuer".

### UX scope
Ne jamais perdre silencieusement une session.

### Tests attendus
Lifecycle, abandon/reprise, route guards.

### Critères d'acceptation
Une session incomplète peut être reprise sans recréer un quiz.

### Non-objectifs
Historique complet de toutes les sessions.

### Risques
Conflit entre draft et submit final.

### Rapport attendu
Rapports CORE-11A app/API.

## CORE-11B — Session history & completed session details

### Parent macro-lot
CORE-11.

### Horizon
MVP_STABLE.

### Objectif
Créer l'historique et le détail des sessions terminées.

### Pourquoi maintenant
Les résultats existent mais ne sont pas encore organisés en historique produit.

### Repos concernés
App + API.

### Dépendances strictes
CORE-11A.

### Travaux parallélisables
Aucun.

### Backend scope
Listes filtrées, détails, ownership.

### Frontend scope
Historique, détails, retours depuis progression/cours.

### UX scope
Comprendre ce qui a été travaillé et quand.

### Tests attendus
List/detail auth/404/happy path, widget route tests.

### Critères d'acceptation
Un quiz terminé ne se rouvre pas comme une session active.

### Non-objectifs
Analytics avancés.

### Risques
Confondre historique pédagogique et progression globale.

### Rapport attendu
Rapports CORE-11B app/API.

## PLUS-01A — Course Deep Revision open-question V1

### Parent macro-lot
PLUS-01.

### Horizon
MVP_PLUS.

### Objectif
Activer une première révision approfondie course-level basée sur question ouverte.

### Pourquoi maintenant
Le quick est stabilisé ; l'utilisateur peut passer à un mode plus profond.

### Repos concernés
App + API.

### Dépendances strictes
STAB-02A, CORE-10A, quick lifecycle stable.

### Travaux parallélisables
CORE-11A.

### Backend scope
Route deep course-level, sélection source/KU backend, action `OPEN_QUESTION`.

### Frontend scope
UI premium question ouverte course-level.

### UX scope
Présenter Deep comme différent de Quick, sans promettre exam.

### Tests attendus
Auth/ownership, start deep, submit correction, mastery update si inclus.

### Critères d'acceptation
Deep V1 existe sans dépendre de tout l'historique CORE-11B.

### Non-objectifs
Résultat deep complet si repoussé à PLUS-01B.

### Risques
Réutiliser trop de legacy sans harmoniser le lifecycle.

### Rapport attendu
Rapports PLUS-01A app/API.

## PLUS-01B — Deep lifecycle, completion & result

### Parent macro-lot
PLUS-01.

### Horizon
MVP_PLUS.

### Objectif
Compléter le lifecycle Deep avec completion et résultat.

### Pourquoi maintenant
Deep V1 doit devenir un flow complet, pas juste une activité isolée.

### Repos concernés
App + API.

### Dépendances strictes
PLUS-01A, CORE-11A.

### Travaux parallélisables
Aucun.

### Backend scope
Completion/result deep, agrégation feedback, ownership.

### Frontend scope
Résultat Deep lisible et retour progression.

### UX scope
Feedback immédiat et conseils sans coach adaptatif complet.

### Tests attendus
Repository lifecycle, controller, e2e, widget result.

### Critères d'acceptation
Deep a un début, une réponse, une correction et une fin.

### Non-objectifs
Mode examen.

### Risques
Score IA à calibrer.

### Rapport attendu
Rapports PLUS-01B app/API.

## PLUS-02 — Complete and pre-exam revision sheets

### Parent macro-lot
PLUS-02.

### Horizon
MVP_PLUS.

### Objectif
Remplacer les faux onglets de fiche par de vrais contenus.

### Pourquoi maintenant
Les onglets `Complète` et `Examen` ne doivent pas rester des promesses vides.

### Repos concernés
App + API.

### Dépendances strictes
STAB-02B, CORE-09A.

### Travaux parallélisables
PLUS-01A.

### Backend scope
Génération/récupération fiche complète et pré-examen, versioning.

### Frontend scope
Tabs réels ou masquage selon disponibilité.

### UX scope
Fiches lisibles, sources consultables, aucun contenu inventé.

### Tests attendus
Study artifacts, endpoints, widgets sheet.

### Critères d'acceptation
Chaque onglet visible correspond à un contenu réel ou est clairement verrouillé.

### Non-objectifs
Mode examen complet.

### Risques
Coût IA et temps de génération.

### Rapport attendu
Rapports PLUS-02 app/API.

## ADAPT-01 — Today and adaptive coach

### Parent macro-lot
ADAPT-01.

### Horizon
MVP_PLUS.

### Objectif
Créer une vraie page Today avec prochaine action recommandée.

### Pourquoi maintenant
Le produit a besoin de guider l'utilisateur, pas seulement d'exposer des écrans.

### Repos concernés
App + API.

### Dépendances strictes
CORE-10B.

### Travaux parallélisables
CORE-10C.

### Backend scope
Read model de recommandation, notion due, raisons pédagogiques.

### Frontend scope
Page Today et CTA vers cours/session/fiche.

### UX scope
Recommandation honnête, pas de "reprendre" si le système ne sait pas.

### Tests attendus
Use cases recommendation, widget states, anti-fake.

### Critères d'acceptation
Today peut devenir accueil seulement si la recommandation est réelle.

### Non-objectifs
Gamification complète.

### Risques
Moteur trop ambitieux pour V1.

### Rapport attendu
Rapports ADAPT-01 app/API.

## PLUS-03 — Exam preparation V1

### Parent macro-lot
PLUS-03.

### Horizon
POST_MVP.

### Objectif
Créer un mode préparation examen réel.

### Pourquoi maintenant
Après Deep, fiches complètes et historique, le modèle pédagogique a assez de contexte.

### Repos concernés
App + API.

### Dépendances strictes
PLUS-01B, PLUS-02, CORE-11B.

### Travaux parallélisables
Aucun.

### Backend scope
Sources examen, session chronométrée, résultats distincts.

### Frontend scope
Mode exam, session, résultat, points faibles.

### UX scope
Ne pas mélanger entraînement court et simulation examen.

### Tests attendus
Lifecycle exam, scoring, e2e, widget tests.

### Critères d'acceptation
Exam est un vrai mode, pas une variation de Quick.

### Non-objectifs
Correction humaine ou import automatique d'annales sans source.

### Risques
Complexité pédagogique et coût IA.

### Rapport attendu
Rapports PLUS-03 app/API.

## GENUI-01 — Controlled GenUI surface

### Parent macro-lot
GENUI-01.

### Horizon
POST_MVP.

### Objectif
Réintroduire GenUI sous forme de widgets autorisés et validés.

### Pourquoi maintenant
GenUI ne doit revenir qu'après stabilisation des flows principaux.

### Repos concernés
App + API.

### Dépendances strictes
STAB-02B, ADAPT-01, PLUS-01A.

### Travaux parallélisables
Aucun.

### Backend scope
Payloads typés, validation, fallback.

### Frontend scope
Catalogue `SummaryCard`, `SourceExcerptCard`, `McqQuestionCard`, `OpenQuestionCard`, `CorrectionPanel`, `NextActionCard`, `WeaknessCard`.

### UX scope
Surface contrôlée, jamais UI arbitraire.

### Tests attendus
Validation payload, snapshot/widget fallbacks.

### Critères d'acceptation
Un payload invalide ne casse pas l'écran.

### Non-objectifs
Génération libre d'interface.

### Risques
Complexité de versioning.

### Rapport attendu
Rapports GENUI-01 app/API.

## RELEASE-01 — Production readiness

### Parent macro-lot
RELEASE-01.

### Horizon
RELEASE.

### Objectif
Préparer la production : CI complète, stockage, secrets, monitoring, quotas IA, analytics, crash reporting, accessibilité, politique données.

### Pourquoi maintenant
Seulement lorsque le MVP stable est démontrable.

### Repos concernés
App + API.

### Dépendances strictes
QUALITY-00 et lots MVP_STABLE requis.

### Travaux parallélisables
Aucun.

### Backend scope
Infra, env, monitoring, tests DB/Redis/worker, sécurité.

### Frontend scope
Builds release, crash reporting, accessibilité, stores si pertinent.

### UX scope
Accessibilité et confiance utilisateur.

### Tests attendus
Suites complètes reproductibles, smoke prod-like.

### Critères d'acceptation
Le projet peut être déployé et surveillé sans bricolage manuel.

### Non-objectifs
Nouvelles fonctionnalités produit majeures.

### Risques
Sous-estimer le coût infra/secrets/conformité.

### Rapport attendu
Rapports RELEASE-01 app/API.

## MVP_STABLE

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
