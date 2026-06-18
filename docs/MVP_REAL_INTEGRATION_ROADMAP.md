# Roadmap technique — MVP intégré réel

Date d'audit : 18 juin 2026  
Frontend : `/Users/karim/Project/app-révision/revision_app`  
Backend : `/Users/karim/Project/app-révision/api`  
Livrable : roadmap de remplacement des mocks par une intégration réelle, sans implémentation applicative.

## 1. Résumé exécutif

### Verdict

Constat : l'application contient deux couches distinctes.

La couche réelle existe déjà pour l'authentification, les matières, les documents, l'upload PDF, le traitement asynchrone, les knowledge units, les fiches document-level, les activités, les rich closed exercises, Today, les mastery states et une première version de revision sessions.

La nouvelle expérience Duolingo-like introduite côté Flutter est une démonstration locale. Elle est visuellement utile et testée, mais les matières, cours, sources, fiches, questions, résultats, streak, gems et progression du parcours principal viennent de fixtures sous `lib/features/mvp` et du singleton `MvpStudyController.instance`.

Recommandation : conserver la direction visuelle et les composants de design system, mais remplacer progressivement la source de données du parcours principal par une architecture réelle `Subject -> Course -> CourseSource -> Document -> DocumentChunk -> KnowledgeUnit`.

### Ce qui est réel aujourd'hui

- Auth Firebase et bootstrap `/students/me` via `AuthController`, `FirebaseAuthRepository` et `HttpStudentProfileBootstrapper`.
- CRUD minimal des matières via `GET/POST/DELETE /subjects`.
- Upload PDF réel via `POST /documents/course-pdf`.
- Pipeline document : stockage, job BullMQ, extraction texte, chunking, extraction de knowledge units, statuts `UPLOADED / PROCESSING / READY / FAILED`.
- Fiches et summaries document-level via `/documents/:documentId/summary` et `/documents/:documentId/revision-sheet`.
- QCM, open questions, rich closed exercises et corrections backend.
- Mastery update pour QCM et open questions.
- Revision sessions backend avec `start`, `get` et `next-action`.
- Tests backend et frontend sur les anciens parcours réels.

### Ce qui est démonstration locale

- `MvpSubject`, `MvpCourse`, `MvpSourceFile`, `MvpSessionQuestion`.
- Matière active, cours visibles, sources, key points, common mistakes, weak spots.
- Session MVP et résultat `78% / 4/5 bonnes`.
- Streak `12`, gems `870`, anneau `7 jours`.
- Boutons d'ajout de matière/source dans les écrans MVP.
- Fallback silencieux sur le premier cours via `courseOrFallback`.

### Réutilisable

- UI directionnelle et tokens sous `lib/presentation/design_system`.
- Routes et pages MVP comme maquette fonctionnelle, à rebrancher sur providers réels.
- Modules Flutter réels `subjects`, `documents`, `activities`, `revision_sessions`, `today`, `auth`.
- Backend actuel pour documents, artifacts, activités, rich closed, mastery et sessions.
- Tests existants comme garde-fous de non-régression.

### À remplacer

- `MvpStudyController.instance` par providers Riverpod.
- Fixtures `mvpSubjects` et `mvpSessionQuestions` par repositories HTTP.
- Fallback course silencieux par états `not-found`.
- Scores et progression statiques par résultats et mastery backend.
- `Document` utilisé implicitement comme cours par un vrai modèle `Course`.

### Nombre de lots conseillé

Recommandation : 11 lots d'intégration, `INT-00` à `INT-10`.  
Chemin critique : `Course/CourseSource` Prisma -> API Course -> branchement Accueil/détail -> upload source réel -> fiche course -> modes/session -> résultat -> progression -> suppression des mocks.

## 2. Audit frontend réel

### Sources inspectées

- `lib/app/router/app_router.dart`
- `lib/app/router/app_routes.dart`
- `lib/core/routing/route_paths.dart`
- `lib/presentation/shell/revision_home_shell.dart`
- `lib/features/mvp/application/mvp_study_controller.dart`
- `lib/features/mvp/domain/mvp_study_models.dart`
- `lib/features/mvp/presentation/mvp_home_page.dart`
- `lib/features/mvp/presentation/mvp_course_detail_page.dart`
- `lib/features/mvp/presentation/mvp_course_sheet_page.dart`
- `lib/features/mvp/presentation/mvp_revisions_page.dart`
- `lib/features/mvp/presentation/mvp_revision_session_page.dart`
- `lib/features/mvp/presentation/mvp_session_result_page.dart`
- `lib/features/mvp/presentation/mvp_progress_page.dart`
- `lib/features/mvp/presentation/mvp_sources_page.dart`
- `lib/features/mvp/presentation/mvp_page_helpers.dart`
- `lib/presentation/design_system/components/revision_mvp_components.dart`
- `lib/presentation/design_system/tokens/revision_colors.dart`
- `lib/presentation/design_system/tokens/revision_spacing.dart`
- `lib/presentation/design_system/tokens/revision_radius.dart`
- `lib/presentation/design_system/tokens/revision_shadows.dart`
- `lib/presentation/design_system/tokens/revision_typography.dart`
- `lib/app/di/providers.dart`
- `lib/app/di/infrastructure_providers.dart`
- `lib/app/di/revision_providers.dart`
- `lib/features/subjects/data/http_subjects_repository.dart`
- `lib/features/subjects/application/subjects_notifier.dart`
- `lib/features/documents/data/documents_api.dart`
- `lib/features/documents/application/documents_controller.dart`
- `lib/features/documents/application/subject_documents_notifier.dart`
- `lib/features/documents/domain/revision_document.dart`
- `lib/features/activities/data/http_activities_api.dart`
- `lib/features/activities/application/activity_controller.dart`
- `lib/features/activities/application/rich_closed_exercise_flow_controller.dart`
- `lib/features/revision_sessions/data/http_revision_sessions_api.dart`
- `lib/features/revision_sessions/data/revision_sessions_api.dart`
- `lib/features/revision_sessions/application/revision_session_controller.dart`
- `lib/features/revision_sessions/domain/revision_session.dart`
- `lib/features/today/data/http_today_repository.dart`
- `lib/features/today/application/today_notifier.dart`
- `lib/features/today/domain/today_plan.dart`
- `lib/features/auth/application/auth_controller.dart`
- `lib/features/auth/data/firebase_auth_repository.dart`
- `lib/features/auth/data/http_student_profile_bootstrapper.dart`
- `test/app/router/app_router_test.dart`
- `test/app/revision_app_test.dart`
- `docs/MVP_DUOLINGO_LIKE_PLAN.md`
- `docs/MVP_DUOLINGO_LIKE_IMPLEMENTATION_REPORT.md`
- `design-qa.md`

### Synthèse par zone

| Élément | État actuel | Réel ou mock | Réutilisable | Action requise |
|---|---|---|---|---|
| Routing | `GoRouter` démarre sur `/home`, anciennes routes conservées | Mixte | Oui | Remplacer builders MVP par pages branchées providers réels, garder aliases legacy |
| Shell | `RevisionHomeShell` + bottom/rail navigation 5 onglets | Réel UI | Oui | Conserver la structure, alimenter badges/états par données réelles |
| Auth | `AuthController` + Firebase + `/students/me` | Réel | Oui | Garder comme prérequis de tous les repositories réels |
| Active subject | `MvpStudyController._activeSubjectId` local | Mock | Partiel UI | Créer `activeSubjectProvider` Riverpod, persistance locale optionnelle |
| Courses | `MvpCourse` dans `mvpSubjects` | Mock | UI card reusable | Ajouter `Course` backend + `CoursesRepository` |
| Sources | `MvpSourceFile` local | Mock | `RevisionSourceFileCard` | Brancher `CourseSource` + `RevisionDocument.status` |
| Course detail | `MvpCourseDetailPage` lit `courseOrFallback` | Mock | Oui visuel | Remplacer fallback par loading/error/not-found et `CourseDetail` |
| Sheets | `MvpCourseSheetPage` génère texte depuis fixture | Mock | UI segments/panels | Brancher `CourseSheet` backend |
| Revision modes | `MvpRevisionMode` influence surtout textes/routes | Mock fonctionnel | Libellés/UI | Mapper vers backend `RevisionSessionMode` |
| Session questions | `mvpSessionQuestions` globales | Mock | Layout session | Remplacer par actions `RevisionSession` + activités existantes |
| Session result | `RevisionMasteryRing(value: 0.78)` statique | Mock | Layout résultat | Brancher `RevisionSessionResult` backend |
| Progress | `activeMastery` moyenne de fixtures | Mock | UI progress | Brancher `SubjectProgress` / `CourseProgress` |
| Streak | `RevisionMasteryRing` affiche `7 jours` | Mock | Visuel | Masquer MVP réel ou implémenter après MVP |
| Gems | `RevisionTopCounters` affiche `870` | Mock | Visuel | Masquer MVP réel ou feature flag demo |
| Source upload | Bouton `+` snackbar | Mock/no-op | UI sheet/FAB | Brancher file picker + `POST /courses/:courseId/sources/course-pdf` |
| Subject creation | Bouton `Ajouter une matière` sans action dans MVP sheet | No-op | Ancien onboarding réel | Router vers création réelle ou masquer |
| Documents feature | `DocumentsApi` upload/list/get/delete + knowledge/artifacts | Réel | Oui | Réutiliser sous `CourseSource`, ne pas dupliquer |
| Activities feature | HTTP QCM/open/rich closed + parsers stricts | Réel | Oui | Piloter via session réelle plutôt que session locale |
| Revision sessions Flutter | `start/get` seulement | Partiel réel | Oui | Ajouter `nextAction`, action completion, result |
| Today | `/today` réel, parsé strictement | Réel | Oui | Ajouter contexte course ou adapter affichage |
| Tests | Tests MVP in-memory + tests features réelles | Mixte | Oui | Ajouter contrats Course, providers, route not-found et cutover |

