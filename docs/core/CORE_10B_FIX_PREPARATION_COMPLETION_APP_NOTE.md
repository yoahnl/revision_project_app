# CORE-10B-fix — App note

## Resume

Le correctif `CORE-10B-fix` est porte cote API. Aucun code runtime Flutter n'a ete modifie.

## Contrat public

Le contrat public app reste inchange :

- `GET /courses/:courseId/question-bank/readiness`
- `POST /courses/:courseId/question-bank/prepare`
- `POST /courses/:courseId/revision-sessions/quick`
- statut utilisateur existant `questions en preparation`
- erreur quick existante `COURSE_QUICK_REVISION_QUESTIONS_PREPARING`

L'app n'a pas besoin d'adaptation tant que l'API conserve ces formes.

## Verification Marionette macOS

Marionette est disponible dans l'environnement Codex, mais aucune application Neralune Flutter debug avec VM service URI n'a ete detectee.

Process detectes :

- plusieurs serveurs `marionette_mcp` ;
- une application Flutter macOS `grimaldi` ;
- aucune application `revision_app` / Neralune connectable.

Verification non executee : il aurait ete trompeur de valider le parcours sur l'application Grimaldi.

## Validation app

Commande executee :

```bash
git diff --check
```

Resultat : succes.

## Roadmap

`CORE-10B` est marque `BLOCKED` cote app tant que la preuve runtime macOS demandee n'est pas disponible.

## Fichiers modifies cote app

- `docs/core/CORE_10B_FIX_PREPARATION_COMPLETION_APP_NOTE.md`
- `docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md`
- `docs/roadmap/v2/LOT_TRACKER_V2.md`

## Confirmation

- Aucun code Flutter runtime modifie.
- Aucun backend modifie depuis le repo app.
- Aucun commit n'a ete effectue pendant l'execution initiale du lot. Commit et push realises ensuite sur demande explicite de Yoahn.
