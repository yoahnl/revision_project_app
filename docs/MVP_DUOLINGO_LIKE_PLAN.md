# Revision Project — MVP Duolingo-like depuis fichiers importés

Ce document est un plan de transformation. Il ne contient pas d'implementation, ne modifie pas les routes, ne propose pas de migration executable et ne remplace pas le systeme existant. Il sert a cadrer les lots MVP a venir pour passer d'une application encore centree sur les sujets, documents et activites techniques vers une experience mobile premium ou l'utilisateur revise des cours generes depuis ses propres fichiers.

References visuelles fournies et prises comme direction produit, sans copie litterale :

- `/Users/karim/Downloads/ChatGPT Image Jun 17, 2026, 12_19_27 AM (2).png`
- `/Users/karim/Downloads/ChatGPT Image Jun 17, 2026, 12_19_27 AM (1).png`
- `/Users/karim/Downloads/ChatGPT Image Jun 17, 2026, 12_06_07 AM.png`

## 1. Vision MVP

Le MVP doit transformer des fichiers importes par l'utilisateur en un parcours de revision actif. L'utilisateur ne doit plus avoir l'impression de gerer des documents techniques, mais de travailler une matiere, puis des cours ou chapitres concrets. Le PDF reste present, mais comme source attachee a un cours, pas comme objet central de navigation.

L'experience cible met une seule matiere active au premier plan. L'utilisateur ouvre l'app, voit par exemple `Math`, reprend le cours recommande, consulte les cours de cette matiere, ouvre les sources d'un cours, lit une fiche rapide, lance une courte session de revision, puis voit un resultat clair et une progression mise a jour.

Le MVP doit rester volontairement simple :

- pas de moteur pedagogique parfait ;
- pas de generation IA nouvelle partout ;
- pas de matieres intelligentes totalement autonomes ;
- pas de refonte profonde du backend en une fois ;
- priorite a une experience lisible, coherente et demonstrable ;
- priorite a un design system Flutter reutilisable avant de refaire chaque ecran.

La promesse MVP est donc : `Subject -> Course -> Sources -> Fiche -> Revision -> Resultat -> Progression`, avec une UI mobile dark premium, gamifiee sans infantiliser, et assez robuste pour servir de base aux lots suivants.

## 2. Etat actuel reel du code

### 2.1 Sources inspectees

Frontend Flutter inspecte dans `/Users/karim/Project/app-révision/revision_app` :

- `lib/app/router/app_routes.dart`
- `lib/app/router/app_router.dart`
- `lib/presentation/shell/revision_home_shell.dart`
- `lib/presentation/pages/subjects/subjects_home_page.dart`
- `lib/presentation/pages/subjects/subject_detail_page.dart`
- `lib/presentation/pages/documents/document_detail_page.dart`
- `lib/presentation/pages/today/today_page.dart`
- `lib/presentation/pages/activities/activities_page.dart`
- `lib/presentation/pages/activities/rich_closed_exercise_page.dart`
- `lib/presentation/pages/revision_sessions/revision_session_page.dart`
- `lib/presentation/pages/profile/profile_page.dart`
- `lib/features/today/domain/today_plan.dart`
- `lib/features/activities/domain/rich_closed_exercise.dart`
- `lib/features/activities/application/rich_closed_exercise_flow_controller.dart`
- `lib/features/activities/presentation/rich_closed/`
- `lib/features/revision_sessions/domain/revision_session.dart`
- `lib/features/revision_sessions/data/http_revision_sessions_api.dart`
- `lib/features/activities/data/http_activities_api.dart`
- `lib/presentation/theme/app_colors.dart`
- `lib/presentation/theme/app_spacing.dart`
- `lib/presentation/theme/app_radius.dart`
- `lib/presentation/widgets/revision_button.dart`
- `lib/presentation/widgets/revision_panel.dart`
- `lib/presentation/widgets/revision_navigation.dart`
- `docs/v1/ROADMAP_EXECUTION_LOT_V1_025_READINESS_AUDIT.md`

Backend NestJS inspecte dans `/Users/karim/Project/app-révision/api` :

- `prisma/schema.prisma`
- `src/modules/subjects/interfaces/subjects.controller.ts`
- `src/modules/documents/interfaces/documents.controller.ts`
- `src/modules/study-artifacts/interfaces/study-artifacts.controller.ts`
- `src/modules/revision/interfaces/today.controller.ts`
- `src/modules/activities/interfaces/activities.controller.ts`
- `src/modules/revision-sessions/interfaces/revision-sessions.controller.ts`
- `src/modules/documents/application/upload-course-pdf.use-case.ts`
- `src/modules/jobs/infrastructure/document-processing.consumer.ts`
- `src/modules/activities/application/rich-closed-questions/`
- `src/modules/demo-seed/demo-seed.fixtures.ts`
- `test/critical-paths.e2e-spec.ts`
- `docs/v1/ROADMAP_EXECUTION_LOT_V1_025_READINESS_AUDIT.md`

### 2.2 Frontend actuel

Le routing actuel est gere dans `lib/app/router/app_router.dart` et `lib/app/router/app_routes.dart`. L'application demarre sur `/subjects`. Le shell principal utilise `StatefulShellRoute.indexedStack` avec quatre branches : sujets, aujourd'hui, activites et profil. Les routes importantes actuelles sont :

- `/subjects`
- `/subjects/:subjectId`
- `/subjects/:subjectId/documents/:documentId`
- `/today`
- `/activities`
- `/activities/session`
- `/activities/rich-closed`
- `/profile`
- `/onboarding`
- `/sign-in`

La navigation visible est geree par `RevisionHomeShell`, `RevisionBottomNavigation` et `RevisionNavigationRail`. Elle affiche aujourd'hui `Accueil`, `Aujourd hui`, `Activites`, `Profil`. Elle est deja responsive avec un seuil desktop a 840 px, mais elle ne correspond pas encore a la cible `Accueil / Progres / Revisions / Sources / Profil`.

Les pages actuelles couvrent deja une base utile :

- sujets et detail sujet ;
- detail document ;
- Today plan ;
- activites ;
- session de revision ;
- rich closed exercise complet ;
- profil ;
- onboarding et auth.

Les features Flutter sont organisees par domaine : `subjects`, `documents`, `today`, `activities`, `revision_sessions`, `auth`, `profile`. Les controllers Riverpod et les APIs HTTP existent deja pour plusieurs parcours. C'est une base solide pour le MVP, mais les objets metier visibles sont encore surtout `Subject`, `Document`, `KnowledgeUnit`, `Activity`, pas encore `Course`.

Le design system actuel existe partiellement dans :

- `lib/presentation/theme/app_colors.dart`
- `lib/presentation/theme/app_spacing.dart`
- `lib/presentation/theme/app_radius.dart`
- `lib/presentation/widgets/revision_button.dart`
- `lib/presentation/widgets/revision_panel.dart`
- `lib/presentation/widgets/revision_icon_badge.dart`
- `lib/presentation/widgets/revision_progress_bar.dart`
- `lib/presentation/widgets/revision_choice_tile.dart`
- `lib/presentation/widgets/revision_navigation.dart`

