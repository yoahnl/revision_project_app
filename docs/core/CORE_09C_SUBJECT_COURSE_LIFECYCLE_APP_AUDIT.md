# CORE-09C Subject & Course Lifecycle App Audit

## 1. État actuel des endpoints matière/cours

Avant CORE-09C, l'app savait lister/créer des matières, créer/ouvrir des cours et supprimer certains éléments via les contrats existants. Elle ne disposait pas d'une décision backend officielle pour afficher `Renommer`, `Archiver` ou `Supprimer` selon l'état réel.

## 2. État actuel des suppressions

La suppression côté UI était soit absente, soit trop directe pour les matières. Les actions de gestion ne pouvaient pas distinguer proprement :

- élément vide supprimable ;
- élément utilisé à archiver ;
- élément bloqué.

## 3. Relations Prisma dangereuses

Côté app, ces relations ne sont pas manipulées directement. Le risque UI était d'afficher une action destructive sans demander la décision backend. CORE-09C déplace donc la vérité lifecycle côté API et expose un modèle Flutter de décision.

## 4. Ce qui peut être supprimé

L'app affiche une suppression définitive seulement si la décision backend indique `recommendedAction = DELETE` et `canDelete = true`.

## 5. Ce qui doit être archivé

L'app affiche une archive si la décision backend indique `recommendedAction = ARCHIVE` et `canArchive = true`. L'archive est présentée comme un retrait des listes actives, avec conservation de l'historique.

## 6. Ce qui doit être bloqué

L'app affiche un état/action indisponible lisible si le backend bloque la décision. Les codes machine ne sont pas affichés à l'utilisateur.

## 7. Surfaces UI concernées

Surfaces auditées et modifiées :

- `CourseDetailPage`
- `SubjectsHomePage`
- `SubjectDetailPage`
- repositories HTTP cours/matières
- providers/controllers cours/matières
- fakes et tests associés.

## 8. Dette laissée volontairement hors scope

Hors CORE-09C :

- historique/restauration des archives ;
- page dédiée de gestion avancée ;
- refonte navigation ;
- affichage des archives ;
- CORE-10/CORE-11.

## 9. Recherche statique d'audit

Recherche exécutée :

```bash
rg -n "deleteSubject|deleteCourse|archiveSubject|archiveCourse|updateSubject|updateCourse|renameSubject|renameCourse|subjectId|courseId|Gestion des matières|Supprimer|Archiver|Renommer" lib test
```

Les occurrences `subjectId`/`courseId` restent attendues dans les routes, repositories et tests, pas dans les libellés utilisateur des sheets de gestion.
