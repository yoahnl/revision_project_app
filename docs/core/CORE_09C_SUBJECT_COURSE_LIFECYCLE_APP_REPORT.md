# CORE-09C Subject & Course Lifecycle App Report

## 1. Résumé

L'app consomme maintenant le lifecycle backend des matières et cours : renommer, archiver ou supprimer safe selon la décision API, avec confirmations premium et messages utilisateur lisibles.

## 2. Audit initial

Audit détaillé : `docs/core/CORE_09C_SUBJECT_COURSE_LIFECYCLE_APP_AUDIT.md`.

Zones inspectées :

- `lib/features/subjects/`
- `lib/presentation/pages/subjects/`
- `lib/features/courses/`
- `lib/features/courses/presentation/`
- `lib/features/courses/application/`
- `lib/features/courses/domain/`
- `lib/features/courses/data/`
- `lib/app/router/`
- `test/features/subjects/`
- `test/features/courses/`
- `test/fakes/`

## 3. Sub-agents

- App Integration Agent : modèles lifecycle, repositories HTTP, providers et invalidations.
- UX/Wording Agent : confirmations delete/archive distinctes, aucun code technique affiché.
- QA Agent : tests repositories/controllers/widgets et full Flutter.
- Reviewer Agent : scope App + API, pas de navigation globale nouvelle, pas de données fictives.

## 4. Politique course lifecycle

L'app ne décide pas seule. Elle demande `GET /courses/:courseId/lifecycle`.

- `DELETE` : confirmation suppression définitive.
- `ARCHIVE` : confirmation archive avec conservation historique.
- `BLOCK` : message d'action indisponible.

## 5. Politique subject lifecycle

Même principe via `GET /subjects/:subjectId/lifecycle`.

Après archive/suppression d'une matière active, l'app nettoie la matière active locale et revient à une surface cohérente.

## 6. Migrations Prisma

Aucune migration côté app. Le contrat API repose sur la migration backend CORE-09C.

## 7. Endpoints consommés

Cours :

- `PATCH /courses/:courseId`
- `GET /courses/:courseId/lifecycle`
- `POST /courses/:courseId/archive`
- `DELETE /courses/:courseId`

Matières :

- `PATCH /subjects/:subjectId`
- `GET /subjects/:subjectId/lifecycle`
- `POST /subjects/:subjectId/archive`
- `DELETE /subjects/:subjectId`

## 8. UI ajoutée/modifiée

Ajouts :

- bottom sheet de gestion cours ;
- bottom sheet de gestion matière ;
- action `Gérer` sur le détail cours ;
- action `Gérer la matière` dans la gestion des matières ;
- action `Gérer` sur le détail matière.

Les confirmations `Archiver` et `Supprimer` ont des textes distincts.

## 9. Tests

Ajoutés/modifiés :

- parsing lifecycle cours/matières ;
- PATCH/archive/delete 409 lisible ;
- controllers sujets ;
- gestion cours depuis détail cours ;
- gestion matière depuis liste/détail ;
- fakes mis à jour.

## 10. Commandes exécutées

Résultats frais :

- `flutter --version` : Flutter `3.44.0`, Dart `3.12.0`.
- `flutter pub get` : exit `0`, dépendances résolues.
- `dart analyze lib test` : exit `0`, `No issues found!`.
- `flutter test test/app/router/app_router_test.dart --reporter compact` : exit `0`, 20 tests.
- `flutter test test/app/revision_app_test.dart --reporter compact` : exit `0`, 10 tests.
- `flutter test test/features/subjects --reporter compact` : exit `0`.
- `flutter test test/features/courses --reporter compact` : exit `0`.
- `flutter test test/features/profile --reporter compact` : exit `0`, 2 tests.
- `flutter test --reporter compact` : exit `0`, full suite passée.
- `dart format` ciblé sur les fichiers Dart modifiés : 22 fichiers, `0 changed`.

## 11. Recherches statiques

Recherche finale :

```bash
rg -n "COURSE_DELETE_BLOCKED|SUBJECT_DELETE_BLOCKED|HAS_REVISION_SESSIONS|HAS_QUESTION_BANK_ITEMS|foreign key|constraint|Prisma|payload|backend|cascade|subjectId|courseId" lib test
```

Résultat : 1309 lignes, dominées par routes, repositories, fakes et tests utilisant `subjectId`/`courseId`. Les codes lifecycle techniques ne sont pas affichés dans les libellés utilisateur des sheets.

## CORE-09C-bis hardening fixes