Ces composants sont utiles, mais ils ne suffisent pas encore pour reproduire proprement les maquettes cible. Il manque un vrai package de composants applicatifs : subject switcher, course card, resume course card, source file card, mastery ring, segmented control, bottom sheet shell, mode card et etats standardises.

Le rich closed exercise est tres avance cote Flutter. Les 14 types V1 sont modelises et rendus via `lib/features/activities/domain/rich_closed_exercise.dart` et `lib/features/activities/presentation/rich_closed/`. Ce bloc doit etre reutilise pour les sessions, pas reecrit.

Limites frontend principales :

- navigation pas encore alignee sur la cible ;
- `Course` absent du modele d'interface ;
- sources encore affichees via documents ;
- fiches encore document-level ;
- progression pas encore presentee comme dans la cible ;
- design system trop disperse pour lancer une refonte ecran par ecran ;
- risque de duplication si les nouvelles cartes sont codees localement dans chaque page.

### 2.3 Backend actuel

Le backend NestJS est modulaire. Les modules pertinents sont :

- `subjects`
- `documents`
- `revision`
- `activities`
- `revision-sessions`
- `study-artifacts`
- `jobs`
- `ai`
- `demo-seed`
- `auth`

Le schema Prisma actuel contient notamment :

- `StudentProfile`
- `Subject`
- `Document`
- `DocumentProcessingJob`
- `KnowledgeUnit`
- `DocumentChunk`
- `KnowledgeUnitSource`
- `Summary`
- `SummarySource`
- `RevisionSheet`
- `RevisionSheetSection`
- `MasteryState`
- `ActivitySession`
- `RevisionSession`
- `RevisionSessionAction`
- `RichClosedExercisePayload`
- `RichClosedExerciseResult`

Le modele actuel est document-centric. `Document` porte le fichier, son `storagePath`, son `status`, ses chunks, ses knowledge units, ses summaries et ses revision sheets. `KnowledgeUnit` est lie a `Subject` et optionnellement a un `Document`. `RevisionSheet` et `Summary` sont uniques par document.

Le pipeline document existe deja :

1. upload PDF via `POST /documents/course-pdf` ;
2. stockage local via le storage adapter ;
3. creation du `Document` ;
4. enqueue du job de processing ;
5. extraction texte ;
6. chunking ;
7. extraction de knowledge units ;
8. document `READY`.

Les endpoints actuels reutilisables incluent :

- `GET /subjects`
- `GET /subjects/:id`
- `POST /subjects`
- `DELETE /subjects/:id`
- `POST /documents`
- `POST /documents/course-pdf`
- `GET /subjects/:subjectId/documents`
- `GET /documents/:documentId`
- `GET /documents/:documentId/knowledge-units`
- `DELETE /documents/:documentId`
- `GET /documents/:documentId/summary`
- `POST /documents/:documentId/summary`
- `GET /documents/:documentId/revision-sheet`
- `POST /documents/:documentId/revision-sheet`
- `GET /today`
- `POST /activities/next`
- `POST /activities/open-question`
- `POST /activities/rich-closed/start`
- `GET /activities/rich-closed/:sessionId`
- `POST /activities/rich-closed/:sessionId/submit`
- `GET /activities/rich-closed/:sessionId/result`
- `POST /revision-sessions`
- `GET /revision-sessions/:sessionId`
- `POST /revision-sessions/:sessionId/next-action`

Les limites backend principales :

- pas de modele `Course` ;
- pas de relation `CourseSource` ;
- les fiches et summaries sont document-level, pas course-level ;
- les sessions acceptent `subjectId`, `documentId`, `knowledgeUnitId`, mais pas `courseId` ;
- pas d'endpoint progression par cours ;
- `SessionResult` n'est pas expose comme objet pedagogique dedie ;
- le V1-025 readiness audit signale encore au moins un blocage rich closed a corriger avant de promettre une V1 totalement stable.

## 3. Ecart entre l'existant et la cible

| Sujet | Existant | Cible MVP | Ecart | Risque |
|---|---|---|---|---|
| Navigation | `/subjects`, `/today`, `/activities`, `/profile` dans un shell a 4 onglets | `/home`, `/progress`, `/revisions`, `/sources`, `/profile` | Renommer, ajouter deux sections, garder des alias temporaires | Casser les deep links et tests router |
| Design system | Tokens et widgets generiques partiels | Design system mobile premium complet et reutilisable | Creer composants structurants avant pages | Sur-abstraction ou duplication locale |
| Matiere active | Liste de sujets et detail sujet | Une matiere active avec switcher | Etat local ou backend a definir | UX confuse si plusieurs matieres se melangent |
| Course model | Absent ; `Document` est central | `Course` comme objet central affiche | Ajouter modele ou adapter documents | Dette si document reste le faux cours trop longtemps |
| Sources | `Document` liste par sujet | `CourseSource` attachee a un cours | Liaison course-document manquante | Sources mal rattachees apres upload |
| Fiches | `RevisionSheet` par document | Fiche par cours avec modes rapide/complete/examen | Adapter ou agreger les fiches document-level | IA trop large si on regenere tout trop tot |
| Modes de revision | Today, activities et revision sessions existent | Rapide / approfondie / preparation examen par cours | Mapper les modes vers session/action/question mix | Session trop generique pour l'utilisateur |
| Session | `RevisionSession` existe avec action courante | Session focus, courte, orientee cours | Ajouter contexte course et UI dediee | Duplications avec rich closed page |
| Resultat | Resultats par activite rich closed ou actions | Resultat de session pedagogique global | Endpoint resultat dedie ou agregat | Progression trompeuse si agregation faible |
| Progres | `MasteryState` et Today plan | Progres par matiere, cours, notions faibles | Read model a construire | Scores affiches sans source claire |

## 4. Decision MVP : Course reel ou adapter documents ?

### Option A — MVP rapide : adapter les documents READY

Principe : ne pas creer immediatement un modele `Course`. Les documents `READY` deviennent temporairement les cours visibles. Le titre du fichier devient le titre du cours, les chunks et knowledge units alimentent le detail, et les sources sont limitees au document lui-meme.

Avantages :

- pas de migration Prisma immediate ;
- UI visible plus vite ;
- reutilise directement `GET /subjects/:subjectId/documents` ;
- compatible avec les endpoints de fiche document-level.

Inconvenients :

- contredit la cible produit ou `Document` devient une source ;
- complique l'ajout de plusieurs sources pour un meme cours ;
- cree une dette de vocabulaire dans le front ;
- force des wrappers du type `DocumentAsCourse` qui risquent de rester ;
- rend la progression par cours artificielle.

Option A est acceptable uniquement comme read model transitoire pour afficher rapidement l'Accueil pendant un lot court. Elle ne doit pas devenir l'architecture MVP.

### Option B — MVP propre : ajouter Course / CourseSource