### Points précis confirmés dans le code

Constat :

- `MvpStudyController` est un singleton global `ChangeNotifier`.
- `MvpStudyController.courseOrFallback` retourne `resumeCourse` si l'id est inconnu.
- `MvpHomePage`, `MvpProgressPage`, `MvpRevisionsPage`, `MvpSourcesPage` utilisent `AnimatedBuilder(animation: MvpStudyController.instance)`.
- `MvpCourseDetailPage` fabrique des session ids comme `session-${course.id}-${mode.name}`.
- `MvpRevisionSessionPage` lit `mvpSessionQuestions[_questionIndex]`.
- `MvpSessionResultPage` affiche un score fixe `78%` et `4/5 bonnes`.
- `showMvpSourcesSheet` et `MvpSourcesPage` affichent un snackbar au clic sur `+`.
- `MvpCourseSheetPage` utilise `course.keyPoints`, `course.commonMistakes` et `course.sources.first`.
- Les modèles MVP contiennent `Color` et `IconData`, ce qui ne doit pas devenir un modèle métier réel.

Recommandation :

- Conserver les widgets de présentation, mais sortir toute donnée métier de `features/mvp`.
- Remplacer `Color/IconData` métier par `iconKey` et `colorKey` résolus côté design system.
- Supprimer les fallbacks silencieux dès `INT-00`.

## 3. Audit backend réel

### Sources inspectées

- `prisma/schema.prisma`
- `package.json`
- `src/modules/subjects/interfaces/subjects.controller.ts`
- `src/modules/subjects/application/list-subjects.use-case.ts`
- `src/modules/subjects/application/create-subject.use-case.ts`
- `src/modules/documents/interfaces/documents.controller.ts`
- `src/modules/documents/application/upload-course-pdf.use-case.ts`
- `src/modules/documents/application/documents.repository.ts`
- `src/modules/documents/infrastructure/prisma-documents.repository.ts`
- `src/modules/jobs/infrastructure/document-processing.consumer.ts`
- `src/modules/study-artifacts/interfaces/study-artifacts.controller.ts`
- `src/modules/study-artifacts/application/get-revision-sheet.use-case.ts`
- `src/modules/study-artifacts/application/generate-revision-sheet.use-case.ts`
- `src/modules/study-artifacts/infrastructure/prisma-study-artifacts.repository.ts`
- `src/modules/activities/interfaces/activities.controller.ts`
- `src/modules/activities/application/submit-activity-result.use-case.ts`
- `src/modules/activities/application/submit-open-answer.use-case.ts`
- `src/modules/activities/application/rich-closed-questions/submit-rich-closed-exercise.use-case.ts`
- `src/modules/activities/application/rich-closed-questions/get-rich-closed-exercise-result.use-case.ts`
- `src/modules/revision/interfaces/today.controller.ts`
- `src/modules/revision/application/get-today-plan.use-case.ts`
- `src/modules/revision/infrastructure/prisma-revision.repository.ts`
- `src/modules/revision-sessions/interfaces/revision-sessions.controller.ts`
- `src/modules/revision-sessions/application/start-revision-session.use-case.ts`
- `src/modules/revision-sessions/application/request-next-revision-session-action.use-case.ts`
- `src/modules/revision-sessions/infrastructure/prisma-revision-sessions.repository.ts`
- `test/critical-paths.e2e-spec.ts`

### Capacités réelles et écarts MVP

| Capacité | Modèle/use case actuel | Endpoint actuel | Écart MVP |
|---|---|---|---|
| Profil étudiant | `StudentProfile`, `BootstrapStudentUseCase` | `GET /students/me` | Suffisant |
| Matières | `Subject`, `Create/List/Get/DeleteSubjectUseCase` | `GET/POST/DELETE /subjects` | Ajouter éventuels compteurs/progress dans read model |
| Course | Aucun modèle `Course` | Aucun | À créer |
| CourseSource | Aucun modèle `CourseSource` | Aucun | À créer |
| Upload PDF | `UploadCoursePdfUseCase`, `Document` | `POST /documents/course-pdf` | Adapter avec `courseId` et création `CourseSource` |
| Documents par matière | `ListSubjectDocumentsUseCase` | `GET /subjects/:subjectId/documents` | Devient source technique, pas cours principal |
| Statut source | `Document.status`, `errorCode` | `GET /documents/:documentId` | Exposer via `CourseSource.status` |
| Processing | `DocumentProcessingConsumer`, BullMQ | Job interne | Suffisant, polling côté API/UI à cadrer |
| Knowledge units | `KnowledgeUnit`, `DocumentChunk`, `KnowledgeUnitSource` | `GET /documents/:documentId/knowledge-units` | Ajouter agrégat course-level |
| Summary document | `Summary` | `GET/POST /documents/:documentId/summary` | Non prioritaire pour l'écran fiche course |
| Revision sheet document | `RevisionSheet` | `GET/POST /documents/:documentId/revision-sheet` | Composer ou générer une fiche course |
| Diagnostic quiz | `ActivitySession`, `Question`, `ActivityResult` | `/activities/next`, `/:sessionId/result` | Déjà réutilisable sous mode session |
| Open question | `OpenQuestion`, `OpenAnswerEvaluation` | `/activities/open-question`, `/:sessionId/open-answer` | Déjà réutilisable sous mode approfondi/examen |
| Rich closed | `RichClosedExercisePayload/Result` | `/activities/rich-closed/*` | Déjà réutilisable ; noter mastery update manquant |
| Mastery | `MasteryState`, `RevisionRepository.upsertMastery` | Pas d'endpoint progress dédié | Ajouter read models subject/course |
| Today | `GetTodayPlanUseCase`, `AdaptivePlanService` | `GET /today` | Ajouter course context ou mapping UI |
| Revision session start/get | `RevisionSession`, `RevisionSessionAction` | `POST /revision-sessions`, `GET /revision-sessions/:id` | Ajouter `courseId`, mode, result, completion robuste |
| Next action | `RequestNextRevisionSessionActionUseCase` | `POST /revision-sessions/:id/next-action` | Flutter ne l'appelle pas encore |
| Session completion | Statut existe en Prisma | Aucun endpoint observé | À ajouter ou calculer via lifecycle |
| Session result | Pas de read model dédié | Aucun | À créer comme endpoint calculé |
| Progression cours | `MasteryState` disponible par knowledge unit | Aucun | À créer par agrégation CourseSource/Documents |
| Ownership | Relations `studentId` et `subjectId` nombreuses | Guards + repositories | À reproduire pour Course/CourseSource |
| E2E | `test/critical-paths.e2e-spec.ts` couvre routes critiques | Jest e2e | Étendre au happy path Course |

### Point important : absence confirmée de Course

Constat : `prisma/schema.prisma` ne contient ni `model Course` ni `model CourseSource`. La recherche sur `CourseSource` ne remonte aucun modèle, et les seules occurrences `course` côté API concernent l'upload de PDF nommé `course-pdf`.

Recommandation : ne pas continuer à maquiller `Document` en `Course` dans le parcours principal. Le document doit redevenir une source attachée au cours.

## 4. Matrice mock → donnée réelle

| Donnée frontend actuelle | Emplacement actuel | Source réelle cible | Endpoint cible | Transformation |
|---|---|---|---|---|
| `MvpSubject` | `mvp_study_models.dart` | `Subject` + `SubjectProgress` | `GET /subjects`, `GET /subjects/:id/progress` | `id/name/priority` + stats calculées |
| `MvpSubject.subtitle` | Fixture | Texte UI dérivé | Front | Dériver de `CourseProgress` ou masquer |
| `MvpSubject.accent` | `Color` dans modèle | `colorKey` | `Subject.presentation.colorKey` post-MVP ou mapping local | Résoudre dans design system |
| `MvpSubject.icon` | `IconData` dans modèle | `iconKey` | Mapping local MVP | Résoudre dans design system |
| `MvpCourse.title` | Fixture | `Course.title` | `GET /subjects/:subjectId/courses` | Champ direct |
| `chapterLabel` | Fixture | `Course.chapterLabel` nullable | Course endpoints | Afficher si non nul, sinon `N sources` |
| `description` | Fixture | `Course.description` ou description générée | `GET /courses/:courseId` | Champ nullable avec fallback empty state |
| `completedLessons` | Fixture | À remplacer | `GET /courses/:courseId/progress` | Ne pas afficher comme leçon si aucune notion de leçon réelle |
| `totalLessons` | Fixture | `knowledgeUnitCount` ou `readySourceCount` | `GET /courses/:courseId/progress` | Libellé `notions` plutôt que `leçons` |
| `durationMinutes` | Fixture | `Course.estimatedMinutes` ou mode duration | Course endpoints | Direct, nullable avec valeur UI neutre |
| `difficulty` | Fixture | `Course.difficulty` ou agrégat KU | Course endpoints | Enum `LOW/MEDIUM/HIGH` mappé en label |
| `mastery` | Fixture | Moyenne pondérée `MasteryState` | `GET /courses/:courseId/progress` | `0..1`, arrondi UI |
| `sources` | `MvpSourceFile[]` | `CourseSource` + `Document` | `GET /courses/:courseId/sources` | `fileName/status/errorCode/displayOrder/isPrimary` |
| `learnItems` | Fixture | `KnowledgeUnit.title/summary` | `GET /courses/:courseId/knowledge-units` | Top 2-4 units prêtes |
| `keyPoints` | Fixture | `RevisionSheet.keyPoints` course-level | `GET /courses/:courseId/sheet?mode=rapid` | Agrégation depuis sources prêtes |
| `commonMistakes` | Fixture | `RevisionSheet.commonMistakes` | `GET /courses/:courseId/sheet?mode=complete|exam` | Agrégation backend |
| `weakSpot` | Fixture | Knowledge unit faible | `GET /courses/:courseId/progress` | Min mastery + titre |
| `mvpSessionQuestions` | Fixture globale | Activity/revision action payloads | `POST /revision-sessions`, `POST /revision-sessions/:id/next-action` | Payload typé existant |
| Score statique `78%` | `MvpSessionResultPage` | `RevisionSessionResult.score` | `GET /revision-sessions/:id/result` | Score calculé backend |
| `4/5 bonnes` | `MvpSessionResultPage` | `correctAnswers/totalQuestions` | `GET /revision-sessions/:id/result` | Agrégat actions |
| Streak `12` | `RevisionTopCounters` | Post-MVP | Aucun MVP | Masquer en mode réel MVP |
| Gems `870` | `RevisionTopCounters` | Post-MVP | Aucun MVP | Masquer en mode réel MVP |
| Anneau `7 jours` | `MvpHomePage` | Post-MVP streak réel | Aucun MVP | Remplacer par `sources prêtes` ou masquer |
| Mode `quick/deep/exam` | `MvpRevisionMode` | `RevisionSession.mode` | `POST /revision-sessions` | Ajouter enum backend |
| Session id local | `session-${course.id}-${mode.name}` | `RevisionSession.id` | `POST /revision-sessions` | Retour backend |
| Bouton `+` source | Snackbar | Upload multipart | `POST /courses/:courseId/sources/course-pdf` | File picker + polling |
| Course invalide | `courseOrFallback` | Not found | `GET /courses/:courseId` -> 404 | Afficher état not-found |

