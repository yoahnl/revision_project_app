# CORE-10B-fix-2 — Quick readiness UX app report

## 1. Resume

Ce micro-lot corrige la coherence Flutter autour de la readiness quick :

- readiness target-aware par `courseId` + `questionCount`;
- action principale et carte quick alignees;
- selecteur `5 / 10 / 20 / 30` honnete;
- polling dedie a la cible preparee;
- disponibilite partielle exploitee, par exemple `9 questions prêtes` permet de lancer `5`.

Le code app est valide localement. Le lot reste `BLOCKED` cote roadmap, car la preuve runtime Marionette demandee n'a pas pu etre executee : l'app Neralune debug detectee n'expose pas l'extension Marionette.

## 2. Diagnostic exact

Avant ce fix, l'ecran pouvait afficher simultanement :

```text
Commencer une session rapide
Révision rapide — En préparation
```

Le premier message etait derive de la source PDF `READY`, alors que le second etait derive de la readiness question bank pour 10 questions. Une banque a `9/10` etait donc partiellement exploitable, mais l'UI ne le disait pas clairement.

## 3. Source de verite Flutter

La readiness n'est plus implicitement figee a `10`.

Le provider utilise maintenant une cle explicite :

```dart
({String courseId, int questionCount})
```

Cela permet d'observer separement :

```text
readiness(courseId, 5)
readiness(courseId, 10)
readiness(courseId, 20)
readiness(courseId, 30)
```

## 4. Matrice 5/10/20/30

Le selecteur affiche une disponibilite par quantite :

```text
readyQuestionCount >= quantite -> Pret
readyQuestionCount < quantite + job actif -> En preparation
readyQuestionCount < quantite + aucun job actif -> A preparer
failed pertinent -> A relancer
```

Exemple couvert par test :

```text
readyQuestionCount = 9
5  -> Pret
10 -> En preparation
20 -> A preparer
30 -> A preparer
```

La selection par defaut devient la plus grande quantite immediatement disponible. Dans le cas `9 questions prêtes`, `5` est selectionne par defaut.

## 5. Actions utilisateur

Le selecteur retourne une intention explicite :

```text
start   -> POST /revision-sessions/quick
prepare -> POST /question-bank/prepare
wait    -> bouton disabled
```

L'app ne lance donc plus volontairement le endpoint quick pour utiliser son `409` comme mecanisme normal de preparation. Le `409` reste un filet de securite.

## 6. Course detail

L'action principale du detail cours tient compte de la readiness :

- aucune source prete : comportement existant conserve;
- readiness loading : `Verification...`;
- au moins 5 questions pretes : `Réviser maintenant`;
- preparation active et moins de 5 questions : `Préparation en cours`;
- aucun pool exploitable : `Préparer les questions`.

Avec `9/10`, l'ecran affiche une disponibilite partielle plutot qu'une contradiction.

## 7. Polling Flutter

Un polling dedie question bank a ete ajoute dans le detail cours :

- demarre sur `PREPARING` ou apres `prepare`;
- frequence : 2 secondes;
- invalide la cle exacte `courseId + target`;
- suit la cible preparee, y compris `20`, sans s'arreter seulement parce que `10` devient disponible;
- s'arrete sur `READY`, `FAILED`, `NOT_PREPARED`, dispose ou timeout;
- n'accumule pas plusieurs timers.

Message timeout :

```text
La préparation prend plus de temps que prévu. Tu peux réessayer ou revenir plus tard.
```

## 8. Marionette macOS

Marionette est disponible.

Une app Flutter macOS Neralune debug est detectee avec VM service locale.

Connexion tentee :

```text
ws://127.0.0.1:55354/QiFNi8J3CPY=/ws
```

Resultat :

```text
Failed to connect to app: No isolate found with ext.flutter.marionette.getLogs extension.
Make sure the Flutter app has marionette_flutter initialized.
```

Conclusion : validation visuelle Marionette non executee. L'app Neralune presente n'est pas instrumentee Marionette dans cette session.

## 9. Tests app executes

Commandes executees et resultats :

```text
dart format sur fichiers Dart modifies -> succes
dart analyze fichiers Dart modifies -> succes, no issues
flutter test test/features/courses/course_detail_page_test.dart --reporter compact -> succes, 16 tests passed
flutter --version -> Flutter 3.44.0 stable, Dart 3.12.0
flutter analyze -> echec outil Flutter analysis server, FormatException unexpected end of input, crash report flutter_01.log
dart analyze lib test -> succes, no issues
flutter test --reporter compact -> succes, 480 tests passed
```

Le crash `flutter analyze` est un crash de l'analysis server Flutter, pas un diagnostic projet. `dart analyze lib test` passe.

## 10. Tests ajoutes ou modifies

- Fake repository courses enrichi avec readiness par cible.
- Test widget `readyQuestionCount=9` :
  - affiche une disponibilite partielle;
  - ne contredit pas l'action principale;
  - marque `5` comme pret;
  - marque `10` en preparation;
  - marque `20` et `30` a preparer;
  - demarre une session de 5 questions.

## 11. Fichiers modifies

- `lib/features/courses/application/courses_providers.dart`
- `lib/features/courses/presentation/course_detail_page.dart`
- `lib/features/courses/presentation/widgets/quick_revision_question_count_sheet.dart`
- `test/fakes/in_memory_courses_repository.dart`
- `test/features/courses/course_detail_page_test.dart`
- `docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md`
- `docs/roadmap/v2/LOT_TRACKER_V2.md`

## 12. Fichiers crees

- `docs/core/CORE_10B_FIX_2_QUICK_READINESS_UX_APP_REPORT.md`

## 13. Roadmap

Etat conserve :

```text
CORE-10B = BLOCKED
CORE-10 = IN_PROGRESS
CORE-10C = TODO
```

Raison : tests app OK, mais preuve runtime Marionette et preuve worker Dokploy fix-2 non disponibles.

## 14. Limites restantes

- La preuve visuelle macOS A/B/C/D du prompt n'a pas pu etre executee sans extension Marionette dans l'app.
- La preuve de transition backend deployee `9/10 -> 10/10 -> quick 10` attend le deploiement du correctif API fix-2.
- Le polling est teste par comportement widget et par analyse du code, pas par Marionette runtime.

## 15. Auto-review

- Pas de CORE-10C.
- Pas de nouvelle page.
- Pas de generation IA dans l'app.
- Pas de jargon provider/model expose a l'utilisateur.
- Pas de format global.
- Source de verite target-aware ajoutee.
- Selecteur 5/10/20/30 honnete.
- Polling target-aware annule au dispose.
- Tests Flutter complets passes via `flutter test`.
- `flutter analyze` a crashe cote outil, `dart analyze lib test` passe.
- Aucun commit effectue.

## 16. Critique du prompt

La demande de ne pas lancer de format global est en tension avec la commande `dart format --output=none --set-exit-if-changed lib test`. Le choix applique a ete de formater uniquement les fichiers modifies, puis de verifier l'analyse et les tests. C'est plus coherent avec la contrainte historique du repo.