Principe : creer un vrai `Course` comme objet central de l'experience, et rattacher les documents a ce cours via `CourseSource`. `Document` reste le fichier technique analyse. `KnowledgeUnit`, `RevisionSheet`, `ActivitySession` et `RevisionSession` peuvent etre adaptes progressivement.

Avantages :

- aligne le backend sur l'UX cible ;
- permet plusieurs sources par cours ;
- rend le detail cours naturel ;
- clarifie les URLs `/courses/:courseId` ;
- prepare la progression par cours ;
- evite de vendre le document comme objet produit.

Inconvenients :

- demande une migration Prisma ;
- demande des endpoints nouveaux ;
- demande un read model front supplementaire ;
- oblige a faire attention aux donnees existantes.

### Recommandation

Recommandation : choisir l'Option B, mais en version bornee.

Scope recommande pour le MVP :

- ajouter `Course` maintenant ;
- ajouter `CourseSource` maintenant ;
- ne pas ajouter une table `CourseKnowledgeUnit` au premier passage ;
- deriver les notions d'un cours via les documents attaches par `CourseSource` ;
- ne pas creer `SessionResult` comme table au debut ;
- calculer `Progress` via `MasteryState`, `ActivityResult`, `RichClosedExerciseResult` et les knowledge units rattachees aux sources ;
- garder un adapter `DocumentAsCourse` seulement dans le lot UI transitoire, puis le supprimer quand l'API Course est branchee.

Cette decision evite de construire le MVP sur une illusion, tout en limitant la migration. Le vrai arbitrage est de ne pas generaliser trop tot : un cours peut avoir plusieurs sources, mais les fiches et la progression peuvent d'abord utiliser la source principale ou l'ensemble des documents attaches sans creer un graphe complet course-notion.

## 5. Design system MVP obligatoire

Le design system doit etre le premier lot. Il doit permettre de construire les ecrans cible sans refaire les boutons, cartes, pills et panels dans chaque page.

Structure proposee :

```text
lib/presentation/design_system/
  tokens/
    revision_colors.dart
    revision_spacing.dart
    revision_radius.dart
    revision_typography.dart
    revision_shadows.dart
    revision_motion.dart
  components/
    revision_app_shell.dart
    revision_bottom_nav.dart
    revision_page_scaffold.dart
    revision_glass_card.dart
    revision_gradient_button.dart
    revision_icon_tile.dart
    revision_progress_line.dart
    revision_mastery_ring.dart
    revision_subject_switcher.dart
    revision_course_card.dart
    revision_resume_course_card.dart
    revision_mode_card.dart
    revision_source_file_card.dart
    revision_segmented_control.dart
    revision_sheet_handle.dart
    revision_stat_triplet.dart
    revision_empty_state.dart
    revision_error_state.dart
    revision_loading_state.dart
```

Regles globales :

- aucune couleur hardcodee dans les pages metier ;
- toutes les couleurs passent par `RevisionColors` ;
- tous les espacements passent par `RevisionSpacing` ;
- les rayons passent par `RevisionRadius` ;
- les textes importants passent par `RevisionTypography` ou le theme derive ;
- aucun bouton local bricole dans une page ;
- aucune card locale repetee ;
- les etats loading, error et empty sont standardises ;
- mobile-first obligatoire ;
- desktop correct via max-width et rail, mais pas prioritaire ;
- style Material brut visuellement masque par les composants ;
- commentaires utiles dans le futur code pour expliquer les choix non triviaux.

| Widget | Role | Props principales | Pages utilisatrices | Regles de reutilisation |
|---|---|---|---|---|
| `RevisionAppShell` | Shell global avec fond, safe area et largeur max | `child`, `bottomNav`, `sideRail`, `backgroundVariant` | Toutes les pages connectees | Ne contient pas de logique metier |
| `RevisionBottomNav` | Navigation Accueil/Progres/Revisions/Sources/Profil | `items`, `selectedIndex`, `onTap` | Shell | Remplace l'actuel `RevisionBottomNavigation` apres migration |
| `RevisionPageScaffold` | Structure page mobile avec title/header/actions | `title`, `subtitle`, `leading`, `actions`, `body` | Home, detail cours, progres, revisions | Evite les `Scaffold` locaux repetes |
| `RevisionGlassCard` | Carte dark premium reutilisable | `child`, `onTap`, `padding`, `selected`, `status` | Course card, source card, panels | Pas de logique de navigation interne |
| `RevisionGradientButton` | CTA principal | `label`, `icon`, `onPressed`, `variant`, `expanded` | Fiche, session, resultat | Remplace les CTA locaux |
| `RevisionIconTile` | Icône coloree de cours/mode/source | `icon`, `assetKey`, `accent`, `size` | Home, detail cours, sources | Icons via Material ou registre interne, pas d'asset distant |
| `RevisionProgressLine` | Barre de progression compacte | `value`, `color`, `label`, `semanticsLabel` | Course cards, result, progress | Toujours label accessible |
| `RevisionMasteryRing` | Anneau de maitrise | `value`, `centerLabel`, `size`, `accent` | Home, progress, result | Ne calcule pas le score, affiche une valeur fournie |
| `RevisionSubjectSwitcher` | Bouton/pill de matiere active | `subject`, `subjects`, `onOpen` | Home, progress, revisions | Ouvre bottom sheet dediee |
| `RevisionCourseCard` | Ligne cours | `title`, `subtitle`, `progress`, `duration`, `icon`, `onTap` | Home, progress | Supporte labels longs et petit ecran |
| `RevisionResumeCourseCard` | Hero "Reprendre le cours" | `course`, `progress`, `ctaLabel`, `onContinue` | Home | Une seule par matiere active |
| `RevisionModeCard` | Carte mode rapide/approfondie/examen | `mode`, `title`, `description`, `icon`, `onTap` | Detail cours, hub revisions | Pas de logique session dedans |
| `RevisionSourceFileCard` | Source PDF ou fichier | `fileName`, `status`, `sizeLabel`, `onMenu`, `onTap` | Sources sheet/page | Affiche status processing/ready/error |
| `RevisionSegmentedControl` | Tabs rapide/complete/examen | `segments`, `selected`, `onChanged` | Fiche de lecture | Accessible clavier et semantics |
| `RevisionSheetHandle` | Poignee bottom sheet | `label` optionnel | Sources bottom sheet | Purement structurel |
| `RevisionStatTriplet` | Progression / temps / difficulte | `items` | Detail cours | Evite trois layouts differents |
| `RevisionEmptyState` | Etat vide standard | `title`, `message`, `cta` | Home, sources, progress | Toujours actionnable si possible |
| `RevisionErrorState` | Etat erreur standard | `title`, `message`, `retry` | Toutes pages API | Pas de stacktrace visible |
| `RevisionLoadingState` | Skeleton/spinner standard | `label`, `variant` | Toutes pages API | Pas de layout jump important |

La structure actuelle `lib/presentation/widgets/` peut etre migree progressivement. Le lot DS doit soit deplacer les composants existants avec wrappers de compatibilite, soit creer les nouveaux composants sans casser les imports existants. Le choix recommande est de creer `design_system/` et de laisser les anciens widgets en place jusqu'a suppression lot par lot.