Décision : streak et gems sont post-MVP. Ils doivent être masqués ou affichés uniquement en mode `demo`, jamais en production avec des valeurs fictives.

## 5. Décision de modèle Course

### Modèle Prisma minimal recommandé

```prisma
model Course {
  id               String   @id @default(cuid())
  studentId        String
  subjectId        String
  title            String
  description      String?
  chapterLabel     String?
  estimatedMinutes Int?
  difficulty       KnowledgeUnitDifficulty?
  displayOrder     Int      @default(0)
  iconKey          String?
  colorKey         String?
  createdAt        DateTime @default(now())
  updatedAt        DateTime @updatedAt

  student StudentProfile @relation(fields: [studentId], references: [id], onDelete: Cascade)
  subject Subject        @relation(fields: [subjectId, studentId], references: [id, studentId], onDelete: Cascade)
  sources CourseSource[]

  @@index([studentId])
  @@index([subjectId, studentId])
  @@unique([id, studentId])
  @@unique([subjectId, title])
}

model CourseSource {
  id           String   @id @default(cuid())
  courseId     String
  studentId    String
  subjectId    String
  documentId   String
  displayOrder Int      @default(0)
  role         String?
  isPrimary    Boolean  @default(false)
  createdAt    DateTime @default(now())

  course   Course   @relation(fields: [courseId, studentId], references: [id, studentId], onDelete: Cascade)
  document Document @relation(fields: [documentId, subjectId], references: [id, subjectId], onDelete: Restrict)

  @@index([studentId])
  @@index([courseId])
  @@index([documentId])
  @@unique([courseId, documentId])
  @@unique([courseId, displayOrder])
}
```

### Cardinalité

Recommandation MVP :

- `Subject 1 -> N Course`.
- `Course 1 -> N CourseSource`.
- `CourseSource N -> 1 Document`.
- Un `Document` ne devrait être attaché qu'une seule fois au même cours.
- Un `Document` peut être attaché à plusieurs cours seulement si un besoin produit explicite apparaît. Pour le MVP, garder la possibilité technique via `CourseSource`, mais empêcher les duplications accidentelles côté use case.

### Ownership

Constat : l'API actuelle protège déjà beaucoup de relations avec `studentId` et `subjectId`.

Recommandation :

- `Course.studentId` obligatoire.
- `CourseSource.studentId` dénormalisé pour simplifier les requêtes ownership.
- Toutes les requêtes Course doivent filtrer par `studentId`.
- `Course.subjectId` doit référencer `(Subject.id, Subject.studentId)`.
- `CourseSource.documentId` doit vérifier que le document appartient au même étudiant et à la même matière.

### Contraintes uniques et index

- `@@unique([id, studentId])` sur `Course` pour relations sécurisées.
- `@@unique([subjectId, title])` à discuter : utile pour éviter doublons visibles, mais peut être trop strict si l'utilisateur veut deux cours homonymes. Alternative plus souple : index simple + validation UI.
- `@@unique([courseId, documentId])` sur `CourseSource`.
- `@@unique([courseId, displayOrder])` si l'ordre est stable.
- Index `studentId`, `subjectId`, `courseId`, `documentId`.

### Cascades et suppression

Recommandation :

- Suppression d'un `Subject` : cascade vers `Course`, `CourseSource`, `Document` déjà cascade via subject.
- Suppression d'un `Course` : supprimer ses `CourseSource`, mais ne supprimer les `Document` associés que si l'action utilisateur dit explicitement "supprimer aussi les fichiers". Pour le MVP, `DELETE /courses/:courseId` doit refuser ou archiver si des sources existent, ou supprimer cours + liens seulement. Éviter une suppression destructrice implicite des documents.
- Suppression d'une source : `DELETE /courses/:courseId/sources/:sourceId` doit supprimer le lien ; supprimer le `Document` seulement si aucune autre source ne le référence et si le produit l'assume.

### Source principale

Recommandation : utiliser `isPrimary` sur `CourseSource`. Maintenir au plus une source principale par cours via logique transactionnelle. La première source ajoutée devient primaire.

### `CourseKnowledgeUnit`

Décision MVP : ne pas créer `CourseKnowledgeUnit`.

Justification : les knowledge units peuvent être dérivées des `Document` attachés via `CourseSource`. Une table dédiée n'est utile que si l'on veut éditer un curriculum course-level, fusionner/dédoublonner des notions entre documents, ou ordonner manuellement les units. C'est post-MVP.

### `SessionResult`

Décision MVP : résultat de session calculé comme read model à la demande.

Justification : `ActivityResult`, `OpenAnswerEvaluation`, `RichClosedExerciseResult`, `RevisionSessionAction` et `MasteryState` existent déjà. Un endpoint `GET /revision-sessions/:sessionId/result` peut agréger ces tables sans ajouter immédiatement une table `SessionResult`. Si les performances ou l'audit historique l'exigent, persister un snapshot post-MVP.

## 6. Création d'un cours et ajout de la première source

### Option A — Créer le cours, puis importer une source

Principe : l'utilisateur crée un cours avec titre/matière, puis ajoute un PDF depuis le détail du cours.

Avantages :

- Contrat simple.
- Le cours existe même si l'upload échoue.
- L'utilisateur garde le contrôle du titre.
- Facile à tester et à backfiller.

Inconvénients :

- Une étape de plus.
- Possibilité de cours vide.

### Option B — Importer un fichier et créer automatiquement le cours depuis le nom du fichier

Avantages :

- Rapide.
- Compatible avec l'ancien mental model document-centric.

Inconvénients :

- Risque de titres mauvais.
- Encourage `Document` comme faux `Course`.
- Difficile pour plusieurs sources d'un même cours.

### Option C — Importer un fichier, laisser l'IA proposer le titre, puis confirmation

Avantages :

- Meilleure UX à terme.
- Peut proposer chapitre, difficulté et description.

Inconvénients :

- Dépend du pipeline IA.
- Plus lent.
- Plus risqué pour un MVP intégré.

### Choix MVP

Recommandation : Option A.

Parcours :

1. Accueil ou Sources -> bouton `+`.
2. Bottom sheet "Nouveau cours".
3. Champs obligatoires : matière active, titre.
4. Champs optionnels : description, chapitre, durée estimée, difficulté.
5. `POST /subjects/:subjectId/courses`.
6. Redirection vers `/courses/:courseId`.
7. CTA "Ajouter une source".
8. File picker PDF.
9. `POST /courses/:courseId/sources/course-pdf`.
10. La source apparaît `UPLOADED`, puis `PROCESSING`, puis `READY` ou `FAILED`.

Comportement si le PDF échoue :

- Le cours reste créé.
- La source affiche `FAILED` et `errorCode`.
- L'utilisateur peut supprimer la source ou réessayer.

Comportement si le cours est créé mais la source échoue :

- Pas de rollback du cours.
- État empty clair : "Ajoute une source pour générer la fiche et les révisions".

## 7. API Course et CourseSource

### Endpoints existants à réutiliser

- `GET /subjects`
- `POST /subjects`
- `GET /subjects/:subjectId/documents` pendant la migration/backfill uniquement.
- `GET /documents/:documentId`
- `GET /documents/:documentId/knowledge-units`
- `GET/POST /documents/:documentId/revision-sheet`
- `POST /activities/next`
- `POST /activities/open-question`
- `POST /activities/rich-closed/start`
- `POST /revision-sessions`
- `GET /revision-sessions/:sessionId`
- `POST /revision-sessions/:sessionId/next-action`

### Endpoints nouveaux ou adaptés

