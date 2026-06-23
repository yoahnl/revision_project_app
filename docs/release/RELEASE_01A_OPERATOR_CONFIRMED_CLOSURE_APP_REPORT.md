# RELEASE-01A — Operator-confirmed closure App report

## Résumé

RELEASE-01A est clôturé côté App en `DONE` sur la base d'une confirmation opérateur du smoke MVP complet. Codex avait préparé le gate runtime, vérifié la configuration App, corrigé l'accès réseau macOS et le retour OAuth Google iOS, puis exécuté les validations locales. Codex n'a pas exécuté lui-même le smoke complet.

## Audit initial avant clôture

- `docs/release/RELEASE_01A_RUNTIME_SMOKE_APP_REPORT.md` existait et déclarait encore `READY_FOR_RUNTIME` / `IN_PROGRESS`.
- `docs/release/RELEASE_01A_RUNTIME_SMOKE_EVIDENCE_PACK.md` existait et indiquait que RELEASE-01A ne pouvait pas passer `DONE` sans validation par app réelle ou Marionette.
- `ios/Runner/Info.plist` contient `CFBundleURLTypes` avec le scheme Google Sign-In.
- `macos/Runner/DebugProfile.entitlements` contient `com.apple.security.network.client`.
- `macos/Runner/Release.entitlements` contient `com.apple.security.network.client`.
- Les trackers App listaient `RELEASE-01A` et `RELEASE-01` en `IN_PROGRESS`.

## Ce qui avait été préparé par RELEASE-01A

- Audit de la configuration API base URL.
- Audit des routes session, résultat, reprise et historique.
- Vérification de la présence Marionette et de sa documentation.
- Correction macOS pour autoriser les appels réseau en sandbox.
- Correction iOS pour permettre le retour Google Sign-In.
- Evidence pack sans secrets.
- Trackers alignés sur l'état `READY_FOR_RUNTIME`.

## Confirmation opérateur

Le smoke MVP complet a été confirmé manuellement par l'opérateur humain du projet après le gate RELEASE-01A. Codex n'a pas exécuté ce parcours complet lui-même ; cette clôture documente une confirmation opérateur. Aucun secret, token Firebase, URL privée sensible ou PDF de test n'est documenté.

## Ce qui est maintenant considéré comme fermé

- RELEASE-01A passe à `DONE`.
- RELEASE-01 passe à `DONE` côté App, car aucun autre sous-lot RELEASE-01 obligatoire n'est listé dans les trackers App.
- La réserve `smoke MVP complet encore à exécuter` est remplacée par `smoke MVP complet confirmé manuellement par l'opérateur humain`.

## Ce qui n'a pas été exécuté directement par Codex

- Smoke Marionette complet.
- Connexion utilisateur réelle.
- Upload d'un PDF de test.
- Reprise/complétion runtime complète pendant cette clôture.
- Ouverture du résultat depuis l'historique pendant cette clôture.

## Corrections documentaires appliquées

- Rapport App RELEASE-01A enrichi avec une section `Confirmation opérateur`.
- Evidence pack App enrichi avec une section `Confirmation opérateur`.
- Trackers App mis à jour en `DONE`.

## État des trackers

- `RELEASE-01A` : `DONE`.
- `RELEASE-01` : `DONE`.

## Fichiers modifiés

- `docs/release/RELEASE_01A_RUNTIME_SMOKE_APP_REPORT.md`
- `docs/release/RELEASE_01A_RUNTIME_SMOKE_EVIDENCE_PACK.md`
- `docs/release/RELEASE_01A_OPERATOR_CONFIRMED_CLOSURE_APP_REPORT.md`
- `docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md`
- `docs/roadmap/v2/LOT_TRACKER_V2.md`

## Validations exécutées

Résultats de clôture :

- `plutil -lint macos/Runner/DebugProfile.entitlements macos/Runner/Release.entitlements ios/Runner/Info.plist` : OK.
- `dart analyze lib test` : OK, no issues found.
- `flutter test --reporter compact` : 494 tests passed.
- `git diff --check` : OK.

## Risques restants

- La preuve de smoke complet est une confirmation opérateur, pas une trace exécutée par Codex.
- Le runbook reste nécessaire pour reproduire le smoke lors des futures releases.
- Les secrets et fichiers de test ne sont volontairement pas documentés.

## Prochaines étapes post-MVP recommandées

- Garder Marionette comme outil de smoke visuel reproductible.
- Ajouter plus tard un scénario smoke automatisé uniquement si un compte de test et un dataset contrôlé sont disponibles.
- Refaire le smoke manuel avant toute release publique majeure.

## Auto-review finale

- Aucune UI modifiée.
- Aucun flow métier modifié.
- Aucun secret documenté.
- Aucune preuve runtime inventée.
- La confirmation opérateur est formulée explicitement.
- RELEASE-01 n'est passé `DONE` que parce que le tracker App ne liste aucun autre sous-lot RELEASE-01 obligatoire.

## Critique du prompt

Le prompt est bien cadré pour une clôture documentaire : il permet d'acter une confirmation humaine sans la transformer en preuve exécutée par Codex. La limite principale est l'absence d'artefact runtime consultable dans le repo ; le rapport reste donc volontairement prudent.
