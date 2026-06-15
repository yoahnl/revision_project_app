# Smoke checks — Revision App

## 1. Objectif

Cette checklist sert à vérifier rapidement que la démo Revision App reste présentable après un changement backend, frontend ou infra.

Elle cible uniquement les chemins critiques :

- disponibilité API ;
- seed de démo ;
- plan du jour ;
- documents et notions ;
- résumé et fiche ;
- QCM ;
- question ouverte ;
- session de révision IA ;
- écran Flutter principal.

Elle ne remplace pas les tests automatisés ni une recette complète.

## 2. Prérequis

- API démarrée sur l’environnement à tester.
- Application Flutter pointée vers cette API.
- Un compte Firebase de démonstration existe déjà.
- L’UID Firebase de ce compte est connu par la personne qui exécute le smoke.
- Les migrations nécessaires ont déjà été appliquées sur la base cible.
- Ne jamais utiliser une base de production pour le seed.

Valeurs factices utilisées dans les exemples :

```bash
DEMO_FIREBASE_UID=demo-local-uid
DEMO_STUDENT_EMAIL=demo-revision@example.test
```

Ne pas remplacer ces exemples par un vrai UID ou un vrai token dans Git.

## 3. Commandes API non destructives

Depuis le dossier API :

```bash
npx prisma validate
npm run prisma:generate
npm run lint:check
npm test -- demo-seed --runInBand
npm run test:e2e -- --runInBand
```

Ne pas lancer :

```bash
npm run lint
npm run format
npm run test:cov
npx prisma db push
npx prisma migrate reset
```

## 4. Validation du seed dry-run

Le dry-run valide les garde-fous et affiche les objets prévus sans écrire en base.

```bash
cd api
DEMO_SEED_CONFIRM=revision-demo DEMO_FIREBASE_UID=demo-local-uid npm run demo:seed -- --dry-run
```

Attendu :

- sortie JSON ;
- `mode` vaut `dry-run` ;
- l’URL DB est masquée ;
- l’UID Firebase est masqué ;
- 1 matière ;
- 1 document ;
- plusieurs chunks ;
- plusieurs notions ;
- plusieurs mastery states ;
- aucun appel Genkit ;
- aucune écriture DB.

## 5. Validation optionnelle du seed réel sur DB locale/staging

Le seed réel est autorisé uniquement sur une base locale ou staging explicitement prévue pour la démo.

Exemple :

```bash
cd api
DEMO_SEED_CONFIRM=revision-demo \
DEMO_FIREBASE_UID=<uid-firebase-demo> \
DEMO_STUDENT_EMAIL=demo-revision@example.test \
DEMO_STUDENT_DISPLAY_NAME="Demo Revision" \
npm run demo:seed
```

Attendu :

- refus si `NODE_ENV=production` ;
- refus sans confirmation ;
- refus sans UID Firebase ;
- résumé des données créées ;
- aucune donnée hors namespace démo supprimée.

Le seed ne crée pas de compte Firebase. Il crée uniquement les lignes DB associées à l’UID fourni.

## 6. Smoke API `/health`

```bash
curl -sS "$API_URL/health"
```

Attendu :

```json
{"status":"ok"}
```

## 7. Smoke API `/today` avec token Firebase de démo

Récupérer un token Firebase depuis l’app ou un outil local sécurisé, sans le coller dans Git.

```bash
curl -sS "$API_URL/today" \
  -H "Authorization: Bearer <token-firebase-demo>"
```

Attendu :

- `generatedAt` présent ;
- `items` est une liste ;
- actions possibles : `diagnostic_quiz`, `open_question`, `revision_session` ;
- pas de contenu source complet inattendu ;
- pas de secret.

## 8. Smoke documents et notions

```bash
curl -sS "$API_URL/subjects/<subject-id>/documents" \
  -H "Authorization: Bearer <token-firebase-demo>"

curl -sS "$API_URL/documents/<document-id>" \
  -H "Authorization: Bearer <token-firebase-demo>"

curl -sS "$API_URL/documents/<document-id>/knowledge-units" \
  -H "Authorization: Bearer <token-firebase-demo>"
```

Attendu :

- document READY visible ;
- notions visibles ;
- sources visibles sous forme bornée ;
- pas de `storagePath` dans les réponses publiques.

Le document seedé est un document logique READY. Il ne correspond pas à un PDF physique importé.

## 9. Smoke résumé / fiche

