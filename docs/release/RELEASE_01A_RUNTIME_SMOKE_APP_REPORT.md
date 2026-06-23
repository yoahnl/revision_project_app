# RELEASE-01A — Runtime smoke App report

## Verdict

`READY_FOR_RUNTIME`, représenté par `IN_PROGRESS` dans les trackers App car le statut `READY_FOR_RUNTIME` n'est pas listé parmi les statuts autorisés.

L'app CORE-11B est déployée côté Dokploy et le code local contient les routes et providers nécessaires au smoke MVP. Deux corrections runtime minimales ont été appliquées localement : accès réseau client macOS et URL scheme iOS Google Sign-In. Elles devront être commit/push/build avant validation runtime finale. Le smoke utilisateur complet n'a pas été exécuté avec Marionette, car il exige une session authentifiée, un PDF et un parcours backend réel contrôlé.

## Audit initial avant correction

### Configuration API

- `AppConfig.apiBaseUrl` lit `API_BASE_URL`.
- La valeur par défaut est `https://revision-api.yoahn.me`.
- `lib/app/di/infrastructure_providers.dart` construit `Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl))`.
- `ios/ci_scripts/ci_post_clone.sh` transmet `API_BASE_URL` via `--dart-define`.

### Auth / Firebase

- L'app initialise Firebase via `lib/firebase_options.dart`.
- Le smoke complet nécessite un utilisateur authentifié ; Codex n'a pas reçu de credentials et ne doit pas extraire de token depuis les logs.

### Routes critiques

Routes côté app présentes :

- détail cours ;
- session `/revision-sessions/:sessionId` ;
- résultat `/revision-sessions/:sessionId/result`.

Parcours CORE-11A/CORE-11B côté App :

- `getResumableCourseRevisionSession` ;
- sauvegarde et suppression de draft ;
- completion quick ;
- `getCourseRevisionSessionHistory` ;
- ouverture résultat depuis historique.

### Marionette

- `dev/marionette_main.dart` existe.
- `dev/README.md` documente :
  - lancement macOS ;
  - lancement iOS simulator ;
  - override `API_BASE_URL` ;
  - logs HTTP sans headers ni bodies.

## Dokploy

Lecture seule uniquement.

- Frontend CORE-11B déployé : oui.
- Commit App déployé : `fbdb1e824732bd56151b4b0ebbd11d531ffc4ccb`.
- Déploiement : `CORE-11B session history app`, status `done`.
- Backend CORE-11B déployé : oui, commit `1804aee2ea9bf68d2b12d68a1e4b955c06c3935e`.

## Corrections faites

Corrections runtime App :

- `com.apple.security.network.client=true` ajouté aux entitlements macOS debug et release pour autoriser les appels API/Firebase en sandbox.
- `CFBundleURLTypes` iOS ajouté avec le `REVERSED_CLIENT_ID` Google pour permettre le retour OAuth Google Sign-In.

Corrections documentaires :

- création du rapport App RELEASE-01A ;
- mise à jour des trackers App.

## Smoke Marionette

Non exécuté.

Raison : le scénario complet nécessite un compte connecté, un PDF de test, une création de données et une confirmation de worker backend. Le runbook canonique est dans le repo API : `docs/release/RELEASE_01A_MVP_RUNTIME_SMOKE_RUNBOOK.md`.

## Tests exécutés

Résultats :

- `plutil -lint macos/Runner/DebugProfile.entitlements macos/Runner/Release.entitlements ios/Runner/Info.plist` : OK.
- `dart analyze lib test` : OK, no issues found.
- `flutter test test/features/courses/course_detail_page_test.dart --reporter compact` : 20 tests passed.
- `flutter test test/features/courses/http_courses_repository_test.dart --reporter compact` : 29 tests passed.
- `flutter test test/features/revision_sessions --reporter compact` : 42 tests passed.
- `flutter test --reporter compact` : 494 tests passed.
- `git diff --check` : OK.

## Blockers release

Pas de blocker App statique détecté.

Blocker de validation : smoke MVP complet non exécuté avec Marionette ou app réelle authentifiée.

## Risques restants

- Aucun test runtime n'a confirmé la restauration de draft et l'historique depuis l'app déployée après CORE-11B.
- Le smoke dépend d'un compte Firebase et d'un PDF de test non fournis à Codex.

## Fichiers créés/modifiés

Créé côté App :

- `docs/release/RELEASE_01A_RUNTIME_SMOKE_APP_REPORT.md`
- `docs/release/RELEASE_01A_RUNTIME_SMOKE_EVIDENCE_PACK.md`

Modifiés côté App :

- `macos/Runner/DebugProfile.entitlements`
- `macos/Runner/Release.entitlements`
- `ios/Runner/Info.plist`
- `docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md`
- `docs/roadmap/v2/LOT_TRACKER_V2.md`

## Auto-review finale

- Aucun changement UI ou feature.
- Aucun secret copié.
- Aucune preuve runtime inventée.
- `DONE` non utilisé.

## Confirmation Git

Aucun commit effectué.
