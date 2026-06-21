# STAB-02B — Canonical Flow Isolation, Feature Extraction & Legacy Deprecation

## 1. Résumé

STAB-02B isole le parcours frontend canonique de Neralune sans supprimer brutalement les anciennes routes. Le CTA `Réviser` du détail matière ne pointe plus vers l'ancien flow Activities : il ouvre le hub `Réviser` canonique. Les routes legacy restent accessibles directement pour compatibilité et sont documentées dans l'inventaire V2.

Le lot extrait aussi des widgets lourds ou clairement autonomes :

- bottom sheet Sources du détail cours ;
- bottom sheet de sélection du nombre de questions quick ;
- carte source du détail matière.

## 2. Audit initial

Fichiers audités :

- `lib/app/router/app_router.dart`
- `lib/app/router/app_routes.dart`
- `lib/core/routing/route_paths.dart`
- `lib/presentation/shell/revision_home_shell.dart`
- `lib/features/courses/presentation/courses_home_page.dart`
- `lib/features/courses/presentation/course_detail_page.dart`
- `lib/features/courses/presentation/course_revision_sheet_page.dart`
- `lib/features/courses/presentation/revisions_pending_page.dart`
- `lib/features/courses/presentation/subject_progress_page.dart`
- `lib/features/courses/presentation/course_quick_revision_launcher.dart`
- `lib/presentation/pages/revision_sessions/revision_session_page.dart`
- `lib/presentation/pages/revision_sessions/revision_session_result_page.dart`
- `lib/presentation/pages/profile/profile_page.dart`
- `lib/presentation/pages/subjects/subjects_home_page.dart`
- `lib/presentation/pages/subjects/subject_detail_page.dart`
- `lib/presentation/pages/onboarding/onboarding_page.dart`
- `lib/presentation/pages/today/`
- `lib/presentation/pages/activities/`
- `lib/features/activities/`
- `lib/presentation/pages/documents/`
- `lib/presentation/widgets/`
- `lib/presentation/theme/`
- `lib/presentation/design_system/`
- `test/app/`
- `test/features/courses/`
- `test/features/revision_sessions/`
- `test/features/subjects/`
- `test/features/activities/`
- `test/features/today/`
- `test/features/documents/`

Constats :

- Le shell principal expose bien `Accueil`, `Progrès`, `Réviser`, `Profil`.
- Les sessions quick et résultats quick utilisent les routes immersives `/revision-sessions/:sessionId` et `/revision-sessions/:sessionId/result`.
- Les routes `Today`, `Activities`, `RichClosed` restent déclarées comme legacy accessibles.
- Le détail matière envoyait encore `Réviser` vers `/activities?subjectId=...`.
- `CourseRevisionSheetPage` dépendait encore de `AppSpacing`.
- Les liens juridiques de l'écran de connexion restent volontairement hors scope.

## 3. Sub-agents utilisés

Les passes ont été menées avec sub-agents :

- Canonical Flow / Router Isolation Agent : classification routes et CTAs legacy.
- Feature Extraction Agent : candidates d'extraction dans cours, accueil, auth, détail matière.
- Design System / Dead Code Agent : ancien thème, assets, composants inutilisés et risques.

## 4. Parcours canonique final

```text
Accueil
-> cours
-> sources du cours / fiche / revision rapide
-> session quick
-> resultat quick
-> cours ou fiche
-> progres
```

```text
Reviser
-> quick direct
-> session quick
-> resultat quick
```

```text
Progres
-> cours
-> quick / fiche / sources
```

## 5. Routes support

- `/`
- `/sign-in`
- `/onboarding`
- `/subjects`
- `/subjects/:subjectId`
- `/sources`

## 6. Routes legacy conservées

- `/subjects/:subjectId/documents/:documentId`
- `/today`
- `/activities`
- `/activities/session`
- `/activities/rich-closed`

Ces routes restent accessibles directement et leurs tests existants restent verts. Elles ne sont plus introduites depuis le CTA `Réviser` du détail matière.

## 7. Routes legacy dépréciées

Les routes `Today`, `Activities`, `RichClosed` sont considérées `LEGACY_ACCESSIBLE` dans l'inventaire. Elles restent compilées et testées, mais ne sont pas des destinations principales de la bottom nav.

## 8. Code réellement supprimé

Aucun fichier n'a été supprimé.

Du code privé a été déplacé :

- `_SourcesBottomSheet` et helpers vers `CourseSourcesBottomSheet`.
- `_QuickRevisionQuestionCountSheet` et `_QuestionCountChip` vers `QuickRevisionQuestionCountSheet`.
- `_DocumentListItem` et helpers vers `SubjectDocumentListItem`.

## 9. Preuves avant suppression

Aucune suppression de fichier n'a été appliquée. Les éléments suivants ont été identifiés comme candidats mais conservés :