```bash
curl -sS "$API_URL/documents/<document-id>/summary" \
  -H "Authorization: Bearer <token-firebase-demo>"

curl -sS "$API_URL/documents/<document-id>/revision-sheet" \
  -H "Authorization: Bearer <token-firebase-demo>"
```

Attendu :

- résumé READY ;
- fiche READY ;
- sources bornées ;
- pas de `promptVersion`, `provider`, `model`, `storagePath` dans la réponse publique.

## 10. Smoke QCM

```bash
curl -sS "$API_URL/activities/next" \
  -H "Authorization: Bearer <token-firebase-demo>" \
  -H "Content-Type: application/json" \
  -d '{"subjectId":"<subject-id>","knowledgeUnitId":"<knowledge-unit-id>","questionCount":10}'
```

Attendu pré-submit :

- type `diagnostic_quiz` ;
- questions visibles ;
- choix visibles ;
- pas de `correctChoiceId` ;
- pas de `correctChoiceIds` ;
- pas de feedback/correction.

Les QCM ne sont pas seedés directement. Ils sont générés ou lancés par les use cases existants.

## 11. Smoke question ouverte

```bash
curl -sS "$API_URL/activities/open-question" \
  -H "Authorization: Bearer <token-firebase-demo>" \
  -H "Content-Type: application/json" \
  -d '{"subjectId":"<subject-id>","knowledgeUnitId":"<knowledge-unit-id>"}'
```

Attendu pré-submit :

- type `open_question` ;
- prompt visible ;
- sources sans texte complet ;
- pas de `modelAnswer` ;
- pas de score ;
- pas de feedback.

Soumission :

```bash
curl -sS "$API_URL/activities/<session-id>/open-answer" \
  -H "Authorization: Bearer <token-firebase-demo>" \
  -H "Content-Type: application/json" \
  -d '{"answerText":"Réponse de démonstration structurée, sans donnée personnelle."}'
```

Attendu post-submit :

- évaluation `READY` ou `FAILED` contrôlé ;
- pas de stack trace ;
- pas de message provider brut.

## 12. Smoke session de révision IA

```bash
curl -sS "$API_URL/revision-sessions" \
  -H "Authorization: Bearer <token-firebase-demo>" \
  -H "Content-Type: application/json" \
  -d '{"subjectId":"<subject-id>","knowledgeUnitId":"<knowledge-unit-id>"}'
```

Attendu :

- session STARTED ;
- action initiale déterministe ;
- payload métier public ;
- pas de widget arbitraire ;
- pas de correction pré-submit.

Action suivante :

```bash
curl -sS "$API_URL/revision-sessions/<session-id>/next-action" \
  -H "Authorization: Bearer <token-firebase-demo>" \
  -X POST
```

Attendu :

- action bornée ;
- pas de chatbot libre ;
- pas de payload arbitraire.

## 13. Smoke frontend manuel

Dans l’app Flutter :

1. Se connecter avec le compte Firebase de démonstration.
2. Ouvrir `Aujourd'hui`.
3. Vérifier plusieurs actions dans le plan du jour.
4. Lancer un QCM depuis Today.
5. Lancer une question ouverte depuis Today.
6. Lancer une session de révision IA depuis Today.
7. Ouvrir la matière de démo.
8. Ouvrir le document de démo.
9. Vérifier les notions sourcées.
10. Vérifier le résumé et la fiche si l’UI les expose.

Attendu :

- pas d’écran vide inattendu ;
- pas de correction QCM avant submit ;
- pas de source complète pré-submit ;
- messages d’erreur propres en cas d’échec IA.

## 14. Signaux rouges / rollback

Arrêter la démo et investiguer si :

- `/health` échoue ;
- `/today` retourne une erreur 500 ;
- le seed réel a été lancé sur une mauvaise base ;
- la page Today affiche zéro action malgré le seed ;
- un payload pré-submit contient `correctChoiceId`, `correctChoiceIds` ou `modelAnswer` ;
- un endpoint renvoie une stack trace ;
- un token réel, UID réel ou secret a été copié dans un fichier du repo.

## 15. Ce qui ne doit jamais être fait en production

- Ne jamais lancer le seed réel en production.
- Ne jamais lancer `prisma migrate reset`.
- Ne jamais lancer `prisma db push --force-reset`.
- Ne jamais écrire un token Firebase réel dans Git.
- Ne jamais écrire un UID personnel dans Git.
- Ne jamais exposer `DATABASE_URL`, clés IA ou secrets Redis dans une doc.
- Ne jamais utiliser le dry-run comme preuve que les données ont été écrites.