- Le test `HttpCoursesRepository.updateCourse` vérifie maintenant que la réponse `PATCH /courses/:courseId` contient les compteurs complets `sourceCount`, `readySourceCount`, `processingSourceCount` et `failedSourceCount`.
- Aucun workaround parser n'a été ajouté côté Flutter : le contrat attendu reste corrigé côté API.
- Aucun lien juridique, rename `Neralune`, workflow CI, Xcode Cloud ou UI produit n'a été modifié par CORE-09C-bis.
- Note hors lot : `macos/Runner.xcodeproj/xcshareddata/xcodecloud/manifest.json` était déjà modifié dans le working tree avant cette reprise ; il n'a pas été modifié ni revert par ce lot.

Tests ciblés exécutés pendant le durcissement :

- `flutter test test/features/courses/http_courses_repository_test.dart --reporter compact` : OK, 24 tests.
- `flutter --version` : Flutter 3.44.0, Dart 3.12.0.
- `flutter pub get` : OK, avec avertissement habituel de dépendances plus récentes incompatibles avec les contraintes.
- `dart analyze lib test` : OK, aucun issue.
- `flutter test test/app/router/app_router_test.dart --reporter compact` : OK, 20 tests.
- `flutter test test/features/courses --reporter compact` : OK, 67 tests.
- `flutter test test/features/subjects --reporter compact` : OK, 28 tests.
- `flutter test test/features/documents --reporter compact` : OK, 39 tests.
- `flutter test test/app/revision_app_test.dart --reporter compact` : OK, 10 tests.
- `flutter test --reporter compact` : OK, full suite à 477 tests.

Note validation : une tentative parallèle de suites Flutter a échoué sur des locks/artefacts natifs macOS (`startup lock`, `objective_c.dylib`). Les mêmes suites relancées séquentiellement sont vertes.

Confirmation backend Flutter : aucune logique métier app n'a été étendue hors vérification du contrat existant.

Confirmation Git : aucun commit effectué pendant CORE-09C-bis.

## 12. Limitations

- Pas d'écran d'historique des archives.
- Pas de restauration d'élément archivé.
- Pas de gestion avancée multi-sélection.

## 13. Dette restante

- Historique/restauration des archives.
- Ajustements UX fins éventuels après test réel.
- CORE-10A et CORE-11 restent des lots séparés.

## 14. Fichiers créés/modifiés/supprimés

Créés :

- `lib/features/courses/presentation/widgets/course_management_sheet.dart`
- `lib/presentation/pages/subjects/widgets/subject_management_sheet.dart`
- `docs/core/CORE_09C_SUBJECT_COURSE_LIFECYCLE_APP_AUDIT.md`
- `docs/core/CORE_09C_SUBJECT_COURSE_LIFECYCLE_APP_REPORT.md`

Modifiés :

- `lib/features/courses/application/courses_providers.dart`
- `lib/features/courses/data/http_courses_repository.dart`
- `lib/features/courses/domain/course_models.dart`
- `lib/features/courses/domain/courses_repository.dart`
- `lib/features/courses/presentation/course_detail_page.dart`
- `lib/features/subjects/application/subjects_controller.dart`
- `lib/features/subjects/application/subjects_notifier.dart`
- `lib/features/subjects/data/http_subjects_repository.dart`
- `lib/features/subjects/domain/subject.dart`
- `lib/presentation/pages/subjects/subject_detail_page.dart`
- `lib/presentation/pages/subjects/subjects_home_page.dart`
- `test/fakes/in_memory_courses_repository.dart`
- `test/fakes/in_memory_subjects_repository.dart`
- `test/features/courses/course_detail_page_test.dart`
- `test/features/courses/http_courses_repository_test.dart`
- `test/features/onboarding/onboarding_page_test.dart`
- `test/features/subjects/http_subjects_repository_test.dart`
- `test/features/subjects/subject_detail_page_test.dart`
- `test/features/subjects/subjects_controller_test.dart`
- `test/features/subjects/subjects_home_page_test.dart`
- `docs/roadmap/v2/DECISIONS_V2.md`
- `docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md`
- `docs/roadmap/v2/LOT_TRACKER_V2.md`
- `docs/roadmap/v2/REVISION_PROJECT_ROADMAP_V2.md`
- `docs/roadmap/v2/UX_UI_TARGET_V2.md`

Supprimés : aucun.

## 15. Contenu complet des fichiers créés/modifiés/supprimés

Le contenu complet est disponible dans le diff Git local. Ce rapport ne s'inclut pas lui-même pour éviter une récursion documentaire.

## 16. Auto-review

- L'app ne crée pas de décision lifecycle locale.
- Les actions destructives demandent la décision backend.
- Les codes techniques sont mappés en messages lisibles.
- Aucune nouvelle navigation globale.
- Aucun backend Flutter fictif ou mock runtime.

## 17. Critique du prompt

Le prompt CORE-09C-bis est bien borné côté app : il évite de compenser un bug de réponse API par un parser permissif Flutter. La seule modification app utile est donc un test de contrat plus strict.

## 18. Confirmation aucun commit

Aucun commit, amend, merge, rebase, push, tag ou branche n'a été créé.