| Endpoint | Statut | Justification | MVP |
|---|---|---|---|
| `GET /subjects/:subjectId/courses` | Nouveau | Liste course-centric de l'accueil | Oui |
| `POST /subjects/:subjectId/courses` | Nouveau | Création explicite de cours | Oui |
| `GET /courses/:courseId` | Nouveau | Détail course + sources + stats légères | Oui |
| `PATCH /courses/:courseId` | Nouveau | Édition titre/description/order | MVP minimal ou post |
| `DELETE /courses/:courseId` | Nouveau | Gestion cours | MVP si création incluse |
| `GET /courses/:courseId/sources` | Nouveau | Bottom sheet sources réel | Oui |
| `POST /courses/:courseId/sources/course-pdf` | Nouveau adaptant upload | Upload source attachée | Oui |
| `DELETE /courses/:courseId/sources/:sourceId` | Nouveau | Suppression lien/source | Oui |
| `GET /courses/:courseId/knowledge-units` | Nouveau agrégat | Fiche/session/progress course-level | Oui |
| `GET /courses/:courseId/sheet?mode=rapid|complete|exam` | Nouveau agrégat | Fiche course visible | Oui |
| `POST /courses/:courseId/sheet?mode=rapid|complete|exam` | Nouveau agrégat/generation | Générer si absent | Oui |
| `POST /revision-sessions` | Adapté | Ajouter `courseId` et `mode` | Oui |
| `POST /revision-sessions/:sessionId/next-action` | Existant, Flutter à brancher | Continuer session réelle | Oui |
| `POST /revision-sessions/:sessionId/actions/:actionId/complete` | Nouveau recommandé | Marquer action terminée proprement | Oui |
| `GET /revision-sessions/:sessionId/result` | Nouveau | Résultat global session | Oui |
| `GET /subjects/:subjectId/progress` | Nouveau | Page Progrès matière | Oui |
| `GET /courses/:courseId/progress` | Nouveau | Course cards et détail | Oui |

### Contrats endpoint

#### `GET /subjects/:subjectId/courses`

- Request : auth bearer, path `subjectId`.
- Response : `CourseListItem[]`.
- Erreurs : `401`, `404 Subject not found`.
- Ownership : filtrer `subjectId + studentId`.
- Idempotence : oui.
- Prisma : `Course`, agrégats `CourseSource`, `Document`, `MasteryState`.
- MVP : oui.

#### `POST /subjects/:subjectId/courses`

- Request :

```json
{
  "title": "Loi normale",
  "description": "Statistiques inférentielles",
  "chapterLabel": "Chapitre 3",
  "estimatedMinutes": 20,
  "difficulty": "MEDIUM",
  "iconKey": "chart",
  "colorKey": "blue"
}
```

- Response : `CourseDetail`.
- Erreurs : `400 title invalid`, `404 Subject not found`, `409 duplicate if unique title kept`.
- Ownership : `subjectId` doit appartenir au student.
- Idempotence : non, sauf clé optionnelle post-MVP.
- Prisma : crée `Course`.
- MVP : oui.

#### `GET /courses/:courseId`

- Response : `CourseDetail`.
- Inclure : course, subject résumé, sources, progress léger, canStart flags.
- Erreurs : `404 Course not found`.
- Ownership : `courseId + studentId`.
- MVP : oui.

#### `PATCH /courses/:courseId`

- Request : subset éditable `title/description/chapterLabel/estimatedMinutes/difficulty/iconKey/colorKey/displayOrder`.
- Erreurs : `400`, `404`, `409`.
- MVP : optionnel. Peut être post-MVP si création/suppression suffit.

#### `DELETE /courses/:courseId`

- Recommandation : MVP minimal avec suppression du cours et des liens `CourseSource`, sans supprimer `Document` par défaut.
- Erreurs : `404`, `409 Course has active processing source` si nécessaire.
- Prisma : transaction.

#### `GET /courses/:courseId/sources`

- Response : `CourseSource[]`.
- Chaque source contient `sourceId`, `documentId`, `fileName`, `mimeType`, `status`, `errorCode`, `displayOrder`, `isPrimary`, `createdAt`.
- Ownership : `Course.studentId`.
- MVP : oui.

#### `POST /courses/:courseId/sources/course-pdf`

- Request multipart : `file`.
- Response : `CourseSource`.
- Erreurs : `400 file missing`, `400 non PDF`, `413 too large`, `404 course`, `409 duplicate source`.
- Ownership : `courseId + studentId`.
- Idempotence : non ; post-MVP avec checksum.
- Prisma : transaction `Document` + `CourseSource` + `DocumentProcessingJob`.
- MVP : oui.

#### `DELETE /courses/:courseId/sources/:sourceId`

- Response : `204`.
- Erreurs : `404`.
- Ownership : `courseId + sourceId + studentId`.
- Suppression : lien seulement par défaut.
- MVP : oui.

#### `GET /courses/:courseId/knowledge-units`

- Response :

```json
{
  "courseId": "course_1",
  "items": [
    {
      "id": "ku_1",
      "title": "Standardisation",
      "summary": "...",
      "difficulty": "MEDIUM",
      "documentId": "doc_1",
      "sources": [{ "chunkId": "chunk_1", "pageNumber": 2, "index": 3 }]
    }
  ]
}
```

- Erreurs : `404`, `409 no ready sources`.
- MVP : oui.

#### `GET /courses/:courseId/sheet?mode=rapid|complete|exam`

- Response : `CourseSheet`.
- Erreurs : `404 course`, `404 sheet not generated`, `409 no ready source`, `422 invalid mode`.
- MVP : oui.

#### `POST /courses/:courseId/sheet?mode=rapid|complete|exam`

- Comportement MVP : générer les fiches document-level manquantes pour sources prêtes puis composer un read model course-level.
- Erreurs : `409 source processing`, `502 generation failed`.
- MVP : oui.

#### `POST /revision-sessions`

- Adapter request :

```json
{
  "subjectId": "subject_1",
  "courseId": "course_1",
  "mode": "quick",
  "preferredAction": "rich_closed_exercise"
}
```

- Response : `RevisionSessionSummary` + `currentAction`.
- Ownership : course appartient au student et à la subject.
- Prisma : ajouter `courseId` et `mode` à `RevisionSession`.
- MVP : oui.

#### `POST /revision-sessions/:sessionId/actions/:actionId/complete`

- Request :

```json
{
  "activitySessionId": "activity_1"
}
```

- Comportement : vérifie que l'activité liée est soumise/complétée, marque l'action `COMPLETED`, calcule éventuellement si session terminée.
- Justification : le backend possède `RevisionSessionActionStatus`, mais aucun endpoint observé ne marque clairement une action comme terminée.
- MVP : oui.

#### `GET /revision-sessions/:sessionId/result`

- Response : `RevisionSessionResult`.
- Agrège `ActivityResult`, `OpenAnswerEvaluation`, `RichClosedExerciseResult`, actions et mastery.
- MVP : oui.

#### `GET /subjects/:subjectId/progress` et `GET /courses/:courseId/progress`

- Response : `SubjectProgress` / `CourseProgress`.
- Calcul : agrégats `MasteryState` sur knowledge units des sources prêtes.
- MVP : oui.

## 8. DTO frontend cibles

### Règles générales

- Parsing strict : champ obligatoire absent ou type incorrect -> `FormatException`.
- Pas de `Color`, pas de `IconData` dans les modèles métier.
- `iconKey` et `colorKey` restent des clés de présentation.
- Les dates arrivent en ISO string et sont converties en `DateTime`.
- Les statuts inconnus deviennent `unknown` uniquement si l'UI a un état sûr ; sinon rejet.

### `CourseListItem`

- `id: String`
- `subjectId: String`
- `title: String`
- `description: String?`
- `chapterLabel: String?`
- `estimatedMinutes: int?`
- `difficulty: CourseDifficulty?`
- `iconKey: String?`
- `colorKey: String?`
- `sourceCount: int`
- `readySourceCount: int`
- `knowledgeUnitCount: int`
- `mastery: double?`
- `lastPracticedAt: DateTime?`
- Usage UI : accueil, listes cours, recommandation.

### `CourseDetail`

- `course: CourseListItem`
- `subjectName: String`
- `sources: List<CourseSource>`
- `progress: CourseProgress?`
- `canGenerateSheet: bool`
- `canStartRevision: bool`
- Usage UI : détail cours.

### `CourseSource`

- `id: String`
- `courseId: String`
- `documentId: String`
- `fileName: String`
- `mimeType: String`
- `status: CourseSourceStatus`
- `errorCode: String?`
- `sizeLabel: String?` ou `sizeBytes: int?`
- `displayOrder: int`
- `isPrimary: bool`
- `createdAt: DateTime`
- Usage UI : bottom sheet sources, page sources, processing.

### `CourseKnowledgeUnit`

- `id: String`
- `courseId: String`
- `documentId: String?`
- `title: String`
- `summary: String`
- `difficulty: CourseDifficulty?`
- `displayOrder: int?`
- `mastery: double?`
- `sources: List<DocumentArtifactSource>`
- Usage UI : learn items, sheet, session targeting, progress.

### `CourseSheet`

- `id: String`
- `courseId: String`
- `mode: CourseSheetMode`
- `status: StudyArtifactStatus`
- `title: String`
- `introduction: String?`
- `sections: List<CourseSheetSection>`
- `keyPoints: List<String>`
- `commonMistakes: List<String>`
- `mustKnow: List<String>`
- `practiceSuggestions: List<String>`
- `sources: List<DocumentArtifactSource>`
- `errorCode: String?`
- Usage UI : fiche rapide/complète/examen.

### `CourseProgress`