## 6. Navigation MVP cible

### 6.1 Routes actuelles

Routes actuelles identifiees :

- `/` redirige vers `/subjects`
- `/subjects`
- `/subjects/:subjectId`
- `/subjects/:subjectId/documents/:documentId`
- `/today`
- `/activities`
- `/activities/session`
- `/activities/rich-closed`
- `/profile`
- `/onboarding`
- `/sign-in`

### 6.2 Routes cibles MVP

Routes cibles recommandees :

- `/home`
- `/progress`
- `/revisions`
- `/sources`
- `/profile`
- `/courses/:courseId`
- `/courses/:courseId/sheet`
- `/revision-sessions/:sessionId`
- `/revision-sessions/:sessionId/result`

### 6.3 Compatibilite temporaire

Aliases a garder pendant le MVP :

- `/subjects` -> `/home`
- `/today` -> `/home` ou page cachee accessible en debug jusqu'a retrait ;
- `/activities` -> `/revisions`
- `/activities/session` -> `/revision-sessions/:sessionId` quand `sessionId` existe, sinon route legacy ;
- `/activities/rich-closed` conservee pour ne pas casser les tests V1 et les deep links d'exercice ;
- `/subjects/:subjectId/documents/:documentId` conservee jusqu'a remplacement par `/courses/:courseId/sources`.

La migration doit etre progressive :

1. ajouter les nouvelles constantes de route ;
2. conserver les anciennes constantes ;
3. brancher le nouveau shell ;
4. ajouter des redirections testees ;
5. supprimer les routes legacy seulement apres stabilisation.

Le shell cible doit afficher cinq destinations : `Accueil`, `Progres`, `Revisions`, `Sources`, `Profil`. `Sources` peut d'abord lister les sources de la matiere active, meme si l'acces principal reste le bottom sheet du cours.

## 7. Ecrans MVP

### 7.1 Accueil matiere active

Contenu :

- subject switcher ;
- compteurs eventuels de streak et points ;
- titre de la matiere active ;
- hero card `Reprendre le cours` ;
- liste des cours de la matiere ;
- bottom nav.

Composants design system :

- `RevisionPageScaffold`
- `RevisionSubjectSwitcher`
- `RevisionResumeCourseCard`
- `RevisionCourseCard`
- `RevisionProgressLine`
- `RevisionMasteryRing`
- `RevisionEmptyState`
- `RevisionLoadingState`
- `RevisionErrorState`

Source de donnees :

- MVP transitoire : `GET /subjects`, `GET /subjects/:subjectId/documents`, `GET /documents/:documentId/knowledge-units`.
- MVP propre : `GET /subjects`, `GET /subjects/:subjectId/courses`, `GET /subjects/:subjectId/progress`.

Actions :

- changer de matiere ;
- ouvrir un cours ;
- reprendre le cours recommande ;
- ouvrir l'ajout de matiere si aucun sujet.

Tests :

- affiche la matiere active ;
- affiche empty state sans cours ;
- supporte labels longs ;
- navigation vers detail cours ;
- pas d'overflow sur largeur mobile.

### 7.2 Subject switcher bottom sheet

Contenu :

- liste des matieres ;
- matiere active ;
- bouton ajouter matiere ;
- etat vide si aucune matiere ;
- action de fermeture.

Composants design system :

- `RevisionSheetHandle`
- `RevisionGlassCard`
- `RevisionIconTile`
- `RevisionGradientButton`

Source de donnees :

- `GET /subjects`
- `POST /subjects` si creation dans le MVP.

Tests :

- ouvre depuis le switcher ;
- selectionne une autre matiere ;
- conserve l'etat actif localement ;
- ne casse pas le route state.

### 7.3 Detail cours

Contenu :

- header cours ;
- icone et metadonnees ;
- stats progression / temps / difficulte ;
- actions `Revision rapide`, `Revision approfondie`, `Preparation examen` ;
- bouton `Fiche` ;
- bouton `Sources` ;
- aperçu `Ce que tu vas apprendre`.

Composants design system :

- `RevisionPageScaffold`
- `RevisionIconTile`
- `RevisionStatTriplet`
- `RevisionModeCard`
- `RevisionGradientButton`
- `RevisionGlassCard`
- `RevisionProgressLine`

Source de donnees :

- `GET /courses/:courseId`
- fallback transitoire : document + knowledge units.

Endpoint/API :

- indispensable : `GET /courses/:courseId`
- utile : `GET /courses/:courseId/progress` si non inclus dans le detail.

Tests :

- affiche les trois modes ;
- ouvre la fiche ;
- ouvre les sources ;
- lance une session avec le bon mode ;
- labels longs ne cassent pas le header.

### 7.4 Sources bottom sheet

Contenu :

- liste des fichiers sources ;
- statut de traitement ;
- menu par source ;
- gros bouton `+` ;
- ajout PDF ;
- erreurs de fichier.

Composants design system :

- `RevisionSheetHandle`
- `RevisionSourceFileCard`
- `RevisionGradientButton`
- `RevisionEmptyState`
- `RevisionErrorState`
- `RevisionLoadingState`

Source de donnees :

- `GET /courses/:courseId/sources`
- `POST /courses/:courseId/sources/course-pdf`
- reutilisation interne de l'upload document.

Tests :

- affiche source ready/processing/error ;
- bouton ajout PDF disponible ;
- upload invalide affiche erreur ;
- bottom sheet scrollable ;
- pas d'URL image distante.

### 7.5 Fiche de lecture

Contenu :

- tabs `Rapide`, `Complete`, `Examen` ;
- resume ;
- points cles ;
- pieges frequents ;
- sources utilisees ;
- CTA vers revision.

Composants design system :

- `RevisionPageScaffold`
- `RevisionSegmentedControl`
- `RevisionGlassCard`
- `RevisionSourceFileCard`
- `RevisionGradientButton`

Source de donnees :

- `GET /courses/:courseId/sheet?mode=rapid|complete|exam`
- adaptation initiale depuis `GET /documents/:documentId/revision-sheet`.

Tests :

- change de mode sans perdre la page ;
- affiche sources ;
- supporte contenu long ;
- affiche fallback si fiche absente ;
- ne lance pas de generation IA automatiquement sans action explicite.

### 7.6 Hub Revisions

Contenu :

- revision rapide ;
- revision approfondie ;
- preparation examen ;
- recommande aujourd'hui ;
- raccourcis vers cours recents.

Composants design system :

- `RevisionPageScaffold`
- `RevisionModeCard`
- `RevisionCourseCard`
- `RevisionEmptyState`

Source de donnees :

- `GET /today` reutilisable ;
- `GET /subjects/:subjectId/courses` ;
- `GET /subjects/:subjectId/progress`.

Tests :

- affiche recommandations ;
- lance mode rapide ;
- garde la matiere active ;
- degrade proprement si Today vide.

### 7.7 Session de revision

Contenu :

- une question ou action a la fois ;
- progress bar ;
- reponses ;
- validation ;
- feedback immediat ;
- bouton continuer.

