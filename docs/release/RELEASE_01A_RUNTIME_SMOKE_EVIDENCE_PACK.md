# RELEASE-01A — Runtime smoke App evidence pack

## Verdict

`DONE`, après confirmation opérateur du smoke MVP complet.

## Confirmation opérateur

Smoke MVP complet confirmé manuellement par l'opérateur humain.
Codex n'a pas exécuté le smoke complet.
Aucun secret, token ou PDF de test n'est documenté.

## Preuves App

- `AppConfig.apiBaseUrl` utilise `API_BASE_URL`, fallback `https://revision-api.yoahn.me`.
- `dioProvider` applique cette base URL globalement.
- `dev/marionette_main.dart` utilise la même configuration et journalise les requêtes HTTP sans headers ni bodies.
- Les routes session et résultat existent dans `AppRoutes`.
- Les appels repository couvrent quick, resumable, history, draft-answer, complete et result.

## Corrections runtime appliquées

- `macos/Runner/DebugProfile.entitlements` : ajout local de `com.apple.security.network.client`.
- `macos/Runner/Release.entitlements` : ajout local de `com.apple.security.network.client`.
- `ios/Runner/Info.plist` : ajout local du URL scheme Google basé sur `REVERSED_CLIENT_ID`.

## Preuves Dokploy

- Frontend CORE-11B déployé : commit `fbdb1e824732bd56151b4b0ebbd11d531ffc4ccb`, status `done`.
- Backend CORE-11B déployé : commit `1804aee2ea9bf68d2b12d68a1e4b955c06c3935e`, status `done`.

## Smoke Marionette

Non exécuté par Codex.

Le smoke MVP complet a été confirmé manuellement par l'opérateur humain du projet après le gate RELEASE-01A. Le runbook de référence reste côté API : `docs/release/RELEASE_01A_MVP_RUNTIME_SMOKE_RUNBOOK.md`.

## Commandes locales exécutées

```text
plutil -lint macos/Runner/DebugProfile.entitlements macos/Runner/Release.entitlements ios/Runner/Info.plist -> OK
dart analyze lib test -> OK, no issues found
flutter test test/features/courses/course_detail_page_test.dart --reporter compact -> 20 tests passed
flutter test test/features/courses/http_courses_repository_test.dart --reporter compact -> 29 tests passed
flutter test test/features/revision_sessions --reporter compact -> 42 tests passed
flutter test --reporter compact -> 494 tests passed
git diff --check -> OK
```

## Fichiers créés

- `docs/release/RELEASE_01A_RUNTIME_SMOKE_APP_REPORT.md`
- `docs/release/RELEASE_01A_RUNTIME_SMOKE_EVIDENCE_PACK.md`
- `docs/release/RELEASE_01A_OPERATOR_CONFIRMED_CLOSURE_APP_REPORT.md`

## Fichiers modifiés

- `macos/Runner/DebugProfile.entitlements`
- `macos/Runner/Release.entitlements`
- `ios/Runner/Info.plist`
- `docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md`
- `docs/roadmap/v2/LOT_TRACKER_V2.md`

## Limite de preuve

Le runtime App a été préparé par Codex, et le smoke MVP complet a été confirmé manuellement par l'opérateur humain. RELEASE-01A est donc clôturé `DONE` sans prétendre que Codex a exécuté le smoke complet.