- `courseId: String`
- `mastery: double?`
- `knowledgeUnitCount: int`
- `practicedKnowledgeUnitCount: int`
- `readySourceCount: int`
- `processingSourceCount: int`
- `failedSourceCount: int`
- `lastActivityAt: DateTime?`
- `weakKnowledgeUnits: List<CourseKnowledgeUnitProgress>`
- `recommendedAction: RecommendedCourseAction?`
- Usage UI : cards, détail, progress.

### `SubjectProgress`

- `subjectId: String`
- `mastery: double?`
- `courseCount: int`
- `readyCourseCount: int`
- `readySourceCount: int`
- `totalSourceCount: int`
- `weakCourses: List<CourseListItem>`
- `recommendedCourse: CourseListItem?`
- Usage UI : page Progrès, top subject context.

### `RevisionSessionSummary`

- `id: String`
- `subjectId: String`
- `courseId: String`
- `mode: RevisionSessionMode`
- `status: RevisionSessionStatus`
- `currentAction: RevisionSessionAction?`
- `history: List<RevisionSessionAction>`
- `createdAt: DateTime`
- `completedAt: DateTime?`
- Usage UI : session page.

### `RevisionSessionAction`

- Réutiliser les payloads existants : diagnostic quiz, open question, rich closed exercise.
- Ajouter `actionId`, `status`, `displayOrder`, `activitySessionId`, `knowledgeUnitId`, `documentId`.
- Usage UI : router vers le bon renderer.

### `RevisionSessionResult`

- `sessionId: String`
- `mode: RevisionSessionMode`
- `courseId: String`
- `score: double?`
- `correctAnswers: int`
- `totalQuestions: int`
- `completedActions: int`
- `masteredKnowledgeUnits: List<CourseKnowledgeUnitProgress>`
- `weakKnowledgeUnits: List<CourseKnowledgeUnitProgress>`
- `masteryDelta: double?`
- `recommendedNextAction: RecommendedCourseAction?`
- `completedAt: DateTime`
- Usage UI : résultat post-session.

## 9. Architecture Flutter cible

### Structure recommandée

```text
lib/features/courses/
  domain/
    course.dart
    course_source.dart
    course_sheet.dart
    course_progress.dart
    courses_repository.dart
  data/
    http_courses_repository.dart
  application/
    courses_notifier.dart
    course_detail_notifier.dart
    course_sources_notifier.dart
    active_subject_provider.dart
  presentation/
    courses_home_page.dart
    course_detail_page.dart
    course_sheet_page.dart
    course_sources_sheet.dart

lib/features/progress/
  domain/
  data/
  application/
  presentation/

lib/features/revision_hub/
  presentation/

lib/features/revision_sessions/
  domain/
  application/
  data/
  presentation/
```

### Repository interface cible

```text
CoursesRepository
- listCourses(subjectId)
- createCourse(subjectId, input)
- getCourse(courseId)
- updateCourse(courseId, input)
- deleteCourse(courseId)
- listSources(courseId)
- uploadSource(courseId, file)
- deleteSource(courseId, sourceId)
- listKnowledgeUnits(courseId)
- getSheet(courseId, mode)
- generateSheet(courseId, mode)
- getCourseProgress(courseId)
- getSubjectProgress(subjectId)
```

### Providers Riverpod

Recommandation :

- `activeSubjectIdProvider` : source unique de matière active, initialisée depuis `subjectsNotifierProvider`.
- `activeSubjectProvider` : combine active id + `subjectsNotifierProvider`.
- `coursesProvider(subjectId)` : `AsyncValue<List<CourseListItem>>`.
- `courseDetailProvider(courseId)` : `AsyncValue<CourseDetail>`.
- `courseSourcesProvider(courseId)` : `AsyncValue<List<CourseSource>>`, auto-refresh/polling si source processing.
- `courseSheetProvider(courseId, mode)` : `AsyncValue<CourseSheet?>`.
- `courseProgressProvider(courseId)` : `AsyncValue<CourseProgress>`.
- `subjectProgressProvider(subjectId)` : `AsyncValue<SubjectProgress>`.
- `realRevisionSessionProvider(sessionId)` : charge session et current action.

### Cache et invalidation

- Après `createCourse` : invalider `coursesProvider(subjectId)` et `subjectProgressProvider`.
- Après `uploadSource` : invalider `courseDetailProvider`, `courseSourcesProvider`, `courseProgressProvider`.
- Pendant `PROCESSING` : polling borné sur `courseSourcesProvider`.
- Après activité soumise : invalider `courseProgressProvider`, `subjectProgressProvider`, `todayNotifierProvider`.
- Après `next-action` : invalider session provider.

### Persistance locale de la matière active

Hypothèse : `shared_preferences` est déjà disponible via `KvStoragePort`.

Recommandation : stocker `activeSubjectId` localement, mais valider au démarrage que le sujet existe encore pour l'étudiant. Sinon, choisir le premier sujet réel ou afficher empty state.

### Mode démo

Les repositories fake ne doivent être injectés que dans :

- tests ;
- mode demo explicite ;
- previews éventuelles.

Production : `HttpCoursesRepository` obligatoire.

## 10. Conservation et évolution du design system

Constat : le design system MVP est utile mais concentré. `revision_mvp_components.dart` fait 935 lignes et mélange de nombreux composants.

Recommandation structurelle :

```text
lib/presentation/design_system/components/
  revision_page_scaffold.dart
  revision_glass_card.dart
  revision_buttons.dart
  revision_subject_switcher.dart
  revision_course_card.dart
  revision_source_card.dart
  revision_mode_card.dart
  revision_progress.dart
  revision_bottom_sheet.dart
  revision_states.dart
  revision_mvp_components.dart  // barrel export transitoire
```

États communs à créer :

- loading ;
- empty ;
- error ;
- not-found ;
- processing ;
- failed ;
- retry.

Règles :

- Les composants restent purs : aucune logique métier, aucun appel API.
- Les pages métier ne recréent pas localement bouton, card, source row, segmented control, progress line, mastery ring ou bottom sheet frame.
- Les couleurs/icônes sont résolues par `iconKey`/`colorKey` via une registry de présentation.
- Pas de nouveau design system concurrent.

## 11. Upload réel d'une source

### Parcours MVP

```text
Course detail
-> Sources bottom sheet
-> bouton +
-> file picker PDF
-> POST /courses/:courseId/sources/course-pdf
-> création Document
-> création CourseSource
-> job BullMQ
-> UPLOADED
-> PROCESSING
-> READY ou FAILED
-> refresh UI
```

### Polling recommandé

Décision MVP : polling simple.

- Fréquence : toutes les 2 secondes.
- Durée maximale : 2 minutes par upload visible.
- Arrêt : toutes les sources du cours sont `READY` ou `FAILED`, l'écran est quitté, ou timeout.
- Timeout UI : afficher "Traitement encore en cours, reviens dans un instant" avec refresh manuel.
- Pas de websocket/SSE pour le MVP.

### Cas d'erreur

- Fichier trop grand : afficher message lié à `413` ou `Document file is too large`.
- Mauvais MIME type : afficher "PDF uniquement".
- Document sans texte : `DOCUMENT_TEXT_EMPTY`.
- Extraction échouée : `DOCUMENT_TEXT_EXTRACTION_FAILED`.
- Knowledge extraction vide : `KNOWLEDGE_EXTRACTION_EMPTY`.
- Source invalid : `KNOWLEDGE_SOURCE_INVALID`.
- Upload créé mais source échoue : garder source `FAILED`, bouton retry.
- Orphelin storage : le use case actuel supprime le fichier si la création document échoue ; conserver cette garantie.

## 12. Fiches réelles

### Option A — Utiliser la fiche de la source principale

Avantages : rapide, réutilise `RevisionSheet` document-level existant.  
Inconvénients : ignore les autres sources.

### Option B — Composer une fiche course-level depuis toutes les sources

Avantages : respecte le modèle multi-source sans nouvelle table lourde.  
Inconvénients : nécessite un agrégateur et une stratégie de dédoublonnage.

### Option C — Générer un nouvel artifact course-level

Avantages : meilleure qualité pédagogique.  
Inconvénients : nouveau contrat IA, nouvelle persistance, coût plus haut.

### Choix MVP

Recommandation : Option B en read model composé.

Comportement :

- Pour chaque source `READY`, charger ou générer sa `RevisionSheet` document-level.
- Composer une `CourseSheet` publique avec sections triées par source/displayOrder.
- Dédupliquer les `keyPoints` et `commonMistakes` de façon simple.
- Conserver les sources/chunks visibles.
- Si aucune source prête : `409 no ready source`.
- Si certaines sources processing : afficher un warning UI, mais permettre fiche partielle si au moins une source prête.

Stratégie post-MVP : Option C avec `CourseRevisionSheet` persistant si la qualité de composition est insuffisante.

Modes :

- `rapid` : résumé court, top key points, must know.
- `complete` : sections complètes, mistakes, sources.
- `exam` : must know, pièges, questions d'entraînement suggérées.

## 13. Modes de révision réels

### Règle centrale

Ne pas créer trois moteurs frontend. Une seule `StudySessionPage` doit être pilotée par :

- `RevisionSession.mode`;
- `RevisionSession.currentAction`;
- payload typé backend ;
- composants existants QCM/open/rich closed.

### Révision rapide

Objectif :

- 3 à 8 minutes ;
- peu de questions ;
- feedback immédiat ;
- notions fragiles prioritaires.

Backend :

- mode `quick`;
- actions autorisées : diagnostic quiz court, rich closed court ;
- 3 à 5 questions ;
- `questionCount` bas ;
- condition de fin : 1 à 2 actions complétées ou durée cible atteinte.

### Révision approfondie

Objectif :

- 10 à 25 minutes ;
- plusieurs formats ;
- explications détaillées ;
- au moins une question ouverte si knowledge unit disponible.