Composants design system :

- `RevisionPageScaffold`
- `RevisionProgressLine`
- `RevisionGradientButton`
- composants rich closed existants ;
- `RevisionErrorState`.

Source de donnees :

- `POST /courses/:courseId/revision-sessions`
- `GET /revision-sessions/:sessionId`
- `POST /revision-sessions/:sessionId/next-action`
- endpoints rich closed existants quand l'action le demande.

Tests :

- session demarre depuis un cours ;
- action rich closed s'affiche ;
- feedback visible seulement apres validation ;
- pas de score recalcule cote Flutter ;
- navigation resultat.

### 7.8 Resultat de session

Contenu :

- score ;
- bonnes reponses ;
- notions maitrisees ;
- notions a retravailler ;
- prochaine etape ;
- CTA fiche complete ou preparation examen.

Composants design system :

- `RevisionPageScaffold`
- `RevisionMasteryRing`
- `RevisionGlassCard`
- `RevisionCourseCard`
- `RevisionGradientButton`

Source de donnees :

- `GET /revision-sessions/:sessionId/result`
- aggregation depuis resultats d'activites existants.

Tests :

- affiche resultat apres session ;
- gere resultat absent ;
- ne calcule pas score cote Flutter ;
- CTA retourne vers cours ou revision.

### 7.9 Progres simple

Contenu :

- maitrise globale ;
- progression des cours ;
- points faibles ;
- CTA vers revision.

Composants design system :

- `RevisionPageScaffold`
- `RevisionSubjectSwitcher`
- `RevisionMasteryRing`
- `RevisionCourseCard`
- `RevisionProgressLine`
- `RevisionGlassCard`

Source de donnees :

- `GET /subjects/:subjectId/progress`
- `GET /subjects`.

Tests :

- affiche progres par cours ;
- affiche points faibles ;
- change de matiere ;
- empty state si pas de donnees ;
- valeurs accessibles avec labels texte.

## 8. API MVP proposee

### 8.1 Endpoints existants reutilisables

| Endpoint | Utilite MVP | Limite |
|---|---|---|
| `GET /subjects` | Charger matieres et switcher | Pas d'active subject persiste |
| `POST /subjects` | Ajouter matiere | Pas de metadonnees visuelles |
| `GET /subjects/:subjectId/documents` | Adapter transitoire cours/sources | Document reste central |
| `POST /documents/course-pdf` | Upload PDF existant | Pas de rattachement course |
| `GET /documents/:documentId/knowledge-units` | Notions extraites | Document-level |
| `GET /documents/:documentId/revision-sheet` | Fiche existante | Pas de mode course |
| `POST /documents/:documentId/revision-sheet` | Generation fiche | IA document-level |
| `GET /today` | Recommandations | Pas course-aware |
| `POST /activities/rich-closed/start` | Demarrer exercice riche | Demande `knowledgeUnitId` |
| `GET /activities/rich-closed/:sessionId` | Lire exercice | OK |
| `POST /activities/rich-closed/:sessionId/submit` | Soumettre exercice | OK |
| `GET /activities/rich-closed/:sessionId/result` | Correction | OK |
| `POST /revision-sessions` | Demarrer session | Pas `courseId` |
| `GET /revision-sessions/:sessionId` | Lire session | Pas resultat dedie |
| `POST /revision-sessions/:sessionId/next-action` | Action suivante | Selection encore orientee subject/document/KU |

### 8.2 Endpoints nouveaux ou adaptes

| Endpoint | Utilite | Payload | Response | Erreurs | Impact Prisma | MVP |
|---|---|---|---|---|---|---|
| `GET /subjects/:subjectId/courses` | Liste cours home/progress | Aucun | `CourseListItem[]` avec progression, duree, source count | 404 subject, 401 auth | Lit `Course`, `CourseSource`, derive progress | Indispensable |
| `POST /subjects/:subjectId/courses` | Creer cours vide ou depuis titre | `{ title, iconKey?, accentColor? }` | `CourseDto` | 400 title, 404 subject | Cree `Course` | Optionnel MVP si import cree le cours |
| `GET /courses/:courseId` | Detail cours | Aucun | `CourseDetailDto` avec stats, sources, learning preview | 404 course | Lit `Course`, sources, KUs | Indispensable |
| `GET /courses/:courseId/sources` | Bottom sheet sources | Aucun | `CourseSourceDto[]` | 404 course | Lit `CourseSource -> Document` | Indispensable |
| `POST /courses/:courseId/sources/course-pdf` | Ajouter PDF a un cours | multipart `file` | `CourseSourceDto` + document status | 400 file, 404 course, 413 size | Cree `Document`, `CourseSource`, job | Indispensable |
| `DELETE /courses/:courseId/sources/:sourceId` | Retirer source du cours | Aucun | 204 | 404, 409 si unique source | Supprime lien, pas document au debut | Optionnel |
| `GET /courses/:courseId/sheet?mode=rapid|complete|exam` | Fiche V2 | Query `mode` | `CourseSheetDto` | 404, 422 no ready source | Lit/adapte `RevisionSheet` | Indispensable |
| `POST /courses/:courseId/sheet` | Generer/regenerer fiche | Query `mode?` | `CourseSheetDto` | 422 no ready source, IA errors | Reutilise generator document ou future course sheet | Optionnel au debut |
| `POST /courses/:courseId/revision-sessions` | Demarrer session depuis cours | `{ mode }` | `RevisionSessionDto` | 400 mode, 404 course, 422 no KU | Cree `RevisionSession` avec selected KU/doc | Indispensable |
| `GET /revision-sessions/:sessionId/result` | Resultat pedagogique global | Aucun | `SessionResultDto` | 404, 409 not completed | Derive activites/actions | Indispensable pour resultat |
| `GET /subjects/:subjectId/progress` | Page progres | Aucun | `SubjectProgressDto` | 404 subject | Lit `MasteryState`, KUs, courses | Indispensable |

### 8.3 DTOs recommandes

`CourseListItemDto` :

- `id`
- `subjectId`
- `title`
- `subtitle`
- `iconKey`
- `accentColor`
- `progressRatio`
- `completedLessons`
- `totalLessons`
- `estimatedMinutes`
- `sourceCount`
- `status`

`CourseDetailDto` :

- `id`
- `subjectId`
- `title`
- `description`
- `iconKey`
- `accentColor`
- `progress`
- `estimatedMinutes`
- `difficultyLabel`
- `sourcesSummary`
- `learningPreview`
- `availableModes`

`CourseSourceDto` :

- `id`
- `courseId`
- `documentId`
- `fileName`
- `mimeType`
- `status`
- `errorCode`
- `sizeLabel`
- `createdAt`
- `role`

`CourseSheetDto` :

- `courseId`
- `mode`
- `title`
- `summary`
- `keyPoints`
- `commonMistakes`
- `mustKnow`
- `practiceSuggestions`
- `sections`
- `sources`
- `status`

`SessionResultDto` :

