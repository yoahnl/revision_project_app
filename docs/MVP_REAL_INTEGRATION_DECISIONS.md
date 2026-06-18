# MVP Real Integration — Décisions structurantes

## Décision 1 — Modèle Course / Source

Choix retenu :
MVP Core avec `Course` + `Document.courseId`. Pas de `CourseSource` dans le coeur MVP.

Alternatives :
`CourseSource` comme table de liaison entre cours et documents.

Pourquoi :
Le MVP n'a pas encore de besoin prouvé de partage d'un même PDF entre plusieurs cours. `Document.courseId` réduit les jointures, simplifie l'upload, simplifie l'ownership et limite les incohérences.

Impact :
Un document appartient à un seul cours. L'upload sous cours crée un document déjà attaché. Le backend doit vérifier que le cours, la matière et l'utilisateur correspondent avant tout attachement.

À revoir après MVP :
Si le produit exige partage de sources, rôles avancés ou composition multi-source, introduire `CourseSource` en MVP+.

## Décision 2 — Portée MVP Core vs MVP+

Choix retenu :
Séparer strictement MVP Core et MVP+.

Inclus MVP Core :
Utilisateur authentifié, matières réelles, cours réels, PDF réels, upload réel, processing réel, fiche minimale source principale, révision rapide réelle, résultat réel, progression réelle minimale, suppression des fixtures métier en production.

Repoussé MVP+ :
Révision approfondie, préparation examen, fiches multi-source, source roles `NOTES`/`EXAM`/`CORRECTION`, gamification, badges, streak, gems, cleanup legacy complet.

Pourquoi :
Le plan précédent ressemblait à une V1 complète. Le MVP doit d'abord prouver le parcours réel de bout en bout.

## Décision 3 — Cycle de vie RevisionSession

Choix retenu :
Le backend avance la session via `POST /revision-sessions/:sessionId/advance` après vérification d'un résultat d'activité persisté.

Endpoints :
`POST /revision-sessions`, `GET /revision-sessions/:sessionId`, `POST /revision-sessions/:sessionId/advance`, `GET /revision-sessions/:sessionId/result`.

Pourquoi :
Le frontend ne doit pas pouvoir déclarer une action terminée sans preuve métier. `advance` centralise la validation, la transition d'état et la fin de session quick.

Risques :
Les actions rich closed actuelles peuvent avoir `activitySessionId = null`. Le MVP doit créer ou lier l'activité avant `advance`, sinon `advance` refuse.

## Décision 4 — Modes de révision

Choix retenu :
Seul `quick` est disponible dans le MVP Core.

Quick :
Une action, cinq questions fermées ou rich closed court, feedback immédiat, résultat simple.

Deep :
MVP+, visible désactivé avec badge `Bientôt` ou masqué.

Exam :
MVP+, visible désactivé avec badge `Bientôt` ou masqué, activable seulement avec sources d'examen.

Pourquoi :
Un seul mode réel réduit le périmètre et rend le cycle session testable.

## Décision 5 — Fiche de révision

Choix retenu :
Utiliser la fiche de la source principale pour le MVP Core.

Pourquoi :
C'est la stratégie la moins coûteuse, la plus testable, et elle réutilise les artifacts document-level existants.

Limites :
Une fiche ne synthétise pas encore toutes les sources du cours.

Post-MVP :
Ajouter composition multi-source ou artifact course-level IA si le besoin pédagogique le justifie.

## Décision 6 — Progression

Choix retenu :
Séparer couverture et maîtrise.

Formules :
`coverage = practicedKnowledgeUnitCount / knowledgeUnitCount`
`mastery = average(MasteryState.score for practiced units)`
`estimatedGlobalMastery = coverage * mastery`

UI :
Les cards affichent une maîtrise estimée seulement quand il existe de la pratique. La page Progrès affiche couverture, maîtrise sur notions travaillées et estimation globale séparément.

Limites :
L'estimation globale reste prudente et dépend de la qualité des knowledge units extraites.

## Décision 7 — Streak / gems / gamification

Choix retenu :
Hors MVP Core.

Pourquoi :
Les valeurs actuelles sont mockées (`12`, `870`, `7 jours`). Les afficher en production ferait mentir l'interface.

Post-MVP :
Ajouter streak, gems, badges et récompenses après le parcours réel de base.

## Décision 8 — Fixtures / mocks

Choix retenu :
Ne pas créer ni maintenir de mode démo produit.

Pourquoi :
Le produit cible est le parcours réel. Les fixtures peuvent aider les tests, previews ou développements locaux, mais elles ne doivent pas devenir un mode utilisateur ou une branche durable de l'application.

Règle production :
Aucun fallback silencieux vers `MvpStudyController.instance`, `mvpSubjects`, `mvpSessionQuestions`, score `78%`, streak `12` ou gems `870`.