Backend :

- mode `deep`;
- actions autorisées : diagnostic quiz, rich closed, open question ;
- alternance via coach ou déterministe ;
- condition de fin : 3 à 5 actions ou demande utilisateur.

### Préparation examen

Objectif :

- difficulté élevée ;
- plus de questions ;
- `complexityProfile=exam` pour rich closed ;
- résultat final détaillé.

Backend :

- mode `exam`;
- actions autorisées : rich closed exam, diagnostic quiz plus long, open question ;
- feedback peut être différé au résultat final pour certains formats ;
- condition de fin : nombre d'actions/questions fixé.

### Entrée commune

```json
{
  "subjectId": "subject_1",
  "courseId": "course_1",
  "mode": "quick"
}
```

Le backend choisit les knowledge units depuis les sources prêtes du cours et les mastery states.

## 14. Cycle de vie réel d'une RevisionSession

### Cycle cible

```text
START
-> currentAction READY
-> réponse activité
-> résultat activité persisté
-> action COMPLETED
-> next-action
-> nouvelle action READY
-> fin de session
-> session COMPLETED
-> résultat agrégé
```

### Trous actuels observés

Constat :

- Backend : `POST /revision-sessions/:sessionId/next-action` existe.
- Frontend : `RevisionSessionsApi` expose seulement `startRevisionSession` et `getRevisionSession`.
- Prisma : `RevisionSessionAction.status` existe.
- Use cases observés : `appendAction` ajoute des actions `READY`.
- Aucun endpoint observé ne marque clairement une action `COMPLETED`.
- Aucun endpoint observé ne termine la session.
- `SubmitRichClosedExerciseUseCase` ne met pas à jour `MasteryState`, contrairement à QCM et open question.

### Recommandation MVP

Ajouter :

- `POST /revision-sessions/:sessionId/actions/:actionId/complete`
- `POST /revision-sessions/:sessionId/complete` ou completion automatique quand le mode atteint sa condition de fin.
- `GET /revision-sessions/:sessionId/result`.

Le frontend :

1. démarre session ;
2. rend current action ;
3. soumet l'activité au moteur existant ;
4. appelle complete action ;
5. appelle next-action ou complete session ;
6. charge result.

## 15. Résultat de session réel

### Contrat cible

```text
RevisionSessionResult
- sessionId
- mode
- courseId
- score
- correctAnswers
- totalQuestions
- completedActions
- masteredKnowledgeUnits
- weakKnowledgeUnits
- masteryDelta
- recommendedNextAction
- completedAt
```

### Agrégation

- `ActivityResult` : `correctAnswers`, `totalQuestions`, `score`.
- `OpenAnswerEvaluation` : ratio `score/maxScore`, feedback, missing points.
- `RichClosedExerciseResult` : `correctAnswers`, `totalQuestions`, `score`.
- `RevisionSessionAction` : actions complétées, types, knowledge units.
- `MasteryState` : mastered/weak units après submit.

### Calcul MVP

Recommandation : calcul à la demande.

- `correctAnswers` : somme des résultats fermés.
- `totalQuestions` : somme QCM + rich closed ; open question compte comme 1 si score disponible.
- `score` : moyenne pondérée par nombre de questions ou maxScore.
- `completedActions` : actions `COMPLETED`.
- `masteryDelta` : comparer mastery avant/après seulement si snapshot disponible ; sinon `null` MVP.
- `recommendedNextAction` : dérivée du lowest mastery.

Post-MVP : persister un snapshot `RevisionSessionResult` si besoin d'historique exact.

## 16. Progression réelle

### Formule MVP

```text
courseMastery =
  moyenne des MasteryState.score des knowledge units
  issues des documents attachés au cours
```

Règles :

- Sans source prête : `mastery = null`, état `empty`.
- Sources en processing : afficher processing, pas de score artificiel.
- Sans activité mais knowledge units prêtes : `mastery = 0` ou `null` à décider. Recommandation : `0` avec libellé "Pas encore pratiqué".
- Knowledge unit sans mastery : score `0` dans la moyenne si on veut encourager la pratique ; `null` si on veut mesurer seulement pratiqué. Recommandation MVP : `0`, mais afficher `practicedKnowledgeUnitCount`.
- Weak units : lowest scores, puis units jamais pratiquées.
- Arrondis : UI en pourcentage entier, backend en `0..1`.

### Métriques compatibles existant

- `readySourceCount`.
- `processingSourceCount`.
- `failedSourceCount`.
- `knowledgeUnitCount`.
- `practicedKnowledgeUnitCount`.
- `lastPracticedAt`.
- `averageMastery`.
- `weakKnowledgeUnits`.

Ne pas afficher `3/7 leçons` tant qu'aucune vraie notion de leçon n'existe.

## 17. Stratégie de migration des données existantes

Constat : le backend possède des documents attachés directement aux matières.

Backfill recommandé :

1. Pour chaque `Document` existant `COURSE_PDF`, créer un `Course`.
2. Titre : dériver de `fileName` sans extension, normalisé.
3. `subjectId` et `studentId` : copiés du document.
4. `displayOrder` : ordre stable par `createdAt`.
5. Créer `CourseSource` vers le `Document`.
6. Première source `isPrimary = true`.
7. Ne pas dupliquer `Document`, `Summary`, `RevisionSheet`, `KnowledgeUnit`.
8. Idempotence : si un `CourseSource` existe déjà pour le document, ne rien recréer.
9. Rollback : supprimer uniquement les `CourseSource` et `Course` créés par backfill si un flag/marqueur est ajouté, sinon rollback manuel impossible sans risque.
10. Deep links legacy `/subjects/:subjectId/documents/:documentId` restent valides jusqu'à suppression post-MVP.

Ne pas lancer cette migration dans cette mission.

## 18. Stratégie de migration frontend

Cutover progressif :

1. Introduire `features/courses` avec repositories/providers réels.
2. Garder le rendu visuel du MVP.
3. Ajouter mode `demo` explicite pour fixtures.
4. Supprimer `courseOrFallback`.
5. Remplacer l'accueil mock par `subjects + courses`.
6. Remplacer le détail cours par `CourseDetail`.
7. Remplacer les sources par `CourseSource`.
8. Remplacer la fiche par `CourseSheet`.
9. Remplacer la session locale par `RevisionSession`.
10. Remplacer le résultat par `RevisionSessionResult`.
11. Remplacer la progression par `CourseProgress/SubjectProgress`.
12. Supprimer `mvp_study_models.dart`, `mvp_study_controller.dart`.
13. Renommer les pages `mvp_*` vers `courses_*` ou les supprimer au profit des nouvelles.

Fichiers à conserver/adaptater :

- Conserver : design tokens, cards, buttons, source rows, mode cards.
- Adapter : `mvp_home_page.dart`, `mvp_course_detail_page.dart`, `mvp_course_sheet_page.dart`, `mvp_revisions_page.dart`, `mvp_sources_page.dart`, `mvp_progress_page.dart`.
- Supprimer fin de cutover : `mvp_study_models.dart`, `mvp_study_controller.dart`, `mvp_revision_session_page.dart` si remplacée par session réelle.

## 19. Feature flag et mode démo

Modes recommandés :

```text
real
demo
test
```

Règles :

- `real` : défaut production, HTTP repositories, aucune fixture métier.
- `demo` : activation explicite via config locale/dev, fixtures autorisées.
- `test` : fakes in-memory injectées par `ProviderScope`.

Le mode réel ne doit jamais afficher Math/Loi normale si ces données ne viennent pas du backend de l'utilisateur connecté.

Implémentation Flutter :

- `AppConfig.dataMode`.
- Providers conditionnels dans `revision_providers.dart`.
- Tests qui vérifient que `real` utilise `HttpCoursesRepository`.

## 20. États UI réels

| Écran | Loading | Empty | Error | Not-found | Processing | Ready | Failed | Retry |
|---|---|---|---|---|---|---|---|---|
| Accueil | skeleton cards | aucune matière/cours | reload | sujet actif supprimé | sources en cours sur cards | cours listés | source failed visible | reload courses |
| Détail cours | header skeleton | aucune source | reload | course 404 | source processing | CTA session enabled si units | source failed | retry upload |
| Sources | spinner/pull refresh | aucune source | reload | course 404 | badge processing + polling | file card ready | errorCode | retry/delete |
| Fiche | loader | aucune source prête | regenerate/retry | course 404 | fiche partielle ou attente | sections | generation failed | regenerate |
| Hub révisions | loader | aucun cours prêt | reload | sujet 404 | modes disabled si processing only | modes enabled | warning | reload |
| Session | loader action | aucune action | retry | session 404 | activité loading | action renderer | action failed | retry action |
| Résultat | loader | session non terminée | retry | session 404 | calcul en cours | result | result failed | reload |
| Progrès | skeleton | pas de données | reload | subject 404 | sources processing | stats | warnings | reload |

## 21. Tests requis

### Backend

- Course entity/use case validation.
- Course ownership cross-student.
- CourseSource creation and uniqueness.
- Upload source attaches document to correct course.
- Upload source rejects non-PDF and oversize.
- Processing status visible through course source.
- `GET /courses/:id` 404 cross-student.
- Delete source does not delete unrelated document.
- Course knowledge units aggregate only attached documents.
- Course sheet rapid/complete/exam contracts.
- Revision session start with `courseId` and `mode`.
- Next-action scoped to course knowledge units.
- Action completion marks `RevisionSessionAction.COMPLETED`.
- Session completion and result aggregation.
- Course progress formula.
- Backfill idempotence.
- E2E happy path.

### Frontend