- `sessionId`
- `courseId`
- `scoreRatio`
- `correctCount`
- `totalCount`
- `masteredItems`
- `itemsToReview`
- `nextStep`
- `completedAt`

## 9. Donnees et Prisma MVP

### 9.1 Analyse du schema actuel

Le schema actuel sait deja representer une matiere, des documents, des chunks, des notions, des fiches, des activites et des sessions. La piece manquante est le niveau produit `Course`. Aujourd'hui, un document est a la fois fichier, unite d'affichage potentielle, source de chunks, source de fiche et point d'entree utilisateur. C'est precisement ce qu'il faut separer.

### 9.2 Evolution minimale proposee

Ajouter `Course` maintenant : oui.

Champs recommandes :

```text
Course
- id
- studentId
- subjectId
- title
- description?
- iconKey?
- accentColor?
- status
- displayOrder?
- estimatedMinutes?
- createdAt
- updatedAt
```

Ajouter `CourseSource` maintenant : oui.

Champs recommandes :

```text
CourseSource
- id
- courseId
- documentId
- role
- displayOrder?
- createdAt
- updatedAt
```

Contraintes recommandees :

- `Course` appartient a un `Subject` et a un `StudentProfile` ;
- `CourseSource` reference un `Document` du meme etudiant et de la meme matiere ;
- unique logique `courseId + documentId` ;
- suppression d'un cours ne supprime pas forcement le document au premier MVP, sauf decision produit explicite ;
- suppression d'un subject cascade deja tout ce qui est rattache.

Ajouter `CourseKnowledgeUnit` maintenant : non, pas au premier MVP.

Justification : `KnowledgeUnit` est deja lie a `Document`, et `CourseSource` relie le cours a ses documents. Pour le MVP, les notions d'un cours peuvent etre derivees par `course -> sources -> documents -> knowledgeUnits`. Une table many-to-many devient utile plus tard si une meme notion doit etre mutualisee, dedupliquee ou reorganisee entre plusieurs cours.

Ajouter `SessionResult` maintenant : non, pas en table au premier MVP.

Justification : les resultats peuvent etre calcules depuis `RevisionSession`, `RevisionSessionAction`, `ActivitySession`, `ActivityResult` et `RichClosedExerciseResult`. Une table dediee sera utile si le resultat doit etre historise avec un format stable, partageable ou auditable.

Ajouter une table `Progress` maintenant : non.

Justification : le progres peut etre calcule depuis `MasteryState`, les knowledge units et les resultats d'activite. Une table de snapshot peut venir plus tard pour performance ou analytics, mais elle serait prematuree au MVP.

### 9.3 Plan de migration futur, non execute dans ce lot

1. Ajouter les modeles `Course` et `CourseSource`.
2. Ajouter enums `CourseStatus` et `CourseSourceRole` si utile.
3. Generer une migration Prisma en lot backend dedie.
4. Ajouter un script de backfill local/dev : pour chaque document READY existant, creer un Course temporaire et une CourseSource.
5. Garder le backfill idempotent.
6. Ne pas supprimer les routes documents.
7. Ajouter tests repository pour isolation student/subject.
8. Ajouter e2e creation cours, ajout source, fiche, session.

## 10. Lots MVP recommandes

Roadmap conseillee : 12 lots. Elle permet de voir rapidement la nouvelle UI tout en evitant de retarder le vrai modele `Course`.

### Lot MVP-01 — Design system V2

Objectif : creer les tokens et composants MVP reutilisables.

Scope : `lib/presentation/design_system/`, wrappers autour des widgets existants si necessaire, tests widget de base.

Non-objectifs : aucune page refaite completement, aucune route modifiee, aucune dependance lourde.

Fichiers probablement concernes : nouveaux fichiers sous `lib/presentation/design_system/`, tests sous `test/presentation/design_system/`.

Front tasks : tokens, glass card, gradient button, nav item, course card, source card, segmented control, loading/error/empty.

Backend tasks : aucun.

Tests : rendu compact, labels longs, semantics minimales, tap targets.

Criteres d'acceptation : les pages futures peuvent utiliser les composants sans couleur hardcodee locale.

Risques : abstraction trop large. Mitigation : props simples, pas de generiques inutiles.

Dependances : aucune.

### Lot MVP-02 — Navigation V2 et shell cible

Objectif : ajouter le shell `Accueil / Progres / Revisions / Sources / Profil`.

Scope : nouvelles routes constantes, nouveau shell ou evolution du shell existant, alias legacy.

Non-objectifs : pas de refonte du contenu des pages, pas de suppression des routes V1.

Fichiers probablement concernes : `lib/app/router/app_routes.dart`, `lib/app/router/app_router.dart`, `lib/presentation/shell/revision_home_shell.dart`, tests router.

Front tasks : brancher cinq onglets, ajouter pages placeholders sobres, conserver `/activities/rich-closed`.

Backend tasks : aucun.

Tests : redirections, navigation onglets, deep links legacy.

Criteres d'acceptation : l'utilisateur voit la nouvelle navigation sans casser les parcours existants.

Risques : casser auth redirect. Mitigation : tests router avant/apres.

Dependances : MVP-01.

### Lot MVP-03 — Accueil matiere active avec adapter transitoire

Objectif : rendre la nouvelle home visible rapidement avec une matiere active et des cours adaptes depuis documents READY.

Scope : read model Flutter `CoursePreview` derive de subjects/documents, page `/home`, subject switcher.

Non-objectifs : pas de migration Prisma, pas de nouveau backend, pas de suppression de `/subjects`.

Fichiers probablement concernes : `features/subjects`, `features/documents`, nouvelle feature `courses` cote app, page home.

Front tasks : modeles UI `CoursePreview`, hero resume, liste cours, bottom sheet matieres, empty/loading/error.

Backend tasks : aucun ou reutilisation endpoints existants.

Tests : home avec documents, home vide, switch matiere, labels longs.

Criteres d'acceptation : la cible visuelle commence a apparaitre avec donnees reelles.

Risques : dette `DocumentAsCourse`. Mitigation : nommer l'adapter explicitement comme temporaire et le supprimer au MVP-05.

Dependances : MVP-01, MVP-02.

### Lot MVP-04 — Backend Course minimal

Objectif : ajouter `Course` et `CourseSource` persistants.

Scope : migration Prisma dediee, repository, use cases, controllers courses.

Non-objectifs : pas de `CourseKnowledgeUnit`, pas de table `Progress`, pas de generation IA course-level.

Fichiers probablement concernes : `prisma/schema.prisma`, nouveau module `src/modules/courses/`, `src/app.module.ts`, tests repository/controller.

Front tasks : aucun sauf contrat partage en docs.

Backend tasks : models Prisma, endpoints `GET /subjects/:subjectId/courses`, `GET /courses/:courseId`, `GET /courses/:courseId/sources`.

Tests : isolation student, subject mismatch, liste cours, detail cours, sources.

Criteres d'acceptation : un cours peut etre liste et expose avec ses sources.

Risques : migration mal backfillee. Mitigation : migration petite + seed/backfill local separe.