- `assets/brand/neralune_cat.svg` : non référencé par le code, mais conservé comme source complète de marque.
- `RevisionTextField` : aucune référence runtime trouvée, mais non supprimé dans ce lot pour éviter un nettoyage hors parcours canonique.
- `AppRoutes.revisionSessionSegment` : constante candidate à suppression, non supprimée car sans impact produit.

## 10. Widgets extraits

- `lib/features/courses/presentation/widgets/course_sources_bottom_sheet.dart`
- `lib/features/courses/presentation/widgets/quick_revision_question_count_sheet.dart`
- `lib/presentation/pages/subjects/widgets/subject_document_list_item.dart`

## 11. Règle de placement de chaque widget

- `CourseSourcesBottomSheet` reste dans `features/courses` car il dépend des providers et modèles de cours.
- `QuickRevisionQuestionCountSheet` reste dans `features/courses` car il est spécifique au démarrage quick course-level.
- `SubjectDocumentListItem` reste dans `presentation/pages/subjects/widgets` car il est propre au détail matière subject-level.
- Aucun composant extrait n'a été ajouté au design system : ils ne sont pas transverses.

## 12. Design system : composants conservés/créés

Aucun nouveau composant design system n'a été créé.

Composants premium réutilisés :

- `RevisionBottomSheetFrame`
- `RevisionFloatingAddButton`
- `RevisionSourceFileCard`
- `RevisionGradientButton`
- `RevisionEmptyState`
- `RevisionProcessingState`

## 13. Ancien thème : état final

Recherche dans le canonique demandé :

```bash
rg -n "presentation/theme|AppColors|AppSpacing|AppRadius|RevisionPanel|RevisionPage\\(" lib/features/courses lib/presentation/pages/profile lib/presentation/shell
```

Résultat : aucune occurrence.

Les composants historiques restent utilisés par routes legacy hors scope, notamment Activities/Today/RichClosed.

## 14. Détail matière : destination finale du CTA Réviser

Le CTA `Réviser` de `SubjectDetailPage` ouvre maintenant :

```text
/revisions
```

Il ne construit plus d'URL `/activities?subjectId=...`.

## 15. Création matière : décision retenue

Le comportement existant est conservé. La création de matière via onboarding/gestion matière reste une dette UX à traiter séparément si Yoahn veut un formulaire dédié hors onboarding.

## 16. Assets : état final

Conservés :

- `assets/brand/neralune_cat_body.svg`
- `assets/brand/neralune_cat_tail.svg`
- `assets/brand/google_g.svg`
- `assets/brand/neralune_cat.svg`

La mascotte Neralune n'a pas été modifiée.

## 17. Package Neralune : confirmation

Recherche :

```bash
rg -n "package:revision_app" lib test dev || true
```

Résultat : aucune occurrence.

Le package reste `Neralune`.

## 18. Liens juridiques : dette volontairement différée

Les liens `Conditions d’utilisation` et `Politique de confidentialité` n'ont pas été modifiés. Ils restent temporairement sans destination à la demande explicite du propriétaire du produit et seront traités avant publication.

## 19. Tests ajoutés/modifiés

Ajout :

- `test/features/subjects/subject_detail_page_test.dart` vérifie que le CTA `Réviser` du détail matière ouvre le hub canonique `/revisions` et non `Activities`.

Tests existants conservés :

- routes legacy directes ;
- Activities ;
- Today ;
- Documents ;
- courses ;
- revision sessions ;
- auth/onboarding/profile.

## 20. Commandes exécutées

```bash
flutter --version
```

Résultat : Flutter 3.44.0, Dart 3.12.0.

```bash
mkdir -p build/ios/SourcePackages build/macos/SourcePackages && flutter pub get
```

Résultat : succès. SPM conservé ; aucun CocoaPods généré.

```bash
dart analyze lib test
```

Résultat : `No issues found!`.

```bash
flutter test test/app/router/app_router_test.dart --reporter compact
flutter test test/app/revision_app_test.dart --reporter compact
flutter test test/features/auth --reporter compact
flutter test test/features/onboarding --reporter compact
flutter test test/features/profile --reporter compact
flutter test test/features/subjects --reporter compact
flutter test test/features/courses --reporter compact
flutter test test/features/revision_sessions --reporter compact
flutter test test/features/activities --reporter compact
flutter test test/features/today --reporter compact
flutter test test/features/documents --reporter compact
flutter test --reporter compact
```

Résultat : toutes les suites passent. Les suites longues Activities et full Flutter ont une sortie tronquée par l'outil, mais les commandes retournent le code 0 et finissent par `All tests passed!`.

## 21. Résultats exacts

- `dart analyze lib test` : 0 issue.
- `test/app/router/app_router_test.dart` : All tests passed.
- `test/app/revision_app_test.dart` : All tests passed.
- `test/features/auth` : All tests passed.
- `test/features/onboarding` : All tests passed.
- `test/features/profile` : All tests passed.
- `test/features/subjects` : All tests passed.
- `test/features/courses` : All tests passed.
- `test/features/revision_sessions` : All tests passed.
- `test/features/activities` : All tests passed.
- `test/features/today` : All tests passed.
- `test/features/documents` : All tests passed.
- `flutter test --reporter compact` : All tests passed.