- DTO parsing for `CourseListItem`, `CourseDetail`, `CourseSource`, `CourseSheet`, `CourseProgress`, `RevisionSessionResult`.
- HTTP repository request/response/error mapping.
- Providers loading/error/empty/not-found.
- Active subject switch with real subjects.
- Courses list real data.
- Unknown course route displays not-found, no fallback.
- Upload source calls multipart endpoint.
- Processing polling stops correctly.
- Course sheet modes.
- Revision modes produce correct backend requests.
- Session page handles QCM/open/rich closed actions.
- Next-action flow.
- Result page displays backend score only.
- Progress page displays real progress only.
- Small width and accessibility.
- Demo mode does not leak into real mode.

### Contrats

- Backend contract tests for JSON shape.
- Frontend parser tests for the same fixtures.
- Anti-drift tests for enum strings: modes, statuses, action kinds, source statuses.

## 22. Lots d'intégration

### INT-00 — Stabilisation de la couche frontend MVP

- Objectif : rendre la couche MVP prête à être rebranchée sans nouvelle dette.
- Valeur utilisateur : aucun changement visible majeur, mais moins de comportements trompeurs.
- Scope : supprimer fallback silencieux, introduire abstraction repository, mode demo explicite, états async, découpage minimal design system.
- Non-objectifs : pas d'API Course, pas de refonte UI.
- Frontend tasks : créer interfaces `CoursesRepository`, `DemoCoursesRepository`, providers, not-found route state, masquer streak/gems en real.
- Backend tasks : aucune.
- Prisma/data tasks : aucune.
- API contracts : aucun nouveau.
- Fichiers probablement concernés : `lib/features/mvp/**`, `lib/app/di/revision_providers.dart`, `lib/presentation/design_system/components/revision_mvp_components.dart`, tests app.
- Tests : route course inconnue, demo vs real provider, no fake counters in real.
- Commandes : `dart analyze lib test`, `flutter test test/app --reporter compact`, `flutter test test/features/subjects --reporter compact`.
- Critères d'acceptation : aucun fallback silencieux, fixtures uniquement en demo/test.
- Risques : trop toucher l'UI ; mitigation : aucun changement visuel majeur.
- Dépendances : aucune.
- Estimation : S, 1-2 jours.

### INT-01 — Course et CourseSource Prisma

- Objectif : ajouter les modèles centraux.
- Valeur utilisateur : fondation pour vrais cours multi-sources.
- Scope : Prisma schema, migration dev, repositories backend, tests repository.
- Non-objectifs : pas de branchage Flutter.
- Frontend tasks : aucune.
- Backend tasks : entités/use cases Course/CourseSource.
- Prisma/data tasks : `Course`, `CourseSource`, relations `StudentProfile/Subject/Document`.
- API contracts : internes seulement.
- Fichiers : `prisma/schema.prisma`, migrations, `src/modules/courses/**`, app module.
- Tests : repository create/list/get/delete, ownership.
- Commandes : `npm test -- courses --runInBand`, `npm run build`, `npm run lint:check`.
- Critères : modèles générés, ownership strict.
- Risques : cascade destructive ; mitigation : tests suppression.
- Dépendances : INT-00 non bloquant.
- Estimation : M, 2-4 jours.

### INT-02 — Course API et migration/backfill

- Objectif : exposer Course API et convertir les documents existants.
- Valeur utilisateur : vrais cours visibles par API.
- Scope : endpoints courses, backfill idempotent, DTO publics.
- Non-objectifs : upload source course, fiches course.
- Frontend tasks : parser DTO en tests si voulu.
- Backend tasks : controllers, use cases, DTO mapping.
- Prisma/data tasks : script backfill non destructif.
- API contracts : `GET/POST /subjects/:subjectId/courses`, `GET/PATCH/DELETE /courses/:courseId`.
- Fichiers : `src/modules/courses/interfaces/courses.controller.ts`, `src/modules/courses/application/*`, tests e2e.
- Tests : ownership, invalid title, missing course, backfill idempotent.
- Commandes : `npm test -- courses --runInBand`, `npm run test:e2e -- --runInBand`.
- Critères : documents existants mappables sans duplication.
- Risques : backfill ambigu ; mitigation : dry-run obligatoire.
- Dépendances : INT-01.
- Estimation : M, 3-5 jours.

### INT-03 — Intégration réelle Accueil / détail cours / subject switcher

- Objectif : remplacer les cours mockés du parcours principal.
- Valeur utilisateur : voit ses vraies matières et ses vrais cours.
- Scope : `CoursesRepository` HTTP, providers, accueil, détail, subject switcher.
- Non-objectifs : upload source réel, session réelle.
- Frontend tasks : `HttpCoursesRepository`, parsers, pages branchées AsyncValue.
- Backend tasks : ajustements mineurs API Course.
- Prisma/data tasks : aucune hors backfill.
- API contracts : Course list/detail.
- Fichiers : `lib/features/courses/**`, `mvp_home_page.dart` ou nouvelle `courses_home_page.dart`, router tests.
- Tests : parsing, provider, empty/error/not-found, subject switch.
- Commandes : `dart analyze lib test`, `flutter test test/app --reporter compact`, `flutter test test/features/subjects --reporter compact`.
- Critères : aucune fixture sur home/detail en mode real.
- Risques : route legacy cassée ; mitigation : tests router.
- Dépendances : INT-02.
- Estimation : M, 3-5 jours.

### INT-04 — Sources réelles et upload PDF

- Objectif : brancher sources et bouton `+`.
- Valeur utilisateur : ajoute un PDF à un cours et voit son statut.
- Scope : endpoints sources, upload multipart, polling.
- Non-objectifs : course sheet multi-source.
- Frontend tasks : source sheet réel, file picker, polling, retry/delete.
- Backend tasks : `POST /courses/:id/sources/course-pdf`, list/delete sources.
- Prisma/data tasks : transaction Document + CourseSource + job.
- API contracts : CourseSource.
- Fichiers : `src/modules/courses/**`, `lib/features/courses/data/http_courses_repository.dart`, source widgets.
- Tests : upload, non-PDF, status, polling, failed state.
- Commandes : backend tests courses/documents, frontend documents/courses tests.
- Critères : snackbar mock supprimé.
- Risques : upload orphelin ; mitigation : transaction + cleanup storage.
- Dépendances : INT-03.
- Estimation : M, 3-5 jours.

### INT-05 — Fiche réelle par cours

- Objectif : remplacer `MvpCourseSheetPage` par une fiche issue des sources.
- Valeur utilisateur : lit une vraie fiche générée depuis ses PDFs.
- Scope : `CourseSheet` aggregator, modes rapid/complete/exam, UI states.
- Non-objectifs : nouvelle IA course-level persistée.
- Frontend tasks : parser `CourseSheet`, brancher segmented control.
- Backend tasks : `GET/POST /courses/:id/sheet`.
- Prisma/data tasks : réutiliser `RevisionSheet`, pas de table nouvelle MVP.
- API contracts : `CourseSheet`.
- Fichiers : study-artifacts + courses, `course_sheet_page`.
- Tests : no ready source, partial ready, generation failure, source refs.
- Commandes : `npm test -- study-artifacts --runInBand`, Flutter course sheet tests.
- Critères : key points/mistakes ne viennent plus de fixtures.
- Risques : agrégation pauvre ; mitigation : post-MVP `CourseRevisionSheet`.
- Dépendances : INT-04.
- Estimation : M, 3-5 jours.

### INT-06 — Modes de révision backend

- Objectif : donner un sens réel à rapide/approfondie/examen.
- Valeur utilisateur : choisit un mode qui influence la session.
- Scope : `RevisionSession.mode`, `courseId`, règles d'action par mode.
- Non-objectifs : nouvelle page session frontend complète.
- Frontend tasks : envoyer `courseId/mode`, adapter DTO.
- Backend tasks : migration `RevisionSession.courseId/mode`, sélection KU par course.
- Prisma/data tasks : modifier `RevisionSession`, `RevisionSessionAction` si besoin.
- API contracts : `POST /revision-sessions` adapté.
- Fichiers : `revision-sessions/**`, `prisma/schema.prisma`, Flutter API.
- Tests : mode quick/deep/exam, allowed actions, course ownership.
- Commandes : `npm test -- revision-sessions --runInBand`, Flutter revision session API tests.
- Critères : pas de session locale pour démarrer un mode.
- Risques : dupliquer moteur ; mitigation : réutiliser StartNext/Open/RichClosed.
- Dépendances : INT-03, INT-04.
- Estimation : L, 4-7 jours.

### INT-07 — Session frontend branchée au vrai moteur

- Objectif : remplacer `MvpRevisionSessionPage`.
- Valeur utilisateur : répond à de vraies activités issues de ses documents.
- Scope : session page unique, current action, next-action, completion action.
- Non-objectifs : résultat/progress final.
- Frontend tasks : `nextAction`, action completion, renderers existants.
- Backend tasks : endpoint action completion si pas fait en INT-06.
- Prisma/data tasks : action status.
- API contracts : `POST /revision-sessions/:id/actions/:actionId/complete`, `next-action`.
- Fichiers : `lib/features/revision_sessions/**`, rich closed flow integration.
- Tests : QCM/open/rich closed action flow, no local questions.
- Commandes : Flutter revision_sessions/activities tests, backend revision-sessions/activities.
- Critères : `mvpSessionQuestions` inutilisé en real.
- Risques : activité soumise mais action pas complétée ; mitigation : tests transactionnels.
- Dépendances : INT-06.
- Estimation : L, 5-8 jours.

### INT-08 — Résultat réel et mise à jour de maîtrise