Dependances : decisions schema validees.

### Lot MVP-05 — Branchement Flutter Course API

Objectif : remplacer l'adapter documents par l'API Course.

Scope : feature `courses`, API client, domain models, providers, home alimentee par courses.

Non-objectifs : pas de refonte detail cours complete si non necessaire.

Fichiers probablement concernes : `lib/features/courses/`, `lib/features/subjects/`, page home, tests API parser.

Front tasks : parser strict DTO Course, controller, error mapping, suppression adapter transitoire.

Backend tasks : ajustements mineurs DTO si tests revelent un manque.

Tests : parse course list/detail/sources, home API success/error/empty.

Criteres d'acceptation : l'Accueil n'utilise plus `Document` comme faux cours.

Risques : contrats instables. Mitigation : fixtures API et tests parser.

Dependances : MVP-04.

### Lot MVP-06 — Detail cours V2

Objectif : creer l'ecran `/courses/:courseId`.

Scope : header cours, stats, modes, fiche, sources, learning preview.

Non-objectifs : pas de session custom avancee, pas de fiche redesign profond.

Fichiers probablement concernes : page course detail, `features/courses`, router, tests widget.

Front tasks : layout responsive, CTA modes, ouverture sources, navigation fiche.

Backend tasks : enrichir `GET /courses/:courseId` si champs manquants.

Tests : trois modes visibles, sources ouvrables, fiche ouvrable, labels longs.

Criteres d'acceptation : le cours devient l'ecran central.

Risques : trop charger l'ecran. Mitigation : stats simples, learning preview court.

Dependances : MVP-05.

### Lot MVP-07 — Sources bottom sheet + ajout source

Objectif : attacher des PDF a un cours depuis l'UI cible.

Scope : bottom sheet sources, upload PDF, statuts processing/ready/error.

Non-objectifs : pas de gestion avancee multi-fichiers, pas de suppression destructive par defaut.

Fichiers probablement concernes : `features/courses`, `features/documents`, widgets sources, backend courses/documents.

Front tasks : picker existant si disponible, source cards, upload state, retry.

Backend tasks : `POST /courses/:courseId/sources/course-pdf` reutilisant `UploadCoursePdfUseCase` et creant `CourseSource`.

Tests : upload PDF valide, fichier invalide, status rendering, source list refresh.

Criteres d'acceptation : l'utilisateur ajoute une source a un cours sans voir l'objet technique Document.

Risques : upload et linking non atomiques. Mitigation : transaction ou cleanup document si lien echoue.

Dependances : MVP-04, MVP-06.

### Lot MVP-08 — Fiche de lecture V2 modes rapide/complete/examen

Objectif : exposer une fiche orientee cours avec trois modes.

Scope : `/courses/:courseId/sheet`, segmented control, adaptation des `RevisionSheet` existantes.

Non-objectifs : pas de nouveau prompt IA obligatoire, pas de course-level artifact parfait.

Fichiers probablement concernes : app `features/courses` ou `features/study_artifacts`, backend `study-artifacts` ou `courses`.

Front tasks : DTO `CourseSheet`, UI tabs, sources, fallback fiche absente.

Backend tasks : `GET /courses/:courseId/sheet?mode=...` qui mappe la source principale ou les sources ready.

Tests : modes, contenu long, source citations, fiche absente.

Criteres d'acceptation : l'utilisateur lit une fiche sans ouvrir un document.

Risques : contenu identique entre modes. Mitigation : MVP accepte adaptation simple, libelles honnetes.

Dependances : MVP-07.

### Lot MVP-09 — Hub Revisions V2

Objectif : creer `/revisions` avec modes et recommandations.

Scope : cartes rapide/approfondie/examen, recommande aujourd'hui, cours recents.

Non-objectifs : pas de nouveau moteur adaptatif.

Fichiers probablement concernes : page revisions, `features/today`, `features/courses`.

Front tasks : hub, CTA vers session, empty state.

Backend tasks : reutiliser `GET /today`, ajouter champs course-aware plus tard si necessaire.

Tests : hub charge, CTA session, Today vide.

Criteres d'acceptation : le parcours revision n'est plus cache dans `/activities`.

Risques : doublon avec Today. Mitigation : Today devient source de recommandation, pas onglet principal.

Dependances : MVP-05.

### Lot MVP-10 — Session de revision focus

Objectif : rendre une session courte et focalisee depuis un cours.

Scope : route `/revision-sessions/:sessionId`, mode rapide/approfondie/examen, reutilisation rich closed/open question.

Non-objectifs : pas de nouveau type de question, pas de score Flutter, pas de flow libre.

Fichiers probablement concernes : `features/revision_sessions`, `features/activities`, router, backend revision-sessions.

Front tasks : progress bar, current action, validation, feedback, continuer.

Backend tasks : `POST /courses/:courseId/revision-sessions`, mapping mode -> preferred action/question mix.

Tests : start session, action rich closed, next action, erreurs no KU.

Criteres d'acceptation : une session demarre depuis le detail cours et conduit a un resultat.

Risques : melange de flows existants. Mitigation : wrapper session, pas de duplication des widgets rich closed.

Dependances : MVP-06, MVP-09.

### Lot MVP-11 — Resultat de session et Progres simple

Objectif : ajouter resultat clair et page `/progress`.

Scope : result session, progression globale, progression par cours, points faibles.

Non-objectifs : pas d'analytics avance, pas de table Progress.

Fichiers probablement concernes : app progress/result pages, backend result/progress use cases.

Front tasks : mastery ring, listes maitrise/a retravailler, CTA prochaine etape.

Backend tasks : `GET /revision-sessions/:sessionId/result`, `GET /subjects/:subjectId/progress`.

Tests : resultat apres submit, progress empty, progress avec mastery.

Criteres d'acceptation : l'utilisateur voit ce qu'il a reussi et quoi faire ensuite.

Risques : progression trompeuse. Mitigation : afficher seulement des valeurs derivables et labeliser clairement.

Dependances : MVP-10.

### Lot MVP-12 — Polish, fixtures, tests, demo

Objectif : rendre le MVP demonstrable de bout en bout.

Scope : fixtures locales, smoke app/API, responsive checks, accessibilite minimale, runbook demo actualise.

Non-objectifs : pas d'audit final lourd, pas de deploiement, pas de nouvelle IA.

Fichiers probablement concernes : tests Flutter, tests e2e API, docs demo, seed demo.

Front tasks : tests petit ecran, labels longs, empty/error/loading, no overflow evident.

Backend tasks : fixtures courses/sources/progress, e2e happy path.

Tests : happy path complet, non-regression rich closed, router, today/session.

Criteres d'acceptation : demo rejouable avec import ou fixtures.

Risques : trop de polish. Mitigation : limiter aux bugs visibles et tests MVP.

Dependances : tous lots precedents.

## 11. Plan de validation

Happy path MVP :

