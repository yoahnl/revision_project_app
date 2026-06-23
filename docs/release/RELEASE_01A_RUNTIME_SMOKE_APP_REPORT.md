# RELEASE-01A — Runtime smoke App report

## Verdict

`DONE`, après confirmation opérateur du smoke MVP complet.

L'app CORE-11B est déployée côté Dokploy et le code contient les routes et providers nécessaires au smoke MVP. Deux corrections runtime minimales ont été appliquées : accès réseau client macOS et URL scheme iOS Google Sign-In. Le smoke MVP complet a été confirmé manuellement par l'opérateur humain du projet après le gate RELEASE-01A. Codex n'a pas exécuté ce parcours complet lui-même.

## Confirmation opérateur

Le smoke MVP complet a été confirmé manuellement par l'opérateur humain du projet après le gate RELEASE-01A. Codex n'a pas exécuté ce parcours complet lui-même ; cette clôture documente une confirmation opérateur. Aucun secret, token Firebase, URL privée sensible ou PDF de test n'est documenté dans ce rapport.

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

Non exécuté par Codex.

Le scénario complet a été confirmé manuellement par l'opérateur humain du projet. Le runbook canonique reste dans le repo API : `docs/release/RELEASE_01A_MVP_RUNTIME_SMOKE_RUNBOOK.md`.

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

La réserve de validation RELEASE-01A est levée par confirmation opérateur. RELEASE-01A est donc clôturé en `DONE`.

## Risques restants

- La preuve runtime complète reste une confirmation opérateur et non une exécution Codex.
- Les secrets et fichiers de test ne sont volontairement pas documentés.

## Fichiers créés/modifiés

Créé côté App :

- `docs/release/RELEASE_01A_RUNTIME_SMOKE_APP_REPORT.md`
- `docs/release/RELEASE_01A_RUNTIME_SMOKE_EVIDENCE_PACK.md`
- `docs/release/RELEASE_01A_OPERATOR_CONFIRMED_CLOSURE_APP_REPORT.md`

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
- Le statut `DONE` est utilisé uniquement après confirmation opérateur du smoke MVP complet.

## Confirmation Git

Ce rapport initial a été créé avant le commit/push du gate RELEASE-01A. La clôture operator-confirmed ultérieure est documentée dans `docs/release/RELEASE_01A_OPERATOR_CONFIRMED_CLOSURE_APP_REPORT.md`.