- Objectif : remplacer score statique par résultat agrégé.
- Valeur utilisateur : voit son vrai score et ses vraies notions faibles.
- Scope : `GET /revision-sessions/:id/result`, rich closed mastery update, result UI.
- Non-objectifs : streak/gems.
- Frontend tasks : parser/result page.
- Backend tasks : agrégateur résultat, mastery update rich closed ou action-level update.
- Prisma/data tasks : pas de table result MVP.
- API contracts : `RevisionSessionResult`.
- Fichiers : `revision-sessions`, `activities/rich-closed`, result page.
- Tests : QCM/open/rich closed aggregation, score, weak/mastered units.
- Commandes : backend activities/revision-sessions, Flutter result tests.
- Critères : aucun `78%` codé en dur en real.
- Risques : formule contestable ; mitigation : documenter calcul.
- Dépendances : INT-07.
- Estimation : M, 3-5 jours.

### INT-09 — Progression réelle

- Objectif : brancher page Progrès et course cards.
- Valeur utilisateur : progression explicable et à jour.
- Scope : subject/course progress endpoints, UI progress.
- Non-objectifs : streak/gems/badges.
- Frontend tasks : providers progress, progress page.
- Backend tasks : read models progress.
- Prisma/data tasks : requêtes mastery + CourseSource + KnowledgeUnit.
- API contracts : `GET /subjects/:id/progress`, `GET /courses/:id/progress`.
- Fichiers : `src/modules/courses/progress`, `lib/features/progress/**`.
- Tests : no sources, processing, no mastery, cross-student.
- Commandes : backend courses/revision tests, Flutter progress tests.
- Critères : plus de moyenne de fixtures.
- Risques : progression trompeuse ; mitigation : afficher composants de formule.
- Dépendances : INT-08.
- Estimation : M, 3-5 jours.

### INT-10 — Suppression des mocks et durcissement e2e

- Objectif : finir le cutover MVP réel.
- Valeur utilisateur : parcours principal sans donnée fictive.
- Scope : supprimer fixtures production, e2e happy path, docs.
- Non-objectifs : nouvelles features post-MVP.
- Frontend tasks : supprimer `features/mvp` ou le limiter à demo, cleanup routes.
- Backend tasks : e2e happy path complet.
- Prisma/data tasks : valider backfill local/dev.
- API contracts : gel MVP.
- Fichiers : tests e2e, router, docs.
- Tests : happy path complet, anti-regression V1 rich closed, Today, sessions.
- Commandes : `flutter test --reporter compact`, `npm run test:e2e -- --runInBand`, lint/build/analyze.
- Critères : mode production sans fixture métier.
- Risques : retirer trop tôt les routes legacy ; mitigation : aliases et tests.
- Dépendances : INT-09.
- Estimation : M, 3-5 jours.

## 23. Happy path obligatoire

| Étape | Endpoint | Modèle | Page | État | Test | Erreur possible |
|---|---|---|---|---|---|---|
| 1 utilisateur authentifié | `GET /students/me` | `StudentProfile` | Shell | signed-in | auth bootstrap | 401 |
| 2 matière réelle chargée | `GET /subjects` | `Subject` | Accueil | ready | subjects provider | empty |
| 3 création cours | `POST /subjects/:id/courses` | `Course` | bottom sheet | created | course use case | 400/404/409 |
| 4 ajout PDF | `POST /courses/:id/sources/course-pdf` | `CourseSource + Document` | sources sheet | uploaded | upload widget/e2e | 400/413 |
| 5 upload réel | même endpoint | `Document.storagePath` | source card | uploaded | repository test | storage fail |
| 6 processing réel | job BullMQ | `DocumentProcessingJob` | source card | processing | job test | extraction fail |
| 7 KUs extraites | `GET /courses/:id/knowledge-units` | `KnowledgeUnit` | detail/sheet | ready | aggregate test | no chunks |
| 8 fiche réelle | `GET/POST /courses/:id/sheet` | `CourseSheet` | fiche | ready | sheet test | 409/502 |
| 9 révision rapide | `POST /revision-sessions` | `RevisionSession` | session | ready | mode test | no KU |
| 10 questions du fichier | current action/activity endpoints | `ActivitySession` | renderer action | ready | action payload tests | generation fail |
| 11 réponses soumises | activity submit endpoints | results | session | submitted | activity tests | invalid answer |
| 12 résultat calculé | `GET /revision-sessions/:id/result` | `RevisionSessionResult` | résultat | ready | result e2e | incomplete |
| 13 mastery mise à jour | internal + progress endpoints | `MasteryState` | progress | updated | mastery tests | KU missing |
| 14 Progrès à jour | `GET /courses/:id/progress` | `CourseProgress` | Progrès | ready | progress tests | stale cache |

## 24. Définition de done du MVP réel

Le MVP réel est terminé uniquement si :

- aucune fixture métier n'alimente le parcours production ;
- les matières viennent de l'API ;
- les cours viennent de l'API ;
- les sources viennent de l'API ;
- le bouton `+` importe réellement un PDF ;
- le statut PDF est réel ;
- la fiche vient du backend ;
- les questions viennent du backend ;
- le `sessionId` vient du backend ;
- les réponses sont persistées ;
- le score est calculé ;
- la progression est recalculée ;
- un utilisateur ne peut pas accéder aux données d'un autre ;
- les erreurs sont affichées proprement ;
- les tests critiques passent ;
- le design validé est conservé ;
- le repository de démo n'est pas actif en production ;
- les compteurs streak/gems sont masqués ou réels.

## 25. Éléments explicitement repoussés après MVP

- Streak réel.
- Gems réelles.
- Notifications.
- Répétition espacée avancée.
- Badges.
- Classement.
- Social.
- Partage de fiche.
- Offline complet.
- Websocket/SSE pour processing.
- Création automatique avancée de curriculum.
- Édition visuelle du graphe de connaissances.
- Course-level artifact IA persistant sophistiqué.
- Déduplication sémantique avancée des knowledge units multi-documents.

## 26. Risques

| Risque | Probabilité | Impact | Mitigation | Lot |
|---|---:|---:|---|---|
| Modèle Course trop complexe | Moyenne | Haut | Modèle minimal, pas de `CourseKnowledgeUnit` MVP | INT-01 |
| Backfill destructif | Moyenne | Haut | Dry-run, idempotence, pas de suppression documents | INT-02 |
| Duplication du moteur de session | Moyenne | Haut | Réutiliser activities + RevisionSession | INT-06/07 |
| CourseSource mal isolée par studentId | Faible | Haut | Tests cross-student, relations composites | INT-01/04 |
| Progression trompeuse | Moyenne | Moyen | Formule documentée, afficher counts | INT-09 |
| Fiche course-level trop coûteuse | Moyenne | Moyen | Composer document sheets MVP | INT-05 |
| Upload orphelin | Moyenne | Haut | Transaction + cleanup storage comme use case actuel | INT-04 |
| Session non terminable | Moyenne | Haut | Endpoint complete action/session | INT-07 |
| Dérive contrats JSON | Moyenne | Moyen | Tests contrat backend/frontend | INT-10 |
| Singleton mock persistant | Haute | Haut | Mode demo explicite et suppression finale | INT-00/10 |
| Deux design systems concurrents | Moyenne | Moyen | Barrel export unique, composants purs | INT-00 |
| Routes legacy cassées | Moyenne | Moyen | Aliases et router tests | INT-03/10 |
| `features/mvp` conservé trop longtemps | Haute | Moyen | Critère INT-10 explicite | INT-10 |
| Rich closed ne met pas à jour mastery | Moyenne | Moyen | Ajouter update mastery ou agrégat result explicite | INT-08 |

## 27. Recommandation finale

Nombre exact recommandé : 11 lots.

Chemin critique :

1. `INT-00` stabilise le front et empêche les faux comportements de production.
2. `INT-01` et `INT-02` créent la colonne vertébrale `Course/CourseSource`.
3. `INT-03` remplace les mocks visibles de l'accueil et du détail.
4. `INT-04` rend l'ajout de PDF réel.
5. `INT-05` rend les fiches réelles.
6. `INT-06` à `INT-08` branchent modes, session et résultat.
7. `INT-09` rend la progression réelle.
8. `INT-10` supprime les mocks et verrouille le happy path.

Premier lot conseillé : `INT-00 — Stabilisation de la couche frontend MVP`.

Décisions à valider avant développement :

- Un document peut-il être attaché à plusieurs cours dans le MVP ?
- `DELETE /courses/:courseId` supprime-t-il seulement le cours ou aussi les documents orphelins ?
- Les compteurs streak/gems sont-ils masqués en MVP réel ?
- La formule de mastery compte-t-elle les units jamais pratiquées comme `0` ou les exclut-elle ?
- Les fiches course-level MVP composent-elles toujours toutes les sources prêtes ou seulement la source principale ?

Fonctionnalités incluses dans le MVP :

- Auth.
- Matières réelles.
- Cours réels.
- Sources PDF réelles.
- Processing réel.
- Fiches course réelles composées.
- Trois modes de révision branchés au moteur existant.
- Résultats calculés.
- Progression course/subject réelle.

Fonctionnalités repoussées :

- Streak/gems.
- Badges/social/notifications.
- Websocket.
- Course-level IA artifact avancé.
- Curriculum automatique avancé.

### Auto-review

- Chaque valeur mockée identifiée a une source réelle cible.
- Chaque écran principal a une source de données réelle cible.
- Les lots produisent des tranches testables.
- Le design system est conservé et non remplacé.
- Aucun nouveau moteur parallèle n'est proposé.
- Aucune implémentation applicative n'a été incluse dans ce document.
- Incertitude signalée : stratégie exacte de suppression Course/Document et formule mastery doivent être validées produit avant implémentation.