| Etape | Attendu | Reel / mock / simule | Depend backend | Depend IA |
|---|---|---|---|---|
| 1. Arrivee Accueil | L'utilisateur voit `/home` | Reel | Auth + subjects | Non |
| 2. Matiere active Math | Switcher affiche Math | Reel ou fixture | `GET /subjects` | Non |
| 3. Liste de cours | Loi normale visible | Reel apres Course API, mock au MVP-03 | `GET /subjects/:id/courses` | Non |
| 4. Ouvre Loi normale | Detail cours affiche stats/modes | Reel | `GET /courses/:id` | Non |
| 5. Ouvre Sources | Bottom sheet fichiers | Reel | `GET /courses/:id/sources` | Non |
| 6. Ajoute PDF | Upload en processing | Reel local/dev | `POST /courses/:id/sources/course-pdf` | Non immediat |
| 7. PDF traite | Source passe ready | Reel si worker actif, simule en fixture | jobs document | Oui pour extraction KU |
| 8. Ouvre fiche rapide | Fiche lisible | Reel via adapter document sheet | `GET /courses/:id/sheet` | Oui si generation absente |
| 9. Lance revision rapide | Session demarre | Reel | `POST /courses/:id/revision-sessions` | Eventuellement pour generation |
| 10. Repond question | Validation et feedback | Reel via activites existantes | activities/rich closed | Non en tests mockes |
| 11. Voit resultat | Score et prochaines etapes | Reel derive | `GET /revision-sessions/:id/result` | Non |
| 12. Voit progression | Cours et points faibles maj | Reel derive ou fixture | `GET /subjects/:id/progress` | Non |

Commandes de validation a prevoir par lot :

- Flutter : `dart analyze lib test`
- Flutter : tests router et widgets cibles
- Flutter : tests features courses/revision_sessions/activities
- API : tests unitaires modules courses/study-artifacts/revision-sessions
- API : e2e happy path course -> source -> sheet -> session -> result -> progress
- Anti-regression : rich closed V1 conserve, Today conserve, revision sessions conserve

## 12. Risques et arbitrages

| Risque | Probabilite | Impact | Mitigation |
|---|---:|---:|---|
| Creer un `Course` model trop tot et trop large | Moyenne | Eleve | Ajouter seulement `Course` + `CourseSource`, reporter `CourseKnowledgeUnit` |
| Garder `Document` comme Course trop longtemps | Elevee si Option A | Eleve | Adapter transitoire limite au MVP-03, suppression au MVP-05 |
| Design system trop abstrait | Moyenne | Moyen | Composants concrets lies aux ecrans MVP, pas de generiques inutiles |
| Casser les routes existantes | Moyenne | Eleve | Alias temporaires, tests router, ne pas supprimer `/activities/rich-closed` |
| Session trop generique | Moyenne | Moyen | `POST /courses/:id/revision-sessions` mappe explicitement le mode |
| Progression fausse ou trompeuse | Moyenne | Eleve | Afficher seulement des scores derives, labels prudents, pas de table Progress prematuree |
| Sur-ingenierie IA | Elevee | Eleve | Reutiliser fiches document-level avant course-level generation |
| Duplication widgets/pages | Elevee sans DS | Moyen | Lot MVP-01 obligatoire avant pages |
| Upload source partiellement cree | Moyenne | Eleve | Transaction ou cleanup si document cree mais CourseSource echoue |
| UI dark premium illisible en petits ecrans | Moyenne | Moyen | Tests labels longs, max-width, scroll, tap targets |
| Rich closed readiness pas totalement vert | Moyenne | Eleve | Corriger les blocages V1-025 avant demo finale |

## 13. Recommandation finale

Verdict : faire un MVP en 12 lots.

Ordre conseille :

1. Design system V2.
2. Navigation V2.
3. Accueil matiere active avec adapter transitoire.
4. Backend Course minimal.
5. Branchement Flutter Course API.
6. Detail cours V2.
7. Sources bottom sheet + ajout source.
8. Fiche de lecture V2.
9. Hub Revisions V2.
10. Session de revision focus.
11. Resultat de session + Progres simple.
12. Polish, fixtures, tests, demo.

Ce qu'il faut faire maintenant :

- creer le design system cible avant de toucher aux pages ;
- ajouter le shell de navigation cible avec alias legacy ;
- construire vite une home visible avec donnees adaptees ;
- introduire ensuite le vrai modele Course minimal ;
- brancher l'UI sur l'API Course et supprimer l'adapter document.

Ce qu'il faut repousser apres MVP :

- `CourseKnowledgeUnit` many-to-many ;
- `SessionResult` persiste en table ;
- table `Progress` ou snapshots analytics ;
- generation IA course-level multi-sources avancee ;
- personnalisation fine des streaks/points ;
- refonte complete des flows rich closed ;
- suppression definitive des routes legacy ;
- design system desktop avance.

Arbitrage principal : le produit doit devenir course-centric, mais le passage doit etre progressif. L'erreur serait de faire soit une grosse migration conceptuelle avant d'avoir une UI, soit une jolie UI qui continue de mentir en affichant les documents comme des cours. La roadmap propose un compromis : UI visible rapidement, puis vrai modele `Course` minimal, puis raccordement propre.

## 14. Review critique et auto-critique du plan

### Review coherence

- Le premier lot est bien le design system.
- Le second lot est bien la navigation/shell.
- Le plan ne demande aucune implementation dans ce document.
- Le plan ne demande pas de migration dans ce lot-ci.
- `Document` devient une source dans la cible.
- Les routes legacy sont conservees temporairement.
- Les endpoints existants sont reutilises quand ils sont suffisants.
- Le scoring rich closed reste backend.
- Les widgets rich closed existants ne sont pas reecrits.

### Points discutables du prompt ou du plan

- Le prompt demande une experience Duolingo-like, mais le risque de gamification superficielle est reel. Le plan limite volontairement les streaks/points aux compteurs affichables sans en faire le moteur du MVP.
- Le prompt pousse vers `CourseKnowledgeUnit`, mais l'ajouter tout de suite peut etre trop couteux. Le plan recommande de le reporter tant que `CourseSource -> Document -> KnowledgeUnit` suffit.
- Le prompt veut une UI premium, mais le code actuel possede deja des widgets visuels. Le plan ne recommande pas de tout jeter : il propose un nouveau namespace DS et une migration progressive.
- Le plan introduit un adapter transitoire documents-vers-cours au MVP-03 alors qu'il recommande `Course`. C'est volontaire pour rendre la nouvelle UI visible vite, mais cet adapter doit etre supprime au MVP-05.
- Le resultat de session sans table dediee peut etre limite. C'est acceptable au MVP si le DTO annonce clairement ce qui est derive.

### Auto-critique

Ce plan est ambitieux pour un MVP parce qu'il touche a la fois au design system, a la navigation, au modele produit et aux endpoints. Le decoupage en 12 lots reduit le risque, mais il faudra resister a la tentation de fusionner les lots backend Course, sources et progression. Le point le plus fragile est l'agregation de fiche et progression par cours a partir de donnees encore document-level. La mitigation est de rester honnete dans les DTOs et d'eviter toute promesse pedagogique que les donnees ne prouvent pas encore.