## 22. Recherches statiques

```bash
rg -n "activitiesRoutePath|todayRoutePath|RichClosed|ActivitiesPage|TodayPage" lib/features/courses lib/presentation/pages/profile lib/presentation/shell lib/app/router || true
```

Résultat :

```text
lib/app/router/app_router.dart:146:                builder: (context, state) => const TodayPage(),
lib/app/router/app_router.dart:158:                builder: (context, state) => ActivitiesPage(
lib/app/router/app_router.dart:220:          child: RichClosedExercisePage(
```

Analyse : occurrences acceptables, uniquement déclarations de routes legacy conservées.

```bash
rg -n "presentation/theme|AppColors|AppSpacing|AppRadius|RevisionPanel|RevisionPage\\(" lib/features/courses lib/presentation/pages/profile lib/presentation/shell || true
```

Résultat : vide.

```bash
rg -n "package:revision_app" lib test dev || true
```

Résultat : vide.

```bash
rg -n "Loi normale|Kant|78%|4/5 bonnes|870|7 jours|streak|gemmes" lib/features/courses lib/presentation/pages lib/presentation/shell || true
```

Résultat : vide.

```bash
git diff --unified=0 | rg "onTap:\\s*\\(\\)\\s*\\{\\}|onPressed:\\s*\\(\\)\\s*\\{\\}" || true
```

Résultat : vide. Aucun callback vide nouveau.

## 23. Limitations

- Les routes legacy `Today`, `Activities` et `RichClosed` restent déclarées et testées.
- `DocumentDetailPage` reste un flow subject-level legacy accessible depuis le détail matière.
- `RevisionTextField` et `AppRoutes.revisionSessionSegment` restent des candidats de nettoyage futur.
- L'ancien thème existe encore pour des routes legacy hors parcours canonique.

## 24. Dette restante

- Décider du futur de Today dans ADAPT-01.
- Décider si Activities/RichClosed restent des flows visibles ou deviennent totalement internes.
- Remplacer le flow document subject-level par une approche course-level si le produit le confirme.
- Nettoyer les candidats morts dans un lot dédié, après validation produit.
- Implémenter les liens juridiques avant publication, conformément à la dette volontaire.

## 25. Fichiers créés

- `docs/ui/FRONTEND_CANONICAL_LEGACY_INVENTORY_V2.md`
- `docs/ui/STAB_02B_CANONICAL_FLOW_LEGACY_ISOLATION_REPORT.md`
- `lib/features/courses/presentation/widgets/course_sources_bottom_sheet.dart`
- `lib/features/courses/presentation/widgets/quick_revision_question_count_sheet.dart`
- `lib/presentation/pages/subjects/widgets/subject_document_list_item.dart`

## 26. Fichiers modifiés

- `docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md`
- `docs/roadmap/v2/LOT_TRACKER_V2.md`
- `lib/features/courses/presentation/course_detail_page.dart`
- `lib/features/courses/presentation/course_revision_sheet_page.dart`
- `lib/features/courses/presentation/courses_home_page.dart`
- `lib/presentation/pages/subjects/subject_detail_page.dart`
- `test/features/subjects/subject_detail_page_test.dart`

## 27. Fichiers supprimés

Aucun.

## 28. Auto-review

- Roadmap V2 lue.
- Rapports STAB-01A/B/C et STAB-02A relus.
- Routes classées canonical/support/legacy/dead candidate.
- CTA `Réviser` du détail matière corrigé.
- Widgets lourds extraits sans changement fonctionnel.
- Widgets feature-specific conservés hors design system.
- Liens juridiques non modifiés.
- Backend non modifié.
- GenKit non modifié.
- Aucun rename global.
- Aucune donnée fictive ajoutée.
- Aucun callback vide nouveau.
- Tests obligatoires exécutés.
- Recherches statiques exécutées.
- Trackers mis à jour.
- Inventaire et rapport créés.
- Aucun commit effectué.

## 29. Critique du prompt

Le prompt demande à la fois de ne pas vider `features/*/presentation` et de valider via une mention de tracker qui parle de le vider progressivement. J'ai privilégié la règle explicite du prompt et la contrainte d'architecture actuelle : extractions ciblées, pas de déplacement massif.

La suppression de code mort aurait pu être tentante, mais elle aurait mélangé isolation canonique et cleanup global. J'ai donc documenté les candidats plutôt que de supprimer prématurément.

## 30. Confirmation backend intact

Aucun fichier backend, Prisma, GenKit, provider IA ou contrat HTTP n'a été modifié.

## 31. Confirmation Git

Aucun commit, amend, merge, rebase, push ou tag n'a été effectué dans ce lot.
